// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/math/SignedSafeMath.sol";

contract MockSignedSafeMath {
    using SignedSafeMath for int;

    function mul(int a, int b) external pure returns (int) {
        return a.mul(b);
    }

    function div(int a, int b) external pure returns (int){
        return a.div(b);
    }

    function sub(int a, int b) external pure returns (int){
        return a.sub(b);
    }

    function add(int a, int b) external pure returns (int) {
        return a.add(b);
    }
}
