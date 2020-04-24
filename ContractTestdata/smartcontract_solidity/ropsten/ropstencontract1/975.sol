/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

pragma solidity ^0.5.3;

contract C {

    event Print(string text, address value);
    address aAddr;

    function esegui(address _aAddr) public {
      require (_aAddr != address(0));
      aAddr = _aAddr;
      // emette un evento
      emit Print("L'indirizzo del mittente è , ", _aAddr);
    }

    function chiamaA(string memory _istruzione) public {
      aAddr.call(abi.encode("eseguiIstruzione(string)", _istruzione));
    }

}
