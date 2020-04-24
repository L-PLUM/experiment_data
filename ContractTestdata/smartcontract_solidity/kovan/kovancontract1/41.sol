/**
 *Submitted for verification at Etherscan.io on 2019-02-22
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

contract Permissionable is Ownable {
    mapping(address => bool) grantedAddress;
    
    event  GrantPermission(address indexed sender, address indexed granter);
    
    constructor() public {
        grantAddress(msg.sender);
    }
    
    modifier onlyGrantedAddress() {
        require(grantedAddress[msg.sender]);
        _;
    }
    
    function grantAddress(address _address) onlyOwner public returns (bool) {
        require(_address != address(0));
        
        grantedAddress[_address] = true;
        emit GrantPermission(msg.sender, _address);
        return true;
    }
}

contract PNPStorage is Permissionable {
    
    // Storage Variable
    mapping(bytes32 => uint256) private uintStorage;
    mapping(bytes32 => address) private addressStorage;
    mapping(bytes32 => string) private stringStorage;
    mapping(bytes32 => bytes) private bytesStorage;
    mapping(bytes32 => bool) private boolStorage;
    mapping(bytes32 => int256) private intStorage;
    
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
    function setUint(bytes32 _key, uint _value) onlyGrantedAddress external {
        uintStorage[_key] = _value;
    }
    
    // @param _key The key to be set in the address record
    function setAddress(bytes32 _key, address _value) onlyGrantedAddress external {
        addressStorage[_key] = _value;
    }
    
    // @param _key The key to be set in the string record
    function setString(bytes32 _key, string calldata _value) onlyGrantedAddress external {
        stringStorage[_key] = _value;
    }
    
    // @param _key The key to be set in the bytes record
    function setBytes(bytes32 _key, bytes calldata _value) onlyGrantedAddress external {
        bytesStorage[_key] = _value;
    }
    
    // @param _key The key to be set in the bool record
    function setBool(bytes32 _key, bool _value) onlyGrantedAddress external {
        boolStorage[_key] = _value;
    }
    
    // @param _key The key to be set in the int record
    function setInt(bytes32 _key, int _value) onlyGrantedAddress external {
        intStorage[_key] = _value;
    }
    
    
    /*** Delete Methods ***/
    
    // @param _key The key to be delete in the address record
    function deleteAddress(bytes32 _key) onlyGrantedAddress external {
        delete addressStorage[_key];
    }
    
    // @param _key The key to be delete in the uint record
    function deleteUint(bytes32 _key) onlyGrantedAddress external {
        delete uintStorage[_key];
    }
    
    // @param _key The key to be delete in the string record
    function deleteString(bytes32 _key) onlyGrantedAddress external {
        delete stringStorage[_key];
    }
    
    // @param _key The key to be delete in the bytes record
    function deleteBytes(bytes32 _key) onlyGrantedAddress external {
        delete bytesStorage[_key];
    }
    
    // @param _key The key to be delete in the bool record
    function deleteBool(bytes32 _key) onlyGrantedAddress external {
        delete boolStorage[_key];
    }
    
    // @param _key The key to be delete in the int record
    function deleteInt(bytes32 _key) onlyGrantedAddress external {
        delete intStorage[_key];
    }
    
}
