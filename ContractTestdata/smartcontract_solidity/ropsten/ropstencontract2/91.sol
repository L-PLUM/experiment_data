/**
 *Submitted for verification at Etherscan.io on 2019-08-12
*/

// File: contracts/vendor/IERC20.sol

pragma solidity 0.5.8;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/vendor/SafeMath.sol

pragma solidity 0.5.8;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: contracts/vendor/Ownable.sol

pragma solidity 0.5.8;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

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
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Must be owner");
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
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
        require(newOwner != address(0), "Cannot transfer to zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/vendor/ERC20.sol

pragma solidity 0.5.8;




/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract ERC20 is IERC20, Ownable {
    using SafeMath for uint256;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowed;
    mapping (address => uint256) internal _timeUpdates;
    mapping (address => uint256) internal _circulatingSupply;
    mapping (address => bool) private _isHolder;
    
    address[] internal _holders;

    uint256 internal _totalSupply;

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner The address to query the balance of.
     * @return An uint256 representing the amount owned by the passed address.
     */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _transfer(from, to, value);
        _approve(from, msg.sender, _allowed[from][msg.sender].sub(value));
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowed[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Transfer token for a specified addresses
     * @param from The address to transfer from.
     * @param to The address to transfer to.
     * @param value The amount to be transferred.
     */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));
        
        _circulatingSupply[to] = _circulatingSupply[to].add(value);
        _circulatingSupply[from] = _circulatingSupply[from].add(value);

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);

        if(!_isHolder[to]) {
            _isHolder[to] = true;
           _holders.push(to);
        }

        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);

        if(!_isHolder[account]) {
            _isHolder[account] = true;
           _holders.push(account);
        }
        
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Approve an address to spend another addresses' tokens.
     * @param owner The address that owns the tokens.
     * @param spender The address that will spend the tokens.
     * @param value The number of tokens that can be spent.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(spender != address(0));
        require(owner != address(0));

        _allowed[owner][spender] = value;
        emit Approval(owner, spender, value);
    }
}

// File: contracts/vendor/ERC20Mintable.sol

pragma solidity 0.5.8;


/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic
 */
contract ERC20Mintable is ERC20 {
    /**
     * @dev Function to mint tokens
     * @param to The address that will receive the minted tokens.
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 value) public onlyOwner returns (bool) {
        _mint(to, value);
        return true;
    }
}

// File: contracts/vendor/ERC20Burnable.sol

pragma solidity 0.5.8;


/**
 * @dev Extension of `ERC20` that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
contract ERC20Burnable is ERC20Mintable {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See `ERC20._burn`.
     */
    function burn(uint256 amount) public onlyOwner {
        _burn(msg.sender, amount);
    }
    
}

// File: contracts/vendor/ERC20Whitelisted.sol

pragma solidity 0.5.8;


/**
 * @title WhitelistedRole
 * @dev Whitelisted accounts have been approved by a WhitelistAdmin to perform certain actions (e.g. participate in a
 * crowdsale). This role is special in that the only accounts that can add it are WhitelistAdmins (who can also remove
 * it), and not Whitelisteds themselves.
 */
contract ERC20Whitelisted is ERC20Burnable {

    event StorageWhitelistedAdded(address indexed account);
    event StorageWhitelistedRemoved(address indexed account);
    event TransferWhitelistedAdded(address indexed account);
    event TransferWhitelistedRemoved(address indexed account);

    mapping(address => bool) internal storageWhitelisted;
    mapping(address => bool) internal transferWhitelisted;

    constructor() public {
        storageWhitelisted[msg.sender] = true;
        transferWhitelisted[msg.sender] = true;
    }

    function isStorageWhitelisted(address account) public view returns (bool) {
        return storageWhitelisted[account];
    }

    function isTransferWhitelisted(address account) public view returns (bool) {
        return transferWhitelisted[account];
    }

    function addStorageWhitelisted(address account) public onlyOwner {
        storageWhitelisted[account] = true;
        emit StorageWhitelistedAdded(account);
    }

    function removeStorageWhitelisted(address account) public onlyOwner {
        storageWhitelisted[account] = false;
        emit StorageWhitelistedRemoved(account);
    }

    function addTransferWhitelisted(address account) public onlyOwner {
        transferWhitelisted[account] = true;
        emit TransferWhitelistedAdded(account);
    }

    function removeTransferWhitelisted(address account) public onlyOwner {
        transferWhitelisted[account] = false;
        emit TransferWhitelistedRemoved(account);
    }
}

// File: contracts/vendor/Pausable.sol

pragma solidity 0.5.8;


/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is ERC20Whitelisted {
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
    function pause() public whenNotPaused onlyOwner {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public whenPaused onlyOwner {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

// File: contracts/vendor/ERC20Standard.sol

pragma solidity 0.5.8;


/**
 * @title Pausable token
 * @dev ERC20 with pausable transfers and allowances.
 *
 * Useful if you want to e.g. stop trades until the end of a crowdsale, or have
 * an emergency switch for freezing all token transfers in the event of a large
 * bug.
 */
contract ERC20Standard is Pausable {
    uint256 private transferFee = 39;
    uint256 private storageFee = 2;
    uint256 private minimumTransfer = 2542000000000000;
    uint256 private effectiveCirculatingSupply = 100000000000000000000000;

    address internal vaultWallet;
    address internal transferFeeWallet;

    event FeeChanged(uint256 newFee);
    event TransferFeeWalletChanged(address newTransferFeeWallet);
    event VaultWalletChanged(address newVaultWallet);

    function balanceOf(address owner) public view returns (uint256) {
        uint result = super.balanceOf(owner);

        if(owner == vaultWallet && _holders.length > 0) {
            for(uint i = 0; i < _holders.length; i++) {
                result = result.add(_calculateStorageFee(_holders[i]));
            }

            return result;
        }

        if(_calculateStorageFee(owner) > 0) {
            return super.balanceOf(owner).sub(_calculateStorageFee(owner));
        }

        return super.balanceOf(owner);
    }

    function transfer(address to, uint256 value) public whenNotPaused returns (bool) {
        require(value >= minimumTransfer);

        if(_calculateStorageFee(msg.sender) > 0) {
            _transfer(msg.sender, vaultWallet, _calculateStorageFee(msg.sender));
        }

        _timeUpdates[msg.sender] = block.timestamp;
        _timeUpdates[to] = block.timestamp;

        if(_calculateTransferFee(msg.sender, to, value) > 0) {
            _transfer(msg.sender, transferFeeWallet, _calculateTransferFee(msg.sender, to, value));
            _transfer(msg.sender, to, value.sub(_calculateTransferFee(msg.sender, to, value)));
            return true;
        }

        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public whenNotPaused returns (bool) {
        require(value >= minimumTransfer);

        if(_calculateStorageFee(from) > 0) {
            _transfer(from, vaultWallet, _calculateStorageFee(from));
        }

        _timeUpdates[from] = block.timestamp;
        _timeUpdates[to] = block.timestamp;

        if(_calculateTransferFee(from, to, value) > 0) {
            _transfer(from, transferFeeWallet, _calculateTransferFee(from, to, value));
            return super.transferFrom(from, to, value.sub(_calculateTransferFee(from, to, value)));
        }

        return super.transferFrom(from, to, value);
    }

    function approve(address spender, uint256 value) public whenNotPaused returns (bool) {
        if(_calculateStorageFee(msg.sender) > 0) {
            _transfer(msg.sender, vaultWallet, _calculateStorageFee(msg.sender));
        }

        _timeUpdates[msg.sender] = block.timestamp;
        return super.approve(spender, value);
    }

    function increaseAllowance(address spender, uint256 addedValue) public whenNotPaused returns (bool) {

        if(_calculateStorageFee(msg.sender) > 0) {
            _transfer(msg.sender, vaultWallet, _calculateStorageFee(msg.sender));
        }
        
        _timeUpdates[msg.sender] = block.timestamp;
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public whenNotPaused returns (bool) {
        if(_calculateStorageFee(msg.sender) > 0) {
            _transfer(msg.sender, vaultWallet, _calculateStorageFee(msg.sender));
        }
        
        _timeUpdates[msg.sender] = block.timestamp;
        return super.decreaseAllowance(spender, subtractedValue);
    }

    function mint(address to, uint256 value) public onlyOwner whenNotPaused returns (bool) {
        if(_calculateStorageFee(to) > 0) {
            _transfer(to, vaultWallet, _calculateStorageFee(to));
        }
        
        _timeUpdates[to] = block.timestamp;
        _mint(to, value);
        return true;
    }

    function burn(uint256 amount) public onlyOwner whenNotPaused {
        if(_calculateStorageFee(msg.sender) > 0) {
            _transfer(msg.sender, vaultWallet, _calculateStorageFee(msg.sender));
        }
        
        _timeUpdates[msg.sender] = block.timestamp;
        _burn(msg.sender, amount);
    }

    function setTransferFee(uint256 newFee) public onlyOwner {
        require(newFee > 0);

        transferFee = newFee;
        emit FeeChanged(newFee);
    }

    function setVaultWallet(address newVaultWallet) public onlyOwner {
        require(newVaultWallet != address(0));

        storageWhitelisted[vaultWallet] = false;
        transferWhitelisted[vaultWallet] = false;

        vaultWallet = newVaultWallet;

        storageWhitelisted[newVaultWallet] = true;
        transferWhitelisted[newVaultWallet] = true;

        emit VaultWalletChanged(newVaultWallet);
    }

    function setTransferFeeWallet(address newTransferFeeWallet) public onlyOwner {
        require(newTransferFeeWallet != address(0));

        storageWhitelisted[newTransferFeeWallet] = false;
        transferWhitelisted[newTransferFeeWallet] = false;

        transferFeeWallet = newTransferFeeWallet;

        storageWhitelisted[newTransferFeeWallet] = true;
        transferWhitelisted[newTransferFeeWallet] = true;

        emit VaultWalletChanged(newTransferFeeWallet);
    }

    function withdrawStorageFee(address holder) external {
        require(msg.sender == vaultWallet);
        require(_calculateStorageFee(holder) > 0);

        _transfer(holder, vaultWallet, _calculateStorageFee(holder));
        _timeUpdates[holder] = block.timestamp;
    }

    function _calculateStorageFee(address _address) internal view returns(uint256) {
        if(isStorageWhitelisted(_address) || block.timestamp.sub(_timeUpdates[_address]) < 1 days) {
            return 0;
        }

        return (_balances[_address].mul(storageFee).div(1000).mul(block.timestamp.sub(_timeUpdates[_address]).div(1 days))).div(365);
    }

    function _calculateTransferFee(address from, address to, uint256 value) internal view returns(uint256) {
        if(isTransferWhitelisted(from) || isTransferWhitelisted(to)) {
            return 0;
        }

        if(_circulatingSupply[from] >= effectiveCirculatingSupply) {
            return value.mul(transferFee.div(2)).div(10000);
        }

        return value.mul(transferFee).div(10000);
    }
}

// File: contracts/HasPrice.sol

pragma solidity 0.5.8;


contract HasPrice is Ownable {
    
    /// @dev Represents the price of the inherited context
    uint256 private price;

    /// @dev Fires when the price is changed
    event ChangedPrice(uint256 newPrice);

    /// @dev Set the price. Only the owner of the oracle can set the price
    /// @param _newPrice the price to be set
    function setPrice(uint256 _newPrice)
        public
        onlyOwner
    {
        price = _newPrice;
        emit ChangedPrice(_newPrice);
    }

    /// @dev Get the current price
    /// @return The value of the current price
    function getPrice()
        public
        view
        returns (uint256)
    {
        return price;
    }
}

// File: contracts/AGLDTToken.sol

pragma solidity 0.5.8;



contract AGLDTToken is ERC20Standard, HasPrice {
    string public name = "AgAu gold backed token - test";
    string public symbol = "AGLDT";
    uint8 public decimals = 18;

    constructor(address _vaultWallet, address _transferFeeWallet) public {
        vaultWallet = _vaultWallet;
        transferFeeWallet = _transferFeeWallet;

        storageWhitelisted[_vaultWallet] = true;
        transferWhitelisted[_vaultWallet] = true;
        storageWhitelisted[_transferFeeWallet] = true;
        transferWhitelisted[_transferFeeWallet] = true;
    }
}
