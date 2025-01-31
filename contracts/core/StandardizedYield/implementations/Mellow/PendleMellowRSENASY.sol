// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./PendleMellowVaultERC20SYUpg.sol";

contract PEndleMellowRSENASY is PendleMellowVaultERC20SYUpg {
    constructor(
        address _depositToken,
        address _vault,
        uint256 _interfaceVersion
    ) PendleMellowVaultERC20SYUpg(_depositToken, _vault, _interfaceVersion) {}

    function exchangeRate() public view virtual override returns (uint256 res) {
        return PMath.ONE;
    }

    function getTokensIn() public view virtual override returns (address[] memory res) {
        return ArrayLib.create(vault);
    }

    function isValidTokenIn(address token) public view virtual override returns (bool) {
        return token == vault;
    }
}
