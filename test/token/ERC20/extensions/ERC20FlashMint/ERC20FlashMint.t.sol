// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../../../src/token/ERC20/extensions/MockERC20FlashMint.sol";
import "./ERC3156FlashBorrower.sol";

contract ERC20FlashMintTest is Test {
    address private constant CUSTOMIZED_FLASH_FEE_RECEIVER = address(1024);

    MockERC20FlashMint private _testing = new MockERC20FlashMint("test name", "test symbol", address(this), 10000);
    ERC3156FlashBorrower private flashBorrower = new ERC3156FlashBorrower();

    function test_MaxFlashLoan() external {
        uint totalSupply = _testing.totalSupply();
        assertEq(totalSupply, 10000);
        // query for self
        assertEq(_testing.maxFlashLoan(address(_testing)), type(uint).max - totalSupply);
        // query for other
        assertEq(_testing.maxFlashLoan(address(0)), 0);
    }

    function test_FlashFee() external {
        // case 1: default flash fee (0)
        uint amountToLoan = 100;
        assertEq(_testing.flashFee(address(_testing), amountToLoan), 0);
        // revert with wrong token address
        vm.expectRevert("ERC20FlashMint: wrong token");
        _testing.flashFee(address(0), amountToLoan);

        // case 2: customized flash fee (10% amountToLoan)
        _testing.customizedFlashFeeAndReceiver();
        assertEq(_testing.flashFee(address(_testing), amountToLoan), amountToLoan / 10);
        // revert with wrong token address
        vm.expectRevert("ERC20FlashMint: wrong token");
        _testing.flashFee(address(0), amountToLoan);
    }

    event Transfer(address indexed from, address indexed to, uint256 value);

    event ParamsIn(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes data
    );

    event Monitor(
        address owner,
        uint balance,
        uint totalSupply
    );

    function test_FlashLoan_DefaultFlashFeeAndReceiver() external {
        assertEq(_testing.totalSupply(), 10000);
        // case 1: pass with flash borrower's approval and valid return value
        uint amountToLoan = 20000;
        uint defaultFee = 0;
        flashBorrower.flipApprove();
        flashBorrower.flipValidReturnValue();

        // mint amountToLoan to flashBorrower
        vm.expectEmit(address(_testing));
        emit Transfer(address(0), address(flashBorrower), amountToLoan);
        // check params input in IERC3156FlashBorrower.onFlashLoan()
        vm.expectEmit(address(flashBorrower));
        emit ParamsIn(address(this), address(_testing), amountToLoan, defaultFee, '');
        // check the state during IERC3156FlashBorrower.onFlashLoan()
        vm.expectEmit(address(flashBorrower));
        emit Monitor(address(flashBorrower), amountToLoan, amountToLoan + 10000);
        // burn amountToLoan + fee(0) from flashBorrower
        vm.expectEmit(address(_testing));
        emit Transfer(address(flashBorrower), address(0), amountToLoan + defaultFee);
        _testing.flashLoan(flashBorrower, address(_testing), amountToLoan, '');
        // total supply not changed
        assertEq(_testing.totalSupply(), 10000);

        // case 2: revert if amountToLoan > maxFlashLoan
        uint amountExceedsMaxFlashLoan = _testing.maxFlashLoan(address(_testing)) + 1;
        vm.expectRevert("ERC20FlashMint: amount exceeds maxFlashLoan");
        _testing.flashLoan(flashBorrower, address(_testing), amountExceedsMaxFlashLoan, '');

        // case 3: revert if receiver.onFlashLoan() with invalid return value
        flashBorrower.flipValidReturnValue();
        vm.expectRevert("ERC20FlashMint: invalid return value");
        _testing.flashLoan(flashBorrower, address(_testing), amountToLoan, '');
        flashBorrower.flipValidReturnValue();

        // case 4: revert without approval in IERC3156FlashBorrower.onFlashLoan()
        flashBorrower.flipApprove();
        vm.expectRevert("ERC20: insufficient allowance");
        _testing.flashLoan(flashBorrower, address(_testing), amountToLoan, '');
        flashBorrower.flipApprove();

        // case 5: revert with different amounts can be minted and burned in onFlashLoan()
        // transfer 1 to address(1) in IERC3156FlashBorrower.onFlashLoan()
        bytes memory data = abi.encodeCall(_testing.transfer, (address(1), 1));
        vm.expectRevert("ERC20: burn amount exceeds balance");
        _testing.flashLoan(flashBorrower, address(_testing), amountToLoan, data);
    }

    function test_FlashLoan_CustomizedFlashFeeAndReceiver() external {
        _testing.customizedFlashFeeAndReceiver();
        assertEq(_testing.balanceOf(address(this)), 10000);
        assertEq(_testing.balanceOf(address(flashBorrower)), 0);
        assertEq(_testing.balanceOf(CUSTOMIZED_FLASH_FEE_RECEIVER), 0);

        // case 1: pass with flash borrower's approval and valid return value
        uint amountToLoan = 20000;
        uint customizedFlashFee = amountToLoan / 10;
        flashBorrower.flipApprove();
        flashBorrower.flipValidReturnValue();
        // transfer flash fee to flash borrower
        _testing.transfer(address(flashBorrower), customizedFlashFee);

        // mint amountToLoan to flashBorrower
        vm.expectEmit(address(_testing));
        emit Transfer(address(0), address(flashBorrower), amountToLoan);
        // check params input in IERC3156FlashBorrower.onFlashLoan()
        vm.expectEmit(address(flashBorrower));
        emit ParamsIn(address(this), address(_testing), amountToLoan, customizedFlashFee, '');
        // check the state during IERC3156FlashBorrower.onFlashLoan()
        vm.expectEmit(address(flashBorrower));
        emit Monitor(address(flashBorrower), amountToLoan + customizedFlashFee, amountToLoan + 10000);
        // burn amountToLoan from flashBorrower
        vm.expectEmit(address(_testing));
        emit Transfer(address(flashBorrower), address(0), amountToLoan);
        // transfer customizedFlashFee to customizedFlashFeeReceiver
        vm.expectEmit(address(_testing));
        emit Transfer(address(flashBorrower), CUSTOMIZED_FLASH_FEE_RECEIVER, customizedFlashFee);

        _testing.flashLoan(flashBorrower, address(_testing), amountToLoan, '');
        // total supply not changed
        assertEq(_testing.totalSupply(), 10000);
        assertEq(_testing.balanceOf(address(this)), 10000 - customizedFlashFee);
        assertEq(_testing.balanceOf(address(flashBorrower)), 0);
        assertEq(_testing.balanceOf(CUSTOMIZED_FLASH_FEE_RECEIVER), customizedFlashFee);

        // case 2: revert if amountToLoan > maxFlashLoan
        uint amountExceedsMaxFlashLoan = _testing.maxFlashLoan(address(_testing)) + 1;
        vm.expectRevert("ERC20FlashMint: amount exceeds maxFlashLoan");
        _testing.flashLoan(flashBorrower, address(_testing), amountExceedsMaxFlashLoan, '');

        // case 3: revert if receiver.onFlashLoan() with invalid return value
        flashBorrower.flipValidReturnValue();
        vm.expectRevert("ERC20FlashMint: invalid return value");
        _testing.flashLoan(flashBorrower, address(_testing), amountToLoan, '');
        flashBorrower.flipValidReturnValue();

        // case 4: revert without approval in IERC3156FlashBorrower.onFlashLoan()
        flashBorrower.flipApprove();
        vm.expectRevert("ERC20: insufficient allowance");
        _testing.flashLoan(flashBorrower, address(_testing), amountToLoan, '');
        flashBorrower.flipApprove();

        // case 5: revert with different amounts can be minted and burned in onFlashLoan()
        // transfer 1 to address(1) in IERC3156FlashBorrower.onFlashLoan()
        bytes memory data = abi.encodeCall(_testing.transfer, (address(1), 1));
        vm.expectRevert("ERC20: burn amount exceeds balance");
        _testing.flashLoan(flashBorrower, address(_testing), amountToLoan, data);

        // case 6: revert with insufficient flash fee
        _testing.transfer(address(flashBorrower), customizedFlashFee - 1);
        vm.expectRevert("ERC20: transfer amount exceeds balance");
        _testing.flashLoan(flashBorrower, address(_testing), amountToLoan, '');
    }
}
