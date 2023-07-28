// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/math/SafeMath.sol";

contract MockSafeMath {
    using SafeMath for uint;

    function tryAdd(uint a, uint b) external pure returns (bool, uint) {
        return a.tryAdd(b);
    }

    function trySub(uint a, uint b) external pure returns (bool, uint) {
        return a.trySub(b);
    }

    function tryMul(uint a, uint b) external pure returns (bool, uint) {
        return a.tryMul(b);
    }

    function tryDiv(uint a, uint b) external pure returns (bool, uint) {
        return a.tryDiv(b);
    }

    function tryMod(uint a, uint b) external pure returns (bool, uint) {
        return a.tryMod(b);
    }

    function add(uint a, uint b) external pure returns (uint){
        return a.add(b);
    }

    function sub(uint a, uint b) external pure returns (uint) {
        return a.sub(b);
    }

    function mul(uint a, uint b) external pure returns (uint){
        return a.mul(b);
    }

    function div(uint a, uint b) external pure returns (uint) {
        return a.div(b);
    }

    function mod(uint a, uint b) external pure returns (uint) {
        return a.mod(b);
    }

    function sub(
        uint a,
        uint b,
        string memory errorMessage
    ) external pure returns (uint){
        return a.sub(b, errorMessage);
    }

    function div(
        uint a,
        uint b,
        string memory errorMessage
    ) external pure returns (uint) {
        return a.div(b, errorMessage);
    }

    function mod(
        uint a,
        uint b,
        string memory errorMessage
    ) external pure returns (uint) {
        return a.mod(b, errorMessage);
    }
}
