// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/utils/cryptography/MockECDSA.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";

contract ECDSATest is Test {
    using stdJson for string;

    MockECDSA me = new MockECDSA();
    uint signerPrivateKey = 1024;
    address signerAddress = vm.addr(signerPrivateKey);
    string jsonTestData = vm.readFile("test/utils/cryptography/data/ECDSA_test.json");

    function test_ToEthSignedMessageHash() external {
        // case 1: hash digest
        bytes32 digestHash = keccak256("Michael.W");
        bytes32 ethSignedMessageHash = me.toEthSignedMessageHash(digestHash);
        bytes32 expectedEthSignedMessageHash = jsonTestData.readBytes32(".eth_signed_msg_hash_from_hash");
        assertEq(expectedEthSignedMessageHash, ethSignedMessageHash);

        // case 2: bytes digest
        bytes memory digestBytes = bytes("Michael.W");
        ethSignedMessageHash = me.toEthSignedMessageHash(digestBytes);
        expectedEthSignedMessageHash = jsonTestData.readBytes32(".eth_signed_msg_hash_from_bytes");
        assertEq(expectedEthSignedMessageHash, ethSignedMessageHash);
    }

    function test_ToTypedDataHash() external {
        // set chain id
        vm.chainId(1024);
        // get fixed address of TargetEIP712 contract
        vm.setNonce(address(1024), 1024);
        vm.prank(address(1024));
        TargetEIP712 te = new TargetEIP712();
        // fixed contract address is 0x7a41fc8b73D6F307830b88878caf48D077128F63
        assertEq(0x7a41fc8b73D6F307830b88878caf48D077128F63, address(te));

        bytes32 structHash = jsonTestData.readBytes32(".struct_hash");
        bytes32 typedDataHash = me.toTypedDataHash(te.getDomainSeparator(), structHash);
        bytes32 expectedTypedDataHash = jsonTestData.readBytes32(".typed_data_hash");
        assertEq(expectedTypedDataHash, typedDataHash);
    }

    function test_TryRecover_WithVRS() external {
        // case 1: pass tryRecover() with no RecoverError
        bytes32 ethSignedMessageHash = me.toEthSignedMessageHash(bytes("Michael.W"));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, ethSignedMessageHash);
        (address signerRecovered, ECDSA.RecoverError error) = me.tryRecover(ethSignedMessageHash, v, r, s);
        assertEq(signerAddress, signerRecovered);
        assertTrue(error == ECDSA.RecoverError.NoError);

        //  case 2: return InvalidSignatureS error with an s value > secp256k1n/2
        bytes32 sInvalid = bytes32(type(uint).max);
        (signerRecovered, error) = me.tryRecover(ethSignedMessageHash, v, r, sInvalid);
        assertEq(address(0), signerRecovered);
        assertTrue(error == ECDSA.RecoverError.InvalidSignatureS);

        // case 3: return InvalidSignature error with zero v/r/s
        (signerRecovered, error) = me.tryRecover(ethSignedMessageHash, 0, 0, 0);
        assertEq(address(0), signerRecovered);
        assertTrue(error == ECDSA.RecoverError.InvalidSignature);

        // case 4: return an arbitrary signer and no RecoverError for another hash digest
        (signerRecovered, error) = me.tryRecover(me.toEthSignedMessageHash(bytes("Michael.W/Michael.W")), v, r, s);
        assertNotEq(signerAddress, signerRecovered);
        assertTrue(error == ECDSA.RecoverError.NoError);
    }

    function test_Recover_WithVRS() external {
        // case 1: pass recover() with no RecoverError
        bytes32 ethSignedMessageHash = me.toEthSignedMessageHash(bytes("Michael.W"));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, ethSignedMessageHash);
        address signerRecovered = me.recover(ethSignedMessageHash, v, r, s);
        assertEq(signerAddress, signerRecovered);

        //  case 2: revert with an s value > secp256k1n/2
        bytes32 sInvalid = bytes32(type(uint).max);
        vm.expectRevert("ECDSA: invalid signature 's' value");
        me.recover(ethSignedMessageHash, v, r, sInvalid);

        // case 3: revert with zero v/r/s
        vm.expectRevert("ECDSA: invalid signature");
        me.recover(ethSignedMessageHash, 0, 0, 0);

        // case 4: return an arbitrary signer for another hash digest
        signerRecovered = me.recover(me.toEthSignedMessageHash(bytes("Michael.W/Michael.W")), v, r, s);
        assertNotEq(signerAddress, signerRecovered);
    }

    function test_TryRecover_WithSignature() external {
        // case 1: pass tryRecover() with no RecoverError
        bytes memory validSig = jsonTestData.readBytes(".valid_signature");
        bytes32 digestHash = me.toEthSignedMessageHash(bytes("Michael.W"));
        (address signerRecovered, ECDSA.RecoverError error) = me.tryRecover(digestHash, validSig);
        assertEq(signerAddress, signerRecovered);
        assertTrue(error == ECDSA.RecoverError.NoError);

        // case 2: return InvalidSignatureLength if signature's length != 65
        (signerRecovered, error) = me.tryRecover(digestHash, '0x');
        assertEq(address(0), signerRecovered);
        assertTrue(error == ECDSA.RecoverError.InvalidSignatureLength);

        // case 3: return InvalidSignatureS if s value (second bytes32) in signature > secp256k1n/2
        bytes memory invalidSig = abi.encodePacked(bytes32(0), type(uint).max, uint8(0));
        (signerRecovered, error) = me.tryRecover(digestHash, invalidSig);
        assertEq(address(0), signerRecovered);
        assertTrue(error == ECDSA.RecoverError.InvalidSignatureS);

        // case 4: return InvalidSignature error with signature of zero v/r/s
        invalidSig = abi.encodePacked(bytes32(0), bytes32(0), uint8(0));
        (signerRecovered, error) = me.tryRecover(digestHash, invalidSig);
        assertEq(address(0), signerRecovered);
        assertTrue(error == ECDSA.RecoverError.InvalidSignature);

        // case 5: return an arbitrary signer and no RecoverError for another hash digest
        (signerRecovered, error) = me.tryRecover(me.toEthSignedMessageHash(bytes("Michael.W/Michael.W")), validSig);
        assertNotEq(signerAddress, signerRecovered);
        assertTrue(error == ECDSA.RecoverError.NoError);
    }

    function test_Recover_WithSignature() external {
        // case 1: pass recover() with no RecoverError
        bytes memory validSig = jsonTestData.readBytes(".valid_signature");
        bytes32 digestHash = me.toEthSignedMessageHash(bytes("Michael.W"));
        address signerRecovered = me.recover(digestHash, validSig);
        assertEq(signerAddress, signerRecovered);

        // case 2: revert if signature's length != 65
        vm.expectRevert("ECDSA: invalid signature length");
        me.recover(digestHash, '0x');

        // case 3: revert if s value (second bytes32) in signature > secp256k1n/2
        bytes memory invalidSig = abi.encodePacked(bytes32(0), type(uint).max, uint8(0));
        vm.expectRevert("ECDSA: invalid signature 's' value");
        me.recover(digestHash, invalidSig);

        // case 4: revert with signature of zero v/r/s
        invalidSig = abi.encodePacked(bytes32(0), bytes32(0), uint8(0));
        vm.expectRevert("ECDSA: invalid signature");
        me.recover(digestHash, invalidSig);


        // case 5: return an arbitrary signer and no RecoverError for another hash digest
        signerRecovered = me.recover(me.toEthSignedMessageHash(bytes("Michael.W/Michael.W")), validSig);
        assertNotEq(signerAddress, signerRecovered);
    }

    function test_TryRecover_WithRAndVS() external {
        // case 1: pass tryRecover() with no RecoverError
        bytes32 ethSignedMessageHash = me.toEthSignedMessageHash(bytes("Michael.W"));
        bytes32 r = jsonTestData.readBytes32(".compact_signature_r");
        bytes32 vs = jsonTestData.readBytes32(".compact_signature_vs");
        (address signerRecovered, ECDSA.RecoverError error) = me.tryRecover(ethSignedMessageHash, r, vs);
        assertEq(signerAddress, signerRecovered);
        assertTrue(error == ECDSA.RecoverError.NoError);

        //  case 2: return InvalidSignatureS error with an s value > secp256k1n/2
        bytes32 vsInvalid = bytes32(type(uint).max);
        (signerRecovered, error) = me.tryRecover(ethSignedMessageHash, r, vsInvalid);
        assertEq(address(0), signerRecovered);
        assertTrue(error == ECDSA.RecoverError.InvalidSignatureS);

        // case 3: return InvalidSignature error with zero r/vs
        (signerRecovered, error) = me.tryRecover(ethSignedMessageHash, 0, 0);
        assertEq(address(0), signerRecovered);
        assertTrue(error == ECDSA.RecoverError.InvalidSignature);

        // case 4: return an arbitrary signer and no RecoverError for another hash digest
        (signerRecovered, error) = me.tryRecover(me.toEthSignedMessageHash(bytes("Michael.W/Michael.W")), r, vs);
        assertNotEq(signerAddress, signerRecovered);
        assertTrue(error == ECDSA.RecoverError.NoError);
    }

    function test_Recover_WithRAndVS() external {
        // case 1: pass recover() with no RecoverError
        bytes32 ethSignedMessageHash = me.toEthSignedMessageHash(bytes("Michael.W"));
        bytes32 r = jsonTestData.readBytes32(".compact_signature_r");
        bytes32 vs = jsonTestData.readBytes32(".compact_signature_vs");
        address signerRecovered = me.recover(ethSignedMessageHash, r, vs);
        assertEq(signerAddress, signerRecovered);

        //  case 2: revert with an s value > secp256k1n/2
        bytes32 vsInvalid = bytes32(type(uint).max);
        vm.expectRevert("ECDSA: invalid signature 's' value");
        me.recover(ethSignedMessageHash, r, vsInvalid);

        // case 3: revert with zero r/vs
        vm.expectRevert("ECDSA: invalid signature");
        me.recover(ethSignedMessageHash, 0, 0);

        // case 4: return an arbitrary signer for another hash digest
        signerRecovered = me.recover(me.toEthSignedMessageHash(bytes("Michael.W/Michael.W")), r, vs);
        assertNotEq(signerAddress, signerRecovered);
    }
}

contract TargetEIP712 is EIP712("test name", "1") {
    function getDomainSeparator() external view returns (bytes32){
        return _domainSeparatorV4();
    }
}