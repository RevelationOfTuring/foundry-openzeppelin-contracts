// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../../src/token/ERC20/extensions/MockERC20Pausable.sol";

contract ERC20PausableTest is Test {
    MockERC20Pausable private _testing = new MockERC20Pausable("test name", "test symbol");
    address private user1 = address(1);
    address private user2 = address(2);

    function test_BeforeTokenTransfer() external {
        // pass mint/burn/transfer/transferFrom if not paused
        assertFalse(_testing.paused());
        // mint
        _testing.mint(user1, 100);
        assertEq(_testing.balanceOf(user1), 100);
        // burn
        _testing.burn(user1, 1);
        assertEq(_testing.balanceOf(user1), 100 - 1);
        // transfer
        vm.prank(user1);
        _testing.transfer(user2, 2);
        assertEq(_testing.balanceOf(user1), 100 - 1 - 2);
        assertEq(_testing.balanceOf(user2), 2);
        // transferFrom
        vm.prank(user1);
        _testing.approve(address(this), 50);
        _testing.transferFrom(user1, user2, 10);
        assertEq(_testing.balanceOf(user1), 100 - 1 - 2 - 10);
        assertEq(_testing.balanceOf(user2), 2 + 10);
        assertEq(_testing.allowance(user1, address(this)), 50 - 10);

        // revert mint/burn/transfer/transferFrom if paused
        _testing.pause();
        assertTrue(_testing.paused());
        // mint
        vm.expectRevert("ERC20Pausable: token transfer while paused");
        _testing.mint(user1, 100);
        // burn
        vm.expectRevert("ERC20Pausable: token transfer while paused");
        _testing.burn(user1, 1);
        // transfer
        vm.expectRevert("ERC20Pausable: token transfer while paused");
        vm.prank(user1);
        _testing.transfer(user2, 2);
        // transfer from
        vm.expectRevert("ERC20Pausable: token transfer while paused");
        _testing.transferFrom(user1, user2, 10);
    }
}
