// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

contract MockMerkleProof {
    using MerkleProof for bytes32[];
    bytes32 private _root;

    constructor(bytes32 root){
        _root = root;
    }

    function verify(
        bytes32[] memory proof,
        address account,
        uint amount
    ) external view returns (bool) {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        return proof.verify(_root, leaf);
    }

    function verifyCalldata(
        bytes32[] calldata proof,
        address account,
        uint amount
    ) external view returns (bool) {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        return proof.verifyCalldata(_root, leaf);
    }

    function processProof(bytes32[] memory proof, bytes32 leaf) external pure returns (bytes32){
        return proof.processProof(leaf);
    }

    function processProofCalldata(bytes32[] calldata proof, bytes32 leaf) external pure returns (bytes32) {
        return proof.processProofCalldata(leaf);
    }

    function multiProofVerify(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        address[] memory accounts,
        uint[] memory amounts
    ) external view returns (bool){
        uint len = accounts.length;
        require(len == amounts.length, "length unmatched");
        bytes32[] memory leaves = new bytes32[](len);
        for (uint i = 0; i < len; i++) {
            leaves[i] = keccak256(bytes.concat(keccak256(abi.encode(accounts[i], amounts[i]))));
        }

        return proof.multiProofVerify(proofFlags, _root, leaves);
    }

    function multiProofVerifyCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        address[] calldata accounts,
        uint[] calldata amounts
    ) external view returns (bool) {
        uint len = accounts.length;
        require(len == amounts.length, "length unmatched");
        bytes32[] memory leaves = new bytes32[](len);
        for (uint i = 0; i < len; i++) {
            leaves[i] = keccak256(bytes.concat(keccak256(abi.encode(accounts[i], amounts[i]))));
        }

        return proof.multiProofVerifyCalldata(proofFlags, _root, leaves);
    }

    function processMultiProof(
        bytes32[] memory proof,
        bool[] memory proofFlags,
        bytes32[] memory leaves
    ) external pure returns (bytes32 merkleRoot) {
        return proof.processMultiProof(proofFlags, leaves);
    }

    function processMultiProofCalldata(
        bytes32[] calldata proof,
        bool[] calldata proofFlags,
        bytes32[] memory leaves
    ) external pure returns (bytes32 merkleRoot) {
        return proof.processMultiProofCalldata(proofFlags, leaves);
    }
}
