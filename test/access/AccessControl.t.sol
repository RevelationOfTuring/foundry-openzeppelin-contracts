// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../src/access/MockAccessControl.sol";

contract AccessControlTest is Test {
    MockAccessControl private _testing = new MockAccessControl();

    bytes32 immutable private ROLE_DEFAULT = 0;
    bytes32 immutable private ROLE_1 = keccak256("ROLE_1");

    function test_SupportsInterface() external {
        // support IERC165 and IAccessControl
        assertTrue(_testing.supportsInterface(type(IERC165).interfaceId));
        assertTrue(_testing.supportsInterface(type(IAccessControl).interfaceId));
    }

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    function test_HasRole_GetRoleAdmin_SetRoleAdmin() external {
        // deployer was granted default role
        assertTrue(_testing.hasRole(ROLE_DEFAULT, address(this)));
        // default admin of any role is bytes32(0)
        assertEq(_testing.getRoleAdmin(ROLE_DEFAULT), 0);
        assertEq(_testing.getRoleAdmin(ROLE_1), 0);

        // change admin role by _setRoleAdmin()
        bytes32 newAdminRole = keccak256("new admin role");
        vm.expectEmit(true, true, true, false, address(_testing));
        emit RoleAdminChanged(ROLE_1, 0, newAdminRole);
        _testing.setRoleAdmin(ROLE_1, newAdminRole);
        assertEq(_testing.getRoleAdmin(ROLE_1), newAdminRole);
    }

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    function test_GrantRole() external {
        address account = address(1024);
        assertFalse(_testing.hasRole(ROLE_DEFAULT, account));

        vm.expectEmit(true, true, true, false, address(_testing));
        emit RoleGranted(ROLE_DEFAULT, account, address(this));
        _testing.grantRole(ROLE_DEFAULT, account);
        assertTrue(_testing.hasRole(ROLE_DEFAULT, account));

        // grant role for ROLE_1
        assertFalse(_testing.hasRole(ROLE_1, account));
        vm.expectEmit(true, true, true, false, address(_testing));
        emit RoleGranted(ROLE_1, account, address(this));
        _testing.grantRole(ROLE_1, account);
        assertTrue(_testing.hasRole(ROLE_1, account));
    }

    function testFail_GrantRole_NoEventWhenGrantAgain() external {
        address account = address(1024);
        _testing.grantRole(ROLE_DEFAULT, account);

        // no emit event if grant again
        vm.expectEmit(true, true, true, false, address(_testing));
        emit RoleGranted(ROLE_DEFAULT, account, address(this));
        _testing.grantRole(ROLE_DEFAULT, account);
    }

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function test_RevokeRole() external {
        address account = address(1024);
        _testing.grantRole(ROLE_DEFAULT, account);
        assertTrue(_testing.hasRole(ROLE_DEFAULT, account));
        vm.expectEmit(true, true, true, false, address(_testing));
        emit RoleRevoked(ROLE_DEFAULT, account, address(this));
        _testing.revokeRole(ROLE_DEFAULT, account);
        assertFalse(_testing.hasRole(ROLE_DEFAULT, account));

        // revoke role for ROLE_1
        _testing.grantRole(ROLE_1, account);
        assertTrue(_testing.hasRole(ROLE_1, account));
        vm.expectEmit(true, true, true, false, address(_testing));
        emit RoleRevoked(ROLE_1, account, address(this));
        _testing.revokeRole(ROLE_1, account);
        assertFalse(_testing.hasRole(ROLE_1, account));
    }

    function testFail_RevokeRole_NoEventWhenRevokeAgain() external {
        address account = address(1024);
        _testing.grantRole(ROLE_DEFAULT, account);
        _testing.revokeRole(ROLE_DEFAULT, account);

        // no emit event if revoke again
        vm.expectEmit(true, true, true, false, address(_testing));
        emit RoleRevoked(ROLE_DEFAULT, account, address(this));
        _testing.revokeRole(ROLE_DEFAULT, account);
    }

    function test_RenounceRole() external {
        address account = address(1024);
        _testing.grantRole(ROLE_DEFAULT, account);
        assertTrue(_testing.hasRole(ROLE_DEFAULT, account));
        vm.prank(account);
        vm.expectEmit(true, true, true, false, address(_testing));
        emit RoleRevoked(ROLE_DEFAULT, account, account);
        _testing.renounceRole(ROLE_DEFAULT, account);
        assertFalse(_testing.hasRole(ROLE_DEFAULT, account));

        // renounce role for ROLE_1
        _testing.grantRole(ROLE_1, account);
        assertTrue(_testing.hasRole(ROLE_1, account));
        vm.prank(account);
        vm.expectEmit(true, true, true, false, address(_testing));
        emit RoleRevoked(ROLE_1, account, account);
        _testing.renounceRole(ROLE_1, account);
        assertFalse(_testing.hasRole(ROLE_1, account));

        // case 1: revert if account != _msgSender()
        vm.expectRevert("AccessControl: can only renounce roles for self");
        _testing.renounceRole(ROLE_DEFAULT, account);
    }

    function testFail_RenounceRole_NoEventWhenRenounceAgain() external {
        _testing.renounceRole(ROLE_DEFAULT, address(this));

        // no emit event if renounce again
        vm.expectEmit(true, true, true, false, address(_testing));
        emit RoleRevoked(ROLE_DEFAULT, address(this), address(this));
        _testing.renounceRole(ROLE_DEFAULT, address(this));
    }

    function test_onlyRole() external {
        // test for modifier onlyRole
        address account = address(1024);
        // test for default role
        // pass
        assertTrue(_testing.hasRole(ROLE_DEFAULT, address(this)));
        _testing.doSomethingWithAccessControl(ROLE_DEFAULT);
        // case 1: revert
        assertFalse(_testing.hasRole(ROLE_DEFAULT, account));
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000400 is missing role 0x0000000000000000000000000000000000000000000000000000000000000000");
        vm.prank(account);
        _testing.doSomethingWithAccessControl(ROLE_DEFAULT);

        // test for role_1
        // case 2: revert
        assertFalse(_testing.hasRole(ROLE_1, account));
        vm.expectRevert("AccessControl: account 0x0000000000000000000000000000000000000400 is missing role 0x00e1b9dbbc5c12d9bbd9ed29cbfd10bab1e01c5e67a7fc74a02f9d3edc5ad0a8");
        vm.prank(account);
        _testing.doSomethingWithAccessControl(ROLE_1);
        // grant role_1 to account
        _testing.grantRole(ROLE_1,account);
        vm.prank(account);
        _testing.doSomethingWithAccessControl(ROLE_1);
    }
}
