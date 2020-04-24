/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity ^0.5.3;

contract C {

    event Print(string text, address value);
    address aAddr;

    function esegui(address _aAddr) public returns(address){
      require(_aAddr != address(0));
      aAddr = _aAddr;
      emit Print("Input: ", _aAddr);
      return aAddr;
    }

    function chiamaA(string memory _istruzione) public returns(string memory) {
      require(aAddr != address(0));
      emit Print("Contratto da chiamare: ", aAddr);
      A a = A(aAddr);
      return a.eseguiIstruzione(_istruzione);
    }

}

contract A {
    function aggiornaBAddr(address _bAddr) public;
    function chiamaBcheChiamaC() public returns(bool, bytes memory);
    function eseguiIstruzione(string memory _istruzione) public pure returns(string memory);
}
