// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/introspection/ERC165Storage.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

interface ICustomized {
    function helloMichael(string memory str) external;
}

contract MockERC165Storage is ERC165Storage, ERC20("", ""), ICustomized {
    string _str;

    // implementation of interface ICustomized
    function helloMichael(string memory str) external {
        _str = str;
    }

    function registerInterface(bytes4 interfaceId) external {
        _registerInterface(interfaceId);
    }
}