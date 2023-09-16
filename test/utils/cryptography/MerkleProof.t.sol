// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/utils/cryptography/MockMerkleProof.sol";

contract MerkleProofTest is Test {
    using stdJson for string;

    struct MerkleProofData {
        address account;
        uint amount;
        bytes32[] proof;
    }

    struct Leaf {
        address account;
        uint amount;
    }

    string private _jsonMerkleTree = vm.readFile("test/utils/cryptography/data/merkle_tree.json");
    string private _jsonMerkleProof = vm.readFile("test/utils/cryptography/data/merkle_proof.json");
    string private _jsonMerkleMultiProof = vm.readFile("test/utils/cryptography/data/merkle_multi_proof.json");
    bytes32 private _rootHash = _jsonMerkleTree.readBytes32(".merkle_root");
    MockMerkleProof private _testing = new MockMerkleProof(_rootHash);

    function test_Verify() external {
        // case 1: pass
        MerkleProofData[] memory merkleProofData = abi.decode(_jsonMerkleProof.parseRaw(""), (MerkleProofData[]));
        for (uint i = 0; i < merkleProofData.length; ++i) {
            assertTrue(_testing.verify(merkleProofData[i].proof, merkleProofData[i].account, merkleProofData[i].amount));
        }

        // case 2: return false if account or amount are changed
        for (uint i = 0; i < merkleProofData.length; ++i) {
            assertFalse(_testing.verify(merkleProofData[i].proof, merkleProofData[i].account, merkleProofData[i].amount + 1));
            assertFalse(_testing.verify(merkleProofData[i].proof, address(uint160(merkleProofData[i].account) + 1), merkleProofData[i].amount));
        }

        // case 3: return false if proof is incorrect
        for (uint i = 1; i < merkleProofData.length; ++i) {
            assertFalse(_testing.verify(merkleProofData[0].proof, merkleProofData[i].account, merkleProofData[i].amount));
        }
    }

    function test_VerifyCalldata() external {
        // case 1: pass
        MerkleProofData[] memory merkleProofData = abi.decode(_jsonMerkleProof.parseRaw(""), (MerkleProofData[]));
        for (uint i = 0; i < merkleProofData.length; ++i) {
            assertTrue(_testing.verifyCalldata(merkleProofData[i].proof, merkleProofData[i].account, merkleProofData[i].amount));
        }

        // case 2: return false if account or amount are changed
        for (uint i = 0; i < merkleProofData.length; ++i) {
            assertFalse(_testing.verifyCalldata(merkleProofData[i].proof, merkleProofData[i].account, merkleProofData[i].amount + 1));
            assertFalse(_testing.verifyCalldata(merkleProofData[i].proof, address(uint160(merkleProofData[i].account) + 1), merkleProofData[i].amount));
        }

        // case 3: return false if proof is incorrect
        for (uint i = 1; i < merkleProofData.length; ++i) {
            assertFalse(_testing.verifyCalldata(merkleProofData[0].proof, merkleProofData[i].account, merkleProofData[i].amount));
        }
    }

    function test_ProcessProof() external {
        MerkleProofData[] memory merkleProofData = abi.decode(_jsonMerkleProof.parseRaw(""), (MerkleProofData[]));
        for (uint i = 0; i < merkleProofData.length; ++i) {
            // case 1: correct leaf with correct proof
            bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(merkleProofData[i].account, merkleProofData[i].amount))));
            assertEq(_rootHash, _testing.processProof(merkleProofData[i].proof, leaf));
            // case 2: bad leaf with account or amount are changed
            bytes32 badLeaf = keccak256(bytes.concat(keccak256(abi.encode(merkleProofData[i].account, merkleProofData[i].amount + 1))));
            assertNotEq(_rootHash, _testing.processProof(merkleProofData[i].proof, badLeaf));
            badLeaf = keccak256(bytes.concat(keccak256(abi.encode(address(uint160(merkleProofData[i].account) + 1), merkleProofData[i].amount))));
            assertNotEq(_rootHash, _testing.processProof(merkleProofData[i].proof, badLeaf));
        }

        // case 3: if proof is incorrect
        for (uint i = 1; i < merkleProofData.length; ++i) {
            bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(merkleProofData[i].account, merkleProofData[i].amount))));
            assertNotEq(_rootHash, _testing.processProof(merkleProofData[0].proof, leaf));
        }
    }

    function test_ProcessProofCalldata() external {
        MerkleProofData[] memory merkleProofData = abi.decode(_jsonMerkleProof.parseRaw(""), (MerkleProofData[]));
        for (uint i = 0; i < merkleProofData.length; ++i) {
            // case 1: correct leaf with correct proof
            bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(merkleProofData[i].account, merkleProofData[i].amount))));
            assertEq(_rootHash, _testing.processProofCalldata(merkleProofData[i].proof, leaf));
            // case 2: bad leaf with account or amount are changed
            bytes32 badLeaf = keccak256(bytes.concat(keccak256(abi.encode(merkleProofData[i].account, merkleProofData[i].amount + 1))));
            assertNotEq(_rootHash, _testing.processProofCalldata(merkleProofData[i].proof, badLeaf));
            badLeaf = keccak256(bytes.concat(keccak256(abi.encode(address(uint160(merkleProofData[i].account) + 1), merkleProofData[i].amount))));
            assertNotEq(_rootHash, _testing.processProofCalldata(merkleProofData[i].proof, badLeaf));
        }

        // case 3: if proof is incorrect
        for (uint i = 1; i < merkleProofData.length; ++i) {
            bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(merkleProofData[i].account, merkleProofData[i].amount))));
            assertNotEq(_rootHash, _testing.processProofCalldata(merkleProofData[0].proof, leaf));
        }
    }

    function test_MultiProofVerify() external {
        // case 1: pass
        bytes32[] memory proof = _jsonMerkleMultiProof.readBytes32Array(".proof");
        bool[] memory proofFlags = _jsonMerkleMultiProof.readBoolArray(".proof_flags");
        (address[] memory accounts, uint[] memory amounts) = _getAccountsAndAmounts();
        assertTrue(_testing.multiProofVerify(
            proof,
            proofFlags,
            accounts,
            amounts
        ));

        // case 2: return false with account changed
        accounts[0] = address(uint160(accounts[0]) + 1);
        assertFalse(_testing.multiProofVerify(
            proof,
            proofFlags,
            accounts,
            amounts
        ));

        // case 3: return false with account changed
        (accounts, amounts) = _getAccountsAndAmounts();
        amounts[0] += 1;
        assertFalse(_testing.multiProofVerify(
            proof,
            proofFlags,
            accounts,
            amounts
        ));

        // case 4: return false with proof flags changed
        (accounts, amounts) = _getAccountsAndAmounts();
        proofFlags[0] = !proofFlags[0];
        proofFlags[1] = !proofFlags[1];
        assertFalse(_testing.multiProofVerify(
            proof,
            proofFlags,
            accounts,
            amounts
        ));

        // case 5: return false with the order of proof changed
        proofFlags = _jsonMerkleMultiProof.readBoolArray(".proof_flags");
        bytes32 tmpBytes32 = proof[0];
        proof[0] = proof[1];
        proof[1] = tmpBytes32;
        assertFalse(_testing.multiProofVerify(
            proof,
            proofFlags,
            accounts,
            amounts
        ));
    }

    function test_MultiProofVerifyCalldata() external {
        // case 1: pass
        bytes32[] memory proof = _jsonMerkleMultiProof.readBytes32Array(".proof");
        bool[] memory proofFlags = _jsonMerkleMultiProof.readBoolArray(".proof_flags");
        (address[] memory accounts, uint[] memory amounts) = _getAccountsAndAmounts();
        assertTrue(_testing.multiProofVerifyCalldata(
            proof,
            proofFlags,
            accounts,
            amounts
        ));

        // case 2: return false with account changed
        accounts[0] = address(uint160(accounts[0]) + 1);
        assertFalse(_testing.multiProofVerifyCalldata(
            proof,
            proofFlags,
            accounts,
            amounts
        ));

        // case 3: return false with account changed
        (accounts, amounts) = _getAccountsAndAmounts();
        amounts[0] += 1;
        assertFalse(_testing.multiProofVerifyCalldata(
            proof,
            proofFlags,
            accounts,
            amounts
        ));

        // case 4: return false with proof flags changed
        (accounts, amounts) = _getAccountsAndAmounts();
        proofFlags[0] = !proofFlags[0];
        proofFlags[1] = !proofFlags[1];
        assertFalse(_testing.multiProofVerifyCalldata(
            proof,
            proofFlags,
            accounts,
            amounts
        ));

        // case 5: return false with the order of proof changed
        proofFlags = _jsonMerkleMultiProof.readBoolArray(".proof_flags");
        bytes32 tmpBytes32 = proof[0];
        proof[0] = proof[1];
        proof[1] = tmpBytes32;
        assertFalse(_testing.multiProofVerifyCalldata(
            proof,
            proofFlags,
            accounts,
            amounts
        ));
    }

    function test_ProcessMultiProof() external {
        bytes32[] memory proof = _jsonMerkleMultiProof.readBytes32Array(".proof");
        bool[] memory proofFlags = _jsonMerkleMultiProof.readBoolArray(".proof_flags");
        (address[] memory accounts, uint[] memory amounts) = _getAccountsAndAmounts();
        bytes32[] memory leaves = new bytes32[](accounts.length);
        for (uint i = 0; i < leaves.length; ++i) {
            leaves[i] = keccak256(bytes.concat(keccak256(abi.encode(accounts[i], amounts[i]))));
        }

        // case 1: correct leaves with correct proof
        assertEq(_rootHash, _testing.processMultiProof(proof, proofFlags, leaves));

        // case 2: bad leaves with account or amount are changed
        bytes32[] memory badLeaves = new bytes32[](leaves.length);
        for (uint i = 0; i < badLeaves.length; ++i) {
            badLeaves[i] = leaves[i];
        }
        badLeaves[1] = keccak256(bytes.concat(keccak256(abi.encode(accounts[1], amounts[1] + 1))));
        assertNotEq(_rootHash, _testing.processMultiProof(proof, proofFlags, badLeaves));
        badLeaves[1] = keccak256(bytes.concat(keccak256(abi.encode(address(uint160(accounts[1]) + 1), amounts[1]))));
        assertNotEq(_rootHash, _testing.processMultiProof(proof, proofFlags, badLeaves));

        // case 3: if proof is incorrect
        proof[1] = bytes32(uint(proof[1]) + 1);
        assertNotEq(_rootHash, _testing.processMultiProof(proof, proofFlags, leaves));

        // case 4: if proof flags are incorrect
        proof = _jsonMerkleMultiProof.readBytes32Array(".proof");
        proofFlags[0] = !proofFlags[0];
        proofFlags[1] = !proofFlags[1];
        assertNotEq(_rootHash, _testing.processMultiProof(proof, proofFlags, leaves));

        // case 5: revert with invalid multiproof
        proofFlags = _jsonMerkleMultiProof.readBoolArray(".proof_flags");
        bytes32[] memory incompleteLeaves = new bytes32[](leaves.length - 1);
        for (uint i = 0; i < leaves.length - 1; ++i) {
            incompleteLeaves[i] = leaves[i];
        }
        vm.expectRevert("MerkleProof: invalid multiproof");
        _testing.processMultiProof(proof, proofFlags, incompleteLeaves);
    }

    function test_ProcessMultiProofCalldata() external {
        bytes32[] memory proof = _jsonMerkleMultiProof.readBytes32Array(".proof");
        bool[] memory proofFlags = _jsonMerkleMultiProof.readBoolArray(".proof_flags");
        (address[] memory accounts, uint[] memory amounts) = _getAccountsAndAmounts();
        bytes32[] memory leaves = new bytes32[](accounts.length);
        for (uint i = 0; i < leaves.length; ++i) {
            leaves[i] = keccak256(bytes.concat(keccak256(abi.encode(accounts[i], amounts[i]))));
        }

        // case 1: correct leaves with correct proof
        assertEq(_rootHash, _testing.processMultiProofCalldata(proof, proofFlags, leaves));

        // case 2: bad leaves with account or amount are changed
        bytes32[] memory badLeaves = new bytes32[](leaves.length);
        for (uint i = 0; i < badLeaves.length; ++i) {
            badLeaves[i] = leaves[i];
        }
        badLeaves[1] = keccak256(bytes.concat(keccak256(abi.encode(accounts[1], amounts[1] + 1))));
        assertNotEq(_rootHash, _testing.processMultiProofCalldata(proof, proofFlags, badLeaves));
        badLeaves[1] = keccak256(bytes.concat(keccak256(abi.encode(address(uint160(accounts[1]) + 1), amounts[1]))));
        assertNotEq(_rootHash, _testing.processMultiProofCalldata(proof, proofFlags, badLeaves));

        // case 3: if proof is incorrect
        proof[1] = bytes32(uint(proof[1]) + 1);
        assertNotEq(_rootHash, _testing.processMultiProofCalldata(proof, proofFlags, leaves));

        // case 4: if proof flags are incorrect
        proof = _jsonMerkleMultiProof.readBytes32Array(".proof");
        proofFlags[0] = !proofFlags[0];
        proofFlags[1] = !proofFlags[1];
        assertNotEq(_rootHash, _testing.processMultiProofCalldata(proof, proofFlags, leaves));

        // case 5: revert with invalid multiproof
        proofFlags = _jsonMerkleMultiProof.readBoolArray(".proof_flags");
        bytes32[] memory incompleteLeaves = new bytes32[](leaves.length - 1);
        for (uint i = 0; i < leaves.length - 1; ++i) {
            incompleteLeaves[i] = leaves[i];
        }
        vm.expectRevert("MerkleProof: invalid multiproof");
        _testing.processMultiProofCalldata(proof, proofFlags, incompleteLeaves);
    }

    function _getAccountsAndAmounts() private view returns (address[] memory, uint[] memory){
        Leaf[] memory leaves = abi.decode(_jsonMerkleMultiProof.parseRaw(".leaves"), (Leaf[]));
        address[] memory accounts = new address[](leaves.length);
        uint[] memory amounts = new uint[](leaves.length);
        for (uint i = 0; i < leaves.length; ++i) {
            accounts[i] = leaves[i].account;
            amounts[i] = leaves[i].amount;
        }

        return (accounts, amounts);
    }
}