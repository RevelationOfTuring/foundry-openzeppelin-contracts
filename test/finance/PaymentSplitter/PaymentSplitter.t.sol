// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/finance/PaymentSplitter.sol";
import "./MockERC20.sol";

contract PaymentSplitterTest is Test {
    PaymentSplitter private _testing;
    MockERC20 private _erc20 = new MockERC20("test name", "test symbol");
    address[] private _payees = [address(1), address(2), address(3)];
    uint[] private _shares = [20, 30, 50];

    function setUp() external {
        vm.deal(address(this), 20000);
        _testing = new PaymentSplitter{value: 10000}(_payees, _shares);
    }

    event PayeeAdded(address account, uint shares);

    function test_Constructor() external {
        // check events
        for (uint i; i < _payees.length; ++i) {
            vm.expectEmit();
            emit PayeeAdded(_payees[i], _shares[i]);
        }
        _testing = new PaymentSplitter(_payees, _shares);

        // revert without the same length of payees and shares
        _payees.push(address(4));
        vm.expectRevert("PaymentSplitter: payees and shares length mismatch");
        new PaymentSplitter(_payees, _shares);

        // revert with 0 length of payees and shares
        vm.expectRevert("PaymentSplitter: no payees");
        new PaymentSplitter(new address[](0), new uint[](0));

        // revert with zero address in payees
        _payees = [address(0)];
        _shares = [10];
        vm.expectRevert("PaymentSplitter: account is the zero address");
        new PaymentSplitter(_payees, _shares);

        // revert with 0 in shares
        _payees = [address(1)];
        _shares = [0];
        vm.expectRevert("PaymentSplitter: shares are 0");
        new PaymentSplitter(_payees, _shares);

        // revert with repetitive addresses in payees
        _payees = [address(1), address(1)];
        _shares = [10, 20];
        vm.expectRevert("PaymentSplitter: account already has shares");
        new PaymentSplitter(_payees, _shares);
    }

    event PaymentReleased(address to, uint amount);
    event PaymentReceived(address from, uint amount);

    function test_releaseEth() external {
        assertEq(address(_testing).balance, 10000);
        // test for totalShares()
        assertEq(_testing.totalShares(), 20 + 30 + 50);
        // test for totalReleased()
        assertEq(_testing.totalReleased(), 0);
        // test for shares(address) && released(address) && payee(uint)
        for (uint i; i < _payees.length; ++i) {
            assertEq(_testing.shares(_payees[i]), _shares[i]);
            assertEq(_testing.released(_payees[i]), 0);
            assertEq(_testing.payee(i), _payees[i]);
        }

        // test for releasable(address)
        assertEq(_testing.releasable(_payees[0]), 10000 * 20 / (20 + 30 + 50));
        assertEq(_testing.releasable(_payees[1]), 10000 * 30 / (20 + 30 + 50));
        assertEq(_testing.releasable(_payees[2]), 10000 * 50 / (20 + 30 + 50));

        // test for release(address payable)
        address account = _payees[0];
        uint amountReleased = 20 / (20 + 30 + 50) * 10000;
        assertEq(account.balance, 0);

        vm.expectEmit(address(_testing));
        emit PaymentReleased(account, amountReleased);
        _testing.release(payable(account));
        assertEq(account.balance, 0 + amountReleased);
        assertEq(address(_testing).balance, 10000 - amountReleased);

        // check getter
        assertEq(_testing.totalReleased(), 0 + amountReleased);
        assertEq(_testing.released(account), 0 + amountReleased);
        assertEq(_testing.releasable(account), 0);

        // transfer 1000 wei into contract
        uint additional = 1000;
        vm.expectEmit(address(_testing));
        emit PaymentReceived(address(this), additional);
        (bool ok,) = address(_testing).call{value: additional}("");
        assertTrue(ok);
        assertEq(address(_testing).balance, 10000 - amountReleased + additional);

        // check releasable(address)
        // full payment for _payees[1] && _payees[2]
        assertEq(_testing.releasable(_payees[1]), (10000 + additional) * 30 / (20 + 30 + 50));
        assertEq(_testing.releasable(_payees[2]), (10000 + additional) * 50 / (20 + 30 + 50));
        // payment only for additional eth
        assertEq(_testing.releasable(_payees[0]), additional * 20 / (20 + 30 + 50));

        // release all
        for (uint i; i < _payees.length; ++i) {
            _testing.release(payable(_payees[i]));
        }

        // check eth balances
        assertEq(address(_testing).balance, 0);
        assertEq(_testing.totalReleased(), 10000 + additional);

        for (uint i; i < _payees.length; ++i) {
            uint ethBalance = (10000 + additional) * _testing.shares(_payees[i]) / _testing.totalShares();
            assertEq(_payees[i].balance, ethBalance);
            assertEq(_testing.released(_payees[i]), ethBalance);
        }
    }

    event ERC20PaymentReleased(IERC20 indexed token, address to, uint amount);

    function test_releaseERC20() external {
        _erc20.mint(address(_testing), 10000);
        assertEq(_erc20.balanceOf(address(_testing)), 10000);
        // test for totalShares()
        assertEq(_testing.totalShares(), 20 + 30 + 50);
        // test for totalReleased(IERC20)
        assertEq(_testing.totalReleased(_erc20), 0);
        // test for shares() && released(IERC20,address) && payee() && releasable(IERC20,address)
        for (uint i; i < _payees.length; ++i) {
            assertEq(_testing.shares(_payees[i]), _shares[i]);
            assertEq(_testing.released(_erc20, _payees[i]), 0);
            assertEq(_testing.payee(i), _payees[i]);
        }

        // test for releasable(IERC20,address)
        assertEq(_testing.releasable(_erc20, _payees[0]), 10000 * 20 / (20 + 30 + 50));
        assertEq(_testing.releasable(_erc20, _payees[1]), 10000 * 30 / (20 + 30 + 50));
        assertEq(_testing.releasable(_erc20, _payees[2]), 10000 * 50 / (20 + 30 + 50));

        // test for release(IERC20,address)
        address account = _payees[0];
        uint amountReleased = 20 / (20 + 30 + 50) * 10000;
        assertEq(_erc20.balanceOf(account), 0);

        vm.expectEmit(address(_testing));
        emit ERC20PaymentReleased(_erc20, account, amountReleased);
        _testing.release(_erc20, account);
        assertEq(_erc20.balanceOf(account), 0 + amountReleased);
        assertEq(_erc20.balanceOf(address(_testing)), 10000 - amountReleased);

        // check getter
        assertEq(_testing.totalReleased(_erc20), 0 + amountReleased);
        assertEq(_testing.released(_erc20, account), 0 + amountReleased);
        assertEq(_testing.releasable(_erc20, account), 0);

        // transfer 1000 erc20 token into contract
        uint additional = 1000;
        _erc20.mint(address(_testing), additional);
        assertEq(_erc20.balanceOf(address(_testing)), 10000 - amountReleased + additional);

        // check releasable(IERC20,address)
        // full payment for _payees[1] && _payees[2]
        assertEq(_testing.releasable(_erc20, _payees[1]), (10000 + additional) * 30 / (20 + 30 + 50));
        assertEq(_testing.releasable(_erc20, _payees[2]), (10000 + additional) * 50 / (20 + 30 + 50));
        // payment only for additional erc20 token
        assertEq(_testing.releasable(_erc20, _payees[0]), additional * 20 / (20 + 30 + 50));

        // release all
        for (uint i; i < _payees.length; ++i) {
            _testing.release(_erc20, _payees[i]);
        }

        // check erc20 token balances
        assertEq(_erc20.balanceOf(address(_testing)), 0);
        assertEq(_testing.totalReleased(_erc20), 10000 + additional);

        for (uint i; i < _payees.length; ++i) {
            uint erc20TokenBalance = (10000 + additional) * _testing.shares(_payees[i]) / _testing.totalShares();
            assertEq(_erc20.balanceOf(_payees[i]), erc20TokenBalance);
            assertEq(_testing.released(_erc20, _payees[i]), erc20TokenBalance);
        }
    }
}
