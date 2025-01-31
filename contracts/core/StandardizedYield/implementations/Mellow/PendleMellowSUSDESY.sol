// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./PendleMellowVaultERC4626SYUpg.sol";

contract PendleMellowSUSDESY is PendleMellowVaultERC4626SYUpg {
    constructor(
        address _erc4626,
        address _vault,
        uint256 _interfaceVersion
    ) PendleMellowVaultERC4626SYUpg(_erc4626, _vault, _interfaceVersion) {}

    function exchangeRate() public view virtual override returns (uint256 res) {
        uint256 rateMellow = IERC4626(erc4626).convertToAssets(PMath.ONE);
        assert(rateMellow == PMath.ONE);
        return IERC4626(erc4626).convertToAssets(rateMellow);
    }
}
