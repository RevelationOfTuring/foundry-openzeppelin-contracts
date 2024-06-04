// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/finance/VestingWallet.sol";
import "./MockERC20.sol";

contract VestingWalletTest is Test {
    VestingWallet private _testing;
    MockERC20 private _erc20 = new MockERC20("test name", "test symbol");
    address private _beneficiary = address(1024);
    uint64 private _startTimestamp = 100;
    uint64 private _durationSeconds = 1000;
    uint private _initialAmount = 10000;

    function setUp() external {
        _testing = new VestingWallet(
            _beneficiary,
            _startTimestamp,
            _durationSeconds
        );

        // set eth balance
        vm.deal(address(_testing), _initialAmount);
        // set erc20 balance
        _erc20.mint(address(_testing), _initialAmount);
    }

    function test_Constructor() external {
        assertEq(_testing.beneficiary(), _beneficiary);
        assertEq(_testing.start(), _startTimestamp);
        assertEq(_testing.duration(), _durationSeconds);

        // revert with zero address of beneficiary
        vm.expectRevert("VestingWallet: beneficiary is zero address");
        new VestingWallet(address(0), _startTimestamp, _durationSeconds);
    }

    event EtherReleased(uint amount);

    function test_releaseEth() external {
        // case 1: before start time
        uint64 currentTimestamp = uint64(block.timestamp);
        assertEq(currentTimestamp, 1);
        // test released()
        assertEq(_testing.released(), 0);
        // test releasable()
        assertEq(_testing.releasable(), 0);
        // test vestedAmount(uint64 timestamp)
        assertEq(_testing.vestedAmount(currentTimestamp), 0);

        // at the start time
        vm.warp(_startTimestamp);
        assertEq(_testing.released(), 0);
        assertEq(_testing.releasable(), 0);
        assertEq(_testing.vestedAmount(_startTimestamp), 0);

        // in the duration (first release)
        currentTimestamp = _startTimestamp + 200;
        vm.warp(currentTimestamp);
        uint amountToRelease = _initialAmount * 200 / _durationSeconds;
        assertEq(_testing.released(), 0);
        assertEq(_testing.releasable(), amountToRelease);
        assertEq(_testing.vestedAmount(currentTimestamp), _initialAmount * 200 / _durationSeconds);

        // test release()
        assertEq(address(_testing).balance, _initialAmount);
        vm.expectEmit(address(_testing));
        emit EtherReleased(amountToRelease);
        _testing.release();

        assertEq(address(_testing).balance, _initialAmount - amountToRelease);
        assertEq(_beneficiary.balance, amountToRelease);
        assertEq(_testing.released(), amountToRelease);
        assertEq(_testing.releasable(), 0);
        assertEq(_testing.vestedAmount(currentTimestamp), amountToRelease);

        // in the duration (second release)
        currentTimestamp = currentTimestamp + 400;
        vm.warp(currentTimestamp);
        uint released = amountToRelease;
        amountToRelease = _initialAmount * 400 / _durationSeconds;
        assertEq(_testing.released(), released);
        assertEq(_testing.releasable(), amountToRelease);
        assertEq(_testing.vestedAmount(currentTimestamp), released + amountToRelease);

        // test release()
        assertEq(address(_testing).balance, _initialAmount - released);
        _testing.release();
        assertEq(address(_testing).balance, _initialAmount - released - amountToRelease);
        assertEq(_beneficiary.balance, released + amountToRelease);
        assertEq(_testing.released(), released + amountToRelease);
        assertEq(_testing.releasable(), 0);
        assertEq(_testing.vestedAmount(currentTimestamp), released + amountToRelease);

        // after end time
        currentTimestamp = _startTimestamp + _durationSeconds + 1;
        vm.warp(currentTimestamp);
        released += amountToRelease;
        amountToRelease = _initialAmount - released;
        assertEq(_testing.released(), released);
        assertEq(_testing.releasable(), amountToRelease);
        assertEq(_testing.vestedAmount(currentTimestamp), _initialAmount);

        // test release()
        assertEq(address(_testing).balance, _initialAmount - released);
        _testing.release();
        assertEq(address(_testing).balance, 0);
        assertEq(_beneficiary.balance, _initialAmount);
        assertEq(_testing.released(), _initialAmount);
        assertEq(_testing.releasable(), 0);
        assertEq(_testing.vestedAmount(currentTimestamp), _initialAmount);
    }

    event ERC20Released(address indexed token, uint amount);

    function test_releaseErc20() external {
        address erc20Address = address(_erc20);
        // case 1: before start time
        uint64 currentTimestamp = uint64(block.timestamp);
        assertEq(currentTimestamp, 1);
        // test released(address token)
        assertEq(_testing.released(erc20Address), 0);
        // test releasable(address token)
        assertEq(_testing.releasable(erc20Address), 0);
        // test vestedAmount(address token, uint64 timestamp)
        assertEq(_testing.vestedAmount(erc20Address, currentTimestamp), 0);

        // at the start time
        vm.warp(_startTimestamp);
        assertEq(_testing.released(erc20Address), 0);
        assertEq(_testing.releasable(erc20Address), 0);
        assertEq(_testing.vestedAmount(erc20Address, _startTimestamp), 0);

        // in the duration (first release)
        currentTimestamp = _startTimestamp + 200;
        vm.warp(currentTimestamp);
        uint amountToRelease = _initialAmount * 200 / _durationSeconds;
        assertEq(_testing.released(erc20Address), 0);
        assertEq(_testing.releasable(erc20Address), amountToRelease);
        assertEq(_testing.vestedAmount(erc20Address, currentTimestamp), _initialAmount * 200 / _durationSeconds);

        // test release(address token)
        assertEq(_erc20.balanceOf(address(_testing)), _initialAmount);
        vm.expectEmit(address(_testing));
        emit ERC20Released(erc20Address, amountToRelease);
        _testing.release(erc20Address);

        assertEq(_erc20.balanceOf(address(_testing)), _initialAmount - amountToRelease);
        assertEq(_erc20.balanceOf(_beneficiary), amountToRelease);
        assertEq(_testing.released(erc20Address), amountToRelease);
        assertEq(_testing.releasable(erc20Address), 0);
        assertEq(_testing.vestedAmount(erc20Address, currentTimestamp), amountToRelease);

        // in the duration (second release)
        currentTimestamp = currentTimestamp + 400;
        vm.warp(currentTimestamp);
        uint released = amountToRelease;
        amountToRelease = _initialAmount * 400 / _durationSeconds;
        assertEq(_testing.released(erc20Address), released);
        assertEq(_testing.releasable(erc20Address), amountToRelease);
        assertEq(_testing.vestedAmount(erc20Address, currentTimestamp), released + amountToRelease);

        // test release(address token)
        assertEq(_erc20.balanceOf(address(_testing)), _initialAmount - released);
        _testing.release(erc20Address);
        assertEq(_erc20.balanceOf(address(_testing)), _initialAmount - released - amountToRelease);
        assertEq(_erc20.balanceOf(_beneficiary), released + amountToRelease);
        assertEq(_testing.released(erc20Address), released + amountToRelease);
        assertEq(_testing.releasable(erc20Address), 0);
        assertEq(_testing.vestedAmount(erc20Address, currentTimestamp), released + amountToRelease);

        // after end time
        currentTimestamp = _startTimestamp + _durationSeconds + 1;
        vm.warp(currentTimestamp);
        released += amountToRelease;
        amountToRelease = _initialAmount - released;
        assertEq(_testing.released(erc20Address), released);
        assertEq(_testing.releasable(erc20Address), amountToRelease);
        assertEq(_testing.vestedAmount(erc20Address, currentTimestamp), _initialAmount);

        // test release(address token)
        assertEq(_erc20.balanceOf(address(_testing)), _initialAmount - released);
        _testing.release(erc20Address);
        assertEq(_erc20.balanceOf(address(_testing)), 0);
        assertEq(_erc20.balanceOf(_beneficiary), _initialAmount);
        assertEq(_testing.released(erc20Address), _initialAmount);
        assertEq(_testing.releasable(erc20Address), 0);
        assertEq(_testing.vestedAmount(erc20Address, currentTimestamp), _initialAmount);
    }
}
