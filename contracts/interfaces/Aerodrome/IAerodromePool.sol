// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

interface IAerodromePool {
    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint256 _reserve0, uint256 _reserve1, uint256 _blockTimestampLast);

    function factory() external view returns (address);

    function totalSupply() external view returns (uint256);
}
