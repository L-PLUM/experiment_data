/**
 *Submitted for verification at Etherscan.io on 2019-01-14
*/

pragma solidity ^0.5.0;

contract nodereptest {
  event Log(address indexed sender, bytes32 indexed data);

  function logEthTx(bytes32 _data) public {
    emit Log(msg.sender, _data);
  }
}
