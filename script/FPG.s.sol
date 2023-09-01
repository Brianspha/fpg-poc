// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {FPG} from "../src/fpg/FPG.sol";
import {FPGToken} from "../src/tokens/FPGToken.sol";
import {StreamCreator} from "../src/sablier/StreamCreator.sol";
import {SablierV2LockupLinear} from "@sablier/v2-core/src/SablierV2LockupLinear.sol";
import {SablierV2Comptroller} from "@sablier/v2-core/src/SablierV2Comptroller.sol";
import {SablierV2NFTDescriptor} from "@sablier/v2-core/src/SablierV2NFTDescriptor.sol";
import {ISablierV2LockupLinear} from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";

import "forge-std/Script.sol";

contract FPGScript is Script {
    SablierV2LockupLinear public lockupLinear;
    SablierV2NFTDescriptor public sablierV2NFTDescriptor;
    StreamCreator public streamCreator;
    FPGToken public token;
    FPG public fpg;

    address public spha = 0x5aF828D07f4e403522F2E88eC544E1F7D559E29d;

    function setUp() public {
        uint256 deployerPrivateKey = vm.envUint("LOCAL_HOST_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        token = new FPGToken();
        token.initialize("FPG", "Funding Public Goods");
        token.mint(spha, 100_000_000_000 ether);
        // deploy Sablier Contracts
        SablierV2Comptroller sablierV2Comptroller = new SablierV2Comptroller(
            spha
        );
        sablierV2NFTDescriptor = new SablierV2NFTDescriptor();
        lockupLinear = new SablierV2LockupLinear(
            spha,
            sablierV2Comptroller,
            sablierV2NFTDescriptor
        );
        streamCreator = new StreamCreator(lockupLinear, address(token));
        fpg = new FPG();
        fpg.initialize(streamCreator, false);
        console.log("Token Deployment address");
        console.log(address(token));
        console.log("FPG Deployment Address");
        console.log(address(fpg));
        console.log("StreamCreator Deployment address");
        console.log(address(streamCreator));
        console.log("SablierV2Comptroller Deployment Address");
        console.log(address(sablierV2Comptroller));
        console.log("SablierV2LockupLinear Deployment Address");
        console.log(address(lockupLinear));
        vm.stopBroadcast();
    }

    function run() public {
        vm.broadcast();
    }
}
