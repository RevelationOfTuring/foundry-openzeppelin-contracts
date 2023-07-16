// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/Multicall.sol";

contract MockMulticall is Multicall {
    uint _number;

    function add(uint i) external {
        _number += i;
    }

    function mul(uint i) external {
        _number *= i;
    }

    function getNumber() external view returns (uint){
        return _number;
    }
}
