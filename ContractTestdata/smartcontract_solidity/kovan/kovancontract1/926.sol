/**
 *Submitted for verification at Etherscan.io on 2018-12-17
*/

pragma solidity ^0.4.25;
contract Message {
    string public  message;
    uint public people;
    address owner;
  constructor(string your_message) public{
    message=your_message;
    people=0;
    owner=msg.sender;
  }
  function setMessage(string your_message) public{
    message=your_message;
  }
  function getMessage() public view returns (string) {
    return message;
  }
  function pay() public payable {
      
  }
}
