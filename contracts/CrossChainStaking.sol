// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MultiTokenPool {
    using SafeERC20 for IERC20;

    mapping(address => uint256) public totalPoolLiquidity;
    address[] public supportedTokens;

    event LiquidityAdded(address indexed provider, address token, uint256 amount);

    constructor(address[] memory _tokens) {
        supportedTokens = _tokens;
    }

    function addLiquidity(address token, uint256 amount) external {
        require(isSupportedToken(token), "Token not supported");
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        totalPoolLiquidity[token] += amount;
        emit LiquidityAdded(msg.sender, token, amount);
    }

    function isSupportedToken(address token) internal view returns (bool) {
        for (uint i = 0; i < supportedTokens.length; i++) {
            if (supportedTokens[i] == token) {
                return true;
            }
        }
        return false;
    }
}
