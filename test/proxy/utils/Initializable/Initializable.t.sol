// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../../src/proxy/utils/MockInitializable.sol";
import "./MockERC1967Proxy.sol";
import "./Implementation.sol";

contract InitializableTest is Test, IMockInitializable, IImplementation, IModuleAdded {

    event Initialized(uint8 version);

    function test_Initializer_SingleInitializerInConstructor() external {
        vm.expectEmit();
        emit IMockInitializable.DoWithInitializer(0);
        vm.expectEmit();
        emit Initialized(1);

        MockInitializable testingSingleInitializerInConstructor = new MockInitializable(ConstructorLogic.DO_WITH_SINGLE_INITIALIZER);
        assertEq(testingSingleInitializerInConstructor.counter(), 1);
        assertEq(testingSingleInitializerInConstructor.getInitializedVersion(), 1);
        assertFalse(testingSingleInitializerInConstructor.isInitializing());

        // revert if call the initializer after constructor
        vm.expectRevert("Initializable: contract is already initialized");
        testingSingleInitializerInConstructor.doWithInitializer();
    }

    function test_Initializer_NestedInitializerInConstructor() external {
        vm.expectEmit();
        emit IMockInitializable.DoWithInitializer(0);
        vm.expectEmit();
        emit IMockInitializable.DoInNestedInitializer(1);
        vm.expectEmit();
        emit Initialized(1);

        MockInitializable testingNestedInitializerInConstructor = new MockInitializable(ConstructorLogic.DO_WITH_NESTED_INITIALIZER);
        assertEq(testingNestedInitializerInConstructor.counter(), 2);
        assertEq(testingNestedInitializerInConstructor.getInitializedVersion(), 1);
        assertFalse(testingNestedInitializerInConstructor.isInitializing());

        // revert if call the initializer after constructor
        vm.expectRevert("Initializable: contract is already initialized");
        testingNestedInitializerInConstructor.doWithInitializer();
    }

    function test_Initializer_InitializersInSequenceInConstructor() external {
        vm.expectEmit();
        emit IMockInitializable.DoWithInitializer(0);
        vm.expectEmit();
        emit Initialized(1);
        vm.expectEmit();
        emit IMockInitializable.DoWithInitializer(1);
        vm.expectEmit();
        emit Initialized(1);

        MockInitializable testingInitializersInSequenceInConstructor = new MockInitializable(ConstructorLogic.DO_WITH_INITIALIZERS_IN_SEQUENCE);
        assertEq(testingInitializersInSequenceInConstructor.counter(), 2);
        assertEq(testingInitializersInSequenceInConstructor.getInitializedVersion(), 1);
        assertFalse(testingInitializersInSequenceInConstructor.isInitializing());

        // revert if call the initializer after constructor
        vm.expectRevert("Initializable: contract is already initialized");
        testingInitializersInSequenceInConstructor.doWithInitializer();
    }

    function test_Initializer_OutOfConstructor() external {
        MockInitializable testingEmptyConstructor = new MockInitializable(ConstructorLogic.NO_LOGIC);
        assertEq(testingEmptyConstructor.getInitializedVersion(), 0);
        assertFalse(testingEmptyConstructor.isInitializing());

        vm.expectEmit(address(testingEmptyConstructor));
        emit IMockInitializable.DoWithInitializer(0);
        vm.expectEmit(address(testingEmptyConstructor));
        emit Initialized(1);

        testingEmptyConstructor.doWithInitializer();
        assertEq(testingEmptyConstructor.counter(), 1);
        assertEq(testingEmptyConstructor.getInitializedVersion(), 1);
        assertFalse(testingEmptyConstructor.isInitializing());

        // revert if call the initializer again
        vm.expectRevert("Initializable: contract is already initialized");
        testingEmptyConstructor.doWithInitializer();
    }

    function test_Reinitializer() external {
        // case 1: test call single reinitializer
        MockInitializable testing = new MockInitializable(ConstructorLogic.DO_WITH_SINGLE_INITIALIZER);
        assertEq(testing.counter(), 1);
        assertEq(testing.getInitializedVersion(), 1);

        uint8 version = uint8(testing.getInitializedVersion()) + 1;
        vm.expectEmit(address(testing));
        emit IMockInitializable.DoWithReinitializer(version);
        vm.expectEmit(address(testing));
        emit Initialized(version);

        testing.doWithReinitializer(version);
        assertEq(testing.counter(), version);
        assertEq(testing.getInitializedVersion(), version);
        assertFalse(testing.isInitializing());

        // revert if call single reinitializer again with the same or lesser version
        vm.expectRevert("Initializable: contract is already initialized");
        testing.doWithReinitializer(version);
        vm.expectRevert("Initializable: contract is already initialized");
        testing.doWithReinitializer(version - 1);

        // revert if call initializer again
        vm.expectRevert("Initializable: contract is already initialized");
        testing.doWithInitializer();

        // case 2: test call initializers in sequence
        version = testing.getInitializedVersion() + 10;
        vm.expectEmit(address(testing));
        emit IMockInitializable.DoWithReinitializer(version);
        vm.expectEmit(address(testing));
        emit Initialized(version);
        vm.expectEmit(address(testing));
        emit IMockInitializable.DoWithReinitializer(version + 1);
        vm.expectEmit(address(testing));
        emit Initialized(version + 1);

        testing.doWithReinitializersInSequence(version);
        assertEq(testing.counter(), version + 1);
        assertEq(testing.getInitializedVersion(), version + 1);
        assertFalse(testing.isInitializing());

        // revert if call single reinitializer again with the same or lesser version
        vm.expectRevert("Initializable: contract is already initialized");
        testing.doWithReinitializer(version + 1);
        vm.expectRevert("Initializable: contract is already initialized");
        testing.doWithReinitializer(version + 1 - 1);

        // revert if call initializer again
        vm.expectRevert("Initializable: contract is already initialized");
        testing.doWithInitializer();

        // case 3: test call nested reinitializers
        // revert
        version = testing.getInitializedVersion() + 1;
        vm.expectRevert("Initializable: contract is already initialized");
        testing.doWithNestedReinitializer(version);
    }

    function test_OnlyInitializing() external {
        // case 1: revert when call onlyInitializing directly out of initializer or reinitializer
        MockInitializable testing = new MockInitializable(ConstructorLogic.NO_LOGIC);
        vm.expectRevert("Initializable: contract is not initializing");
        testing.doWithOnlyInitializing();

        // case 2: revert when call nested onlyInitializing directly out of initializer or reinitializer
        vm.expectRevert("Initializable: contract is not initializing");
        testing.doWithNestedOnlyInitializing();

        // case 3: call onlyInitializing in initializer
        vm.expectEmit(address(testing));
        emit IMockInitializable.DoWithOnlyInitializing(1, true, 0);
        vm.expectEmit(address(testing));
        emit IMockInitializable.DoWithInitializer(1);
        vm.expectEmit(address(testing));
        emit Initialized(1);

        testing.doWithOnlyInitializingInInitializer();
        assertEq(testing.counter(), 0 + 2);
        assertEq(testing.getInitializedVersion(), 1);
        assertFalse(testing.isInitializing());

        // case 4: call onlyInitializing in sequence in initializer
        testing = new MockInitializable(ConstructorLogic.NO_LOGIC);
        vm.expectEmit(address(testing));
        emit IMockInitializable.DoWithOnlyInitializing(1, true, 0);
        vm.expectEmit(address(testing));
        emit IMockInitializable.DoWithOnlyInitializing(1, true, 1);
        vm.expectEmit(address(testing));
        emit IMockInitializable.DoWithInitializer(2);
        vm.expectEmit(address(testing));
        emit Initialized(1);

        testing.doWithOnlyInitializingInSequenceInInitializer();
        assertEq(testing.counter(), 0 + 3);
        assertEq(testing.getInitializedVersion(), 1);
        assertFalse(testing.isInitializing());

        // case 5: call nested onlyInitializing in initializer
        testing = new MockInitializable(ConstructorLogic.NO_LOGIC);
        vm.expectEmit(address(testing));
        emit IMockInitializable.DoWithOnlyInitializing(1, true, 0);
        vm.expectEmit(address(testing));
        emit IMockInitializable.DoWithOnlyInitializing(1, true, 1);
        vm.expectEmit(address(testing));
        emit IMockInitializable.DoWithInitializer(2);
        vm.expectEmit(address(testing));
        emit Initialized(1);

        testing.doWithNestedOnlyInitializingInInitializer();
        assertEq(testing.counter(), 0 + 3);
        assertEq(testing.getInitializedVersion(), 1);
        assertFalse(testing.isInitializing());

        // case 6: call onlyInitializing in reinitializer
        uint8 version = testing.getInitializedVersion() + 10;
        vm.expectEmit(address(testing));
        emit IMockInitializable.DoWithOnlyInitializing(version, true, 3);
        vm.expectEmit(address(testing));
        emit IMockInitializable.DoWithReinitializer(4);
        vm.expectEmit(address(testing));
        emit Initialized(version);

        testing.doWithOnlyInitializingInReinitializer(version);
        assertEq(testing.counter(), 3 + 2);
        assertEq(testing.getInitializedVersion(), version);
        assertFalse(testing.isInitializing());

        // case 7: call onlyInitializing in sequence in reinitializer
        version = testing.getInitializedVersion() + 10;
        vm.expectEmit(address(testing));
        emit IMockInitializable.DoWithOnlyInitializing(version, true, 5);
        vm.expectEmit(address(testing));
        emit IMockInitializable.DoWithOnlyInitializing(version, true, 6);
        vm.expectEmit(address(testing));
        emit IMockInitializable.DoWithReinitializer(7);
        vm.expectEmit(address(testing));
        emit Initialized(version);

        testing.doWithOnlyInitializingInSequenceInReinitializer(version);
        assertEq(testing.counter(), 5 + 3);
        assertEq(testing.getInitializedVersion(), version);
        assertFalse(testing.isInitializing());

        // case 8: call nested onlyInitializing in reinitializer
        version = testing.getInitializedVersion() + 10;
        vm.expectEmit(address(testing));
        emit IMockInitializable.DoWithOnlyInitializing(version, true, 8);
        vm.expectEmit(address(testing));
        emit IMockInitializable.DoWithOnlyInitializing(version, true, 9);
        vm.expectEmit(address(testing));
        emit IMockInitializable.DoWithReinitializer(10);
        vm.expectEmit(address(testing));
        emit Initialized(version);

        testing.doWithNestedOnlyInitializingInReinitializer(version);
        assertEq(testing.counter(), 8 + 3);
        assertEq(testing.getInitializedVersion(), version);
        assertFalse(testing.isInitializing());

        // case 9: disable initializers
        // case 9.1: disable after initializer
        vm.expectEmit(address(testing));
        emit Initialized(type(uint8).max);

        testing.disableInitializers();
        assertEq(testing.getInitializedVersion(), type(uint8).max);
        assertFalse(testing.isInitializing());
        // can't reinitialize again
        vm.expectRevert("Initializable: contract is already initialized");
        testing.doWithReinitializer(type(uint8).max);

        // case 9.2: disable before initializer
        testing = new MockInitializable(ConstructorLogic.NO_LOGIC);
        vm.expectEmit(address(testing));
        emit Initialized(type(uint8).max);

        testing.disableInitializers();
        assertEq(testing.getInitializedVersion(), type(uint8).max);
        assertFalse(testing.isInitializing());
        // can't initialize or reinitialize again
        vm.expectRevert("Initializable: contract is already initialized");
        testing.doWithInitializer();
        vm.expectRevert("Initializable: contract is already initialized");
        testing.doWithReinitializer(type(uint8).max);

        // case 10: revert if call _disableInitializers in initializer
        testing = new MockInitializable(ConstructorLogic.NO_LOGIC);
        vm.expectRevert("Initializable: contract is initializing");
        testing.disableInitializersInInitializer();

        // case 11: revert if call _disableInitializers in initializer
        testing = new MockInitializable(ConstructorLogic.DO_WITH_SINGLE_INITIALIZER);
        vm.expectRevert("Initializable: contract is initializing");
        testing.disableInitializersInReinitializer(1 + 1);
    }

    function test_AllModifiersInProxyAndImplementationPattern() external {
        // deploy Implementation first
        Implementation currentImplementation = new Implementation();
        // deploy proxy and execute the initializer
        uint i = 1024;
        vm.expectEmit();
        emit IImplementation.InitializeStorageUint(i);
        vm.expectEmit();
        emit Initialized(1);

        address payable proxyAddress = payable(address(new MockERC1967Proxy(
            address(currentImplementation),
            abi.encodeCall(
                currentImplementation.__Implementation_initialize,
                (i)
            )
        )));
        // check the initialized result of proxy
        assertEq(Implementation(proxyAddress).i(), i);
        // call proxy
        i = 2048;
        Implementation(proxyAddress).setI(i);
        assertEq(Implementation(proxyAddress).i(), i);

        // revert if initialize again
        vm.expectRevert("Initializable: contract is already initialized");
        Implementation(proxyAddress).__Implementation_initialize(i);

        // deploy the implementation to upgrade
        ImplementationToUpgrade newImplementation = new ImplementationToUpgrade();
        // upgrade and execute the reinitialize
        i = 4096;
        address addr = address(1024);
        uint8 version = 1 + 1;
        vm.expectEmit(proxyAddress);
        emit IModuleAdded.InitializeStorageAddress(addr);
        vm.expectEmit(proxyAddress);
        emit Initialized(version);

        MockERC1967Proxy(proxyAddress).upgradeToAndCall(
            address(newImplementation),
            abi.encodeCall(
                newImplementation.reinitialize,
                (i, addr, version)
            )
        );
        // check the reinitialized result of proxy
        assertEq(ImplementationToUpgrade(proxyAddress).i(), i);
        assertEq(ImplementationToUpgrade(proxyAddress).addr(), addr);
        // call proxy with old and new functions
        i = 8192;
        ImplementationToUpgrade(proxyAddress).setI(i);
        assertEq(ImplementationToUpgrade(proxyAddress).i(), i);
        addr = address(2048);
        ImplementationToUpgrade(proxyAddress).setAddr(addr);
        assertEq(ImplementationToUpgrade(proxyAddress).addr(), addr);

        // reinitialize again with larger version
        i = 16384;
        addr = address(4096);
        vm.expectEmit(proxyAddress);
        emit IModuleAdded.InitializeStorageAddress(addr);
        vm.expectEmit(proxyAddress);
        emit Initialized(version + 1);

        ImplementationToUpgrade(proxyAddress).reinitialize(i, addr, version + 1);
        // check the reinitialized result of proxy
        assertEq(ImplementationToUpgrade(proxyAddress).i(), i);
        assertEq(ImplementationToUpgrade(proxyAddress).addr(), addr);

        // disable the proxy from reinitializers
        vm.expectEmit(proxyAddress);
        emit Initialized(type(uint8).max);

        ImplementationToUpgrade(proxyAddress).disableInitializers();

        // revert if reinitialize again
        vm.expectRevert("Initializable: contract is already initialized");
        ImplementationToUpgrade(proxyAddress).reinitialize(i, addr, type(uint8).max);
    }
}