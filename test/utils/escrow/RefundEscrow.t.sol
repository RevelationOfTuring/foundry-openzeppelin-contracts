// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/utils/escrow/RefundEscrow.sol";

contract RefundEscrowTest is Test {
    RefundEscrow re;
    address payable beneficiary = payable(address(1 << 1));
    address payable payee = payable(address(1 << 2));
    address payable other = payable(address(1 << 3));

    // copy events from RefundEscrow.sol to do event assertion
    event RefundsClosed();
    event RefundsEnabled();

    function setUp() external {
        re = new RefundEscrow(beneficiary);
        // change balance of the owner
        vm.deal(address(this), 10 ether);
        // change balance of other
        vm.deal(other, 10 ether);
    }

    function test_Getter() external {
        // initial state
        require(re.state() == RefundEscrow.State.Active);
        assertEq(beneficiary, re.beneficiary());
    }

    function test_StateChange() external {
        // case 1: Active to Closed
        vm.expectEmit(address(re));
        emit RefundsClosed();
        re.close();
        require(re.state() == RefundEscrow.State.Closed);
        // revert if not owner
        vm.prank(other);
        vm.expectRevert("Ownable: caller is not the owner");
        re.close();
        // revert if not Active state before close()
        vm.expectRevert("RefundEscrow: can only close while active");
        re.close();

        // case 2: Active to Refunding
        re = new RefundEscrow(beneficiary);
        vm.expectEmit(address(re));
        emit RefundsEnabled();
        re.enableRefunds();
        require(re.state() == RefundEscrow.State.Refunding);
        // revert if not owner
        vm.prank(other);
        vm.expectRevert("Ownable: caller is not the owner");
        re.enableRefunds();
        // revert if not Active state before enableRefunds()
        vm.expectRevert("RefundEscrow: can only enable refunds while active");
        re.enableRefunds();
    }

    function test_WithdrawalAllowed() external {
        // case 1: at Active state
        assertFalse(re.withdrawalAllowed(address(0)));
        // case 2: at Closed state
        re.close();
        assertFalse(re.withdrawalAllowed(address(0)));
        // case 3: at Refunding state
        re = new RefundEscrow(beneficiary);
        re.enableRefunds();
        assertTrue(re.withdrawalAllowed(address(0)));
    }

    function test_BeneficiaryWithdraw() external {
        // case 1: revert at Refunding state
        re.enableRefunds();
        vm.expectRevert("RefundEscrow: beneficiary can only withdraw while closed");
        re.beneficiaryWithdraw();

        // case 2: revert at Active state
        re = new RefundEscrow(beneficiary);
        vm.expectRevert("RefundEscrow: beneficiary can only withdraw while closed");
        re.beneficiaryWithdraw();

        // case 3: success at Closed state
        vm.deal(address(re), 1 ether);
        re.close();
        assertEq(0, beneficiary.balance);
        re.beneficiaryWithdraw();
        assertEq(1 ether, beneficiary.balance);
    }

    function test_Deposit() external {
        // revert if not at Active state
        // case 1: at Closed state
        re.close();
        vm.expectRevert("RefundEscrow: can only deposit while active");
        re.deposit{value : 1 ether}(payee);

        // case 2: at Refunding state
        re = new RefundEscrow(beneficiary);
        re.enableRefunds();
        vm.expectRevert("RefundEscrow: can only deposit while active");
        re.deposit{value : 1 ether}(payee);

        // revert if not owner
        re = new RefundEscrow(beneficiary);
        vm.expectRevert("Ownable: caller is not the owner");
        vm.prank(other);
        re.deposit{value : 1 ether}(payee);

        // success at Active state
        re.deposit{value : 1 ether}(payee);
        assertEq(1 ether, address(re).balance);
        assertEq(1 ether, re.depositsOf(payee));

        // deposit again
        re.deposit{value : 2 ether}(payee);
        assertEq(1 ether + 2 ether, address(re).balance);
        assertEq(1 ether + 2 ether, re.depositsOf(payee));

        // deposit to other
        re.deposit{value : 3 ether}(other);
        assertEq(1 ether + 2 ether + 3 ether, address(re).balance);
        assertEq(1 ether + 2 ether, re.depositsOf(payee));
        assertEq(3 ether, re.depositsOf(other));
    }

    function test_Withdraw() external {
        // revert if not at Refunding state
        // case 1: at Active state
        vm.expectRevert("ConditionalEscrow: payee is not allowed to withdraw");
        re.withdraw(payee);
        // case 2: at Closed state
        re.close();
        vm.expectRevert("ConditionalEscrow: payee is not allowed to withdraw");
        re.withdraw(payee);

        // success at Refunding state
        re = new RefundEscrow(beneficiary);
        re.deposit{value : 2 ether}(payee);
        re.deposit{value : 1 ether}(other);
        re.enableRefunds();

        assertEq(0, payee.balance);
        re.withdraw(payee);
        assertEq(2 ether, payee.balance);

        assertEq(10 ether, other.balance);
        re.withdraw(other);
        assertEq(11 ether, other.balance);

        // revert if not owner
        vm.prank(other);
        vm.expectRevert("Ownable: caller is not the owner");
        re.withdraw(other);
    }
}