// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/utils/MockCounters.sol";

contract CounterTest is Test {
    MockCounters mc;

    function setUp() external {
        mc = new MockCounters();
    }

    function test_Increment() external {
        assertEq(0, mc.current());
        mc.increment();
        assertEq(1, mc.current());
        mc.increment();
        assertEq(2, mc.current());
    }

    function test_Decrement() external {
        mc.increment();
        assertEq(1, mc.current());
        mc.decrement();
        assertEq(0, mc.current());
        // overflow
        vm.expectRevert("Counter: decrement overflow");
        mc.decrement();
    }

    function test_Reset() external {
        mc.increment();
        mc.increment();
        assertEq(2, mc.current());
        mc.reset();
        assertEq(0, mc.current());
    }
}