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
