// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../../src/token/ERC20/extensions/MockERC20Burnable.sol";

contract ERC20BurnableTest is Test {
    MockERC20Burnable private _testing = new MockERC20Burnable("test name", "test symbol");
    address private user1 = address(1);
    address private user2 = address(2);

    function setUp() external {
        _testing.mint(user1, 100);
    }

    function test_Burn() external {
        vm.prank(user1);
        _testing.burn(1);
        assertEq(_testing.balanceOf(user1), 100 - 1);

        // revert if burn more than balance
        vm.expectRevert("ERC20: burn amount exceeds balance");
        _testing.burn(100);
    }

    function test_BurnFrom() external {
        // revert without approve
        vm.prank(user2);
        vm.expectRevert("ERC20: insufficient allowance");
        _testing.burnFrom(user1, 1);

        // revert if burn more than allowance
        vm.prank(user1);
        _testing.approve(user2, 1);
        vm.prank(user2);
        vm.expectRevert("ERC20: insufficient allowance");
        _testing.burnFrom(user1, 2);

        // revert if burn more than balance
        vm.prank(user1);
        _testing.approve(user2, 100 + 1);
        vm.prank(user2);
        vm.expectRevert("ERC20: burn amount exceeds balance");
        _testing.burnFrom(user1, 100 + 1);

        // pass
        vm.prank(user2);
        _testing.burnFrom(user1, 10);
        assertEq(_testing.allowance(user1, user2), 101 - 10);
        assertEq(_testing.balanceOf(user1), 100 - 10);

        // allowance not changed if it was set to type(uint).max
        vm.prank(user1);
        _testing.approve(user2, type(uint).max);
        vm.prank(user2);
        _testing.burnFrom(user1, 10);
        assertEq(_testing.allowance(user1, user2), type(uint).max);
    }
}
