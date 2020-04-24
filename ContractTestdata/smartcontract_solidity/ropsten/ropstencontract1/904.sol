/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity ^0.5.0;

contract ODXVerifyAddress {

  event VerifyAddress(address indexed ethAddr, string indexed code);
  
  function verifyAddress(string memory code) public {
    bytes memory mCode = bytes(code);
    require (mCode.length>0);
    emit VerifyAddress(msg.sender, code);
  }
  
}
