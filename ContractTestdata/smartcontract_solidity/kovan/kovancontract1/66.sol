/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity 0.5.4;

contract Ownable {
    address public owner;
    
    event transferOwner(address indexed existingOwner, address indexed newOwner);
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function transferOwnership(address newOwner) onlyOwner public {
        if(newOwner != address(0)){
            owner = newOwner;
            emit transferOwner(msg.sender, owner);
        }
    }
        
}

contract PNPStorage is Ownable {
    
    // Storage Variable
    mapping(bytes32 => uint256) private uintStorage;
    mapping(bytes32 => address) private addressStorage;
    mapping(bytes32 => string) private stringStorage;
    mapping(bytes32 => bytes) private bytesStorage;
    mapping(bytes32 => bool) private boolStorage;
    mapping(bytes32 => int256) private intStorage;
    
    /*** Modifiers ***/
    
    /// @dev Only allow access from the latest version of a contract in the PNP network after deployment
    modifier onlyPermissionedContract() {
        if(msg.sender == owner) {
            // The owner is only allowed to set the storage upon deployment to register the initial contracts, afterwards their direct access is disabled
            require(boolStorage[keccak256("contract.storage.initialised")] == false);
        } else {
            // Make sure the access is permitted to only contracts in our Dapp
            require(addressStorage[keccak256(abi.encodePacked("contract.address", msg.sender))] != address(0));
        }
        _;
    }
    
    /*** Get Methods ***/
    
    // @param _key The key for the uint record
    function getUint(bytes32 _key) external view returns(uint) {
        return uintStorage[_key];
    }
    
    // @param _key The key for the address record
    function getAddress(bytes32 _key) external view returns(address) {
        return addressStorage[_key];
    }
    
    // @param _key The key for string record
    function getString(bytes32 _key) external view returns(string memory) {
        return stringStorage[_key];
    }
    
    // @param _key The key for bytes record
    function getBytes(bytes32 _key) external view returns(bytes memory) {
        return bytesStorage[_key];
    }
    
    // @param _key The key for bool record
    function getBool(bytes32 _key) external view returns(bool) {
        return boolStorage[_key];
    }
    
    // @param _key The key for int record
    function getInt(bytes32 _key) external view returns(int) {
        return intStorage[_key];
    }
    
    /*** Set Methods ***/
    
    // @param _key The key to be set in the uint record
    function setUint(bytes32 _key, uint _value) onlyPermissionedContract external {
        uintStorage[_key] = _value;
    }
    
    // @param _key The key to be set in the address record
    function setAddress(bytes32 _key, address _value) onlyPermissionedContract external {
        addressStorage[_key] = _value;
    }
    
    // @param _key The key to be set in the string record
    function setString(bytes32 _key, string calldata _value) onlyPermissionedContract external {
        stringStorage[_key] = _value;
    }
    
    // @param _key The key to be set in the bytes record
    function setBytes(bytes32 _key, bytes calldata _value) onlyPermissionedContract external {
        bytesStorage[_key] = _value;
    }
    
    // @param _key The key to be set in the bool record
    function setBool(bytes32 _key, bool _value) onlyPermissionedContract external {
        boolStorage[_key] = _value;
    }
    
    // @param _key The key to be set in the int record
    function setInt(bytes32 _key, int _value) onlyPermissionedContract external {
        intStorage[_key] = _value;
    }
    
    
    /*** Delete Methods ***/
    
    // @param _key The key to be delete in the address record
    function deleteAddress(bytes32 _key) onlyPermissionedContract external {
        delete addressStorage[_key];
    }
    
    // @param _key The key to be delete in the uint record
    function deleteUint(bytes32 _key) onlyPermissionedContract external {
        delete uintStorage[_key];
    }
    
    // @param _key The key to be delete in the string record
    function deleteString(bytes32 _key) onlyPermissionedContract external {
        delete stringStorage[_key];
    }
    
    // @param _key The key to be delete in the bytes record
    function deleteBytes(bytes32 _key) onlyPermissionedContract external {
        delete bytesStorage[_key];
    }
    
    // @param _key The key to be delete in the bool record
    function deleteBool(bytes32 _key) onlyPermissionedContract external {
        delete boolStorage[_key];
    }
    
    // @param _key The key to be delete in the int record
    function deleteInt(bytes32 _key) onlyPermissionedContract external {
        delete intStorage[_key];
    }
    
}
