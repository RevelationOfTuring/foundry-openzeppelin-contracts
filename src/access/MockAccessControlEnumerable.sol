// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/AccessControlEnumerable.sol";

contract MockAccessControlEnumerable is AccessControlEnumerable {
    constructor(){
        // set msg.sender into admin role
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function doSomethingWithAccessControl(bytes32 role) onlyRole(role) external {}
}
