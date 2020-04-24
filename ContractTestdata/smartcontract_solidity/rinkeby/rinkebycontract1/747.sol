/**
 *Submitted for verification at Etherscan.io on 2019-02-08
*/

pragma solidity ^0.4.25;
pragma experimental ABIEncoderV2;
 
contract StemFilieraPubblica2 {
 
    struct Cordone {
        string State;
        //Fase firma contratto
        //bytes32 CodiceCliente;
        string Barcode;
        string DataContratto;
        //Fase consegna kit alla mamma
        string CodiceSpedizione;
        string DataSpedizione;
        //Chiamata da ospedale per ritiro kit
        string DataChiamata;
        //Fase ritiro kit dal Cliente
        string CodiceSpedizioneRitiro;
        string DataSpedizioneRitiro;
        //Fase consegna kit alla Banca
        string DataConsegnaBanca;
        //Fase crioconservazione
        string DataCrio;
        //Fase rilascio certificato
        string HashFile;
        string DataRilascio;
    }
    
    address public  Futura;
 
    mapping (bytes32 => Cordone) public Cordoni;
 
    //Check permessi
    modifier checkAdmin()
    {
        require(Futura == msg.sender);
        _;
    }
    
    //Check permessi
    modifier checkParamObligatory(string param)
    {
        require(bytes(param).length>0);
        _;
    }
 
    function getInfo(bytes32 inputCodiceCliente) public view returns (Cordone) {
        return Cordoni[inputCodiceCliente];
    }
    
    
    /*function getInfo2(string inputCodiceCliente) public view returns (string)
    {
        return string(abi.encodePacked("aaa", " - ", inputCodiceCliente));
    }*/
    
 
    // constructor function
    constructor () public
    {
        Futura = msg.sender;
        
    }
 
    function ActCFirmaContratto(bytes32 inputCodiceCliente, string inputBarcode, string inputDataContratto) public
                                                checkAdmin() checkParamObligatory(inputBarcode) checkParamObligatory(inputDataContratto)  returns (bool)
    {
        Cordoni[inputCodiceCliente].Barcode = inputBarcode;
        Cordoni[inputCodiceCliente].DataContratto = inputDataContratto;
        
        Cordoni[inputCodiceCliente].State = "Firma";
        
        return true;
    }
    
    function ActConsegnaKitMamma(bytes32 inputCodiceCliente, string inputCodiceSpedizione, string inputDataSpedizione) public
                                                checkAdmin() checkParamObligatory(inputCodiceSpedizione) checkParamObligatory(inputDataSpedizione)  returns (bool)
    {        
        Cordoni[inputCodiceCliente].CodiceSpedizione = inputCodiceSpedizione;
        Cordoni[inputCodiceCliente].DataSpedizione = inputDataSpedizione;
    
        Cordoni[inputCodiceCliente].State = "ConsegnaKitMamma";
        
        return true;
    }
    
    function ActChiamata(bytes32  inputCodiceCliente, string  inputDataChiamata) public
     checkAdmin() checkParamObligatory(inputDataChiamata)  returns (bool)
    {
        Cordoni[inputCodiceCliente].DataChiamata = inputDataChiamata;
        Cordoni[inputCodiceCliente].State = "ChiamataRitiro";
        return true;
    }
    
    function ActRitiroKIT(bytes32 inputCodiceCliente, string inputCodiceSpedizioneRitiro, string inputDataSpedizioneRitiro) public
                                                checkAdmin() checkParamObligatory(inputCodiceSpedizioneRitiro) checkParamObligatory(inputDataSpedizioneRitiro)  returns (bool)
    {
        Cordoni[inputCodiceCliente].CodiceSpedizioneRitiro = inputCodiceSpedizioneRitiro;
        Cordoni[inputCodiceCliente].DataSpedizioneRitiro = inputDataSpedizioneRitiro;
        
        Cordoni[inputCodiceCliente].State = "RitiroKIT";
        
        return true;
    }
    
    function ActConsegnaKitBanca(bytes32 inputCodiceCliente, string inputDataConsegnaBanca) public
                                                checkAdmin() checkParamObligatory(inputDataConsegnaBanca)  returns (bool)
    {
        Cordoni[inputCodiceCliente].DataConsegnaBanca = inputDataConsegnaBanca;
        
        Cordoni[inputCodiceCliente].State = "ConsegnaKitBanca";
        
        return true;
    }
    
    function ActCrioconservazione(bytes32 inputCodiceCliente, string inputDataCrio) public
                                                checkAdmin() checkParamObligatory(inputDataCrio)  returns (bool)
    {
        Cordoni[inputCodiceCliente].DataCrio = inputDataCrio;
        
        Cordoni[inputCodiceCliente].State = "Crioconservazione";
        
        return true;
    }
    
    function ActInvioCertificato(bytes32 inputCodiceCliente, string inputHashFile, string inputDataRilascio) public
                                                checkAdmin() checkParamObligatory(inputDataRilascio)  returns (bool)
    {
        Cordoni[inputCodiceCliente].HashFile = inputHashFile;
        Cordoni[inputCodiceCliente].DataRilascio = inputDataRilascio;
        
        Cordoni[inputCodiceCliente].State = "InvioCertificato";
        
        return true;
    }
}
