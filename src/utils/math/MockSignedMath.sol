// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/math/SignedMath.sol";

contract MockSignedMath {
    using SignedMath for int;

    function max(int a, int b) external pure returns (int) {
        return a.max(b);
    }

    function min(int a, int b) external pure returns (int) {
        return a.min(b);
    }

    function average(int a, int b) external pure returns (int){
        return a.average(b);
    }

    function abs(int n) external pure returns (uint) {
        return n.abs();
    }
}
