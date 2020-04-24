/**
 *Submitted for verification at Etherscan.io on 2019-07-29
*/

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol

pragma solidity ^0.5.0;


/**
 * @dev Optional functions from the ERC20 standard.
 */
contract ERC20Detailed is IERC20 {
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for `name`, `symbol`, and `decimals`. All three of
     * these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei.
     *
     * > Note that this information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * `IERC20.balanceOf` and `IERC20.transfer`.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }
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

// File: tabookey-gasless/contracts/IRelayRecipient.sol

pragma solidity ^0.5.5;

contract IRelayRecipient {

    /**
     * return the relayHub of this contract.
     */
    function getHubAddr() public view returns (address);

    /**
     * return the contract's balance on the RelayHub.
     * can be used to determine if the contract can pay for incoming calls,
     * before making any.
     */
    function getRecipientBalance() public view returns (uint);

    /*
     * Called by Relay (and RelayHub), to validate if this recipient accepts this call.
     * Note: Accepting this call means paying for the tx whether the relayed call reverted or not.
     *
     *  @return "0" if the the contract is willing to accept the charges from this sender, for this function call.
     *      any other value is a failure. actual value is for diagnostics only.
     *      ** Note: values below 10 are reserved by canRelay

     *  @param relay the relay that attempts to relay this function call.
     *          the contract may restrict some encoded functions to specific known relays.
     *  @param from the sender (signer) of this function call.
     *  @param encodedFunction the encoded function call (without any ethereum signature).
     *          the contract may check the method-id for valid methods
     *  @param gasPrice - the gas price for this transaction
     *  @param transactionFee - the relay compensation (in %) for this transaction
     *  @param signature - sender's signature over all parameters except approvalData
     *  @param approvalData - extra dapp-specific data (e.g. signature from trusted party)
     */
     function acceptRelayedCall(
        address relay,
        address from,
        bytes calldata encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes calldata approvalData,
        uint256 maxPossibleCharge
    )
    external
    view
    returns (uint256, bytes memory);

    /** this method is called before the actual relayed function call.
     * It may be used to charge the caller before (in conjuction with refunding him later in postRelayedCall for example).
     * the method is given all parameters of acceptRelayedCall and actual used gas.
     *
     *
     *** NOTICE: if this method modifies the contract's state, it must be protected with access control i.e. require msg.sender == getHubAddr()
     *
     *
     * Revert in this functions causes a revert of the client's relayed call but not in the entire transaction
     * (that is, the relay will still get compensated)
     */
    function preRelayedCall(bytes calldata context) external returns (bytes32);

    /** this method is called after the actual relayed function call.
     * It may be used to record the transaction (e.g. charge the caller by some contract logic) for this call.
     * the method is given all parameters of acceptRelayedCall, and also the success/failure status and actual used gas.
     *
     *
     *** NOTICE: if this method modifies the contract's state, it must be protected with access control i.e. require msg.sender == getHubAddr()
     *
     *
     * @param success - true if the relayed call succeeded, false if it reverted
     * @param actualCharge - estimation of how much the recipient will be charged. This information may be used to perform local booking and
     *   charge the sender for this call (e.g. in tokens).
     * @param preRetVal - preRelayedCall() return value passed back to the recipient
     *
     * Revert in this functions causes a revert of the client's relayed call but not in the entire transaction
     * (that is, the relay will still get compensated)
     */
    function postRelayedCall(bytes calldata context, bool success, uint actualCharge, bytes32 preRetVal) external;

}

// File: tabookey-gasless/contracts/IRelayHub.sol

pragma solidity ^0.5.5;

contract IRelayHub {
    // Relay management

    // Add stake to a relay and sets its unstakeDelay.
    // If the relay does not exist, it is created, and the caller
    // of this function becomes its owner. If the relay already exists, only the owner can call this function. A relay
    // cannot be its own owner.
    // All Ether in this function call will be added to the relay's stake.
    // Its unstake delay will be assigned to unstakeDelay, but the new value must be greater or equal to the current one.
    // Emits a Staked event.
    function stake(address relayaddr, uint256 unstakeDelay) external payable;

    // Emited when a relay's stake or unstakeDelay are increased
    event Staked(address indexed relay, uint256 stake, uint256 unstakeDelay);

    // Registers the caller as a relay.
    // The relay must be staked for, and not be a contract (i.e. this function must be called directly from an EOA).
    // Emits a RelayAdded event.
    // This function can be called multiple times, emitting new RelayAdded events. Note that the received transactionFee
    // is not enforced by relayCall.
    function registerRelay(uint256 transactionFee, string memory url) public;

    // Emitted when a relay is registered or re-registerd. Looking at these events (and filtering out RelayRemoved
    // events) lets a client discover the list of available relays.
    event RelayAdded(address indexed relay, address indexed owner, uint256 transactionFee, uint256 stake, uint256 unstakeDelay, string url);

    // Removes (deregisters) a relay. Unregistered (but staked for) relays can also be removed. Can only be called by
    // the owner of the relay. After the relay's unstakeDelay has elapsed, unstake will be callable.
    // Emits a RelayRemoved event.
    function removeRelayByOwner(address relay) public;

    // Emitted when a relay is removed (deregistered). unstakeTime is the time when unstake will be callable.
    event RelayRemoved(address indexed relay, uint256 unstakeTime);

    // Deletes the relay from the system, and gives back its stake to the owner. Can only be called by the relay owner,
    // after unstakeDelay has elapsed since removeRelayByOwner was called.
    // Emits an Unstaked event.
    function unstake(address relay) public;

    // Emitted when a relay is unstaked for, including the returned stake.
    event Unstaked(address indexed relay, uint256 stake);

    // States a relay can be in
    enum RelayState {
        Unknown, // The relay is unknown to the system: it has never been staked for
        Staked, // The relay has been staked for, but it is not yet active
        Registered, // The relay has registered itself, and is active (can relay calls)
        Removed    // The relay has been removed by its owner and can no longer relay calls. It must wait for its unstakeDelay to elapse before it can unstake
    }

    // Returns a relay's status. Note that relays can be deleted when unstaked or penalized.
    function getRelay(address relay) external view returns (uint256 totalStake, uint256 unstakeDelay, uint256 unstakeTime, address payable owner, RelayState state);

    // Balance management

    // Deposits ether for a contract, so that it can receive (and pay for) relayed transactions. Unused balance can only
    // be withdrawn by the contract itself, by callingn withdraw.
    // Emits a Deposited event.
    function depositFor(address target) public payable;

    // Emitted when depositFor is called, including the amount and account that was funded.
    event Deposited(address indexed recipient, address indexed from, uint256 amount);

    // Returns an account's deposits. These can be either a contnract's funds, or a relay owner's revenue.
    function balanceOf(address target) external view returns (uint256);

    // Withdraws from an account's balance, sending it back to it. Relay owners call this to retrieve their revenue, and
    // contracts can also use it to reduce their funding.
    // Emits a Withdrawn event.
    function withdraw(uint256 amount) public;

    // Emitted when an account withdraws funds from RelayHub.
    event Withdrawn(address indexed dest, uint256 amount);

    // Relaying

    // Check if the RelayHub will accept a relayed operation. Multiple things must be true for this to happen:
    //  - all arguments must be signed for by the sender (from)
    //  - the sender's nonce must be the current one
    //  - the recipient must accept this transaction (via acceptRelayedCall)
    // Returns a PreconditionCheck value (OK when the transaction can be relayed), or a recipient-specific error code if
    // it returns one in acceptRelayedCall.
    function canRelay(
        address relay,
        address from,
        address to,
        bytes memory encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes memory signature,
        bytes memory approvalData
    ) public view returns (uint256 status, bytes memory recipientContext);

    // Preconditions for relaying, checked by canRelay and returned as the corresponding numeric values.
    enum PreconditionCheck {
        OK,                         // All checks passed, the call can be relayed
        WrongSignature,             // The transaction to relay is not signed by requested sender
        WrongNonce,                 // The provided nonce has already been used by the sender
        AcceptRelayedCallReverted,  // The recipient rejected this call via acceptRelayedCall
        InvalidRecipientStatusCode  // The recipient returned an invalid (reserved) status code
    }

    // Relays a transaction. For this to suceed, multiple conditions must be met:
    //  - canRelay must return PreconditionCheck.OK
    //  - the sender must be a registered relay
    //  - the transaction's gas price must be larger or equal to the one that was requested by the sender
    //  - the transaction must have enough gas to not run out of gas if all internal transactions (calls to the
    // recipient) use all gas available to them
    //  - the recipient must have enough balance to pay the relay for the worst-case scenario (i.e. when all gas is
    // spent)
    //
    // If all conditions are met, the call will be relayed and the recipient charged. preRelayedCall, the encoded
    // function and postRelayedCall will be called in order.
    //
    // Arguments:
    //  - from: the client originating the request
    //  - recipient: the target IRelayRecipient contract
    //  - encodedFunction: the function call to relay, including data
    //  - transactionFee: fee (%) the relay takes over actual gas cost
    //  - gasPrice: gas price the client is willing to pay
    //  - gasLimit: gas to forward when calling the encoded function
    //  - nonce: client's nonce
    //  - signature: client's signature over all previous params, plus the relay and RelayHub addresses
    //  - approvalData: dapp-specific data forwared to acceptRelayedCall. This value is *not* verified by the Hub, but
    //    it still can be used for e.g. a signature.
    //
    // Emits a TransactionRelayed event.
    function relayCall(
        address from,
        address to,
        bytes memory encodedFunction,
        uint256 transactionFee,
        uint256 gasPrice,
        uint256 gasLimit,
        uint256 nonce,
        bytes memory signature,
        bytes memory approvalData
    ) public;

    // Emitted when an attempt to relay a call failed. This can happen due to incorrect relayCall arguments, or the
    // recipient not accepting the relayed call. The actual relayed call was not executed, and the recipient not charged.
    // The reason field contains an error code: values 1-10 correspond to PreconditionCheck entries, and values over 10
    // are custom recipient error codes returned from acceptRelayedCall.
    event CanRelayFailed(address indexed relay, address indexed from, address indexed to, bytes4 selector, uint256 reason);

    // Emitted when a transaction is relayed. Note that the actual encoded function might be reverted: this will be
    // indicated in the status field.
    // Useful when monitoring a relay's operation and relayed calls to a contract.
    // Charge is the ether value deducted from the recipient's balance, paid to the relay's owner.
    event TransactionRelayed(address indexed relay, address indexed from, address indexed to, bytes4 selector, RelayCallStatus status, uint256 charge);

    // Reason error codes for the TransactionRelayed event
    enum RelayCallStatus {
        OK,                      // The transaction was successfully relayed and execution successful - never included in the event
        RelayedCallFailed,       // The transaction was relayed, but the relayed call failed
        PreRelayedFailed,        // The transaction was not relayed due to preRelatedCall reverting
        PostRelayedFailed,       // The transaction was relayed and reverted due to postRelatedCall reverting
        RecipientBalanceChanged  // The transaction was relayed and reverted due to the recipient's balance changing
    }

    // Returns how much gas should be forwarded to a call to relayCall, in order to relay a transaction that will spend
    // up to relayedCallStipend gas.
    function requiredGas(uint256 relayedCallStipend) public view returns (uint256);

    // Returns the maximum recipient charge, given the amount of gas forwarded, gas price and relay fee.
    function maxPossibleCharge(uint256 relayedCallStipend, uint256 gasPrice, uint256 transactionFee) public view returns (uint256);

    // Relay penalization. Any account can penalize relays, removing them from the system immediately, and rewarding the
    // reporter with half of the relay's stake. The other half is burned so that, even if the relay penalizes itself, it
    // still loses half of its stake.

    // Penalize a relay that signed two transactions using the same nonce (making only the first one valid) and
    // different data (gas price, gas limit, etc. may be different). The (unsigned) transaction data and signature for
    // both transactions must be provided.
    function penalizeRepeatedNonce(bytes memory unsignedTx1, bytes memory signature1, bytes memory unsignedTx2, bytes memory signature2) public;

    // Penalize a relay that sent a transaction that didn't target RelayHub's registerRelay or relayCall.
    function penalizeIllegalTransaction(bytes memory unsignedTx, bytes memory signature) public;

    event Penalized(address indexed relay, address sender, uint256 amount);

    function getNonce(address from) view external returns (uint256);
}

// File: @0x/contracts-utils/contracts/src/LibBytes.sol

/*

  Copyright 2018 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity ^0.5.5;


library LibBytes {

    using LibBytes for bytes;

    /// @dev Gets the memory address for a byte array.
    /// @param input Byte array to lookup.
    /// @return memoryAddress Memory address of byte array. This
    ///         points to the header of the byte array which contains
    ///         the length.
    function rawAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := input
        }
        return memoryAddress;
    }
    
    /// @dev Gets the memory address for the contents of a byte array.
    /// @param input Byte array to lookup.
    /// @return memoryAddress Memory address of the contents of the byte array.
    function contentAddress(bytes memory input)
        internal
        pure
        returns (uint256 memoryAddress)
    {
        assembly {
            memoryAddress := add(input, 32)
        }
        return memoryAddress;
    }

    /// @dev Copies `length` bytes from memory location `source` to `dest`.
    /// @param dest memory address to copy bytes to.
    /// @param source memory address to copy bytes from.
    /// @param length number of bytes to copy.
    function memCopy(
        uint256 dest,
        uint256 source,
        uint256 length
    )
        internal
        pure
    {
        if (length < 32) {
            // Handle a partial word by reading destination and masking
            // off the bits we are interested in.
            // This correctly handles overlap, zero lengths and source == dest
            assembly {
                let mask := sub(exp(256, sub(32, length)), 1)
                let s := and(mload(source), not(mask))
                let d := and(mload(dest), mask)
                mstore(dest, or(s, d))
            }
        } else {
            // Skip the O(length) loop when source == dest.
            if (source == dest) {
                return;
            }

            // For large copies we copy whole words at a time. The final
            // word is aligned to the end of the range (instead of after the
            // previous) to handle partial words. So a copy will look like this:
            //
            //  ####
            //      ####
            //          ####
            //            ####
            //
            // We handle overlap in the source and destination range by
            // changing the copying direction. This prevents us from
            // overwriting parts of source that we still need to copy.
            //
            // This correctly handles source == dest
            //
            if (source > dest) {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because it
                    // is easier to compare with in the loop, and these
                    // are also the addresses we need for copying the
                    // last bytes.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the last 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the last bytes in
                    // source already due to overlap.
                    let last := mload(sEnd)

                    // Copy whole words front to back
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    // solhint-disable-next-line no-empty-blocks
                    for {} lt(source, sEnd) {} {
                        mstore(dest, mload(source))
                        source := add(source, 32)
                        dest := add(dest, 32)
                    }
                    
                    // Write the last 32 bytes
                    mstore(dEnd, last)
                }
            } else {
                assembly {
                    // We subtract 32 from `sEnd` and `dEnd` because those
                    // are the starting points when copying a word at the end.
                    length := sub(length, 32)
                    let sEnd := add(source, length)
                    let dEnd := add(dest, length)

                    // Remember the first 32 bytes of source
                    // This needs to be done here and not after the loop
                    // because we may have overwritten the first bytes in
                    // source already due to overlap.
                    let first := mload(source)

                    // Copy whole words back to front
                    // We use a signed comparisson here to allow dEnd to become
                    // negative (happens when source and dest < 32). Valid
                    // addresses in local memory will never be larger than
                    // 2**255, so they can be safely re-interpreted as signed.
                    // Note: the first check is always true,
                    // this could have been a do-while loop.
                    // solhint-disable-next-line no-empty-blocks
                    for {} slt(dest, dEnd) {} {
                        mstore(dEnd, mload(sEnd))
                        sEnd := sub(sEnd, 32)
                        dEnd := sub(dEnd, 32)
                    }
                    
                    // Write the first 32 bytes
                    mstore(dest, first)
                }
            }
        }
    }

    /// @dev Returns a slices from a byte array.
    /// @param b The byte array to take a slice from.
    /// @param from The starting index for the slice (inclusive).
    /// @param to The final index for the slice (exclusive).
    /// @return result The slice containing bytes at indices [from, to)
    function slice(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        require(
            from <= to,
            "FROM_LESS_THAN_TO_REQUIRED"
        );
        require(
            to <= b.length,
            "TO_LESS_THAN_LENGTH_REQUIRED"
        );
        
        // Create a new bytes structure and copy contents
        result = new bytes(to - from);
        memCopy(
            result.contentAddress(),
            b.contentAddress() + from,
            result.length
        );
        return result;
    }
    
    /// @dev Returns a slice from a byte array without preserving the input.
    /// @param b The byte array to take a slice from. Will be destroyed in the process.
    /// @param from The starting index for the slice (inclusive).
    /// @param to The final index for the slice (exclusive).
    /// @return result The slice containing bytes at indices [from, to)
    /// @dev When `from == 0`, the original array will match the slice. In other cases its state will be corrupted.
    function sliceDestructive(
        bytes memory b,
        uint256 from,
        uint256 to
    )
        internal
        pure
        returns (bytes memory result)
    {
        require(
            from <= to,
            "FROM_LESS_THAN_TO_REQUIRED"
        );
        require(
            to <= b.length,
            "TO_LESS_THAN_LENGTH_REQUIRED"
        );
        
        // Create a new bytes structure around [from, to) in-place.
        assembly {
            result := add(b, from)
            mstore(result, sub(to, from))
        }
        return result;
    }

    /// @dev Pops the last byte off of a byte array by modifying its length.
    /// @param b Byte array that will be modified.
    /// @return The byte that was popped off.
    function popLastByte(bytes memory b)
        internal
        pure
        returns (bytes1 result)
    {
        require(
            b.length > 0,
            "GREATER_THAN_ZERO_LENGTH_REQUIRED"
        );

        // Store last byte.
        result = b[b.length - 1];

        assembly {
            // Decrement length of byte array.
            let newLen := sub(mload(b), 1)
            mstore(b, newLen)
        }
        return result;
    }

    /// @dev Pops the last 20 bytes off of a byte array by modifying its length.
    /// @param b Byte array that will be modified.
    /// @return The 20 byte address that was popped off.
    function popLast20Bytes(bytes memory b)
        internal
        pure
        returns (address result)
    {
        require(
            b.length >= 20,
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

        // Store last 20 bytes.
        result = readAddress(b, b.length - 20);

        assembly {
            // Subtract 20 from byte array length.
            let newLen := sub(mload(b), 20)
            mstore(b, newLen)
        }
        return result;
    }

    /// @dev Tests equality of two byte arrays.
    /// @param lhs First byte array to compare.
    /// @param rhs Second byte array to compare.
    /// @return True if arrays are the same. False otherwise.
    function equals(
        bytes memory lhs,
        bytes memory rhs
    )
        internal
        pure
        returns (bool equal)
    {
        // Keccak gas cost is 30 + numWords * 6. This is a cheap way to compare.
        // We early exit on unequal lengths, but keccak would also correctly
        // handle this.
        return lhs.length == rhs.length && keccak256(lhs) == keccak256(rhs);
    }

    /// @dev Reads an address from a position in a byte array.
    /// @param b Byte array containing an address.
    /// @param index Index in byte array of address.
    /// @return address from byte array.
    function readAddress(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (address result)
    {
        require(
            b.length >= index + 20,  // 20 is length of address
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Read address from array memory
        assembly {
            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 20-byte mask to obtain address
            result := and(mload(add(b, index)), 0xffffffffffffffffffffffffffffffffffffffff)
        }
        return result;
    }

    /// @dev Writes an address into a specific position in a byte array.
    /// @param b Byte array to insert address into.
    /// @param index Index in byte array of address.
    /// @param input Address to put into byte array.
    function writeAddress(
        bytes memory b,
        uint256 index,
        address input
    )
        internal
        pure
    {
        require(
            b.length >= index + 20,  // 20 is length of address
            "GREATER_OR_EQUAL_TO_20_LENGTH_REQUIRED"
        );

        // Add offset to index:
        // 1. Arrays are prefixed by 32-byte length parameter (add 32 to index)
        // 2. Account for size difference between address length and 32-byte storage word (subtract 12 from index)
        index += 20;

        // Store address into array memory
        assembly {
            // The address occupies 20 bytes and mstore stores 32 bytes.
            // First fetch the 32-byte word where we'll be storing the address, then
            // apply a mask so we have only the bytes in the word that the address will not occupy.
            // Then combine these bytes with the address and store the 32 bytes back to memory with mstore.

            // 1. Add index to address of bytes array
            // 2. Load 32-byte word from memory
            // 3. Apply 12-byte mask to obtain extra bytes occupying word of memory where we'll store the address
            let neighbors := and(
                mload(add(b, index)),
                0xffffffffffffffffffffffff0000000000000000000000000000000000000000
            )
            
            // Make sure input address is clean.
            // (Solidity does not guarantee this)
            input := and(input, 0xffffffffffffffffffffffffffffffffffffffff)

            // Store the neighbors and address into memory
            mstore(add(b, index), xor(input, neighbors))
        }
    }

    /// @dev Reads a bytes32 value from a position in a byte array.
    /// @param b Byte array containing a bytes32 value.
    /// @param index Index in byte array of bytes32 value.
    /// @return bytes32 value from byte array.
    function readBytes32(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes32 result)
    {
        require(
            b.length >= index + 32,
            "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
        );

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            result := mload(add(b, index))
        }
        return result;
    }

    /// @dev Writes a bytes32 into a specific position in a byte array.
    /// @param b Byte array to insert <input> into.
    /// @param index Index in byte array of <input>.
    /// @param input bytes32 to put into byte array.
    function writeBytes32(
        bytes memory b,
        uint256 index,
        bytes32 input
    )
        internal
        pure
    {
        require(
            b.length >= index + 32,
            "GREATER_OR_EQUAL_TO_32_LENGTH_REQUIRED"
        );

        // Arrays are prefixed by a 256 bit length parameter
        index += 32;

        // Read the bytes32 from array memory
        assembly {
            mstore(add(b, index), input)
        }
    }

    /// @dev Reads a uint256 value from a position in a byte array.
    /// @param b Byte array containing a uint256 value.
    /// @param index Index in byte array of uint256 value.
    /// @return uint256 value from byte array.
    function readUint256(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (uint256 result)
    {
        result = uint256(readBytes32(b, index));
        return result;
    }

    /// @dev Writes a uint256 into a specific position in a byte array.
    /// @param b Byte array to insert <input> into.
    /// @param index Index in byte array of <input>.
    /// @param input uint256 to put into byte array.
    function writeUint256(
        bytes memory b,
        uint256 index,
        uint256 input
    )
        internal
        pure
    {
        writeBytes32(b, index, bytes32(input));
    }

    /// @dev Reads an unpadded bytes4 value from a position in a byte array.
    /// @param b Byte array containing a bytes4 value.
    /// @param index Index in byte array of bytes4 value.
    /// @return bytes4 value from byte array.
    function readBytes4(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes4 result)
    {
        require(
            b.length >= index + 4,
            "GREATER_OR_EQUAL_TO_4_LENGTH_REQUIRED"
        );

        // Arrays are prefixed by a 32 byte length field
        index += 32;

        // Read the bytes4 from array memory
        assembly {
            result := mload(add(b, index))
            // Solidity does not require us to clean the trailing bytes.
            // We do it anyway
            result := and(result, 0xFFFFFFFF00000000000000000000000000000000000000000000000000000000)
        }
        return result;
    }

    /// @dev Reads nested bytes from a specific position.
    /// @dev NOTE: the returned value overlaps with the input value.
    ///            Both should be treated as immutable.
    /// @param b Byte array containing nested bytes.
    /// @param index Index of nested bytes.
    /// @return result Nested bytes.
    function readBytesWithLength(
        bytes memory b,
        uint256 index
    )
        internal
        pure
        returns (bytes memory result)
    {
        // Read length of nested bytes
        uint256 nestedBytesLength = readUint256(b, index);
        index += 32;

        // Assert length of <b> is valid, given
        // length of nested bytes
        require(
            b.length >= index + nestedBytesLength,
            "GREATER_OR_EQUAL_TO_NESTED_BYTES_LENGTH_REQUIRED"
        );
        
        // Return a pointer to the byte array as it exists inside `b`
        assembly {
            result := add(b, index)
        }
        return result;
    }

    /// @dev Inserts bytes at a specific position in a byte array.
    /// @param b Byte array to insert <input> into.
    /// @param index Index in byte array of <input>.
    /// @param input bytes to insert.
    function writeBytesWithLength(
        bytes memory b,
        uint256 index,
        bytes memory input
    )
        internal
        pure
    {
        // Assert length of <b> is valid, given
        // length of input
        require(
            b.length >= index + 32 + input.length,  // 32 bytes to store length
            "GREATER_OR_EQUAL_TO_NESTED_BYTES_LENGTH_REQUIRED"
        );

        // Copy <input> into <b>
        memCopy(
            b.contentAddress() + index,
            input.rawAddress(), // includes length of <input>
            input.length + 32   // +32 bytes to store <input> length
        );
    }

    /// @dev Performs a deep copy of a byte array onto another byte array of greater than or equal length.
    /// @param dest Byte array that will be overwritten with source bytes.
    /// @param source Byte array to copy onto dest bytes.
    function deepCopyBytes(
        bytes memory dest,
        bytes memory source
    )
        internal
        pure
    {
        uint256 sourceLen = source.length;
        // Dest length must be >= source length, or some bytes would not be copied.
        require(
            dest.length >= sourceLen,
            "GREATER_OR_EQUAL_TO_SOURCE_BYTES_LENGTH_REQUIRED"
        );
        memCopy(
            dest.contentAddress(),
            source.contentAddress(),
            sourceLen
        );
    }
}

// File: tabookey-gasless/contracts/RelayRecipient.sol

pragma solidity ^0.5.5;

// Contract that implements the relay recipient protocol.  Inherited by Gatekeeper, or any other relay recipient.
//
// The recipient contract is responsible to:
// * pass a trusted IRelayHub singleton to the constructor.
// * Implement acceptRelayedCall, which acts as a whitelist/blacklist of senders.  It is advised that the recipient's owner will be able to update that list to remove abusers.
// * In every function that cares about the sender, use "address sender = getSender()" instead of msg.sender.  It'll return msg.sender for non-relayed transactions, or the real sender in case of relayed transactions.




contract RelayRecipient is IRelayRecipient {

    IRelayHub private relayHub; // The IRelayHub singleton which is allowed to call us

    function getHubAddr() public view returns (address) {
        return address(relayHub);
    }

    /**
     * Initialize the RelayHub of this contract.
     * Must be called at least once (e.g. from the constructor), so that the contract can accept relayed calls.
     * For ownable contracts, there should be a method to update the RelayHub, in case a new hub is deployed (since
     * the RelayHub itself is not upgradeable)
     * Otherwise, the contract might be locked on a dead hub, with no relays.
     */
    function setRelayHub(IRelayHub _rhub) internal {
        relayHub = _rhub;

        //attempt a read method, just to validate the relay is a valid RelayHub contract.
        getRecipientBalance();
    }

    function getRelayHub() internal view returns (IRelayHub) {
        return relayHub;
    }

    /**
     * return the balance of this contract.
     * Note that this method will revert on configuration error (invalid relay address)
     */
    function getRecipientBalance() public view returns (uint) {
        return getRelayHub().balanceOf(address(this));
    }

    function getSenderFromData(address origSender, bytes memory msgData) public view returns (address) {
        address sender = origSender;
        if (origSender == getHubAddr()) {
            // At this point we know that the sender is a trusted IRelayHub, so we trust that the last bytes of msg.data are the verified sender address.
            // extract sender address from the end of msg.data
            sender = LibBytes.readAddress(msgData, msgData.length - 20);
        }
        return sender;
    }

    /**
     * return the sender of this call.
     * if the call came through the valid RelayHub, return the original sender.
     * otherwise, return `msg.sender`
     * should be used in the contract anywhere instead of msg.sender
     */
    function getSender() public view returns (address) {
        return getSenderFromData(msg.sender, msg.data);
    }

    function getMessageData() public view returns (bytes memory) {
        bytes memory origMsgData = msg.data;
        if (msg.sender == getHubAddr()) {
            // At this point we know that the sender is a trusted IRelayHub, so we trust that the last bytes of msg.data are the verified sender address.
            // extract original message data from the start of msg.data
            origMsgData = new bytes(msg.data.length - 20);
            for (uint256 i = 0; i < origMsgData.length; i++)
            {
                origMsgData[i] = msg.data[i];
            }
        }
        return origMsgData;
    }
}

// File: tabookey-gasless/contracts/GsnUtils.sol

pragma solidity ^0.5.5;


library GsnUtils {

    /**
     * extract method sig from encoded function call
     */
    function getMethodSig(bytes memory msgData) internal pure returns (bytes4) {
        return bytes4(bytes32(LibBytes.readUint256(msgData, 0)));
    }

    /**
     * extract parameter from encoded-function block.
     * see: https://solidity.readthedocs.io/en/develop/abi-spec.html#formal-specification-of-the-encoding
     * note that the type of the parameter must be static.
     * the return value should be casted to the right type.
     */
    function getParam(bytes memory msgData, uint index) internal pure returns (uint) {
        return LibBytes.readUint256(msgData, 4 + index * 32);
    }

    /**
     * extract dynamic-sized (string/bytes) parameter.
     * we assume that there ARE dynamic parameters, hence getParam(0) is the offset to the first
     * dynamic param
     * https://solidity.readthedocs.io/en/develop/abi-spec.html#use-of-dynamic-types
     */
    function getBytesParam(bytes memory msgData, uint index) internal pure returns (bytes memory ret)  {
        uint ofs = getParam(msgData,index)+4;
        uint len = LibBytes.readUint256(msgData, ofs);
        ret = LibBytes.slice(msgData, ofs+32, ofs+32+len);
    }

    function getStringParam(bytes memory msgData, uint index) internal pure returns (string memory) {
        return string(getBytesParam(msgData,index));
    }

    function checkSig(address signer, bytes32 hash, bytes memory sig) pure internal returns (bool) {
        // Check if @v,@r,@s are a valid signature of @signer for @hash
        uint8 v = uint8(sig[0]);
        bytes32 r = LibBytes.readBytes32(sig,1);
        bytes32 s = LibBytes.readBytes32(sig,33);
        return signer == ecrecover(hash, v, r, s);
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

// File: contracts/erc725/contracts/ERC725.sol

pragma solidity ^0.5.4;

interface ERC725 {
    event DataChanged(bytes32 indexed key, bytes32 value);
    event OwnerChanged(address indexed ownerAddress);
    event ContractCreated(address indexed contractAddress);

    function changeOwner(address _owner) external;
    function getData(bytes32 _key) external view returns (bytes32 _value);
    function setData(bytes32 _key, bytes32 _value) external;
    function execute(uint256 _operationType, address _to, uint256 _value, bytes calldata _data) external;
}

// File: contracts/erc725/contracts/Assert.sol

pragma solidity 0.5.10;

contract AssertTester {
    constructor() public {
        Assert.equal(msg.sender, address(this), "asdsd");
    }
}

library Assert {

    function equal(address actual, address expected, string memory text) internal pure {
        if (expected == actual) return;
        bytes memory t = abi.encodePacked(text, ": \n",
            "expected: ", toString(expected), "\n",
            "  actual: ", toString(actual), "\n"
        );
        revert( string(t));
    }

    function equal(uint actual, uint expected, string memory text) internal pure {
        if (expected == actual) return;
        bytes memory t = abi.encodePacked(text, ": \n",
            "expected: ", toString(expected), "\n",
            "  actual: ", toString(actual), "\n"
        );
        revert( string(t));
    }

    function equal(bytes32 actual, bytes32 expected, string memory text) internal pure {
        if (expected == actual) return;
        bytes memory t = abi.encodePacked(text, ": \n",
            "expected: ", toString(expected), "\n",
            "  actual: ", toString(actual), "\n"
        );
        revert( string(t));
    }

    function concat( string memory str, address a) internal pure returns (string memory) {
        bytes memory b =abi.encodePacked(str, toString(a));
        return string(b);
    }

    function concat( string memory str, uint a) internal pure returns (string memory) {
        bytes memory b =abi.encodePacked(str, toString(a));
        return string(b);
    }

    function toString(address _addr) pure internal returns (string memory) {
        bytes32 value = bytes32(uint256(_addr));
        return toString(value, 20);
    }

    function toString(bytes32 b) pure internal returns (string memory) {
        return toString(b, 32);
    }

    function toString(bytes32 value, uint nbytes) pure internal returns(string memory) {
        bytes memory alphabet = "0123456789abcdef";

        bytes memory str = new bytes(nbytes*2+2);
        str[0] = '0';
        str[1] = 'x';
        for (uint i = 0; i < nbytes; i++) {
            str[2+i*2] = alphabet[uint(uint8(value[i + 12] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(value[i + 12] & 0x0f))];
        }
        return string(str);
    }

    function toString(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
}

// File: contracts/erc725/contracts/Identity.sol

pragma solidity ^0.5.4;


contract ProxyAccount is ERC725 {
    
    uint256 constant OPERATION_CALL = 0;
    uint256 constant OPERATION_CREATE = 1;
    // bytes32 constant KEY_OWNER = 0x0000000000000000000000000000000000000000000000000000000000000000;

    mapping(bytes32 => bytes32) store;
    
    address public owner;
    
    constructor(address _owner) public {
        owner = _owner;
    }


    event sender1(address addr);

    modifier onlyOwner(string memory message) {
        require(msg.sender == owner, "only-owner-allowed");
        _;
    }
    
    // function toAddress(bytes32 a) internal pure returns (address b){
    //   assembly {
    //         mstore(0, a)
    //         b := mload(0)
    //     }
    //   return b;
    // }
    
    // function toBytes32(address a) internal pure returns (bytes32 b){
    //   assembly {
    //         mstore(0, a)
    //         b := mload(0)
    //     }
    //   return b;
    // }
    
    // ----------------
    // Public functions
    
    function () external payable {}
    
    function changeOwner(address _owner)
        external
        onlyOwner(Assert.concat("chown newowner=", _owner))
    {
        owner = _owner;
        emit OwnerChanged(owner);
    }

    function getData(bytes32 _key)
        external
        view
        returns (bytes32 _value)
    {
        return store[_key];
    }

    function setData(bytes32 _key, bytes32 _value)
        public
        onlyOwner("setdata")
    {
        store[_key] = _value;
        emit DataChanged(_key, _value);
    }

    function execute(uint256 _operationType, address _to, uint256 _value, bytes calldata _data)
        external
        onlyOwner("exec")
    {
        if (_operationType == OPERATION_CALL) {
            require( executeCall(_to, _value, _data) );
        } else if (_operationType == OPERATION_CREATE) {
            address newContract = executeCreate(_data);
            emit ContractCreated(newContract);
        } else {
            // We don't want to spend users gas if parametar is wrong
            revert("failed");
        }
    }

    // copied from GnosisSafe
    // https://github.com/gnosis/safe-contracts/blob/v0.0.2-alpha/contracts/base/Executor.sol
    function executeCall(address to, uint256 value, bytes memory data)
        internal
        returns (bool success)
    {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := call(gas, to, value, add(data, 0x20), mload(data), 0, 0)
        }
    }

    // copied from GnosisSafe
    // https://github.com/gnosis/safe-contracts/blob/v0.0.2-alpha/contracts/base/Executor.sol
    function executeCreate(bytes memory data)
        internal
        returns (address newContract)
    {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            newContract := create(0, add(data, 0x20), mload(data))
        }
    }
}

// File: contracts/Identity.sol

pragma solidity 0.5.10;


/**
 * this is the identity contract that is used by our Sponsor.
 * it is tied to a specific sponsor (which created it).
 * at trusts the sponsor to call it only after it verified the real
 * owner using isOwner()
 */
contract Identity is ProxyAccount {

    address public sponsor;
    constructor(address _owner, address _sponsor) public ProxyAccount(_owner) {
        sponsor = _sponsor;
    }

    //called by the Sponsor, to validate the owner of the identity.
    function isOwner(address _owner) public view returns (bool) {
        return owner == _owner;
    }

    //replace the onlyOwner modifier, to trust calls from our sponsor.
    modifier onlyOwner(string memory message) {

        require ( msg.sender == sponsor || msg.sender == owner );
        _;
    }
}

// File: contracts/Sponsor.sol

pragma solidity 0.5.10;





/**
 * Sponsor exposed API.
 * Note that these methods are supposed to be call via a relay
 */
contract ISponsor {
    event IdentityCreated(address newIdentity);

    /**
     * create new identity. emits "IdentityCreated" with the newly created identity
     */
    function createIdentity(uint salt) external;

    /**
     * relay the given call.
     */
    function relayToTarget(Identity sender, address target, bytes memory func) public;
}

/**
 * general-purpose base-class for a sponsor.
 * supports 3 modes of assertions:
 * - require explicit identities to be whitelisted
 * - require identity code to be whitelisted
 * - require targets to be whitelisted.
 * each option can be enabled separately.
 * Note that the createIdentity() method white-list the generated identity (if that
 *  require mode is enabled)
 */
contract Sponsor is ISponsor, RelayRecipient, Ownable {

    bool requirewhiteListedIdentities;
    bool requireWhiteListedTargets;
    bool requireWhiteListedIdentityCode;

    bool whitelistedOurIdentity;

    mapping(address => bool) whiteListedIdentities;
    mapping(address => bool) whiteListedTargets;

    constructor() public {
    }

    function set_relay_hub(IRelayHub hub) onlyOwner public {
        super.setRelayHub(hub);
    }

    //deposit to the relay hub on behalf of this sponsor contract
    function relayHubDeposit() public payable {
        getRelayHub().depositFor.value(msg.value)(address(this));
    }
    //check deposit on relay hub.
    function getDeposit() view public returns (uint)  {
        return getRelayHub().balanceOf(address(this));
    }

    //withdraw the relayHub deposit into the destination address.
    function withdrawDepositTo(uint amount, address payable target) onlyOwner public {
        getRelayHub().withdraw(amount);
        target.transfer(amount);
    }

    //trusted identity code.
    // since we trust the call() method of the identity, we must whitelist valid code (unless we explicitly)
    // have to whitelist each address.
    mapping(bytes32 => bool) whiteListedIdentityCode;

    //add (or remove) whitelisted identity. enable whitelist.
    //NOTE: whitelist is enabled on first add.
    function addIdentity(Identity id, bool on) onlyOwner public {
        whiteListedIdentities[address(id)] = on;
        if (on)
            requirewhiteListedIdentities = true;
    }

    function addIdentityCode(address identity, bool on) onlyOwner public {
        whiteListedIdentityCode[getExtCodeHash(identity)] = on;
    }

    function addTarget(address target, bool on) onlyOwner public {
        whiteListedTargets[target] = on;
    }

    enum ResultCode {
        MethodNotAllowed, //we only allow calls to relay and createIdentity.
        IdentityAddressNotWhitelisted, //required per-identity whitelisting, but it isn't.
        IdentityCodeNotWhitelisted, //required identity CODE whitelisting, but it isn't.
        TargetAddressNotWhitelisted, //required target address whitelisting, but it isn't.
        SenderNotIdentityOwner      //only identity owner can make call through the identity.
    }

    /**
     * This is the only method we accept relay request to.
     * This method is not called directly by the client, since it calls the standard relay()
     * @param sender the sender identity to use. must accept caller (getSender()) as owner.
     * @param target the target
     */
    function relayToTarget(Identity sender, address target, bytes memory func) public {

        sender.execute(0 /*OPERATION_CALL*/, target, 0, func);
    }


    //actual salt is used in TokenSponsor (yah, need to re-design this class hierarchy)
    function createIdentityInternal(address newOwner, uint /*salt*/) internal returns (Identity){
        Identity ret = new Identity(newOwner, address(this));
        return ret;
    }

    function createIdentity(uint salt) external {

        Identity ret = createIdentityInternal(getSender(), salt);

        if (requirewhiteListedIdentities)
            whiteListedIdentities[address(ret)] = true;

        //if code whitelisting is enabled, then make sure our Identity code contract is whitelisted.
        if (requireWhiteListedIdentityCode && !whitelistedOurIdentity) {
            whiteListedIdentityCode[getExtCodeHash(address(ret))] = true;
            whitelistedOurIdentity = true;
        }
        emit IdentityCreated(address(ret));
    }

    function acceptRelayedCall(
        address ,//relay,
        address from,
        bytes calldata encodedFunction,
        uint256 ,//transactionFee,
        uint256 ,//gasPrice,
        uint256 ,//gasLimit,
        uint256 ,//nonce,
        bytes calldata ,//approvalData,
        uint256 //maxPossibleCharge
        ) external view returns (uint256, bytes memory) {

        if (uint(address(this)) != 0) return (0,"ok");

        //        bytes4 sig = GsnUtils.getMethodSig(encodedFunction);
        bytes4 sig = LibBytes.readBytes4(encodedFunction,0);
        if (sig == this.createIdentity.selector) {
            //we currently allow anyone to createIdentity()
            return (0,"");
        }

        if (sig == this.relayToTarget.selector) {

            //extract params of relayToTarget
            Identity identity = Identity(address(GsnUtils.getParam(encodedFunction, 0)));
//            address target = address(GsnUtils.getParam(encodedFunction, 1));

//            if (requirewhiteListedIdentities && !whiteListedIdentities[address(identity)])
//                return (100 + uint32(ResultCode.IdentityAddressNotWhitelisted), "");
//
//            if (requireWhiteListedIdentityCode && !whiteListedIdentityCode[getExtCodeHash(address(identity))])
//                return (100 + uint32(ResultCode.IdentityCodeNotWhitelisted), "");

            if (!identity.isOwner(from) )
                return (100+uint32(ResultCode.SenderNotIdentityOwner), "");

//            if (requireWhiteListedTargets && !whiteListedTargets[target])
//                return (100 + uint32(ResultCode.TargetAddressNotWhitelisted), "");

            return (0, "");
        }

        return (100 + uint32(ResultCode.MethodNotAllowed), "");
    }

    function preRelayedCall(bytes calldata context) external returns (bytes32) {
    }

    function postRelayedCall(bytes calldata context, bool success, uint actualCharge, bytes32 preRetVal) external {
    }

    function getExtCodeHash(address addr) public view returns (bytes32 ret) {
        assembly {
            ret := extcodehash(addr)
        }
    }

    function appendAddress(bytes memory data, address addr) public pure returns (bytes memory ret) {
        ret = abi.encodePacked(data,addr);
    }
}

library factory {
    function newSoponsor() public returns (Sponsor){
        return new Sponsor();
    }
}

// File: contracts/TokenSponsor.sol

pragma solidity 0.5.10;




/**
 * sponsor interface with create2 methods
 */
contract ISponsorCreate2 is ISponsor {

    //return the address for a given owner - the same that createIdentity will create
    function getIdentityAddress(address owner, uint salt) view public returns (address);
}

/**
 * A sponsor contract that accepts tokens instead of ether.
 * at construction time, the sponsor is given an ERC20 token.
 * - it freely creates identity object for free.
 * - the generated identity objects are set with allowance to the sponsor to withdraw
 *      the token from them.
 * - the user need to transfer ether into the identity object to make other calls.
 * - the user can make any call (any token transfer, any contract call), and
 *      pay with the token.
 */
contract TokenSponsor is Sponsor, ISponsorCreate2 {

    string constant commitId="$Id: 14b4d512304bd0dd8ff8c7757b216d3c4f00c855 $";
    IERC20 public token;

    event TokenSponsorCreated(string indexed symbol, address indexed token);

    constructor(IERC20 _token) public {
        token = _token;
        //allow owner to withdraw collected fees
        token.approve(msg.sender, 10_000000_000000_000000);
        requireWhiteListedIdentityCode = true;

        //symbol() is not in the standard IERC20 interface..
        (bool success, bytes memory ret) = address(token).call(abi.encodeWithSignature("symbol()"));
        string memory sym;
        if (success)
            sym = abi.decode(ret, (string));
        else
            sym = "unknown";
        emit TokenSponsorCreated(string(sym), address(token));
    }

    /**
     * convert the given amount in eth (wei) to the given token.
     * for our TokenSponsor, we need only to be able to convert to our token.
     */
    function eth2token(IERC20 /*token*/, uint amount) public pure returns (uint) {
        //assume 2 tokens per eth, with rounding.
        return amount*2;
    }

    function createIdentityInternal(address identOwner, uint salt) internal returns (Identity){

        require(msg.sender != getSender(), "must be called through relay");
        Identity ident = createIdentityForOwner(identOwner, salt);

        //allow sponsor to withdraw from identity's token.
        //note that the identity accepts calls from the sponsor
        ident.execute(0, address(token), 0, abi.encodeWithSelector(
                token.approve.selector, this, 10 ether));

        return ident;
    }

    function acceptRelayedCall(
        address , //relay,
        address from,
        bytes calldata encodedFunction,
        uint256 , //transactionFee,
        uint256 , //gasPrice,
        uint256 , //gasLimit,
        uint256 , //nonce,
        bytes calldata ,//approvalData,
        uint256 maxPossibleCharge
        ) external view returns (uint256, bytes memory) {

        bytes4 selector = GsnUtils.getMethodSig(encodedFunction);

        if (selector == this.createIdentity.selector) {
            uint salt = uint(GsnUtils.getParam(encodedFunction, 0));
            return (0, abi.encode(
                getIdentityAddress(from,salt),  //the is the identity that will get generated.
                uint(0)));  //special case: no pre-charge for createIdentity
        }
        if ( selector != this.relayToTarget.selector )
            return (203, "invalid target method");

        //separated method, just because of "stack too deep" issues...
        // nicely, it also handles only the case of relayToTarget.
        return arcInternal(
            address(GsnUtils.getParam(encodedFunction, 0)),
            maxPossibleCharge,
            from);
    }

    function arcInternal(
        address ctx_ident,
        uint maxPossibleCharge,
        address from
    ) internal view returns (uint,bytes memory) {

        uint ctx_preCharge = eth2token(token, maxPossibleCharge);

        bytes memory ctxBytes = abi.encode(ctx_ident, ctx_preCharge);

        //copied from Sponsor object, since we can't call super.
        if (!Identity(uint160(ctx_ident)).isOwner(from) )
            return (299, "not identity owner" );

        if ( !whiteListedIdentityCode[getExtCodeHash(address(ctx_ident))])
            return (298, "untrusted identity codehash" );

        //check the caller can afford entire gaslimit.
        if (token.balanceOf(ctx_ident) < ctx_preCharge)
            return (201,"insuf token balance");

        //the caller doesn't allow sponsor to withdraw txfee.
        // note that createIdentity() set it by default
        if (token.allowance(ctx_ident, address(this)) < ctx_preCharge)
            return (202,"no allowance to sponsor");
/*
//we CANNOT call super,since its external function...
// copied over the one important check: isOwner (299, above)
// we should either:
//  - call super using `call` (ugly. no param check, etc)
//  - create "internal template" method, which acceptRelayedCall should call.
//      (we get the benefit that ARC is a template method, so you must implement it
//      or fail compilation of "new TokenSponsor()"

//        (uint status,) = super.acceptRelayedCall(
//            relay,
//            from,
//            encodedFunction,
//            transactionFee,
//            gasPrice,
//            gasLimit,
//            nonce,
//            approvalData,
//            maxPossibleCharge
//            );
//        if ( status!=0 )
//            return (status,"");
*/

        return (0,ctxBytes);
    }

    function preRelayedCall(bytes calldata context) external returns (bytes32) {
        require( msg.sender == getHubAddr() );

        //no context == free call...
//        if ( context.length==0 )
//            return 0;

        ( address ctx_ident, uint ctx_preCharge ) =
                abi.decode(context,(address, uint));

        //our createIdentity special case: no pre-charge (since no address to charge)
        if ( ctx_preCharge==0 )
            return 0;

        //require the caller to pre-pay the sponsor the max possible charge.
        require(token.transferFrom(ctx_ident, address(this), ctx_preCharge));
        return 0;
    }


    event debug( address ident, uint charge, uint preCharge, uint balIdent, uint balSponsor);

    function postRelayedCall(bytes calldata context,
            bool ,//success,
            uint actualCharge,
            bytes32 //preRetVal
        ) external {

        require( msg.sender == getHubAddr() );
        //no context == free call...
//        if ( context.length==0 )
//            return;

        ( address ctx_ident, uint ctx_preCharge ) =
            abi.decode(context,(address, uint));

        uint256 charge = eth2token(token, actualCharge);

        emit debug( ctx_ident, charge, ctx_preCharge, token.balanceOf(ctx_ident), token.balanceOf(address(this)));

        if ( ctx_preCharge==0 ) {
            //special case of createIdentity: no pre-charge.
            token.transferFrom(ctx_ident, address(this), charge);
            return;
        }

        require(ctx_preCharge >= charge, "wtf: pre-charge < charge?");
        uint256 refund = ctx_preCharge - charge;

        //refund the user the unused charge
        token.transfer(ctx_ident, refund);

    }


    bytes identityConstructor;

    //save identity constructor code. unfortunately, even though we can call "new Indentity"
    // we can't get that code for our create2...`
    function setIdentityConstructor(bytes memory ctr) public {
        identityConstructor = ctr;
    }

    //return a constructor call to Identity with 2 parameters: owner and sponsor(this)
    function getIdentityConstructor(address owner) view internal returns (bytes memory) {
        require( identityConstructor.length > 0, "identityConstructor not set");
        return abi.encodePacked(identityConstructor,uint256(owner), uint256(address(this)));
    }

    function identSalt(address owner, uint salt) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(this,owner,uint(salt))));
    }
    //return an address, with owner as salt.
    // the same address should be returned by createIdentityForOwner
    function getIdentityAddress(address owner, uint salt) view public returns (address){
        return address(uint256(keccak256(abi.encodePacked( uint8(0xff),
          address(this), identSalt(owner,salt), keccak256(getIdentityConstructor(owner))))));
    }


    event Create2(address addr);
    //create a new identity object, for this owner.
    // this method is public and anyone can create it - but only the rightful owner
    // will ever be able to use it, so it doesn't matter.
    function createIdentityForOwner(address owner, uint salt) public returns(Identity) {

        address addr = getIdentityAddress(owner, salt);
        bytes32 hash = getExtCodeHash(addr);
        if ( hash == bytes32(0) ) {
            //create only if not already exist
            address addr1 = deploy2(getIdentityConstructor(owner), identSalt(owner,salt));
            require( addr==addr1, "FATAL: create2 returned wrong address...");
        }

        Identity id = Identity(uint160(addr));
        emit Create2(addr); //for testing..
        return id;
    }

    //create2-based deployment
    function deploy2(bytes memory code, uint256 _salt) public returns(address addr) {
        assembly {
            addr := create2(0, add(code, 0x20), mload(code), _salt)
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }
    }
}

library factory1 {
    function newSoponsor() public returns (Sponsor){
        return new TokenSponsor(IERC20(0));
    }
}

// File: contracts/SampleToken.sol

pragma solidity ^0.5.0;




contract SampleToken is ERC20, ERC20Detailed {

    event TokenCreated();
    constructor() public
        ERC20Detailed ("Sample Token", "SMPL", 18) {
        emit TokenCreated();
    }

    function publicMint(uint amount) public {
        _mint(msg.sender, amount);
    }
}

contract Tok2 is ERC20, ERC20Detailed {

    event TokenCreated();
    constructor() public
        ERC20Detailed ("Another Token", "Tok2", 18) {
        emit TokenCreated();
    }

    function publicMint(uint amount) public {
        _mint(msg.sender, amount);
    }
}
