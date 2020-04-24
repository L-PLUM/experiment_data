/**
 *Submitted for verification at Etherscan.io on 2019-02-14
*/

pragma solidity ^0.4.23;

contract Maxidice {
    struct Room {
        bytes32 roomID;
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

    mapping(bytes32 => Room) rooms;
    uint256 currentRoomID = 0;
    
    constructor() public{

    }
    
    function createRoom() public constant returns(bytes32){
        bytes32 roomID = keccak256(abi.encode(block.timestamp));
        // refreshRoom(roomID);
        return roomID;
    }

    function refreshRoom(bytes32 roomID) public {
        Room memory newRoom;
        newRoom.roomID = roomID;
        newRoom.currentPlayers = 0;
        newRoom.totalAmountBetting = 0;
        rooms[roomID] = newRoom;
    }
    
    function bet(uint256 numberSelected, bytes32 roomID) public payable returns(bool){
        require(!checkRoomExists(roomID), "room is not exist");
        require(numberSelected >=1 && numberSelected <= 6, "only select number from 1 to 6");
        rooms[roomID].playerInfo[msg.sender].amountBet = msg.value;
        rooms[roomID].playerInfo[msg.sender].numberSelected = numberSelected;
        rooms[roomID].currentPlayers += 1;
        rooms[roomID].totalAmountBetting += msg.value;
        rooms[roomID].players.push(msg.sender);
    }

    function checkRoomExists(bytes32 roomID) public view returns(bool) {
        if (rooms[roomID].roomID == roomID) {
            return true;
        }
        return false;
    }
    
    function startGame(bytes32 roomID) public {
        uint256 numberGenerated = block.number % 6 + 1;
        distributePrizes(roomID, numberGenerated);
    }
    
    function distributePrizes(bytes32 roomID, uint256 numberWinner) public {
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
