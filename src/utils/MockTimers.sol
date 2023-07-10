// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/Timers.sol";

contract MockTimersTimestamp {
    using Timers for Timers.Timestamp;

    Timers.Timestamp _tt;

    function getDeadline() external view returns (uint64){
        return _tt.getDeadline();
    }

    function setDeadline(uint64 newTimestamp) external {
        _tt.setDeadline(newTimestamp);
    }

    function reset() external {
        _tt.reset();
    }

    function isUnset() external view returns (bool) {
        return _tt.isUnset();
    }

    function isStarted() external view returns (bool) {
        return _tt.isStarted();
    }

    function isPending() external view returns (bool) {
        return _tt.isPending();
    }

    function isExpired() external view returns (bool) {
        return _tt.isExpired();
    }
}

contract MockTimersBlockNumber {
    using Timers for Timers.BlockNumber;

    Timers.BlockNumber _tb;

    function getDeadline() external view returns (uint64){
        return _tb.getDeadline();
    }

    function setDeadline(uint64 newBlockNumber) external {
        _tb.setDeadline(newBlockNumber);
    }

    function reset() external {
        _tb.reset();
    }

    function isUnset() external view returns (bool) {
        return _tb.isUnset();
    }

    function isStarted() external view returns (bool) {
        return _tb.isStarted();
    }

    function isPending() external view returns (bool) {
        return _tb.isPending();
    }

    function isExpired() external view returns (bool) {
        return _tb.isExpired();
    }
}
