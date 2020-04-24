/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

pragma solidity ^0.4.18;
//Domenico Romano
//romanoing.eth

contract scrivi {
  string messaggio;

  function scrivi() public {
    messaggio = "romanoing-ethDeveloper";
  }

  function setscrivi(string _messaggio) public {
    messaggio = _messaggio;
  }

  function getscrivi() public view returns (string) {
    return messaggio;
  }
}
