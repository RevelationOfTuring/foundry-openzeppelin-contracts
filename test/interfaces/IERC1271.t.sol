// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/interfaces/MockERC1271.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

contract IERC1271Test is Test {
    using ECDSA for bytes;

    uint signerPrivateKey = 1024;
    MockERC1271 me = new MockERC1271(vm.addr(signerPrivateKey));

    function test_IsValidSignature_PassWithCorrectSignature() external {
        (bytes32 digestHash, bytes memory signature) = getDigestHashAndSignature(signerPrivateKey, "Michael.W");
        bytes4 magicValue = me.isValidSignature(digestHash, signature);
        assertTrue(magicValue == IERC1271.isValidSignature.selector);
    }

    function test_IsValidSignature_NotPassWithIncorrectSignature() external {
        (bytes32 digestHash, bytes memory signature) = getDigestHashAndSignature(signerPrivateKey + 1, "Michael.W");
        bytes4 magicValue = me.isValidSignature(digestHash, signature);
        assertFalse(magicValue == IERC1271.isValidSignature.selector);
    }

    // utils to get digest hash and signature with specific private key and string message
    function getDigestHashAndSignature(uint privateKey, string memory message) private pure returns (bytes32 digestHash, bytes memory signature){
        digestHash = bytes(message).toEthSignedMessageHash();
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digestHash);
        signature = bytes.concat(r, s, bytes1(v));
    }
}

