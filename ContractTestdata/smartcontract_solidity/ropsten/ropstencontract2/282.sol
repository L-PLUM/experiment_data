pragma solidity ^0.5.4;

import "./AGDEntityFactory.sol";
import "./AGDVerifierFactory.sol";
import "./AGDOwnable.sol";
import "./AGDStorage.sol";


contract GenieIdentity is Ownable{ 
    
    address _storageSpace;
    
    modifier glnHasNotExisted (string memory gln){
        Storage storageSpace = Storage(_storageSpace);
        require(storageSpace.getGLNToUserAccount(gln) == 0x0000000000000000000000000000000000000000);
        _;
    }
    
    constructor (
        address _storage, 
        address _e,
        address _v
    ) 
    public 
    {
        _storageSpace = _storage;
        Storage storageSpace = Storage(_storage);
        storageSpace.setEntityFactoryAddress(_e);
        EntityFactory entityFactory = EntityFactory(storageSpace.getEntityFactoryAddress());
        entityFactory.setStorageSpace(_storageSpace);
        storageSpace.setVerifierFactoryAddress(_e);
        VerifierFactory verifierFactory = VerifierFactory(storageSpace.getVerifierFactoryAddress());
        verifierFactory.setStorageSpace(_storageSpace);
    }
    
    function RegisterVerifier(address payable _trustedIdentity) public {
        Storage storageSpace = Storage(_storageSpace);
        VerifierFactory verifierFactory = VerifierFactory(storageSpace.getVerifierFactoryAddress());
        verifierFactory.createNewVerifier(_trustedIdentity);
    }
    
    //
    function RegisterIdentifier(
        string memory _globalIdentifierNumber,
        bytes32[] memory _keys,
        uint256[] memory _purposes,
        uint256 _managementRequired,
        uint256 _executionRequired
    ) 
    public glnHasNotExisted (_globalIdentifierNumber){
        Storage storageSpace = Storage(_storageSpace);
        EntityFactory entityFactory = EntityFactory(storageSpace.getEntityFactoryAddress());
        entityFactory.createEntity(_globalIdentifierNumber, _keys, _purposes, _managementRequired, _executionRequired);
    }
    
    //
    function activationGenieIdentity(address _genieAddress) public onlyOwner(){
        Storage storageSpace = Storage(_storageSpace);
        storageSpace.activationGenieIdentity(_genieAddress);
    }
    
    function setDelegationAccount(address _delegation) public onlyOwner() {
        Storage storageSpace = Storage(_storageSpace);
        storageSpace.setDelegationAccount(_delegation);
    }
    
    function checkAccountWasLost(address account) public view returns (bool) {
        Storage storageSpace = Storage(_storageSpace);
        return storageSpace.checkAccountWasLost(account);
    }
    
    function getOldAccountToNewAccount(address _oldAccount) public view returns (address) {
        Storage storageSpace = Storage(_storageSpace);
        return storageSpace.getOldAccountToNewAccount(_oldAccount);
    }
    
    function getNewAccountFromOldAccount(address _newAccount) public view returns (address) {
        Storage storageSpace = Storage(_storageSpace);
        return storageSpace.getNewAccountFromOldAccount(_newAccount);
    }
    
    function lostAccount(string memory gln, bool approved, address newAccount) public {
        Storage storageSpace = Storage(_storageSpace);
        storageSpace.lostAccount(gln, approved, newAccount);
    }
    
    function getDelegationAccount() public view returns (address) {
        Storage storageSpace = Storage(_storageSpace);
        return storageSpace.getDelegationAccount();
    }
    
    function activationGenieToken(address _genieAddress) public onlyOwner(){
        Storage storageSpace = Storage(_storageSpace);
        storageSpace.activationGenieToken(_genieAddress);
    }

    function changeGenie(address newGenieIdentityAddress, address newGenieTokenAddress) public onlyOwner()
    {
        Storage storageSpace = Storage(_storageSpace);
        storageSpace.changeGenie(newGenieIdentityAddress, newGenieTokenAddress);
    }
    
    function getNFProductFactoryAddress() public view returns (address){
        Storage storageSpace = Storage(_storageSpace);
        return storageSpace.getNFProductFactoryAddress();
    }
    
    function getFProductFactoryAddress() public view returns (address){
        Storage storageSpace = Storage(_storageSpace);
        return storageSpace.getFProductFactoryAddress();
    }
    
    function changeNFProductFactoryAddress(address newValue) public onlyOwner(){
        Storage storageSpace = Storage(_storageSpace);
        storageSpace.setNFProductFactoryAddress(newValue);
    }
    
    function changeFProductFactoryAddress(address newValue) public onlyOwner(){
        Storage storageSpace = Storage(_storageSpace);
        storageSpace.setFProductFactoryAddress(newValue);
    }
    
    function getEntityFactoryAddress() public view returns (address){
        Storage storageSpace = Storage(_storageSpace);
        return storageSpace.getEntityFactoryAddress();
    }
    
    function changeEntityFactoryAddress(address newValue) public onlyOwner(){
        Storage storageSpace = Storage(_storageSpace);
        storageSpace.setEntityFactoryAddress(newValue);
    }
    
    function getProductBatchFactoryAddress() public view returns (address){
        Storage storageSpace = Storage(_storageSpace);
        return storageSpace.getProductBatchFactoryAddress();
    }
    
    function changeProductBatchFactoryAddress(address newValue) public onlyOwner(){
        Storage storageSpace = Storage(_storageSpace);
        storageSpace.setProductBatchFactoryAddress(newValue);
    }
    
    
    function getVerifierFactoryAddress() public view returns (address){
        Storage storageSpace = Storage(_storageSpace);
        return storageSpace.getVerifierFactoryAddress();
    }
    
    function changeVerifierFactoryAddress(address newValue) public onlyOwner(){
        Storage storageSpace = Storage(_storageSpace);
        storageSpace.setVerifierFactoryAddress(newValue);
    }
    
    function getEntityCount() public view returns (uint){
        Storage storageSpace = Storage(_storageSpace);
        return storageSpace.getEntityCount();
    }
    
    function getGLNToEntityContractAddress(string memory _gln) public view returns (address){
        Storage storageSpace = Storage(_storageSpace);
        return storageSpace.getGLNToEntityContractAddress(_gln);
    }
    
    function getAccountToEntityContractAddress(address _account) public view returns (address){
        Storage storageSpace = Storage(_storageSpace);
        return storageSpace.getAccountToEntityContractAddress(_account);
    }
    
    
    function getGLNToUserAccount(string memory _gln) public view returns (address){
        Storage storageSpace = Storage(_storageSpace);
        return storageSpace.getGLNToUserAccount(_gln);
    }

    
    function getUserAccountToGln(address _account) public view returns (string memory){
        Storage storageSpace = Storage(_storageSpace);
        return storageSpace.getUserAccountToGln(_account);
    }
    
    function getGLNToUserType(string memory _gln) public view returns (uint){
        Storage storageSpace = Storage(_storageSpace);
        return storageSpace.getGLNToUserType(_gln);
    }
    
    function getNFProductCount() public view returns (uint){
        Storage storageSpace = Storage(_storageSpace);
        return storageSpace.getNFProductCount();
    }
    
    function getFProductCount() public view returns (uint){
        Storage storageSpace = Storage(_storageSpace);
        return storageSpace.getFProductCount();
    }
    
    function getFProductToOwner(address _FProductAddress) public view returns (address){
        Storage storageSpace = Storage(_storageSpace);
        return storageSpace.getFProductToOwner(_FProductAddress);
    }
    
    function getNFProductToOwner(address _NFProductAddress) public view returns (address){
        Storage storageSpace = Storage(_storageSpace);
        return storageSpace.getNFProductToOwner(_NFProductAddress);
    }
    
    function getOwnerToFProducts(address _owner) public view returns (address[] memory){
        Storage storageSpace = Storage(_storageSpace);
        return storageSpace.getOwnerToFProducts(_owner);
    }
    
    function getOwnerToNFProducts(address _owner) public view returns (address[] memory){
        Storage storageSpace = Storage(_storageSpace);
        return storageSpace.getOwnerToNFProducts(_owner);
    }
    
    //
    function AddKey(bytes32 _key, uint256 _purpose, uint256 _type)
        public
        returns (bool success)
    {
        Storage storageSpace = Storage(_storageSpace);
        Identity entities = Identity(address(uint160(storageSpace.getAccountToEntityContractAddress(tx.origin))));
        return entities.addKey(_key, _purpose, _type);
    }
    
    function ChangeKeysRequired(uint256 purpose, uint256 number)
        public
    {
        Storage storageSpace = Storage(_storageSpace);
        Identity entities = Identity(address(uint160(storageSpace.getAccountToEntityContractAddress(tx.origin))));
        return entities.changeKeysRequired(purpose, number);
    }
    
    function DestroyAndSend(address _recipient)
        public
    {
        Storage storageSpace = Storage(_storageSpace);
        Identity entities = Identity(address(uint160(storageSpace.getAccountToEntityContractAddress(tx.origin))));
        return entities.destroyAndSend(_recipient);
    }
    
    function Pause()
        public
    {
        Storage storageSpace = Storage(_storageSpace);
        Identity entities = Identity(address(uint160(storageSpace.getAccountToEntityContractAddress(tx.origin))));
        return entities.pause();
    }
    
    function Unpause()
        public
    {
        Storage storageSpace = Storage(_storageSpace);
        Identity entities = Identity(address(uint160(storageSpace.getAccountToEntityContractAddress(tx.origin))));
        return entities.unpause();
    }
    
    function RefreshClaim(bytes32 _claimId)
        public
        returns (bool)
    {
        Storage storageSpace = Storage(_storageSpace);
        Identity entities = Identity(address(uint160(storageSpace.getAccountToEntityContractAddress(tx.origin))));
        return entities.refreshClaim(_claimId);
    }
    
    function AddrToKey(address addr)
        public
        view
        returns (bytes32)
    {
        Storage storageSpace = Storage(_storageSpace);
        Identity entities = Identity(address(uint160(storageSpace.getAccountToEntityContractAddress(tx.origin))));
        return entities.addrToKey(addr);
    }
    
    function GetClaimId(address issuer, uint256 topic)
        public
        view
        returns (bytes32)
    {
        Storage storageSpace = Storage(_storageSpace);
        Identity entities = Identity(address(uint160(storageSpace.getAccountToEntityContractAddress(tx.origin))));
        return entities.getClaimId(issuer, topic);
    }
    
    function GetKeysRequired(uint256 purpose)
        public
        view
        returns (uint256)
    {
        Storage storageSpace = Storage(_storageSpace);
        Identity entities = Identity(address(uint160(storageSpace.getAccountToEntityContractAddress(tx.origin))));
        return entities.getKeysRequired(purpose);
    }
    
    function GetSignatureAddress(bytes32 toSign, bytes memory signature)
        public
        view
        returns (address)
    {
        Storage storageSpace = Storage(_storageSpace);
        Identity entities = Identity(address(uint160(storageSpace.getAccountToEntityContractAddress(tx.origin))));
        return entities.getSignatureAddress(toSign, signature);
    }
    
    function GetKey(bytes32 _key)
        public
        view
        returns(uint256[] memory purposes, uint256 keyType, bytes32 key)
    {
        Storage storageSpace = Storage(_storageSpace);
        Identity entities = Identity(address(uint160(storageSpace.getAccountToEntityContractAddress(tx.origin))));
        return entities.getKey(_key); 
    }

    function GetKeysByPurpose(uint256 _purpose)
        public
        view
        returns(bytes32[] memory _keys) 
    {
        Storage storageSpace = Storage(_storageSpace);
        Identity entities = Identity(address(uint160(storageSpace.getAccountToEntityContractAddress(tx.origin))));
        return entities.getKeysByPurpose(_purpose); 
    }

    // function getKey(bytes32 _key)
    //     public
    //     view
    //     returns(uint256[] memory purposes)
    // {
    //     Storage storageSpace = Storage(_storageSpace);
    //     Identity entities = Identity(address(uint160(storageSpace.getAccountToEntityContractAddress(tx.origin))));
    //     return entities.getKey(_key); 
    // }
    
    function AddClaim(
        uint256 _topic,
        uint256 _scheme,
        address _issuer,
        bytes memory _signature,
        bytes memory _data,
        string memory _uri
    ) public
    returns (uint256 claimRequestId)
    {
        Storage storageSpace = Storage(_storageSpace);
        Identity entities = Identity(address(uint160(storageSpace.getAccountToEntityContractAddress(tx.origin))));
        return entities.addClaim(
            _topic,
            _scheme,
            _issuer,
            _signature,
            _data,
            _uri
        );
    }

    function Approve(uint256 _id, bool _approve) public returns (bool success) {
        Storage storageSpace = Storage(_storageSpace);
        Identity entities = Identity(address(uint160(storageSpace.getAccountToEntityContractAddress(tx.origin))));
        return entities.approve(_id, _approve);
    }
    
    function RemoveKey(bytes32 _key, uint256 _purpose) public returns (bool success) {
        Storage storageSpace = Storage(_storageSpace);
        Identity entities = Identity(address(uint160(storageSpace.getAccountToEntityContractAddress(tx.origin))));
        return entities.removeKey(_key, _purpose);
    }

    function Execute(address _to, uint256 _value, bytes memory _data) public returns (uint256 executionId) {
        Storage storageSpace = Storage(_storageSpace);
        Identity entities = Identity(address(uint160(storageSpace.getAccountToEntityContractAddress(tx.origin))));
        return entities.execute(_to, _value, _data);
    }

    function KeyHasPurpose(bytes32 _key, uint256 _purpose) public view returns (bool exists) {
        Storage storageSpace = Storage(_storageSpace);
        Identity entities = Identity(address(uint160(storageSpace.getAccountToEntityContractAddress(tx.origin))));
        return entities.keyHasPurpose(_key, _purpose);
    }

    function RemoveClaim(bytes32 _claimId) public returns (bool success) {
        Storage storageSpace = Storage(_storageSpace);
        Identity entities = Identity(address(uint160(storageSpace.getAccountToEntityContractAddress(tx.origin))));
        return entities.removeClaim(_claimId);
    }

    function GetClaim(bytes32 _claimId)
        public
        view
        returns(
            uint256 topic,
            uint256 scheme,
            address issuer,
            bytes memory signature,
            bytes memory data,
            string memory uri
        )
    {
        Storage storageSpace = Storage(_storageSpace);
        Identity entities = Identity(address(uint160(storageSpace.getAccountToEntityContractAddress(tx.origin))));
        return entities.getClaim(_claimId);
    }

    function GetClaimIdsByTopic(uint256 _topic)
        public
        view
        returns(bytes32[] memory claimIds)
    {
        Storage storageSpace = Storage(_storageSpace);
        Identity entities = Identity(address(uint160(storageSpace.getAccountToEntityContractAddress(tx.origin))));
        return entities.getClaimIdsByType(_topic);
    }
   
}
