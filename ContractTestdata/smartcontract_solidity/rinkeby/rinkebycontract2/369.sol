/**
 *Submitted for verification at Etherscan.io on 2019-07-28
*/

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: openzeppelin-solidity/contracts/access/Roles.sol

pragma solidity ^0.5.0;

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

// File: openzeppelin-solidity/contracts/access/roles/PauserRole.sol

pragma solidity ^0.5.0;


contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/lifecycle/Pausable.sol

pragma solidity ^0.5.0;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is PauserRole {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// File: contracts/OnlineMarket.sol

pragma solidity 0.5.8;



/*
* @title OnlineMarket
*
* @dev This contract allows the addition and removal of admins and storefront owners
*
*/
contract OnlineMarket is Ownable, Pausable{

    //Owner
    //address owner;

    // Admin mapping
    mapping(address => bool) private admins;

    //Mapping of StoreOwner approved or not by Admin
    mapping(address => bool) private storeOwnerApprovalMapping;

    // Hold the requested Store Owners
    address[] private requestedStoreOwners;
    // Hold the requested Store Owners index against store owner Ids
    mapping(address => uint) private requestedStoreOwnersIndex;

    // Hold the approved Store Owners
    address[] private approvedStoreOwners;
    // Hold the approved Store Owners index against store owner Ids
    mapping(address => uint) private approvedStoreOwnersIndex;

    //Events which are emitted at various points
    event LogAdminAdded(address adminAddress);
    event LogAdminRemoved(address adminAddress);
    event LogStoreOwnersApproved(address storeOwner);
    event LogStoreOwnerRemoved(address storeOwner);
    event LogStoreOwnerAdded(address storeOwner);

    // Modifier to restrict function calls to only admin
    modifier onlyAdmin(){
        require(admins[msg.sender] == true);
        _;
    }

    /** @dev The account that deploys contract is made admin.
	*/
    constructor() public{
        admins[msg.sender] = true;
    }

   /** @dev Function is to add an Admin. Admins can add more admins.
	* @param adminAddress Address of the Admin
	*/
    function addAdmin(address adminAddress) public onlyAdmin whenNotPaused{
        admins[adminAddress] = true;
        emit LogAdminAdded(adminAddress);
    }

    /** @dev Function is to remove an Admin. OnlyOwner can remove admins
	* @param adminAddress Address of the Admin
	*/
    function removeAdmin(address adminAddress) public onlyOwner whenNotPaused{
        require(admins[adminAddress] == true);
        admins[adminAddress] = false;
        emit LogAdminRemoved(adminAddress);
    }

    /** @dev Function is to check if an address is Admin or not.
	* @param adminAddress Address of the Admin
    * @return true if address is admin otherwise false
	*/
    function checkAdmin(address adminAddress) public view returns(bool){
        return admins[adminAddress];
    }

    /** @dev Function is to view a requested StoreOwner at a particular index
	* @param index requested store owner index
    * @return address of requestedStoreOwner at the requested index
	*/
    function viewRequestedStoreOwner(uint index) public view onlyAdmin returns (address){
        return requestedStoreOwners[index];
    }

    /** @dev Function is to view all requested StoreOwners
    * @return addresses of all the requestedStoreOwner
	*/
    function viewRequestedStoreOwners() public view onlyAdmin returns (address[] memory){
        return requestedStoreOwners;
    }

    /** @dev Function is to view an approved StoreOwners at requested index
    * @return addresses of the approvedStoreOwner
	*/
    function viewApprovedStoreOwner(uint index) public view onlyAdmin returns (address){
        return approvedStoreOwners[index];
    }

    /** @dev Function is to view all approved StoreOwners
    * @return addresseses of all the approved StoreOwner
	*/
    function viewApprovedStoreOwners() public view onlyAdmin returns (address[] memory){
        return approvedStoreOwners;
    }

    /** @dev Function is to approve the Stores
    * @param storeOwner address
	*/
    function approveStoreOwners(address storeOwner) public onlyAdmin whenNotPaused{
        //Updated mapping with status of approval
        storeOwnerApprovalMapping[storeOwner] = true;
        // remove it from requested store owners
        removeRequestedStoreOwner(storeOwner);
        // Add it to approved store owners
        approvedStoreOwners.push(storeOwner);
        approvedStoreOwnersIndex[storeOwner] = approvedStoreOwners.length-1;
        emit LogStoreOwnersApproved(storeOwner);
    }

    /** @dev Function is to remove the approved storeOwner
    * @param storeOwner address
    * @return true if store is removed otherwise false
	*/
    function removeStoreOwner(address storeOwner) public onlyAdmin whenNotPaused returns(bool){
        //Updated mapping with false
        storeOwnerApprovalMapping[storeOwner] = false;
        // remove it from approved store owners
        removeApprovedStoreOwner(storeOwner);
        emit LogStoreOwnerRemoved(storeOwner);
        return true;
    }

    /** @dev Function is to check the status of the store owner
    * @param storeOwner address
    * @return true if store is approved otherwise false
	*/
    function checkStoreOwnerStatus(address storeOwner) public view returns(bool){
        return storeOwnerApprovalMapping[storeOwner];
    }

    /** @dev Function is to add store owner
    * @return true if store is added otherwise false
	*/
    function addStoreOwner() public whenNotPaused returns(bool){
        require(storeOwnerApprovalMapping[msg.sender] == false);
        requestedStoreOwners.push(msg.sender);
        requestedStoreOwnersIndex[msg.sender] = requestedStoreOwners.length-1;
        emit LogStoreOwnerAdded(msg.sender);
        return true;
    }

     /** @dev Function is to get requested store owners length
    * @return length of requestedStoreOwners
	*/
    function getRequestedStoreOwnersLength() public view returns(uint){
        return requestedStoreOwners.length;
    }

     /** @dev Function is to get approved store owners length
    * @return length of approvedStoreOwners
	*/
    function getApprovedStoreOwnersLength() public view returns(uint){
        return approvedStoreOwners.length;
    }

    /** @dev Function is to remove the requestedStoreOwner
    * @param storeOwner address
	*/
    function removeRequestedStoreOwner(address storeOwner) private onlyAdmin whenNotPaused {
        uint index = requestedStoreOwnersIndex[storeOwner];
        if (requestedStoreOwners.length > 1) {
            requestedStoreOwners[index] = requestedStoreOwners[requestedStoreOwners.length-1];
        }
        requestedStoreOwners.length--;
    }

    /** @dev Function is to remove approvedStoreOwner
    * @param storeOwner address
	*/
    function removeApprovedStoreOwner(address storeOwner) private onlyAdmin whenNotPaused{
        uint index = approvedStoreOwnersIndex[storeOwner];
        if (approvedStoreOwners.length > 1) {
            approvedStoreOwners[index] = approvedStoreOwners[approvedStoreOwners.length-1];
        }
        approvedStoreOwners.length--;
    }

}

// File: contracts/StoreFront.sol

pragma solidity 0.5.8;




/*
* @title StoreFront
*
* @dev This contract allows storeowners to manage their stores, add/remove products from store and buyers to buy the products
*
*/
contract StoreFront is Ownable, Pausable{

    //OnlineMarket Instance
    OnlineMarket public onlineMarketInstance;


    /** @dev Constructor to link the Marketplace contract
	* @param onlineMarketContractAddress to link OnlineMarket contract
	*/
    constructor(address onlineMarketContractAddress) public {
        onlineMarketInstance = OnlineMarket(onlineMarketContractAddress);
    }

    /** @dev Struct that hold Stores data
	* @param storeId Store Id
	* @param storeName Store name
	* @param storeOwner address of the storeOwner
	* @param balance Store balance
	*/
    struct Store {
        bytes32 storeId;
        string storeName;
        address storeOwner;
        uint balance;
    }

    /** @dev Struct that hold Products data
	* @param productId ProductId
	* @param productName Product name
	* @param description description of the Product
    * @param price price of the Product
	* @param quantity quantity of the product in a store
    * @param storeId Store Id
	*/
    struct Product {
        bytes32 productId;
        string productName;
        string description;
        uint price;
        uint quantity;
        bytes32 storeId;
    }

    // Hold all the stores
    bytes32[] private  stores;
    // Hold mapping of the stores with index
    mapping(bytes32 => uint) private storesIndex;

     // Mapping Stores with StoreId
    mapping(bytes32 => Store) private storeById;

    // Mapping Store Owners with StoreIds
    mapping(address =>  bytes32[]) private storesByOwners;

    // Mapping Products by Products Id
    mapping(bytes32 => Product) private productsById;

    //Mapping of Product by Store
    mapping(bytes32 => bytes32[]) private productsByStore;

    //Events which are emitted at various points
    event LogStoreCreated(bytes32 storeId);
    event LogStoreRemoved(bytes32 storeId);
    event LogProductAdded(bytes32 productId);
    event LogProductRemoved (bytes32 productId,bytes32 storefrontId);
    event LogBalanceWithdrawn(bytes32 storeId, uint storeBalance);
    event LogPriceUpdated (bytes32 productId,uint oldPrice,uint newPrice);
    event LogProductSold(bytes32 productId, bytes32 storeId, uint price, uint buyerQty, uint amount, address buyer, uint remainingQuantity);

    // Modifier to to restrict function calls to only approved store owner
    modifier onlyApprovedStoreOwner() {
        require(onlineMarketInstance.checkStoreOwnerStatus(msg.sender) == true);
        _;
    }

    // Modifier to to restrict function calls to the store owner who created the store
    modifier onlyStoreOwner(bytes32 storeId) {
        require(storeById[storeId].storeOwner == msg.sender);
        _;
    }

    /** @dev Function is to create the store by approved store owner
	* @param storeName Name of the store
    * @return storeId
	*/
    function createStore(string memory storeName) public onlyApprovedStoreOwner whenNotPaused returns(bytes32){
        bytes32 storeId = keccak256(abi.encodePacked(msg.sender, storeName, now));
        Store memory store = Store(storeId, storeName, msg.sender, 0);
        storeById[storeId] = store;
        storesByOwners[msg.sender].push(store.storeId);
        stores.push(store.storeId);
        storesIndex[store.storeId] = stores.length-1;
        emit LogStoreCreated(store.storeId);
        return store.storeId;
    }

    /** @dev Function is to get all the stores
	* @param storeOwner address
    * @return storeIds - all the storeIds
	*/
    function getStores(address storeOwner) public view onlyApprovedStoreOwner returns(bytes32[] memory){
        return storesByOwners[storeOwner];
    }

    /** @dev Function is to get storeId by the store owner
	* @param storeOwner address
    * @param index Store owner index
    * @return storeId
	*/
    function getStoreIdByOwner(address storeOwner, uint index) public view returns(bytes32) {
        return storesByOwners[storeOwner][index];
    }

    /** @dev Function is to get stores count by the store owner
	* @param storeOwner address
    * @return no of stores
	*/
    function getStoreCountByOwner(address storeOwner) public view returns(uint){
        return storesByOwners[storeOwner].length;
    }

    /** @dev Function is to remove a store
	* @param storeId Id of the store
	*/
    function removeStore(bytes32 storeId) public onlyApprovedStoreOwner onlyStoreOwner(storeId) whenNotPaused {
        //Remove all products in the store;
        removeProducts(storeId);
        //remove store from stores array
        uint storeIndex = storesIndex[storeId];
        if (stores.length > 1) {
            stores[storeIndex] = stores[stores.length-1];
        }
        stores.length--;
        //remove store by Owner
        uint length = storesByOwners[msg.sender].length;
        for (uint i=0; i<length; i++) {
            if(storesByOwners[msg.sender][i] == storeId){
                if(i!=length-1){
                    storesByOwners[msg.sender][i] = storesByOwners[msg.sender][length-1];
                }
                delete storesByOwners[msg.sender][length-1];
                storesByOwners[msg.sender].length--;
                break;
            }
        }
        // Withdraw store balance and transfer to msg.sender
        uint storeBalance = storeById[storeId].balance;
		if (storeBalance > 0) {
			msg.sender.transfer(storeBalance);
			storeById[storeId].balance = 0;
			emit LogBalanceWithdrawn(storeId, storeBalance);
		}

        //Delete Store By Id
        delete storeById[storeId];
        emit LogStoreRemoved(storeId);
    }

    /** @dev Function is to withdraw the store balance
	* @param storeId Id of the store
	*/
    function withdrawStoreBalance(bytes32 storeId) public payable onlyApprovedStoreOwner onlyStoreOwner(storeId) whenNotPaused{
        require(storeById[storeId].balance > 0);
		uint storeBalance = storeById[storeId].balance;
		msg.sender.transfer(storeBalance);
		emit LogBalanceWithdrawn(storeId, storeBalance);
		storeById[storeId].balance = 0;
    }

    /** @dev Function is to get stores Id
	* @param index storeId index
    * @return storeId
	*/
    function getStoreId(uint index) public view returns(bytes32){
        return stores[index];
    }

     /** @dev Function is to get store owner of the store
	* @param storeId Id of the store
    * @return storeOwner address
	*/
    function getStoreOwner(bytes32 storeId) public view returns(address){
        return storeById[storeId].storeOwner;
    }

    /** @dev Function is to get store name
	* @param storeId Id of the store
    * @return storeName
	*/
    function getStoreName(bytes32 storeId) public view returns(string memory){
        return storeById[storeId].storeName;
    }

     /** @dev Function is to get total store counts
    * @return totalStoreCount
	*/
    function getTotalStoresCount() view public returns (uint) {
		return stores.length;
	}

    /** @dev Function is to get store balance
    * @param storeId Id of the store
    * @return storeBalance
	*/
    function getStoreBalance(bytes32 storeId) public view onlyApprovedStoreOwner onlyStoreOwner(storeId) returns (uint) {
		return storeById[storeId].balance;
	}

     /** @dev Function is to add a Product to the store
    * @param storeId Id of the store
    * @param productName Name of the product
    * @param description Description of the product
    * @param price price of the product
    * @param quantity quantity of the product
    * @return productId
	*/
    function addProduct(bytes32 storeId, string memory productName, string memory description, uint price, uint quantity)
    public onlyApprovedStoreOwner onlyStoreOwner(storeId) whenNotPaused returns(bytes32){
        bytes32 productId = keccak256(abi.encodePacked(storeId, productName, now));
        Product memory product = Product(productId, productName, description, price, quantity, storeId);
        productsById[productId] = product;
        productsByStore[storeId].push(product.productId);
        emit LogProductAdded(product.productId);
        return product.productId;
    }

     /** @dev Function is to update Product price of a store
    * @param storeId Id of the store
    * @param productId Id of the product
    * @param newPrice new price of the product
	*/
    function updateProductPrice(bytes32 storeId, bytes32 productId, uint newPrice)
    public onlyStoreOwner(storeId) whenNotPaused {
		Product storage product = productsById[productId];
		uint oldPrice = product.price;
		productsById[productId].price = newPrice;
		emit LogPriceUpdated(productId, oldPrice, newPrice);
	}

    /** @dev Function is to get the price of the Product
    * @param productId Id of the product
    * @return price of the product
	*/
    function getProductPrice(bytes32 productId) public view returns (uint) {
		return productsById[productId].price;
	}

    /** @dev Function is to get the name of the Product
    * @param productId Id of the product
    * @return name of the product
	*/
    function getProductName(bytes32 productId) public view returns (string memory) {
		return productsById[productId].productName;
	}

    /** @dev Function is to get productIds in a store
    * @param storeId Id of the store
    * @return productIds in a store
	*/
    function getProductIdsByStore(bytes32 storeId) public view returns(bytes32[] memory){
        return productsByStore[storeId];
    }

    /** @dev Function is to get productId in a store
    * @param storeId Id of the store
    * @param index product Id index in a store
    * @return productId in a store
	*/
    function getProductIdByStore(bytes32 storeId, uint index) public view returns(bytes32){
        return productsByStore[storeId][index];
    }

    /** @dev Function is to get no of products in a store
    * @param storeId Id of the store
    * @return no of products in a store
	*/
    function getProductsCountByStore(bytes32 storeId) public view returns(uint){
        return productsByStore[storeId].length;
    }

    /** @dev Function is to get product by Id
    * @param productId Id of the product
    * @return productId Id of the product
    * @return productName Name of the product
    * @return description Description of the product
    * @return price price of the product
    * @return quantity quantity of the product
    * @return storeId Id of the store
	*/
    function getProductById(bytes32 productId) public view returns (string memory, string memory, uint, uint, bytes32){
        return (productsById[productId].productName, productsById[productId].description, productsById[productId].price,
        productsById[productId].quantity, productsById[productId].storeId);
    }

    /** @dev Function is to remove products in a store.
    * @param storeId Id of the store
	*/
    function removeProducts(bytes32 storeId) public onlyApprovedStoreOwner onlyStoreOwner(storeId) whenNotPaused{
        for (uint i=0; i< productsByStore[storeId].length; i++) {
                bytes32 productId = productsByStore[storeId][i];
                delete productsByStore[storeId][i];
                delete productsById[productId];
        }
    }

    /** @dev Function is to remove product in a store.
    * @param storeId Id of the store
    * @param productId Id of the Product
	*/
    function removeProductByStore(bytes32 storeId, bytes32 productId) public onlyApprovedStoreOwner onlyStoreOwner(storeId) whenNotPaused{
        bytes32[] memory productIds = productsByStore[storeId];
		uint productsCount = productIds.length;
        for(uint i=0; i<productsCount; i++) {
			if (productIds[i] == productId) {
				productIds[i] = productIds[productsCount-1];
				delete productIds[productsCount-1];
                productsByStore[storeId] = productIds;
				delete productsById[productId];
				emit LogProductRemoved(productId, storeId);
				break;
			}
		}
    }

    /** @dev Function is to buy the products by the buyer
    * @param storeId Id of the store
    * @param productId Id of the Product
    * @param quantity quanities of the product to buy
    * @return true if product is bought otherwise false
	*/
    function buyProduct(bytes32 storeId, bytes32 productId, uint quantity) public payable whenNotPaused returns(bool){
        //store owner can not buy its own productsById
        Product storage prdct = productsById[productId];
        Store storage str = storeById[storeId];
        //store owner can not buy its own products
        require(str.storeOwner != msg.sender);
        uint amount =  prdct.price*quantity;
        require(msg.value >= amount);
        require (quantity <= prdct.quantity);

        //refund remaining fund back to buyer
        uint remainingValue = msg.value-amount;
        msg.sender.transfer(remainingValue);

        //update product quantity & store balance
        prdct.quantity-=quantity;
        str.balance+=amount;
        emit LogProductSold(productId, storeId, prdct.price, quantity, amount, msg.sender, prdct.quantity);
		return true;
    }

}
