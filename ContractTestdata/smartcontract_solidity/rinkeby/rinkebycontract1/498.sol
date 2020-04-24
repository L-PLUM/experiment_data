/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity >=0.4.22;

contract Storage {
  address owner;
  uint256 public counter;

  constructor () public {
    owner = msg.sender;
    counter = 0;
  }

  function inc () public {
    counter = counter + 1;
  }
}
