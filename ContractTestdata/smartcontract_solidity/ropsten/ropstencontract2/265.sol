pragma solidity ^0.5.4;

import "./AGDF-Product.sol";
import "./AGDStorage.sol";

contract F_ProductFactory {
    
    event FungileProductCreated(address NewFProduct, address Creator);
    
    address _storageSpace;
    
    F_Product[] public f_products;

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
    
    function createNewFProduct(string memory _name, string memory _symbol, uint8 _decimals, uint totalSupply) public onlyGenieToken(msg.sender) returns (address) {
        Storage storageSpace = Storage(_storageSpace);
        F_Product newproduct = new F_Product(_name, _symbol, _decimals, totalSupply, _storageSpace);
        f_products.push(newproduct);
        emit FungileProductCreated(address(newproduct), msg.sender);
        storageSpace.inscreaseFProductCount();
        storageSpace.setOwnerToFProducts(tx.origin, address(newproduct));
        storageSpace.setFProductToOwner(tx.origin, address(newproduct));
        return address(newproduct);
    }
    
    function getDeployedFProduct() public view returns (F_Product[] memory) {
        return f_products;
    }

}
