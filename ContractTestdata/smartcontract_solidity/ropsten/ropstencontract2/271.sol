pragma solidity ^0.5.5;
//pragma experimental ABIEncoderV2;
import "./AGDIdentity.sol";
import "./AGDStorage.sol";

contract EntityFactory{
    event EntityCreated(address NewEntity, string GlobalIdentifierNumber);
    address _storageSpace;
    
    Identity[] deployedEntities;
    
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
    
    function createEntity(
        string memory _globalIdentifierNumber,
        bytes32[] memory _keys,
        uint256[] memory _purposes,
        uint256 _managementRequired,
        uint256 _executionRequired
    ) public 
        onlyGenieIdentity(msg.sender)
    {
        // bytes32[] memory _keys;
        // uint256[] memory _purposes;
        Storage storageSpace = Storage(_storageSpace);
        Identity newEntity = new Identity(
            _globalIdentifierNumber,
            _storageSpace,
            _keys,
            _purposes,
            _managementRequired,
            _executionRequired
        );
        storageSpace.setGLNToEntityContractAddress(_globalIdentifierNumber, address(newEntity));
        storageSpace.setAccountToEntityContractAddress(tx.origin, address(newEntity));
        storageSpace.setGLNToUserAccount(_globalIdentifierNumber, tx.origin);
        storageSpace.setUserAccountToGln(_globalIdentifierNumber, tx.origin);
        deployedEntities.push(newEntity);
        storageSpace.inscreaseEntityCount();
        emit EntityCreated(address(newEntity), _globalIdentifierNumber);
    }

    // function getDeployedEntities() public view //onlyGenie(msg.sender) 
    //     returns (Identity[]  memory _entities) {
    //     return deployedEntities;
    // }
}
