// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/utils/cryptography/MockEIP712.sol";

contract EIP712Test is Test {
    using stdJson for string;

    // fix the contract address with salt 'Michael.W'
    MockEIP712 me = new MockEIP712{salt : 'Michael.W'}("mock name", "1");
    string jsonTestData = vm.readFile("test/utils/cryptography/data/EIP712_test.json");

    function setUp() external {
        // fix chain id to 1024
        vm.chainId(1024);
    }

    function test_DomainSeparator() external {
        // case 1: right domain separator
        bytes32 expectedDomainSeparator = jsonTestData.readBytes32(".domain_separator");
        assertEq(expectedDomainSeparator, me.getDomainSeparator());

        // case 2: domain separator changed with the chain id
        vm.chainId(2048);
        expectedDomainSeparator = jsonTestData.readBytes32(".domain_separator_with_chain_id_changed");
        assertEq(expectedDomainSeparator, me.getDomainSeparator());
    }

    // typed data
    struct NameCard {
        string name;
        uint salary;
        address personAddress;
    }

    function test_Verify() external {
        // case 1: pass verify
        bytes memory signature = jsonTestData.readBytes(".signature");
        address signerAddress = jsonTestData.readAddress(".signer_address");
        bytes memory encodedBytes = jsonTestData.parseRaw(".value");
        NameCard memory nameCard = abi.decode(encodedBytes, (NameCard));

        me.verify(
            nameCard.name,
            nameCard.salary,
            nameCard.personAddress,
            signerAddress,
            signature
        );

        // case 2: fail to pass verify with value changed
        vm.expectRevert("invalid signature");
        me.verify(
            nameCard.name,
            nameCard.salary + 1,
            nameCard.personAddress,
            signerAddress,
            signature
        );
    }
}