// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../../../../../src/token/ERC20/extensions/MockERC4626.sol";
import "./MockERC20.sol";

contract ERC4626Test is Test {
    MockERC20WithDecimals private _asset = new MockERC20WithDecimals("test name", "test symbol", 6);
    MockERC4626 private _testing = new MockERC4626("test name", "test symbol", _asset);
    address private receiver = address(1);

    function setUp() external {
        _asset.mint(address(this), 100);
    }

    function test_Constructor() external {
        // case 1: asset with uint8 decimal
        assertEq(_testing.decimals(), 6);
        assertEq(_testing.asset(), address(_asset));

        // case 2: asset with decimal that > type(uint8).max
        MockERC20WithLargeDecimals _assetWithLargeDecimals = new MockERC20WithLargeDecimals();
        _testing = new MockERC4626("test name", "test symbol", IERC20(address(_assetWithLargeDecimals)));
        // default decimals 18 of shares with a large decimal on asset
        assertEq(_testing.decimals(), 18);
        assertEq(_testing.asset(), address(_assetWithLargeDecimals));

        // case 3: asset without {decimals}
        MockERC20WithoutDecimals _assetWithoutDecimals = new MockERC20WithoutDecimals();
        _testing = new MockERC4626("test name", "test symbol", IERC20(address(_assetWithoutDecimals)));
        // default decimals 18 of shares without decimals() in asset
        assertEq(_testing.decimals(), 18);
        assertEq(_testing.asset(), address(_assetWithoutDecimals));
    }

    function test_MaxDeposit() external {
        // case 1: asset && shares total supply == 0
        assertEq(_testing.totalAssets(), 0);
        assertEq(_testing.totalSupply(), 0);
        assertEq(_testing.maxDeposit(receiver), type(uint256).max);

        // case 2: asset > 0 && total supply > 0
        _asset.approve(address(_testing), 10);
        _testing.deposit(10, receiver);
        assertEq(_testing.totalAssets(), 10);
        assertEq(_testing.totalSupply(), 10);
        assertEq(_testing.maxDeposit(receiver), type(uint256).max);

        // case 3: asset == 0 && total supply > 0
        _testing.transferAsset(receiver, 10);
        assertEq(_testing.totalAssets(), 0);
        assertEq(_testing.totalSupply(), 10);
        assertEq(_testing.maxDeposit(receiver), 0);

        // case 4: asset > 0 && total supply == 0
        _testing.burn(receiver, 10);
        _asset.transfer(address(_testing), 10);
        assertEq(_testing.totalAssets(), 10);
        assertEq(_testing.totalSupply(), 0);
        assertEq(_testing.maxDeposit(receiver), type(uint256).max);
    }

    function test_DepositAndAndPreviewDeposit() external {
        // case 1: asset && shares total supply == 0
        assertEq(_testing.totalAssets(), 0);
        assertEq(_testing.totalSupply(), 0);
        // deposit 0
        uint assetToDeposit = 0;
        uint sharesToMint = assetToDeposit;
        assertEq(_testing.previewDeposit(assetToDeposit), sharesToMint);
        assertEq(_testing.deposit(assetToDeposit, receiver), sharesToMint);
        assertEq(_testing.totalAssets(), assetToDeposit);
        assertEq(_testing.totalSupply(), sharesToMint);
        assertEq(_testing.balanceOf(receiver), sharesToMint);
        // deposit some
        assetToDeposit = 20;
        sharesToMint = assetToDeposit;
        assertEq(_testing.previewDeposit(assetToDeposit), sharesToMint);
        _asset.approve(address(_testing), assetToDeposit);
        assertEq(_testing.deposit(assetToDeposit, receiver), sharesToMint);
        assertEq(_testing.totalAssets(), assetToDeposit);
        assertEq(_testing.totalSupply(), sharesToMint);
        assertEq(_testing.balanceOf(receiver), sharesToMint);

        // case 2: asset > 0 && total supply > 0
        // deposit 0
        assetToDeposit = 0;
        sharesToMint = assetToDeposit;
        assertEq(_testing.previewDeposit(assetToDeposit), sharesToMint);
        assertEq(_testing.deposit(assetToDeposit, receiver), sharesToMint);
        assertEq(_testing.totalAssets(), 20 + assetToDeposit);
        assertEq(_testing.totalSupply(), 20 + sharesToMint);
        assertEq(_testing.balanceOf(receiver), 20 + sharesToMint);
        // deposit some
        assetToDeposit = 22;
        sharesToMint = assetToDeposit * _testing.totalSupply() / _testing.totalAssets();
        assertEq(_testing.previewDeposit(assetToDeposit), sharesToMint);
        _asset.approve(address(_testing), assetToDeposit);
        assertEq(_testing.deposit(assetToDeposit, receiver), sharesToMint);
        assertEq(_testing.totalAssets(), 20 + assetToDeposit);
        assertEq(_testing.totalSupply(), 20 + sharesToMint);
        assertEq(_testing.balanceOf(receiver), 20 + sharesToMint);

        // case 3: asset == 0 && total supply > 0
        _testing.transferAsset(receiver, 42);
        assertEq(_testing.totalAssets(), 0);
        assertEq(_testing.totalSupply(), 42);
        // deposit 0
        assetToDeposit = 0;
        sharesToMint = assetToDeposit;
        assertEq(_testing.previewDeposit(assetToDeposit), sharesToMint);
        assertEq(_testing.deposit(assetToDeposit, receiver), sharesToMint);
        assertEq(_testing.totalAssets(), 0 + assetToDeposit);
        assertEq(_testing.totalSupply(), 42 + sharesToMint);
        assertEq(_testing.balanceOf(receiver), 42 + sharesToMint);
        // deposit some
        // revert for division by 0
        assetToDeposit = 21;
        vm.expectRevert();
        _testing.previewDeposit(assetToDeposit);
        vm.expectRevert("ERC4626: deposit more than max");
        _testing.deposit(assetToDeposit, receiver);

        // case 4: asset > 0 && total supply == 0
        _asset.transfer(address(_testing), 20);
        _testing.burn(receiver, 42);
        assertEq(_testing.totalAssets(), 20);
        assertEq(_testing.totalSupply(), 0);
        // deposit 0
        assetToDeposit = 0;
        sharesToMint = assetToDeposit;
        assertEq(_testing.previewDeposit(assetToDeposit), sharesToMint);
        assertEq(_testing.deposit(assetToDeposit, receiver), sharesToMint);
        assertEq(_testing.totalAssets(), 20 + assetToDeposit);
        assertEq(_testing.totalSupply(), 0 + sharesToMint);
        assertEq(_testing.balanceOf(receiver), 0 + sharesToMint);
        // deposit some
        assetToDeposit = 15;
        sharesToMint = assetToDeposit;
        assertEq(_testing.previewDeposit(assetToDeposit), sharesToMint);
        _asset.approve(address(_testing), assetToDeposit);
        assertEq(_testing.deposit(assetToDeposit, receiver), sharesToMint);
        assertEq(_testing.totalAssets(), 20 + assetToDeposit);
        assertEq(_testing.totalSupply(), 0 + sharesToMint);
        assertEq(_testing.balanceOf(receiver), 0 + sharesToMint);
    }

    function test_MaxMintAndMintAndPreviewMint() external {
        // case 1: total supply == 0
        assertEq(_testing.totalSupply(), 0);
        assertEq(_testing.maxMint(receiver), type(uint).max);
        // 1 asset 1 share
        uint sharesToMint = 15;
        uint assetToDeposit = sharesToMint;
        assertEq(_testing.previewMint(sharesToMint), assetToDeposit);
        _asset.approve(address(_testing), assetToDeposit);
        assertEq(_testing.mint(sharesToMint, receiver), assetToDeposit);

        assertEq(_testing.totalAssets(), 0 + 15);
        assertEq(_testing.totalSupply(), 0 + sharesToMint);
        assertEq(_testing.balanceOf(receiver), sharesToMint);

        // case 2: total supply != 0
        assertEq(_testing.maxMint(receiver), type(uint).max);
        sharesToMint = 10;
        assetToDeposit = sharesToMint * _testing.totalAssets() / _testing.totalSupply();
        assertEq(_testing.previewMint(sharesToMint), assetToDeposit);
        _asset.approve(address(_testing), 10);
        assertEq(_testing.mint(sharesToMint, receiver), assetToDeposit);
        assertEq(_testing.totalAssets(), 15 + assetToDeposit);
        assertEq(_testing.totalSupply(), 15 + sharesToMint);
        assertEq(_testing.balanceOf(receiver), 15 + sharesToMint);
    }

    function test_MaxWithdraw() external {
        // case 1: total supply == 0
        assertEq(_testing.totalSupply(), 0);
        assertEq(_testing.maxWithdraw(receiver), 0);

        // case 2: total supply != 0
        _asset.approve(address(_testing), 10);
        _testing.deposit(10, receiver);
        assertEq(_testing.totalSupply(), 10);
        assertEq(
            _testing.maxWithdraw(receiver),
            _testing.balanceOf(receiver) * _testing.totalAssets() / _testing.totalSupply()
        );
    }

    function test_WithdrawAndPreviewWithdraw() external {
        // case 1: asset && shares total supply == 0
        // withdraw 0 asset
        uint assetsToWithdraw = 0;
        uint sharesToBurn = assetsToWithdraw;
        assertEq(_testing.previewWithdraw(assetsToWithdraw), 0);
        assertEq(_testing.withdraw(assetsToWithdraw, receiver, address(this)), sharesToBurn);
        assertEq(_testing.totalSupply(), 0);
        assertEq(_testing.totalAssets(), 0);
        assertEq(_testing.balanceOf(address(this)), 0);
        assertEq(_asset.balanceOf(receiver), 0);
        // withdraw some asset
        assetsToWithdraw = 10;
        assertEq(_testing.previewWithdraw(assetsToWithdraw), 10);
        vm.expectRevert("ERC4626: withdraw more than max");
        _testing.withdraw(assetsToWithdraw, receiver, address(this));

        // case 2: asset > 0 && total supply > 0
        _asset.approve(address(_testing), 20);
        _testing.deposit(20, receiver);
        assertEq(_testing.totalSupply(), 20);
        assertEq(_testing.totalAssets(), 20);
        assertEq(_testing.balanceOf(receiver), 20);
        assertEq(_asset.balanceOf(receiver), 0);

        assetsToWithdraw = 10;
        sharesToBurn = assetsToWithdraw * _testing.totalSupply() / _testing.totalAssets();
        assertEq(_testing.previewWithdraw(assetsToWithdraw), sharesToBurn);

        vm.prank(receiver);
        assertEq(_testing.withdraw(assetsToWithdraw, receiver, receiver), sharesToBurn);
        assertEq(_testing.totalSupply(), 20 - assetsToWithdraw);
        assertEq(_testing.totalAssets(), 20 - assetsToWithdraw);
        assertEq(_testing.balanceOf(receiver), 20 - sharesToBurn);
        assertEq(_asset.balanceOf(receiver), 0 + assetsToWithdraw);

        // msg.sender is not the owner
        assetsToWithdraw = 2;
        sharesToBurn = assetsToWithdraw * _testing.totalSupply() / _testing.totalAssets();
        assertEq(_testing.previewWithdraw(assetsToWithdraw), sharesToBurn);

        vm.prank(receiver);
        _testing.approve(address(this), assetsToWithdraw);
        assertEq(_testing.withdraw(assetsToWithdraw, receiver, receiver), sharesToBurn);
        assertEq(_testing.totalSupply(), 20 - 10 - assetsToWithdraw);
        assertEq(_testing.totalAssets(), 20 - 10 - assetsToWithdraw);
        assertEq(_testing.balanceOf(receiver), 20 - 10 - sharesToBurn);
        assertEq(_asset.balanceOf(receiver), 0 + 10 + assetsToWithdraw);

        // revert if withdraw more asset
        assetsToWithdraw = _testing.maxWithdraw(receiver) + 1;
        vm.expectRevert("ERC4626: withdraw more than max");
        vm.prank(receiver);
        _testing.withdraw(assetsToWithdraw, receiver, receiver);

        // case 3: asset == 0 && total supply > 0
        _testing.transferAsset(address(this), _testing.totalAssets());
        assertEq(_testing.totalAssets(), 0);
        assertEq(_testing.totalSupply(), 8);
        assertEq(_testing.balanceOf(receiver), 8);
        assertEq(_asset.balanceOf(receiver), 12);
        // revert if without any
        assetsToWithdraw = 1;
        vm.expectRevert();
        _testing.previewWithdraw(assetsToWithdraw);
        vm.expectRevert();
        _testing.withdraw(assetsToWithdraw, receiver, receiver);

        // case 4: asset > 0 && total supply == 0
        _asset.mint(address(_testing), 20);
        _testing.burn(receiver, 8);
        assertEq(_testing.totalAssets(), 20);
        assertEq(_testing.totalSupply(), 0);
        assertEq(_testing.balanceOf(receiver), 0);
        assertEq(_asset.balanceOf(receiver), 12);

        assetsToWithdraw = 3;
        sharesToBurn = assetsToWithdraw;
        assertEq(_testing.previewWithdraw(assetsToWithdraw), sharesToBurn);

        // revert if withdraw any
        vm.expectRevert("ERC4626: withdraw more than max");
        _testing.withdraw(assetsToWithdraw, receiver, receiver);
    }

    function test_MaxRedeemAndRedeemAndPreviewRedeem() external {
        // case 1: total supply == 0
        assertEq(_testing.totalSupply(), 0);
        assertEq(_testing.maxRedeem(receiver), _testing.balanceOf(receiver));
        // 1 asset 1 share
        uint sharesToBurn = 1;
        uint assetToRedeem = sharesToBurn;
        assertEq(_testing.previewRedeem(sharesToBurn), assetToRedeem);
        // revert if redeem any
        vm.expectRevert("ERC4626: redeem more than max");
        vm.prank(receiver);
        _testing.redeem(sharesToBurn, receiver, receiver);

        // case 2: total supply != 0
        _asset.approve(address(_testing), 50);
        _testing.deposit(50, receiver);
        assertEq(_testing.totalAssets(), 50);
        assertEq(_testing.totalSupply(), 50);
        assertEq(_testing.balanceOf(receiver), 50);
        assertEq(_asset.balanceOf(receiver), 0);

        assertEq(_testing.maxRedeem(receiver), _testing.balanceOf(receiver));
        sharesToBurn = 20;
        assetToRedeem = sharesToBurn * _testing.totalAssets() / _testing.totalSupply();
        assertEq(_testing.previewRedeem(sharesToBurn), assetToRedeem);

        vm.prank(receiver);
        assertEq(_testing.redeem(sharesToBurn, receiver, receiver), assetToRedeem);
        assertEq(_testing.totalAssets(), 50 - assetToRedeem);
        assertEq(_testing.totalSupply(), 50 - sharesToBurn);
        assertEq(_testing.balanceOf(receiver), 50 - sharesToBurn);
        assertEq(_asset.balanceOf(receiver), assetToRedeem);

        // revert if redeem more
        sharesToBurn = _testing.maxRedeem(receiver) + 1;
        vm.expectRevert("ERC4626: redeem more than max");
        _testing.redeem(sharesToBurn, receiver, receiver);
    }

    function test_AssetAndTotalAssetsAndConvertToSharesAndConvertToAssets() external {
        // test {asset}
        assertEq(_testing.asset(), address(_asset));

        // total supply == 0
        // test {convertToShares}
        assertEq(_testing.totalSupply(), 0);
        for (uint assets = 0; assets < 100; ++assets) {
            assertEq(_testing.convertToShares(assets), assets);
        }
        // test {convertToAssets}
        for (uint shares = 0; shares < 100; ++shares) {
            assertEq(_testing.convertToAssets(shares), shares);

        }

        // total supply != 0
        _asset.approve(address(_testing), 50);
        _testing.deposit(50, receiver);
        assertEq(_testing.totalSupply(), 50);
        // test {totalAssets}
        assertEq(_testing.totalAssets(), 50);
        // test {convertToShares}
        for (uint assets = 1; assets < 100; ++assets) {
            assertEq(_testing.convertToShares(assets), assets * _testing.totalSupply() / _testing.totalAssets());
        }
        // test {convertToAssets}
        for (uint shares = 1; shares < 100; ++shares) {
            assertEq(_testing.convertToAssets(shares), shares * _testing.totalAssets() / _testing.totalSupply());
        }
    }
}