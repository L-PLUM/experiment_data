/**
 *Submitted for verification at Etherscan.io on 2019-02-18
*/

pragma solidity ^0.5.3;

contract BusinnessLogicSC1 {

    event Print(string messaggio, address mittente, uint256 importo);

    function esegui(uint256 _importo) public {
        emit Print("Hello world 1", msg.sender, _importo);
    }

}
