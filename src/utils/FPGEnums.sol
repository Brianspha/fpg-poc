// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/**
 * @title Enum for the status of a feature in a project.
 * @dev Represents the possible states that a feature can be in.
 */
enum FeatureStatus {
    Completed, // The feature has been completed. 0
    InProgress, // The feature is currently in progress. 1
    FundingPhase, // The feature is in a funding phase. 2
    MoreFundingNeeded
}
