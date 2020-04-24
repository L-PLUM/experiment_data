/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity ^0.5.3;

contract BusinnessLogicSC3 {

    event Request(string messaggio, address mittente, uint256 importo);
    event Response(string messaggio, address from, address to, uint importo);

    function esegui(uint256 _importo) public {
        emit Request("Hello world 3", msg.sender, _importo);
    }

    function callBack(string memory _messaggio, address _from, address _to, uint _importo) public {
        emit Response(_messaggio, _from, _to, _importo);
    }

}
