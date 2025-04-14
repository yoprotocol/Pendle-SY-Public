// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "../PendleERC4626UpgSYV2.sol";
import "../../../../interfaces/FX/IFXBase.sol";

contract PendleFXSaveSY is PendleERC4626UpgSYV2 {
    address public constant FXSAVE = 0x7743e50F534a7f9F1791DdE7dCD89F7783Eefc39;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant FXUSD = 0x085780639CC2cACd35E474e71f4d000e2405d8f6;

    constructor() PendleERC4626UpgSYV2(FXSAVE) {}

    function initialize() external virtual initializer {
        __SYBaseUpg_init("SY f(x) USD Saving", "SY-fxSAVE");
        _safeApproveInf(asset, yieldToken);
        _safeApproveInf(USDC, asset);
        _safeApproveInf(FXUSD, asset);
    }

    function _deposit(
        address tokenIn,
        uint256 amountDeposited
    ) internal virtual override returns (uint256 /*amountSharesOut*/) {
        if (tokenIn == USDC || tokenIn == FXUSD) {
            (tokenIn, amountDeposited) = (asset, IFXBase(asset).deposit(address(this), USDC, amountDeposited, 0));
        }
        return super._deposit(tokenIn, amountDeposited);
    }

    function _previewDeposit(
        address tokenIn,
        uint256 amountTokenToDeposit
    ) internal view virtual override returns (uint256 /*amountSharesOut*/) {
        if (tokenIn == USDC || tokenIn == FXUSD) {
            (tokenIn, amountTokenToDeposit) = (asset, IFXBase(asset).previewDeposit(tokenIn, amountTokenToDeposit));
        }
        return super._previewDeposit(tokenIn, amountTokenToDeposit);
    }

    function getTokensIn() public view virtual override returns (address[] memory res) {
        return ArrayLib.create(asset, yieldToken, USDC, FXUSD);
    }

    function isValidTokenIn(address token) public view virtual override returns (bool) {
        return token == USDC || token == FXUSD || token == yieldToken || token == asset;
    }
}
