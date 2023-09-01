// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {SablierTest} from "../../../base/Sablier.t.sol";

contract StreamCreatorTest is SablierTest {
    function setUp() public virtual override {
        SablierTest.setUp();
    }

    function test_CreateAliceStream() public {
        _transferTo(spha, alice, DEFAULT_LOCK_UP_AMOUNT * 3);

        _approveFromAccountTo(
            address(alice),
            address(streamCreator),
            DEFAULT_LOCK_UP_AMOUNT
        );
        vm.startPrank(alice);

        streamCreator.createLockupLinearStream(
            address(alice),
            DEFAULT_LOCK_UP_AMOUNT,
            120 days,
            1 hours,
            5 minutes
        );
        assertEq(lockupLinear.balanceOf(alice), 1);
        vm.stopPrank();
    }
}
