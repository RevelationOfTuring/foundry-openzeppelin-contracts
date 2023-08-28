// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/utils/cryptography/MockSignatureChecker.sol";
import "../../../src/interfaces/MockERC1271.sol";

contract SignatureCheckerTest is Test {
    using ECDSA for bytes;

    MockSignatureChecker msc = new MockSignatureChecker();
    uint eoaSignerPrivateKeyInERC1271 = 1024;
    MockERC1271 me = new MockERC1271(vm.addr(eoaSignerPrivateKeyInERC1271));
    uint signerPrivateKey = 2048;
    address signerAddress = vm.addr(signerPrivateKey);

    function test_IsValidSignatureNow_AsEOAAddress() external {
        // case 1: return true with correct eoa signature
        bytes32 digestHash = bytes("Michael.W").toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signerPrivateKey, digestHash);
        bytes memory signature = bytes.concat(r, s, bytes1(v));

        assertTrue(msc.isValidSignatureNow(
                signerAddress,
                digestHash,
                signature
            ));

        // case 2: return false with incorrect eoa signature
        bytes memory incorrectSignature = bytes.concat(r, s, bytes1(v + 1));
        assertFalse(msc.isValidSignatureNow(
                signerAddress,
                digestHash,
                incorrectSignature
            ));
    }

    function test_IsValidSignatureNow_AsIERC1271Address() external {
        // case 1: return true with valid signature of ERC1271
        bytes32 digestHash = bytes("Michael.W").toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(eoaSignerPrivateKeyInERC1271, digestHash);
        bytes memory signature = bytes.concat(r, s, bytes1(v));

        assertTrue(msc.isValidSignatureNow(
                address(me),
                digestHash,
                signature
            ));

        // case 2: return true with invalid signature of ERC1271
        bytes memory incorrectSignature = bytes.concat(r, s, bytes1(v + 1));

        assertFalse(msc.isValidSignatureNow(
                address(me),
                digestHash,
                incorrectSignature
            ));

        // case 3: return false when the signer contract address is not the implementor of IERC1271
        (v, r, s) = vm.sign(eoaSignerPrivateKeyInERC1271, digestHash);
        signature = bytes.concat(r, s, bytes1(v));

        assertFalse(msc.isValidSignatureNow(
                address(new NotImplementIERC1271()),
                digestHash,
                signature
            ));
    }
}

contract NotImplementIERC1271 {}
