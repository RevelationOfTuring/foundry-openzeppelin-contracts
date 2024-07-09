// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/proxy/utils/Initializable.sol";

// the implementation before upgrade
interface IImplementation {
    event InitializeStorageUint(uint);
}

contract Implementation is Initializable, IImplementation {
    // storage
    uint public i;

    // initializer
    function __Implementation_initialize(uint i_) external initializer {
        i = i_;
        emit InitializeStorageUint(i_);
    }

    function setI(uint newI) external {
        i = newI;
    }
}

// supplement in the new implementation
interface IModuleAdded {
    event InitializeStorageAddress(address);
}

contract ModuleAdded is Initializable, IModuleAdded {
    // supplement storage
    address public addr;

    // initializer modified with onlyInitializing
    function __ModuleAdded_initialize(address addr_) internal onlyInitializing {
        addr = addr_;
        emit InitializeStorageAddress(addr_);
    }

    function setAddr(address newAddr) external {
        addr = newAddr;
    }
}

// new implementation to upgrade to
contract ImplementationToUpgrade is Implementation, ModuleAdded {
    function reinitialize(uint newI, address newAddr, uint8 version) external reinitializer(version) {
        __ModuleAdded_initialize(newAddr);
        this.setI(newI);
    }

    function disableInitializers() external {
        _disableInitializers();
    }
}
