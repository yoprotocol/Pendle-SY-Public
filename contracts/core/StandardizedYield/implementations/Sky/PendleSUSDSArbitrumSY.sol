// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../../SYBaseUpg.sol";
import "../../../../interfaces/Sky/ISkyPSM3.sol";

contract PendleSUSDSArbitrumSY is SYBaseUpg {
    address public constant USDS = 0x6491c05A82219b8D1479057361ff1654749b876b;
    address public constant USDC = 0xaf88d065e77c8cC2239327C5EDb3A432268e5831;
    address public constant SUSDS = 0xdDb46999F8891663a8F2828d25298f70416d7610;
    address public constant PSM = 0x2B05F8e1cACC6974fD79A673a341Fe1f58d27266;

    constructor() SYBaseUpg(SUSDS) {}

    function initialize() external initializer {
        __SYBaseUpg_init("SY Savings USDS", "SY-sUSDS");
        _safeApproveInf(USDS, PSM);
        _safeApproveInf(USDC, PSM);
    }

    function _deposit(
        address tokenIn,
        uint256 amountDeposited
    ) internal virtual override returns (uint256 /*amountSharesOut*/) {
        if (tokenIn != SUSDS) {
            return ISkyPSM3(PSM).swapExactIn(tokenIn, SUSDS, amountDeposited, 0, address(this), 0);
        } else {
            return amountDeposited;
        }
    }

    function _redeem(
        address receiver,
        address tokenOut,
        uint256 amountSharesToRedeem
    ) internal virtual override returns (uint256 amountTokenOut) {
        if (tokenOut != SUSDS) {
            return ISkyPSM3(PSM).swapExactIn(SUSDS, tokenOut, amountSharesToRedeem, 0, receiver, 0);
        } else {
            return amountSharesToRedeem;
        }
    }

    function exchangeRate() public view virtual override returns (uint256) {
        return ISkyPSM3(PSM).convertToAssetValue(1e18);
    }

    function _previewDeposit(
        address tokenIn,
        uint256 amountTokenToDeposit
    ) internal view virtual override returns (uint256 /*amountSharesOut*/) {
        if (tokenIn == SUSDS) return amountTokenToDeposit;
        return ISkyPSM3(PSM).previewSwapExactIn(tokenIn, SUSDS, amountTokenToDeposit);
    }

    function _previewRedeem(
        address tokenOut,
        uint256 amountSharesToRedeem
    ) internal view override returns (uint256 /*amountTokenOut*/) {
        if (tokenOut == SUSDS) return amountSharesToRedeem;
        return ISkyPSM3(PSM).previewSwapExactIn(SUSDS, tokenOut, amountSharesToRedeem);
    }

    function getTokensIn() public view virtual override returns (address[] memory res) {
        return ArrayLib.create(USDC, USDS, SUSDS);
    }

    function getTokensOut() public view virtual override returns (address[] memory res) {
        return ArrayLib.create(USDC, USDS, SUSDS);
    }

    function isValidTokenIn(address token) public view virtual override returns (bool) {
        return token == USDC || token == USDS || token == SUSDS;
    }

    function isValidTokenOut(address token) public view virtual override returns (bool) {
        return token == USDC || token == USDS || token == SUSDS;
    }

    function assetInfo()
        external
        view
        virtual
        returns (AssetType assetType, address assetAddress, uint8 assetDecimals)
    {
        return (AssetType.TOKEN, USDS, 18);
    }
}
