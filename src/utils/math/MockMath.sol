// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/math/Math.sol";

contract MockMath {
    using Math for uint;

    function max(uint a, uint b) external pure returns (uint){
        return a.max(b);
    }

    function min(uint a, uint b) external pure returns (uint){
        return a.min(b);
    }

    function average(uint a, uint b) external pure returns (uint){
        return a.average(b);
    }

    function ceilDiv(uint a, uint b) external pure returns (uint){
        return a.ceilDiv(b);
    }

    function mulDiv(uint x, uint y, uint denominator) external pure returns (uint){
        return x.mulDiv(y, denominator);
    }

    function mulDiv(uint x, uint y, uint denominator, Math.Rounding rounding) external pure returns (uint){
        return x.mulDiv(y, denominator, rounding);
    }

    function sqrt(uint a) external pure returns (uint){
        return a.sqrt();
    }

    function sqrt(uint a, Math.Rounding rounding) external pure returns (uint) {
        return a.sqrt(rounding);
    }

    function log2(uint value) external pure returns (uint){
        return value.log2();
    }

    function log2(uint value, Math.Rounding rounding) external pure returns (uint) {
        return value.log2(rounding);
    }

    function log10(uint value) external pure returns (uint) {
        return value.log10();
    }

    function log10(uint value, Math.Rounding rounding) external pure returns (uint) {
        return value.log10(rounding);
    }

    function log256(uint value) external pure returns (uint) {
        return value.log256();
    }

    function log256(uint value, Math.Rounding rounding) external pure returns (uint) {
        return value.log256(rounding);
    }
}
