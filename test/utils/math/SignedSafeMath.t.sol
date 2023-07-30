// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/utils/math/MockSignedSafeMath.sol";

contract SignedSafeMathTest is Test {
    MockSignedSafeMath mssm = new MockSignedSafeMath();

    function test_Add() external {
        assertEq(mssm.add(1, 2), 3);
        assertEq(mssm.add(- 1, 2), 1);
        assertEq(mssm.add(- 1, - 2), - 3);
        // overflow
        vm.expectRevert();
        mssm.add(type(int).max, 1);
    }

    function test_Sub() external {
        assertEq(mssm.sub(3, 2), 1);
        assertEq(mssm.sub(3, - 2), 5);
        assertEq(mssm.sub(- 3, 2), - 5);
        assertEq(mssm.sub(- 3, - 2), - 1);
        // overflow
        vm.expectRevert();
        mssm.sub(type(int).min, 1);
    }

    function test_Mul() external {
        assertEq(mssm.mul(3, 2), 6);
        assertEq(mssm.mul(3, - 2), - 6);
        assertEq(mssm.mul(- 3, 2), - 6);
        assertEq(mssm.mul(- 3, - 2), 6);
        // overflow
        vm.expectRevert();
        mssm.mul(type(int).max, 2);
        vm.expectRevert();
        mssm.mul(type(int).min, 2);
    }

    function test_Div() external {
        assertEq(mssm.div(3, 2), 1);
        assertEq(mssm.div(3, - 2), - 1);
        assertEq(mssm.div(- 3, 2), - 1);
        assertEq(mssm.div(- 3, - 2), 1);
        // overflow
        vm.expectRevert();
        mssm.div(1, 0);
    }
}