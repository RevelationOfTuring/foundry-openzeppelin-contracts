// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/Counters.sol";

contract MockCounters {
    using Counters for Counters.Counter;

    Counters.Counter _counter;

    function current() external view returns (uint){
        return _counter.current();
    }

    function increment() external {
        _counter.increment();
    }

    function decrement() external {
        _counter.decrement();
    }

    function reset() external {
        _counter.reset();
    }
}
