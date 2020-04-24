/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.5.3;

// L'owner del contratto deve essere admin

contract MainSC {

    address[] private blSmartContracts;

    // Aggiorna la lista degli smart contracts che contengono la businness logic.
    // Può essere fatto solo da admin (TODO aggiungere modifier).
    function setBLSmartContracts(address[] memory _blSmartContracts) public {
        blSmartContracts = _blSmartContracts;
    }

    // Aggiunge alla lista degli smart contracts che contengono la businness logic un nuovo smart contract.
    // Può essere fatto solo da admin (TODO aggiungere modifier).
    function addBLSmartContract(address _blSC) public {
        require(_blSC != address(0));

        // TODO Controllo che lo smart contract non sia già registrato
        blSmartContracts.push(_blSC);
    }
    
    function getBLSmartContracts() public view returns(address[] memory) {
        return blSmartContracts;
    }

}
