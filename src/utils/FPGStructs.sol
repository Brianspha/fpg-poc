// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {FeatureStatus} from "./FPGEnums.sol";

struct FPGProject {
    address owner;
    bytes url;
    mapping(bytes branchName => FeatureDetail FeatureDetail) fundingRequests;
    bytes[] branches;
}



struct FeatureDetail {
    bytes featureName;
    uint40 duration;
    uint40 startDate;
    uint256 fundsCommitted;
    mapping(address => uint256 amount) funders;
    FeatureStatus status;
}
