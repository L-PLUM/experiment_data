/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.5.3;

// L'owner del contratto deve essere il wallet "standard"

contract WalletSC {

    address[] private customSmartContracts;
    address private mainAddr;

    event Print(string messaggio, address mittente);
    event Feedback(address destinatario, string messaggio);

    function() external payable {
        emit Print("Sono arrivati dei token nel wallet", address(this));
        eseguiIstruzioni();
    }

    function eseguiIstruzioni() internal {
        for (uint i = 0; i < customSmartContracts.length; i++) {
            (bool success,) = customSmartContracts[i].call(abi.encodeWithSignature("esegui()"));
            if (success)
                emit Feedback(customSmartContracts[i], "Chiamata ok");
            else
                emit Feedback(customSmartContracts[i], "Chiamata ko");
        }

        address[] memory blSmartContracts = getBLSmartContracts();
        for (uint i = 0; i < blSmartContracts.length; i++) {
            (bool success,) = blSmartContracts[i].call(abi.encodeWithSignature("esegui()"));
            if (success)
                emit Feedback(blSmartContracts[i], "Chiamata ok");
            else
                emit Feedback(blSmartContracts[i], "Chiamata ko");
        }
    }

    function getBLSmartContracts() public view returns(address[] memory) {
        require(mainAddr != address(0));
        MainSC mainSC = MainSC(mainAddr);
        return mainSC.getBLSmartContracts();
    }

    function getCustomSmartContracts() public view returns(address[] memory) {
        return customSmartContracts;
    }

    // Può essere invocato solo da owner o da admin (TODO aggiungere modifier).
    function updateMainAddr(address _mainAddr) public {
        require(_mainAddr != address(0));
        mainAddr = _mainAddr;
    }

    // Può essere invocato solo da owner (TODO aggiungere modifier).
    function addCustomSmartContract(address _customSC) public {
        require(_customSC != address(0));

        // TODO Controllo che lo smart contract non sia già registrato
        customSmartContracts.push(_customSC);
    }

}

contract MainSC {
    function setBLSmartContracts(address[] memory _blSmartContracts) public;
    function addBLSmartContract(address _blSC) public;
    function getBLSmartContracts() public view returns(address[] memory);
}
