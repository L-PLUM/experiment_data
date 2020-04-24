/**
 *Submitted for verification at Etherscan.io on 2019-07-31
*/

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

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
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

pragma solidity ^0.5.0;



/**
 * @dev Implementation of the `IERC20` interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using `_mint`.
 * For a generic mechanism see `ERC20Mintable`.
 *
 * *For a detailed writeup see our guide [How to implement supply
 * mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226).*
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an `Approval` event is emitted on calls to `transferFrom`.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard `decreaseAllowance` and `increaseAllowance`
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See `IERC20.approve`.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See `IERC20.totalSupply`.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IERC20.balanceOf`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See `IERC20.transfer`.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See `IERC20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `ERC20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     /**
     * @dev Destoys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See `_burn` and `_approve`.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
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

// File: contracts/MarketPlace.sol

pragma solidity ^0.5.8;





/**
* @title MarketPlace
* @author Mehmet Dogan
* @dev This contract allows to create and manage a public market place on Ethereum Network.
* Two design patterns are implemented into the contract as Pausable and Ownable.
* Ownable allows to contract owner to add new admins.
* Pausable allows to stop contract state updates due to any emergency.
* SafeMath allows us to handle overflows/underflows on arithmetic operations.
*/
contract MarketPlace is Pausable, Ownable {
    using SafeMath for uint256;

    /**
    * @dev Modifier to make a function callable only by the admin.
    */
    modifier onlyAdmin() {
        require(admins[msg.sender], "Not an admin");
        _;
    }

    /**
    * @dev Modifier to make a function callable only by the store owner.
    */
    modifier onlyStoreOwner() {
        require(storeOwners[msg.sender], "Not a store owner");
        _;
    }

    /**
    *  @dev This event raises when a new store owner is added by the admin
    *  @param storeOwner is the address of newly added owner
     */
    event LogNewStoreOwner(address indexed storeOwner);

    /**
    *  @dev This event raises when a new store is added by the owner
    *  @param storeOwner is the address store owner
    *  @param storeId is the identifier for store
    */
    event LogNewStore(address indexed storeOwner, uint256 storeId);

    /**
    *  @dev This event raises when a new product added to the store by the owner
    *  @param storeId is the identifier for the store
    *  @param productId is the identifier for the product
    */
    event LogNewProduct(uint256 storeId, uint256 productId);

    /// mapping that stores admins of the Market Place
    mapping(address => bool) public admins;

    /// mapping that stores storeOwners of the Market Place
    mapping(address => bool) public storeOwners;

    /// mapping from owners to stores
    mapping(address => uint256[]) ownerToStores;

    /// mapping from storeIds to owners
    mapping(uint256 => address) private storeToOwners;

    /// mapping from storeIds to metaDatas
    mapping(uint256 => bytes32) public storeMetadatas;

    /// mapping from storeIds to productIds that are available on the store
    mapping(uint256 => uint256[]) private storeToProducts;

    /// mapping from productIds to Product Details
    mapping(uint256 => Product) public products;

    /// mapping from storeIds to ETH/ERC20 tokens balances
    mapping(uint256 => mapping(address => uint256)) private balances;

    /// total Store Count
    uint256 public storeCount;

    /// total Product Count
    uint256 public productCount;

    struct Product {
        // ZERO_ADDRESS denotes ethereum, where as the other addresses should correspond to ERC20 tokens.
        address paymentAddress;
        // Price in terms of unit denoted by paymentAddress
        uint256 price;
        // IPFS Hash of product that stores image, name and description
        bytes32 metaData;
        // Quantity left on the stocks
        uint256 stock;
        // The identifier for the store that sells the product
        uint256 storeID;
        // The status that allows of soft remove of product from store
        bool onStore;
    }

    /**
    * @dev Only contract owner can add new admins to the system.
    * @param newAdmin Address of the user that will be joined the system as Admin.
    */
    function addAdmin(address newAdmin) public onlyOwner {
        admins[newAdmin] = true;
    }

    /**
    * @dev Only admin can add new store owners to the system.
    * @param _storeOwner Address of the user that will be joined the system as Store Owner.
    */
    function addStoreOwner(address _storeOwner) public onlyAdmin whenNotPaused {
        storeOwners[_storeOwner] = true;
        emit LogNewStoreOwner(_storeOwner);
    }

    /**
    * @dev Adds new store to the marketplace.
    * @param storeInfo IPFS hash of the data that stores metadata about the store.
    * @notice raises LogNewStore event when completed
    */
    function createStore(bytes32 storeInfo) public onlyStoreOwner whenNotPaused {
        ownerToStores[msg.sender].push(storeCount);
        storeMetadatas[storeCount] = storeInfo;
        storeToOwners[storeCount] = msg.sender;
        emit LogNewStore(msg.sender,storeCount);
        storeCount++;
    }

    /**
    * @dev Edits the metadata of the store.
    * @param storeId Identifier for the store.
    * @param storeInfo IPFS hash of the data that stores metadata about the store.
    */
    function editStoreInfo(uint256 storeId, bytes32 storeInfo) public onlyStoreOwner whenNotPaused {
        require(storeToOwners[storeId] == msg.sender, "Only owner of the store can update info");
        storeMetadatas[storeId] = storeInfo;
    }

    /**
    * @dev Adds new product to the store
    * @param _storeID Identifier for the store.
    * @param _ipfsHash IPFS hash of the data that stores metadata about the product.
    * @param _stock Quantity of the product
    * @param tokenAddress payment method that can be ERC20 token address or ZERO_ADDRESS for ethereum
    * @param price Price in terms of unit denoted by paymentAddress
    */
    function addProduct(uint256 _storeID, bytes32 _ipfsHash, uint256 _stock, address tokenAddress, uint256 price) public onlyStoreOwner {
        require(storeToOwners[_storeID] == msg.sender, "Only owner of the store can add products to the store");
        Product storage product = products[productCount];
        product.metaData = _ipfsHash;
        product.stock = _stock;
        product.paymentAddress = tokenAddress;
        product.price = price;
        product.storeID = _storeID;
        product.onStore = true;
        storeToProducts[_storeID].push(productCount);
        emit LogNewProduct(_storeID,productCount);
        productCount++;

    }

    /**
    * @dev Modifies the product's price
    * @param _productID Identifier for the product.
    * @param tokenAddress payment method that can be ERC20 token address or ZERO_ADDRESS for ethereum
    * @param price Price in terms of unit denoted by paymentAddress
    */
    function changeProductPrice(uint256 _productID, address tokenAddress, uint256 price) public onlyStoreOwner {
        Product storage product = products[_productID];
        require(storeToOwners[product.storeID] == msg.sender, "Only owner of the store can edit product's price");
        product.paymentAddress = tokenAddress;
        product.price = price;

    }

    /**
    * @dev Removes the product from store
    * @param productID Identifier for the product.
    */
    function removeProduct(uint256 productID) public onlyStoreOwner {
        uint256 storeID = products[productID].storeID;
        require(storeToOwners[storeID] == msg.sender, "Only owner of the store can remove products from the store");
        Product storage product = products[productID];
        product.onStore = false;
    }

    /**
    * @dev Shoppers purchase the product with desired quantity
    * @param productID Identifier for the product.
    * @param tokenAddress payment method that can be ERC20 token address or ZERO_ADDRESS for ethereum
    * @param paidAmount Price in terms of unit denoted by paymentAddress
    * @param quantity amount of the products that will be purchased
    */
    function purchaseProduct(uint256 productID, address tokenAddress, uint256 paidAmount, uint256 quantity) public payable {
        Product storage product = products[productID];
        require(product.stock >= quantity, "Not enough product on the store");
        require(product.onStore, "Product not available on Store");
        uint256 totalCost = quantity.mul(product.price);
        if(tokenAddress == address(0)) {
            require(msg.value == totalCost, "Msg.value must exactly match the total cost");
            balances[product.storeID][tokenAddress] = balances[product.storeID][tokenAddress].add(totalCost);
        }
        else{
            require(paidAmount >= totalCost, "Not eligible to purchase the product");
            require(ERC20(tokenAddress).transferFrom(msg.sender,address(this), totalCost), "Not enough approved ERC20");
            balances[product.storeID][tokenAddress] = balances[product.storeID][tokenAddress].add(totalCost);
        }
        product.stock = product.stock.sub(quantity);

    }

    /**
    * @dev Returns the stores of owner
    * @param storeOwner Address of the store owner
    * @return Array of store IDs
    */
    function getStoresOfOwner(address storeOwner) external view returns(uint256[] memory stores){
        return ownerToStores[storeOwner];
    }
    /**
    * @dev Returns the products in the store
    * @param storeId Identifier for the store
    * @return Array of product IDs
    */
    function getProductsInStore(uint256 storeId) external view returns(uint256[] memory _products){
        return storeToProducts[storeId];
    }

    /**
    * @dev Returns the products in the store
    * @param storeId Identifier for the store
    * @param tokenAddress payment method that can be ERC20 token address or ZERO_ADDRESS for ethereum
    * @return Array of product IDs
    */
    function getBalanceOfStore(uint256 storeId, address tokenAddress) external view returns(uint256 balance){
        return balances[storeId][tokenAddress];
    }

    /**
    * @dev Transfers the funds in the store to the owner
    * @param storeId Identifier for the store
    * @param tokenAddress payment method that can be ERC20 token address or ZERO_ADDRESS for ethereum
    */
    function withdrawBalance(uint256 storeId, address tokenAddress) external {
        require(storeToOwners[storeId] == msg.sender, "Only owner of the store can withdraw funds");
        uint256 balance = balances[storeId][tokenAddress];
        balances[storeId][tokenAddress] = 0;
        if(tokenAddress == address(0)){
            msg.sender.transfer(balance);
        }
        else{
            require(ERC20(tokenAddress).transfer(msg.sender, balance), "Not enough approved ERC20");
        }
    }

    /**
    * @dev Fallback function that welcomes any incoming Ethereum
    */
    function() external payable { }

    /**
    * @dev Constructor for the marketplace
    * @notice Deployer is set as admin to the marketplace
    * @notice Deployer is also set as pauser and owner
    */
    constructor() public {
        admins[msg.sender] = true;
    }

    /**
    * @dev Destructs the contract and transfer funds to the owner
    * @notice Only Contract Owner can execute
    */
    function killContract() public onlyOwner {
        selfdestruct(msg.sender);
    }



}
