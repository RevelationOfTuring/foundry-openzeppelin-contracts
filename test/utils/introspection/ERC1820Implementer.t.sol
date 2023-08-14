// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/utils/introspection/MockERC1820Implementer.sol";
import "../../../src/utils/introspection/ERC1820Registry.sol";

contract ERC1820ImplementerTest is Test {
    MockERC1820Implementer mei = new MockERC1820Implementer();
    ERC1820Registry er = new ERC1820Registry();
    bytes32 constant ERC1820_ACCEPT_MAGIC = keccak256("ERC1820_ACCEPT_MAGIC");

    function test_ERC1820Implementer() external {
        address account = address(1024);
        bytes32 interfaceHashERC721 = er.interfaceHash("ERC721Token");
        // no registered interface
        assertEq(0, mei.canImplementInterfaceForAddress(interfaceHashERC721, account));

        // revert when set implementer in ERC1820Registry before register operation in ERC1820 implementer
        vm.prank(account);
        er.setManager(account, address(this));
        vm.expectRevert("Does not implement the interface");
        er.setInterfaceImplementer(account, interfaceHashERC721, address(mei));

        // register interface between ERC1820Registry and ERC1820Implementer
        // 1. register willing in ERC1820Implementer
        mei.registerInterfaceForAddress(interfaceHashERC721, account);
        assertEq(ERC1820_ACCEPT_MAGIC, mei.canImplementInterfaceForAddress(interfaceHashERC721, account));
        // query for interface hash not registered
        bytes32 interfaceHashOther = er.interfaceHash("ERC20Token");
        assertNotEq(ERC1820_ACCEPT_MAGIC, mei.canImplementInterfaceForAddress(interfaceHashOther, account));
        // query for account not registered
        assertNotEq(ERC1820_ACCEPT_MAGIC, mei.canImplementInterfaceForAddress(interfaceHashERC721, address(1024 + 1)));

        // 2. set implementer in ERC1820Registry
        er.setInterfaceImplementer(account, interfaceHashERC721, address(mei));

        // 3. check from ERC1820Registry
        assertEq(address(mei), er.getInterfaceImplementer(account, interfaceHashERC721));
    }
}