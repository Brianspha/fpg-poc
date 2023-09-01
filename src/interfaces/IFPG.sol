// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "../utils/FPGErrors.sol";
import "../utils/FPGStructs.sol";
import "../utils/FPGEvents.sol";
import "../utils/FPGModifiers.sol";
import {FeatureStatus} from "../utils/FPGEnums.sol";
import {StreamCreator} from "../sablier/StreamCreator.sol";

/// @title IFPG - Funding Platform for GitHub Projects
/// @author brianspha
/// @notice Interface defining functions required for managing projects and funding features on the FPG platform
/// @dev This interface enables users to list projects, request funding for specific features, and contribute funds to those features.
interface IFPG {
    /// @notice Allows anyone to list their project on the FPG platform.
    /// @param projectURL The GitHub/Gitlab URL of the project to be listed.
    function addProject(bytes memory projectURL) external;

    /// @notice Allows the owner of a project to request funding for a specific feature.
    /// @param projectURL The GitHub/Gitlab URL of the project to be listed.
    /// @param branchName The name of the branch where the feature will be developed and tracked.
    /// @param featureName The name of the feature to request funding for.
    /// @param startDate The start date for the feature development.
    /// @param duration The duration of developing the feature.
    function requestFeatureFunding(
        bytes memory projectURL,
        bytes memory branchName,
        bytes memory featureName,
        uint256 startDate,
        uint256 duration
    ) external;

    /// @notice Allows anyone to support a listed feature by contributing funds.
    /// @param projectURL The GitHub/Gitlab URL of the project to be listed.
    /// @param branchName The branch name for the feature to fund.
    /// @param amount The amount of funding in tokens.
    /// @dev Callers must approve the implementing contract to spend the [amount] tokens before using this function.
    /// @dev Funding is streamed to the project owner based on the specified amount.
    function fundFeature(
        bytes memory projectURL,
        bytes memory branchName,
        uint256 amount
    ) external;

    /// @notice Allows contributors to stop funding a feature, refunding the remaining amount not yet streamed.
    /// @param projectURL The GitHub/Gitlab URL of the project to be listed.
    /// @param branchName The branch name for the feature to stop funding.
    function stopFundingFeature(
        bytes memory projectURL,
        bytes memory branchName
    ) external;

    /// @notice Allows the project creator to update the status of a funded feature.
    /// @param projectURL The GitHub/Gitlab URL of the project to be listed.
    /// @param branchName The branch name for the feature to update.
    /// @param status The new status of the feature.
    function updateFeatureStatus(
        bytes memory projectURL,
        bytes memory branchName,
        FeatureStatus status
    ) external;

    /// @notice Initializes the contract with the provided streaming contract.
    /// @dev Ideally, avoid front-running this initialization function.
    /// @param sablier The streaming contract responsible for creating linear streams.
    function initialize(StreamCreator sablier, bool revocable) external;

    /// @notice Starts a new project by listing it on the FPG platform.
    /// @param projectURL The GitHub/Gitlab URL of the project to be listed.
    /// @param branchName The name of the initial branch for the project.
    function startProject(
        bytes memory projectURL,
        bytes memory branchName
    ) external;

    /// @notice Retrieves the URLs of all projects listed on the platform.
    function getProjectURLs() external view returns (bytes[] memory);

    /// @notice Retrieves detailed information about a project.
    /// @param projectURL The GitHub/Gitlab URL of the project.
    /// @return The project's creator address and an array of branch names.
    function getProjectDetails(
        bytes memory projectURL
    ) external returns (address, bytes[] memory);

    /// @notice Retrieves detailed information about a specific feature within a project.
    /// @param projectURL The GitHub/Gitlab URL of the project.
    /// @param branchName The name of the branch containing the feature.
    /// @return The feature's name, start date, duration, total funding amount, and current status.
    function getFeatureDetails(
        bytes memory projectURL,
        bytes memory branchName
    )
        external
        view
        returns (address, bytes memory, uint40, uint40, uint256, FeatureStatus);

    function projectActive(
        bytes memory projectURL
    ) external view returns (bool);
}
