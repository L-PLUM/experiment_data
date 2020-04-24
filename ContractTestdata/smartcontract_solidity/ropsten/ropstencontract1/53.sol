/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity ^0.5.4;
// Domenico Romano
// romanoing.ether

contract strutturaDati {
    uint256 public contaPersone;
    mapping(uint => Persona) public persone;

    struct Persona {
        uint id;
        string _Nome;
        string _Cognome;
    }

    function addPersona(string memory _Nome, string memory _Cognome) public {
        contaPersone+=1;
        persone[contaPersone]= Persona(contaPersone, _Nome, _Cognome);
    }
}
