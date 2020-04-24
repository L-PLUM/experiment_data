/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity ^0.5.6;

contract Ownable {
  address public owner;

  constructor() public{
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

}

contract Lebac is Ownable{
  // Address to which any funds sent to this contract will be forwarded
  event Transfered(address from, uint value, bytes data);

  // Declare empty fallback
  function() external payable { }

  function flush() public onlyOwner {
    owner.call.value(address(this).balance)("");
  }
}
