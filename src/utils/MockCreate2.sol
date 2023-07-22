// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/utils/Create2.sol";

contract MockCreate2 {
    function deploy(
        uint256 amount,
        bytes32 salt,
        bytes memory bytecode
    ) external returns (address) {
        return Create2.deploy(amount, salt, bytecode);
    }

    function computeAddress(bytes32 salt, bytes32 bytecodeHash) external view returns (address) {
        return Create2.computeAddress(salt, bytecodeHash);
    }

    function computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) external pure returns (address addr){
        return Create2.computeAddress(salt, bytecodeHash, deployer);
    }

    receive() external payable {}
}

contract ContractWithConstructor {
    string public _name;
    uint public _age;
    constructor(string memory name, uint age){
        _name = name;
        _age = age;
    }
}

contract ContractWithPayableConstructor {
    string public _name;
    uint public _age;
    constructor(string memory name, uint age) payable {
        _name = name;
        _age = age;
    }
}