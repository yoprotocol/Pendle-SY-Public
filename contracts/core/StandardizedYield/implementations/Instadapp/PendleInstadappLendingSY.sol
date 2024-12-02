// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "../../SYBaseWithRewardsUpg.sol";
import "../../../../interfaces/IERC4626.sol";
import "../../../../interfaces/Instadapp/IInstadappStakingRewards.sol";

contract PendleInstadappLendingSY is SYBaseWithRewardsUpg {
    using PMath for uint256;

    address public constant LIQUIDITY = 0x52Aa899454998Be5b000Ad077a46Bbe360F4e497;
    address public constant INST = 0x6f40d4A6237C257fff2dB00FA0510DeEECd303eb;

    // solhint-disable immutable-vars-naming
    address public immutable stakingRewards;
    address public immutable asset;

    constructor(address _stakingRewards) SYBaseUpg(IInstadappStakingRewards(_stakingRewards).stakingToken()) {
        stakingRewards = _stakingRewards;
        asset = IERC4626(yieldToken).asset();
    }

    function initialize(string memory _name, string memory _symbol) external initializer {
        __SYBaseUpg_init(_name, _symbol);
        _safeApproveInf(asset, LIQUIDITY);
        _safeApproveInf(yieldToken, stakingRewards);
    }

    function _deposit(
        address tokenIn,
        uint256 amountDeposited
    ) internal virtual override returns (uint256 /*amountSharesOut*/) {
        uint256 amountToStake;
        if (tokenIn == yieldToken) {
            amountToStake = amountDeposited;
        } else {
            amountToStake = IERC4626(yieldToken).deposit(amountDeposited, address(this));
        }
        IInstadappStakingRewards(stakingRewards).stake(amountToStake);
        return amountToStake;
    }

    function _redeem(
        address receiver,
        address tokenOut,
        uint256 amountSharesToRedeem
    ) internal override returns (uint256 amountTokenOut) {
        IInstadappStakingRewards(stakingRewards).withdraw(amountSharesToRedeem);
        if (tokenOut == yieldToken) {
            amountTokenOut = amountSharesToRedeem;
            _transferOut(yieldToken, receiver, amountTokenOut);
        } else {
            amountTokenOut = IERC4626(yieldToken).redeem(amountSharesToRedeem, receiver, address(this));
        }
    }

    function exchangeRate() public view virtual override returns (uint256) {
        return IERC4626(yieldToken).convertToAssets(PMath.ONE);
    }

    function _previewDeposit(
        address tokenIn,
        uint256 amountTokenToDeposit
    ) internal view override returns (uint256 /*amountSharesOut*/) {
        if (tokenIn == yieldToken) return amountTokenToDeposit;
        else return IERC4626(yieldToken).previewDeposit(amountTokenToDeposit);
    }

    function _previewRedeem(
        address tokenOut,
        uint256 amountSharesToRedeem
    ) internal view override returns (uint256 /*amountTokenOut*/) {
        if (tokenOut == yieldToken) return amountSharesToRedeem;
        else return IERC4626(yieldToken).previewRedeem(amountSharesToRedeem);
    }

    function getTokensIn() public view override returns (address[] memory res) {
        res = new address[](2);
        res[0] = asset;
        res[1] = yieldToken;
    }

    function getTokensOut() public view override returns (address[] memory res) {
        res = new address[](2);
        res[0] = asset;
        res[1] = yieldToken;
    }

    function isValidTokenIn(address token) public view override returns (bool) {
        return token == yieldToken || token == asset;
    }

    function isValidTokenOut(address token) public view override returns (bool) {
        return token == yieldToken || token == asset;
    }

    function assetInfo() external view returns (AssetType assetType, address assetAddress, uint8 assetDecimals) {
        return (AssetType.TOKEN, asset, IERC20Metadata(asset).decimals());
    }

    /*///////////////////////////////////////////////////////////////
                               REWARDS-RELATED
    //////////////////////////////////////////////////////////////*/

    function _getRewardTokens() internal pure override returns (address[] memory res) {
        return ArrayLib.create(INST);
    }

    function _redeemExternalReward() internal override {
        IInstadappStakingRewards(stakingRewards).getReward();
    }
}
