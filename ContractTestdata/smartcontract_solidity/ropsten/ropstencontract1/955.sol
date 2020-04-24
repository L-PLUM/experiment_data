/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

pragma solidity ^0.5.3;

contract C {

    event Print(string text, address value);
    address aAddr;
    A a;

    function istanziaA(address _aAddr) public {
      a = A(_aAddr);
    }

    function esegui(address _aAddr) public {
      require (_aAddr != address(0));
      aAddr = _aAddr;
      // emette un evento
      emit Print("L'indirizzo del mittente è , ", _aAddr);
    }

    function chiamaA(string memory _istruzione) public view returns(string memory) {
      return a.eseguiIstruzione(_istruzione);
    }

}

contract A {
    function aggiornaBAddr(address _bAddr) public;
    function chiamaBcheChiamaC() public;
    function eseguiIstruzione(string memory _istruzione) public pure returns(string memory);
}
