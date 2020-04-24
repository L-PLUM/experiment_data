/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.4.23;

contract Maxidice {
    int256 public minimumNumber = 1;
    int256 public maximumNumber = 6;
    int256 public maximumPlayerInRoom = 6;
    struct Room {
        string roomID;
        uint256 currentPlayers;
        uint256 totalAmountBetting;
        uint256 numberWin;
        address[] players;
        mapping(address => Player) playerInfo;
    }

    struct Player {
        uint256 amountBet;
        uint256 numberSelected;
    }

    mapping(string => Room) rooms;
    uint256 currentRoomID = 0;
    
    constructor() public{

    }
    
    function createRoom(string roomID) public returns(string) {
        Room memory newRoom;
        newRoom.roomID = roomID;
        newRoom.currentPlayers = 1;
        newRoom.totalAmountBetting = 0;
        rooms[roomID] = newRoom;
        rooms[roomID].players.push(msg.sender);
    }

    function joinRoom(string roomID) public {
        require(!checkRoomExists(roomID), "room is not exist");
        rooms[roomID].players.push(msg.sender);
    }
    
    function bet(uint256 numberSelected, string roomID) public payable returns(bool){
        require(!checkRoomExists(roomID), "room is not exist");
        require(numberSelected >=1 && numberSelected <= 6, "only select number from 1 to 6");
        rooms[roomID].playerInfo[msg.sender].amountBet = msg.value;
        rooms[roomID].playerInfo[msg.sender].numberSelected = numberSelected;
        rooms[roomID].currentPlayers += 1;
        rooms[roomID].totalAmountBetting += msg.value;
        rooms[roomID].players.push(msg.sender);
    }

    function checkRoomExists(string roomID) public view returns(bool) {
        if (keccak256(rooms[roomID].roomID) == keccak256(roomID)) {
            return true;
        }
        return false;
    }
    
    function startGame(string memory roomID) public {
        uint256 numberGenerated = block.number % 6 + 1;
        distributePrizes(roomID, numberGenerated);
    }
    
    function distributePrizes(string roomID, uint256 numberWinner) public {
        address[100] memory winners;
        Room storage room = rooms[roomID];
        uint256 totalBetWon = 0;
        uint256 count = 0;
        for (uint256 i = 0; i < room.players.length; i++) {
            address playerAddr = room.players[i];
            if (room.playerInfo[playerAddr].numberSelected == numberWinner) {
                winners[count] = playerAddr;
                totalBetWon += room.playerInfo[playerAddr].amountBet;
                count++;
            }
        }
        uint256 totalBetLose = ((room.totalAmountBetting - totalBetWon) * 98) / 100;
        for (uint256 j = 0; j < count; j++) {
            address wonAddr = winners[j];
            uint256 paybackAmount = room.playerInfo[wonAddr].amountBet;
            paybackAmount += (paybackAmount / totalBetWon) * totalBetLose;
            wonAddr.transfer(paybackAmount);
        }
    }
}
