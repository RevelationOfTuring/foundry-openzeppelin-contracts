// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/Strings.sol";

contract MockStrings {
    using Strings for uint;
    using Strings for address;

    function toString(uint value) external pure returns (string memory){
        return value.toString();
    }

    function toHexString(uint value) external pure returns (string memory){
        return value.toHexString();
    }

    function toHexString(uint value, uint length) external pure returns (string memory){
        return value.toHexString(length);
    }

    function toHexString(address addr) external pure returns (string memory){
        return addr.toHexString();
    }
}
