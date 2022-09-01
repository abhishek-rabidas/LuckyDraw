// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

contract Prize {

    uint public playerCount;
    address payable deployer;

    struct Player {
        uint id;
        string name;
        address payable playerAccount;
    }

    event winner(
        uint indexed id,
        string name
    );

    constructor() {
        deployer = payable(msg.sender);
    }

    //table to maintain the players data
    mapping(uint256 => Player) public players;

    function participate (string memory _name) payable external {
        require(checkParticipation(msg.sender), "Already Participated");
        require(msg.value == 1 ether, "Amount should be 1 ether");

        players[playerCount] = Player(
            playerCount,
            _name,
            payable(msg.sender)
        );

        playerCount++;

        //the participation amount gets stored in the contract balance
    }

    function checkParticipation(address _address) internal view returns(bool) {
        //check for duplicate participation

        for (uint i=0; i<playerCount; i++) {
            if(players[i].playerAccount == _address)
                return false;
        }

        return true;
    }

    function chooseWinner() external {
        require(msg.sender == deployer, "Not the deployer!!!");
        require(playerCount > 0, "No players!");

        //randomly selecting winner out of all the players
        uint winnerId = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % playerCount;

        emit winner (
            players[winnerId].id,
            players[winnerId].name
        );

        //sending the winning amount to winner
        payable(players[winnerId].playerAccount).transfer(address(this).balance);

        //reset the game
        playerCount = 0;
    }

    function viewBalance() view external returns(uint) {
        return address(this).balance;
    }

}