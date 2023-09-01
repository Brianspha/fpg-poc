// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {SablierTest} from "../../../base/Sablier.t.sol";
import {FPG} from "../../../../src/fpg/FPG.sol";
import "../../../../src/utils/FPGStructs.sol";

contract FPGTests is SablierTest {
    FPG public fpg;
    bytes public constant PROJECT_URL = "https://github.com/foundry-rs/foundry";
    bytes public constant BRANCH_NAME = "abi-decode";
    bytes public constant FEATURE_NAME = "SOME NAME";
    bytes public constant PROJECT_URL1 =
        "1https://github.com/foundry-rs/foundry";
    bytes public constant BRANCH_NAME1 = "1abi-decode";
    bytes public constant FEATURE_NAME1 = "1SOME NAME";
    uint256 public constant DEFAULT_FEATURE_FUNDING = 10 ether;

    function setUp() public virtual override {
        SablierTest.setUp();
        vm.startPrank(spha);
        fpg = new FPG();
        fpg.initialize(SablierTest.streamCreator, false);
        vm.stopPrank();
    }

    function test_AliceAddProjectURL() public {
        vm.startPrank(alice);
        fpg.addProject(PROJECT_URL);
        address projectOwner;
        bytes[] memory branches;

        (projectOwner, branches) = fpg.getProjectDetails(PROJECT_URL);
        assertEq(projectOwner, alice);
        assertEq(branches.length, 0);
        vm.stopPrank();
    }

    function test_BobAddProjectURL() public {
        vm.startPrank(bob);
        fpg.addProject(PROJECT_URL1);
        address projectOwner;
        bytes[] memory branches;

        (projectOwner, branches) = fpg.getProjectDetails(PROJECT_URL1);
        assertEq(projectOwner, bob);
        assertEq(branches.length, 0);
        vm.stopPrank();
    }

    function test_AliceRequestFeatureFunding() public {
        vm.startPrank(alice);
        fpg.addProject(PROJECT_URL);
        uint40 START_DATE = uint40(block.timestamp + 5 minutes);
        uint40 END_DATE = uint40(1 weeks);

        fpg.requestFeatureFunding(
            PROJECT_URL,
            BRANCH_NAME,
            FEATURE_NAME,
            START_DATE,
            END_DATE
        );
        address owner;
        bytes memory tempFeatureName;
        uint40 duration;
        uint40 startDate;
        uint256 commitedFunding;
        FeatureStatus status;
        (owner,tempFeatureName, duration, startDate, commitedFunding, status) = fpg
            .getFeatureDetails(PROJECT_URL, BRANCH_NAME);
        assertEq(tempFeatureName, FEATURE_NAME);
        assertEq(duration, END_DATE);
        assertEq(commitedFunding, 0);
        assertEq(uint(status), uint(FeatureStatus.FundingPhase));
        vm.stopPrank();
    }

    function test_BobRequestFeatureFunding() public {
        vm.startPrank(alice);
        fpg.addProject(PROJECT_URL1);
        uint40 START_DATE = uint40(block.timestamp + 5 minutes);
        uint40 END_DATE = uint40(1 weeks);

        fpg.requestFeatureFunding(
            PROJECT_URL1,
            BRANCH_NAME1,
            FEATURE_NAME1,
            START_DATE,
            END_DATE
        );
        address owner;
        bytes memory tempFeatureName;
        uint40 duration;
        uint40 startDate;
        uint256 commitedFunding;
        FeatureStatus status;
        (owner,tempFeatureName, duration, startDate, commitedFunding, status) = fpg
            .getFeatureDetails(PROJECT_URL1, BRANCH_NAME1);
        assertEq(tempFeatureName, FEATURE_NAME1);
        assertEq(duration, END_DATE);
        assertEq(commitedFunding, 0);
        assertEq(uint(status), uint(FeatureStatus.FundingPhase));
        vm.stopPrank();
    }

    function test_GetAllFeatureFundingRequests() public {
        test_AliceRequestFeatureFunding();
        test_BobRequestFeatureFunding();
        bytes[] memory projects = fpg.getProjectURLs();
        for (uint256 i; i < projects.length; ) {
            console.log("Project URLS");
            console.logBytes(projects[i]);
            unchecked {
                ++i;
            }
        }
    }

    function test_SphaFinanceAliceFeatureRequest() public {
        vm.startPrank(alice);
        fpg.addProject(PROJECT_URL);
        uint40 START_DATE = uint40(block.timestamp + 5 minutes);
        uint40 END_DATE = uint40(1 weeks);

        fpg.requestFeatureFunding(
            PROJECT_URL,
            BRANCH_NAME,
            FEATURE_NAME,
            START_DATE,
            END_DATE
        );
        vm.stopPrank();
        _approveFromAccountTo(spha, address(fpg), DEFAULT_FEATURE_FUNDING);
        vm.startPrank(spha);
        fpg.fundFeature(PROJECT_URL, BRANCH_NAME, DEFAULT_FEATURE_FUNDING);
        vm.stopPrank();
        uint256 commitedFunding;
        (, , , , commitedFunding, ) = fpg.getFeatureDetails(
            PROJECT_URL,
            BRANCH_NAME
        );
        assertEq(commitedFunding, DEFAULT_FEATURE_FUNDING);
    }

    function test_GetAllFeatureFundingRequests_AndFeatureDetails_AndFundingRecieved()
        public
    {
        test_AliceStartFeatureWork();
        test_BobStartFeatureWork();
        bytes[] memory projects = fpg.getProjectURLs();
        uint256 projectsLenght = projects.length;
        for (uint256 i; i < projectsLenght; ) {
            console.log("Project URLS");
            console.logBytes(projects[i]);
            address projectOwner;
            bytes[] memory branches;

            (projectOwner, branches) = fpg.getProjectDetails(projects[i]);
            console.log("Project Owner");
            console.log(projectOwner);
            uint256 branchesLenght = branches.length;
            for (uint256 j; j < branchesLenght; ) {
                address owner;
                bytes memory tempFeatureName;
                uint40 duration;
                uint40 startDate;
                uint256 commitedFunding;
                FeatureStatus status;
                (
                    owner,
                    tempFeatureName,
                    duration,
                    startDate,
                    commitedFunding,
                    status
                ) = fpg.getFeatureDetails(projects[i], branches[j]);
                console.log("Project Features");
                console.logBytes("StartDate: ");
                console.log(startDate);
                console.logBytes("Duration: ");
                console.log(duration);
                console.logBytes("Commited Funding: ");
                console.log(commitedFunding);
                console.logBytes("FeatureStatus: ");
                console.log(uint(status));
                unchecked {
                    ++j;
                }
            }

            unchecked {
                ++i;
            }
        }
    }

    function test_AliceStartFeatureWork() public {
        vm.startPrank(alice);
        fpg.addProject(PROJECT_URL);
        uint40 START_DATE = uint40(block.timestamp + 5 minutes);
        uint40 END_DATE = uint40(1 weeks);

        fpg.requestFeatureFunding(
            PROJECT_URL,
            BRANCH_NAME,
            FEATURE_NAME,
            START_DATE,
            END_DATE
        );
        vm.stopPrank();
        _approveFromAccountTo(spha, address(fpg), DEFAULT_FEATURE_FUNDING);
        vm.startPrank(spha);
        fpg.fundFeature(PROJECT_URL, BRANCH_NAME, DEFAULT_FEATURE_FUNDING);
        vm.stopPrank();
        vm.startPrank(alice);
        SablierTest._fastFowardTime(10 minutes);
        fpg.startProject(PROJECT_URL, BRANCH_NAME);
        assertEq(SablierTest.lockupLinear.balanceOf(alice), 1);
        SablierTest._fastFowardTime(8 days);
        assertEq(SablierTest.lockupLinear.streamedAmountOf(1) / 1 ether, 10);
        vm.stopPrank();
    }

    function test_BobStartFeatureWork() public {
        vm.startPrank(bob);
        fpg.addProject(PROJECT_URL1);
        uint40 START_DATE = uint40(block.timestamp + 5 minutes);
        uint40 END_DATE = uint40(1 weeks);

        fpg.requestFeatureFunding(
            PROJECT_URL1,
            BRANCH_NAME1,
            FEATURE_NAME1,
            START_DATE,
            END_DATE
        );
        vm.stopPrank();
        _approveFromAccountTo(spha, address(fpg), DEFAULT_FEATURE_FUNDING);
        vm.startPrank(spha);
        fpg.fundFeature(PROJECT_URL1, BRANCH_NAME1, DEFAULT_FEATURE_FUNDING);
        vm.stopPrank();
        vm.startPrank(bob);
        SablierTest._fastFowardTime(10 minutes);
        fpg.startProject(PROJECT_URL1, BRANCH_NAME1);
        assertEq(SablierTest.lockupLinear.balanceOf(bob), 1);
        SablierTest._fastFowardTime(8 days);
        assertEq(SablierTest.lockupLinear.streamedAmountOf(1) / 1 ether, 10);
        vm.stopPrank();
    }
}
