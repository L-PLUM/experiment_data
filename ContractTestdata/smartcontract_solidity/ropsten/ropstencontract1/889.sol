/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity ^0.5.3;

contract B {

    event Print(string text, address value);
    
    C c;

    function istanziaC(address _cAddr) public {
      c = C(_cAddr);
    }

    function chiamaC(address _aAddr) public returns(address){
        emit Print("Input: ", _aAddr);
        emit Print("msg.sender: ", msg.sender);
        return c.esegui(_aAddr);
    }

}

contract C {
    function esegui(address _aAddr) public returns(address);
    function chiamaA(string memory _istruzione) public returns(string memory);
}
