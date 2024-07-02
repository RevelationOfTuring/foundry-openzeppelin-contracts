// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/interfaces/draft-IERC1822.sol";

interface IImplement {
    event InitialCallWithoutArgs();
    event InitialCallWithArgs(uint, address, string);
    event Receive();
    event Fallback(bytes);
}

contract Implement is IImplement {
    function initialCallWithoutArgs() external {
        emit InitialCallWithoutArgs();
    }

    function initialCallWithArgs(uint arg1, address arg2, string memory arg3) external {
        emit InitialCallWithArgs(arg1, arg2, arg3);
    }

    receive() external payable {
        emit Receive();
    }

    fallback() external {
        emit Fallback(msg.data);
    }
}

contract ImplementERC1822Proxiable is Implement, IERC1822Proxiable {
    bytes32 public proxiableUUID;

    constructor(bytes32 newProxiableUUID){
        proxiableUUID = newProxiableUUID;
    }
}