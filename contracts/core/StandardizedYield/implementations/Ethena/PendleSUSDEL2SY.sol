// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.17;

import "../PendleERC20SYUpg.sol";
import "../../../../interfaces/IPExchangeRateOracle.sol";
import "../../../../interfaces/IPTokenWithSupplyCap.sol";

contract PendleSUSDEL2SY is PendleERC20SYUpg, IPTokenWithSupplyCap {
    event SetNewExchangeRateOracle(address oracle);

    event SupplyCapUpdated(uint256 newSupplyCap);

    error SupplyCapExceeded(uint256 totalSupply, uint256 supplyCap);

    address public immutable usde;
    address public exchangeRateOracle;
    uint256 public supplyCap;

    constructor(address _susde, address _usde) PendleERC20SYUpg(_susde) {
        usde = _usde;
    }

    function initialize(uint256 _initialSupplyCap, address _initialExchangeRateOracle) external initializer {
        __SYBaseUpg_init("SY Ethena sUSDE", "SY-sUSDE");
        _setExchangeRateOracle(_initialExchangeRateOracle);
        _updateSupplyCap(_initialSupplyCap);
    }

    /*///////////////////////////////////////////////////////////////
                            EXCHANGE RATE ORACLE
    //////////////////////////////////////////////////////////////*/

    function exchangeRate() public view virtual override returns (uint256) {
        return IPExchangeRateOracle(exchangeRateOracle).getExchangeRate();
    }

    function setExchangeRateOracle(address _exchangeRateOracle) external onlyOwner {
        _setExchangeRateOracle(_exchangeRateOracle);
    }

    function _setExchangeRateOracle(address _exchangeRateOracle) internal {
        exchangeRateOracle = _exchangeRateOracle;
        emit SetNewExchangeRateOracle(_exchangeRateOracle);
    }

    /*///////////////////////////////////////////////////////////////
                            SUPPLY CAP LOGIC
    //////////////////////////////////////////////////////////////*/

    function _previewDeposit(
        address /*tokenIn*/,
        uint256 amountTokenToDeposit
    ) internal view override returns (uint256 /*amountSharesOut*/) {
        uint256 _newSupply = totalSupply() + amountTokenToDeposit;
        uint256 _supplyCap = supplyCap;

        if (_newSupply > _supplyCap) {
            revert SupplyCapExceeded(_newSupply, _supplyCap);
        }

        return amountTokenToDeposit;
    }

    function updateSupplyCap(uint256 newSupplyCap) external onlyOwner {
        _updateSupplyCap(newSupplyCap);
    }

    function _updateSupplyCap(uint256 newSupplyCap) internal {
        supplyCap = newSupplyCap;
        emit SupplyCapUpdated(newSupplyCap);
    }

    // @dev: whenNotPaused not needed as it has already been added to beforeTransfer
    function _afterTokenTransfer(address from, address, uint256) internal virtual override {
        // only check for minting case
        // saving gas on user->user transfers
        // skip supply cap checking on burn to allow lowering supply cap
        if (from != address(0)) {
            return;
        }

        uint256 _supply = totalSupply();
        uint256 _supplyCap = supplyCap;
        if (_supply > _supplyCap) {
            revert SupplyCapExceeded(_supply, _supplyCap);
        }
    }

    function getAbsoluteSupplyCap() external view returns (uint256) {
        return supplyCap;
    }

    function getAbsoluteTotalSupply() external view returns (uint256) {
        return totalSupply();
    }

    function assetInfo()
        external
        view
        virtual
        override
        returns (AssetType assetType, address assetAddress, uint8 assetDecimals)
    {
        return (AssetType.TOKEN, usde, IERC20Metadata(usde).decimals());
    }
}
