// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/token/ERC20/MockERC20.sol";

contract ERC20Test is Test {
    MockERC20 private _testing = new MockERC20("test name", "test symbol");
    address private owner = address(1);
    address private spender = address(2);

    function test_Getter() external {
        assertEq(_testing.name(), "test name");
        assertEq(_testing.symbol(), "test symbol");
        assertEq(_testing.decimals(), 18);
        assertEq(_testing.totalSupply(), 0);
    }

    event Transfer(address indexed from, address indexed to, uint value);

    function test_MintAndBurn() external {
        // 1. mint()
        assertEq(_testing.balanceOf(owner), 0);
        assertEq(_testing.totalSupply(), 0);

        vm.expectEmit(true, true, false, true, address(_testing));
        emit Transfer(address(0), owner, 1024);
        _testing.mint(owner, 1024);
        assertEq(_testing.balanceOf(owner), 1024);
        assertEq(_testing.totalSupply(), 1024);

        // revert if account is 0 address when mint
        vm.expectRevert("ERC20: mint to the zero address");
        _testing.mint(address(0), 1024);

        // 2. burn()
        vm.expectEmit(true, true, false, true, address(_testing));
        emit Transfer(owner, address(0), 1);
        _testing.burn(owner, 1);
        assertEq(_testing.balanceOf(owner), 1024 - 1);
        assertEq(_testing.totalSupply(), 1024 - 1);

        // revert if amount > balance when burn
        vm.expectRevert("ERC20: burn amount exceeds balance");
        _testing.burn(owner, 1024);

        // revert if account is 0 address when burn
        vm.expectRevert("ERC20: burn from the zero address");
        _testing.burn(address(0), 1);
    }

    event Approval(address indexed owner, address indexed spender, uint value);

    function test_ApproveAndIncreaseAllowanceAndDecreaseAllowance() external {
        // 1. approve()
        assertEq(_testing.allowance(owner, spender), 0);
        vm.expectEmit(true, true, false, true, address(_testing));
        emit Approval(owner, spender, 1024);
        vm.prank(owner);
        _testing.approve(spender, 1024);
        assertEq(_testing.allowance(owner, spender), 1024);

        // revert with 0 address as owner or spender
        vm.expectRevert("ERC20: approve from the zero address");
        vm.prank(address(0));
        _testing.approve(spender, 0);
        vm.expectRevert("ERC20: approve to the zero address");
        _testing.approve(address(0), 0);

        // 2. increaseAllowance()
        vm.expectEmit(true, true, false, true, address(_testing));
        emit Approval(owner, spender, 1024 + 1);
        vm.prank(owner);
        _testing.increaseAllowance(spender, 1);
        assertEq(_testing.allowance(owner, spender), 1024 + 1);

        // revert with 0 address as owner or spender
        vm.expectRevert("ERC20: approve from the zero address");
        vm.prank(address(0));
        _testing.increaseAllowance(spender, 0);
        vm.expectRevert("ERC20: approve to the zero address");
        _testing.increaseAllowance(address(0), 0);

        // 3. decreaseAllowance()
        vm.expectEmit(true, true, false, true, address(_testing));
        emit Approval(owner, spender, 1025 - 2);
        vm.prank(owner);
        _testing.decreaseAllowance(spender, 2);
        assertEq(_testing.allowance(owner, spender), 1025 - 2);

        // revert with 0 address as owner or spender
        vm.expectRevert("ERC20: approve from the zero address");
        vm.prank(address(0));
        _testing.decreaseAllowance(spender, 0);
        vm.expectRevert("ERC20: approve to the zero address");
        _testing.decreaseAllowance(address(0), 0);
    }

    function test_TransferAndTransferFrom() external {
        // 1. transfer()
        address to = address(3);
        _testing.mint(owner, 100);
        vm.expectEmit(true, true, false, true, address(_testing));
        emit Transfer(owner, to, 1);
        vm.prank(owner);
        _testing.transfer(to, 1);
        assertEq(_testing.balanceOf(owner), 100 - 1);
        assertEq(_testing.balanceOf(to), 1);

        // revert with 0 address as from or to
        vm.expectRevert("ERC20: transfer from the zero address");
        vm.prank(address(0));
        _testing.transfer(to, 0);
        vm.expectRevert("ERC20: transfer to the zero address");
        _testing.transfer(address(0), 0);

        // revert with insufficient balance
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        vm.prank(owner);
        _testing.transfer(to, 99 + 1);

        // 2. transferFrom()
        // revert if allowance < amount
        vm.prank(owner);
        _testing.approve(spender, 10);
        vm.expectRevert("ERC20: insufficient allowance");
        vm.prank(spender);
        _testing.transferFrom(owner, to, 11);

        // revert if amount > owner's balance
        uint balance = _testing.balanceOf(owner);
        vm.prank(owner);
        _testing.approve(spender, balance + 1);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        vm.prank(spender);
        _testing.transferFrom(owner, to, balance + 1);

        // revert with 0 address as owner or spender or to
        vm.expectRevert("ERC20: approve from the zero address");
        _testing.transferFrom(address(0), to, 0);

        vm.prank(address(0));
        vm.expectRevert("ERC20: approve to the zero address");
        _testing.transferFrom(owner, to, 0);

        vm.expectRevert("ERC20: transfer to the zero address");
        vm.prank(spender);
        _testing.transferFrom(owner, address(0), 0);

        // pass with emit
        uint balanceOwner = _testing.balanceOf(owner);
        uint balanceTo = _testing.balanceOf(to);
        vm.prank(owner);
        _testing.approve(spender, 10);

        vm.expectEmit(true, true, false, true, address(_testing));
        emit Approval(owner, spender, 10 - 9);
        emit Transfer(owner, to, 9);
        vm.prank(spender);
        _testing.transferFrom(owner, to, 9);
        assertEq(_testing.balanceOf(owner), balanceOwner - 9);
        assertEq(_testing.balanceOf(to), balanceTo + 9);

        // no approval update with infinite allowance
        vm.prank(owner);
        _testing.approve(spender, type(uint).max);
        assertEq(_testing.allowance(owner, spender), type(uint).max);

        vm.prank(spender);
        _testing.transferFrom(owner, to, 10);
        assertEq(_testing.allowance(owner, spender), type(uint).max);
    }
}
