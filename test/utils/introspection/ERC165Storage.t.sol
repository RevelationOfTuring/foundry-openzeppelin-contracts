// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/utils/introspection/MockERC165Storage.sol";

contract ERC165StorageTest is Test {
    MockERC165Storage me = new MockERC165Storage();

    function test_ERC165Storage() external {
        // only support IERC165 in initial status
        assertTrue(me.supportsInterface(type(IERC165).interfaceId));
        assertFalse(me.supportsInterface(type(IERC20).interfaceId));
        assertFalse(me.supportsInterface(type(IERC20Metadata).interfaceId));
        assertFalse(me.supportsInterface(type(ICustomized).interfaceId));

        // register interfaces
        me.registerInterface(type(IERC20).interfaceId);
        me.registerInterface(type(IERC20Metadata).interfaceId);
        me.registerInterface(type(ICustomized).interfaceId);
        // revert if try to register invalid interface id (0xffffffff) in IERC165
        vm.expectRevert("ERC165: invalid interface id");
        me.registerInterface(0xffffffff);

        // check
        assertTrue(me.supportsInterface(type(IERC20).interfaceId));
        assertTrue(me.supportsInterface(type(IERC20Metadata).interfaceId));
        assertTrue(me.supportsInterface(type(ICustomized).interfaceId));
    }
}