/**
 *Submitted for verification at Etherscan.io on 2019-08-12
*/

// File: @openzeppelin/contracts/ownership/Ownable.sol

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

// File: @openzeppelin/contracts/access/Roles.sol

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

// File: @openzeppelin/contracts/access/roles/PauserRole.sol

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

// File: @openzeppelin/contracts/lifecycle/Pausable.sol

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

// File: @openzeppelin/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: contracts/Store.sol

pragma solidity ^0.5.0;



// import "./Marketplace.sol";

/**
 * @title Store
 * @dev The Store contract contains the information and functions to manage the store.
 * @author Luis Videla
 */
contract Store is Ownable {

    address marketplaceAddress;

    string public name;

    // item handling
    mapping(uint => Item) public items;
    uint public itemIterator;

    /// @dev Item struct that contains the properties of an item
    struct Item {
        uint id;
        string name;
        uint price;
        uint quantity;
        bool exists;
    }

    /**
     * Events
     */
    event AddedItem(uint indexed id, string name, uint price, uint quantity);
    event RemovedItem(uint indexed id);
    event ChangedPrice(uint indexed id, uint prevPrice, uint price);
    event BoughtItem(uint indexed id, address indexed buyer, uint quantity);
    event DeletedStore(address indexed addr, address indexed owner);
    event WithdrewFunds(address indexed addr, uint amount);

    /// @dev Throws is item does not exist
    modifier itemExists(uint _id) {
        require(items[_id].exists == true, "Nonexistent item.");
        _;
    }

    /// @dev Throws if Marketplace contract is paused
    modifier isNotPaused() {
        Marketplace m = Marketplace(marketplaceAddress);
        bool paused = m.paused();
        require(paused == false, "The Marketplace is paused");
        _;
    }

    /// @dev The Store contructor that sets up the properties for the opening of this store
    constructor(address _owner, address _marketplaceAddr, string memory _name) public {
        // owner = _owner;
        transferOwnership (_owner);

        marketplaceAddress = _marketplaceAddr;
        name = _name;
        itemIterator = 0;
    }

    /**
     * @dev Gets the properties of the store
     * @return owner The store owner's address
     * @return marketplaceAddress The marketplace address (which was used to deploy this Store)
     * @return name The store's name
     * @return itemIterator The store's item count
     */
    function getValues() public view returns (address, address, string memory, uint) {
        return (owner(), marketplaceAddress, name, itemIterator);
    }

    /**
     * @dev Add an item to the store
     * @param _name Name of the item
     * @param _price Price of the item
     * @param _quantity Quantity of the item
     */
    function addItem(string memory _name, uint _price, uint _quantity) public onlyOwner isNotPaused {
        emit AddedItem(itemIterator, _name, _price, _quantity);
        items[itemIterator] = Item(itemIterator, _name, _price, _quantity, true);
        itemIterator = SafeMath.add(itemIterator, 1);
    }

    /**
     * @dev Remove an item from the store
     * @param _id The item's id
      */
    function removeItem(uint _id) public itemExists(_id) onlyOwner isNotPaused {
        emit RemovedItem(_id);
        delete items[_id];
    }

    /**
     * @dev Change the price of an item from the store
     * @param _id The item's id
     * @param _price The item's new price in wei
     */
    function changePrice(uint _id, uint _price) public itemExists(_id) onlyOwner isNotPaused {
        emit ChangedPrice(_id, items[_id].price, _price);
        items[_id].price = _price;
    }

    /**
     * @dev Buying an item from the store
     * @param _id The item's id
     * @param _quantity The quantity that the user wants to buy
     */
    function buyItem(uint _id, uint _quantity) public payable itemExists(_id) isNotPaused {
        require(items[_id].price <= msg.value, "Not enough ether.");
        require(items[_id].quantity >= _quantity, "We don't have that amount.");
        emit BoughtItem(_id, msg.sender, _quantity);
        items[_id].quantity = items[_id].quantity - _quantity;
    }

    /**
     * @dev Delete the store
     * @notice This is an external call, but will only accept calls made from the marketplace contract that created this
     * store. The marketplace contract has checks in place to make sure no malicious store owners will delete a store
     * that does not belong to them.
     */
    function deleteStore() external isNotPaused {
        // Verify that call is made from the marketplace contract
        require(msg.sender == marketplaceAddress, "You do not have permission to perform this action.");
        emit DeletedStore(address(this), owner());
        // cast to address(uint160) to make address payable
        selfdestruct(address(uint160(owner())));
    }

    /**
     * @dev Withdraw funds from the Store contract into the owner's address
     * @param _amount The amount of funds to withdraw in wei
     */
    function withdrawFunds(uint _amount) public onlyOwner {
        require(_amount <= address(this).balance, "You don't have you have enough ether.");
        emit WithdrewFunds(owner(), _amount);
        // cast to address(uint160) to make address payable
        address(uint160(owner())).transfer(_amount);
    }
}

// File: contracts/Marketplace.sol

pragma solidity ^0.5.0;




/**
 * @title Marketplace
 * @dev The Marketplace contract determines which addresses are the admins and the store owners.
 * It is also allows store owners to open a store using an external function from the Store contract.
 * Using a store owners address it can determine the stores that the store owner is in charge of
 * @author Luis Videla
 */
contract Marketplace is Ownable, Pausable {
    mapping(address => bool) public admins;
    mapping(address => bool) public storeOwners;
    mapping(address => Store[]) public stores;

    /**
     * Events
     */
    event AddedAdmin(address indexed addr);
    event RemovedAdmin(address indexed addr);
    event AddedStoreOwner(address indexed addr);
    event RemovedStoreOwner(address indexed addr);
    event AddedStore(address indexed owner, string name);
    event DeletedStore(address indexed addr, address indexed owner);

    /// @dev Throws if called by any account that isn't an admin
    modifier onlyAdmin() {
        require(admins[msg.sender] == true, "You do not have permission to perform this action.");
        _;
    }

    /// @dev Throws if called by any account that isn't a store owner
    modifier onlyStoreOwner() {
        require(storeOwners[msg.sender] == true, "You are not the owner of this store.");
        _;
    }

    /// @dev Throws if called by an account that isn't a store owner of a particular store
    modifier validStoreOwner() {
        bool exists = false;
        Store[] memory storeList = stores[msg.sender];
        for (uint i = 0; i < storeList.length; i++) {
            if (storeList[i].owner() == msg.sender) {
                exists = true;
            }
        }
        require(exists, "You are not the owner of this store.");
        _;
    }

    /// @dev The Marketplace constructor sets the sender as the owner of the contract
    /// and is added to the list of admins
    constructor() public {
        transferOwnership(msg.sender);
        admins[msg.sender] = true;
    }

    /**
     * @dev Adds an address to the admin mapping
     * @param _addr An address
     */
    function addAdmin(address _addr) public onlyAdmin whenNotPaused {
        emit AddedAdmin(_addr);
        admins[_addr] = true;
    }

    /**
     * @dev Sets admin status in the mapping to false
     * @param _addr An address
     */
    function removeAdmin(address _addr) public onlyOwner whenNotPaused {
        require(_addr != owner(), "You do not have permissions to remove an owner.");
        emit RemovedAdmin(_addr);
        admins[_addr] = false;
    }

    /**
     * @dev Adds an address to the store owner mapping
     * @param _addr An address
     */
    function addStoreOwner(address _addr) public onlyAdmin whenNotPaused {
        emit AddedStoreOwner(_addr);
        storeOwners[_addr] = true;
    }

    /**
     * @dev Sets admin status in the mapping to false
     * @param _addr An address
     */
    function removeStoreOwner(address _addr) public onlyAdmin whenNotPaused {
        emit RemovedStoreOwner(_addr);
        storeOwners[_addr] = false;
    }

    /**
     * @dev Gets the list of stores from the store mapping
     * @param _addr An address
     */
    function getStores(address _addr) public view returns (Store[] memory) {
        return stores[_addr];
    }

    /**
     * @dev Gets the store values
     * @param _store The contract address of a store
     */
    function getStoreValues(Store _store) public view returns (address, address, string memory, uint) {
        return _store.getValues();
    }

    /**
     * @dev Add a store
     * @param _name The store's name
     */
    function addStore(string memory _name) public onlyStoreOwner whenNotPaused returns (Store storeAddress) {
        emit AddedStore(msg.sender, _name);
        Store store = new Store(msg.sender, address(this), _name);
        Store[] memory existingStores = stores[msg.sender];
        Store[] memory storeList = new Store[](existingStores.length + 1);

        for (uint i = 0; i < existingStores.length; i++) {
            storeList[i] = existingStores[i];
        }

        storeList[storeList.length - 1] = store;

        stores[msg.sender] = storeList;
        return store;
    }

    /**
     * @dev Deletes a store
     * @notice The actual deletion happens using an external call in the Store contract
     * @param _addr The store's address
     */
    function deleteStore(address _addr) public validStoreOwner whenNotPaused {
        emit DeletedStore(_addr, msg.sender);
        Store[] memory existingStores = stores[msg.sender];
        Store[] memory storeList = new Store[](existingStores.length - 1);
        uint counter = 0;

        for (uint i = 0; i < existingStores.length; i++) {
            if (address(existingStores[i]) != _addr) {
                storeList[counter] = existingStores[i];
                counter++;
            }
        }

        stores[msg.sender] = storeList;
        Store(_addr).deleteStore();
    }

}
