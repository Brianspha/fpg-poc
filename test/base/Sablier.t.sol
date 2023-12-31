// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import {FPGToken} from "../../src/tokens/FPGToken.sol";
import {StreamCreator} from "../../src/sablier/StreamCreator.sol";

import {SablierV2LockupLinear} from "@sablier/v2-core/src/SablierV2LockupLinear.sol";
import {SablierV2Comptroller} from "@sablier/v2-core/src/SablierV2Comptroller.sol";
import {SablierV2NFTDescriptor} from "@sablier/v2-core/src/SablierV2NFTDescriptor.sol";
import {ISablierV2LockupLinear} from "@sablier/v2-core/src/interfaces/ISablierV2LockupLinear.sol";

abstract contract SablierTest is Test {
    SablierV2LockupLinear public lockupLinear;
    SablierV2NFTDescriptor public sablierV2NFTDescriptor;
    StreamCreator public streamCreator;
    FPGToken public token;
    address public bob;
    address public alice;
    address public spha;
    uint256 public constant DEFAULT_ETHER_BALANCE = 1_000_000 ether;
    uint256 public constant DEFAULT_LOCK_UP_AMOUNT = 50_000 ether;

    function setUp() public virtual {
        // create users
        spha = _createUser("spha");
        bob = _createUser("bob");
        alice = _createUser("alice");
        // label addresses
        vm.label(address(token), "Default Vault Token");
        vm.label(alice, "Alice address");
        vm.label(spha, "Spha address");
        vm.label(bob, "Bob address");
        vm.startPrank(spha);
        //deploy token
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
        vm.stopPrank();
    }

    function _approveFromAccountTo(
        address account,
        address spender,
        uint256 amount
    ) internal {
        vm.startPrank(account);
        token.approve(spender, amount);
        vm.stopPrank();
    }

    function _transferTo(
        address from,
        address account,
        uint256 amount
    ) internal {
        vm.startPrank(from);

        token.transfer(account, amount);
        vm.stopPrank();
    }

    function _fastFowardTime(uint256 timeInDays) internal {
        vm.warp(block.timestamp + timeInDays);
    }

    function _createUser(
        string memory name
    ) internal returns (address payable) {
        address payable user = payable(makeAddr(name));
        vm.deal({account: user, newBalance: 1000 ether});

        return user;
    }
}
