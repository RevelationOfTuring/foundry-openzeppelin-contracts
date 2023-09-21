// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/access/MockOwnable2Step.sol";

contract Ownable2StepTest is Test {
    MockOwnable2Step private _testing;

    function setUp() external {
        _testing = new MockOwnable2Step();
    }

    function test_OnlyOwner() external {
        assertEq(address(this), _testing.owner());

        // test for modifier: onlyOwner
        // case 1: pass the check of modifier
        assertEq(0, _testing.i());
        _testing.setI(1024);
        assertEq(1024, _testing.i());
        // case 2: revert if the msgSender() is not owner
        vm.prank(address(1024));
        vm.expectRevert("Ownable: caller is not the owner");
        _testing.setI(1024);
    }

    event OwnershipTransferStarted(address indexed previousOwner, address indexed newOwner);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function test_TransferOwnership() external {
        // test for public function: transferOwnership
        assertEq(address(0), _testing.pendingOwner());
        // case 1: pass
        vm.expectEmit(true, true, false, false, address(_testing));
        emit OwnershipTransferStarted(address(this), address(1024));
        _testing.transferOwnership(address(1024));
        assertEq(address(1024), _testing.pendingOwner());

        // test for internal function: _transferOwnership
        // case 1: pass with clearing pending owner and new owner transferred
        vm.expectEmit(true, true, false, false, address(_testing));
        emit OwnershipTransferred(address(this), address(2048));
        _testing.transferOwnershipInternal(address(2048));
        // new owner transferred
        assertEq(address(2048), _testing.owner());
        // clear the pending owner
        assertEq(address(0), _testing.pendingOwner());
    }

    function test_AcceptOwnership() external {
        // case 1: pass
        _testing.transferOwnership(address(1024));
        assertEq(address(1024), _testing.pendingOwner());
        assertEq(address(this), _testing.owner());
        vm.prank(address(1024));
        vm.expectEmit(true, true, false, false, address(_testing));
        emit OwnershipTransferred(address(this), address(1024));
        _testing.acceptOwnership();
        // clear the pending owner
        assertEq(address(0), _testing.pendingOwner());
        // new owner transferred
        assertEq(address(1024), _testing.owner());

        // case 2: revert if _msgSender() is not pending owner
        // current pending owner is address(0)
        vm.expectRevert("Ownable2Step: caller is not the new owner");
        vm.prank(address(1));
        _testing.acceptOwnership();
    }
}
