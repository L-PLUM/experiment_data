pragma solidity ^0.5.4;

import "./AGDVerifier.sol";
import "./AGDStorage.sol";

contract VerifierFactory {
    
    event VerifierCreated(address Verifier, address Creator);
    
    address _storageSpace;
    
    ClaimVerifier[] public verifiers;

    modifier onlyGenieIdentity(address _addr){
        Storage storageSpace = Storage(_storageSpace);
        require(_addr == storageSpace.getGenieIdentityAddress());
        _;
    }

    function getStorageSpace() public view returns (address) {
        return _storageSpace;
    }
    
    function setStorageSpace(address _newAddress) public {
        _storageSpace = _newAddress;
    }
    
    function createNewVerifier(address payable _trustedIdentity) public onlyGenieIdentity(msg.sender) returns (address) {
        Storage storageSpace = Storage(_storageSpace);
        ClaimVerifier newverifier = new ClaimVerifier(_trustedIdentity);
        verifiers.push(newverifier);
        emit VerifierCreated(address(newverifier), tx.origin);
        return address(newverifier);
    } 
    
    function getDeployedNFProduct() public view returns (ClaimVerifier[] memory) {
        return verifiers;
    }
    
}
