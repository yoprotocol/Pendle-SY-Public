// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.23;

import "../PendleERC4626UpgSYV2.sol";
import "../../../../interfaces/EtherFi/IVedaTeller.sol";

contract PendlePaladinSCTokenSY is PendleERC4626UpgSYV2 {
    address public immutable rawToken;
    address public immutable teller;

    constructor(address _rawToken, address _teller, address _wscToken) PendleERC4626UpgSYV2(_wscToken) {
        rawToken = _rawToken;
        teller = _teller;
    }

    function initialize(string memory _name, string memory _symbol) external override initializer {
        __SYBaseUpg_init(_name, _symbol);
        _safeApproveInf(rawToken, teller);
        _safeApproveInf(asset, yieldToken);
    }

    function _deposit(
        address tokenIn,
        uint256 amountDeposited
    ) internal virtual override returns (uint256 /*amountSharesOut*/) {
        if (tokenIn == rawToken) {
            (tokenIn, amountDeposited) = (asset, IVedaTeller(teller).deposit(rawToken, amountDeposited, 0));
        }
        return super._deposit(tokenIn, amountDeposited);
    }

    function getTokensIn() public view virtual override returns (address[] memory res) {
        return ArrayLib.create(rawToken, asset, yieldToken);
    }

    function isValidTokenIn(address token) public view virtual override returns (bool) {
        return token == rawToken || token == yieldToken || token == asset;
    }
}
