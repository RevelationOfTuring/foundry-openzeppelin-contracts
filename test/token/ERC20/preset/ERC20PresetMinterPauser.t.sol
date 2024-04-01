// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract ERC20PresetMinterPauserTest is Test {
    ERC20PresetMinterPauser private _testing = new ERC20PresetMinterPauser("test name", "test symbol");

    function test_Constructor() external {
        address deployer = address(this);

        // check the auth grant
        assertTrue(_testing.hasRole(_testing.DEFAULT_ADMIN_ROLE(), deployer));
        assertTrue(_testing.hasRole(_testing.MINTER_ROLE(), deployer));
        assertTrue(_testing.hasRole(_testing.PAUSER_ROLE(), deployer));
    }

    function test_Mint() external {
        address user = address(1);
        assertEq(_testing.balanceOf(user), 0);
        // pass mint
        _testing.mint(user, 100);
        assertEq(_testing.balanceOf(user), 100);

        // revert if the caller has no auth of MINTER_ROLE
        assertFalse(_testing.hasRole(_testing.MINTER_ROLE(), user));
        vm.prank(user);
        vm.expectRevert("ERC20PresetMinterPauser: must have minter role to mint");
        _testing.mint(user, 100);
    }

    function test_PauseAndUnpause() external {
        address user = address(1);

        // test for {pause}
        assertFalse(_testing.paused());
        _testing.pause();
        assertTrue(_testing.paused());

        // revert if caller has no auth of PAUSER_ROLE
        assertFalse(_testing.hasRole(_testing.PAUSER_ROLE(), user));
        vm.prank(user);
        vm.expectRevert("ERC20PresetMinterPauser: must have pauser role to pause");
        _testing.pause();

        // revert with {mint}
        vm.expectRevert("ERC20Pausable: token transfer while paused");
        _testing.mint(user, 1);
        // revert with {transfer}
        vm.expectRevert("ERC20Pausable: token transfer while paused");
        _testing.transfer(user, 1);
        // revert with {transferFrom}
        _testing.approve(user, 1024);
        vm.expectRevert("ERC20Pausable: token transfer while paused");
        vm.prank(user);
        _testing.transferFrom(address(this), user, 1024);
        // revert with {burn}
        vm.expectRevert("ERC20Pausable: token transfer while paused");
        _testing.burn(1);
        // revert with {burnFrom}
        vm.expectRevert("ERC20Pausable: token transfer while paused");
        vm.prank(user);
        _testing.burnFrom(address(this), 1024);

        // test for {unpause}
        _testing.unpause();
        assertFalse(_testing.paused());

        // revert if caller has no auth of PAUSER_ROLE
        vm.prank(user);
        vm.expectRevert("ERC20PresetMinterPauser: must have pauser role to unpause");
        _testing.unpause();

        // available on {mint}
        assertEq(_testing.balanceOf(user), 0);
        _testing.mint(user, 100);
        assertEq(_testing.balanceOf(user), 100);
        // available on {transfer}
        assertEq(_testing.balanceOf(address(this)), 0);
        vm.prank(user);
        _testing.transfer(address(this), 1);
        assertEq(_testing.balanceOf(address(this)), 1);
        // available on {transferFrom}
        vm.prank(user);
        _testing.approve(address(this), 100);
        _testing.transferFrom(user, address(this), 1);
        assertEq(_testing.balanceOf(address(this)), 1 + 1);
        // available on {burn}
        _testing.burn(1);
        assertEq(_testing.balanceOf(address(this)), 2 - 1);
        // available on {burnFrom}
        _testing.approve(user, 1);
        vm.prank(user);
        _testing.burnFrom(address(this), 1);
        assertEq(_testing.balanceOf(address(this)), 1 - 1);
    }
}
