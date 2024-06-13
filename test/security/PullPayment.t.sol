// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/security/MockPullPayment.sol";

contract PullPaymentTest is Test {
    MockPullPayment private _testing;
    address private _payee1 = address(1);
    address private _payee2 = address(2);

    function setUp() external {
        _testing = new MockPullPayment();
    }

    event DoWithAsyncTransfer(address payee, uint amount);

    function test_AsyncTransferAndPayments() external {
        address testingAddress = address(_testing);

        // load the inner escrow contract with the address computed from deployer address and nonce
        // note: the nonce in the first contract deployment by a contract is 1
        Escrow innerEscrow = Escrow(
            computeCreateAddress(testingAddress, vm.getNonce(testingAddress) - 1)
        );

        assertEq(address(innerEscrow).balance, 0);

        // deposit for payee 1
        assertEq(_testing.payments(_payee1), 0);

        vm.expectEmit(testingAddress);
        emit DoWithAsyncTransfer(_payee1, 100);
        _testing.doWithAsyncTransfer{value: 100}(_payee1, 100);

        assertEq(_testing.payments(_payee1), 100);
        assertEq(address(innerEscrow).balance, 0 + 100);

        // revert with depositing to escrow contract directly
        vm.expectRevert("Ownable: caller is not the owner");
        innerEscrow.deposit{value: 100}(_payee1);

        // deposit for payee 2
        assertEq(_testing.payments(_payee2), 0);

        vm.expectEmit(testingAddress);
        emit DoWithAsyncTransfer(_payee2, 101);
        _testing.doWithAsyncTransfer{value: 101}(_payee2, 101);

        assertEq(_testing.payments(_payee2), 101);
        assertEq(address(innerEscrow).balance, 100 + 101);

        // revert with depositing to escrow contract directly
        vm.expectRevert("Ownable: caller is not the owner");
        innerEscrow.deposit{value: 101}(_payee2);
    }

    function test_WithdrawPayments() external {
        address testingAddress = address(_testing);

        // load the inner escrow contract with the address computed from deployer address and nonce
        // note: the nonce in the first contract deployment by a contract is 1
        Escrow innerEscrow = Escrow(
            computeCreateAddress(testingAddress, vm.getNonce(testingAddress) - 1)
        );

        _testing.doWithAsyncTransfer{value: 50}(_payee1, 50);
        _testing.doWithAsyncTransfer{value: 100}(_payee2, 100);
        assertEq(address(innerEscrow).balance, 50 + 100);

        // withdraw the deposited eth to payee 1
        assertEq(_payee1.balance, 0);
        // revert if withdraw from the escrow directly
        vm.expectRevert("Ownable: caller is not the owner");
        innerEscrow.withdraw(payable(_payee1));

        _testing.withdrawPayments(payable(_payee1));
        assertEq(_payee1.balance, 50);
        assertEq(address(innerEscrow).balance, 100);

        // withdraw the deposited eth to payee 2
        assertEq(_payee2.balance, 0);
        // revert if withdraw from the escrow directly
        vm.expectRevert("Ownable: caller is not the owner");
        innerEscrow.withdraw(payable(_payee2));

        _testing.withdrawPayments(payable(_payee2));
        assertEq(_payee2.balance, 100);
        assertEq(address(innerEscrow).balance, 0);
    }
}

