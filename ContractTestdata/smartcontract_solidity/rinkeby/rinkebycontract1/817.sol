/**
 *Submitted for verification at Etherscan.io on 2019-02-07
*/

pragma solidity 0.5.0;

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
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
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
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
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
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
    require(value <= _balances[from]);
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
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}

// File: contracts/BandToken.sol

/**
 * @title BandToken
 *
 * @dev BandToken ERC-20 follows the ERC-20 standard. However, it adds token
 * locking functionality. Some addresses will have their tokens locked, which
 * means not all of their tokens are transferable. Locked tokens will reduce
 * monthly proportionally until they are fully unlocked.
 */
contract BandToken is ERC20, Ownable {

  string public constant name = "BandToken";
  string public constant symbol = "BAND";
  uint256 public constant decimals = 18;

  /**
   * @dev TokenLock struct represents the token locking information. This is
   * only relevant to Band investors that have token locking aggrements. It
   * consists of four fields. Note that the i^th month, mean the i^th month
   * since 2019/04, counting 2019/04 as the zeroth month.
   *
   * start: token locking starts at the beginning of the start^th month.
   * cliff: at the beginning of the cliff^th month, the amount of locked tokens
   *        will be propotional to the number of full months since start and
   *        the total of months between start and end.
   * end: at the beginning of the end^th month, all of the tokens are unlocked.
   * totalValue: the total amount of tokens that the locking has control over.
   */
  struct TokenLockInfo {
    uint8 start;
    uint8 cliff;
    uint8 end;
    uint256 totalValue;
  }

  mapping (address => TokenLockInfo) public locked;

  // Array of epoch timestamps generated in constructor. The i^th index
  // represents the end of the i^th month after Band mainnet launch, which is
  // the beginning of Q2 2019.
  uint256[48] private eomTimestamps;

  /**
   * @dev BandToken constructor. All of the available tokens are minted to the
   * token creator.
   */
  constructor(uint256 totalSupply, address creator) public {
    // Initially, all of the minted tokens belong to the contract creator.
    _mint(creator, totalSupply);
    transferOwnership(creator);

    // Populate eomTimestamps for every month from the start of Q2 2019.
    // until the end of Q1 2023, for the total of 4 years (48 months).
    eomTimestamps[0] = 1556668800;   // End of 2019/04
    eomTimestamps[1] = 1559347200;   // End of 2019/05
    eomTimestamps[2] = 1561939200;   // End of 2019/06
    eomTimestamps[3] = 1564617600;   // End of 2019/07
    eomTimestamps[4] = 1567296000;   // End of 2019/08
    eomTimestamps[5] = 1569888000;   // End of 2019/09
    eomTimestamps[6] = 1572566400;   // End of 2019/10
    eomTimestamps[7] = 1575158400;   // End of 2019/11
    eomTimestamps[8] = 1577836800;   // End of 2020/00
    eomTimestamps[9] = 1580515200;   // End of 2020/01
    eomTimestamps[10] = 1583020800;  // End of 2020/02
    eomTimestamps[11] = 1585699200;  // End of 2020/03
    eomTimestamps[12] = 1588291200;  // End of 2020/04
    eomTimestamps[13] = 1590969600;  // End of 2020/05
    eomTimestamps[14] = 1593561600;  // End of 2020/06
    eomTimestamps[15] = 1596240000;  // End of 2020/07
    eomTimestamps[16] = 1598918400;  // End of 2020/08
    eomTimestamps[17] = 1601510400;  // End of 2020/09
    eomTimestamps[18] = 1604188800;  // End of 2020/10
    eomTimestamps[19] = 1606780800;  // End of 2020/11
    eomTimestamps[20] = 1609459200;  // End of 2021/00
    eomTimestamps[21] = 1612137600;  // End of 2021/01
    eomTimestamps[22] = 1614556800;  // End of 2021/02
    eomTimestamps[23] = 1617235200;  // End of 2021/03
    eomTimestamps[24] = 1619827200;  // End of 2021/04
    eomTimestamps[25] = 1622505600;  // End of 2021/05
    eomTimestamps[26] = 1625097600;  // End of 2021/06
    eomTimestamps[27] = 1627776000;  // End of 2021/07
    eomTimestamps[28] = 1630454400;  // End of 2021/08
    eomTimestamps[29] = 1633046400;  // End of 2021/09
    eomTimestamps[30] = 1635724800;  // End of 2021/10
    eomTimestamps[31] = 1638316800;  // End of 2021/11
    eomTimestamps[32] = 1640995200;  // End of 2022/00
    eomTimestamps[33] = 1643673600;  // End of 2022/01
    eomTimestamps[34] = 1646092800;  // End of 2022/02
    eomTimestamps[35] = 1648771200;  // End of 2022/03
    eomTimestamps[36] = 1651363200;  // End of 2022/04
    eomTimestamps[37] = 1654041600;  // End of 2022/05
    eomTimestamps[38] = 1656633600;  // End of 2022/06
    eomTimestamps[39] = 1659312000;  // End of 2022/07
    eomTimestamps[40] = 1661990400;  // End of 2022/08
    eomTimestamps[41] = 1664582400;  // End of 2022/09
    eomTimestamps[42] = 1667260800;  // End of 2022/10
    eomTimestamps[43] = 1669852800;  // End of 2022/11
    eomTimestamps[44] = 1672531200;  // End of 2023/00
    eomTimestamps[45] = 1675209600;  // End of 2023/01
    eomTimestamps[46] = 1677628800;  // End of 2023/02
    eomTimestamps[47] = 1680307200;  // End of 2023/03
  }

  /**
   * @dev Set locking period for the specified address. See TokenLockInfo above
   * for the descriptions of the function arguments.
   */
  function setTokenLock(
    address addr,
    uint8 start,
    uint8 cliff,
    uint8 end,
    uint256 value
  )
    public
    onlyOwner
    returns (bool)
  {
    require(start < cliff);
    require(cliff <= end);
    require(end > 0 && end <= 48);

    locked[addr] = TokenLockInfo({
      start: start,
      cliff: cliff,
      end: end,
      totalValue: value
    });

    return true;
  }

  /**
   * @dev Get the unlocked balance of the specified address.
   * @param addr The address to query
   * @return The unlocked balance, which is the total balance subtracted by
   * the number of tokens yet remained to be unlocked for this address. See
   * TokenLockInfo above for details.
   */
  function unlockedBalanceOf(address addr) public view returns (uint256) {
    TokenLockInfo storage lockInfo = locked[addr];
    uint256 totalBalance = balanceOf(addr);
    uint8 end = lockInfo.end;
    if (end == 0) {
      // Most of the time, the address will not have token locking logic.
      // We can simply return totalBalance in this case.
      return totalBalance;
    }
    // Calculate the current month using a simple loop. The array size is
    // limitted to 48, so the gas cost here is bounded to approximately 10k.
    uint8 currentMonth = 0;
    while (currentMonth < end && eomTimestamps[currentMonth] <= now) {
      // Loop one-by-one until we find the first month that ends after the
      // current time.
      currentMonth = currentMonth + 1;
    }
    uint8 start = lockInfo.start;
    uint8 cliff = lockInfo.cliff;
    uint256 totalLocked = lockInfo.totalValue;
    // This variable will be initialized in one of the three conditions below.
    // It will indicate the effective amount of locked tokens at this moment.
    uint256 currentlyLocked = 0;
    if (currentMonth < cliff) {
      // The cliff has not passed yet. All of the tokens are locked.
      currentlyLocked = totalLocked;
    } else if (currentMonth < end) {
      // Some of the tokens are locked proportionally to the remaining time.
      uint256 totalMonths = uint256(end - start);
      uint256 remainingMonths = uint256(end - currentMonth);
      currentlyLocked = totalLocked.mul(remainingMonths).div(totalMonths);
    } else {
      // The duration has passed. None of the tokens are locked.
      currentlyLocked = 0;
    }
    if (currentlyLocked > totalBalance) {
      return 0;
    } else {
      return totalBalance.sub(currentlyLocked);
    }
  }

  /**
   * @dev Similar to ERC20 transfer, with extra token locking restriction.
   */
  function transfer(address to, uint256 value) public returns (bool) {
    require(value <= unlockedBalanceOf(msg.sender));
    return super.transfer(to, value);
  }

  /**
  * @dev Transfer tokens and call the reciver's given function with supplied
  * data, using ERC165 to determine interoperability.
  */
  function transferAndCall(
    address to,
    uint256 value,
    bytes4 sig,
    bytes calldata data
  )
    external
    returns (bool)
  {
    require(value <= unlockedBalanceOf(msg.sender));
    super.transfer(to, value);
    require(ERC165Checker._supportsInterface(to, sig));
    (bool success,) = to.call(abi.encodePacked(sig, uint256(msg.sender), value, data));
    require(success);
    return true;
  }

  /**
   * @dev Similar to ERC20 transferFrom, with extra token locking restriction.
   */
  function transferFrom(address from, address to, uint256 value)
    public
    returns (bool)
  {
    require(value <= unlockedBalanceOf(from));
    return super.transferFrom(from, to, value);
  }
}

// File: openzeppelin-solidity/contracts/introspection/IERC165.sol

/**
 * @title IERC165
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
interface IERC165 {

  /**
   * @notice Query if a contract implements an interface
   * @param interfaceId The interface identifier, as specified in ERC-165
   * @dev Interface identification is specified in ERC-165. This function
   * uses less than 30,000 gas.
   */
  function supportsInterface(bytes4 interfaceId)
    external
    view
    returns (bool);
}

// File: openzeppelin-solidity/contracts/introspection/ERC165.sol

/**
 * @title ERC165
 * @author Matt Condon (@shrugs)
 * @dev Implements ERC165 using a lookup table.
 */
contract ERC165 is IERC165 {

  bytes4 private constant _InterfaceId_ERC165 = 0x01ffc9a7;
  /**
   * 0x01ffc9a7 ===
   *   bytes4(keccak256('supportsInterface(bytes4)'))
   */

  /**
   * @dev a mapping of interface id to whether or not it's supported
   */
  mapping(bytes4 => bool) private _supportedInterfaces;

  /**
   * @dev A contract implementing SupportsInterfaceWithLookup
   * implement ERC165 itself
   */
  constructor()
    internal
  {
    _registerInterface(_InterfaceId_ERC165);
  }

  /**
   * @dev implement supportsInterface(bytes4) using a lookup table
   */
  function supportsInterface(bytes4 interfaceId)
    external
    view
    returns (bool)
  {
    return _supportedInterfaces[interfaceId];
  }

  /**
   * @dev internal method for registering an interface
   */
  function _registerInterface(bytes4 interfaceId)
    internal
  {
    require(interfaceId != 0xffffffff);
    _supportedInterfaces[interfaceId] = true;
  }
}

// File: contracts/AdminInterface.sol

/**
 * @title AdminInterface
 */
interface AdminInterface {

  /**
   * @dev Return whether the given address is an admin at the moment.
   */
  function isAdmin(address account) external view returns (bool);
}

// File: contracts/BandContractBase.sol

contract BandContractBase {
  /**
   * @dev Helper modifier to only allow the function to be called from a
   * specific caller.
   */
  modifier onlyFrom(address caller) {
    require(msg.sender == caller);
    _;
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
contract CommunityToken is IERC20, Ownable {
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
  function delegateVote(address delegator) public returns (bool) {
    require(delegatorOf(msg.sender) == msg.sender);
    require(delegator != msg.sender);
    // Update delegator of this sender
    delegators[msg.sender] = delegator;
    // Update voting power of involved parties
    uint256 balance = balanceOf(msg.sender);
    _changeVotingPower(msg.sender, votingPowerOf(msg.sender).sub(balance));
    _changeVotingPower(delegator, votingPowerOf(delegator).add(balance));
    emit Delegate(msg.sender, delegator);
    return true;
  }

  /**
   * @dev Revoke voting power delegation from the previously assigned delegator.
   */
  function revokeDelegateVote(address previousDelegator) public returns (bool) {
    require(delegatorOf(msg.sender) == previousDelegator);
    require(previousDelegator != msg.sender);
    // Update delegator of this sender
    delegators[msg.sender] = address(0);
    // Update voting power of involved parties
    uint256 balance = balanceOf(msg.sender);
    _changeVotingPower(msg.sender, votingPowerOf(msg.sender).add(balance));
    _changeVotingPower(previousDelegator, votingPowerOf(previousDelegator).sub(balance));
    emit Delegate(msg.sender, address(0));
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
   * @dev Transfer tokens and call the reciver's given function with supplied
   * data, using ERC165 to determine interoperability.
   */
  function transferAndCall(
    address to,
    uint256 value,
    bytes4 sig,
    bytes calldata data
  )
    external
    returns (bool)
  {
    _transfer(msg.sender, to, value);
    require(ERC165Checker._supportsInterface(to, sig));
    (bool success,) = to.call(abi.encodePacked(sig, uint256(msg.sender), value, data));
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
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));
    _allowed[msg.sender][spender] = (_allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
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

// File: contracts/Equation.sol

/**
 * @title Equation
 *
 * @dev Equation library abstracts the representation of mathematics equation.
 * As of current, an equation is basically an expression tree of constants,
 * one variable (X), and operators.
 */
library Equation {
  using SafeMath for uint256;

  /**
   * @dev An expression tree is encoded as a set of nodes, with root node having
   * index zero. Each node consists of 3 values:
   *  1. opcode: the expression that the node represents. See table below.
   * +--------+----------------------------------------+------+------------+
   * | Opcode |              Description               | i.e. | # children |
   * +--------+----------------------------------------+------+------------+
   * |   00   | Integer Constant                       |   c  |      0     |
   * |   01   | Variable                               |   X  |      0     |
   * |   02   | Arithmetic Square Root                 |   √  |      1     |
   * |   03   | Boolean Not Condition                  |   !  |      1     |
   * |   04   | Arithmetic Addition                    |   +  |      2     |
   * |   05   | Arithmetic Subtraction                 |   -  |      2     |
   * |   06   | Arithmetic Multiplication              |   *  |      2     |
   * |   07   | Arithmetic Division                    |   /  |      2     |
   * |   08   | Arithmetic Exponentiation              |  **  |      2     |
   * |   09   | Arithmetic Equal Comparison            |  ==  |      2     |
   * |   10   | Arithmetic Non-Equal Comparison        |  !=  |      2     |
   * |   11   | Arithmetic Less-Than Comparison        |  <   |      2     |
   * |   12   | Arithmetic Greater-Than Comparison     |  >   |      2     |
   * |   13   | Arithmetic Non-Greater-Than Comparison |  <=  |      2     |
   * |   14   | Arithmetic Non-Less-Than Comparison    |  >=  |      2     |
   * |   15   | Boolean And Condition                  |  &&  |      2     |
   * |   16   | Boolean Or Condition                   |  ||  |      2     |
   * |   17   | Ternary Operation                      |  ?:  |      3     |
   * +--------+----------------------------------------+------+------------+
   *  2. children: the list of node indices of this node's sub-expressions.
   *  Different opcode nodes will have different number of children.
   *  3. value: the value inside the node. Currently this is only relevant for
   *  Integer Constant (Opcode 00).
   *
   * An equation's data is a list of nodes. The nodes will link against
   * each other using index as pointer. The root node of the expression tree
   * is the first node in the list
   */
  struct Node {
    uint8 opcode;
    uint8 child0;
    uint8 child1;
    uint8 child2;
    uint256 value;
  }

  /**
   * @dev An internal struct to keep track of expression type. This is to make
   * sure than the given equation type-checks.
   */
  enum ExprType {
    Invalid,
    Math,
    Boolean
  }

  uint8 constant OPCODE_CONST = 0;
  uint8 constant OPCODE_VAR = 1;
  uint8 constant OPCODE_SQRT = 2;
  uint8 constant OPCODE_NOT = 3;
  uint8 constant OPCODE_ADD = 4;
  uint8 constant OPCODE_SUB = 5;
  uint8 constant OPCODE_MUL = 6;
  uint8 constant OPCODE_DIV = 7;
  uint8 constant OPCODE_EXP = 8;
  uint8 constant OPCODE_EQ = 9;
  uint8 constant OPCODE_NE = 10;
  uint8 constant OPCODE_LT = 11;
  uint8 constant OPCODE_GT = 12;
  uint8 constant OPCODE_LE = 13;
  uint8 constant OPCODE_GE = 14;
  uint8 constant OPCODE_AND = 15;
  uint8 constant OPCODE_OR = 16;
  uint8 constant OPCODE_IF = 17;
  uint8 constant OPCODE_INVALID = 18;

  /**
   * @dev Initialize equation by array of opcodes/values in prefix order. Array
   * is read as if it is the *pre-order* traversal of the expression tree.
   * For instance, expression x^2 - 3 is encoded as: [5, 8, 1, 0, 2, 0, 3]
   *
   *                 5 (Opcode -)
   *                    /  \
   *                   /     \
   *                /          \
   *         8 (Opcode **)       \
   *             /   \             \
   *           /       \             \
   *         /           \             \
   *  1 (Opcode X)  0 (Opcode c)  0 (Opcode c)
   *                     |              |
   *                     |              |
   *                 2 (Value)     3 (Value)
   *
   * @param self storage pointer to equation data to initialize.
   * @param _expressions array of opcodes/values to initialize.
   */
  function init(Node[] storage self, uint256[] memory _expressions) internal {
    // Init should only be called when the equation is not yet initialized.
    assert(self.length == 0);

    // Limit expression length to < 256 to make sure gas cost is managable.
    require(_expressions.length < 256);

    for (uint8 idx = 0; idx < _expressions.length; ++idx) {
      // Get the next opcode. Obviously it must be within the opcode range.
      uint256 opcode = _expressions[idx];
      require(opcode < OPCODE_INVALID);

      Node memory node;
      node.opcode = uint8(opcode);

      // Get the node's value. Only applicable on Integer Constant case.
      if (opcode == OPCODE_CONST) {
        node.value = _expressions[++idx];
      }

      self.push(node);
    }

    // Actual code to create the tree. We also assert and the end that all
    // of the provided expressions are exhausted.
    (uint8 lastNodeIndex,) = populateTree(self, 0);
    require(lastNodeIndex == self.length - 1);
  }

  /**
   * @dev Clear the existing equation. Must be called prior to init of the tree
   * has already been initialized.
   */
  function clear(Node[] storage self) internal {
    assert(self.length < 256);

    for (uint8 idx = 0; idx < self.length; ++idx) {
      delete self[idx];
    }

    self.length = 0;
  }

  /**
   * @dev Calculate the Y position from the X position for this equation.
   */
  function calculate(Node[] storage self, uint256 xValue)
    internal
    view
    returns (uint256)
  {
    return solveMath(self, 0, xValue);
  }

  /**
   * @dev Return the number of children the given opcode node has.
   */
  function getChildrenCount(uint8 opcode) private pure returns (uint8) {
    if (opcode <= OPCODE_VAR) {
      return 0;
    } else if (opcode <= OPCODE_NOT) {
      return 1;
    } else if (opcode <= OPCODE_OR) {
      return 2;
    } else if (opcode <= OPCODE_IF) {
      return 3;
    } else {
      assert(false);
    }
  }

  /**
   * @dev Check whether the given opcode and list of expression types match.
   * Execute revert EVM opcode on failure.
   * @return The type of this expression itself.
   */
  function checkExprType(uint8 opcode, ExprType[] memory types)
    private
    pure
    returns (ExprType)
  {
    if (opcode <= OPCODE_VAR) {
      return ExprType.Math;

    } else if (opcode == OPCODE_SQRT) {
      require(types[0] == ExprType.Math);
      return ExprType.Math;

    } else if (opcode == OPCODE_NOT) {
      require(types[0] == ExprType.Boolean);
      return ExprType.Boolean;

    } else if (opcode >= OPCODE_ADD && opcode <= OPCODE_EXP) {
      require(types[0] == ExprType.Math);
      require(types[1] == ExprType.Math);
      return ExprType.Math;

    } else if (opcode >= OPCODE_EQ && opcode <= OPCODE_GE) {
      require(types[0] == ExprType.Math);
      require(types[1] == ExprType.Math);
      return ExprType.Boolean;

    } else if (opcode >= OPCODE_AND && opcode <= OPCODE_OR) {
      require(types[0] == ExprType.Boolean);
      require(types[1] == ExprType.Boolean);
      return ExprType.Boolean;

    } else if (opcode == OPCODE_IF) {
      require(types[0] == ExprType.Boolean);
      require(types[1] != ExprType.Invalid);
      require(types[1] == types[2]);
      return types[1];

    }
  }

  /**
   * @dev Helper function to recursively populate node information following
   * the given pre-order node list. It inspects the opcode and recursively
   * call populateTree(s) accordingly.
   *
   * @param self storage pointer to equation data to build tree.
   * @param currentNodeIndex the index of the current node to populate info.
   * @return An (uint8, bool). The first value represents the last
   * (highest/rightmost) node ndex of the current subtree. The second value
   * indicates the type that one would get from evaluating this subtree.
   */
  function populateTree(Node[] storage self, uint8 currentNodeIndex)
    private
    returns (uint8, ExprType)
  {
    require(currentNodeIndex < self.length);
    Node storage node = self[currentNodeIndex];

    uint8 opcode = node.opcode;
    uint8 childrenCount = getChildrenCount(opcode);

    ExprType[] memory childrenTypes = new ExprType[](childrenCount);
    uint8 lastNodeIndex = currentNodeIndex;

    for (uint8 idx = 0; idx < childrenCount; ++idx) {
      if (idx == 0) {
        node.child0 = lastNodeIndex + 1;
      } else if (idx == 1) {
        node.child1 = lastNodeIndex + 1;
      } else if (idx == 2) {
        node.child2 = lastNodeIndex + 1;
      } else {
        assert(false);
      }

      (lastNodeIndex, childrenTypes[idx]) = populateTree(self, lastNodeIndex + 1);
    }

    ExprType exprType = checkExprType(opcode, childrenTypes);
    return (lastNodeIndex, exprType);
  }


  /**
   * @dev Calculate the arithmetic value of this sub-expression at the given
   * X position.
   */
  function solveMath(Node[] storage self, uint8 nodeIdx, uint256 xValue)
    private
    view
    returns (uint256)
  {
    Node storage node = self[nodeIdx];
    uint8 opcode = node.opcode;

    if (opcode == OPCODE_CONST) {
      return node.value;
    } else if (opcode == OPCODE_VAR) {
      return xValue;
    } else if (opcode == OPCODE_SQRT) {
      uint256 childValue = solveMath(self, node.child0, xValue);
      uint256 temp = childValue.add(1).div(2);
      uint256 result = childValue;

      while (temp < result) {
        result = temp;
        temp = childValue.div(temp).add(temp).div(2);
      }

      return result;

    } else if (opcode >= OPCODE_ADD && opcode <= OPCODE_EXP) {

      uint256 leftValue = solveMath(self, node.child0, xValue);
      uint256 rightValue = solveMath(self, node.child1, xValue);

      if (opcode == OPCODE_ADD) {
        return leftValue.add(rightValue);
      } else if (opcode == OPCODE_SUB) {
        return leftValue.sub(rightValue);
      } else if (opcode == OPCODE_MUL) {
        return leftValue.mul(rightValue);
      } else if (opcode == OPCODE_DIV) {
        return leftValue.div(rightValue);
      } else if (opcode == OPCODE_EXP) {
        uint256 power = rightValue;
        uint256 expResult = 1;
        for (uint256 idx = 0; idx < power; ++idx) {
          expResult = expResult.mul(leftValue);
        }
        return expResult;
      }
    } else if (opcode == OPCODE_IF) {
      bool condValue = solveBool(self, node.child0, xValue);
      if (condValue) {
        return solveMath(self, node.child1, xValue);
      } else {
        return solveMath(self, node.child2, xValue);
      }
    }

    assert(false);
  }

  /**
   * @dev Calculate the arithmetic value of this sub-expression.
   */
  function solveBool(Node[] storage self, uint8 nodeIdx, uint256 xValue)
    private
    view
    returns (bool)
  {
    Node storage node = self[nodeIdx];
    uint8 opcode = node.opcode;

    if (opcode == OPCODE_NOT) {
      return !solveBool(self, node.child0, xValue);
    } else if (opcode >= OPCODE_EQ && opcode <= OPCODE_GE) {

      uint256 leftValue = solveMath(self, node.child0, xValue);
      uint256 rightValue = solveMath(self, node.child1, xValue);

      if (opcode == OPCODE_EQ) {
        return leftValue == rightValue;
      } else if (opcode == OPCODE_NE) {
        return leftValue != rightValue;
      } else if (opcode == OPCODE_LT) {
        return leftValue < rightValue;
      } else if (opcode == OPCODE_GT) {
        return leftValue > rightValue;
      } else if (opcode == OPCODE_LE) {
        return leftValue <= rightValue;
      } else if (opcode == OPCODE_GE) {
        return leftValue >= rightValue;
      }
    } else if (opcode >= OPCODE_AND && opcode <= OPCODE_OR) {

      bool leftBoolValue = solveBool(self, node.child0, xValue);
      bool rightBoolValue = solveBool(self, node.child1, xValue);

      if (opcode == OPCODE_AND) {
        return leftBoolValue && rightBoolValue;
      } else if (opcode == OPCODE_OR) {
        return leftBoolValue || rightBoolValue;
      }
    } else if (opcode == OPCODE_IF) {
      bool condValue = solveBool(self, node.child0, xValue);
      if (condValue) {
        return solveBool(self, node.child1, xValue);
      } else {
        return solveBool(self, node.child2, xValue);
      }
    }

    assert(false);
  }
}

// File: contracts/ParametersInterface.sol

/**
 * @title ParametersInterface
 */
interface ParametersInterface {

  /**
   * @dev Return the value at the given key. Throw if the value is not set.
   */
  function get(bytes32 key) external view returns (uint256);

  /**
   * @dev Similar to get function, but returns 0 instead of throwing.
   */
  function getZeroable(bytes32 key) external view returns (uint256);
}

// File: contracts/Proof.sol

/**
 * @title Proof
 *
 * @dev Proof library is a utility library for Merkle proof on sparse Merkle
 * tree. See https://ethresear.ch/t/optimizing-sparse-merkle-trees/3751.
 */
library Proof {

  /**
   * @dev Verify that the given key-value belongs to the merkle tree.
   * @param rootHash Merkle root hash
   * @param key The key (address) in Merkle tree
   * @param value The value that is claimed to be in the tree
   * @param proof Merkle tree proof
   */
  function verify(
    bytes32 rootHash,
    address key,
    bytes32 value,
    bytes32[] memory proof
  )
    internal
    pure
    returns (bool)
  {
    bytes32 currentLeaf = value;
    bytes32 anotherLeaf;

    uint256 proofIndex = 1;
    uint256 mask = uint256(proof[0]);

    for (uint256 i = 1; i < (1 << 160); i <<= 1) {
      if ((mask & i) > 0) {
        anotherLeaf = bytes32(0);
      } else {
        require(proofIndex < proof.length);
        anotherLeaf = proof[proofIndex];
        proofIndex++;
      }

      if ((uint(key) & i) == 0) {
        currentLeaf = hash(currentLeaf, anotherLeaf);
      } else {
        currentLeaf = hash(anotherLeaf, currentLeaf);
      }
    }

    require(currentLeaf == rootHash);
    require(proofIndex == proof.length);
    return true;
  }

  /**
   * @dev Similar to keccak256, but optimize to return 0 when hashing (0, 0)
   */
  function hash(bytes32 left, bytes32 right) private pure returns (bytes32) {
    if (left == bytes32(0) && right == bytes32(0)) {
      return bytes32(0);
    }
    return keccak256(abi.encodePacked(left, right));
  }
}

// File: contracts/CommunityCore.sol

/**
 * @title CommunityCore
 *
 * @dev Community Core contract keeps custody of community reward pool. It
 * allows community admins to report per period reward distribution. Anyone
 * can send transaction here to withdraw rewards. Community Core contract also
 * acts as the automated market maker, allowing anyone to buy/sell community
 * token with itself.
 */
contract CommunityCore is BandContractBase, ERC165 {
  using Equation for Equation.Node[];
  using SafeMath for uint256;
  using Proof for bytes32;

  event Buy(  // Someone buys community token
    address indexed buyer,
    uint256 amount,
    uint256 price
  );

  event Sell(  // Someone sells community token
    address indexed seller,
    uint256 amount,
    uint256 price,
    uint256 commissionCost
  );

  event Deflate(  // An admin burns community token to deflate the system
    address indexed admin,
    uint256 amount
  );

  event RewardDistributionSubmitted(  // A new reward distribution is submitted
    uint256 indexed rewardID,
    address indexed submitter,
    uint256 totalReward,
    uint256 totalPortion,
    bytes32 rewardPortionRootHash,
    uint256 activeAt
  );

  event RewardDistributionEditted( // An existing reward is modified
    uint256 indexed rewardID,
    address indexed editor,
    uint256 totalReward,
    uint256 totalPortion,
    bytes32 rewardPortionRootHash,
    uint256 activeAt
  );

  event RewardClaimed(  // Someone claims reward
    uint256 indexed rewardID,
    address indexed member,
    uint256 rewardPortion,
    uint256 amount
  );

  Equation.Node[] public equation;

  BandToken public bandToken;
  CommunityToken public commToken;
  ParametersInterface public params;

  // Denominator for inflation-related ratios and sales tax.
  uint256 public constant DENOMINATOR = 1e12;

  // Last time the auto-inflation was added to system. Auto-inflation happens
  // automatically everytime someone buys or sells tokens through bonding curve.
  uint256 public lastInflationTime;

  // Curve multiplier indicate the coefficient in front of the curve equation.
  // This allows contract to inflate or deflate the community token supply
  // without making the equation inconsistent with the number of collateralized
  // Band tokens.
  uint256 public curveMultiplier = DENOMINATOR;

  // Amount of Band that is currently collatoralized. Note that this may be
  // different from 'bandToken.balanceOf(this)' since someboday can arbitrarily
  // send Band to this contract. We don't want that to affect token price.
  // EIP-777, if finalized, will help with this.
  uint256 public currentBandCollatoralized = 0;

  // Most recent time that reward allocation was submitted to the contract.
  uint256 public lastRewardTime = 0;

  // Amount of token that is in this community core account, but is already
  // entitled to some users as reward.
  uint256 public unwithdrawnReward = 0;

  // ID of the next reward.
  uint256 public nextRewardID = 1;

  /**
   * @dev Reward struct to keep track of reward distribution/withdrawal for
   * a particular time period.
   */
  struct Reward {
    uint256 totalReward;
    uint256 totalPortion;
    bytes32 rewardPortionRootHash;
    uint256 activeAt;
    mapping (address => bool) claims;
  }

  mapping (uint256 => Reward) public rewards;

  /**
   * @dev Create community core contract.
   */
  constructor(
    BandToken _bandToken,
    CommunityToken _commToken,
    ParametersInterface _params,
    uint256[] memory _expressions
  )
    public
  {
    _registerInterface(this.buy.selector);
    _registerInterface(this.sell.selector);
    bandToken = _bandToken;
    commToken = _commToken;
    params = _params;
    equation.init(_expressions);
    lastInflationTime = now;
  }

  /**
   * @dev Throws if called by any account other than the admin.
   */
  modifier onlyAdmin() {
    AdminInterface admin = AdminInterface(params.get("core:admin_contract"));
    require(admin.isAdmin(msg.sender));
    _;
  }

  /**
   * @dev Calculate buy price for some amounts of tokens in Band
   */
  function getBuyPrice(uint256 amount) public view returns (uint256) {
    uint256 startSupply = commToken.totalSupply();
    uint256 endSupply = startSupply.add(amount);
    // The raw price as calculated from the difference between the starting and
    // ending positions.
    uint256 rawPrice =
      equation.calculate(endSupply).sub(equation.calculate(startSupply));
    // Price after adjusting inflation in.
    return rawPrice.mul(curveMultiplier).div(DENOMINATOR);
  }

  /**
   * @dev Calculate sell price for some amounts of tokens in Band
   */
  function getSellPrice(uint256 amount) public view returns (uint256) {
    uint256 startSupply = commToken.totalSupply();
    uint256 endSupply = startSupply.sub(amount);
    // The raw price as calcuated from the difference between the starting and
    // ending positions.
    uint256 rawPrice =
      equation.calculate(startSupply).sub(equation.calculate(endSupply));
    // Price after adjusting inflation in.
    return rawPrice.mul(curveMultiplier).div(DENOMINATOR);
  }

  /**
   * @dev Called by admins to report reward distribution over the past period.
   * @param rewardPortionRootHash Merkle root of the distribution tree.
   * @param totalPortion Total value of portion assignments (Merkle leaves)
   * of all community participants.
   */
  function addRewardDistribution(
    bytes32 rewardPortionRootHash,
    uint256 totalPortion
  )
    public
    onlyAdmin
  {
    uint256 rewardPeriod = params.get("core:reward_period");
    require(now >= lastRewardTime.add(rewardPeriod));

    _adjustAutoInflation();

    uint256 nonce = nextRewardID;
    nextRewardID = nonce.add(1);

    uint256 currentBalance = commToken.balanceOf(address(this));
    uint256 totalReward = currentBalance.sub(unwithdrawnReward);
    uint256 activeAt = now.add(params.get("core:reward_edit_period"));

    rewards[nonce] = Reward({
      totalReward: totalReward,
      totalPortion: totalPortion,
      rewardPortionRootHash: rewardPortionRootHash,
      activeAt: activeAt
    });

    lastRewardTime = now;
    unwithdrawnReward = currentBalance;

    emit RewardDistributionSubmitted(
      nonce,
      msg.sender,
      totalReward,
      totalPortion,
      rewardPortionRootHash,
      activeAt
    );
  }

  /**
   * @dev Called by admin to edit a not-yet-active reward distribution. After
   * being editted, the distribution active time will get pushed back by
   * 'reward_edit_period'.
   */
  function editRewardDistribution(
    uint256 rewardID,
    bytes32 rewardPortionRootHash,
    uint256 totalPortion
  )
    public
    onlyAdmin
  {
    require(rewardID > 0 && rewardID < nextRewardID);
    Reward storage reward = rewards[rewardID];
    require(now < reward.activeAt);
    uint256 activeAt = now.add(params.get("core:reward_edit_period"));
    reward.totalPortion = totalPortion;
    reward.rewardPortionRootHash = rewardPortionRootHash;
    reward.activeAt = activeAt;

    emit RewardDistributionSubmitted(
      rewardID,
      msg.sender,
      reward.totalReward,
      totalPortion,
      rewardPortionRootHash,
      activeAt
    );
  }

  /**
   * @dev Called by anyone in the community to withdraw rewards.
   * @param beneficiary The address to receive the rewards.
   * @param rewardID The reward to withdraw.
   * @param rewardPortion The value at the leaf node of the sender.
   * @param proof Merkle proof consistent with the reward's root hash.
   */
  function claimReward(
    address beneficiary,
    uint256 rewardID,
    uint256 rewardPortion,
    bytes32[] calldata proof
  )
    external
  {
    require(rewardID > 0 && rewardID < nextRewardID);
    Reward storage reward = rewards[rewardID];
    require(now >= reward.activeAt);
    require(!reward.claims[beneficiary]);
    reward.claims[beneficiary] = true;

    require(reward.rewardPortionRootHash.verify(
      beneficiary,
      bytes32(rewardPortion),
      proof
    ));

    uint256 userReward =
      reward.totalReward.mul(rewardPortion).div(reward.totalPortion);

    unwithdrawnReward = unwithdrawnReward.sub(userReward);
    require(commToken.transfer(beneficiary, userReward));
    emit RewardClaimed(rewardID, beneficiary, rewardPortion, userReward);
  }

  /**
   * @dev Deflate the community token by burning tokens from the given admin.
   * curveMultiplier will adjust up to make the equation is consistent.
   */
  function deflate(uint256 amount) public onlyAdmin {
    require(commToken.burn(msg.sender, amount));
    _adjustcurveMultiplier();
    emit Deflate(msg.sender, amount);
  }

  /**
   * @dev Buy some amount of tokens with Band. Must be called by BandToken
   * contract after `bandAmount` BANDs have been transferred to this contract.
   * Revert if bandAmount is not sufficient. Return extra BANDs back to buyer
   * if the buyer pays too much.
   */
  function buy(address buyer, uint256 priceLimit, uint256 commAmount)
    external
    onlyFrom(address(bandToken))
  {
    _adjustAutoInflation();
    uint256 adjustedPrice = getBuyPrice(commAmount);
    require(adjustedPrice != 0 && adjustedPrice <= priceLimit);
    require(commToken.mint(buyer, commAmount));
    if (priceLimit > adjustedPrice) {
      require(bandToken.transfer(buyer, priceLimit.sub(adjustedPrice)));
    }
    currentBandCollatoralized = currentBandCollatoralized.add(adjustedPrice);
    emit Buy(buyer, commAmount, adjustedPrice);
  }

  /**
   * @dev Sell some amount of tokens for Band. Must be called by CommToken
   * contract after `commAmount` tokens have been transferred to this contract.
   * Revert if sell price is less than `priceLimit`. Some tokens are treated
   * as `commissions` and stay with this contract; the remaining get burnt.
   */
  function sell(address seller, uint256 commAmount, uint256 priceLimit)
    external
    onlyFrom(address(commToken))
  {
    _adjustAutoInflation();
    uint256 salesCommission = params.getZeroable("core:sales_commission");
    require(salesCommission <= DENOMINATOR);
    uint256 commissionCost = commAmount.mul(salesCommission).div(DENOMINATOR);
    uint256 adjustedPrice = getSellPrice(commAmount.sub(commissionCost));
    require(adjustedPrice != 0 && adjustedPrice >= priceLimit);
    if (commissionCost != commAmount) {
      require(commToken.burn(address(this), commAmount.sub(commissionCost)));
    }
    require(bandToken.transfer(seller, adjustedPrice));
    currentBandCollatoralized = currentBandCollatoralized.sub(adjustedPrice);
    emit Sell(seller, commAmount, adjustedPrice, commissionCost);
  }

  /**
   * @dev Auto inflate token supply per `inflation_ratio` parameter. This
   * function is expected to be called prior to any buy/sell/rewardDistribution.
   */
  function _adjustAutoInflation() private {
    uint256 currentSupply = commToken.totalSupply();
    if (currentSupply != 0) {
      uint256 inflationRatio = params.getZeroable("core:inflation_ratio");
      uint256 pastSeconds = now.sub(lastInflationTime);
      uint256 inflatedSupply =
        currentSupply.mul(pastSeconds).mul(inflationRatio).div(DENOMINATOR);

      if (inflatedSupply != 0) {
        require(commToken.mint(address(this), inflatedSupply));
        _adjustcurveMultiplier();
      }
    }
    lastInflationTime = now;
  }

  /**
   * @dev Adjust the inflation ratio to match the new comm token supply.
   */
  function _adjustcurveMultiplier() private {
    uint256 eqCollateral = equation.calculate(commToken.totalSupply());
    require(currentBandCollatoralized != 0);
    require(eqCollateral != 0);
    curveMultiplier =
      DENOMINATOR.mul(currentBandCollatoralized).div(eqCollateral);
    assert(
      eqCollateral.mul(curveMultiplier).div(DENOMINATOR) <=
      currentBandCollatoralized
    );
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
    Inconclusive  // The poll is resolved, with result No.
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
interface VotingInterface {

  event PollResolved(  // A poll is resolved.
    address indexed pollContract,
    uint256 indexed pollID,
    ResolveListener.PollState pollState
  );

  /**
   * Start a new poll for the function caller.
   */
  function startPoll(
    CommunityToken token,
    uint256 pollID,
    bytes8 prefix,
    ParametersInterface params
  )
    external
    returns (bool);

  /**
   * Return the current vote score for a specific poll.
   */
  function getPollTotalVote(address pollContract, uint256 pollID)
    external
    view
    returns (uint256 yesCount, uint256 noCount);

  /**
   * Return the vote allocation for the given voter.
   */
  function getPollUserVote(address pollContract, uint256 pollID, address voter)
    external
    view
    returns (uint256 yesCount, uint256 noCount);
}

// File: contracts/Parameters.sol

/*
 * @title Parameters
 *
 * @dev Parameter contract is a one-per-community contract that maintains
 * configuration of everything in the community, including inflation rate,
 * vote quorums, proposal expiration timeout, etc.
 */
contract Parameters is BandContractBase, ParametersInterface, ResolveListener {
  using SafeMath for uint256;

  event ProposalProposed(  // A new proposal is proposed.
    uint256 indexed proposalID,
    address indexed proposer
  );

  event ProposalAccepted( // A proposol is accepted.
    uint256 indexed proposalID
  );

  event ProposalRejected( // A proposol is rejected.
    uint256 indexed proposalID
  );

  event ParameterInit(  // A parameter is initialized during contract creation.
    bytes32 indexed key,
    uint256 value
  );

  event ParameterProposed(  // A parameter change is proposed.
    uint256 indexed proposalID,
    bytes32 indexed key,
    uint256 value
  );

  CommunityToken public token;
  VotingInterface public voting;

  // Public map of all active parameters.
  mapping (bytes32 => uint256) public params;

  struct KeyValue {
    bytes32 key;
    uint256 value;
  }

  /**
   * @dev Proposal struct for each of the proposal change that is proposed to
   * this contract.
   */
  struct Proposal {
    uint256 changeCount;
    mapping (uint256 => KeyValue) changes;
  }

  uint256 public nextProposalNonce = 1;
  mapping (uint256 => Proposal) public proposals;

  /**
   * @dev Create parameters contract. Initially set of key-value pairs can be
   * given in this constructor.
   */
  constructor(
    CommunityToken _token,
    VotingInterface _voting,
    bytes32[] memory keys,
    uint256[] memory values
  )
    public
  {
    token = _token;
    voting = _voting;

    require(keys.length == values.length);
    for (uint256 idx = 0; idx < keys.length; ++idx) {
      params[keys[idx]] = values[idx];
      emit ParameterInit(keys[idx], values[idx]);
    }

    require(get("params:commit_time") > 0);
    require(get("params:reveal_time") > 0);
    require(get("params:min_participation_pct") <= 100);
    require(get("params:support_required_pct") <= 100);
  }

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

  /**
   * @dev Return the 'changeIndex'^th change of the given proposal.
   */
  function getProposalChange(uint256 proposalID, uint256 changeIndex)
    public
    view
    returns (bytes32, uint256)
  {
    KeyValue memory keyValue = proposals[proposalID].changes[changeIndex];
    return (keyValue.key, keyValue.value);
  }

  /**
   * @dev Propose a set of new key-value changes.
   */
  function propose(bytes32[] calldata keys, uint256[] calldata values)
    external
    returns (uint256)
  {
    require(keys.length == values.length);
    uint256 proposalID = nextProposalNonce;
    nextProposalNonce = proposalID.add(1);

    emit ProposalProposed(
      proposalID,
      msg.sender
    );
    proposals[proposalID].changeCount = keys.length;
    for (uint256 index = 0; index < keys.length; ++index) {
      bytes32 key = keys[index];
      uint256 value = values[index];
      emit ParameterProposed(proposalID, key, value);
      proposals[proposalID].changes[index] = KeyValue(key, value);
    }
    require(
      voting.startPoll(
        token,
        proposalID,
        "params:",
        this
      )
    );
    return proposalID;
  }

  /**
   * @dev Called by the voting contract once the poll is resolved.
   */
  function onResolved(uint256 proposalID, PollState pollState)
    public
    onlyFrom(address(voting))
    returns (bool)
  {
    Proposal storage proposal = proposals[proposalID];
    if (pollState == PollState.Yes) {
      for (uint256 index = 0; index < proposal.changeCount; ++index) {
        bytes32 key = proposal.changes[index].key;
        uint256 value = proposal.changes[index].value;
        params[key] = value;
      }
      emit ProposalAccepted(proposalID);
    } else {
      emit ProposalRejected(proposalID);
    }
    return true;
  }
}

// File: contracts/factory/TokenFactory.sol

contract TokenFactory{
  function create(
    string calldata _name,
    string calldata _symbol,
    uint8 _decimals
  )
    external
    returns(CommunityToken)
  {
    CommunityToken token = new CommunityToken(_name, _symbol, _decimals);
    token.transferOwnership(msg.sender);
    return token;
  }
}

// File: contracts/factory/ParametersFactory.sol

contract ParametersFactory{
  function create(
    CommunityToken _token,
    VotingInterface _voting,
    bytes32[] calldata _keys,
    uint256[] calldata _values
  )
    external
    returns(Parameters)
  {
    return new Parameters(_token, _voting, _keys, _values);
  }
}

// File: contracts/factory/CoreFactory.sol

contract CoreFactory{
  function create(
    BandToken _bandToken,
    CommunityToken _commToken,
    ParametersInterface _params,
    uint256[] calldata _expressions
  )
    external
    returns(CommunityCore)
  {
    return new CommunityCore(_bandToken, _commToken, _params, _expressions);
  }
}

// File: contracts/BandFactory.sol

contract BandFactory is Ownable {
  event BandCreated(
    address bandAddress,
    address indexed owner,
    uint256 totalSupply
  );

  event CommunityCreated(
    uint256 nonce,
    address token,
    address parameter,
    address core
  );

  event NewVotingContractRegistered(
    address indexed voting
  );

  event VotingContractRemoved(
    address indexed voting
  );

  BandToken public band;
  CommunityCore[] public cores;

  TokenFactory public tokenFactory;
  ParametersFactory public parametersFactory;
  CoreFactory public coreFactory;

  mapping (address => bool) public verifiedVotingContracts;

  constructor(
    uint256 _totalSupply,
    TokenFactory _tokenFactory,
    ParametersFactory _parametersFactory,
    CoreFactory _coreFactory
  )
    public
  {
    band = new BandToken(_totalSupply, msg.sender);
    tokenFactory = _tokenFactory;
    parametersFactory = _parametersFactory;
    coreFactory = _coreFactory;

    emit BandCreated(address(band), msg.sender, _totalSupply);
  }

  function createNewCommunity(
    string calldata _name,
    string calldata _symbol,
    uint8 _decimals,
    VotingInterface _voting,
    bytes32[] calldata _keys,
    uint256[] calldata _values,
    uint256[] calldata _expressions
  )
    external
    returns(bool)
  {
    require(verifiedVotingContracts[address(_voting)]);
    CommunityToken token = tokenFactory.create(_name, _symbol, _decimals);
    Parameters params = parametersFactory.create(token, _voting, _keys, _values);
    CommunityCore core = coreFactory.create(band, token, params, _expressions);

    token.transferOwnership(address(core));
    cores.push(core);

    emit CommunityCreated(
      cores.length - 1,
      address(token),
      address(params),
      address(core));
    return true;
  }

  function addVotingContract(VotingInterface _voting)
    public
    onlyOwner
    returns(bool)
  {
    require(!verifiedVotingContracts[address(_voting)]);
    verifiedVotingContracts[address(_voting)] = true;
    emit NewVotingContractRegistered(address(_voting));
    return true;
  }

  function removeVotingContract(VotingInterface _voting)
    public
    onlyOwner
    returns(bool)
  {
    require(verifiedVotingContracts[address(_voting)]);
    verifiedVotingContracts[address(_voting)] = false;
    emit VotingContractRemoved(address(_voting));
    return true;
  }
}
