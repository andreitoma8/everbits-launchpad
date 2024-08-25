// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct MemeSustainedLaunch {
    string name;
    string symbol;
    uint256 totalSupply;
    uint256 idoSupply;
    address owner;
    bool launched;
}

struct StandardIDOParams {
    string name;
    string symbol;
    uint256 totalSupply;
    uint256 idoSupply;
    uint256 liquidityPercentage;
    uint256 softCap;
    uint256 hardCap;
    uint256 startTimestamp;
    uint256 endTimestamp;
    uint256 liquidityLockDuration;
}

interface ILaunchpadFactory {
    function getEverbitsTreasury() external view returns (address);
}
