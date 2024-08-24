// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Oracle.sol";

contract DynamicFee {
    Oracle public priceOracle;
    uint256 public baseFee; // e.g., 0.3% fee as 3000 in basis points (bps)
    uint256 public minFee;   // Minimum fee limit
    uint256 public maxFee;   // Maximum fee limit
    uint256 public volatilityFactor; // Determines how much volatility impacts the fee

    event FeeAdjusted(uint256 newFee);

    constructor(address oracleAddress, uint256 _baseFee, uint256 _minFee, uint256 _maxFee, uint256 _volatilityFactor) {
        priceOracle = Oracle(oracleAddress);
        baseFee = _baseFee;
        minFee = _minFee;
        maxFee = _maxFee;
        volatilityFactor = _volatilityFactor;
    }

    function adjustFee(string memory tokenPair) external {
        uint256 volatility = getVolatility(tokenPair);
        uint256 newFee = baseFee + (volatility * volatilityFactor);

        if (newFee > maxFee) {
            newFee = maxFee;
        } else if (newFee < minFee) {
            newFee = minFee;
        }

        baseFee = newFee;
        emit FeeAdjusted(newFee);
    }

    function getVolatility(string memory tokenPair) internal view returns (uint256) {
        // Retrieve price volatility for the token pair from the oracle
        // This is a simplified example, in practice you'd calculate historical price deviations
        uint256 price = priceOracle.getPrice(tokenPair);
        uint256 volatility = (price * 10) / 100; // Example: 10% of the current price
        return volatility;
    }

    function getTradingFee() external view returns (uint256) {
        return baseFee;
    }
}
