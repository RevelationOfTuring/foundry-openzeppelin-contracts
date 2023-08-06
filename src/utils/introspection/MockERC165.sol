// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/introspection/ERC165.sol";

interface ICustomizedInterface {
    error CustomizedError();

    event CustomizedEvent(uint n);

    function viewFunction(address addr) external view returns (address);

    function pureFunction(uint n) external pure returns (uint);

    function externalFunction(uint[] calldata nums, address[] calldata addrs) external;
}

contract MockERC165 is ERC165, ICustomizedInterface {
    uint _totalSum;
    uint _totalNumberOfAddress;

    // implementation of ICustomizedInterface
    function viewFunction(address addr) external view returns (address){
        if (addr == msg.sender) {
            return addr;
        }

        return address(1024);
    }

    function pureFunction(uint n) external pure returns (uint){
        return n + 1;
    }

    function externalFunction(uint[] calldata nums, address[] calldata addrs) external {
        for (uint i; i < nums.length; ++i) {
            _totalSum += nums[i];
        }

        _totalNumberOfAddress = addrs.length;
    }

    // override supportsInterface(bytes4) of IERC165
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(ICustomizedInterface).interfaceId || super.supportsInterface(interfaceId);
    }
}
