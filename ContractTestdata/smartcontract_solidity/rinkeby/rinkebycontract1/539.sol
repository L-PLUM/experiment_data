/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity ^0.5.3;

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


library SafeMathMod { // Partial SafeMath Library

    function mul(uint256 a, uint256 b) pure internal returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) pure internal returns(uint256) {
        assert(b != 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256 c) {
        require((c = a - b) < a);
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256 c) {
        require((c = a + b) > a);
    }
}

contract Usdc { //is inherently ERC20
    using SafeMathMod
    for uint256;

    /**
     * @constant name The name of the token
     * @constant symbol  The symbol used to display the currency
     * @constant decimals  The number of decimals used to dispay a balance
     * @constant totalSupply The total number of tokens times 10^ of the number of decimals
     * @constant MAX_UINT256 Magic number for unlimited allowance
     * @storage balanceOf Holds the balances of all token holders
     * @storage allowed Holds the allowable balance to be transferable by another address.
     */

    address owner;



    string constant public name = "USDC";

    string constant public symbol = "USDC";

    uint256 constant public decimals = 18;

    uint256 constant public totalSupply = 100000000e18;

    uint256 constant private MAX_UINT256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowed;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event TransferFrom(address indexed _spender, address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function() external payable {
        revert();
    }

    constructor () public {
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }




    /**
     * @dev function that sells available tokens
     */


    function transfer(address _to, uint256 _value) public returns(bool success) {
        /* Ensures that tokens are not sent to address "0x0" */
        require(_to != address(0));
        /* Prevents sending tokens directly to contracts. */


        /* SafeMathMOd.sub will throw if there is not enough balance and if the transfer value is 0. */
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool success) {
        /* Ensures that tokens are not sent to address "0x0" */
        require(_to != address(0));
        /* Ensures tokens are not sent to this contract */


        uint256 allowance = allowed[_from][msg.sender];
        /* Ensures sender has enough available allowance OR sender is balance holder allowing single transsaction send to contracts*/
        require(_value <= allowance || _from == msg.sender);

        /* Use SafeMathMod to add and subtract from the _to and _from addresses respectively. Prevents under/overflow and 0 transfers */
        balanceOf[_to] = balanceOf[_to].add(_value);
        balanceOf[_from] = balanceOf[_from].sub(_value);

        /* Only reduce allowance if not MAX_UINT256 in order to save gas on unlimited allowance */
        /* Balance holder does not need allowance to send from self. */
        if (allowed[_from][msg.sender] != MAX_UINT256 && _from != msg.sender) {
            allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
     * @dev Transfer the specified amounts of tokens to the specified addresses.
     * @dev Be aware that there is no check for duplicate recipients.
     *
     * @param _toAddresses Receiver addresses.
     * @param _amounts Amounts of tokens that will be transferred.
     */
    function multiPartyTransfer(address[] memory _toAddresses, uint256[] memory _amounts) public {
        /* Ensures _toAddresses array is less than or equal to 255 */
        require(_toAddresses.length <= 255);
        /* Ensures _toAddress and _amounts have the same number of entries. */
        require(_toAddresses.length == _amounts.length);

        for (uint8 i = 0; i < _toAddresses.length; i++) {
            transfer(_toAddresses[i], _amounts[i]);
        }
    }

    /**
     * @dev Transfer the specified amounts of tokens to the specified addresses from authorized balance of sender.
     * @dev Be aware that there is no check for duplicate recipients.
     *
     * @param _from The address of the sender
     * @param _toAddresses The addresses of the recipients (MAX 255)
     * @param _amounts The amounts of tokens to be transferred
     */
    function multiPartyTransferFrom(address _from, address[] memory _toAddresses, uint256[] memory _amounts) public {
        /* Ensures _toAddresses array is less than or equal to 255 */
        require(_toAddresses.length <= 255);
        /* Ensures _toAddress and _amounts have the same number of entries. */
        require(_toAddresses.length == _amounts.length);

        for (uint8 i = 0; i < _toAddresses.length; i++) {
            transferFrom(_from, _toAddresses[i], _amounts[i]);
        }
    }

    /**
     * @notice `msg.sender` approves `_spender` to spend `_value` tokens
     *
     * @param _spender The address of the account able to transfer the tokens
     * @param _value The amount of tokens to be approved for transfer
     * @return Whether the approval was successful or not
     */
    function approve(address _spender, uint256 _value) public returns(bool success) {
        /* Ensures address "0x0" is not assigned allowance. */
        require(_spender != address(0));

        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(address _owner, address _spender) public view returns(uint256 remaining) {
        remaining = allowed[_owner][_spender];
    }

    function isNotContract(address _addr) private view returns(bool) {
        uint length;
        assembly {
            /* retrieve the size of the code on target address, this needs assembly */
            length: = extcodesize(_addr)
        }
        return (length == 0);
    }

}








contract AkemonaCrowdsale {
    using SafeMath for uint256;

    struct RefundRequest {
        uint256 purchaseIndex;
        // TODO: partial refund
    }

    RefundRequest[] refundRequests;

    struct Purchase {
        address investor;
        uint256 paid;
        uint256 received;
        bool refunded;
        bool refundRequested;
    }

    Purchase[] purchases;

    address public owner;

    AkemonaCrowdsaleToken public token;
    Usdc public usdc;
    AkemonaWhitelist public whitelist;
    address public escrow;
    uint256 public openingTime;
    uint256 public closingTime;
    uint256 public minimumInvestment;
    uint256 public goal;
    uint256 public cap;

    uint256 public raised;



    bool public isDisbursed;
    uint256 public disbursementTime;

    bool private _paused;


    // zero coupon bond
    uint256 public maturityTime;
    uint256 public rate;

    event PurchaseEvent(address indexed _purchaser, uint256 indexed _paid, uint256 indexed _received);

    constructor(
            address payable _usdc, 
            address _whitelist, 
            address _escrow, 
            uint256 _openingTime, 
            uint256 _closingTime, 

            uint256 _minimumInvestment,
            uint256 _goal,
            uint256 _cap,

            uint256 _maturityTime,
            uint256 _rate
            
            ) public {
        owner = msg.sender;
        raised = 0;

        token = new AkemonaCrowdsaleToken();
        usdc = Usdc(_usdc);
        whitelist = AkemonaWhitelist(_whitelist);
        escrow = _escrow;
        openingTime = _openingTime;
        closingTime = _closingTime;
        minimumInvestment = _minimumInvestment;
        goal = _goal;
        cap = _cap;

        require(closingTime > openingTime, "Invalid closingTime");


        maturityTime = _maturityTime;
        require(maturityTime > closingTime, "Invalid maturityTime");
        rate = _rate;
    }

    modifier restricted() {
        if (msg.sender == owner) _;
    }

    modifier whenNotPaused() {
        require(!_paused, "Contract is paused");
        _;
    }

    modifier whenPaused() {
        require(_paused, "Contract is not paused");
        _;
    }

    function getTokensPerDollar(uint256 usdcAmount) public view returns (uint256) {
        return usdcAmount;
    }

    function getPricePerToken() public view returns (uint256) {
         // 1 dollar
        uint256 faceValue = 1e18;

        if (block.timestamp > maturityTime) {
            return faceValue;
        }

        // TODO: calculate this

        return faceValue;
    }

    function purchase() public whenNotPaused {
        require(!isDisbursed, "Contract is already disbursed");
        require(block.timestamp < closingTime, "Contract is past its closing time.");
        require(block.timestamp > openingTime, "Contract is not yet open.");

        require(raised < cap, "Contract has already met its cap.");

        require(usdc.allowance(msg.sender, address(this)) > 0, "Sender has not approved a USDC transfer to escrow.");
        uint usdcAmount = usdc.allowance(msg.sender, address(this));

        require(raised + usdcAmount < cap, "This purchase would put contract over its cap.");


        require(whitelist.isPurchaseAuthorized(msg.sender, usdcAmount), "Sender is not whitelisted.");
        require (usdcAmount > minimumInvestment, "Amount is below the minimum investment.");
        require(usdc.transferFrom(msg.sender, escrow, usdcAmount), "USDC transfer failed.");

        /*
        TODO
        -	If the address is in the list of pending refunds, reject the purchase
        */

        uint256 amountToIssue = getTokensPerDollar(usdcAmount);
        require(token.mint(msg.sender, amountToIssue), "Token failed to mint.");

        raised = raised + usdcAmount;

        purchases.push(Purchase(msg.sender, usdcAmount, amountToIssue, false, false));

        emit PurchaseEvent(msg.sender, usdcAmount, amountToIssue);
    }

    function setDisbursed(bool _isDisbursed, uint256 _disbursementTime) public restricted {
        isDisbursed = _isDisbursed;
        disbursementTime = _disbursementTime;
    }

    function pause() public restricted whenNotPaused {
        _paused = true;
    }


    function unpause() public restricted whenPaused {
        _paused = false;
    }

    function paused() public view returns (bool) {
        return _paused;
    }

    function isTransferAuthorized(address _from, address _to, uint256 value) public view returns (bool) {
        if (_paused) {
            return false;
        }

        return whitelist.isTransferAuthorized(_from, _to, this);
    }

    // Refunds the sender's purchase(s)
    function requestRefund(bool onlyMostRecent) public whenNotPaused {
        require(!isDisbursed, "Contract is already disbursed");

        bool refundProcessed = false;
        bool cont = true;

        for (uint i = purchases.length - 1; i >= 0 && cont; i--) {
            if (purchases[i].investor == msg.sender && !purchases[i].refunded && !purchases[i].refundRequested) {
                purchases[i].refundRequested = true;
                refundRequests.push(RefundRequest(i));
                refundProcessed = true;
                if (onlyMostRecent) {
                    cont = false;
                }
            }
        }

        require(refundProcessed, "Refund request was not processed.  No eligible purchases found to refund.");
    }

    function disburseRefunds() public whenNotPaused {
        require(!isDisbursed, "Contract is already disbursed");

        uint256 usdcAuthorized = usdc.allowance(escrow, address(this));
        require(usdcAuthorized > 0, "Contract does not have authorization to refund USDC.");

        uint256 usdcAvailable = usdc.balanceOf(escrow);
        require(usdcAvailable > 0, "Insufficient funds.");

        if (usdcAuthorized < usdcAvailable) {
            usdcAvailable = usdcAuthorized;
        }

        bool continueProcessing = true;

        for (uint i = refundRequests.length - 1; i >= 0; i--) {
            if (continueProcessing) {
                Purchase storage currentPurchase = purchases[refundRequests[i].purchaseIndex];
                if(!currentPurchase.refunded && currentPurchase.refundRequested) {
                    if (usdcAvailable >= currentPurchase.paid) {
                        // Process the refund
                        require(usdc.transferFrom(escrow, currentPurchase.investor, currentPurchase.paid), "USDC transfer failed.");
                        token.burnFrom(currentPurchase.investor, currentPurchase.received);
                        //require(, "Failed to recall tokens.");

                        currentPurchase.refunded = true;

                        raised = raised - currentPurchase.paid;
                    } else {
                        // Insufficient funds to process refund
                        continueProcessing = false;
                    }
                }
            }
        }
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








contract AkemonaWhitelist {
    using SafeMath for uint256;

    address public owner;

    mapping (address => bool) public accredited;
    mapping (address => bool) public whitelisted;
    mapping (address => mapping(address => bool)) public exceptions;

    constructor() public {
        owner = msg.sender;
    }

    modifier restricted() {
        if (msg.sender == owner) _;
    }

    function isPurchaseAuthorized(address _investor, uint256 _amount) public view returns (bool) {
        if (!whitelisted[_investor]) {
            return false;
        }
        return true;
    }

    function isTransferAuthorized(address _from, address _to, AkemonaCrowdsale _contract) public view returns (bool) {
        if (!_contract.isDisbursed()) {
            return false;
        }
        if (!whitelisted[_to]) {
            return false;
        }
        if (block.timestamp - _contract.disbursementTime() > 60 * 60 * 24 * 365) {
            return true;
        }
        if (exceptions[_from][_to]) {
            return true;
        }
        // TODO
        // If the crowdsale contract is in a buyback period, and the toAddress is the borrower, and the fromAddress is an original investor in the crowdsale, return true
        return false;
    }

    function addAccreditedAddresses(address[] memory _addresses) public restricted {
        for (uint8 i = 0; i < _addresses.length; i++) {
            accredited[_addresses[i]] = true;
            whitelisted[_addresses[i]] = true;
        }
    }

    function addWhitelistedAddresses(address[] memory _addresses) public restricted {
        for (uint8 i = 0; i < _addresses.length; i++) {
            accredited[_addresses[i]] = false;
            whitelisted[_addresses[i]] = true;
        }
    }

    function removeAccreditedAddresses(address[] memory _addresses) public restricted {
        for (uint8 i = 0; i < _addresses.length; i++) {
            accredited[_addresses[i]] = false;
            whitelisted[_addresses[i]] = false;
        }
    }

    function removeWhitelistedAddresses(address[] memory _addresses) public restricted {
        for (uint8 i = 0; i < _addresses.length; i++) {
            accredited[_addresses[i]] = false;
            whitelisted[_addresses[i]] = false;
        }
    }

    function addException(address _from, address  _to) public restricted {
        exceptions[_from][_to] = true;
    }

    function removeException(address _from, address _to) public restricted {
        exceptions[_from][_to] = false;
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





/**
 * @title ERC20Detailed token
 * @dev The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @return the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @return the symbol of the token.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @return the number of decimals of the token.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
}







/**
 * @title SampleCrowdsaleToken
 * @dev Very simple ERC20 Token that can be minted.
 * It is meant to be used in a crowdsale contract.
 */
contract AkemonaCrowdsaleToken is ERC20Mintable, ERC20Detailed {

    AkemonaCrowdsale crowdsale;

    constructor () public ERC20Detailed("Akemona aPledge Token", "AKPL", 18) {
        // solhint-disable-previous-line no-empty-blocks
    }

    function setCrowdsale(address _crowdsale) public onlyMinter {
        crowdsale = AkemonaCrowdsale(_crowdsale);
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(crowdsale.isTransferAuthorized(from, to, value), "Transfer is not authorized.");
        super._transfer(from, to, value);
    }


    function burn(uint256 value) public onlyMinter {
        _burn(msg.sender, value);
    }

    function burnFrom(address from, uint256 value) public onlyMinter {
        _burnFrom(from, value);
    }
}
