/**
 *Submitted for verification at Etherscan.io on 2019-02-06
*/

pragma solidity >=0.5.0;

contract Thingy{
  mapping(address => uint256) public captures_tracker;
  uint256 private max_souls_per_body;

  constructor() public {
      max_souls_per_body = 3;
  }

  function foldByDefault() public {
    require(1==2, 'what?');
 
  }

  function doThings() public{
    //What is wrong? This require statement breaks the code. It works when commented out.
    require(captures_tracker[msg.sender] < max_souls_per_body);
    captures_tracker[msg.sender]++;
  }
}
