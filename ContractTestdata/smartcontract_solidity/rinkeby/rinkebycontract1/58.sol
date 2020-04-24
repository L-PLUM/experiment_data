/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity 0.5.0;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
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
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

// File: contracts/BandContractBase.sol

contract BandContractBase {

  // Denominator for any division
  uint256 public constant DENOMINATOR = 1e12;

  // 100*10^12 For percentage calculation in the contract
  uint256 public constant ONE_HUNDRED_PERCENT = 100 * DENOMINATOR;

  /**
   * @dev Helper modifier to only allow the function to be called from a
   * specific caller.
   */
  modifier onlyFrom(address caller) {
    require(msg.sender == caller);
    _;
  }
}

// File: openzeppelin-solidity/contracts/introspection/ERC165Checker.sol

/**
 * @title ERC165Checker
 * @dev Use `using ERC165Checker for address`; to include this library
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
library ERC165Checker {
  // As per the EIP-165 spec, no interface should ever match 0xffffffff
  bytes4 private constant _InterfaceId_Invalid = 0xffffffff;

  bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;
  /**
   * 0x01ffc9a7 ===
   *   bytes4(keccak256('supportsInterface(bytes4)'))
   */

  /**
   * @notice Query if a contract supports ERC165
   * @param account The address of the contract to query for support of ERC165
   * @return true if the contract at account implements ERC165
   */
  function _supportsERC165(address account)
    internal
    view
    returns (bool)
  {
    // Any contract that implements ERC165 must explicitly indicate support of
    // InterfaceId_ERC165 and explicitly indicate non-support of InterfaceId_Invalid
    return _supportsERC165Interface(account, _InterfaceId_ERC165) &&
      !_supportsERC165Interface(account, _InterfaceId_Invalid);
  }

  /**
   * @notice Query if a contract implements an interface, also checks support of ERC165
   * @param account The address of the contract to query for support of an interface
   * @param interfaceId The interface identifier, as specified in ERC-165
   * @return true if the contract at account indicates support of the interface with
   * identifier interfaceId, false otherwise
   * @dev Interface identification is specified in ERC-165.
   */
  function _supportsInterface(address account, bytes4 interfaceId)
    internal
    view
    returns (bool)
  {
    // query support of both ERC165 as per the spec and support of _interfaceId
    return _supportsERC165(account) &&
      _supportsERC165Interface(account, interfaceId);
  }

  /**
   * @notice Query if a contract implements interfaces, also checks support of ERC165
   * @param account The address of the contract to query for support of an interface
   * @param interfaceIds A list of interface identifiers, as specified in ERC-165
   * @return true if the contract at account indicates support all interfaces in the
   * interfaceIds list, false otherwise
   * @dev Interface identification is specified in ERC-165.
   */
  function _supportsAllInterfaces(address account, bytes4[] memory interfaceIds)
    internal
    view
    returns (bool)
  {
    // query support of ERC165 itself
    if (!_supportsERC165(account)) {
      return false;
    }

    // query support of each interface in _interfaceIds
    for (uint256 i = 0; i < interfaceIds.length; i++) {
      if (!_supportsERC165Interface(account, interfaceIds[i])) {
        return false;
      }
    }

    // all interfaces supported
    return true;
  }

  /**
   * @notice Query if a contract implements an interface, does not check ERC165 support
   * @param account The address of the contract to query for support of an interface
   * @param interfaceId The interface identifier, as specified in ERC-165
   * @return true if the contract at account indicates support of the interface with
   * identifier interfaceId, false otherwise
   * @dev Assumes that account contains a contract that supports ERC165, otherwise
   * the behavior of this method is undefined. This precondition can be checked
   * with the `supportsERC165` method in this library.
   * Interface identification is specified in ERC-165.
   */
  function _supportsERC165Interface(address account, bytes4 interfaceId)
    private
    view
    returns (bool)
  {
    // success determines whether the staticcall succeeded and result determines
    // whether the contract at account indicates support of _interfaceId
    (bool success, bool result) = _callERC165SupportsInterface(
      account, interfaceId);

    return (success && result);
  }

  /**
   * @notice Calls the function with selector 0x01ffc9a7 (ERC165) and suppresses throw
   * @param account The address of the contract to query for support of an interface
   * @param interfaceId The interface identifier, as specified in ERC-165
   * @return success true if the STATICCALL succeeded, false otherwise
   * @return result true if the STATICCALL succeeded and the contract at account
   * indicates support of the interface with identifier interfaceId, false otherwise
   */
  function _callERC165SupportsInterface(
    address account,
    bytes4 interfaceId
  )
    private
    view
    returns (bool success, bool result)
  {
    bytes memory encodedParams = abi.encodeWithSelector(
      _InterfaceId_ERC165,
      interfaceId
    );

    // solium-disable-next-line security/no-inline-assembly
    assembly {
      let encodedParams_data := add(0x20, encodedParams)
      let encodedParams_size := mload(encodedParams)

      let output := mload(0x40)  // Find empty storage location using "free memory pointer"
      mstore(output, 0x0)

      success := staticcall(
        30000,                 // 30k gas
        account,              // To addr
        encodedParams_data,
        encodedParams_size,
        output,
        0x20                   // Outputs are 32 bytes long
      )

      result := mload(output)  // Load the result
    }
  }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

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
  function owner() public view returns(address) {
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
  function isOwner() public view returns(bool) {
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

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: contracts/Feeless.sol

/**
 * @title Feeless
 */
contract Feeless {
    
	address public execDelegator;

  /**
  * @dev A modifier to be used for every function that can be called feelessly.
  * Function must have `sender` as the first argument, and this modifer guarantees
  * that the sender argument can be used safely. That is, either the function is called
  * directly by the sender or is called by the authorized execDelegator.
  */
  modifier feeless(address sender) {
    if (msg.sender != execDelegator) {
      require(sender == msg.sender);
    }
    _;
  }

  /**
  * @dev A function for setting the state variable execDelegator.
  * Can only be set onece.
  * @param nextExecDelegator address of new execDelegator
  */
  function setExecDelegator(address nextExecDelegator) public {
    require(execDelegator == address(0));
    execDelegator = nextExecDelegator;
  }
}

// File: contracts/CommunityToken.sol

/**
 * @title CommunityToken
 *
 * @dev Template for community token in Band ecosystem. It is essentially an
 * ERC20 contract with the ability for the "owner" to mint or burn tokens.
 * The owner will be the community's core contract after it is deployed.
 * Additionally, the contract has builtin voting power features, including
 * vote delegation and historical power tracking.
 */
contract CommunityToken is IERC20, Ownable, Feeless {
  using SafeMath for uint256;

  // `owner` chooses to delegate its voting power to `delegator`. Delegator
  // is address(0) if owner chooses to revoke previous delegation.
  event Delegate(
    address indexed owner,
    address indexed delegator
  );

  event VotingPowerUpdate(
    address indexed owner,
    uint256 votingPower
  );

  string public name;
  string public symbol;
  uint256 public decimals;

  uint256 private _totalSupply;

  mapping (address => uint256) _balances;
  // Amount of tokens allowed in transferFrom, similar to ERC-20 standard.
  mapping (address => mapping (address => uint256)) _allowed;

  /**
   * @dev IMPORTANT: voting in CommunityToken are kept as a linked
   * list of ALL historical changes of voting power in block number and power.
   *
   * For instance, if an address has the following balance list:
   *  (0, 0) -> (1000, 100) -> (1010, 90) -> (1020, 95)
   * It means the historical voting power of the address is:
   *    [at height=1000] Receive 100 voting power
   *    [at height=1010] Lose 10 voting power
   *    [at height=1020] Receive 5 voting power
   *
   * Voting power of A can change if either:
   *  1. A new address chooses A as his delegator.
   *  2. One of A's delegating members decide to stop the delegation.
   *  3. One of A's delegating members balance changes.
   * If multiple changes occur at the same block, only the last one will be
   * kept on the linked list data structure.
   *
   * This allows the contract to figure out voting power of the address at any
   * blockno `t`, by searching for the node that has the biggest blockno
   * that is not greater than `t`.
   *
   * For efficiency, blockno and power are packed into one uint256 integer,
   * with the top 64 bits representing blockno, and the bottom 192 bits
   * representing voting power.
   */
  mapping (address => mapping(uint256 => uint256)) _votingPower;
  mapping (address => uint256) public votingPowerNonces;

  // Mapping of voting delegator. All voting power of an address is
  // automatically transfered to to its delegator, until delegation is revoked.
  // Map to address(0) if an address is the delegator of itself.
  mapping (address => address) delegators;

  constructor(
    string memory _name,
    string memory _symbol,
    uint8 _decimals
  )
    public
  {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
  }

  /**
   * @dev Returns total number of tokens in existence
   */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
   * @dev Returns user voting power at the given nonce, that is, as of the
   * user's nonce^th voting power change
   */
  function historicalVotingPowerAtNonce(address owner, uint256 nonce)
    public
    view
    returns (uint256)
  {
    require(nonce <= votingPowerNonces[owner]);
    return _votingPower[owner][nonce] & ((1 << 192) - 1);  // Lower 192 bits
  }

  /**
   * @dev Returns user voting power at the given time. Under the hood, this
   * performs binary search to look for the largest nonce at which the
   * blockno is not greater than 'blockno'. The voting power at that nonce is
   * the returning value.
   */
  function historicalVotingPowerAtBlock(address owner, uint256 blockno)
    public
    view
    returns (uint256)
  {
    // Data in the current block is not yet finalized. This method only works
    // for past blocks.
    require(blockno < block.number);
    require(blockno < (1 << 64));

    uint256 start = 0;
    uint256 end = votingPowerNonces[owner];

    // The gas cost of this binary search is approximately 200 * log2(lastNonce)
    while (start < end) {
      // Doing ((start + end + 1) / 2) here to prevent infinite loop.
      uint256 mid = start.add(end).add(1).div(2);
      if ((_votingPower[owner][mid] >> 192) > blockno) { // Upper 64 bits blockno
        // If midTime > blockno, this mid can't possibly be the answer
        end = mid.sub(1);
      } else {
        // Otherwise, search on the greater side, but still keep mid as a
        // possible option.
        start = mid;
      }
    }

    // Double check again that the binary search is correct.
    assert((_votingPower[owner][start] >> 192) <= blockno);
    if (start < votingPowerNonces[owner]) {
      assert((_votingPower[owner][start + 1] >> 192) > blockno);
    }

    return historicalVotingPowerAtNonce(owner, start);
  }

  /**
   * @dev Gets the voting delegator of the specified address.
   */
  function delegatorOf(address owner) public view returns (address) {
    address delegator = delegators[owner];
    if (delegator == address(0)) {
      // If no mapping is specified, then it is the delegator of itself
      return owner;
    }
    return delegator;
  }

  /**
   * @dev Gets the current voting power of the specified address.
   */
  function votingPowerOf(address owner) public view returns (uint256) {
    return historicalVotingPowerAtNonce(owner, votingPowerNonces[owner]);
  }

  /**
   * @dev Gets the current balance of the specified address.
   * @param owner The address to query the the balance of.
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
  function allowance(address owner, address spender)
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
   * @dev Assign the given delegator to the transaction sender. The delegator
   * can vote on this account's behalf. Note that delegator assignments are
   * NOT recursive.
   */
  function delegateVote(address sender, address delegator) 
    public
    feeless(sender)
  returns (bool) {
    require(delegatorOf(sender) == sender);
    require(delegator != sender);
    // Update delegator of this sender
    delegators[sender] = delegator;
    // Update voting power of involved parties
    uint256 balance = balanceOf(sender);
    _changeVotingPower(sender, votingPowerOf(sender).sub(balance));
    _changeVotingPower(delegator, votingPowerOf(delegator).add(balance));
    emit Delegate(sender, delegator);
    return true;
  }

  /**
   * @dev Revoke voting power delegation from the previously assigned delegator.
   */
  function revokeDelegateVote(address sender, address previousDelegator)
    public
    feeless(sender)
  returns (bool) {
    require(delegatorOf(sender) == previousDelegator);
    require(previousDelegator != sender);
    // Update delegator of this sender
    delegators[sender] = address(0);
    // Update voting power of involved parties
    uint256 balance = balanceOf(sender);
    _changeVotingPower(sender, votingPowerOf(sender).add(balance));
    _changeVotingPower(previousDelegator, votingPowerOf(previousDelegator).sub(balance));
    emit Delegate(sender, address(0));
    return true;
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
   * @dev Similar to transfer, with extra parameter sender.
   */
  function transferFeeless(address sender, address to, uint256 value) 
    public
    feeless(sender)
    returns (bool)
  {
    _transfer(sender, to, value);
    return true;
  }

  /**
   * @dev Transfer tokens and call the reciver's given function with supplied
   * data, using ERC165 to determine interoperability.
   */
  function transferAndCall(
    address sender,
    address to,
    uint256 value,
    bytes4 sig,
    bytes calldata data
  )
    external
    feeless(sender)
    returns (bool)
  {
    _transfer(sender, to, value);
    require(ERC165Checker._supportsInterface(to, sig));
    (bool success,) = to.call(abi.encodePacked(sig, uint256(sender), value, data));
    require(success);
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
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value 
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Mint token to the specified address for the given amount.
   */
  function mint(address account, uint256 amount)
    public
    onlyOwner
    returns (bool)
  {
    _mint(account, amount);
    return true;
  }

  /**
   * @dev Burn token from the specified address for the given amount.
   */
  function burn(address account, uint256 amount)
    public
    onlyOwner
    returns (bool)
  {
    _burn(account, amount);
    return true;
  }

  /**
   * @dev Transfer token for a specified addresses
   * @param from The address to transfer from.
   * @param to The address to transfer to.
   * @param value The amount to be transferred.
   */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= balanceOf(from));
    require(from != to);
    require(to != address(0));
    _changeBalance(from, balanceOf(from).sub(value));
    _changeBalance(to, balanceOf(to).add(value));
    emit Transfer(from, to, value);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param amount The amount that will be created.
   */
  function _mint(address account, uint256 amount) internal {
    require(account != address(0));
    _totalSupply = _totalSupply.add(amount);
    _changeBalance(account, balanceOf(account).add(amount));
    emit Transfer(address(0), account, amount);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param amount The amount that will be burnt.
   */
  function _burn(address account, uint256 amount) internal {
    require(account != address(0));
    require(amount <= balanceOf(account));
    _totalSupply = _totalSupply.sub(amount);
    _changeBalance(account, balanceOf(account).sub(amount));
    emit Transfer(account, address(0), amount);
  }

  /**
   * @dev Change balance of the given account to a new value. The new balance
   * will be reflected both in `_balances` of this account and in `votingPower`
   * of this account's delegator.
   */
  function _changeBalance(address owner, uint256 newBalance) internal {
    uint256 oldBalance = balanceOf(owner);
    require(oldBalance != newBalance);
    // Update `_balances` with new balance.
    _balances[owner] = newBalance;
    // Compute new voting power of the address's delegator (can be itself).
    address delegator = delegatorOf(owner);
    uint256 previousPower = votingPowerOf(delegator);
    uint256 newPower = previousPower.add(newBalance).sub(oldBalance);
    _changeVotingPower(delegator, newPower);
  }

  /**
   * @dev Change voting power of the given (potentially delegated) account
   * to a new value.
   */
  function _changeVotingPower(address owner, uint256 newPower) internal {
    uint256 currentBlockno = block.number;
    uint256 currentNonce = votingPowerNonces[owner];
    require(newPower < (1 << 192));
    require(currentBlockno < (1 << 64));
    if ((_votingPower[owner][currentNonce] >> 192) != currentBlockno) {
      // If the current blockno is not equal to the last one on the linked list,
      // we append a new entry to the list. Otherwise, we simply rewrite the
      // last node's power to newPower.
      currentNonce = currentNonce.add(1);
      votingPowerNonces[owner] = currentNonce;
    }
    _votingPower[owner][currentNonce] = (currentBlockno << 192) | newPower;
    emit VotingPowerUpdate(owner, newPower);
  }
}

// File: contracts/ParametersBase.sol

/**
 * @title ParametersBase
 */
contract ParametersBase {
  /**
   * Public map of all active parameters.
   * This variable have to be declared first,
   * if not "delegatecall" will use another variable instead.
   */
  mapping (bytes32 => uint256) public params;

  /**
   * @dev Return the value at the given key. Throw if the value is not set.
   */
  function get(bytes32 key) public view returns (uint256) {
    uint256 value = params[key];
    require(value != 0);
    return value;
  }

  /**
   * @dev Similar to get function, but returns 0 instead of throwing.
   */
  function getZeroable(bytes32 key) public view returns (uint256) {
    return params[key];
  }
}

// File: contracts/ResolveListener.sol

/**
 * @title ResolveListener
 */
interface ResolveListener {

  enum PollState {
    Invalid,      // Invalid, no poll at this address/ID.
    Active,       // The poll is accepting commit/reveal.
    Yes,          // The poll is resolved, with result Yes.
    No,           // The poll is resolved, with result No.
    Inconclusive  // The poll is resolved, with result Inconclusive.
  }

  /**
   * @dev Call by Voting contract after a poll is resolved. The Callee should
   * make sure to only accept the call from its Voting contract.
   */
  function onResolved(uint256 pollID, PollState pollState)
    external returns (bool);
}

// File: contracts/VotingInterface.sol

/**
 * @title VotingInterface
 */
contract VotingInterface {

  event PollResolved(  // A poll is resolved.
    address indexed pollContract,
    uint256 indexed pollID,
    ResolveListener.PollState pollState
  );

  /**
   * Mimic the parameters in Parameters.sol and make it private.
   * So no one can write this params.
   */
  mapping (bytes32 => uint256) private _params;

  /**
   * Make these params readable via internal call.
   */
  function getParam(bytes32 key) internal view returns(uint256) {
    return _params[key];
  }

  /**
   * Verify voting parameters
   */
  function verifyVotingParams()
    public 
    returns (bool);

  /**
   * Start a new poll for the function caller.
   */
  function startPoll(
    CommunityToken token,
    uint256 pollID,
    bytes8 prefix,
    ParametersBase params
  )
    public
    returns (bool);

  /**
   * Return the current state for a specific poll.
   */
  function getPollState(address pollContract, uint256 pollID)
    public
    view
    returns (ResolveListener.PollState);

  /**
   * Return the current vote score for a specific poll.
   */
  function getPollTotalVote(address pollContract, uint256 pollID)
    public
    view
    returns (uint256 yesCount, uint256 noCount);

  /**
   * Return the vote allocation for the given voter.
   */
  function getPollUserVote(address pollContract, uint256 pollID, address voter)
    public
    view
    returns (uint256 yesCount, uint256 noCount);
}

// File: contracts/CommitRevealVoting.sol

/**
 * @title CommitRevealVoting
 */
contract CommitRevealVoting is BandContractBase, VotingInterface, Feeless {
  using SafeMath for uint256;

  event PollCreated(  // A poll is created.
    address indexed pollContract,
    uint256 indexed pollID,
    address indexed tokenContract,
    uint256 commitEndTime,
    uint256 revealEndTime,
    uint256 voteMinParticipation,
    uint256 voteSupportRequired
  );

  event PollResolved(  // A poll is resolved.
    address indexed pollContract,
    uint256 indexed pollID,
    ResolveListener.PollState pollState
  );

  event VoteCommitted(  // A vote is committed by a user.
    address indexed pollContract,
    uint256 indexed pollID,
    address indexed voter,
    bytes32 voteHash
  );

  event VoteRevealed(  // A vote is revealed by a user.
    address indexed pollContract,
    uint256 indexed pollID,
    address indexed voter,
    uint256 yesWeight,
    uint256 noWeight,
    uint256 salt
  );

  enum VoteState {
    Invalid,      // Invalid, default value
    Committed,    // The vote has been committed, but not yet revealed.
    Revealed      // The vote has been revealed.
  }

  struct Poll {
    CommunityToken token; // The address of community token contract for voting power reference

    uint256 snapshotBlockNo;        // The block number to count voting power
    uint256 commitEndTime;          // Expiration timestamp of commit period
    uint256 revealEndTime;          // Expiration timestamp of reveal period
    uint256 voteSupportRequiredPct; // Threshold % for detemining poll result

    uint256 voteMinParticipation; // The minimum # of votes required
    uint256 yesCount;             // The current total number of YES votes
    uint256 noCount;              // The current total number of NO votes
    uint256 totalCount;           // The current total number of Yes+No votes

    mapping (address => bytes32) commits;       // Each user's committed vote
    mapping (address => uint256) yesWeights;    // Each user's yes vote weight
    mapping (address => uint256) noWeights;     // Each user's no vote weight

    ResolveListener.PollState pollState;  // The state of this poll.
  }

  // Mapping of all polls ever existed, for each of the poll creators.
  mapping (address => mapping (uint256 => Poll)) public polls;

  modifier pollMustNotExist(address pollContract, uint256 pollID) {
    require(polls[pollContract][pollID].pollState == ResolveListener.PollState.Invalid);
    _;
  }

  modifier pollMustBeActive(address pollContract, uint256 pollID) {
    require(polls[pollContract][pollID].pollState == ResolveListener.PollState.Active);
    _;
  }

  function getPollState(address pollContract, uint256 pollID)
    public
    view
    returns (ResolveListener.PollState)
  {
    return polls[pollContract][pollID].pollState;
  }

  function getPollTotalVote(address pollContract, uint256 pollID)
    public
    view
    returns (uint256 yesCount, uint256 noCount)
  {
    Poll storage poll = polls[pollContract][pollID];
    return (poll.yesCount, poll.noCount);
  }

  function getPollUserVote(address pollContract, uint256 pollID, address voter)
    public
    view
    returns (uint256 yesWeight, uint256 noWeight)
  {
    Poll storage poll = polls[pollContract][pollID];
    return (poll.yesWeights[voter], poll.noWeights[voter]);
  }

  function getPollUserState(address pollContract, uint256 pollID, address voter)
    public
    view
    returns (VoteState)
  {
    Poll storage poll = polls[pollContract][pollID];
    if (poll.commits[voter] == 0) {
      return VoteState.Invalid;
    } else if (poll.yesWeights[voter] == 0 && poll.noWeights[voter] == 0) {
      return VoteState.Committed;
    }
    return VoteState.Revealed;
  }

  function getPollUserCommit(address pollContract, uint256 pollID, address voter)
    public
    view
    returns (bytes32)
  {
    Poll storage poll = polls[pollContract][pollID];
    return poll.commits[voter];
  }

  function verifyVotingParams() public returns(bool) {
    uint256 commitEndTime = getParam("params:commit_time");
    uint256 revealEndTime = getParam("params:reveal_time");
    uint256 voteMinParticipationPct = getParam("params:min_participation_pct");
    uint256 voteSupportRequiredPct = getParam("params:support_required_pct");

    require(commitEndTime > 0);
    require(revealEndTime > 0);
    require(voteMinParticipationPct > 0 && voteMinParticipationPct <=  ONE_HUNDRED_PERCENT);
    require(voteSupportRequiredPct > 0 && voteSupportRequiredPct <= ONE_HUNDRED_PERCENT);

    return true;
  }

  function startPoll(
    CommunityToken token,
    uint256 pollID,
    bytes8 prefix,
    ParametersBase params
  )
    public
    pollMustNotExist(msg.sender, pollID)
    returns (bool)
  {
    uint256 commitEndTime = now.add(get(params, prefix, "commit_time"));
    uint256 revealEndTime = commitEndTime.add(get(params, prefix, "reveal_time"));
    uint256 voteMinParticipationPct = get(params, prefix, "min_participation_pct");
    uint256 voteSupportRequiredPct = get(params, prefix, "support_required_pct");

    require(revealEndTime < 2 ** 64);
    require(commitEndTime < revealEndTime);
    require(voteMinParticipationPct <= ONE_HUNDRED_PERCENT);
    require(voteSupportRequiredPct <= ONE_HUNDRED_PERCENT);

    // NOTE: This could possibliy be slightly mismatched with `snapshotBlockNo`
    // if there are mint/burn transactions in this block prior to
    // this transaction. The effect, however, should be minimal as
    // `minimum_quorum` is primarily used to ensure minimum number of vote
    // participants. The primary decision factor should be `support_required`.
    uint256 voteMinParticipation
      = voteMinParticipationPct.mul(token.totalSupply()).div(ONE_HUNDRED_PERCENT);

    Poll storage poll = polls[msg.sender][pollID];
    poll.snapshotBlockNo = block.number.sub(1);
    poll.commitEndTime = commitEndTime;
    poll.revealEndTime = revealEndTime;
    poll.voteSupportRequiredPct = voteSupportRequiredPct;
    poll.voteMinParticipation = voteMinParticipation;
    poll.pollState = ResolveListener.PollState.Active;
    poll.token = token;

    emit PollCreated(
      msg.sender,
      pollID,
      address(token),
      commitEndTime,
      revealEndTime,
      voteMinParticipation,
      voteSupportRequiredPct
    );
    return true;
  }

  function commitVote(
    address sender,
    address pollContract,
    uint256 pollID,
    bytes32 commitValue,
    bytes32 prevCommitValue,
    uint256 totalWeight,
    uint256 prevTotalWeight
  )
    public
    feeless(sender)
    pollMustBeActive(pollContract, pollID)
  {
    Poll storage poll = polls[pollContract][pollID];
    
    // Must be in commit period.
    require(now < poll.commitEndTime);
    // commitValue should look like hash
    require(commitValue != 0);
    // totalWeight = 0 is pointless
    require(totalWeight > 0);
    // totalWeight will not exceed voting power of sender
    require(
      totalWeight <= 
      poll.token.historicalVotingPowerAtBlock(
        sender,
        poll.snapshotBlockNo
      )
    );

    // caculate current commit by hashing prev totalWeight and commitValue
    bytes32 prevCommitValWithTW = getHash(prevTotalWeight, prevCommitValue);
    require(poll.commits[sender] == prevCommitValWithTW);

    // calculate new commit by hashing totalWeight and commitValue
    bytes32 commitValWithTW = getHash(totalWeight, commitValue);
    poll.commits[sender] = commitValWithTW;

    // remove prevTotalWeight from poll.totalCount before adding new totalWeight
    poll.totalCount = poll.totalCount.sub(prevTotalWeight).add(totalWeight);

    emit VoteCommitted(pollContract, pollID, sender, commitValWithTW);
  }

  function revealVote(
    address voteOwner,
    address pollContract,
    uint256 pollID,
    uint256 yesWeight,
    uint256 noWeight,
    uint256 salt
  )
    public
    pollMustBeActive(pollContract, pollID)
  {
    Poll storage poll = polls[pollContract][pollID];
    // Must be in reveal period.
    require(now >= poll.commitEndTime && now < poll.revealEndTime);
    // pointless if yesWeight and noWeight are 0
    require(yesWeight > 0 || noWeight > 0);
    // Must not already be revealed.
    require(getPollUserState(pollContract, pollID, voteOwner) == VoteState.Committed);
    // Must be consistent with the prior commit value.
    require(
      getHash(yesWeight.add(noWeight),
        keccak256(abi.encodePacked(yesWeight, noWeight, salt))
      ) ==
      poll.commits[voteOwner]
    );

    poll.yesWeights[voteOwner] = yesWeight;
    poll.yesCount = poll.yesCount.add(yesWeight);
    poll.noWeights[voteOwner] = noWeight;
    poll.noCount = poll.noCount.add(noWeight);

    emit VoteRevealed(pollContract, pollID, voteOwner, yesWeight, noWeight, salt);
  }

  function resolvePoll(address pollContract, uint256 pollID)
    public
    pollMustBeActive(pollContract, pollID)
  {
    Poll storage poll = polls[pollContract][pollID];

    require(now >= poll.commitEndTime);

    ResolveListener.PollState pollState;

    if (poll.totalCount < poll.voteMinParticipation) {
      pollState = ResolveListener.PollState.Inconclusive;
    } else {
      require(now >= poll.revealEndTime);

      uint256 yesCount = poll.yesCount;
      uint256 noCount = poll.noCount;

      if (yesCount.mul(ONE_HUNDRED_PERCENT) >= poll.voteSupportRequiredPct.mul(yesCount.add(noCount))) {
        pollState = ResolveListener.PollState.Yes;
      } else {
        pollState = ResolveListener.PollState.No;
      }
    }

    poll.pollState = pollState;
    emit PollResolved(pollContract, pollID, pollState);
    require(ResolveListener(pollContract).onResolved(pollID, pollState));
  }

  function getHash(uint256 weight, bytes32 commit)
    private
    pure
    returns (bytes32)
  {
    if (commit == 0 && weight == 0) {
      return 0;
    }
    return keccak256(abi.encodePacked(weight, commit));
  }

  function get(ParametersBase params, bytes8 prefix, bytes24 key)
    internal
    view
    returns (uint256)
  {
    uint8 prefixSize = 0;
    while (prefixSize < 8 && prefix[prefixSize] != byte(0)) {
      ++prefixSize;
    }
    return params.get(bytes32(prefix) | (bytes32(key) >> (8 * prefixSize)));
  }
}
