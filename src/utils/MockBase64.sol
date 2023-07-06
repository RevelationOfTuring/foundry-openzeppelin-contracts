// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/Base64.sol";

contract MockBase64 {
    using Base64 for bytes;

    function encode(bytes memory rawBytes) external pure returns (string memory){
        return rawBytes.encode();
    }
}
