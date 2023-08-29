// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import "openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

contract MockEIP712 is EIP712 {
    using ECDSA for bytes32;

    constructor(string memory name, string memory version) EIP712(name, version) {}

    function verify(
        string memory name,
        uint salary,
        address personalAddress,
        address signer,
        bytes memory signature
    ) external view {
        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("NameCard(string name,uint256 salary,address personalAddress)"),
                keccak256(bytes(name)),
                salary,
                personalAddress
            )
        );

        bytes32 digest = _hashTypedDataV4(structHash);
        require(signer == digest.recover(signature), "invalid signature");
    }

    function getDomainSeparator() external view returns (bytes32) {
        return _domainSeparatorV4();
    }
}
