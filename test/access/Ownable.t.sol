// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/access/MockOwnable.sol";

contract OwnableTest is Test {
    MockOwnable private _testing;

    function setUp() external {
        _testing = new MockOwnable();
    }

    function test_CheckOwnerAndOnlyOwner() external {
        assertEq(address(this), _testing.owner());
        // test for internal function: _checkOwner
        // case 1: pass
        _testing.checkOwner();
        // case 2: revert if the msgSender() is not owner
        vm.prank(address(1024));
        vm.expectRevert("Ownable: caller is not the owner");
        _testing.checkOwner();

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function test_TransferOwnership() external {
        // test for public function: transferOwnership
        assertEq(address(this), _testing.owner());
        // case 1: pass
        vm.expectEmit(true, true, false, false, address(_testing));
        emit OwnershipTransferred(address(this), address(1024));
        _testing.transferOwnership(address(1024));
        assertEq(address(1024), _testing.owner());
        // case 2: revert if new owner is 0
        vm.prank(address(1024));
        vm.expectRevert("Ownable: new owner is the zero address");
        _testing.transferOwnership(address(0));

        // test for internal function: _transferOwnership
        // case 1: pass with any address of new owner
        vm.expectEmit(true, true, false, false, address(_testing));
        emit OwnershipTransferred(address(1024), address(2048));
        _testing.transferOwnershipInternal(address(2048));
        assertEq(address(2048), _testing.owner());
        vm.expectEmit(true, true, false, false, address(_testing));
        emit OwnershipTransferred(address(2048), address(0));
        _testing.transferOwnershipInternal(address(0));
        assertEq(address(0), _testing.owner());
    }

    function test_RenounceOwnership() external {
        assertEq(address(this), _testing.owner());
        vm.expectEmit(true, true, false, false, address(_testing));
        emit OwnershipTransferred(address(this), address(0));
        _testing.renounceOwnership();
        assertEq(address(0), _testing.owner());
    }
}
