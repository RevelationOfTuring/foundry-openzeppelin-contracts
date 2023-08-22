// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

contract MockECDSA {
    using ECDSA for bytes32;

    function tryRecover(bytes32 hash, bytes memory signature) external pure returns (address, ECDSA.RecoverError) {
        return hash.tryRecover(signature);
    }

    function recover(bytes32 hash, bytes memory signature) external pure returns (address) {
        return hash.recover(signature);
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) external pure returns (address, ECDSA.RecoverError) {
        return hash.tryRecover(r, vs);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) external pure returns (address){
        return hash.recover(r, vs);
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external pure returns (address, ECDSA.RecoverError) {
        return hash.tryRecover(v, r, s);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external pure returns (address){
        return hash.recover(v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash) external pure returns (bytes32) {
        return hash.toEthSignedMessageHash();
    }

    function toEthSignedMessageHash(bytes memory s) external pure returns (bytes32) {
        return ECDSA.toEthSignedMessageHash(s);
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) external pure returns (bytes32) {
        return domainSeparator.toTypedDataHash(structHash);
    }
}
