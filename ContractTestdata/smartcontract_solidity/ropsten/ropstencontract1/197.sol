/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^0.5.0;

contract RegisterLegalDocumentInfoContract {
    address owner; 
   
    struct LegalDocumentInfo {
        bytes32 fileName;
        bytes32 fileSHA256;
        uint256 creationDate;
        bool exits;
    }
    
    uint totalLegalDocumentsInfo;
    mapping(bytes32 => LegalDocumentInfo)  LegalDocuments;

    constructor() public {
        owner = msg.sender; // Asignamos el dueño en el constructor
        totalLegalDocumentsInfo = 0;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
	}

    function addLegalDocumentInfo(bytes32 fileSHA256, bytes32 fileName, uint256 creationDate) public
        onlyOwner
        returns(bool success)
    {
         if(LegalDocuments[fileSHA256].exits == true) { 
            emit LegalDocumentInfoDuplicated (fileSHA256, fileName, "Legal Document Info Duplicated");
            return false;
         } else {
            LegalDocumentInfo memory newlegalDocumentInfo;
            newlegalDocumentInfo.fileName = fileName;
            newlegalDocumentInfo.fileSHA256 = fileSHA256;
            newlegalDocumentInfo.creationDate = creationDate;
            newlegalDocumentInfo.exits = true;
            
            LegalDocuments[fileSHA256] = newlegalDocumentInfo;
            totalLegalDocumentsInfo++;
            emit LegalDocumentInfoCreated (fileSHA256, fileName, "New Legal Document Info Created");
            return true;
         }
    }
    
    function getLegalDocumentName(bytes32 fileSHA256) view public returns (bytes32) {
        return LegalDocuments[fileSHA256].fileName;
    }
    
    function getLegalDocumentCreationDate(bytes32 fileSHA256) view public returns (uint256) {
        return LegalDocuments[fileSHA256].creationDate;
    }
    
    function getLegalDocumentInfoExits(bytes32 fileSHA256) view public returns (bool) {
        return LegalDocuments[fileSHA256].exits;
    }
    
    function getTotalLegalDocumentInfo() view public returns (uint) {     
        return totalLegalDocumentsInfo;
    }
    
    
    event LegalDocumentInfoCreated(bytes32 fileSHA256, bytes32 fileName, string message);
    event LegalDocumentInfoDuplicated(bytes32 fileSHA256, bytes32 fileName, string message);

}
