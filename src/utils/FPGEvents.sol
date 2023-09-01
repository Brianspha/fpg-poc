// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {FeatureStatus} from "./FPGEnums.sol";

abstract contract FPGEvents {
    event FeatureFundingRequest(
        address indexed owner,
        bytes indexed branchName,
        bytes indexed featureName,
        uint40 startDate,
        uint40 duration
    );
    event ProjectFundingCommitment(
        bytes indexed branchName,
        uint256 indexed amount
    );
    event RevokedFunding(
        address indexed funder,
        bytes indexed projectURL,
        bytes indexed branchName
    );
    event ProjectStatusUpdated(
        bytes indexed projectURL,
        bytes indexed branchName,
        FeatureStatus indexed status
    );
    event FeatureDevelopmentStarted(
        bytes indexed projectURL,
        bytes indexed branchName,
        uint256 indexed timestamp
    );
    event FPGProjectAdded(address indexed owner, bytes indexed projectURL);
}
