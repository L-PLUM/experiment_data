pragma solidity ^0.5.4;

import "./AGDNF-Token.sol";
import "./AGDStorage.sol";

contract NF_ProductFactory {
    
    event Non_FungibleAssetCreated(address NewNon_FungibleAsset, address Creator);
    
    address _storageSpace;
    
    AGDNF_Token[] public nf_products;

    modifier onlyGenieToken(address _addr){
        Storage storageSpace = Storage(_storageSpace);
        require(_addr == storageSpace.getGenieTokenAddress());
        _;
    }

    function getStorageSpace() public view returns (address) {
        return _storageSpace;
    }
    
    function setStorageSpace(address _newAddress) public {
        _storageSpace = _newAddress;
    }
    
    function createNewNFProduct(string memory name, string memory symbol, address _connectedAsset) public onlyGenieToken(msg.sender) returns (address) {
        Storage storageSpace = Storage(_storageSpace);
        AGDNF_Token newproduct = new AGDNF_Token(name, symbol, _connectedAsset, _storageSpace);
        nf_products.push(newproduct);
        emit Non_FungibleAssetCreated(address(newproduct), tx.origin);
        storageSpace.inscreaseNFProductCount(); 
        storageSpace.setOwnerToNFProducts(tx.origin, address(newproduct));
        storageSpace.setNFProductToOwner(tx.origin, address(newproduct));
        return address(newproduct);
    } 
    
    function getDeployedNFProduct() public view returns (AGDNF_Token[] memory) {
        return nf_products;
    }
    
}
