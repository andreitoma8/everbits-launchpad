// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./interfaces/IUniswapV2Router02.sol";
import "./EverbitsERC20.sol";
import "./interfaces/IEverbitsERC20.sol";
import "./EverbitsIDO.sol";
import "./interfaces/ILaunchpadFactory.sol";

contract LaunchpadFactory is Ownable, ILaunchpadFactory {
    event MemeSustainedLaunchRequested(uint256 _id);
    event MemeSustainedLaunchExecuted(uint256 _id, address _token);
    event StandardIDOCreated(address _ido);

    IUniswapV2Router02 public uniswapV2Router;

    uint256 public memeSustainedLaunchCount;

    address public everbitsTreasury;

    mapping(uint256 => MemeSustainedLaunch) public memeSustainedLaunches;

    constructor(
        address _uinswapV2Router,
        address _everbitsTreasury
    ) Ownable(msg.sender) {
        uniswapV2Router = IUniswapV2Router02(_uinswapV2Router);
        everbitsTreasury = _everbitsTreasury;
    }

    function createMemeSustainedLaunch(
        string calldata name,
        string calldata symbol,
        uint256 totalSupply,
        uint256 idoSupply
    ) external {
        memeSustainedLaunches[memeSustainedLaunchCount] = MemeSustainedLaunch({
            name: name,
            symbol: symbol,
            totalSupply: totalSupply,
            idoSupply: idoSupply,
            owner: msg.sender,
            launched: false
        });
        memeSustainedLaunchCount++;

        emit MemeSustainedLaunchRequested(memeSustainedLaunchCount - 1);
    }

    function executeMemeSustainedLaunch(uint256 id) external payable onlyOwner {
        MemeSustainedLaunch memory launch = memeSustainedLaunches[id];

        // Create token and mint the total supply
        EverbitsERC20 token = new EverbitsERC20(launch.name, launch.symbol); // TODO: Token should have restrictions for transfers and fees
        token.mint(address(this), launch.totalSupply);

        // Transfer the rest of the supply to the owner
        token.transfer(msg.sender, launch.totalSupply - launch.idoSupply);

        // Launch the token on UniSwap
        uniswapV2Router.addLiquidityETH{value: msg.value}(
            address(token),
            launch.idoSupply,
            launch.idoSupply,
            msg.value,
            address(this),
            block.timestamp
        );

        memeSustainedLaunches[id].launched = true;

        emit MemeSustainedLaunchExecuted(id, address(token));
    }

    function createStandardIDO(StandardIDOParams calldata params) external {
        EverbitsIDO ido = new EverbitsIDO(
            address(uniswapV2Router),
            msg.sender,
            params
        );

        emit StandardIDOCreated(address(ido));
    }

    function getEverbitsTreasury() external view override returns (address) {
        return everbitsTreasury;
    }

    function setEverbitsTreasury(address _everbitsTreasury) external onlyOwner {
        everbitsTreasury = _everbitsTreasury;
    }
}
