pragma solidity ^0.5.4;

import "./AGDOwnable.sol"; 

contract Storage is Ownable {
    
    event AccountIsLost(string GlobalIdentifierNumber, bool Approved, address NewAccount);
    
    address fProductFactoryAddress;
    address nfProductFactoryAddress;
    address entityFactory;
    address verifierFactory;
    address productBatchFactory;
    address public genieIdentity;
    address public genieToken;
    address delegation;
    
    
    mapping (string => address) glnToUserAccount;
    mapping (address => string) userAccountToGLN;
    mapping (string => address) glnToEntityContractAddress;
    mapping (address => address) accountToEntityContractAddress;
    mapping (string => uint) glnToUserType;
    mapping (address => address[]) ownerToNFProducts;
    mapping (address => address[]) ownerToFProducts;
    mapping (address => address) nfProductToOwner;
    mapping (address => address) fProductToOwner;
    mapping (address => address) oldAccountToNewAccount;
    mapping (address => address) newAccountFromOldAccount;
    mapping (address => bool) accountWasLost;
    mapping (address => address[]) public nfProductToListProductBatch;
    mapping (address => address) public productBatchToNFProduct;
    
    bool public firstTimesIdentity = true;
    bool public firstTimesToken = true;
    uint entitiesCount;
    uint nfproductCount;
    uint fproductCount;
    
    modifier infirstTimesIdentity (){
        require(firstTimesIdentity == true);
        _;
    }
    
    modifier infirstTimesToken (){
        require(firstTimesToken == true);
        _;
    }
    
    modifier onlyGenieIdentity(address _addr){
        require(_addr == genieIdentity);
        _;
    }
    
    modifier onlyGenieToken(address _addr){
        require(_addr == genieToken);
        _;
    }
    
    function activationGenieIdentity(address _genieAddress) public infirstTimesIdentity () {
        genieIdentity = _genieAddress;
        firstTimesIdentity = false;
    }
    
    function activationGenieToken(address _genieAddress) public infirstTimesToken () {
        genieToken = _genieAddress;
        firstTimesToken = false;
    }

    function changeGenie(address newGenieIdentityAddress, address newGenieTokenAddress) public onlyGenieIdentity(msg.sender) 
    {
        genieIdentity = newGenieIdentityAddress;
        genieToken = newGenieTokenAddress;
    }
    
    function getGenieIdentityAddress() public view returns (address){
        return genieIdentity;
    }
    
    function getGenieTokenAddress() public view returns (address){
        return genieToken;
    }
    
    function getFProductFactoryAddress() public view returns (address){
        return fProductFactoryAddress;
    }
    
    function setFProductFactoryAddress(address newValue) public {
        fProductFactoryAddress = newValue;
    }
    
    function getNFProductFactoryAddress() public view returns (address){
        return nfProductFactoryAddress;
    }
    
    function setNFProductFactoryAddress(address newValue) public {
        nfProductFactoryAddress = newValue;
    }
    
    function getProductBatchFactoryAddress() public view returns (address){
        return productBatchFactory;
    }
    
    function setProductBatchFactoryAddress(address newValue) public {
        productBatchFactory = newValue;
    }
    
    function getEntityFactoryAddress() public view returns (address){
        return entityFactory;
    }
    
    function setEntityFactoryAddress(address newValue) public {
        entityFactory = newValue;
    }
    
    
    function getVerifierFactoryAddress() public view returns (address){
        return verifierFactory;
    }
    
    function setVerifierFactoryAddress(address newValue) public {
        verifierFactory = newValue;
    }
    
    
    function inscreaseEntityCount() public {
        entitiesCount++;
    }
    
    function getEntityCount() public view returns (uint){
        return entitiesCount;
    }
    
    function inscreaseNFProductCount() public {
        nfproductCount++;
    }
    
    function getNFProductCount() public view returns (uint){
        return nfproductCount;
    }
    
    function inscreaseFProductCount() public {
        fproductCount++;
    }
    
    function getFProductCount() public view returns (uint){
        return fproductCount;
    }
    
    function getGLNToEntityContractAddress(string memory _gln) public view returns (address){
        return glnToEntityContractAddress[_gln];
    }
    
    function setGLNToEntityContractAddress(string memory _gln, address _contractAddress) public {
        glnToEntityContractAddress[_gln] = _contractAddress;
    }
    
    function getAccountToEntityContractAddress(address _account) public view returns (address){
        return accountToEntityContractAddress[_account];
    }
    
    function setAccountToEntityContractAddress(address _account, address _contractAddress) public {
        accountToEntityContractAddress[_account] = _contractAddress;
    }
    
    function getGLNToUserAccount(string memory _gln) public view returns (address){
        return glnToUserAccount[_gln];
    }
    
    function setGLNToUserAccount(string memory _gln, address _account) public {
        glnToUserAccount[_gln] = _account;
    }
    
    function getUserAccountToGln(address _account) public view returns (string memory){
        return userAccountToGLN[_account];
    }
    
    function setUserAccountToGln(string memory _gln, address _account) public {
        userAccountToGLN[_account] = _gln;
    }
    
    function getGLNToUserType(string memory _gln) public view returns (uint){
        return glnToUserType[_gln];
    }
    
    function setGLNToUserType(string memory _gln, uint _type) public {
        glnToUserType[_gln] = _type;
    }
    
    function getOwnerToNFProducts(address _owner) public view returns (address[] memory){
        return ownerToNFProducts[_owner];
    }
    
    function setOwnerToNFProducts(address _owner, address _NFProductAddress) public {
        ownerToNFProducts[_owner].push(_NFProductAddress);
    }
    
    function getOwnerToFProducts(address _owner) public view returns (address[] memory){
        return ownerToFProducts[_owner];
    }
    
    function setOwnerToFProducts(address _owner, address _FProductAddress) public {
        ownerToFProducts[_owner].push(_FProductAddress);
    }

    function getNFProductToOwner(address _NFProductAddress) public view returns (address){
        return nfProductToOwner[_NFProductAddress];
    }
    
    function setNFProductToOwner(address _owner, address _NFProductAddress) public {
        nfProductToOwner[_NFProductAddress] = _owner;
    }
    
    function getFProductToOwner(address _FProductAddress) public view returns (address){
        return fProductToOwner[_FProductAddress];
    }
    
    function setFProductToOwner(address _owner, address _FProductAddress) public {
        fProductToOwner[_FProductAddress] = _owner;
    }
    
    function setDelegationAccount(address _delegation) public onlyGenieIdentity(msg.sender) {
        delegation = _delegation;
    }
    
    function getDelegationAccount() public view returns (address) {
        return delegation;
    }
    
    function checkAccountWasLost(address account) public view returns (bool) {
        return accountWasLost[account];
    }
    
    function lostAccount(string memory gln, bool approved, address newAccount) public {
        emit AccountIsLost(gln, approved, newAccount);
        accountWasLost[glnToUserAccount[gln]] = true;
        oldAccountToNewAccount[glnToUserAccount[gln]] = newAccount;
        newAccountFromOldAccount[newAccount] = glnToUserAccount[gln];
        userAccountToGLN[newAccount] = gln;
        accountToEntityContractAddress[newAccount] = glnToEntityContractAddress[gln];
        // for (uint i=0; i<=ownerToNFProducts[glnToUserAccount[gln]].length; i++){
        //     ownerToNFProducts[newAccount].push(ownerToNFProducts[glnToUserAccount[gln]][i]);
        // }
        // for (uint i=0; i<=ownerToFProducts[glnToUserAccount[gln]].length; i++){
        //     ownerToFProducts[newAccount].push(ownerToFProducts[glnToUserAccount[gln]][i]);
        // }
        glnToUserAccount[gln] = newAccount;
    }
    
    function getOldAccountToNewAccount(address _oldAccount) public view returns (address) {
        return oldAccountToNewAccount[_oldAccount];
    }
    
    function getNewAccountFromOldAccount(address _newAccount) public view returns (address) {
        return newAccountFromOldAccount[_newAccount];
    }
    
    function setNFProductToListProductBatch(address _batchProductAddress, address _nfProductAddress) public {
        nfProductToListProductBatch[_nfProductAddress].push(_batchProductAddress);
    }
    
    function getNFProductToListProductBatch(address _nfProductAddress) public view returns (address[] memory){
        return nfProductToListProductBatch[_nfProductAddress];
    }
    
    function setBatchProductToNFProduct(address _batchProductAddress, address _nfProductAddress) public {
        productBatchToNFProduct[_batchProductAddress] = _nfProductAddress;
    }
    
    function getBatchProductToNFProduct(address _batchProductAddress) public view returns (address){
        return productBatchToNFProduct[_batchProductAddress];
    }
    
}
