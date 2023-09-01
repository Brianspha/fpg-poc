// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IFPG} from "../interfaces/IFPG.sol";
import "../utils/FPGStructs.sol";
import "../utils/FPGErrors.sol";
import {FPGModifiers} from "../utils/FPGModifiers.sol";
import {FPGEvents} from "../utils/FPGEvents.sol";
import {FPGUtils} from "../utils/FPGUtils.sol";

import {StreamCreator} from "../sablier/StreamCreator.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {IERC20} from "@sablier/v2-core/src/types/Tokens.sol";

/// @title FPG
/// @author brianspha
/// @notice Implementation of IFPG
/// @dev Contains bugs and is not optimised for GAS!!!
contract FPG is
    IFPG,
    PausableUpgradeable,
    OwnableUpgradeable,
    UUPSUpgradeable,
    FPGEvents,
    FPGModifiers
{
    /**
     *
     *                              Modifiers
     *
     */
    modifier whenFundingRevocable() {
        if (!fundingRevocable) revert NonRefundable();
        _;
    }
    modifier whenNotBlackListed() {
        if (blacklist[_msgSender()]) {
            revert CallerBanned();
        }
        _;
    }
    modifier whenNotActiveAlready(bytes memory project) {
        if (activeProjects[project]) revert ProjectAlreadyActive();
        _;
    }
    modifier whenProjectActive(bytes memory project) {
        if (!activeProjects[project]) revert ProjectNotActive();
        _;
    }
    modifier onlyProjectOwner(bytes memory project) {
        if (_msgSender() != projects[project].owner) revert NotProjectOwner();
        _;
    }
    modifier whenFeatureNotCompleted(
        bytes memory project,
        bytes memory branchName
    ) {
        if (
            projects[project].fundingRequests[branchName].status ==
            FeatureStatus.Completed
        ) revert FeatureCompleted();
        _;
    }
    modifier whenStartDateReached(
        bytes memory project,
        bytes memory branchName
    ) {
        if (
            projects[project].fundingRequests[branchName].startDate >=
            block.timestamp
        ) revert StartDateNotReached();
        _;
    }
    /**
     *
     *                              State Variables
     *
     */

    IERC20 public acceptedToken;
    StreamCreator public streamCreator;
    bool public fundingRevocable;
    mapping(bytes url => FPGProject project) public projects;
    mapping(address owner => bool status) public blacklist;
    mapping(bytes projectURL => bool projectActive) public activeProjects;
    bytes[] public projectURLs;

    /**
     *
     *                              Functions
     *
     */

    function initialize(
        StreamCreator sablier,
        bool revocable
    ) public override initializer {
        if (address(sablier) == address(0)) revert ZeroAddress();
        streamCreator = sablier;
        acceptedToken = sablier.streamingToken();
        fundingRevocable = revocable;
        __Ownable_init();
        __UUPSUpgradeable_init();
        __Pausable_init();
    }

    /// @inheritdoc	IFPG
    function addProject(
        bytes memory projectURL
    )
        external
        override
        whenNotPaused
        whenNotBlackListed
        whenNotActiveAlready(projectURL)
    {
        if (_msgSender() == address(0)) revert ZeroAddress();
        FPGUtils.verifyBytesLengthNotZero(projectURL, "Invalid URL");

        projects[projectURL].owner = _msgSender();
        projects[projectURL].url = projectURL;
        activeProjects[projectURL] = true;
        projectURLs.push(projectURL);
        emit FPGProjectAdded(_msgSender(), projectURL);
    }

    /// @inheritdoc	IFPG
    function requestFeatureFunding(
        bytes memory projectURL,
        bytes memory branchName,
        bytes memory featureName,
        uint256 startDate,
        uint256 duration
    )
        public
        override
        whenNotPaused
        whenNotBlackListed
        whenProjectActive(projectURL)
    {
        FPGUtils.verifyGreaterThanZeroAndBlockNow(
            uint40(startDate),
            "Invalid startDate"
        );
        FPGUtils.verifyGreaterThanZeroAndBlockNow( uint40(duration), "Invalid duration");
        FPGUtils.verifyBytesLengthNotZero(branchName, "Invalid branch name");
        FPGUtils.verifyBytesLengthNotZero(featureName, "Invalid feature name");
        FPGUtils.verifyBytesLengthNotZero(projectURL, "Invalid URL");
        projects[projectURL]
            .fundingRequests[branchName]
            .featureName = featureName;
        projects[projectURL].fundingRequests[branchName].startDate = uint40(
            startDate
        );
        projects[projectURL].fundingRequests[branchName].duration = uint40(
            duration
        );
        projects[projectURL].fundingRequests[branchName].status = FeatureStatus
            .FundingPhase;

        projects[projectURL].branches.push(branchName);
        emit FeatureFundingRequest(
            _msgSender(),
            branchName,
            featureName,
            uint40(
            startDate
        ),
            uint40(
            duration
        )
        );
    }

    /// @inheritdoc	IFPG
    function fundFeature(
        bytes memory projectURL,
        bytes memory branchName,
        uint256 amount
    ) external whenNotPaused {
        FPGUtils.verifyBytesLengthNotZero(projectURL, "Invalid URL");
        FPGUtils.verifyBytesLengthNotZero(branchName, "Invalid branch name");
        FPGUtils.verifyApproveAvailable(
            acceptedToken,
            _msgSender(),
            address(this),
            amount
        );

        ///@dev Transfer tokens to this contract
        assert(acceptedToken.transferFrom(_msgSender(), address(this), amount));
        projects[projectURL]
            .fundingRequests[branchName]
            .fundsCommitted += amount;
        projects[projectURL].fundingRequests[branchName].funders[
            _msgSender()
        ] += amount;
        emit ProjectFundingCommitment(branchName, amount);
    }

    /// @inheritdoc	IFPG
    function stopFundingFeature(
        bytes memory projectURL,
        bytes memory branchName
    ) public override whenFundingRevocable {
        FPGUtils.verifyBytesLengthNotZero(projectURL, "Invalid URL");
        FPGUtils.verifyBytesLengthNotZero(branchName, "Invalid branch name");
        if (
            projects[projectURL].fundingRequests[branchName].status ==
            FeatureStatus.Completed
        ) {
            revert ProjectConculded();
        }
        if (
            projects[projectURL].fundingRequests[branchName].funders[
                _msgSender()
            ] > 0
        ) {
            revert NotRefundAvailable();
        }
        uint256 amount = projects[projectURL]
            .fundingRequests[branchName]
            .funders[_msgSender()];
        projects[projectURL]
            .fundingRequests[branchName]
            .fundsCommitted -= amount;
        projects[projectURL].fundingRequests[branchName].funders[
            _msgSender()
        ] = 0;
        assert(acceptedToken.transferFrom(address(this), _msgSender(), amount));
        emit RevokedFunding(_msgSender(), projectURL, branchName);
    }

    /// @inheritdoc	IFPG
    function updateFeatureStatus(
        bytes memory projectURL,
        bytes memory branchName,
        FeatureStatus status
    ) public override whenFeatureNotCompleted(projectURL, branchName) {
        FPGUtils.verifyBytesLengthNotZero(projectURL, "Invalid URL");
        FPGUtils.verifyBytesLengthNotZero(branchName, "Invalid branch name");
        projects[projectURL].fundingRequests[branchName].status = status;
        emit ProjectStatusUpdated(projectURL, branchName, status);
    }

    /// @inheritdoc	IFPG

    function startProject(
        bytes memory projectURL,
        bytes memory branchName
    )
        public
        override
        whenNotBlackListed
        whenProjectActive(projectURL)
        whenFeatureNotCompleted(projectURL, branchName)
        onlyProjectOwner(projectURL)
        whenStartDateReached(projectURL, branchName)
    {
        FPGUtils.verifyBytesLengthNotZero(projectURL, "Invalid URL");
        FPGUtils.verifyBytesLengthNotZero(branchName, "Invalid branch name");

        projects[projectURL].fundingRequests[branchName].status = FeatureStatus
            .InProgress;
        acceptedToken.approve(
            address(streamCreator),
            projects[projectURL].fundingRequests[branchName].fundsCommitted
        );
        streamCreator.createLockupLinearStream(
            _msgSender(),
            projects[projectURL].fundingRequests[branchName].fundsCommitted,
            uint40(
                projects[projectURL].fundingRequests[branchName].duration +
                    block.timestamp
            ),
            uint40(block.timestamp + 5 minutes),
            uint40(block.timestamp + 5 minutes)
        );
        emit FeatureDevelopmentStarted(projectURL, branchName, block.timestamp);
    }

    /// @inheritdoc	IFPG

    function getProjectURLs() public view override returns (bytes[] memory) {
        return projectURLs;
    }

    /// @inheritdoc	IFPG

    function getProjectDetails(
        bytes memory projectURL
    ) public view override returns (address, bytes[] memory) {
        return (projects[projectURL].owner, projects[projectURL].branches);
    }

    /// @inheritdoc	IFPG

    function getFeatureDetails(
        bytes memory projectURL,
        bytes memory branchName
    )
        public
        view
        returns (address,bytes memory, uint40, uint40, uint256, FeatureStatus)
    {
        return (
            projects[projectURL].owner,
            projects[projectURL].fundingRequests[branchName].featureName,
            projects[projectURL].fundingRequests[branchName].duration,
            projects[projectURL].fundingRequests[branchName].startDate,
            projects[projectURL].fundingRequests[branchName].fundsCommitted,
            projects[projectURL].fundingRequests[branchName].status
        );
    }
    /// @inheritdoc	IFPG
    function projectActive(
        bytes memory projectURL
    ) public view override returns (bool) {
        return activeProjects[projectURL];
    }

    ///@dev required by the OZ UUPS module
    function _authorizeUpgrade(address) internal override onlyOwner {}
}
