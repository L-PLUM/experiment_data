/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity ^0.4.23;

contract Maxidice {
    
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
    mapping(string => Room) rooms;
    constructor() public {
    }

    function createRoom(string roomID) public returns(bool) {
        // Room storage nRoom = Room({roomID: roomID, currentPlayers: 1, totalAmountBetting: 200, wonNumber: 0, players: address[] });
        
        Room memory nRoom;
        nRoom.roomID = roomID;
        nRoom.currentPlayers = 3;
        nRoom.totalAmountBetting = 200;
        rooms[roomID] = nRoom;
        rooms[roomID].players.push(msg.sender);
        roomIDs.push(roomID);
        return true;
    }


    function getRoom(string roomID) public view returns (string, uint, uint256, address[]) {
        Room storage r = rooms[roomID];
        return (r.roomID,r.currentPlayers, r.totalAmountBetting, r.players);
    }
    function getRooms() public view returns(string) {
        // if (roomIDs.length == 0) {
        //     return "";
        // } 
        return roomIDs[0];
        // uint[] memory players = new uint[](roomIDs.length);
        // // string memory rIDs = roomIDs[0];
        // for (uint256 i = 0; i < roomIDs.length; i++) {
        //     // if (i > 0) {
        //     //     rIDs = string(abi.encodePacked(rIDs, ",", roomIDs[i]));
        //     // }
        //     players[i] = 1;
        // }
        // return players;
        // // uint[] memory players = new uint[](roomIDs.length);
        // // for (uint256 i = 0; i < roomIDs.length; i++) {
        // //     if (i > 0) {
        // //         rIDs = string(abi.encodePacked(rIDs, ",", roomIDs[i]));
        // //     }
        // //     players[i] = rooms[roomIDs[i]].currentPlayers;
        // // }
        // // return (rIDs, players);
    }
}
