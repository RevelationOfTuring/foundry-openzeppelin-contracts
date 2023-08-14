// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/introspection/ERC1820Implementer.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract MockERC1820Implementer is ERC1820Implementer, ERC721("", "") {
    function registerInterfaceForAddress(bytes32 interfaceHash, address account) external {
        _registerInterfaceForAddress(interfaceHash, account);
    }
}
