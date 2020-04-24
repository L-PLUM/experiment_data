/**
 *Submitted for verification at Etherscan.io on 2019-08-12
*/

/**
 *Submitted for verification at Etherscan.io on 2019-07-30
*/

pragma solidity ^0.5.2;

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

contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
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


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
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
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

/**
 * @title ERC20 interface
 * @dev see https://eips.ethereum.org/EIPS/eip-20
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
 * Utility library of inline functions on addresses
 */
library Address {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(address(this), spender) == 0));
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must equal true).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves.

        // A Solidity high level call has three parts:
        //  1. The target address is checked to verify it contains contract code
        //  2. The call itself is made, and success asserted
        //  3. The return value is decoded, which in turn checks the size of the returned data.

        require(address(token).isContract());

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success);

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)));
        }
    }
}


/**
 * @title Math
 * @dev Assorted math operations
 */
library Math {
    /**
     * @dev Returns the largest of two numbers.
     */
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    /**
     * @dev Returns the smallest of two numbers.
     */
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }

    /**
     * @dev Calculates the average of two numbers. Since these are integers,
     * averages of an even and odd number cannot be represented, and will be
     * rounded down.
     */
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        // (a + b) / 2 can overflow, so we distribute
        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


/**
 * @title Secondary
 * @dev A Secondary contract can only be used by its primary account (the one that created it)
 */
contract Secondary {
    address private _primary;

    event PrimaryTransferred(
        address recipient
    );

    /**
     * @dev Sets the primary account to the one that is creating the Secondary contract.
     */
    constructor () internal {
        _primary = msg.sender;
        emit PrimaryTransferred(_primary);
    }

    /**
     * @dev Reverts if called from any account other than the primary.
     */
    modifier onlyPrimary() {
        require(msg.sender == _primary);
        _;
    }

    /**
     * @return the address of the primary.
     */
    function primary() public view returns (address) {
        return _primary;
    }

    /**
     * @dev Transfers contract to a new primary.
     * @param recipient The address of new primary.
     */
    function transferPrimary(address recipient) public onlyPrimary {
        require(recipient != address(0));
        _primary = recipient;
        emit PrimaryTransferred(_primary);
    }
}


/**
 * @title Global Whitelist Contract
 * @author Validity Labs AG <[email protected]>
 * @dev Only the admin (primary) can whitelist or unwhitelist tokens. 
 */
contract TokenWhitelist is Secondary {
    using SafeMath for uint256;

    mapping(address => bool) public isWhitelisted;

    /** EVENTS **/
    event ChangedWhitelisting(address indexed registrant, bool whitelisted);

    /** MODIFIERS **/
    /**
    * @dev to prevent forgetting this field
    */
    modifier onlyValidAddress(address _address) {
        require(_address != address(0), "invalid address");
        _;
    }

    /**
    * @dev whitelist tokens in batch
    * @param _addresses token addresses
    */
    function whitelistTokens(address[] calldata _addresses) external {
        require(_addresses.length < 256, "Too many orders. Please place fewer orders per batch.");
        for (uint256 i = 0; i < _addresses.length; i++) {
            whitelistToken(_addresses[i]);
        }
    }

    /**
    * @dev whitelist a token.
    * @param _address token address
    */
    function whitelistToken(address _address) public onlyPrimary onlyValidAddress(_address) {
        require(!isWhitelisted[_address], "Token already whitelisted.");
        isWhitelisted[_address] = true;
        emit ChangedWhitelisting(_address, true);
    }

    /**
    * @dev remove an address from the whitelist
    * @param _address token address
    */
    function unwhitelistToken(address _address) public onlyPrimary onlyValidAddress(_address) {
        require(isWhitelisted[_address], "Token not in the list.");
        isWhitelisted[_address] = false;
        emit ChangedWhitelisting(_address, false);
    }
}







/**
 * @title Decentralized Exchange (DEX) Contract
 * @author Validity Labs AG <[email protected]>
 * @dev Investors can make/cancel an order and take one or multiple orders.
 */
contract DEX is Pausable, TokenWhitelist {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Math for uint256;

    struct Order{
        address maker;   // account of the order maker.
        address specificTaker;  // address of a taker, if applies.
        bool isComplete;  // false: partial order; true: complete order;
        IERC20 sellToken;    // token that the order maker sells
        uint256 sellAmount;  // toal amount of token planned to be sold by the maker
        IERC20 buyToken;    //  token that the order maker buys
        uint256 buyAmount;  // total amount of token planned to be bought by the maker
    }

    Order[] public orderList;

    event MadeOrder(
        uint256 indexed id, 
        address indexed maker,
        address indexed specificTaker,
        bool isComplete, 
        IERC20 sellToken, 
        uint256 sellAmount, 
        IERC20 buyToken, 
        uint256 buyAmount
    );

    event TakenOrder(
        uint256 indexed id,
        address maker,
        address indexed taker,
        IERC20 purchasedToken,
        uint256 purchasedAmount, 
        IERC20 paidToken, 
        uint256 paidAmount   // computed amount of tokens paid by the taker
    );

    event CancelledOrder(
        uint256 indexed id,
        address killer
    );

    modifier checkBatchLength(uint256 length) {
        require(length > 1, "Fewer than two orders. Please use non-batch function instead.");
        require(length < 256, "Too many orders. Please place fewer orders per batch.");
        _;
    }
    
    /**
     * @dev Check against time-out block number
     */
    modifier checkTimeOut(uint256 timeOutBlockNumber) {
        require(block.number <= timeOutBlockNumber, "ERROR: TimeOut");
        _;
    }

    /**
    * @dev Take orders by their id. 
    * @notice Taking a partial order can be placed as the last item on the ids array.
    * @param ids Array of order ids to be taken. Besides the last item of the array, all the rest orders should be complet ones.
    * @param quantityOfPartialOrder If zero, the last item is a complet order. Otherwise, treat as the `quantity` input of a partial order.
    * @param timeOutBlockNumber Time-out block number.
    */
    function takeOrders(
        uint256[] calldata ids,
        uint256 quantityOfPartialOrder,
        uint256 timeOutBlockNumber
    ) 
        external
        whenNotPaused
        checkBatchLength(ids.length)
        checkTimeOut(timeOutBlockNumber)
    {
        if (quantityOfPartialOrder == 0) {
            // all complet orders
            for (uint256 i = 0; i < ids.length; i = i + 1) {
                takeOrder(ids[i], orderList[ids[i]].sellAmount, timeOutBlockNumber);
            }
        } else {
            // the last one is a partial order
            uint256 lastOrderIndex = ids.length - 1;
            takeOrder(ids[lastOrderIndex], quantityOfPartialOrder, timeOutBlockNumber);
            for (uint256 i = 0; i < lastOrderIndex; i = i + 1) {
                takeOrder(ids[i], orderList[ids[i]].sellAmount, timeOutBlockNumber);
            }
        }
    }

    /**
    * @dev Cancel orders by their id. 
    * @notice The order maker could cancel their orders when the DEX is not poaused. 
    * An operator (pauser) could do that at any time.
    * @param ids Array of order ids to be taken.
    */
    function cancelOrders(
        uint256[] calldata ids
    )
        external
        checkBatchLength(ids.length)
    {
        for (uint256 i = 0; i < ids.length; i = i + 1) {
            cancelOrder(ids[i]);
        }
    }

    /**
    * @dev Let investor make an order, providing the approval is done beforehand.
    * @param isComplete If this order can be filled partially (by default), or can only been taken as a whole.
    * @param sellToken Address of the token to be sold in this order.
    * @param sellAmount Total amount of token that is planned to be sold in this order.
    * @param buyToken Address of the token to be purchased in this order.
    * @param buyAmount Total amount of token planned to be bought by the maker
    * @param timeOutBlockNumber Time-out block number.
    */
    function makeOrder(
        bool isComplete,
        IERC20 sellToken, 
        uint256 sellAmount, 
        IERC20 buyToken, 
        uint256 buyAmount,
        uint256 timeOutBlockNumber
    ) 
        public
        whenNotPaused
        checkTimeOut(timeOutBlockNumber)
    {
        _makeOrder(address(0), isComplete, sellToken, sellAmount, buyToken, buyAmount);
    }

    /** OVERLOADED
    * @dev Let investor to make an order, providing the approval is done beforehand.
    * This function allows investor to make an order addressing a particular taker.
    * @notice It can only be called by the operator (pauser).
    * @param specificTaker Address of a taker, if applies.
    * @param isComplete If this order can be filled partially (by default), or can only been taken as a whole.
    * @param sellToken Address of the token to be sold in this order.
    * @param sellAmount Total amount of token that is planned to be sold in this order.
    * @param buyToken Address of the token to be purchased in this order.
    * @param buyAmount Total amount of token planned to be bought by the maker.
    * @param timeOutBlockNumber Time-out block number.
    */
    function makeOrder(
        address specificTaker,
        bool isComplete,
        IERC20 sellToken, 
        uint256 sellAmount, 
        IERC20 buyToken, 
        uint256 buyAmount,
        uint256 timeOutBlockNumber
    ) 
        public
        whenNotPaused
        onlyPauser
        checkTimeOut(timeOutBlockNumber)
    {
        _makeOrder(specificTaker, isComplete, sellToken, sellAmount, buyToken, buyAmount);
    }

    /**
    * @dev Take an order by its id. 
    * @param id Index of the to-be-taken order in orderList
    * @param quantity The amount of "sellToken" that the taker wants to purchase.
    * @param timeOutBlockNumber Time-out block number.
    */
    function takeOrder(
        uint256 id,
        uint256 quantity,
        uint256 timeOutBlockNumber
    ) 
        public
        whenNotPaused
        checkTimeOut(timeOutBlockNumber)
    {
        require(quantity > 0, "Insufficient balance for the purchase.");
        Order memory theOrder = orderList[id];
        require(theOrder.specificTaker == address(0) || theOrder.specificTaker == (msg.sender), "Ineligible taker");
        require(theOrder.sellAmount > 0, "This order has been filled or canceled.");
        uint256 spend = 0;
        uint256 receive = 0;
        if (quantity >= theOrder.sellAmount) {
            // take the entire order anyway
            spend = theOrder.buyAmount;
            receive = theOrder.sellAmount;
            delete(orderList[id]);
        } else {
            // check if partial order is possible or not.
            require(!theOrder.isComplete, "Cannot take a complete order partially");
            spend = quantity.mul(theOrder.buyAmount).div(theOrder.sellAmount);
            receive = quantity;
            orderList[id].sellAmount = theOrder.sellAmount.sub(receive);
            orderList[id].buyAmount = theOrder.buyAmount.sub(spend);
        }
        // taker transfers the "spend" amount of "buyToken" via DEX to the maker
        theOrder.buyToken.safeTransferFrom(msg.sender, theOrder.maker, spend);
        // DEX transfer maker's "quantity" amount of "sellToken" to the taker.
        theOrder.sellToken.safeTransferFrom(theOrder.maker, msg.sender, receive);
        emit TakenOrder(id, theOrder.maker, msg.sender, theOrder.sellToken, receive, theOrder.buyToken, spend);
    }

    /**
    * @dev Cancel an order by its maker or an operator (pauser).
    * @notice The order maker could cancel their orders when the DEX is not poaused. 
    * An operator (pauser) could do that at any time.
    * @param id Index of the to-be-cancelled order in orderList
    */
    function cancelOrder(
        uint256 id
    ) 
        public 
    {
        Order memory theOrder = orderList[id];
        require(isPauser(msg.sender) || (!paused() && theOrder.maker == msg.sender), "Not eligible to cancel this order or the DEX is paused");
        require(theOrder.sellAmount > 0, "This order has been taken or cancelled completely. It cannot be cancelled anymore.");
        delete(orderList[id]);
        // If no token was actually transferred to the DEX. There is no need to transfer token back.
        emit CancelledOrder(id, msg.sender);
    }

    /** 
     * @dev only the admin (primary) account could add an operator (pauser)
     * @param account the account to tbe added as an operator (pauser)
     */
    function addOperator(address account) public onlyPrimary {
        _addPauser(account);
    }

    /**
     * @dev only the admin (primary) account could remove an operator (pauser)
     * @param account the account to tbe removed from the operator (pauser) list
     */
    function removeOperator(address account) public onlyPrimary {
        _removePauser(account);
    }

    /** OVERRIDE
     * @dev only the admin (primary) account could add an operator (pauser)
     * @param account the account to tbe added as an operator (pauser)
     */
    function addPauser(address account) public {}

    /** OVERRIDE
     * @dev operation blocked. Only admin (primary) could remove an operator (pauser)
     * @notice this function is reverted in all cases.
     */
    function renouncePauser() public {}

    /**
    * @dev Internal contract to make an order
    * @notice Free order (buyAmount = 0 or sellAmount = 0) is banned here. 
    * @param specificTaker Address of a taker, if applies.
    * @param isComplete If this order can be filled partially, or can only been taken as a whole.
    * @param sellToken Address of the token to be sold in this order.
    * @param sellAmount Total amount of token that is planned to be sold in this order.
    * @param buyToken Address of the token to be purchased in this order.
    * @param buyAmount Total amount of token planned to be bought by the maker.
    */
    function _makeOrder(
        address specificTaker,
        bool isComplete,
        IERC20 sellToken, 
        uint256 sellAmount, 
        IERC20 buyToken, 
        uint256 buyAmount
    ) private {
        require(address(sellToken) != address(0) && address(buyToken) != address(0), "Invalid token address zero!");
        require(address(sellToken) != address(buyToken), "Cannot exchange to the same token!");
        require(specificTaker != msg.sender, "Cannot make an order for oneself.");
        require(sellAmount > 0, "Insufficient sellAmount!");
        require(buyAmount > 0, "Insufficient buyAmount!");
        Order memory newOrder = Order(msg.sender, specificTaker, isComplete, sellToken, sellAmount, buyToken, buyAmount);
        orderList.push(newOrder);
        // The maker has to approve the DEX beforehand with a suitable amount of allowance.
        emit MadeOrder(orderList.length-1, msg.sender, specificTaker, isComplete, sellToken, sellAmount, buyToken, buyAmount);
    }

}
