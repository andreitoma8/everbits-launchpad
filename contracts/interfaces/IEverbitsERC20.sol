// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// TODO: Token should have restrictions for transfers and fees
interface IEverbitsERC20 is IERC20 {
    function mint(address to, uint256 amount) external;
}
