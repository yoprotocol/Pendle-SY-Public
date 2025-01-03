// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.23;

import "../PendleERC20SYUpg.sol";
import "../../../../interfaces/EtherFi/IVedaTeller.sol";
import "../../../../interfaces/EtherFi/IVedaAccountant.sol";

abstract contract PendleVedaBaseSY is PendleERC20SYUpg {
    using PMath for uint256;

    // solhint-disable immutable-vars-naming
    // solhint-disable const-name-snakecase
    // solhint-disable ordering

    address public immutable vedaTeller;
    address public immutable vedaAccountant;

    constructor(address _boringVault, address _vedaTeller) PendleERC20SYUpg(_boringVault) {
        vedaTeller = _vedaTeller;
        vedaAccountant = IVedaTeller(_vedaTeller).accountant();
    }

    function _deposit(
        address tokenIn,
        uint256 amountDeposited
    ) internal virtual override returns (uint256 /*amountSharesOut*/) {
        if (tokenIn == yieldToken) {
            return amountDeposited;
        }
        return IVedaTeller(vedaTeller).deposit(tokenIn, amountDeposited, 0);
    }

    function _previewDeposit(
        address tokenIn,
        uint256 amountTokenToDeposit
    ) internal view virtual override returns (uint256 amountSharesOut) {
        if (tokenIn == yieldToken) {
            return amountTokenToDeposit;
        }
        uint256 rate = IVedaAccountant(vedaAccountant).getRateInQuoteSafe(tokenIn);
        amountSharesOut = amountTokenToDeposit.divDown(rate);
    }
}
