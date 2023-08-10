// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/introspection/ERC165Checker.sol";

contract MockERC165Checker {
    using ERC165Checker for address;

    function supportsERC165(address account) external view returns (bool){
        return account.supportsERC165();
    }

    function supportsInterface(address account, bytes4 interfaceId) external view returns (bool){
        return account.supportsInterface(interfaceId);
    }

    function getSupportedInterfaces(address account, bytes4[] memory interfaceIds)
    external
    view
    returns (bool[] memory){
        return account.getSupportedInterfaces(interfaceIds);
    }

    function supportsAllInterfaces(address account, bytes4[] memory interfaceIds) external view returns (bool){
        return account.supportsAllInterfaces(interfaceIds);
    }

    function supportsERC165InterfaceUnchecked(address account, bytes4 interfaceId) external view returns (bool){
        return account.supportsERC165InterfaceUnchecked(interfaceId);
    }
}