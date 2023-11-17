// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/access/MockAccessControlEnumerable.sol";

contract AccessControlEnumerableTest is Test {
    MockAccessControlEnumerable private _testing = new MockAccessControlEnumerable();

    bytes32 immutable private ROLE_DEFAULT = 0;
    bytes32 immutable private ROLE_1 = keccak256("ROLE_1");

    function test_SupportsInterface() external {
        // support IERC165 && IAccessControl && IAccessControlEnumerable
        assertTrue(_testing.supportsInterface(type(IERC165).interfaceId));
        assertTrue(_testing.supportsInterface(type(IAccessControl).interfaceId));
        assertTrue(_testing.supportsInterface(type(IAccessControlEnumerable).interfaceId));
    }

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    function test_GrantRole() external {
        // case 1: grant role for ROLE_DEFAULT
        address account = address(1024);
        assertFalse(_testing.hasRole(ROLE_DEFAULT, account));
        // deployer (address of AccessControlEnumerableTest) is already in
        assertEq(_testing.getRoleMemberCount(ROLE_DEFAULT), 1);

        vm.expectEmit(true, true, true, false, address(_testing));
        emit RoleGranted(ROLE_DEFAULT, account, address(this));
        _testing.grantRole(ROLE_DEFAULT, account);
        assertEq(_testing.getRoleMemberCount(ROLE_DEFAULT), 2);
        assertTrue(_testing.hasRole(ROLE_DEFAULT, account));

        // grant more accounts for ROLE_DEFAULT
        _testing.grantRole(ROLE_DEFAULT, address(2048));
        _testing.grantRole(ROLE_DEFAULT, address(4096));
        assertEq(_testing.getRoleMemberCount(ROLE_DEFAULT), 4);

        // revert if msg.sender is not the admin of the role
        vm.prank(address(0));
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000000 is missing role 0x0000000000000000000000000000000000000000000000000000000000000000");
        _testing.grantRole(ROLE_DEFAULT, account);

        // case 2: grant role for ROLE_1
        assertEq(_testing.getRoleMemberCount(ROLE_1), 0);
        assertFalse(_testing.hasRole(ROLE_1, account));
        vm.expectEmit(true, true, true, false, address(_testing));
        emit RoleGranted(ROLE_1, account, address(this));
        _testing.grantRole(ROLE_1, account);
        assertTrue(_testing.hasRole(ROLE_1, account));
        assertEq(_testing.getRoleMemberCount(ROLE_1), 1);

        // grant more accounts for ROLE_1
        _testing.grantRole(ROLE_1, address(2048));
        _testing.grantRole(ROLE_1, address(4096));
        assertEq(_testing.getRoleMemberCount(ROLE_1), 3);

        // revert if msg.sender is not the admin of the role
        vm.prank(address(0));
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000000 is missing role 0x0000000000000000000000000000000000000000000000000000000000000000");
        _testing.grantRole(ROLE_1, account);
    }

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function test_RevokeRole() external {
        // case 1: revoke role for ROLE_DEFAULT
        address account = address(1024);
        _testing.grantRole(ROLE_DEFAULT, account);
        _testing.grantRole(ROLE_DEFAULT, address(2048));
        _testing.grantRole(ROLE_DEFAULT, address(4096));
        assertEq(_testing.getRoleMemberCount(ROLE_DEFAULT), 4);

        vm.expectEmit(true, true, true, false, address(_testing));
        emit RoleRevoked(ROLE_DEFAULT, account, address(this));
        _testing.revokeRole(ROLE_DEFAULT, account);
        assertFalse(_testing.hasRole(ROLE_DEFAULT, account));
        assertEq(_testing.getRoleMemberCount(ROLE_DEFAULT), 3);

        _testing.revokeRole(ROLE_DEFAULT, address(2048));
        _testing.revokeRole(ROLE_DEFAULT, address(4096));
        assertEq(_testing.getRoleMemberCount(ROLE_DEFAULT), 1);

        // revert if msg.sender is not the admin of the role
        vm.prank(address(1));
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000001 is missing role 0x0000000000000000000000000000000000000000000000000000000000000000");
        _testing.revokeRole(ROLE_DEFAULT, address(this));

        // case 2: revoke role for ROLE_1
        _testing.grantRole(ROLE_1, account);
        _testing.grantRole(ROLE_1, address(2048));
        _testing.grantRole(ROLE_1, address(4096));
        assertEq(_testing.getRoleMemberCount(ROLE_1), 3);

        vm.expectEmit(true, true, true, false, address(_testing));
        emit RoleRevoked(ROLE_1, account, address(this));
        _testing.revokeRole(ROLE_1, account);
        assertFalse(_testing.hasRole(ROLE_1, account));
        assertEq(_testing.getRoleMemberCount(ROLE_1), 2);

        _testing.revokeRole(ROLE_1, address(2048));
        _testing.revokeRole(ROLE_1, address(4096));
        assertEq(_testing.getRoleMemberCount(ROLE_1), 0);

        // revert if msg.sender is not the admin of the role
        vm.prank(address(1));
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000001 is missing role 0x0000000000000000000000000000000000000000000000000000000000000000");
        _testing.revokeRole(ROLE_1, address(this));
    }

    function test_GetRoleMemberAndGetRoleMemberCount() external {
        // case 1: for ROLE_DEFAULT
        _testing.grantRole(ROLE_DEFAULT, address(1024));
        _testing.grantRole(ROLE_DEFAULT, address(2048));
        _testing.grantRole(ROLE_DEFAULT, address(4096));

        assertEq(_testing.getRoleMemberCount(ROLE_DEFAULT), 4);
        assertEq(_testing.getRoleMember(ROLE_DEFAULT, 0), address(this));
        assertEq(_testing.getRoleMember(ROLE_DEFAULT, 1), address(1024));
        assertEq(_testing.getRoleMember(ROLE_DEFAULT, 2), address(2048));
        assertEq(_testing.getRoleMember(ROLE_DEFAULT, 3), address(4096));

        // revoke
        _testing.revokeRole(ROLE_DEFAULT, address(1024));

        // index of account are not sorted when #revoke()
        assertEq(_testing.getRoleMemberCount(ROLE_DEFAULT), 3);
        assertEq(_testing.getRoleMember(ROLE_DEFAULT, 0), address(this));
        assertEq(_testing.getRoleMember(ROLE_DEFAULT, 1), address(4096));
        assertEq(_testing.getRoleMember(ROLE_DEFAULT, 2), address(2048));

        // case 2: for ROLE_1
        _testing.grantRole(ROLE_1, address(1024));
        _testing.grantRole(ROLE_1, address(2048));
        _testing.grantRole(ROLE_1, address(4096));

        assertEq(_testing.getRoleMemberCount(ROLE_1), 3);
        assertEq(_testing.getRoleMember(ROLE_1, 0), address(1024));
        assertEq(_testing.getRoleMember(ROLE_1, 1), address(2048));
        assertEq(_testing.getRoleMember(ROLE_1, 2), address(4096));

        // revoke
        _testing.revokeRole(ROLE_1, address(1024));

        // index of account are not sorted when #revoke()
        assertEq(_testing.getRoleMemberCount(ROLE_1), 2);
        assertEq(_testing.getRoleMember(ROLE_1, 0), address(4096));
        assertEq(_testing.getRoleMember(ROLE_1, 1), address(2048));
    }

    function test_onlyRole() external {
        // test for modifier onlyRole
        address account = address(1024);
        // test for ROLE_DEFAULT
        // pass
        assertTrue(_testing.hasRole(ROLE_DEFAULT, address(this)));
        _testing.doSomethingWithAccessControl(ROLE_DEFAULT);
        // case 1: revert
        assertFalse(_testing.hasRole(ROLE_DEFAULT, account));
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000400 is missing role 0x0000000000000000000000000000000000000000000000000000000000000000");
        vm.prank(account);
        _testing.doSomethingWithAccessControl(ROLE_DEFAULT);

        // test for ROLE_1
        // case 2: revert
        assertFalse(_testing.hasRole(ROLE_1, account));
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000400 is missing role 0x00e1b9dbbc5c12d9bbd9ed29cbfd10bab1e01c5e67a7fc74a02f9d3edc5ad0a8");
        vm.prank(account);
        _testing.doSomethingWithAccessControl(ROLE_1);
        // grant ROLE_1 to account
        _testing.grantRole(ROLE_1, account);
        vm.prank(account);
        _testing.doSomethingWithAccessControl(ROLE_1);
    }
}
