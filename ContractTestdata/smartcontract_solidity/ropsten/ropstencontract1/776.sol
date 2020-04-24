/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

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
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

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
    constructor () internal {
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
        require(isOwner());
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
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract WhitelistAdminRole is Ownable {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(msg.sender));
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyOwner {
        _addWhitelistAdmin(account);
    }

    function removeWhitelistAdmin(address account) public onlyOwner {
        _removeWhitelistAdmin(account);
    }

    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}

contract Whitelist {
    event WhitelistCreated(address account);
    event WhitelistChange(address indexed account, bool allowed);

    constructor() public {
        emit WhitelistCreated(address(this));
    }

    function isWhitelisted(address account) public view returns (bool);
}

contract ReferrerProvider is Whitelist {
    event ReferrerProviderCreated(address account);
    event ReferrerChange(address indexed account, address referrer);

    constructor() public {
        emit ReferrerProviderCreated(address(this));
    }

    function getReferrer(address account) public view returns (address referrer);

    function isWhitelisted(address account) public view returns (bool) {
        return getReferrer(account) != address(0);
    }
}

contract ReferrerProviderImpl is ReferrerProvider, WhitelistAdminRole {
    mapping(address => address) public referrers;

    function getReferrer(address _address) public view returns (address referrer) {
        referrer = referrers[_address];
    }

    function setReferrer(address _address, address _referrer) public onlyWhitelistAdmin {
        _setReferrer(_address, _referrer);
    }

    function _setReferrer(address _address, address _referrer) internal {
        referrers[_address] = _referrer;
        emit WhitelistChange(_address, _referrer != address(0));
        emit ReferrerChange(_address, _referrer);
    }
}

contract WhitelistImpl is WhitelistAdminRole, Whitelist {
    mapping(address => bool) public whitelist;

    function isWhitelisted(address account) public view returns (bool) {
        return whitelist[account];
    }

    function addToWhitelist(address[] memory accounts) public onlyWhitelistAdmin {
        for(uint i = 0; i < accounts.length; i++) {
            _setWhitelisted(accounts[i], true);
        }
    }

    function removeFromWhitelist(address[] memory accounts) public onlyWhitelistAdmin {
        for(uint i = 0; i < accounts.length; i++) {
            _setWhitelisted(accounts[i], false);
        }
    }

    function setWhitelisted(address account, bool whitelisted) public onlyWhitelistAdmin {
        _setWhitelisted(account, whitelisted);
    }

    function setWhitelist(address account, bool whitelisted) public onlyWhitelistAdmin {
        _setWhitelisted(account, whitelisted);
    }

    function _setWhitelisted(address account, bool whitelisted) internal {
        whitelist[account] = whitelisted;
        emit WhitelistChange(account, whitelisted);
    }
}

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

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}

contract Events {
    enum BonusType {
        AMOUNT,
        TIME,
        REFERRER,
        REFEREE,
        RESERVED1,
        RESERVED2,
        RESERVED3,
        RESERVED4,
        RESERVED5,
        RESERVED6,
        OTHER
    }

    event Purchase(address indexed beneficiary, address token, uint256 paid, uint256 purchased, uint256 bonus);

    event Bonus(address indexed beneficiary, uint256 amount, BonusType bonusType);
}

/**
 * @title Sale
 * @dev Sale is a base contract for managing a crowdsale,
 * allowing investors to purchase with ether or other payment methods (ERC-20 tokens or BTC etc.)
 * This contract implements such functionality in its most fundamental form and can be extended
 * to provide additional functionality and/or custom behavior.
 * The external interface represents the basic interface for purchasing items, and conform
 * the base architecture for crowdsales. They are *not* intended to be modified / overridden.
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override
 * the methods to add functionality. Consider using 'super' where appropriate to concatenate
 * behavior.
 * This contract is based on openzeppelin Crowdsale contract
 */
contract Sale is Ownable, Events {
    using SafeMath for uint256;

    function () external payable {
        _purchase(msg.sender, address(0), msg.value);
    }

    function buyTokens(address payable _beneficiary) external payable {
        _purchase(_beneficiary, address(0), msg.value);
    }

    /**
     * @dev low level purchase ***DO NOT OVERRIDE***
     * @param _beneficiary Recipient of the purchase
     * @param _token Token paid
     * @param _value value paid
     */
    function _purchase(address payable _beneficiary, address _token, uint _value) internal {
        _preValidatePurchase(_beneficiary, _token, _value);
        (uint purchased, uint change) = _getPurchasedAmount(_beneficiary, _token, _value);
        require(purchased > 0);
        uint bonus = _getBonus(_beneficiary, purchased);
        _deliver(_beneficiary, purchased + bonus);
        emit Purchase(_beneficiary, _token, _value, purchased, bonus);
        _updateState(_beneficiary, _token, _value, purchased, bonus);
        _postValidatePurchase(_beneficiary, _token, _value, purchased, bonus);
        if (change > 0) {
            _processChange(_beneficiary, _token, change);
        }
    }

    function _processChange(address payable _beneficiary, address _token, uint _change) internal {
        if (_token == address(0)) {
            _beneficiary.transfer(_change);
        }
    }

    function _preValidatePurchase(address _beneficiary, address /*_token*/, uint _value) view internal {
        require(_beneficiary != address(0));
        require(_value != 0);
    }

    function _getPurchasedAmount(address _beneficiary, address _token, uint _value) internal returns (uint amount, uint change);

    function _getBonus(address _beneficiary, uint _amount) internal returns (uint) {
        return 0;
    }

    function _deliver(address _beneficiary, uint _amount) internal;

    function _updateState(address _beneficiary, address _token, uint _value, uint _purchased, uint _bonus) internal {

    }

    function _postValidatePurchase(address _beneficiary, address _token, uint _value, uint _purchased, uint _bonus) internal {

    }

    function withdrawEth(address payable _to, uint _value) public onlyOwner {
        _to.transfer(_value);
    }
}

contract WhitelistSale is Sale {

    function getWhitelists() public view returns (address[] memory);

    function _isWhitelisted(address account) internal view returns (bool);

    function _preValidatePurchase(address _beneficiary, address _token, uint _value) view internal {
        super._preValidatePurchase(_beneficiary, _token, _value);
        require(_isWhitelisted(_beneficiary));
    }
}

contract ReferralBonusSale is Sale {

    uint public referrerBonus;
    uint public refereeBonus;

    constructor(uint _referrerBonus, uint _refereeBonus) public {
        referrerBonus = _referrerBonus;
        refereeBonus = _refereeBonus;
    }

    function _getReferrer(address account) internal view returns (address referrer);

    function _getBonus(address _beneficiary, uint _amount) internal returns (uint) {
        address referrer = _getReferrer(_beneficiary);
        if (referrer != address(0) && referrer != address(1)) {
            uint realReferrerBonus = _amount.mul(referrerBonus).div(1000);
            emit Bonus(referrer, realReferrerBonus, BonusType.REFERRER);
            _deliver(referrer, realReferrerBonus);

            uint realRefereeBonus = _amount.mul(refereeBonus).div(1000);
            emit Bonus(_beneficiary, realRefereeBonus, BonusType.REFEREE);
            return realRefereeBonus;
        } else {
            return 0;
        }
    }

    function setReferrerBonus(uint _referrerBonus) public onlyOwner {
        referrerBonus = _referrerBonus;
    }

    function setRefereeBonus(uint _refereeBonus) public onlyOwner {
        refereeBonus = _refereeBonus;
    }
}

contract InternalWhitelistReferralBonusSale is ReferrerProviderImpl, WhitelistSale, ReferralBonusSale {

    constructor(uint _referrerBonus, uint _refereeBonus) ReferralBonusSale(_referrerBonus, _refereeBonus) public {

    }

    function _getReferrer(address account) internal view returns (address referrer) {
        referrer = getReferrer(account);
    }

    function _isWhitelisted(address account) internal view returns (bool) {
        return isWhitelisted(account);
    }

    function setReferrer(address _address, address _referrer) public onlyWhitelistAdmin {
        if (_referrer != address(0) && _referrer != address(1)) {
            require(getReferrer(_referrer) != address(0));
        }
        _setReferrer(_address, _referrer);
    }

    function getWhitelists() public view returns (address[] memory) {
        address[] memory result = new address[](1);
        result[0] = address(this);
        return result;
    }
}

contract OperatorRole is Ownable {
    using Roles for Roles.Role;

    event OperatorAdded(address indexed account);
    event OperatorRemoved(address indexed account);

    Roles.Role private _operators;

    modifier onlyOperator() {
        require(isOperator(msg.sender));
        _;
    }

    function isOperator(address account) public view returns (bool) {
        return _operators.has(account);
    }

    function addOperator(address account) public onlyOwner {
        _addOperator(account);
    }

    function removeOperator(address account) public onlyOwner {
        _removeOperator(account);
    }

    function _addOperator(address account) internal {
        _operators.add(account);
        emit OperatorAdded(account);
    }

    function _removeOperator(address account) internal {
        _operators.remove(account);
        emit OperatorRemoved(account);
    }
}

contract UiEvents {

    /**
     * @dev Should be emitted if new payment method added
     */
    event RateAdd(address token);
    /**
     * @dev Should be emitted if payment method removed
     */
    event RateRemove(address token);
    /**
     * @dev Should be emitted if purchase is processed through external tx
     */
    event ExternalTx(bytes txId);
}

contract SidechainSale is UiEvents, OperatorRole, Sale {
    event XPubChange(address token, string xpub);
    event Change(address token, uint value);

    mapping(address => string) xpubs;

    function setXPub(address _token, string memory _xpub) onlyOwner public {
        setXPubInternal(_token, _xpub);
    }

    function setXPubInternal(address _token, string memory _xpub) internal {
        xpubs[_token] = _xpub;
        emit XPubChange(_token, _xpub);
    }

    function getXPub(address token) view public returns (string memory) {
        return xpubs[token];
    }

    function onReceive(address payable _buyer, address _token, uint256 _value, bytes memory _txId) onlyOperator public {
        require(_token != address(0));
        emit ExternalTx(_txId);
        _purchase(_buyer, _token, _value);
    }

    function _processChange(address payable _beneficiary, address _token, uint _change) internal {
        super._processChange(_beneficiary, _token, _change);
        if (_token == address(1) || _token == address(2) || _token == address(3) || _token == address(4)) {
            emit Change(_token, _change);
        }
    }
}

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
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

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
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
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
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
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
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
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
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
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
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
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

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
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
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}

contract MinterRole {
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {
        _addMinter(account);
    }

    function renounceMinter() public {
        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

/**
 * @title ERC20Mintable
 * @dev ERC20 minting logic
 */
contract ERC20Mintable is ERC20, MinterRole {
    /**
     * @dev Function to mint tokens
     * @param to The address that will receive the minted tokens.
     * @param value The amount of tokens to mint.
     * @return A boolean that indicates if the operation was successful.
     */
    function mint(address to, uint256 value) public onlyMinter returns (bool) {
        _mint(to, value);
        return true;
    }
}

contract MintingSale is Sale {

    ERC20Mintable public token;

    constructor(ERC20Mintable _token) public {
        token = _token;
    }

    function _deliver(address _beneficiary, uint _amount) internal {
        require(token.mint(_beneficiary, _amount));
    }
}

interface KyberNetworkProxy {
    function getExpectedRate(address src, address dest, uint srcQty) view external returns(uint expectedRate, uint slippageRate);
}

contract KyberNetworkRateSale {
    using SafeMath for uint;

    address constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address constant DAI = 0xaD6D458402F60fD3Bd25163575031ACDce07538D;
    address constant WBTC = 0xC269Ed4189F835fb3C3eAb4FEa4cFfBBAcc0d349;

    function _getKyberNetwork() internal view returns (KyberNetworkProxy);

    function _getRateToDai(address _token, uint _value) internal view returns (uint expected) {
        (expected,) = _getKyberNetwork().getExpectedRate(_token, DAI, _value);
    }

    function _getDaiValue(address _token, uint _value) view internal returns (uint daiValue, uint rateToDai, uint tokenDecimals) {
        address kyberTokenAddress;
        if (_token == address(0)) {
            kyberTokenAddress = ETH;
            tokenDecimals = 18;
        } else if (_token == address(2)) {
            kyberTokenAddress = WBTC;
            tokenDecimals = 8;
        } else {
            return (0, 0, 0);
        }
        rateToDai = _getRateToDai(kyberTokenAddress, _value);
        daiValue = _value.mul(rateToDai).div(10 ** tokenDecimals);
    }

}

contract CustomRateSale is Ownable, KyberNetworkRateSale {
    uint public ethDaiRate;
    uint public wbtcDaiRate;

    function _getRateToDai(address _token, uint _value) view internal returns (uint expected) {
        if (_token == ETH && ethDaiRate != 0) {
            return ethDaiRate;
        } else if (_token == WBTC && wbtcDaiRate != 0) {
            return wbtcDaiRate;
        } else {
            return super._getRateToDai(_token, _value);
        }
    }

    function setEthDaiRate(uint _ethDaiRate) onlyOwner public {
        ethDaiRate = _ethDaiRate;
    }

    function setWbtcDaiRate(uint _wbtcDaiRate) onlyOwner public {
        wbtcDaiRate = _wbtcDaiRate;
    }
}

contract AbstractPools {
    struct PoolDescription {
        /**
         * @dev maximal amount of tokens in this pool
         */
        uint maxAmount;
        /**
         * @dev amount of tokens already released
         */
        uint releasedAmount;
        /**
         * @dev release time
         */
        uint releaseTime;
        /**
         * @dev release type of the holder (fixed - date is set in seconds since 01.01.1970, floating - date is set in seconds since holder creation, direct - tokens are transferred to beneficiary immediately)
         */
        ReleaseType releaseType;
    }

    enum ReleaseType { Fixed, Floating, Direct }

    event PoolCreatedEvent(string name, uint maxAmount, uint releaseTime, ReleaseType releaseType);
    event TokenHolderCreatedEvent(string name, address addr, uint amount);
}

contract TransitPools is Ownable {
    using SafeMath for uint256;

    struct PoolDescription {
        /**
         * @dev maximal amount of tokens in this pool
         */
        uint maxAmount;
        /**
         * @dev amount of tokens already released
         */
        uint releasedAmount;
        /**
         * @dev release time
         */
        uint releaseTime;
        /**
         * @dev release type of the holder (fixed - date is set in seconds since 01.01.1970, floating - date is set in seconds since holder creation, direct - tokens are transferred to beneficiary immediately)
         */
        ReleaseType releaseType;
    }

    enum ReleaseType { Fixed, Floating, Direct }

    event PoolCreatedEvent(string name, uint maxAmount, uint releaseTime, uint vestingInterval, uint value, ReleaseType releaseType);
    event TokenHolderCreatedEvent(string name, address addr, uint amount);

    uint constant DAY = 86400;
    uint constant INTERVAL = 30 * DAY;

    ERC20Mintable public token;
    uint public releaseDate = 1568505600; //09/15/2019 @ 12:00am (UTC)
    mapping(string => PoolDescription) pools;
    mapping(address => uint) public released;
    mapping(address => uint) public totals;

    constructor(ERC20Mintable _token) public {
        token = _token;
    }

    function registerPool(string memory _name, uint _maxAmount, ReleaseType _releaseType) internal {
        require(_maxAmount > 0, "maxAmount should be greater than 0");
        require(_releaseType != ReleaseType.Floating, "ReleaseType.Floating is not supported. use Pools instead");
        pools[_name] = PoolDescription(_maxAmount, 0, 0, _releaseType);
        emit PoolCreatedEvent(_name, _maxAmount, 0, INTERVAL, 20, _releaseType);
    }

    function createHolder(string memory _name, address _beneficiary, uint _amount) onlyOwner public {
        PoolDescription storage pool = pools[_name];
        require(pool.maxAmount != 0, "pool is not defined");
        uint newReleasedAmount = _amount.add(pool.releasedAmount);
        require(newReleasedAmount <= pool.maxAmount, "pool is depleted");
        pool.releasedAmount = newReleasedAmount;
        if (pool.releaseType == ReleaseType.Direct) {
            require(token.mint(_beneficiary, _amount));
        } else {
            require(token.mint(address(this), _amount));
            totals[_beneficiary] += _amount;
            emit TokenHolderCreatedEvent(_name, address(this), _amount);
        }
    }

    function getVestedAmount(address _beneficiary) view public returns (uint) {
        if (now < releaseDate) {
            return 0;
        }
        uint total = totals[_beneficiary];
        uint diff = now - releaseDate;
        uint interval = 1 + diff / INTERVAL;
        if (interval >= 5) {
            return total;
        }
        return interval * total / 5;
    }

    function release() public {
        uint vested = getVestedAmount(msg.sender);
        uint amount = vested - released[msg.sender];
        require(amount > 0);
        released[msg.sender] = vested;
        require(token.transfer(msg.sender, amount));
    }

    function getTokensLeft(string memory _name) view public returns (uint) {
        PoolDescription storage pool = pools[_name];
        require(pool.maxAmount != 0, "pool is not defined");
        return pool.maxAmount.sub(pool.releasedAmount);
    }

    function setReleaseDate(uint _releaseDate) onlyOwner public {
        releaseDate = _releaseDate;
    }
}

contract TransitSale is Ownable, Sale, TransitPools, CustomRateSale, SidechainSale, InternalWhitelistReferralBonusSale {

    event RateToDai(address token, uint value, uint rate);

    uint public constant START = 1548979200;
    uint public constant SALE_A_END = START + 14 * DAY;
    uint public constant SALE_B_END = SALE_A_END + 14 * DAY;
    uint public constant SALE_C_END = SALE_B_END + 14 * DAY;
    uint public constant PUBLIC_SALE_END = SALE_C_END + 31 * DAY;

    constructor(ERC20Mintable token) TransitPools(token) InternalWhitelistReferralBonusSale(100, 100) public {
        emit RateAdd(address(0));
        emit RateAdd(address(2));

        registerPool("Bounties", 57_500_000 * 10 ** 18, ReleaseType.Fixed);
        registerPool("Team", 300_000_000 * 10 ** 18, ReleaseType.Fixed);
        registerPool("Reserve", 375_000_000 * 10 ** 18, ReleaseType.Fixed);
        registerPool("Seed", 50_000_000 * 10 ** 18, ReleaseType.Fixed);
        registerPool("RoundA", 100_000_000 * 10 ** 18, ReleaseType.Fixed);
        registerPool("RoundB", 100_000_000 * 10 ** 18, ReleaseType.Fixed);
        registerPool("RoundC", 125_000_000 * 10 ** 18, ReleaseType.Fixed);
        registerPool("RoundD", 125_000_000 * 10 ** 18, ReleaseType.Fixed);
        registerPool("RoundE", 167_500_000 * 10 ** 18, ReleaseType.Fixed);
        registerPool("PreSaleA", 25_000_000 * 10 ** 18, ReleaseType.Direct);
        registerPool("PreSaleB", 25_000_000 * 10 ** 18, ReleaseType.Direct);
        registerPool("PreSaleC", 25_000_000 * 10 ** 18, ReleaseType.Direct);
        registerPool("PublicSale", 25_000_000 * 10 ** 18, ReleaseType.Direct);
    }

    function _getKyberNetwork() internal view returns (KyberNetworkProxy) {
        return KyberNetworkProxy(0x818E6FECD516Ecc3849DAf6845e3EC868087B755);
    }

    function _deliver(address _beneficiary, uint _amount) internal {
        require(token.mint(_beneficiary, _amount));
    }

    function _getPriceInDai() internal view returns (uint) {
        return getBasePrice() * 10 ** 16;
    }

    function _getPurchasedAmount(address _beneficiary, address _token, uint _value) internal returns (uint amount, uint change) {
        (uint daiValue, uint rateToDai, uint tokenDecimals) = _getDaiValue(_token, _value);
        emit RateToDai(_token, _value, rateToDai);
        PoolDescription storage pool = pools[getActivePool()];
        uint left = pool.maxAmount - pool.releasedAmount;
        amount = daiValue.mul(10 ** 18).div(_getPriceInDai());
        change = 0;
        if (amount > left) {
            amount = left;
            uint changeInDai = amount.mul(_getPriceInDai()).div(10 ** 18);
            change = changeInDai.mul(10 ** tokenDecimals).div(rateToDai);
        }
    }

    function _updateState(address _beneficiary, address _token, uint _value, uint _purchased, uint _bonus) internal {
        super._updateState(_beneficiary, _token, _value, _purchased, _bonus);
        PoolDescription storage pool = pools[getActivePool()];
        pool.releasedAmount = pool.releasedAmount.add(_purchased);
    }

    function getActivePool() public view returns (string memory) {
        if (now < START) {
            revert();
        } else if (now < SALE_A_END) {
            return "PreSaleA";
        } else if (now < SALE_B_END) {
            return "PreSaleB";
        } else if (now < SALE_C_END) {
            return "PreSaleC";
        } else if (now < PUBLIC_SALE_END) {
            return "PublicSale";
        } else {
            revert();
        }
    }

    function getBasePrice() public view returns (uint) {
        if (now < START) {
            return 0;
        } else if (now < SALE_A_END) {
            return 7;
        } else if (now < SALE_B_END) {
            return 8;
        } else if (now < SALE_C_END) {
            return 9;
        } else if (now < PUBLIC_SALE_END) {
            return 10;
        } else {
            return 0;
        }
    }

    /**
     * @dev function for Daonomic UI
     */
    function getRate(address _token) public view returns (uint256) {
        (uint daiValue,,) = _getDaiValue(_token, 10 ** 18);
        return daiValue.mul(10 ** 18).div(_getPriceInDai());
    }

    /**
     * @dev function for Daonomic UI
     */
    function start() public view returns (uint256) {
        return START;
    }

    /**
     * @dev function for Daonomic UI
     */
    function end() public view returns (uint256) {
        return PUBLIC_SALE_END;
    }

    /**
     * @dev function for Daonomic UI
     */
    function canBuy(address account) public view returns (bool) {
        return isWhitelisted(account);
    }
}
