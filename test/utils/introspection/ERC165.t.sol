// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/utils/introspection/MockERC165.sol";

contract ERC165Test is Test {
    MockERC165 me = new MockERC165();

    function test_SupportsInterface_IERC165() external {
        // way 1: from function selector
        bytes4 interfaceIdIERC165 = IERC165.supportsInterface.selector;
        assertTrue(me.supportsInterface(interfaceIdIERC165));
        // way 2: from hash result of function signature
        interfaceIdIERC165 = bytes4(keccak256('supportsInterface(bytes4)'));
        assertTrue(me.supportsInterface(interfaceIdIERC165));
        // way 3: from type(interface).interfaceId
        interfaceIdIERC165 = type(IERC165).interfaceId;
        assertTrue(me.supportsInterface(interfaceIdIERC165));

        // not support
        bytes4 interfaceIdNotSupport = 0xffffffff;
        assertFalse(me.supportsInterface(interfaceIdNotSupport));
    }

    function test_SupportsInterface_ICustomizedInterface() external {
        // way 1: from XOR of all function selectors in the interface
        bytes4 interfaceIdICustomizedInterface = ICustomizedInterface.viewFunction.selector
        ^ ICustomizedInterface.pureFunction.selector
        ^ ICustomizedInterface.externalFunction.selector;
        assertTrue(me.supportsInterface(interfaceIdICustomizedInterface));
        // way 2: from XOR of all hash result of function signature
        interfaceIdICustomizedInterface = bytes4(keccak256('viewFunction(address)'))
        ^ bytes4(keccak256('pureFunction(uint256)'))
        ^ bytes4(keccak256('externalFunction(uint256[],address[])'));
        assertTrue(me.supportsInterface(interfaceIdICustomizedInterface));
        // way 3: from type(interface).interfaceId
        interfaceIdICustomizedInterface = type(ICustomizedInterface).interfaceId;
        assertTrue(me.supportsInterface(interfaceIdICustomizedInterface));

        // not support
        bytes4 interfaceIdNotSupport = ICustomizedInterface.pureFunction.selector
        ^ ICustomizedInterface.externalFunction.selector;
        assertFalse(me.supportsInterface(interfaceIdNotSupport));
    }

    function test_SupportsInterface_Gas() external {
        // for type(IERC165).interfaceId
        uint startGas = gasleft();
        me.supportsInterface(type(IERC165).interfaceId);
        uint endGas = gasleft();
        assertLt(startGas - endGas, 30000);

        // type(ICustomizedInterface).interfaceId
        startGas = gasleft();
        me.supportsInterface(type(ICustomizedInterface).interfaceId);
        endGas = gasleft();
        assertLt(startGas - endGas, 30000);
    }
}