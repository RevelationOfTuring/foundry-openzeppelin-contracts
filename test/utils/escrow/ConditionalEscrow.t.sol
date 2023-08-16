// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/utils/escrow/MockConditionalEscrow.sol";

contract ConditionalEscrowTest is Test {
    MockConditionalEscrow mce = new MockConditionalEscrow();
    address payable payee = payable(address(1024));
    address other = address(2048);

    function setUp() external {
        vm.deal(address(this), 10 ether);
        vm.deal(other, 10 ether);
    }

    function test_Deposit() external {
        mce.deposit{value : 1 ether}(payee);
        assertEq(1 ether, mce.depositsOf(payee));
        // check balance
        assertEq(1 ether, address(mce).balance);

        // revert if not owner
        vm.prank(other);
        vm.expectRevert("Ownable: caller is not the owner");
        mce.deposit{value : 1 ether}(payee);
    }

    function test_WithdrawalAllowed() external {
        // not deposit
        assertFalse(mce.withdrawalAllowed(payee));

        // deposit at block number 1024
        vm.roll(1024);
        mce.deposit{value : 1 ether}(payee);

        // return false when query on the block number < 1024+1000
        assertFalse(mce.withdrawalAllowed(payee));
        vm.roll(1024 + 1);
        assertFalse(mce.withdrawalAllowed(payee));
        vm.roll(1024 + 999);
        assertFalse(mce.withdrawalAllowed(payee));
        vm.roll(1024 + 1000);
        assertTrue(mce.withdrawalAllowed(payee));
    }

    function test_Withdraw() external {
        // deposit at block number 1024
        vm.roll(1024);
        mce.deposit{value : 1 ether}(payee);

        // owner can't withdraw to 'payee' before the block number 1024+1000
        vm.expectRevert("ConditionalEscrow: payee is not allowed to withdraw");
        mce.withdraw(payee);

        vm.roll(1024 + 1);
        vm.expectRevert("ConditionalEscrow: payee is not allowed to withdraw");
        mce.withdraw(payee);

        vm.roll(1024 + 999);
        vm.expectRevert("ConditionalEscrow: payee is not allowed to withdraw");
        mce.withdraw(payee);

        // owner withdraw to 'payee'
        vm.roll(1024 + 1000);
        assertEq(0, payee.balance);
        mce.withdraw(payee);
        // check balance of payee
        assertEq(1 ether, payee.balance);
        assertEq(0, address(mce).balance);

        // revert if not owner
        vm.prank(other);
        vm.expectRevert("Ownable: caller is not the owner");
        mce.withdraw(payee);
    }
}