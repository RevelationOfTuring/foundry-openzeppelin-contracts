// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/utils/escrow/Escrow.sol";

contract EscrowTest is Test {
    Escrow e = new Escrow();
    address payable payee = payable(address(1024));
    address other = address(2048);

    // copy events from Escrow.sol to do event assertion
    event Deposited(address indexed payee, uint256 weiAmount);
    event Withdrawn(address indexed payee, uint256 weiAmount);

    function setUp() external {
        // change balance of the owner
        vm.deal(address(this), 10 ether);
        // change balance of other
        vm.deal(other, 10 ether);
    }

    function test_DepositAndDepositsOf() external {
        // check owner
        address owner = address(this);
        assertEq(owner, e.owner());

        // check depositOf() before deposit
        assertEq(0, e.depositsOf(payee));

        // check event
        vm.expectEmit(address(e));
        emit Deposited(payee, 1 ether);
        // deposit
        e.deposit{value : 1 ether}(payee);
        // check balances
        assertEq(address(e).balance, 1 ether);
        assertEq(owner.balance, 10 ether - 1 ether);
        // check depositOf() after deposit
        assertEq(1 ether, e.depositsOf(payee));

        // deposit again
        e.deposit{value : 2 ether}(payee);
        // check balances
        assertEq(address(e).balance, 1 ether + 2 ether);
        assertEq(owner.balance, 10 ether - 1 ether - 2 ether);
        assertEq(1 ether + 2 ether, e.depositsOf(payee));

        // revert if not owner
        vm.prank(other);
        vm.expectRevert("Ownable: caller is not the owner");
        e.deposit{value : 1 ether}(payee);
    }

    function test_Withdraw() external {
        e.deposit{value : 1 ether}(payee);
        // check before withdraw
        assertEq(1 ether, address(e).balance);
        assertEq(0, payee.balance);

        // check event
        vm.expectEmit(address(e));
        emit Withdrawn(payee, 1 ether);
        // withdraw
        e.withdraw(payee);

        // check before withdraw
        assertEq(0, address(e).balance);
        assertEq(1 ether, payee.balance);

        // revert if not owner
        vm.prank(other);
        vm.expectRevert("Ownable: caller is not the owner");
        e.withdraw(payee);
    }
}