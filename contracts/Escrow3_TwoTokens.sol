// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Escrow3_TwoTokens is Ownable {

    uint public totalCurrencies;
    mapping(string => mapping(string => uint)) private rates;
    mapping(string => address) public tokens;
    mapping(string => mapping(address => uint)) public deposits;

    constructor(address token1, address token2) Ownable() {
        register(token1);
        register(token2);
    }

    function register(address token) public onlyOwner {
        string memory tokenSymbol = ERC20(token).symbol();
        require(bytes(tokenSymbol).length != 0, "expect ERC20 token with name");

        address existingAddress = tokens[tokenSymbol];
        if (existingAddress != address(0) && existingAddress != token) {
            revert("Another token with such symbol already registered");
        }
        tokens[tokenSymbol] = token;
    }

    function deposit(string calldata tokenSymbol, uint value) external {
        require(value > 0, "deposit must be > 0");
        ERC20 token = ERC20(tokens[tokenSymbol]);
        require(address(token) != address(0), string(abi.encodePacked(tokenSymbol, " is not registered")));
        require(token.allowance(msg.sender, address(this)) >= value, "escrow smart-contract should be approved to withdraw tokens");

        token.transferFrom(msg.sender, address(this), value);
        if (deposits[tokenSymbol][msg.sender] == 0) {
            totalCurrencies += 1;
        }
        deposits[tokenSymbol][msg.sender] += value;
    }

    function setRate(string calldata tokenSymbol1, string calldata tokenSymbol2, uint rate) external onlyOwner {
        require(rate > 0, "zero rate");
        rates[tokenSymbol1][tokenSymbol2] = rate;
    }

    function exchange(string calldata tokenSymbol1, string calldata tokenSymbol2, address counterPart, uint amount) external {

        require(amount > 0, "zero amount");
        require(deposits[tokenSymbol1][msg.sender] >= amount, "sender deposit is less than amount");

        uint counterPartAmount = amount;

        uint rate = rates[tokenSymbol1][tokenSymbol2];
        if (rate != 0) {
            counterPartAmount = amount * rate;
        } else {
            rate = rates[tokenSymbol2][tokenSymbol1];
            counterPartAmount = amount / rate;
        }
        require(deposits[tokenSymbol2][counterPart] >= counterPartAmount, "receiver deposit is less than amount");

        ERC20 token1 = ERC20(tokens[tokenSymbol1]);
        ERC20 token2 = ERC20(tokens[tokenSymbol2]);

        token1.transfer(counterPart, amount);
        token2.transfer(msg.sender, counterPartAmount);
        deposits[tokenSymbol1][msg.sender] -= amount;
        deposits[tokenSymbol2][counterPart] -= counterPartAmount;
    }

    function isContract(address addr) private view returns (bool) {
        uint size;
        assembly {size := extcodesize(addr)}
        return size > 0;
    }
}
