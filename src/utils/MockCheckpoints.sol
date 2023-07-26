// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/Checkpoints.sol";

contract MockCheckpointsHistory {
    using Checkpoints for Checkpoints.History;

    Checkpoints.History _history;

    function getAtBlock(uint blockNumber) external view returns (uint) {
        return _history.getAtBlock(blockNumber);
    }

    function getAtProbablyRecentBlock(uint blockNumber) external view returns (uint){
        return _history.getAtProbablyRecentBlock(blockNumber);
    }

    function push(uint value) external returns (uint, uint) {
        return _history.push(value);
    }

    // a customized function for update latest value of _history
    function op(uint latestValue, uint delta) internal pure returns (uint){
        return latestValue + delta;
    }

    function pushWithOp(uint delta) external returns (uint, uint) {
        return _history.push(op, delta);
    }

    function latest() external view returns (uint224){
        return _history.latest();
    }

    function latestCheckpoint() external view returns (
        bool exists,
        uint32 _blockNumber,
        uint224 _value
    ){
        return _history.latestCheckpoint();
    }

    function length() external view returns (uint){
        return _history.length();
    }
}

contract MockCheckpointsTrace224 {
    using Checkpoints for Checkpoints.Trace224;

    Checkpoints.Trace224 _trace224;

    function push(
        uint32 key,
        uint224 value
    ) external returns (uint224, uint224){
        return _trace224.push(key, value);
    }

    function lowerLookup(uint32 key) external view returns (uint224){
        return _trace224.lowerLookup(key);
    }

    function upperLookup(uint32 key) external view returns (uint224){
        return _trace224.upperLookup(key);
    }

    function latest() external view returns (uint224) {
        return _trace224.latest();
    }

    function latestCheckpoint() external view returns (
        bool exists,
        uint32 _key,
        uint224 _value
    ){
        return _trace224.latestCheckpoint();
    }

    function length() external view returns (uint) {
        return _trace224.length();
    }
}

contract MockCheckpointsTrace160 {
    using Checkpoints for Checkpoints.Trace160;

    Checkpoints.Trace160 _trace160;

    function push(
        uint96 key,
        uint160 value
    ) external returns (uint160, uint160){
        return _trace160.push(key, value);
    }

    function lowerLookup(uint96 key) external view returns (uint160){
        return _trace160.lowerLookup(key);
    }

    function upperLookup(uint96 key) external view returns (uint160) {
        return _trace160.upperLookup(key);
    }

    function latest() external view returns (uint160) {
        return _trace160.latest();
    }

    function latestCheckpoint() external view returns (
        bool exists,
        uint96 _key,
        uint160 _value
    ){
        return _trace160.latestCheckpoint();
    }

    function length() external view returns (uint) {
        return _trace160.length();
    }
}
