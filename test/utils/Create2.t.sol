// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import {MockCreate2, ContractWithConstructor, ContractWithPayableConstructor} from "../../src/utils/MockCreate2.sol";

contract Create2Test is Test {
    MockCreate2 mc = new MockCreate2();

    function test_Deploy() external {
        string memory name = "Michael.W";
        uint age = 18;
        // 1. deploy the contract with a non-payable constructor
        bytes32 salt = keccak256("deploy the contract with a non-payable constructor");
        // constructor params
        bytes memory encodedConstructorParams = abi.encode(name, age);
        // bytecode = creation code + constructor params
        bytes memory bytecode = abi.encodePacked(type(ContractWithConstructor).creationCode, encodedConstructorParams);
        // deploy
        address newContractAddress = mc.deploy(0, salt, bytecode);
        // check constructor params
        assertEq(name, ContractWithConstructor(newContractAddress)._name());
        assertEq(age, ContractWithConstructor(newContractAddress)._age());

        // 2. deploy the contract with a payable constructor
        vm.deal(address(mc), 3 gwei);
        salt = keccak256("deploy the contract with a payable constructor");
        bytecode = abi.encodePacked(type(ContractWithPayableConstructor).creationCode, encodedConstructorParams);
        newContractAddress = mc.deploy(1 gwei, salt, bytecode);
        assertEq(name, ContractWithConstructor(newContractAddress)._name());
        assertEq(age, ContractWithConstructor(newContractAddress)._age());
        // check eth balances
        assertEq(3 gwei - 1 gwei, address(mc).balance);
        assertEq(1 gwei, address(newContractAddress).balance);

        // revert
        // 1. revert when creates contract on the same address
        vm.expectRevert("Create2: Failed on deploy");
        mc.deploy(1 gwei, salt, bytecode);
        // 2. revert with empty bytecode
        vm.expectRevert("Create2: bytecode length is zero");
        mc.deploy(0, salt, "");
        // 3. revert with insufficient balance
        vm.deal(address(mc), 1 gwei);
        vm.expectRevert("Create2: insufficient balance");
        mc.deploy(1 gwei + 1, salt, bytecode);
    }

    function test_ComputeAddress() external {
        string memory name = "Michael.W";
        uint age = 18;
        // 1. deploy the contract with a non-payable constructor
        bytes32 salt = keccak256("deploy the contract with a non-payable constructor");
        bytes memory encodedConstructorParams = abi.encode(name, age);
        bytes memory bytecode = abi.encodePacked(type(ContractWithConstructor).creationCode, encodedConstructorParams);
        bytes32 bytecodeHash = keccak256(bytecode);
        assertEq(mc.deploy(0, salt, bytecode), mc.computeAddress(salt, bytecodeHash));

        // 2. deploy the contract with a payable constructor
        vm.deal(address(mc), 3 gwei);
        salt = keccak256("deploy the contract with a payable constructor");
        bytecode = abi.encodePacked(type(ContractWithPayableConstructor).creationCode, encodedConstructorParams);
        bytecodeHash = keccak256(bytecode);
        assertEq(mc.deploy(2 gwei, salt, bytecode), mc.computeAddress(salt, bytecodeHash));
        assertEq(address(mc).balance, 1 gwei);
    }

    function test_ComputeAddress_WithDeployer() external {
        MockCreate2 mcOther = new MockCreate2();
        string memory name = "Michael.W";
        uint age = 18;
        // 1. deploy the contract with a non-payable constructor
        bytes32 salt = keccak256("deploy the contract with a non-payable constructor");
        bytes memory encodedConstructorParams = abi.encode(name, age);
        bytes memory bytecode = abi.encodePacked(type(ContractWithConstructor).creationCode, encodedConstructorParams);
        bytes32 bytecodeHash = keccak256(bytecode);
        assertEq(mcOther.deploy(0, salt, bytecode), mc.computeAddress(salt, bytecodeHash, address(mcOther)));

        // 2. deploy the contract with a payable constructor
        vm.deal(address(mcOther), 3 gwei);
        salt = keccak256("deploy the contract with a payable constructor");
        bytecode = abi.encodePacked(type(ContractWithPayableConstructor).creationCode, encodedConstructorParams);
        bytecodeHash = keccak256(bytecode);
        assertEq(mcOther.deploy(2 gwei, salt, bytecode), mc.computeAddress(salt, bytecodeHash, address(mcOther)));
        assertEq(address(mcOther).balance, 1 gwei);
    }
}
