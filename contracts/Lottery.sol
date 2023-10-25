// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
import "hardhat/console.sol";

contract Lottery {

    address payable public owner;
    bool public finished = false;

    struct Participant {
        uint index;
        uint value;
    }

    address payable[] private participants;
    mapping(address => Participant) private registry;

    uint private randomNonce = 0;


    event LotteryDraw(address winner, uint amount);

    constructor() payable {
        console.log("constructor: ", msg.sender);

        owner = payable(msg.sender);
    }

    function register() payable public {
        console.log("BID: ", msg.value);
        require(!finished, "Lottery is finished");
        require(msg.value > 0, "bid must be greater than 0");
        if (registry[msg.sender].value == 0) {
            console.log("was not registered: ", registry[msg.sender].index);
            participants.push(payable(msg.sender));
            registry[msg.sender].index = participants.length;
        }
        registry[msg.sender].value += msg.value;
        console.log("after register: ", registry[msg.sender].index, ",", registry[msg.sender].index);
    }

    function draw() public {
        require(!finished, "Lottery is finished");
        require(msg.sender == owner, "You aren't the owner");

        uint[] memory chances = new uint[](participants.length);


        for (uint i = 0; i < participants.length; i++) {
            uint value = registry[participants[i]].value;
            uint randomChance = random(value);
            console.log("RandomChance", i, ":", randomChance);
            chances[i] = randomChance * value;
        }

        uint maxIndex = 0;
        uint maxChance = chances[0];
        for (uint i = 0; i < chances.length; i++) {
            console.log("participant ", i, ", chance:", chances[i]);
            if (chances[i] > maxChance) {
                maxChance = chances[i];
                maxIndex = i;
            }
        }
        console.log("Winner:", maxIndex, " ", maxChance);
        console.log(", address:", participants[maxIndex]);

        emit LotteryDraw(participants[maxIndex], address(this).balance);
        participants[maxIndex].transfer(address(this).balance);
        finished = true;
    }

    function random(uint value) private returns (uint) {
        uint randomInt = uint(keccak256(abi.encodePacked(block.timestamp, value, randomNonce)));
        randomNonce += 1;
        return randomInt % 1000000;
    }

    function totalParticipants() public view returns (uint) {
        return participants.length;
    }

}
