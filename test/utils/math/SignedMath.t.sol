// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/utils/math/MockSignedMath.sol";

contract SignedMathTest is Test {
    MockSignedMath msm = new MockSignedMath();

    function test_Max() external {
        assertEq(msm.max(1, 2), 2);
        assertEq(msm.max(- 1, - 2), - 1);
        assertEq(msm.max(- 1, 1), 1);
        assertEq(msm.max(- 1, 0), 0);
        assertEq(msm.max(1, 0), 1);
    }

    function test_Min() external {
        assertEq(msm.min(1, 2), 1);
        assertEq(msm.min(- 1, - 2), - 2);
        assertEq(msm.min(- 1, 1), - 1);
        assertEq(msm.min(- 1, 0), - 1);
        assertEq(msm.min(1, 0), 0);
    }

    function test_Average() external {
        assertEq(msm.average(2, 4), 3);
        assertEq(msm.average(2, 3), 2);
        assertEq(msm.average(type(int).max, type(int).max - 2), type(int).max - 1);
        assertEq(msm.average(type(int).min, type(int).min + 2), type(int).min + 1);
    }

    function test_Abs() external {
        assertEq(msm.abs(0), 0);
        assertEq(msm.abs(- 1), 1);
        assertEq(msm.abs(1), 1);
        // int256的最大正数的二进制为0+255个1
        assertEq(msm.abs(type(int).max), (1 << 255) - 1);
        // int256的最小负数的二进制为其最大正数+1，即1+255个0
        assertEq(msm.abs(type(int).min), 1 << 255);
    }
}