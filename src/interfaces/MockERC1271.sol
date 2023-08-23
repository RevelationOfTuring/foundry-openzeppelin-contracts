// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/interfaces/IERC1271.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

contract MockERC1271 is IERC1271 {
    using ECDSA for bytes32;

    address _signerEOA;

    constructor(address signerEOA){
        _signerEOA = signerEOA;
    }

    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue){
        return hash.recover(signature) == _signerEOA ? IERC1271.isValidSignature.selector : bytes4(0);
    }
}