// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Escrow2 {

    uint public totalCurrencies;
    mapping(address => mapping(address => uint)) public deposits;
    mapping(address => mapping(address => uint)) public rates;

    function deposit(address token, uint value) external {
        require(value > 0, "deposit must be > 0");
        require(IERC20(token).allowance(msg.sender, address(this))>=value,"escrow smart-contract should be approved to withdraw tokens");
        IERC20(token).transferFrom(msg.sender, address(this), value);
        if (deposits[token][msg.sender] == 0) {
            totalCurrencies += 1;
        }
        deposits[token][msg.sender] += value;
    }

    function setRate(address myToken, address anotherToken, uint rate) external {
        require(deposits[myToken][msg.sender] > 0, "zero deposit");
        rates[myToken][anotherToken] = rate;
    }

    function exchange(address myToken, address counterPart, address anotherToken, uint amount) external {
        require(deposits[myToken][msg.sender] > 0, "zero deposit");
        require(deposits[myToken][msg.sender] >= amount, "deposit less than amount");
//        require(rates[myToken][anotherToken] > 0, "rate for pair with anotherToken not specified");
//        require(rates[myToken][anotherToken] == rates[anotherToken][myToken], "rates are not equal");

        uint rate = 1; //rates[myToken][anotherToken]
        uint anotherAmount = amount * rate;
        deposits[myToken][msg.sender] -= amount;
        IERC20(myToken).transfer(counterPart, amount);
        IERC20(anotherToken).transfer(msg.sender, anotherAmount);
    }
}
