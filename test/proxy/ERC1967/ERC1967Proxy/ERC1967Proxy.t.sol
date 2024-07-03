// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../../src/proxy/ERC1967/MockERC1967Proxy.sol";
import "./Implement.sol";

contract ERC1967ProxyTest is Test, IERC1967, IImplement {
    MockERC1967Proxy private _testing;
    Implement private _implement = new Implement();

    function test_ConstructorAndImplementation() external {
        // test for {constructor}
        // build the calldata of {initialize} in the implementation
        uint argUint = 1024;
        address argAddress = address(1024);
        bytes memory data = abi.encodeCall(
            _implement.initialize,
            (argUint, argAddress)
        );

        vm.expectEmit();
        emit IERC1967.Upgraded(address(_implement));
        emit IImplement.Initialize(address(this));

        _testing = new MockERC1967Proxy(
            address(_implement),
            data
        );

        address proxyAddress = address(_testing);
        // test for {getImplementation}
        assertEq(_testing.getImplementation(), address(_implement));
        // test for the result of the extra delegatecall in constructor
        Implement proxy = Implement(payable(proxyAddress));
        assertEq(proxy.i(), argUint);
        assertEq(proxy.addr(), argAddress);

        // test for other delegatecall
        argUint = 1;
        argAddress = address(1);
        proxy.initialize(argUint, argAddress);
        assertEq(proxy.i(), argUint);
        assertEq(proxy.addr(), argAddress);

        // delegatecall without calldata
        vm.expectEmit(proxyAddress);
        emit IImplement.Receive();
        (bool ok,) = proxyAddress.call("");
        assertTrue(ok);

        // delegatecall with calldata of unknown function selector
        data = "known";
        vm.expectEmit(proxyAddress);
        emit IImplement.Fallback(data);
        (ok,) = proxyAddress.call(data);
        assertTrue(ok);
    }
}