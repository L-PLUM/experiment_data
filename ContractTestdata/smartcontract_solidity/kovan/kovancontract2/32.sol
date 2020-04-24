/**
 *Submitted for verification at Etherscan.io on 2019-08-08
*/

pragma solidity ^0.5.10;

// Voken Whitelist Contract
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
     *
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
interface IERC20 {
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
 * @dev Interface of VOKEN
 */
interface IVoken {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function burn(uint256 amount) external returns (bool);
}


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 */
contract Ownable {
    address internal _owner;
    address internal _newOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event OwnershipAccepted(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the addresses of the current and new owner.
     */
    function owner() public view returns (address currentOwner, address newOwner) {
        currentOwner = _owner;
        newOwner = _newOwner;
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
     *
     * IMPORTANT: Need to run {acceptOwnership} by the new owner.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");

        emit OwnershipTransferred(_owner, newOwner);
        _newOwner = newOwner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     *
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Accept ownership of the contract.
     *
     * Can only be called by the new owner.
     */
    function acceptOwnership() public {
        require(msg.sender == _newOwner, "Ownable: caller is not the new owner address");
        require(msg.sender != address(0), "Ownable: caller is the zero address");

        emit OwnershipAccepted(_owner, msg.sender);
        _owner = msg.sender;
        _newOwner = address(0);
    }

    /**
     * @dev Rescue compatible ERC20 Token
     *
     * Can only be called by the current owner.
     */
    function rescueTokens(address tokenAddr, address recipient, uint256 amount) external onlyOwner {
        IERC20 _token = IERC20(tokenAddr);
        require(recipient != address(0), "Rescue: recipient is the zero address");
        uint256 balance = _token.balanceOf(address(this));

        require(balance >= amount, "Rescue: amount exceeds balance");
        _token.transfer(recipient, amount);
    }

    /**
     * @dev Withdraw Ether
     *
     * Can only be called by the current owner.
     */
    function withdrawEther(address payable recipient, uint256 amount) external onlyOwner {
        require(recipient != address(0), "Withdraw: recipient is the zero address");

        uint256 balance = address(this).balance;

        require(balance >= amount, "Withdraw: amount exceeds balance");
        recipient.transfer(amount);
    }
}


/**
 * @title Voken Whitelist
 */
contract VokenWhitelist is Ownable {
    using SafeMath256 for uint256;
    using Roles for Roles.Role;

    bool private _allowSignUp;
    uint256 private _counter;
    uint256 private _vokenRefund = 1000000;     // 1 VOKEN for success signal
    uint256 private _vokenRewards = 1000000000; // 1000 VOKENs for rewards
    uint256[15] private _vokenRewardsArr = [
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

    Roles.Role private _proxies;
    IVoken private _voken;

    mapping (address => address) private _referee;
    mapping (address => address[]) private _referrals;

    event Donate(address indexed account, uint256 amount);
    event ProxyAdded(address indexed account);
    event ProxyRemoved(address indexed account);
    event SignUpEnabled();
    event SignUpDisabled();
    event SignedUp(address indexed account, address indexed refereeAccount);

    /**
     * @dev Constructor
     */
    constructor () public {
        _allowSignUp = true;
        
        _referee[msg.sender] = msg.sender;
        _counter = 1;

        emit SignUpEnabled();
        emit SignedUp(msg.sender, msg.sender);

        addProxy(msg.sender);
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
     * @dev Returns the VOKEN main contract address.
     */
    function VOKEN() public view returns (IVoken) {
        return _voken;
    }

    /**
     * @dev Sets the VOKEN main contract address.
     */
    function setVokenMainContract(IVoken vokenMainContract) public onlyOwner {
        require(address(vokenMainContract) != address(0), "VOKEN: main contract is the zero address");
        _voken = vokenMainContract;
    }

    /**
     * @dev Throws if called by account which is not a proxy.
     */
    modifier onlyProxy() {
        require(isProxy(msg.sender), "ProxyRole: caller does not have the Proxy role");
        _;
    }

    /**
     * @dev Returns true if the `account` has the Proxy role.
     */
    function isProxy(address account) public view returns (bool) {
        return _proxies.has(account);
    }

    /**
     * @dev Give an `account` access to the Proxy role.
     *
     * Can only be called by the current owner.
     */
    function addProxy(address account) public onlyOwner {
        _proxies.add(account);
        emit ProxyAdded(account);
    }

    /**
     * @dev Remove an `account` access from the Proxy role.
     *
     * Can only be called by the current owner.
     */
    function removeProxy(address account) public onlyOwner {
        _proxies.remove(account);
        emit ProxyRemoved(account);
    }

    /**
     * @dev Returns the counter.
     */
    function counter() public view returns (uint256) {
        return _counter;
    }

    /**
     * @dev Returns true if the sign-up is allowed.
     */
    function allowSignUp() public view returns (bool) {
        return _allowSignUp;
    }

    /**
     * @dev Enable/disable sign-up.
     *
     * Can only be called by the current owner.
     */
    function setSignUpState(bool value) public onlyOwner {
        _allowSignUp = value;

        if (_allowSignUp) {
            emit SignUpEnabled();
        } else {
            emit SignUpDisabled();
        }
    }

    /**
     * @dev Returns true if the `account` is whitelisted.
     */
    function whitelisted(address account) public view returns (bool) {
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
     * @dev Batch.
     *
     * Can only be called by a proxy.
     */
    function batch(address[] memory accounts, address[] memory refereeAccounts) public onlyProxy returns (bool) {
        require(accounts.length == refereeAccounts.length, "VOKEN Whitelist: batch length is not match");

        for (uint256 i = 0; i < accounts.length; i++) {
            if (accounts[i] != address(0) && !whitelisted(accounts[i]) && whitelisted(refereeAccounts[i])) {
                _whitelist(accounts[i], refereeAccounts[i]);
            }
        }

        return true;
    }

    /**
     * @dev Whitelist an `account` with a `refereeAccount`.
     *
     * Emits {SignedUp} event.
     */
    function _whitelist(address account, address refereeAccount) internal {
        require(!whitelisted(account), "VOKEN Whitelist: account is already whitelisted");
        require(whitelisted(refereeAccount), "VOKEN Whitelist: refereeAccount is not whitelisted");

        _referee[account] = refereeAccount;
        _referrals[refereeAccount].push(account);
        _counter = _counter.add(1);

        emit SignedUp(account, refereeAccount);
    }

    /**
     * @dev Sign-up
     *
     * Can only be called by a proxy.
     */
    function signUp(address account, address refereeAccount) public onlyProxy returns (bool) {
        _whitelist(account, refereeAccount);

        _distributeVokens(account);
        return true;
    }

    /**
     * @dev Distribute VOKENs.
     */
    function _distributeVokens(address account) internal {
        uint256 __distributedAmount;
        uint256 __burnAmount;

        address __cursor = account;
        for(uint i = 0; i < _vokenRewardsArr.length; i++) {
            address __receiver = _referee[__cursor];

            if (__receiver != address(0)) {
                if (__receiver != __cursor && _referrals[__receiver].length > i) {
                    assert(_voken.transfer(__receiver, _vokenRewardsArr[i]));
                    __distributedAmount = __distributedAmount.add(_vokenRewardsArr[i]);
                }
            }

            __cursor = _referee[__cursor];
        }

        // Burn
        __burnAmount = _vokenRewards.sub(__distributedAmount);
        if (__burnAmount > 0) {
            _voken.burn(__burnAmount);
        }

        // Transfer VOKEN refund as a success signal.
        assert(_voken.transfer(account, _vokenRefund));
    }
}
