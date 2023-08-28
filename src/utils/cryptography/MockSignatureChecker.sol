// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/cryptography/SignatureChecker.sol";

contract MockSignatureChecker {
    using SignatureChecker for address;

    function isValidSignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) external view returns (bool){
        return signer.isValidSignatureNow(hash, signature);
    }
}
