// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/token/ERC20/utils/TokenTimelock.sol";
import "./MockERC20.sol";

contract TokenTimelockTest is Test {
    address private _beneficiary = address(1024);
    uint private _releaseTime = 2048;
    MockERC20 private _token = new MockERC20("", "");
    TokenTimelock private _testing = new TokenTimelock(_token, _beneficiary, _releaseTime);

    function test_Constructor() external {
        // revert if _releaseTime <= now
        vm.expectRevert("TokenTimelock: release time is before current time");
        new TokenTimelock(_token, _beneficiary, block.timestamp - 1);
        vm.expectRevert("TokenTimelock: release time is before current time");
        new TokenTimelock(_token, _beneficiary, block.timestamp);
    }

    function test_Getter() external {
        assertEq(address(_testing.token()), address(_token));
        assertEq(_testing.beneficiary(), _beneficiary);
        assertEq(_testing.releaseTime(), _releaseTime);
    }

    function test_Release() external {
        uint amountLocked = 10000;
        _token.mint(address(_testing), amountLocked);
        assertEq(_token.balanceOf(address(_testing)), amountLocked);
        assertEq(_token.balanceOf(address(_beneficiary)), 0);

        // case 1: revert if now < _releaseTime
        assert(block.timestamp < _releaseTime);
        vm.expectRevert("TokenTimelock: current time is before release time");
        _testing.release();

        // case 2: pass if now >= _releaseTime
        vm.warp(_releaseTime);
        _testing.release();
        assertEq(_token.balanceOf(address(_testing)), 0);
        assertEq(_token.balanceOf(address(_beneficiary)), amountLocked);

        // case 3: revert if no token in TokenTimelock
        vm.expectRevert("TokenTimelock: no tokens to release");
        _testing.release();
    }
}
