// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/utils/math/MockSafeMath.sol";

contract SafeMathTest is Test {
    MockSafeMath msm = new MockSafeMath();

    function test_TryAdd() external {
        (bool flag,uint res) = msm.tryAdd(1, 2);
        assertTrue(flag);
        assertEq(res, 3);
        // overflow
        (flag, res) = msm.tryAdd(type(uint).max, 1);
        assertFalse(flag);
        assertEq(res, 0);
    }

    function test_TrySub() external {
        (bool flag,uint res) = msm.trySub(3, 1);
        assertTrue(flag);
        assertEq(res, 2);
        // overflow
        (flag, res) = msm.trySub(1, 2);
        assertFalse(flag);
        assertEq(res, 0);
    }

    function test_TryMul() external {
        (bool flag,uint res) = msm.tryMul(2, 3);
        assertTrue(flag);
        assertEq(res, 6);
        // overflow
        (flag, res) = msm.tryMul(type(uint).max, 2);
        assertFalse(flag);
        assertEq(res, 0);
    }

    function test_TryDiv() external {
        (bool flag,uint res) = msm.tryDiv(7, 2);
        assertTrue(flag);
        assertEq(res, 3);
        // overflow
        (flag, res) = msm.tryDiv(1, 0);
        assertFalse(flag);
        assertEq(res, 0);
    }

    function test_TryMod() external {
        (bool flag,uint res) = msm.tryMod(7, 2);
        assertTrue(flag);
        assertEq(res, 1);
        // overflow
        (flag, res) = msm.tryMod(1, 0);
        assertFalse(flag);
        assertEq(res, 0);
    }

    function test_Add() external {
        assertEq(msm.add(1, 2), 3);
        // overflow
        vm.expectRevert();
        msm.add(type(uint).max, 1);
    }

    function test_Sub() external {
        assertEq(msm.sub(3, 2), 1);
        // overflow
        vm.expectRevert();
        msm.sub(1, 2);

        // with error message
        assertEq(msm.sub(3, 2, "error message"), 1);
        vm.expectRevert("error message");
        msm.sub(1, 2, "error message");
    }

    function test_Mul() external {
        assertEq(msm.mul(3, 2), 6);
        // overflow
        vm.expectRevert();
        msm.mul(type(uint).max, 2);
    }

    function test_Div() external {
        assertEq(msm.div(7, 2), 3);
        // overflow
        vm.expectRevert();
        msm.div(1, 0);

        // with error message
        assertEq(msm.div(7, 2, "error message"), 3);
        vm.expectRevert("error message");
        msm.div(1, 0, "error message");
    }

    function test_Mod() external {
        assertEq(msm.mod(7, 2), 1);
        // overflow
        vm.expectRevert();
        msm.mod(1, 0);

        // with error message
        assertEq(msm.mod(7, 2, "error message"), 1);
        vm.expectRevert("error message");
        msm.mod(1, 0, "error message");
    }
}