// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.23;

import "./PendleConcreteVaultSY.sol";
import "../../../../interfaces/Solv/ISolvRouterV2.sol";
import "../../../../interfaces/Solv/ISolvOpenFundMarket.sol";
import "../../../../interfaces/Solv/ISolvERC3525.sol";
import "../../../../interfaces/Solv/ISolvOracle.sol";

contract PendleConcreteSolvBTCBBNSY is PendleConcreteVaultSY {
    constructor(address _concreteVault) PendleConcreteVaultSY(0x5a35b8817cB92dCd7196B243351f018C4982C010) {}

    address public constant SOLV_BTC_ROUTER_V2 = 0x3d93B9e8F0886358570646dAd9421564C5fE6334;
    address public constant SOLV_OPEN_FUND_MARKET = 0x57bB6a8563a8e8478391C79F3F433C6BA077c567;

    address public constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address public constant SOLV_BTC = 0x7A56E1C57C7475CCf742a1832B028F0456652F97;
    address public constant SOLV_BBN_BTC = 0xd9D920AA40f578ab794426F5C90F6C731D159DEf;

    address[] internal FULL_PATH;
    function initialize(string memory _name, string memory _symbol) external override initializer {
        __SYBaseUpg_init(_name, _symbol);
        _safeApproveInf(WBTC, SOLV_BTC_ROUTER_V2);
        _safeApproveInf(SOLV_BTC, SOLV_BTC_ROUTER_V2);
        _safeApproveInf(SOLV_BBN_BTC, SOLV_BTC_ROUTER_V2);
        _safeApproveInf(asset, yieldToken);
        FULL_PATH = ArrayLib.create(WBTC, SOLV_BTC, SOLV_BBN_BTC);
    }

    function _deposit(address tokenIn, uint256 amountDeposited) internal virtual override returns (uint256) {
        if (tokenIn != yieldToken && tokenIn != asset) {
            (tokenIn, amountDeposited) = (
                asset,
                ISolvRouterV2(SOLV_BTC_ROUTER_V2).deposit(yieldToken, tokenIn, amountDeposited)
            );
        }
        return super._deposit(tokenIn, amountDeposited);
    }

    function _previewDeposit(
        address tokenIn,
        uint256 amountTokenToDeposit
    ) internal view virtual override returns (uint256 /*amountSharesOut*/) {
        if (tokenIn == yieldToken) {
            return amountTokenToDeposit;
        }

        for (uint256 i = 0; i + 1 < FULL_PATH.length; ++i) {
            if (tokenIn == FULL_PATH[i]) {
                address nxtToken = FULL_PATH[i + 1];
                bytes32 poolId = ISolvRouterV2(SOLV_BTC_ROUTER_V2).poolIds(nxtToken, tokenIn);
                (tokenIn, amountTokenToDeposit) = (nxtToken, _previewSolvConvert(poolId, amountTokenToDeposit));
            }
        }
        assert(tokenIn == asset);
        return IERC4626(yieldToken).previewDeposit(amountTokenToDeposit);
    }

    function _previewSolvConvert(bytes32 poolId, uint256 amountIn) internal view returns (uint256) {
        ISolvOpenFundMarket.PoolInfo memory info = ISolvOpenFundMarket(SOLV_OPEN_FUND_MARKET).poolInfos(poolId);
        uint256 numerator = 10 ** ISolvERC3525(info.poolSFTInfo.openFundShare).valueDecimals();
        (uint256 price, ) = ISolvOracle(info.navOracle).getSubscribeNav(poolId, block.timestamp);
        return (amountIn * numerator) / price;
    }
}
