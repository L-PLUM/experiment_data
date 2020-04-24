/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity >=0.4.0 <0.6.0;

contract Maxidice {
    mapping(string => Room) rooms;
    uint256 public minNumber = 1;
    uint256 public maxNumber = 6;
    uint256 public maxPlayerInRoom = 6;
    
    struct Player {
        uint256 numberSelected;
        uint256 amountBet;
    }
    struct Room {
        string roomID;
        uint256 currentPlayers;
        uint256 totalAmountBetting;
        uint256 wonNumber;
        address[] players;
        mapping (address => Player) playerInfo;
    }
    
    constructor() public {
    }

    function createRoom(string memory roomID) public returns(bool) {
        Room memory nRoom;
        nRoom.roomID = roomID;
        nRoom.currentPlayers = 1;
        nRoom.totalAmountBetting = 0;
        rooms[roomID] = nRoom;
        rooms[roomID].players.push(msg.sender);
        return true;
    }
}
