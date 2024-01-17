// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../../../src/token/ERC20/utils/MockSafeERC20.sol";
import "./MockERC20ReturnTrue.sol";
import "./MockERC20ReturnFalse.sol";
import "./MockERC20ReturnNonBool.sol";
import "./MockERC20ReturnNone.sol";
import "./MockERC20Revert.sol";
import "./MockERC20Permit.sol";

contract SafeERC20Test is Test {
    address private constant _REVERT_FLAG = address(1024);

    MockSafeERC20 private _testing = new MockSafeERC20();
    MockERC20ReturnTrue private _mockERC20ReturnTrue = new MockERC20ReturnTrue();
    MockERC20ReturnFalse private _mockERC20ReturnFalse = new MockERC20ReturnFalse();
    IERC20 private _mockERC20ReturnNonBool = IERC20(address(new MockERC20ReturnNonBool()));
    IERC20 private _mockERC20ReturnNone = IERC20(address(new MockERC20ReturnNone()));
    MockERC20Revert private _mockERC20Revert = new MockERC20Revert();
    IERC20 private _mockERC20NoCode = IERC20(address(0));
    MockERC20Permit private _mockERC20Permit = new MockERC20Permit();

    event Transfer(address indexed from, address indexed to, uint value);

    function test_SafeTransfer() external {
        address to = address(this);

        // case 1: pass if token returns true
        vm.expectEmit(true, true, false, true, address(_mockERC20ReturnTrue));
        emit Transfer(address(_testing), to, 1);
        _testing.safeTransfer(_mockERC20ReturnTrue, to, 1);

        // case 2: pass if token has no return
        vm.expectEmit(true, true, false, true, address(_mockERC20ReturnNone));
        emit Transfer(address(_testing), to, 1);
        _testing.safeTransfer(_mockERC20ReturnNone, to, 1);

        // case 3: revert if token returns false
        vm.expectRevert("SafeERC20: ERC20 operation did not succeed");
        _testing.safeTransfer(_mockERC20ReturnFalse, to, 1);

        // case 4: revert if token returns non-bool
        vm.expectRevert();
        _testing.safeTransfer(_mockERC20ReturnNonBool, to, 1);

        // case 5: revert if reverts in token
        vm.expectRevert("MockERC20ReturnRevert: transfer");
        _testing.safeTransfer(_mockERC20Revert, _REVERT_FLAG, 1);

        // case 6: revert if token has no code
        vm.expectRevert("Address: call to non-contract");
        _testing.safeTransfer(_mockERC20NoCode, to, 1);
    }

    function test_SafeTransferFrom() external {
        address from = address(1);
        address to = address(this);

        // case 1: pass if token returns true
        vm.expectEmit(true, true, false, true, address(_mockERC20ReturnTrue));
        emit Transfer(from, to, 1);
        _testing.safeTransferFrom(_mockERC20ReturnTrue, from, to, 1);

        // case 2: pass if token has no return
        vm.expectEmit(true, true, false, true, address(_mockERC20ReturnNone));
        emit Transfer(from, to, 1);
        _testing.safeTransferFrom(_mockERC20ReturnNone, from, to, 1);

        // case 3: revert if token returns false
        vm.expectRevert("SafeERC20: ERC20 operation did not succeed");
        _testing.safeTransferFrom(_mockERC20ReturnFalse, from, to, 1);

        // case 4: revert if token returns non-bool
        vm.expectRevert();
        _testing.safeTransferFrom(_mockERC20ReturnNonBool, from, to, 1);

        // case 5: revert if reverts in token
        vm.expectRevert("MockERC20ReturnRevert: transferFrom");
        _testing.safeTransferFrom(_mockERC20Revert, _REVERT_FLAG, to, 1);

        // case 6: revert if token has no code
        vm.expectRevert("Address: call to non-contract");
        _testing.safeTransferFrom(_mockERC20NoCode, from, to, 1);
    }

    event Approval(address indexed owner, address indexed spender, uint value);

    function test_SafeApprove() external {
        address spenderSomeAllowance = address(1024);
        address spenderZeroAllowance = address(2048);

        // 1. token returns true
        // case 1: pass if clear allowance && token returns true
        assertNotEq(_mockERC20ReturnTrue.allowance(address(_testing), spenderSomeAllowance), 0);
        vm.expectEmit(true, true, false, true, address(_mockERC20ReturnTrue));
        emit Approval(address(_testing), spenderSomeAllowance, 0);
        _testing.safeApprove(_mockERC20ReturnTrue, spenderSomeAllowance, 0);

        // case 2: pass if initial allowance setting && token returns true
        assertEq(_mockERC20ReturnTrue.allowance(address(_testing), spenderZeroAllowance), 0);
        vm.expectEmit(true, true, false, true, address(_mockERC20ReturnTrue));
        emit Approval(address(_testing), spenderZeroAllowance, 1);
        _testing.safeApprove(_mockERC20ReturnTrue, spenderZeroAllowance, 1);

        // case 3: revert if some allowance && non-zero value && token returns true
        vm.expectRevert("SafeERC20: approve from non-zero to non-zero allowance");
        _testing.safeApprove(_mockERC20ReturnTrue, spenderSomeAllowance, 1);

        // 2. token returns false
        // case 1: revert if clear allowance && token returns false
        vm.expectRevert("SafeERC20: ERC20 operation did not succeed");
        _testing.safeApprove(_mockERC20ReturnFalse, spenderSomeAllowance, 0);

        // case 2: revert if initial allowance setting && token returns false
        vm.expectRevert("SafeERC20: ERC20 operation did not succeed");
        _testing.safeApprove(_mockERC20ReturnFalse, spenderZeroAllowance, 1);

        // case 3: revert if some allowance && non-zero value && token returns false
        vm.expectRevert("SafeERC20: approve from non-zero to non-zero allowance");
        _testing.safeApprove(_mockERC20ReturnFalse, spenderSomeAllowance, 1);

        // 3. token returns None
        // case 1: pass if clear allowance && token returns none
        vm.expectEmit(true, true, false, true, address(_mockERC20ReturnNone));
        emit Approval(address(_testing), spenderSomeAllowance, 0);
        _testing.safeApprove(_mockERC20ReturnNone, spenderSomeAllowance, 0);

        // case 2: pass if initial allowance setting && token returns none
        vm.expectEmit(true, true, false, true, address(_mockERC20ReturnNone));
        emit Approval(address(_testing), spenderZeroAllowance, 1);
        _testing.safeApprove(_mockERC20ReturnNone, spenderZeroAllowance, 1);

        // case 3: revert if some allowance && non-zero value && token returns none
        vm.expectRevert("SafeERC20: approve from non-zero to non-zero allowance");
        _testing.safeApprove(_mockERC20ReturnNone, spenderSomeAllowance, 1);

        // 4. token returns non-bool
        // case 1: revert if clear allowance && token returns non-bool
        vm.expectRevert();
        _testing.safeApprove(_mockERC20ReturnNonBool, spenderSomeAllowance, 0);

        // case 2: revert if initial allowance setting && token returns non-bool
        vm.expectRevert();
        _testing.safeApprove(_mockERC20ReturnNonBool, spenderZeroAllowance, 1);

        // case 3: revert if some allowance && non-zero value && token returns non-bool
        vm.expectRevert("SafeERC20: approve from non-zero to non-zero allowance");
        _testing.safeApprove(_mockERC20ReturnNonBool, spenderSomeAllowance, 1);

        // 5. token reverts
        // case 1: revert if pass allowance && value check && token reverts
        vm.expectRevert("MockERC20ReturnRevert: approve");
        _testing.safeApprove(_mockERC20Revert, _REVERT_FLAG, 0);

        // case 2: revert if not pass allowance && value check
        vm.expectRevert("SafeERC20: approve from non-zero to non-zero allowance");
        _testing.safeApprove(_mockERC20ReturnNonBool, spenderSomeAllowance, 1);

        // 6. token has no code
        // revert via allowance's check
        vm.expectRevert();
        _testing.safeApprove(_mockERC20NoCode, spenderSomeAllowance, 1);
    }

    function test_SafeIncreaseAllowance() external {
        address spender = address(this);

        // case 1: pass if token returns true
        assertEq(_mockERC20ReturnTrue.allowance(address(_testing), spender), 0);
        vm.expectEmit(true, true, false, true, address(_mockERC20ReturnTrue));
        emit Approval(address(_testing), spender, 0 + 1);
        _testing.safeIncreaseAllowance(_mockERC20ReturnTrue, spender, 1);

        // case 2: revert if token returns false
        vm.expectRevert("SafeERC20: ERC20 operation did not succeed");
        _testing.safeIncreaseAllowance(_mockERC20ReturnFalse, spender, 1);

        // case 3: pass if token returns none
        assertEq(_mockERC20ReturnNone.allowance(address(_testing), spender), 0);
        vm.expectEmit(true, true, false, true, address(_mockERC20ReturnNone));
        emit Approval(address(_testing), spender, 0 + 1);
        _testing.safeIncreaseAllowance(_mockERC20ReturnNone, spender, 1);

        // case 4: revert if token returns non-bool
        vm.expectRevert();
        _testing.safeIncreaseAllowance(_mockERC20ReturnNonBool, spender, 1);

        // case 5: revert if token reverts
        vm.expectRevert("MockERC20ReturnRevert: approve");
        _testing.safeIncreaseAllowance(_mockERC20Revert, _REVERT_FLAG, 1);

        // case 6: revert if token has no code
        vm.expectRevert();
        _testing.safeIncreaseAllowance(_mockERC20NoCode, spender, 1);
    }

    function test_SafeDecreaseAllowance() external {
        address spenderSomeAllowance = address(1024);

        // 1. token returns true
        // case 1: pass if token returns true && value <= old allowance
        assertEq(_mockERC20ReturnTrue.allowance(address(_testing), spenderSomeAllowance), 1);
        vm.expectEmit(true, true, false, true, address(_mockERC20ReturnTrue));
        emit Approval(address(_testing), spenderSomeAllowance, 1 - 1);
        _testing.safeDecreaseAllowance(_mockERC20ReturnTrue, spenderSomeAllowance, 1);

        // case 2: revert if token returns true && value > old allowance
        vm.expectRevert("SafeERC20: decreased allowance below zero");
        _testing.safeDecreaseAllowance(_mockERC20ReturnTrue, spenderSomeAllowance, 1 + 1);

        // 2. token returns false
        // case 1: revert if token returns false && value <= old allowance
        assertEq(_mockERC20ReturnFalse.allowance(address(_testing), spenderSomeAllowance), 1);
        vm.expectRevert("SafeERC20: ERC20 operation did not succeed");
        _testing.safeDecreaseAllowance(_mockERC20ReturnFalse, spenderSomeAllowance, 1);

        // case 2: revert if token returns false && value > old allowance
        vm.expectRevert("SafeERC20: decreased allowance below zero");
        _testing.safeDecreaseAllowance(_mockERC20ReturnFalse, spenderSomeAllowance, 1 + 1);

        // 3. token returns none
        // case 1: pass if token returns none && value <= old allowance
        assertEq(_mockERC20ReturnNone.allowance(address(_testing), spenderSomeAllowance), 1);
        vm.expectEmit(true, true, false, true, address(_mockERC20ReturnNone));
        emit Approval(address(_testing), spenderSomeAllowance, 1 - 1);
        _testing.safeDecreaseAllowance(_mockERC20ReturnNone, spenderSomeAllowance, 1);

        // case 2: revert if token returns none && value > old allowance
        vm.expectRevert("SafeERC20: decreased allowance below zero");
        _testing.safeDecreaseAllowance(_mockERC20ReturnNone, spenderSomeAllowance, 1 + 1);

        // 4. token returns non-bool
        // case 1: revert if token returns non-bool && value <= old allowance
        assertEq(_mockERC20ReturnNonBool.allowance(address(_testing), spenderSomeAllowance), 1);
        vm.expectRevert();
        _testing.safeDecreaseAllowance(_mockERC20ReturnNonBool, spenderSomeAllowance, 1);

        // case 2: revert if token returns non-bool && value > old allowance
        vm.expectRevert("SafeERC20: decreased allowance below zero");
        _testing.safeDecreaseAllowance(_mockERC20ReturnNonBool, spenderSomeAllowance, 1 + 1);

        // 5. token reverts
        // case 1: revert if token reverts && value <= old allowance
        assertEq(_mockERC20Revert.allowance(address(_testing), _REVERT_FLAG), 1);
        vm.expectRevert("MockERC20ReturnRevert: approve");
        _testing.safeDecreaseAllowance(_mockERC20Revert, _REVERT_FLAG, 1);

        // case 2: revert if token reverts && value > old allowance
        vm.expectRevert("SafeERC20: decreased allowance below zero");
        _testing.safeDecreaseAllowance(_mockERC20Revert, _REVERT_FLAG, 1 + 1);

        // 6. token has no code
        // revert via getting allowance
        vm.expectRevert();
        _testing.safeDecreaseAllowance(_mockERC20NoCode, spenderSomeAllowance, 1);
    }

    function test_SafePermit() external {
        address owner = address(1);
        address spender = address(2);
        uint value = 1024;

        // case 1: pass if nonce increases && no revert in {permit} and {nonces}
        vm.expectEmit(true, true, false, true, address(_mockERC20Permit));
        emit Approval(owner, spender, value);
        _testing.safePermit(
            _mockERC20Permit,
            owner,
            spender,
            value,
            0,
            0,
            0,
            0
        );

        // case 2: revert if nonce not increases
        _mockERC20Permit.setNonceIncreases(false);
        vm.expectRevert("SafeERC20: permit did not succeed");
        _testing.safePermit(
            _mockERC20Permit,
            owner,
            spender,
            value,
            0,
            0,
            0,
            0
        );

        // case 3: revert if reverts in token's {nonces}
        _mockERC20Permit.setNonceIncreases(true);
        _mockERC20Permit.setRevertInNonces(true);
        vm.expectRevert("MockERC20Permit: nonces");
        _testing.safePermit(
            _mockERC20Permit,
            owner,
            spender,
            value,
            0,
            0,
            0,
            0
        );

        // case 4: revert if reverts in token's {permit}
        _mockERC20Permit.setRevertInNonces(false);
        _mockERC20Permit.setRevertInPermit(true);
        vm.expectRevert("MockERC20Permit: permit");
        _testing.safePermit(
            _mockERC20Permit,
            owner,
            spender,
            value,
            0,
            0,
            0,
            0
        );
    }
}
