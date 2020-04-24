/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.5.3;

contract BusinnessLogicSC1 {

    event Print(string messaggio, address mittente);

    function esegui() public {
        emit Print("Hello world 1", msg.sender);
    }

}
