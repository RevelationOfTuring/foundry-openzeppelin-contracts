// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/AccessControl.sol";

contract MockAccessControl is AccessControl {
    constructor(){
        // set msg.sender into admin role
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function setRoleAdmin(bytes32 role, bytes32 adminRole) external {
        _setRoleAdmin(role, adminRole);
    }

    function doSomethingWithAccessControl(bytes32 role) onlyRole(role) external {}
}
