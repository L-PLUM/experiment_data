/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity ^0.5.3;

contract B {

    C c;

    function istanziaC(address _cAddr) public {
      c = C(_cAddr);
    }

    function chiamaC() public {
      c.esegui(msg.sender);
    }

}

contract C {
    function esegui(address _aAddr) public;
    function chiamaA(string memory _istruzione) public view returns(string memory);
}
