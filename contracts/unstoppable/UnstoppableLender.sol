// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IReceiver {
    function receiveTokens(address tokenAddress, uint256 amount) external;
}

/**
 * @title UnstoppableLender
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract UnstoppableLender is ReentrancyGuard {
    IERC20 public immutable damnValuableToken;
    uint256 public poolBalance;

    constructor(address tokenAddress) {
        require(tokenAddress != address(0), "Token address cannot be zero");
        damnValuableToken = IERC20(tokenAddress);
    }

    function depositTokens(uint256 amount) external nonReentrant {
        require(amount > 0, "Must deposit at least one token");
        // Transfer token from sender. Sender must have first approved them.
        damnValuableToken.transferFrom(msg.sender, address(this), amount);
        // 下面這行沒有用 safeMath 會 overflow?
        // 不對， compiler version 是 0.8.0 應該沒問題
        poolBalance = poolBalance + amount;
        // 要使用這個 function 才會 update poolBalance
        // 但是 token.transfer(address(pool), 1) 卻不會
        // 然後下面的 assert(poolBalance == balanceBefore); 就壞惹，永遠不會過
    }

    function flashLoan(uint256 borrowAmount) external nonReentrant {
        // denial of service
        require(borrowAmount > 0, "Must borrow at least one token");

        uint256 balanceBefore = damnValuableToken.balanceOf(address(this));
        require(balanceBefore >= borrowAmount, "Not enough tokens in pool");

        // Ensured by the protocol via the `depositTokens` function
        assert(poolBalance == balanceBefore);

        damnValuableToken.transfer(msg.sender, borrowAmount);

        IReceiver(msg.sender).receiveTokens(
            address(damnValuableToken),
            borrowAmount
        );

        uint256 balanceAfter = damnValuableToken.balanceOf(address(this));
        require(
            balanceAfter >= balanceBefore,
            "Flash loan hasn't been paid back"
        );
    }
}
