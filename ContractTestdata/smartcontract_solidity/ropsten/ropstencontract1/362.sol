/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity ^0.4.23;

contract Maxidice {
  
  event OnCreateRoom(address indexed _from, uint256 _value);
  
  struct Room {
    address[] players;       
    uint256 whosTurnId;
    uint256 roomState;
  }  
  
  Room[] public rooms;

  function createRoom() public {
      Room memory room = Room(new address[](0), 0, 0);
      rooms.push(room);
      rooms[rooms.length-1].players.push(msg.sender);

      OnCreateRoom(msg.sender, 0);
  }
  function getRoomPlayers(uint i) public view returns (address[]){
      return rooms[i].players;
  }
}
