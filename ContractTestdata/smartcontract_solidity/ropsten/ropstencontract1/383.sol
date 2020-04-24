/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity ^0.4.23;

contract Maxidice {
    mapping(string => Room) rooms;
    string[] roomIDs;
    uint public minNumber = 1;
    uint public maxNumber = 6;
    uint public maxPlayerInRoom = 6;
    
    struct Player {
        uint256 numberSelected;
        uint256 amountBet;
    }

    struct Room {
        string roomID;
        uint currentPlayers;
        uint256 totalAmountBetting;
        uint wonNumber;
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
        roomIDs.push(roomID);
        return true;
    }

    function getRooms() public view returns(uint[]) {
        uint[] memory players = new uint[](roomIDs.length);
        // string memory rIDs = roomIDs[0];
        for (uint256 i = 0; i < roomIDs.length; i++) {
            // if (i > 0) {
            //     rIDs = string(abi.encodePacked(rIDs, ",", roomIDs[i]));
            // }
            players[i] = rooms[roomIDs[i]].currentPlayers;
        }
        return players;
        // uint[] memory players = new uint[](roomIDs.length);
        // for (uint256 i = 0; i < roomIDs.length; i++) {
        //     if (i > 0) {
        //         rIDs = string(abi.encodePacked(rIDs, ",", roomIDs[i]));
        //     }
        //     players[i] = rooms[roomIDs[i]].currentPlayers;
        // }
        // return (rIDs, players);
    }
}
