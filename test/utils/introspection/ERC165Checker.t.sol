// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../src/utils/introspection/MockERC165Checker.sol";
import "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract ERC165CheckerTest is Test {
    MockERC165Checker testing = new MockERC165Checker();

    SupportNone supportNone = new SupportNone();
    SupportERC165 supportERC165 = new SupportERC165();
    SupportERC165ButNotInvalidInterfaceId supportERC165ButNotInvalidInterfaceId = new SupportERC165ButNotInvalidInterfaceId();
    SupportManyInterfacesButNotERC165 supportManyInterfacesButNotERC165 = new SupportManyInterfacesButNotERC165();
    SupportManyInterfacesWithERC165 supportManyInterfacesWithERC165 = new SupportManyInterfacesWithERC165();
    bytes4 constant INTERFACE_ID_INVALID = 0xffffffff;

    function test_SupportsERC165InterfaceUnchecked() external {
        // case 1: query to contract SupportNone without revert and return false
        assertFalse(testing.supportsERC165InterfaceUnchecked(address(supportNone), type(IERC165).interfaceId));
        assertFalse(testing.supportsERC165InterfaceUnchecked(address(supportNone), INTERFACE_ID_INVALID));

        // case 2: query to contract SupportERC165
        assertTrue(testing.supportsERC165InterfaceUnchecked(address(supportERC165), type(IERC165).interfaceId));
        assertFalse(testing.supportsERC165InterfaceUnchecked(address(supportERC165), INTERFACE_ID_INVALID));

        // case 3: query to contract SupportERC165ButNotInvalidInterfaceId
        assertTrue(testing.supportsERC165InterfaceUnchecked(address(supportERC165ButNotInvalidInterfaceId), type(IERC165).interfaceId));
        assertTrue(testing.supportsERC165InterfaceUnchecked(address(supportERC165ButNotInvalidInterfaceId), INTERFACE_ID_INVALID));

        // case 4: query to contract SupportManyInterfacesButNotERC165
        assertFalse(testing.supportsERC165InterfaceUnchecked(address(supportManyInterfacesButNotERC165), type(IERC165).interfaceId));
        assertFalse(testing.supportsERC165InterfaceUnchecked(address(supportManyInterfacesButNotERC165), INTERFACE_ID_INVALID));
        assertTrue(testing.supportsERC165InterfaceUnchecked(address(supportManyInterfacesButNotERC165), type(IERC20).interfaceId));
        assertTrue(testing.supportsERC165InterfaceUnchecked(address(supportManyInterfacesButNotERC165), type(IERC20Metadata).interfaceId));
        assertTrue(testing.supportsERC165InterfaceUnchecked(address(supportManyInterfacesButNotERC165), type(ICustomized).interfaceId));

        // case 5: query to contract SupportManyInterfacesWithERC165
        assertTrue(testing.supportsERC165InterfaceUnchecked(address(supportManyInterfacesWithERC165), type(IERC165).interfaceId));
        assertFalse(testing.supportsERC165InterfaceUnchecked(address(supportManyInterfacesWithERC165), INTERFACE_ID_INVALID));
        assertTrue(testing.supportsERC165InterfaceUnchecked(address(supportManyInterfacesWithERC165), type(IERC20).interfaceId));
        assertTrue(testing.supportsERC165InterfaceUnchecked(address(supportManyInterfacesWithERC165), type(IERC20Metadata).interfaceId));
        assertTrue(testing.supportsERC165InterfaceUnchecked(address(supportManyInterfacesWithERC165), type(ICustomized).interfaceId));
    }

    function test_SupportsERC165() external {
        // case 1: query to contract SupportNone without revert and return false
        assertFalse(testing.supportsERC165(address(supportNone)));

        // case 2: query to contract SupportERC165
        assertTrue(testing.supportsERC165(address(supportERC165)));

        // case 3: query to contract SupportERC165ButNotInvalidInterfaceId
        assertFalse(testing.supportsERC165(address(supportERC165ButNotInvalidInterfaceId)));

        // case 4: query to contract SupportManyInterfacesButNotERC165
        assertFalse(testing.supportsERC165(address(supportManyInterfacesButNotERC165)));

        // case 5: query to contract SupportManyInterfacesWithERC165
        assertTrue(testing.supportsERC165(address(supportManyInterfacesWithERC165)));
    }

    function test_SupportsInterface() external {
        // case 1: query to contract SupportNone
        assertFalse(testing.supportsInterface(address(supportNone), INTERFACE_ID_INVALID));
        assertFalse(testing.supportsInterface(address(supportNone), type(IERC165).interfaceId));

        // case 2: query to contract SupportERC165
        assertFalse(testing.supportsInterface(address(supportERC165), INTERFACE_ID_INVALID));
        assertTrue(testing.supportsInterface(address(supportERC165), type(IERC165).interfaceId));

        // case 3: query to contract SupportERC165ButNotInvalidInterfaceId
        assertFalse(testing.supportsInterface(address(supportERC165ButNotInvalidInterfaceId), INTERFACE_ID_INVALID));
        assertFalse(testing.supportsInterface(address(supportERC165ButNotInvalidInterfaceId), type(IERC165).interfaceId));

        // case 4: query to contract SupportManyInterfacesButNotERC165
        assertFalse(testing.supportsInterface(address(supportManyInterfacesButNotERC165), INTERFACE_ID_INVALID));
        assertFalse(testing.supportsInterface(address(supportManyInterfacesButNotERC165), type(IERC165).interfaceId));
        assertFalse(testing.supportsInterface(address(supportManyInterfacesButNotERC165), type(IERC20).interfaceId));
        assertFalse(testing.supportsInterface(address(supportManyInterfacesButNotERC165), type(IERC20Metadata).interfaceId));
        assertFalse(testing.supportsInterface(address(supportManyInterfacesButNotERC165), type(ICustomized).interfaceId));

        // case 5: query to contract SupportManyInterfacesWithERC165
        assertFalse(testing.supportsInterface(address(supportManyInterfacesWithERC165), INTERFACE_ID_INVALID));
        assertTrue(testing.supportsInterface(address(supportManyInterfacesWithERC165), type(IERC165).interfaceId));
        assertTrue(testing.supportsInterface(address(supportManyInterfacesWithERC165), type(IERC20).interfaceId));
        assertTrue(testing.supportsInterface(address(supportManyInterfacesWithERC165), type(IERC20Metadata).interfaceId));
        assertTrue(testing.supportsInterface(address(supportManyInterfacesWithERC165), type(ICustomized).interfaceId));
    }

    function test_GetSupportedInterfaces() external {
        bytes4[] memory interfaceIds = new bytes4[](4);
        interfaceIds[0] = type(IERC165).interfaceId;
        interfaceIds[1] = type(IERC20).interfaceId;
        interfaceIds[2] = type(IERC20Metadata).interfaceId;
        interfaceIds[3] = type(ICustomized).interfaceId;

        // case 1: query to contract SupportNone
        bool[] memory supported = testing.getSupportedInterfaces(address(supportNone), interfaceIds);
        assertEq(supported.length, 4);
        // all false because of not supporting ERC165 completely
        assertFalse(supported[0]);
        assertFalse(supported[1]);
        assertFalse(supported[2]);
        assertFalse(supported[3]);

        // case 2: query to contract SupportERC165
        supported = testing.getSupportedInterfaces(address(supportERC165), interfaceIds);
        assertEq(supported.length, 4);
        assertTrue(supported[0]);
        assertFalse(supported[1]);
        assertFalse(supported[2]);
        assertFalse(supported[3]);

        // case 3: query to contract SupportERC165ButNotInvalidInterfaceId
        supported = testing.getSupportedInterfaces(address(supportERC165ButNotInvalidInterfaceId), interfaceIds);
        assertEq(supported.length, 4);
        // all false because of not supporting ERC165 completely
        assertFalse(supported[0]);
        assertFalse(supported[1]);
        assertFalse(supported[2]);
        assertFalse(supported[3]);

        // case 4: query to contract SupportManyInterfacesButNotERC165
        supported = testing.getSupportedInterfaces(address(supportManyInterfacesButNotERC165), interfaceIds);
        assertEq(supported.length, 4);
        // all false because of not supporting ERC165 completely
        assertFalse(supported[0]);
        assertFalse(supported[1]);
        assertFalse(supported[2]);
        assertFalse(supported[3]);

        // case 5: query to contract SupportManyInterfacesWithERC165
        supported = testing.getSupportedInterfaces(address(supportManyInterfacesWithERC165), interfaceIds);
        assertEq(supported.length, 4);
        // all true
        assertTrue(supported[0]);
        assertTrue(supported[1]);
        assertTrue(supported[2]);
        assertTrue(supported[3]);
    }

    function test_SupportsAllInterfaces() external {
        bytes4[] memory interfaceIds = new bytes4[](4);
        interfaceIds[0] = type(IERC165).interfaceId;
        interfaceIds[1] = type(IERC20).interfaceId;
        interfaceIds[2] = type(IERC20Metadata).interfaceId;
        interfaceIds[3] = type(ICustomized).interfaceId;

        // case 1: query to contract SupportNone
        assertFalse(testing.supportsAllInterfaces(address(supportNone), interfaceIds));

        // case 2: query to contract SupportERC165
        assertFalse(testing.supportsAllInterfaces(address(supportERC165), interfaceIds));

        // case 3: query to contract SupportERC165ButNotInvalidInterfaceId
        assertFalse(testing.supportsAllInterfaces(address(supportERC165ButNotInvalidInterfaceId), interfaceIds));

        // case 4: query to contract SupportManyInterfacesButNotERC165
        assertFalse(testing.supportsAllInterfaces(address(supportManyInterfacesButNotERC165), interfaceIds));

        // case 5: query to contract SupportManyInterfacesWithERC165
        assertTrue(testing.supportsAllInterfaces(address(supportManyInterfacesWithERC165), interfaceIds));
    }
}

// no method `supportsInterface(bytes4 interfaceId)`
contract SupportNone {}

contract SupportERC165 is ERC165 {}

contract SupportERC165ButNotInvalidInterfaceId is ERC165 {
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == 0xffffffff || super.supportsInterface(interfaceId);
    }
}

interface ICustomized {
    function helloMichael() external view returns (string memory);
}

contract SupportManyInterfacesButNotERC165 is ERC20, ICustomized {
    string _str = "michael.w";

    constructor()ERC20("", ""){}

    function helloMichael() external view returns (string memory){
        return _str;
    }

    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return interfaceId == type(IERC20).interfaceId ||
        interfaceId == type(IERC20Metadata).interfaceId ||
        interfaceId == type(ICustomized).interfaceId;
    }
}

contract SupportManyInterfacesWithERC165 is ERC165, ERC20, ICustomized {
    string _str = "michael.w";

    constructor()ERC20("", ""){}

    function helloMichael() external view returns (string memory){
        return _str;
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IERC20).interfaceId ||
        interfaceId == type(IERC20Metadata).interfaceId ||
        interfaceId == type(ICustomized).interfaceId ||
        super.supportsInterface(interfaceId);
    }
}