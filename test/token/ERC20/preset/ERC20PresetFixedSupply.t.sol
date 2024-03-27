// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/token/ERC20/presets/ERC20PresetFixedSupply.sol";

contract ERC20PresetFixedSupplyTest is Test {
    uint private _initialSupply = 100;
    address private _owner = address(this);
    ERC20PresetFixedSupply private _testing = new ERC20PresetFixedSupply("test name", "test symbol", _initialSupply, _owner);

    function test_Constructor() external {
        assertEq(_testing.totalSupply(), _initialSupply);
        assertEq(_testing.balanceOf(_owner), _initialSupply);

        // support {burn} && {burnFrom} of ERC20Burnable
        // test {burn}
        uint amountToBurn = 1;
        _testing.burn(amountToBurn);
        assertEq(_testing.totalSupply(), _initialSupply - amountToBurn);
        assertEq(_testing.balanceOf(_owner), _initialSupply - amountToBurn);

        // test {burnFrom}
        address spender = address(1);
        _testing.approve(spender, amountToBurn);
        vm.prank(spender);
        _testing.burnFrom(_owner, amountToBurn);
        assertEq(_testing.totalSupply(), _initialSupply - amountToBurn - amountToBurn);
        assertEq(_testing.balanceOf(_owner), _initialSupply - amountToBurn - amountToBurn);
    }
}
