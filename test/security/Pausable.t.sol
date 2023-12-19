// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/security/MockPausable.sol";

contract PausableTest is Test {
    MockPausable private _testing = new MockPausable();

    event Paused(address account);
    event Unpaused(address account);

    function test_PauseAndUnpauseAndPaused() external {
        assertFalse(_testing.paused());

        // 1. test _pause()
        vm.expectEmit(false, false, false, true, address(_testing));
        emit Paused(address(this));
        _testing.pause();
        assertTrue(_testing.paused());

        // revert if the contract is on paused
        vm.expectRevert("Pausable: paused");
        _testing.pause();

        // 2. test _unpause()
        vm.expectEmit(false, false, false, true, address(_testing));
        emit Unpaused(address(this));
        _testing.unpause();
        assertFalse(_testing.paused());

        // revert if the contract is on not paused
        vm.expectRevert("Pausable: not paused");
        _testing.unpause();
    }

    function test_WhenNotPausedAndWhenPaused() external {
        assertFalse(_testing.paused());
        // pass modifier 'whenNotPaused'
        _testing.doSomethingWhenNotPaused();

        // not pass modifier 'whenPaused'
        vm.expectRevert("Pausable: not paused");
        _testing.doSomethingWhenPaused();

        // pause the contract
        _testing.pause();
        assertTrue(_testing.paused());

        // pass modifier 'whenPaused'
        _testing.doSomethingWhenPaused();

        // not pass modifier 'whenPaused'
        vm.expectRevert("Pausable: paused");
        _testing.doSomethingWhenNotPaused();
    }
}
