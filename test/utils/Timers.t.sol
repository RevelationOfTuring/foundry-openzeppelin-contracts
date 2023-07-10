// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/utils/MockTimers.sol";

contract TimersTest is Test {
    MockTimersTimestamp mtt = new MockTimersTimestamp();
    MockTimersBlockNumber mtb = new MockTimersBlockNumber();

    function test_SetDeadlineAndGetDeadline_ForTimestamp() external {
        mtt.setDeadline(1024);
        assertEq(1024, mtt.getDeadline());
    }

    function test_ResetAndIsUnset_ForTimestamp() external {
        mtt.setDeadline(1024);
        assertFalse(mtt.isUnset());

        mtt.reset();
        assertTrue(mtt.isUnset());

        assertEq(0, mtt.getDeadline());
    }

    function test_IsStartedAndIsPendingAndIsExpired_ForTimestamp() external {
        mtt.reset();
        assertFalse(mtt.isStarted());
        mtt.setDeadline(1024);
        assertTrue(mtt.isStarted());

        // check pending/expired status
        vm.warp(1024 - 1);
        assertTrue(mtt.isPending());
        assertFalse(mtt.isExpired());

        vm.warp(1024);
        assertFalse(mtt.isPending());
        assertTrue(mtt.isExpired());

        vm.warp(1024 + 1);
        assertFalse(mtt.isPending());
        assertTrue(mtt.isExpired());

        // isExpired() always returns false if unset
        mtt.reset();
        assertFalse(mtt.isExpired());
    }

    function test_SetDeadlineAndGetDeadline_ForBlockNumber() external {
        mtb.setDeadline(1024);
        assertEq(1024, mtb.getDeadline());
    }

    function test_ResetAndIsUnset_ForBlockNumber() external {
        mtb.setDeadline(1024);
        assertFalse(mtb.isUnset());

        mtb.reset();
        assertTrue(mtb.isUnset());

        assertEq(0, mtb.getDeadline());
    }

    function test_IsStartedAndIsPendingAndIsExpired_ForBlockNumber() external {
        mtb.reset();
        assertFalse(mtb.isStarted());
        mtb.setDeadline(1024);
        assertTrue(mtb.isStarted());

        // check pending/expired status
        vm.roll(1024 - 1);
        assertTrue(mtb.isPending());
        assertFalse(mtb.isExpired());

        vm.roll(1024);
        assertFalse(mtb.isPending());
        assertTrue(mtb.isExpired());

        vm.roll(1024 + 1);
        assertFalse(mtb.isPending());
        assertTrue(mtb.isExpired());

        // isExpired() always returns false if unset
        mtb.reset();
        assertFalse(mtb.isExpired());
    }
}
