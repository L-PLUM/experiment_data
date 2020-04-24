/**
 *Submitted for verification at Etherscan.io on 2019-08-02
*/

pragma solidity ^0.5.10;

// New Vision.Network 100G Token
// 
// Upgraded in Aug 2019
//
// More info:
//   https://vision.network
//   https://voken.io
//
// Contact us:
//   [email protected]
//   [email protected]


/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow checks.
 */
library SafeMath256 {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
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
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


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


/**
 * @dev Interface of the ERC20 standard
 */
interface IERC20{
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 */
contract Ownable {
    address internal _owner;

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

    /**
     * @dev Rescue compatible ERC20 Token
     */
    function rescueTokens(address tokenAddr, address recipient, uint256 amount) external onlyOwner {
        IERC20 _token = IERC20(tokenAddr);
        require(recipient != address(0));
        uint256 balance = _token.balanceOf(address(this));

        require(balance >= amount);
        assert(_token.transfer(recipient, amount));
    }

    /**
     * @dev Withdraw Ether
     */
    function withdrawEther(address payable recipient, uint256 amount) external onlyOwner {
        require(recipient != address(0));
        
        uint256 balance = address(this).balance;
        
        require(balance >= amount);
        recipient.transfer(amount);
    }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    bool private _paused;

    event Paused(address account);
    event Unpaused(address account);

    constructor () internal {
        _paused = false;
    }

    /**
     * @return Returns true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev Sets paused state.
     */
    function setPaused(bool value) external onlyOwner {
        _paused = value;

        if (_paused) {
            emit Paused(msg.sender);
        } else {
            emit Unpaused(msg.sender);
        }
    }
}

/**
 * @title New Voken Main Contract
 */
contract NewVoken is Ownable, Pausable, IERC20 {
    using SafeMath256 for uint256;
    using Roles for Roles.Role;

    string private _name = "New Vision.Network 100G Token";
    string private _symbol = "Voken1";
    uint8 private _decimals = 6;                // 6 decimals
    uint256 private _cap = 35000000000000000;   // 35 billion cap, that is 35000000000.000000
    uint256 private _totalSupply;
    uint256 private _whitelistSignUpValue = 1001000000;   // 1001 Voken, as a trigger
    uint256 private _whitelistSignUpValueBack = 1000000;  // 1 Voken, back to sender
    uint256[15] private _whitelistRefRewards = [          // 1000 Voken: 100% Reward
        300000000,  // 300 Voken for Level.1
        200000000,  // 200 Voken for Level.2
        100000000,  // 100 Voken for Level.3
        100000000,  // 100 Voken for Level.4
        100000000,  // 100 Voken for Level.5
        50000000,   //  50 Voken for Level.6
        40000000,   //  40 Voken for Level.7
        30000000,   //  30 Voken for Level.8
        20000000,   //  20 Voken for Level.9
        10000000,   //  10 Voken for Level.10
        10000000,   //  10 Voken for Level.11
        10000000,   //  10 Voken for Level.12
        10000000,   //  10 Voken for Level.13
        10000000,   //  10 Voken for Level.14
        10000000    //  10 Voken for Level.15
    ];
    bool private _allowWhitelistSignUp;
    bool private _rejectNonWhitelistTransaction;

    Roles.Role private _minters;
    
    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping(address => address) private _referee;
    mapping(address => address[]) private _referrals;

    event Donate(address indexed account, uint256 amount);
    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);
    event WhitelistSignUpEnabled();
    event WhitelistSignUpDisabled();
    event WhitelistSignedUp(address indexed account, address indexed refereeAccount);


    /**
     * @dev Constructor
     */
    constructor () public {
        addMinter(msg.sender);

        _allowWhitelistSignUp = true;
        emit WhitelistSignUpEnabled();

        _referee[msg.sender] = msg.sender;
        emit WhitelistSignedUp(msg.sender, msg.sender);
    }

    /**
     * @dev Donate
     */
    function () external payable {
        if (msg.value > 0) {
            emit Donate(msg.sender, msg.value);
        }
    }

    /**
     * @dev Returns the full name of VOKEN.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of VOKEN.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Sets the symbol of VOKEN.
     */
    function setSymbol(string calldata value) external onlyOwner {
        _symbol = value;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the cap on VOKEN's total supply.
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

    /**
     * @dev Returns the amount of VOKEN in existence.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the amount of VOKENs owned by `account`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev Moves `amount` VOKENs from the caller's account to `recipient`.
     * 
     * Auto handle whitelist sign-up when `amount` is a specific value.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external whenNotPaused returns (bool) {
        // Whitelist sign-up
        if (amount == _whitelistSignUpValue
            && _allowWhitelistSignUp
            && inWhitelist(recipient)
            && !inWhitelist(msg.sender)
            && isNotContract(msg.sender)) {

            _whitelistSignUp(msg.sender, recipient);
        }

        // Burn
        else if (recipient == address(0) || recipient == address(this)) {
            _burn(msg.sender, amount);
        }

        // Normal Transfer
        else {
            _transfer(msg.sender, recipient, amount);
        }

        return true;
    }

    /**
     * @dev Returns the remaining number of VOKENs that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}.
     * This is zero by default.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s VOKENs.
     *
     * Emits an {Approval} event.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "VOKEN: approve from the zero address");
        require(spender != address(0), "VOKEN: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Moves `amount` VOKENs from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     * Emits an {Approval} event indicating the updated allowance.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public whenNotPaused returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "VOKEN: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * Emits an {Approval} event indicating the updated allowance.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }


    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * Emits an {Approval} event indicating the updated allowance.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "VOKEN: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev Moves VOKENs `amount` from `sender` to `recipient`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(recipient != address(0));

        // reject non-whitelist transaction
        if (_rejectNonWhitelistTransaction) {
            require(inWhitelist(sender), "VOKEN: non-whitelist");
        }

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /**
     * @dev Returns true if non-whitelist transaction is not allowed.
     */
    function rejectNonWhitelistTransaction() public view returns (bool) {
        return _rejectNonWhitelistTransaction;
    }

    /**
     * @dev Disable/enable non-whitelist transaction.
     */
    function setRejectNonWhitelistTransactionState(bool value) external onlyOwner {
        _rejectNonWhitelistTransaction = value;
    }

    /**
     * @dev Creates `amount` VOKENs and assigns them to `account`, increasing the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(_totalSupply.add(amount) <= _cap, "VOKEN: total supply cap exceeded");
        require(account != address(0), "VOKEN: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` VOKENs from `account`, reducing the total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     */
    function _burn(address account, uint256 amount) internal {
        _balances[account] = _balances[account].sub(amount, "VOKEN: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Throws if called by account which is not a minter.
     */
    modifier onlyMinter() {
        require(isMinter(msg.sender), "MinterRole: caller does not have the Minter role");
        _;
    }

    /**
     * @dev Returns true if the `account` has the Minter role
     */
    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    /**
     * @dev Give an `account` access to the Minter role.
     */
    function addMinter(address account) public onlyOwner {
        _minters.add(account);
        emit MinterAdded(account);
    }

    /**
     * @dev Remove an `account` access from the Minter role.
     */
    function removeMinter(address account) public onlyOwner {
        _minters.remove(account);
        emit MinterRemoved(account);
    }

    /**
     * @dev Creates `amount` VOKENs and assigns them to `account`
     */
    function mint(address account, uint256 amount) public onlyMinter returns (bool) {
        _mint(account, amount);
        return true;
    }

    /**
     * @dev Returns true if the whitelist sign-up is allowed.
     */
    function allowWhitelistSignUp() public view returns (bool) {
        return _allowWhitelistSignUp;
    }

    /**
     * @dev Enable/disable whitelist sign-up.
     */
    function setWhitelistSignUpState(bool value) external onlyOwner {
        _allowWhitelistSignUp = value;

        if (_allowWhitelistSignUp) {
            emit WhitelistSignUpEnabled();
        } else {
            emit WhitelistSignUpDisabled();
        }
    }

    /**
     * @dev Returns true if the `account` is whitelisted.
     */
    function inWhitelist(address account) public view returns (bool) {
        return _referee[account] != address(0);
    }

    /**
     * @dev Returns the referee of an `account`.
     */
    function referee(address account) public view returns (address) {
        return _referee[account];
    }

    /**
     * @dev Returns referrals of a `account`
     */
    function referrals(address account) public view returns (address[] memory) {
        return _referrals[account];
    }

    /**
     * @dev Returns the referrals count of an `account`.
     */
    function referralsCount(address account) public view returns (uint256) {
        return _referrals[account].length;
    }

    /**
     * @dev Batch whitelist.
     */
    function batchWhitelist(address[] memory accounts, address[] memory refereeAccounts) public onlyOwner {
        require(accounts.length == refereeAccounts.length);

        for (uint256 i = 0; i < accounts.length; i++) {
            if (accounts[i] != address(0) && !inWhitelist(accounts[i]) && inWhitelist(refereeAccounts[i])) {
                _whitelist(accounts[i], refereeAccounts[i]);
            }
        }
    }

    /**
     * @dev Whitelist an `account` with a `refereeAccount`.
     */
    function _whitelist(address account, address refereeAccount) internal {
        _referee[account] = refereeAccount;
        _referrals[refereeAccount].push(account);

        emit WhitelistSignedUp(account, refereeAccount);
    }

    /**
     * @dev Whitelist sign-up.
     */
    function _whitelistSignUp(address account, address refereeAccount) internal {
        _whitelist(account, refereeAccount);

        // Whitelist Registration Referral Reward
        _transfer(msg.sender, address(this), _whitelistSignUpValue);
        address __cursor = account;
        for(uint i = 0; i < _whitelistRefRewards.length; i++) {
            address __receiver = _referee[__cursor];

            if (__cursor == __receiver) {
                break;
            }

            if (_referrals[__receiver].length > i) {
                _transfer(address(this), __receiver, _whitelistRefRewards[i]);
            }

            __cursor = _referee[__cursor];
        }

        // Transfer 1 Voken back
        _transfer(address(this), msg.sender, _whitelistSignUpValueBack);
    }

    /**
     * @dev Returns true if the given address is not a contract
     */
    function isNotContract(address addr) internal view returns (bool) {
        uint __size;
        assembly {
            __size := extcodesize(addr)
        }
        return __size == 0;
    }
}
