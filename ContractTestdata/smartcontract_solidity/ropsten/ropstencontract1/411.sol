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

    function getRooms() public view returns(bytes32[] memory r) {
        for (uint256 i = 0; i <= roomIDs.length; i++) {
            Room memory room = rooms[roomIDs[i]];
            string memory roomLabel = appendUintToString(room.roomID, room.currentPlayers);
            r[i] = stringToBytes32(roomLabel);
        }
        return r;
    }
    
    function stringToBytes32(string memory source) returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }
        assembly {
            result := mload(add(source, 32))
        }
    }
    
    function appendUintToString(string inStr, uint v) internal returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory inStrb = bytes(inStr);
        bytes memory s = new bytes(inStrb.length + i);
        uint j;
        for (j = 0; j < inStrb.length; j++) {
            s[j] = inStrb[j];
        }
        for (j = 0; j < i; j++) {
            s[j + inStrb.length] = reversed[i - 1 - j];
        }
        str = string(s);
    }
}
