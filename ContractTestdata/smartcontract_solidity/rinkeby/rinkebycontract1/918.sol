/**
 *Submitted for verification at Etherscan.io on 2019-02-04
*/

pragma solidity ^0.4.24;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
    * @return the address of the owner.
    */
    function owner() public view returns(address) {
        return _owner;
    }

    /**
    * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
    * @return true if `msg.sender` is the owner of the contract.
    */
    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }

    /**
    * @dev Allows the current owner to relinquish control of the contract.
    * @notice Renouncing to ownership will leave the contract without an owner.
    * It will not be possible to call the functions with the `onlyOwner`
    * modifier anymore.
    */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
    * @dev Allows the current owner to transfer control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
    * @dev Transfers control of the contract to a newOwner.
    * @param newOwner The address to transfer ownership to.
    */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
@title Data storage layer implementation
@author Bohdan Grytsenko
@notice Core contract which implements data storage for every entity
*/
contract BaseStorage {
    /// internal attributes ///
    mapping(bytes32 => uint256)         internal _uIntStorage;
    mapping(bytes32 => string)          internal _stringStorage;
    mapping(bytes32 => address)         internal _addressStorage;
    mapping(bytes32 => bytes32)         internal _bytes32Storage;
    mapping(bytes32 => bool)            internal _boolStorage;
    mapping(bytes32 => int256)          internal _intStorage;

    /// modifiers ///
    
    modifier accessRestriction() {
        _;
    }

    /**** Get Methods ***********/
    
    /**
    @notice accessor for address attribute type
    @param key storage key value
    */
    function getAddress(bytes32 key) external view returns (address) {
        return _addressStorage[key];
    }

    /**
    @notice accessor for uint attribute type
    @param key storage key value
    */
    function getUint(bytes32 key) external view returns (uint) {
        return _uIntStorage[key];
    }

    /**
    @notice accessor for string attribute type
    @param key storage key value
    */
    function getString(bytes32 key) external view returns (string memory) {
        return _stringStorage[key];
    } 

    /**
    @notice accessor for bytes32 attribute type
    @param key storage key value
    */
    function getBytes32(bytes32 key) external view returns (bytes32) {
        return _bytes32Storage[key];
    }

    /**
    @notice accessor for bool attribute type
    @param key storage key value
    */
    function getBool(bytes32 key) external view returns (bool) {
        return _boolStorage[key];
    }

    /**
    @notice accessor for int attribute type
    @param key storage key value
    */
    function getInt(bytes32 key) external view returns (int) {
        return _intStorage[key];
    }


    /**** Set Methods ***********/

    /**
    @notice modifier for address attribute type
    @param key storage key value
    @param value value to save into storage
    */
    function setAddress(bytes32 key, address value) external accessRestriction() {
        _addressStorage[key] = value;
    }

    /**
    @notice modifier for uint attribute type
    @param key storage key value
    @param value value to save into storage
    */
    function setUint(bytes32 key, uint value) external accessRestriction() {
        _uIntStorage[key] = value;
    }

    /**
    @notice modifier for string attribute type
    @param key storage key value
    @param value value to save into storage
    */
    function setString(bytes32 key, string value) external accessRestriction() {
        _stringStorage[key] = value;
    }

    /**
    @notice modifier for bytes32 attribute type
    @param key storage key value
    @param value value to save into storage
    */
    function setBytes32(bytes32 key, bytes32 value) external accessRestriction() {
        _bytes32Storage[key] = value;
    }
    
    /**
    @notice modifier for bool attribute type
    @param key storage key value
    @param value value to save into storage
    */
    function setBool(bytes32 key, bool value) external accessRestriction() {
        _boolStorage[key] = value;
    }
    
    /**
    @notice modifier for int attribute type
    @param key storage key value
    @param value value to save into storage
    */
    function setInt(bytes32 key, int value) external accessRestriction() {
        _intStorage[key] = value;
    }


    /**** Delete Methods ***********/
    
    /**
    @notice removal of address attribute type
    @param key storage key value
    */
    function deleteAddress(bytes32 key) external accessRestriction() {
        delete _addressStorage[key];
    }

    /**
    @notice removal of bytes32 attribute type
    @param key storage key value
    */
    function deleteUint(bytes32 key) external accessRestriction() {
        delete _uIntStorage[key];
    }

    /**
    @notice removal of string attribute type
    @param key storage key value
    */
    function deleteString(bytes32 key) external accessRestriction() {
        delete _stringStorage[key];
    }

    /**
    @notice removal of bytes32 attribute type
    @param key storage key value
    */
    function deleteBytes32(bytes32 key) external accessRestriction() {
        delete _bytes32Storage[key];
    }
    
    /**
    @notice removal of bool attribute type
    @param key storage key value
    */
    function deleteBool(bytes32 key) external accessRestriction() {
        delete _boolStorage[key];
    }
    
    /**
    @notice removal of int attribute type
    @param key storage key value
    */
    function deleteInt(bytes32 key) external accessRestriction() {
        delete _intStorage[key];
    }
}

/**
 * @title IBurnableERC20 interface
 * @dev Burnable interface for ERC20 token
 */
interface IBurnableERC20 {
    function burn(uint256 value) external;
    
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

/**
@title storage contract for LakeDiamond contract
@author Bohdan Grytsenko
@notice contract store all data from main contract to save it in case of redeploy main contract with new code
*/
contract LakeDiamondStorage is BaseStorage, Ownable {

    /// public fields ///

    address public lakeDiamondAddress;
    address public proposalStorageAdapterAddress;
    address public orderStorageAdapterAddress;
    IBurnableERC20 public tokenContract;

    /// constructors ///

    constructor (IBurnableERC20 token) public Ownable() {
        tokenContract = token;
    }

    /// modifiers ///
    
    modifier accessRestriction() {
        require(
            msg.sender == proposalStorageAdapterAddress || 
            msg.sender == orderStorageAdapterAddress || 
            msg.sender == lakeDiamondAddress,
            "Only allowed contract can write data to storage"
        );
        _;
    }

    /// public methods ///

    /**
    @notice set new address of main contract(accessible only from contract owner)
    @param contractAddress address of new LakeDiamond contract
    */
    function setLakeDiamondAddress(address contractAddress) public onlyOwner() {
        require(contractAddress != address(0), "New LakeDiamondAddress address must contain non zero address");
        lakeDiamondAddress = contractAddress;
    }

    /**
    @notice set new address of proposal storage adapter(accessible only from contract owner)
    @param contractAddress address of new proposal storage adapter contract
    */
    function setProposalStorageAdapterAddress(address contractAddress) public onlyOwner() {
        require(contractAddress != address(0), "New ProposalStorageAdapterAddress address must contain non zero address");
        proposalStorageAdapterAddress = contractAddress;
    }


    /**
    @notice set new address of order storage adapter(accessible only from contract owner)
    @param contractAddress address of new order storage adapter contract
    */
    function setOrderStorageAdapterAddress(address contractAddress) public onlyOwner() {
        require(contractAddress != address(0), "New OrderStorageAdapterAddress address must contain non zero address");
        orderStorageAdapterAddress = contractAddress;
    }
}

/**
 * @title Proposal storage and management 
 * @author Bohdan Hrytsenko
 * @notice Single point to manage proposals
 */
contract ProposalStorageAdapter {
    LakeDiamondStorage public lakeDiamondStorage;

    /// public fields ///

    bytes32 public constant enitityNameKey = keccak256("proposal");
    bytes32 public constant ownerColumnKey = keccak256("owner");
    bytes32 public constant priceColumnKey = keccak256("price");
    bytes32 public constant amountColumnKey = keccak256("amount");
    bytes32 public constant isActiveColumnKey = keccak256("isActive");
    bytes32 public constant lastProposalIdKey = keccak256("lastProposalIdKey");

    /// constructors ///

    constructor (LakeDiamondStorage lakeDiamondStorageContract) public {
        lakeDiamondStorage = lakeDiamondStorageContract;
    }

    /// modifiers ///

    modifier lakeDiamondContractOnly() {
        require(
            lakeDiamondStorage.lakeDiamondAddress() == msg.sender,
            "Only LakeDiamond contract can write data to storage"
        );
        _;
    }

    /// public methods ///

    /**
    @notice create proposal record in storage
    @param owner proposal owner, address
    @param price price per token in proposal, uint
    @param amount amount of tokens to sell, uint
    @return id of created record
     */
    function createProposal(address owner, uint price, uint amount)
    external 
    lakeDiamondContractOnly() 
    returns(uint256 newId) {
        newId = lakeDiamondStorage.getUint(lastProposalIdKey) + 1;
        bytes memory baseKey = getBaseKey(newId);

        setOwner(baseKey, owner);
        setPrice(baseKey, price);
        setAmount(baseKey, amount);
        setIsActive(baseKey, true);

        lakeDiamondStorage.setUint(lastProposalIdKey, newId);
    }


    /**
    @notice create proposal record in storage
    @return {
        "owner": "proposal ovenr address",
        "price": "proposal price uint",
        "amount": "amount of tokens to sell in proposal, uint",
        "isActive": "is proposal active, bool"
    }   
     */
    function getProposal(uint id) public view returns(address owner, uint price, uint amount, bool isActive) {
        uint lastProposalId = lakeDiamondStorage.getUint(lastProposalIdKey) + 1;
        require(lastProposalId >= id, "Proposal not exists");

        bytes memory baseKey = getBaseKey(id);

        owner = getOwner(baseKey);
        price = getPrice(baseKey);
        amount = getAmount(baseKey);
        isActive = getIsActive(baseKey);
    }
    
    /**
    @notice complete proposal
    @param id id of proposal
    @return is proposal active after completation
     */
    function completeProposal(uint id, uint amount)
    external
    lakeDiamondContractOnly()
    returns(uint withdrawnAmount, bool isActive) {
        bytes memory baseKey = getBaseKey(id);

        isActive = getIsActive(baseKey);
        require(isActive, "Proposal is not active");

        uint proposalAmount = getAmount(baseKey);
        withdrawnAmount = proposalAmount >= amount ? amount : proposalAmount;
        
        proposalAmount -= withdrawnAmount;
        if (proposalAmount == 0) {
            isActive = false;
            setIsActive(baseKey, isActive);
        }
        setAmount(baseKey, proposalAmount);
    }

    /**
    @notice withdraw proposal, set status to inactive
    @param id id of proposal
    @return amount of remaining tokens
    */
    function withdrawProposal(uint id) public lakeDiamondContractOnly() returns(uint proposalAmount) {
        bytes memory baseKey = getBaseKey(id);
        bool proposalIsActive = getIsActive(baseKey);
        require(proposalIsActive, "Proposal is not active.");

        proposalAmount = getAmount(baseKey); 
        require(proposalAmount > 0, "Proposal amount must be greater then 0.");
        
        setIsActive(baseKey, false);
    }

    /**
    @notice proposal owner getter
    @param id id of proposal
    @return proposal owner address
    */
    function getProposalOwner(uint id) external view returns (address owner) {
        owner = getOwner(getBaseKey(id));
    }

    /**
    @notice proposal price getter
    @param id id of proposal
    @return proposal price value
    */
    function getPrice(uint id) external view returns (uint price) {
        price = getPrice(getBaseKey(id));
    }

    /// private methods ///

    function setOwner(bytes memory baseKey, address  owner) private {
        bytes32 ownerKey = keccak256(abi.encode(baseKey, ownerColumnKey));
        lakeDiamondStorage.setAddress(ownerKey, owner);
    }

    function setPrice(bytes memory baseKey, uint price) private {
        bytes32 priceKey = keccak256(abi.encode(baseKey, priceColumnKey));
        lakeDiamondStorage.setUint(priceKey, price);
    }

    function setAmount(bytes memory baseKey, uint amount) private {
        bytes32 amountKey = keccak256(abi.encode(baseKey, amountColumnKey));
        lakeDiamondStorage.setUint(amountKey, amount);
    }

    function setIsActive(bytes memory baseKey, bool isActive) private {
        bytes32 isActiveKey = keccak256(abi.encode(baseKey, isActiveColumnKey));
        lakeDiamondStorage.setBool(isActiveKey, isActive);
    }

    function getOwner(bytes memory baseKey) private view returns(address ) { 
        bytes32 ownerKey = keccak256(abi.encode(baseKey, ownerColumnKey));
        return lakeDiamondStorage.getAddress(ownerKey);
    }

    function getPrice(bytes memory baseKey) private view returns(uint) { 
        bytes32 priceKey = keccak256(abi.encode(baseKey, priceColumnKey));
        return lakeDiamondStorage.getUint(priceKey);
    }

    function getAmount(bytes memory baseKey) private view returns(uint) { 
        bytes32 amountKey = keccak256(abi.encode(baseKey, amountColumnKey));
        return lakeDiamondStorage.getUint(amountKey);
    }

    function getIsActive(bytes memory baseKey) private view returns(bool) { 
        bytes32 isActiveKey = keccak256(abi.encode(baseKey, isActiveColumnKey));
        return lakeDiamondStorage.getBool(isActiveKey);
    }

    function getBaseKey(uint id) private pure returns (bytes memory key) {
        key = abi.encode(enitityNameKey, id);
    }
}

/**
 * @title Order storage and management 
 * @author Bohdan Hrytsenko
 * @notice Single point to manage orders
 */
contract OrderStorageAdapter {
    LakeDiamondStorage public lakeDiamondStorage;

    /// public constants ///

    bytes32 public constant enitityNameKey = keccak256("order");
    bytes32 public constant orderTypeColumnKey = keccak256("orderType");
    bytes32 public constant metadataColumnKey = keccak256("metadata");
    bytes32 public constant priceColumnKey = keccak256("price");
    bytes32 public constant ethAmountColumnKey = keccak256("ethAmount");
    bytes32 public constant tknAmountColumnKey = keccak256("tknAmount");
    bytes32 public constant createdByColumnKey = keccak256("createdBy");
    bytes32 public constant isProcessedColumnKey = keccak256("isProcessed");
    bytes32 public constant lastOrderIdKey = keccak256("lastOrderId");
    bytes32 public constant typeListKey = keccak256("order.TypeList");

    /// constructors ///

    constructor (LakeDiamondStorage lakeDiamondStorageContract) public {
        lakeDiamondStorage = lakeDiamondStorageContract;
    }

    /// modifiers ///
    modifier lakeDiamondContractOnly() {
        require(
            lakeDiamondStorage.lakeDiamondAddress() == msg.sender,
            "Only LakeDiamond contract can write data to storage"
        );
        _;
    }

    /// public methods ///

    /**
    @notice create new order record
    @param orderType type of order, uint
    @param metadata metadata, string
    @param price maximum price per token, uint
    @param tknAmount amount of tokens to buy, uint
    @param ethAmount amount of ether to sell, uint
    @param from order owner, address
    @return created recordId
    */
    function createOrder(
        uint orderType,
        string metadata,
        uint price,
        uint tknAmount,
        uint ethAmount,
        address  from)
        external
        lakeDiamondContractOnly()
        returns(uint newId) {

        newId = lakeDiamondStorage.getUint(lastOrderIdKey) + 1;
        bytes memory baseKey = abi.encode(enitityNameKey, newId);

        setOrderType(baseKey, orderType);
        setMetadata(baseKey, metadata);
        setPrice(baseKey, price);
        setTknAmount(baseKey, tknAmount);
        setEthAmount(baseKey, ethAmount);
        setCreatedBy(baseKey, from);
        setIsProcessed(baseKey, false);
        
        lakeDiamondStorage.setUint(lastOrderIdKey, newId);
    }

    /**
    @notice return order record by id
    @param Id id of order, uint
    @return {
        "orderType": "type of order, uint"
        "metadata": "metadata, string"
        "price": "maximum price per token, uint"
        "ethAmount": "amount of tokens to buy, uint"
        "tknAmount": "amount of ether to sell, uint"
        "from": "order owner, address"
        "isProcessed": "is order processed, bool"
    }
    */
    function getOrder(uint Id) 
        external 
        view
        returns(
        uint orderType,
        string memory metadata,
        uint price,
        uint ethAmount,
        uint tknAmount,
        address  from,
        bool isProcessed) {

        uint lastOrderId = lakeDiamondStorage.getUint(lastOrderIdKey);
        require(lastOrderId >= Id, "Order not exists");
        
        bytes memory baseKey = getBaseKey(Id);

        orderType = getOrderType(baseKey);
        metadata = getMetadata(baseKey);
        price = getPrice(baseKey);
        ethAmount = getEthAmount(baseKey);
        tknAmount = getTokenAmount(baseKey);
        from = getCreatedBy(baseKey);
        isProcessed = getIsProcessed(baseKey);
    }

    /**
    @notice close order
    @param orderId id of order
    */
    function closeOrder(uint orderId) public lakeDiamondContractOnly() {
        setIsProcessed(getBaseKey(orderId), true);
    }

    /**
    @notice create new order type
    @param id id of type
    @param description ty
    */
    function createOrderType(uint id, string memory description) public lakeDiamondContractOnly() {
        lakeDiamondStorage.setString(getOrderTypeKey(id), description);
    }

    /**
    @notice check if order type exist
    @param id id of type
    */
    function getIsOrderTypeExist(uint id) public view returns (bool) {
        string memory description = lakeDiamondStorage.getString(getOrderTypeKey(id));
        return bytes(description).length > 0;
    }


    /**
    @notice get order created by field value
    @param id id of order
    */
    function getOrderCreatedBy(uint id) public view returns (address ) {
        return getCreatedBy(getBaseKey(id));
    }

    /**
    @notice get order price field value
    @param id id of order
    */
    function getPrice(uint id) public view returns(uint value) {
        bytes memory baseKey = getBaseKey(id);
        value = getPrice(baseKey);
    }

    /**
    @notice get order ether amount field value
    @param id id of order
    */
    function getEthAmount(uint id) public view returns(uint value) {
        bytes memory baseKey = getBaseKey(id);
        value = getEthAmount(baseKey);
    }

    /**
    @notice get order token amount field value
    @param id id of order
    */
    function getTokenAmount(uint id) public view returns(uint value) {
        bytes memory baseKey = getBaseKey(id);
        value = getTokenAmount(baseKey);
    }

    /// private methods ///

    function setOrderType(bytes memory baseKey, uint value) private {
        bytes32 orderTypeKey = keccak256(abi.encode(baseKey, orderTypeColumnKey));
        lakeDiamondStorage.setUint(orderTypeKey, value);
    }

    function setMetadata(bytes memory baseKey, string memory value) private {
        bytes32 metadataKey = keccak256(abi.encode(baseKey, metadataColumnKey));
        lakeDiamondStorage.setString(metadataKey, value);
    }

    function setPrice(bytes memory baseKey, uint value) private {
        bytes32 priceKey = keccak256(abi.encode(baseKey, priceColumnKey));
        lakeDiamondStorage.setUint(priceKey, value);
    }

    function setEthAmount(bytes memory baseKey, uint value) private {
        bytes32 ethAmountKey = keccak256(abi.encode(baseKey, ethAmountColumnKey));
        lakeDiamondStorage.setUint(ethAmountKey, value);
    }

    function setTknAmount(bytes memory baseKey, uint value) private {
        bytes32 tknAmountKey = keccak256(abi.encode(baseKey, tknAmountColumnKey));
        lakeDiamondStorage.setUint(tknAmountKey, value);
    }

    function setCreatedBy(bytes memory baseKey, address  value) private {
        bytes32 createdByKey = keccak256(abi.encode(baseKey, createdByColumnKey));
        lakeDiamondStorage.setAddress(createdByKey, value);
    }
    
    function setIsProcessed(bytes memory baseKey, bool value) private {
        bytes32 isProcessedKey = keccak256(abi.encode(baseKey, isProcessedColumnKey));
        lakeDiamondStorage.setBool(isProcessedKey, value);
    }
    
    function getOrderType(bytes memory baseKey) private view returns(uint value) {
        bytes32 orderTypeKey = keccak256(abi.encode(baseKey, orderTypeColumnKey));
        value = lakeDiamondStorage.getUint(orderTypeKey);
    }

    function getMetadata(bytes memory baseKey) private view returns(string memory value) {
        bytes32 metadataKey = keccak256(abi.encode(baseKey, metadataColumnKey));
        value = lakeDiamondStorage.getString(metadataKey);
    }

    function getPrice(bytes memory baseKey) private view returns(uint value) {
        bytes32 priceKey = keccak256(abi.encode(baseKey, priceColumnKey));
        value = lakeDiamondStorage.getUint(priceKey);
    }

    function getEthAmount(bytes memory baseKey) private view returns(uint value) {
        bytes32 ethAmountKey = keccak256(abi.encode(baseKey, ethAmountColumnKey));
        value = lakeDiamondStorage.getUint(ethAmountKey);
    }

    function getTokenAmount(bytes memory baseKey) private view returns(uint value) {
        bytes32 tknAmountKey = keccak256(abi.encode(baseKey, tknAmountColumnKey));
        value = lakeDiamondStorage.getUint(tknAmountKey);
    }

    function getCreatedBy(bytes memory baseKey) private view returns(address  value) {
        bytes32 createdByKey = keccak256(abi.encode(baseKey, createdByColumnKey));
        value = lakeDiamondStorage.getAddress(createdByKey);
    }

    function getIsProcessed(bytes memory baseKey) private view returns(bool value) {
        bytes32 isProcessedKey = keccak256(abi.encode(baseKey, isProcessedColumnKey));
        value = lakeDiamondStorage.getBool(isProcessedKey);
    }

    function getBaseKey(uint index) private pure returns(bytes memory) {
        return abi.encode(enitityNameKey, index);
    }

    function getOrderTypeKey(uint id) private pure returns (bytes32 orderTypeKey) {
        orderTypeKey = keccak256(abi.encode(typeListKey, id));
    }
}

/**
 * @title Main contract to work with orders and proposals
 * @author Bohdan Hrytsenko
 * @notice Main contract to work with orders and proposals
 */
contract LakeDiamond is Ownable {
    using SafeMath for uint;

    /// public fiels ///

    address public backendAddress;
    LakeDiamondStorage public lakeDiamondStorage;
    bool public activeOrderExists;

    string public subOwnerColumnKey = "LikeDiamondsSubOwner";
    string public whiteListKey = "WhiteList";

    /// events ///

    event NewSubOwner(address subOwner);
    event RemovedSubOwner(address subOwner);

    event NewOrderType(uint indexed id, string description);

    event ProposalCreated(address indexed from, uint indexed price, uint indexed amount, uint id);
    event ProposalWithdrawn(uint indexed amount, uint indexed id, bool isActive);
    event ProposalCompleted(uint indexed id, uint indexed tokenAmount, uint indexed orderId, uint etherAmount, bool isActive);
    event BannedAddress(uint indexed newId, address bannedAddress);

    event NewOrder(
        address indexed from,
        uint indexed price,
        uint indexed ethAmount,
        uint tknAmount,
        uint typeId,
        string metadata,
        uint orderId
    );
    event OrderProcessed(uint indexed id, uint rest);

    
    event AddressAddedToWhiteList(address indexed userAddress, uint indexed allowedTokenAmount);

    /// constructors ///
    
    constructor (address storageAddress, address backend) public {
        require(storageAddress != address(0), "Storage address must contain non zero address");
        lakeDiamondStorage = LakeDiamondStorage(storageAddress);
        setBackendAddress(backend);
    }

    /// public methods ///

    /**
    @notice set new backend address(accessible only from contract owner address)
    @param newAddress new backend address
    */
    function setBackendAddress(address newAddress) public onlyOwner() {
        require(newAddress != address(0), "backend address must contain non zero address");
        backendAddress = newAddress;
    }

    /**
    @notice set address to whitelist and set amount of allowed tokens to use in proposal
    (accessible only from backend address)
    @param userAddress address to add to whitelist
    @param allowedTokenAmount amount of tokens alowed to use in proposal, uint
    */
    function addAddressToWhitelist(address userAddress, uint allowedTokenAmount) public {
        require(msg.sender == backendAddress, "You can add address to whitelist only from backend address");

        bytes32 whitelistKey = getWhitelistKey(userAddress);
        lakeDiamondStorage.setUint(whitelistKey, allowedTokenAmount);
        emit AddressAddedToWhiteList(userAddress, allowedTokenAmount);
    }


    /**
    @notice get amount of allowed tokens to use in proposal
    @param userAddress address to add to whitelist
    @return amount of tokens alowed to use in proposal, uint
    */
    function getAllowedAmountTokens(address userAddress) public view returns(uint allowedTokenAmount) {
        bytes32 whitelistKey = getWhitelistKey(userAddress);
        allowedTokenAmount = lakeDiamondStorage.getUint(whitelistKey);
    }

    /**
    @notice add address to subowners list(accessible only from contract owner address)
    @param addresses address list to add to subowners list, address[]
    */
    function addSubOwners(address[] addresses) external onlyOwner() {
        for (uint i = 0; i < addresses.length; i++) {
            bytes32 subownerKey = getSubOwnerKey(addresses[i]);
            lakeDiamondStorage.setBool(subownerKey, true);
            emit NewSubOwner(addresses[i]);
        }
    }

    /**
    @notice remove address from subowners list(accessible only from contract owner address)
    @param addresses address to remove from subowners list, address[]
    */
    function removeSubOwners(address[] addresses) external onlyOwner() {
        for (uint i = 0; i < addresses.length; i++) {
            bytes32 subownerKey = getSubOwnerKey(addresses[i]);
            lakeDiamondStorage.deleteBool(subownerKey);
            emit NewSubOwner(addresses[i]);
        }
    }


    /**
    @notice check is address in subowners list
    @param subOwnerAddress address to check
    @return is address in subowners list, bool
    */
    function getIsSubOwner(address subOwnerAddress) public view returns(bool) {
        bytes32 subownerKey = getSubOwnerKey(subOwnerAddress);
        return lakeDiamondStorage.getBool(subownerKey);
    }

    /**
    @notice create new proposal
    @param price price per token, uint
    @param amount amount of tokens in proposal, uint
    */
    function createProposal(uint price, uint amount) public {
        require(price != 0 && amount != 0, "Price and amount must be greater then 0");

        //uint allowedAmount = getAllowedAmountTokens(msg.sender);
        //require(allowedAmount >= amount, "You can`t create proposal for more tokens then allowed to your account");

        uint256 id = getProposalStorageAdapter().createProposal(msg.sender, price, amount);        
        emit ProposalCreated(msg.sender, price, amount, id);
        
        getToken().transferFrom(msg.sender, address(this), amount);
    }

    /**
    @notice withdraw tokens from proposal and close it
    @param id id of proposal to withdraw
    */
    function withdrawProposal(uint id) public {
        require(!activeOrderExists, "You cant withdraw proposal when active order exists");
        
        ProposalStorageAdapter proposalStorageAdapter = getProposalStorageAdapter();
        address  proposalOwner = proposalStorageAdapter.getProposalOwner(id);
        require(proposalOwner == msg.sender, "Withdrawall accessible only from proposal owner address");
        
        uint withdrawAmount = proposalStorageAdapter.withdrawProposal(id);        
        emit ProposalWithdrawn(withdrawAmount, id, false);
        
        lakeDiamondStorage.tokenContract().transfer(proposalOwner, withdrawAmount);
    }

    /**
    @notice create new order record
    @param typeId id of order type, uint
    @param metadata text information about proposal, string
    @param price maximum price per token in proposal, uint
    @param tknAmount amount of tokens to buy 
    */
    function createOrder(uint typeId, string memory metadata, uint price, uint tknAmount, address[] memory bannedAddresses) public payable {
        require(msg.value > 0);
        require(!activeOrderExists, "You cant create more then one active order. Close previous order to create new.");
        require(getIsSubOwner(msg.sender), "Creating order not allowed from this adress");

        OrderStorageAdapter orderStorageAdapter = getOrderStorageAdapter();
        require(orderStorageAdapter.getIsOrderTypeExist(typeId), "Order type not exist");

        activeOrderExists = true;
        uint newId = orderStorageAdapter.createOrder(typeId, metadata, price, tknAmount, msg.value, msg.sender);
        emit NewOrder(msg.sender, price, msg.value, tknAmount, typeId, metadata, newId);

        for (uint i = 0; i < bannedAddresses.length; i++) {
            emit BannedAddress(newId, bannedAddresses[i]);
        }
    }

    /**
    @notice match proposals to order and send rest of eth back to order`s creator(accessible only from backend address)
    @param orderId id of order, uint
    @param ids list of proposals ids, uint[]
    */
    function matchOrder(uint orderId, uint[] memory ids) public {
        require(msg.sender == backendAddress, "Matching order allowed only from backend address");

        OrderStorageAdapter orderStorageAdapter = getOrderStorageAdapter();
        uint orderPrice = orderStorageAdapter.getPrice(orderId);
        uint orderEtherAmount = orderStorageAdapter.getEthAmount(orderId);
        uint orderTokenAmount = orderStorageAdapter.getTokenAmount(orderId);

        uint orderCoeficient = (orderPrice * orderTokenAmount) / orderEtherAmount;

        ProposalStorageAdapter proposalStorageAdapter = getProposalStorageAdapter();
        for (uint i = 0; i < ids.length; i++) {
            uint proposalId = ids[i];

            (uint proposalTokenAmount, bool isActive) = proposalStorageAdapter.completeProposal(proposalId, orderTokenAmount);
            orderTokenAmount -= proposalTokenAmount;
            getToken().burn(proposalTokenAmount);

            uint proposalEtherAmount = proposalTokenAmount * proposalStorageAdapter.getPrice(proposalId) / orderCoeficient;
            address proposalOwner = proposalStorageAdapter.getProposalOwner(proposalId);
            proposalOwner.transfer(proposalEtherAmount);

            emit ProposalCompleted(proposalId, proposalTokenAmount, orderId, proposalEtherAmount, isActive);

            orderEtherAmount -= proposalEtherAmount;
            if (orderEtherAmount == 0) {
                break;
            }
        }
        orderStorageAdapter.closeOrder(orderId);
        emit OrderProcessed(orderId, address(this).balance);
        orderStorageAdapter.getOrderCreatedBy(orderId).transfer(address(this).balance);

        activeOrderExists = false;
    }

    /**
    @notice set new order type
    @param id type id, uint
    @param description description of order type, string
    */
    function setOrderType(uint id, string memory description) public {
        require(getIsSubOwner(msg.sender), "Setting ordertypes not allowed from this adress");

        getOrderStorageAdapter().createOrderType(id, description);
        emit NewOrderType(id, description);
    }

    /// private methods ///

    function getOrderStorageAdapter() private view returns (OrderStorageAdapter orderStorageAdapter) {
        orderStorageAdapter = OrderStorageAdapter(lakeDiamondStorage.orderStorageAdapterAddress());
    }

    function getProposalStorageAdapter() private view returns (ProposalStorageAdapter proposalStorageAdapter) {
        proposalStorageAdapter = ProposalStorageAdapter(lakeDiamondStorage.proposalStorageAdapterAddress());
    }

    function getToken() private view returns (IBurnableERC20 token) {
        token = IBurnableERC20(lakeDiamondStorage.tokenContract());
    }
    
    function getWhitelistKey(address userAddress) private view returns (bytes32 key) {
        key = keccak256(abi.encode(whiteListKey, userAddress));
    }

    function getSubOwnerKey(address subOwnerAddress) private view returns (bytes32) {
        return keccak256(abi.encode(subOwnerColumnKey, subOwnerAddress));
    }
}
