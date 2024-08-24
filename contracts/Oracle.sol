// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Oracle {
    address public admin;
    mapping(string => uint256) public prices;

    event PriceUpdated(string asset, uint256 price);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not an admin");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    function setPrice(string memory asset, uint256 price) external onlyAdmin {
        prices[asset] = price;
        emit PriceUpdated(asset, price);
    }

    function getPrice(string memory asset) external view returns (uint256) {
        return prices[asset];
    }
}
