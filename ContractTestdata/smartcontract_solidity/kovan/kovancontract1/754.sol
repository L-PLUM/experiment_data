/**
 *Submitted for verification at Etherscan.io on 2019-01-09
*/

pragma solidity ^0.5.2;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: @daostack/infra/contracts/Reputation.sol

/**
 * @title Reputation system
 * @dev A DAO has Reputation System which allows peers to rate other peers in order to build trust .
 * A reputation is use to assign influence measure to a DAO'S peers.
 * Reputation is similar to regular tokens but with one crucial difference: It is non-transferable.
 * The Reputation contract maintain a map of address to reputation value.
 * It provides an onlyOwner functions to mint and burn reputation _to (or _from) a specific address.
 */

contract Reputation is Ownable {

    uint8 public decimals = 18;             //Number of decimals of the smallest unit
    // Event indicating minting of reputation to an address.
    event Mint(address indexed _to, uint256 _amount);
    // Event indicating burning of reputation for an address.
    event Burn(address indexed _from, uint256 _amount);

      /// @dev `Checkpoint` is the structure that attaches a block number to a
      ///  given value, the block number attached is the one that last changed the
      ///  value
    struct Checkpoint {

    // `fromBlock` is the block number that the value was generated from
        uint128 fromBlock;

          // `value` is the amount of reputation at a specific block number
        uint128 value;
    }

      // `balances` is the map that tracks the balance of each address, in this
      //  contract when the balance changes the block number that the change
      //  occurred is also included in the map
    mapping (address => Checkpoint[]) balances;

      // Tracks the history of the `totalSupply` of the reputation
    Checkpoint[] totalSupplyHistory;

    /// @notice Constructor to create a Reputation
    constructor(
    ) public
    {
    }

    /// @dev This function makes it easy to get the total number of reputation
    /// @return The total number of reputation
    function totalSupply() public view returns (uint256) {
        return totalSupplyAt(block.number);
    }

  ////////////////
  // Query balance and totalSupply in History
  ////////////////
    /**
    * @dev return the reputation amount of a given owner
    * @param _owner an address of the owner which we want to get his reputation
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balanceOfAt(_owner, block.number);
    }

      /// @dev Queries the balance of `_owner` at a specific `_blockNumber`
      /// @param _owner The address from which the balance will be retrieved
      /// @param _blockNumber The block number when the balance is queried
      /// @return The balance at `_blockNumber`
    function balanceOfAt(address _owner, uint256 _blockNumber)
    public view returns (uint256)
    {
        if ((balances[_owner].length == 0) || (balances[_owner][0].fromBlock > _blockNumber)) {
            return 0;
          // This will return the expected balance during normal situations
        } else {
            return getValueAt(balances[_owner], _blockNumber);
        }
    }

      /// @notice Total amount of reputation at a specific `_blockNumber`.
      /// @param _blockNumber The block number when the totalSupply is queried
      /// @return The total amount of reputation at `_blockNumber`
    function totalSupplyAt(uint256 _blockNumber) public view returns(uint256) {
        if ((totalSupplyHistory.length == 0) || (totalSupplyHistory[0].fromBlock > _blockNumber)) {
            return 0;
          // This will return the expected totalSupply during normal situations
        } else {
            return getValueAt(totalSupplyHistory, _blockNumber);
        }
    }

      /// @notice Generates `_amount` reputation that are assigned to `_owner`
      /// @param _user The address that will be assigned the new reputation
      /// @param _amount The quantity of reputation generated
      /// @return True if the reputation are generated correctly
    function mint(address _user, uint256 _amount) public onlyOwner returns (bool) {
        uint256 curTotalSupply = totalSupply();
        require(curTotalSupply + _amount >= curTotalSupply); // Check for overflow
        uint256 previousBalanceTo = balanceOf(_user);
        require(previousBalanceTo + _amount >= previousBalanceTo); // Check for overflow
        updateValueAtNow(totalSupplyHistory, curTotalSupply + _amount);
        updateValueAtNow(balances[_user], previousBalanceTo + _amount);
        emit Mint(_user, _amount);
        return true;
    }

      /// @notice Burns `_amount` reputation from `_owner`
      /// @param _user The address that will lose the reputation
      /// @param _amount The quantity of reputation to burn
      /// @return True if the reputation are burned correctly
    function burn(address _user, uint256 _amount) public onlyOwner returns (bool) {
        uint256 curTotalSupply = totalSupply();
        uint256 amountBurned = _amount;
        uint256 previousBalanceFrom = balanceOf(_user);
        if (previousBalanceFrom < amountBurned) {
            amountBurned = previousBalanceFrom;
        }
        updateValueAtNow(totalSupplyHistory, curTotalSupply - amountBurned);
        updateValueAtNow(balances[_user], previousBalanceFrom - amountBurned);
        emit Burn(_user, amountBurned);
        return true;
    }

  ////////////////
  // Internal helper functions to query and set a value in a snapshot array
  ////////////////

      /// @dev `getValueAt` retrieves the number of reputation at a given block number
      /// @param checkpoints The history of values being queried
      /// @param _block The block number to retrieve the value at
      /// @return The number of reputation being queried
    function getValueAt(Checkpoint[] storage checkpoints, uint256 _block) internal view returns (uint256) {
        if (checkpoints.length == 0) {
            return 0;
        }

          // Shortcut for the actual value
        if (_block >= checkpoints[checkpoints.length-1].fromBlock) {
            return checkpoints[checkpoints.length-1].value;
        }
        if (_block < checkpoints[0].fromBlock) {
            return 0;
        }

          // Binary search of the value in the array
        uint256 min = 0;
        uint256 max = checkpoints.length-1;
        while (max > min) {
            uint256 mid = (max + min + 1) / 2;
            if (checkpoints[mid].fromBlock<=_block) {
                min = mid;
            } else {
                max = mid-1;
            }
        }
        return checkpoints[min].value;
    }

      /// @dev `updateValueAtNow` used to update the `balances` map and the
      ///  `totalSupplyHistory`
      /// @param checkpoints The history of data being updated
      /// @param _value The new number of reputation
    function updateValueAtNow(Checkpoint[] storage checkpoints, uint256 _value) internal {
        require(uint128(_value) == _value); //check value is in the 128 bits bounderies
        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length - 1].fromBlock < block.number)) {
            Checkpoint storage newCheckPoint = checkpoints[checkpoints.length++];
            newCheckPoint.fromBlock = uint128(block.number);
            newCheckPoint.value = uint128(_value);
        } else {
            Checkpoint storage oldCheckPoint = checkpoints[checkpoints.length-1];
            oldCheckPoint.value = uint128(_value);
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

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    int256 constant private INT256_MIN = -2**255;

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
    * @dev Multiplies two signed integers, reverts on overflow.
    */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
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
    * @dev Integer division of two signed integers truncating the quotient, reverts on division by zero.
    */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

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
    * @dev Subtracts two signed integers, reverts on overflow.
    */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

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
    * @dev Adds two signed integers, reverts on overflow.
    */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol

/**
 * @title Burnable Token
 * @dev Token that can be irreversibly burned (destroyed).
 */
contract ERC20Burnable is ERC20 {
    /**
     * @dev Burns a specific amount of tokens.
     * @param value The amount of token to be burned.
     */
    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    /**
     * @dev Burns a specific amount of tokens from the target address and decrements allowance
     * @param from address The address which you want to send tokens from
     * @param value uint256 The amount of token to be burned
     */
    function burnFrom(address from, uint256 value) public {
        _burnFrom(from, value);
    }
}

// File: contracts/controller/DAOToken.sol

/**
 * @title DAOToken, base on zeppelin contract.
 * @dev ERC20 compatible token. It is a mintable, destructible, burnable token.
 */

contract DAOToken is ERC20, ERC20Burnable, Ownable {

    string public name;
    string public symbol;
    // solhint-disable-next-line const-name-snakecase
    uint8 public constant decimals = 18;
    uint256 public cap;

    /**
    * @dev Constructor
    * @param _name - token name
    * @param _symbol - token symbol
    * @param _cap - token cap - 0 value means no cap
    */
    constructor(string memory _name, string memory _symbol, uint256 _cap)
    public {
        name = _name;
        symbol = _symbol;
        cap = _cap;
    }

    /**
     * @dev Function to mint tokens
     * @param _to The address that will receive the minted tokens.
     * @param _amount The amount of tokens to mint.
     */
    function mint(address _to, uint256 _amount) public onlyOwner returns (bool) {
        if (cap > 0)
            require(totalSupply().add(_amount) <= cap);
        _mint(_to, _amount);
        return true;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

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

// File: contracts/controller/Avatar.sol

/**
 * @title An Avatar holds tokens, reputation and ether for a controller
 */
contract Avatar is Ownable {
    using SafeERC20 for ERC20;

    string public orgName;
    DAOToken public nativeToken;
    Reputation public nativeReputation;

    event GenericCall(address indexed _contract, bytes _params, bool _success);
    event SendEther(uint256 _amountInWei, address indexed _to);
    event ExternalTokenTransfer(address indexed _externalToken, address indexed _to, uint256 _value);
    event ExternalTokenTransferFrom(address indexed _externalToken, address _from, address _to, uint256 _value);
    event ExternalTokenApproval(ERC20 indexed _externalToken, address _spender, uint256 _value);
    event ReceiveEther(address indexed _sender, uint256 _value);

    /**
    * @dev the constructor takes organization name, native token and reputation system
    and creates an avatar for a controller
    */
    constructor(string memory _orgName, DAOToken _nativeToken, Reputation _nativeReputation) public {
        orgName = _orgName;
        nativeToken = _nativeToken;
        nativeReputation = _nativeReputation;
    }

    /**
    * @dev enables an avatar to receive ethers
    */
    function() external payable {
        emit ReceiveEther(msg.sender, msg.value);
    }

    /**
    * @dev perform a generic call to an arbitrary contract
    * @param _contract  the contract's address to call
    * @param _data ABI-encoded contract call to call `_contract` address.
    * @return bool    success or fail
    *         bytes - the return bytes of the called contract's function.
    */
    function genericCall(address _contract, bytes memory _data)
    public
    onlyOwner
    returns(bool success, bytes memory returnValue) {
      // solhint-disable-next-line avoid-low-level-calls
        (success, returnValue) = _contract.call(_data);
        emit GenericCall(_contract, _data, success);
    }

    /**
    * @dev send ethers from the avatar's wallet
    * @param _amountInWei amount to send in Wei units
    * @param _to send the ethers to this address
    * @return bool which represents success
    */
    function sendEther(uint256 _amountInWei, address payable _to) public onlyOwner returns(bool) {
        _to.transfer(_amountInWei);
        emit SendEther(_amountInWei, _to);
        return true;
    }

    /**
    * @dev external token transfer
    * @param _externalToken the token contract
    * @param _to the destination address
    * @param _value the amount of tokens to transfer
    * @return bool which represents success
    */
    function externalTokenTransfer(ERC20 _externalToken, address _to, uint256 _value)
    public onlyOwner returns(bool)
    {
        _externalToken.safeTransfer(_to, _value);
        emit ExternalTokenTransfer(address(_externalToken), _to, _value);
        return true;
    }

    /**
    * @dev external token transfer from a specific account
    * @param _externalToken the token contract
    * @param _from the account to spend token from
    * @param _to the destination address
    * @param _value the amount of tokens to transfer
    * @return bool which represents success
    */
    function externalTokenTransferFrom(
        ERC20 _externalToken,
        address _from,
        address _to,
        uint256 _value
    )
    public onlyOwner returns(bool)
    {
        _externalToken.safeTransferFrom(_from, _to, _value);
        emit ExternalTokenTransferFrom(address(_externalToken), _from, _to, _value);
        return true;
    }

    /**
    * @dev externalTokenApproval approve the spender address to spend a specified amount of tokens
    *      on behalf of msg.sender.
    * @param _externalToken the address of the Token Contract
    * @param _spender address
    * @param _value the amount of ether (in Wei) which the approval is referring to.
    * @return bool which represents a success
    */
    function externalTokenApproval(ERC20 _externalToken, address _spender, uint256 _value)
    public onlyOwner returns(bool)
    {
        require(_externalToken.approve(_spender, _value), "approve must succeed");
        emit ExternalTokenApproval(_externalToken, _spender, _value);
        return true;
    }

}

// File: contracts/globalConstraints/GlobalConstraintInterface.sol

contract GlobalConstraintInterface {

    enum CallPhase { Pre, Post, PreAndPost }

    function pre( address _scheme, bytes32 _params, bytes32 _method ) public returns(bool);
    function post( address _scheme, bytes32 _params, bytes32 _method ) public returns(bool);
    /**
     * @dev when return if this globalConstraints is pre, post or both.
     * @return CallPhase enum indication  Pre, Post or PreAndPost.
     */
    function when() public returns(CallPhase);
}

// File: contracts/controller/ControllerInterface.sol

/**
 * @title Controller contract
 * @dev A controller controls the organizations tokens ,reputation and avatar.
 * It is subject to a set of schemes and constraints that determine its behavior.
 * Each scheme has it own parameters and operation permissions.
 */
interface ControllerInterface {

    /**
     * @dev Mint `_amount` of reputation that are assigned to `_to` .
     * @param  _amount amount of reputation to mint
     * @param _to beneficiary address
     * @return bool which represents a success
    */
    function mintReputation(uint256 _amount, address _to, address _avatar)
    external
    returns(bool);

    /**
     * @dev Burns `_amount` of reputation from `_from`
     * @param _amount amount of reputation to burn
     * @param _from The address that will lose the reputation
     * @return bool which represents a success
     */
    function burnReputation(uint256 _amount, address _from, address _avatar)
    external
    returns(bool);

    /**
     * @dev mint tokens .
     * @param  _amount amount of token to mint
     * @param _beneficiary beneficiary address
     * @param _avatar address
     * @return bool which represents a success
     */
    function mintTokens(uint256 _amount, address _beneficiary, address _avatar)
    external
    returns(bool);

  /**
   * @dev register or update a scheme
   * @param _scheme the address of the scheme
   * @param _paramsHash a hashed configuration of the usage of the scheme
   * @param _permissions the permissions the new scheme will have
   * @param _avatar address
   * @return bool which represents a success
   */
    function registerScheme(address _scheme, bytes32 _paramsHash, bytes4 _permissions, address _avatar)
    external
    returns(bool);

    /**
     * @dev unregister a scheme
     * @param _avatar address
     * @param _scheme the address of the scheme
     * @return bool which represents a success
     */
    function unregisterScheme(address _scheme, address _avatar)
    external
    returns(bool);

    /**
     * @dev unregister the caller's scheme
     * @param _avatar address
     * @return bool which represents a success
     */
    function unregisterSelf(address _avatar) external returns(bool);

    /**
     * @dev add or update Global Constraint
     * @param _globalConstraint the address of the global constraint to be added.
     * @param _params the constraint parameters hash.
     * @param _avatar the avatar of the organization
     * @return bool which represents a success
     */
    function addGlobalConstraint(address _globalConstraint, bytes32 _params, address _avatar)
    external returns(bool);

    /**
     * @dev remove Global Constraint
     * @param _globalConstraint the address of the global constraint to be remove.
     * @param _avatar the organization avatar.
     * @return bool which represents a success
     */
    function removeGlobalConstraint (address _globalConstraint, address _avatar)
    external  returns(bool);

  /**
    * @dev upgrade the Controller
    *      The function will trigger an event 'UpgradeController'.
    * @param  _newController the address of the new controller.
    * @param _avatar address
    * @return bool which represents a success
    */
    function upgradeController(address _newController, Avatar _avatar)
    external returns(bool);

    /**
    * @dev perform a generic call to an arbitrary contract
    * @param _contract  the contract's address to call
    * @param _data ABI-encoded contract call to call `_contract` address.
    * @param _avatar the controller's avatar address
    * @return bool -success
    *         bytes  - the return value of the called _contract's function.
    */
    function genericCall(address _contract, bytes calldata _data, Avatar _avatar)
    external
    returns(bool, bytes memory);

  /**
   * @dev send some ether
   * @param _amountInWei the amount of ether (in Wei) to send
   * @param _to address of the beneficiary
   * @param _avatar address
   * @return bool which represents a success
   */
    function sendEther(uint256 _amountInWei, address payable _to, Avatar _avatar)
    external returns(bool);

    /**
    * @dev send some amount of arbitrary ERC20 Tokens
    * @param _externalToken the address of the Token Contract
    * @param _to address of the beneficiary
    * @param _value the amount of ether (in Wei) to send
    * @param _avatar address
    * @return bool which represents a success
    */
    function externalTokenTransfer(ERC20 _externalToken, address _to, uint256 _value, Avatar _avatar)
    external
    returns(bool);

    /**
    * @dev transfer token "from" address "to" address
    *      One must to approve the amount of tokens which can be spend from the
    *      "from" account.This can be done using externalTokenApprove.
    * @param _externalToken the address of the Token Contract
    * @param _from address of the account to send from
    * @param _to address of the beneficiary
    * @param _value the amount of ether (in Wei) to send
    * @param _avatar address
    * @return bool which represents a success
    */
    function externalTokenTransferFrom(ERC20 _externalToken, address _from, address _to, uint256 _value, Avatar _avatar)
    external
    returns(bool);

    /**
    * @dev externalTokenApproval approve the spender address to spend a specified amount of tokens
    *      on behalf of msg.sender.
    * @param _externalToken the address of the Token Contract
    * @param _spender address
    * @param _value the amount of ether (in Wei) which the approval is referring to.
    * @return bool which represents a success
    */
    function externalTokenApproval(ERC20 _externalToken, address _spender, uint256 _value, Avatar _avatar)
    external
    returns(bool);

    /**
     * @dev getNativeReputation
     * @param _avatar the organization avatar.
     * @return organization native reputation
     */
    function getNativeReputation(address _avatar)
    external
    view
    returns(address);

    function isSchemeRegistered( address _scheme, address _avatar) external view returns(bool);

    function getSchemeParameters(address _scheme, address _avatar) external view returns(bytes32);

    function getGlobalConstraintParameters(address _globalConstraint, address _avatar) external view returns(bytes32);

    function getSchemePermissions(address _scheme, address _avatar) external view returns(bytes4);

    /**
     * @dev globalConstraintsCount return the global constraint pre and post count
     * @return uint256 globalConstraintsPre count.
     * @return uint256 globalConstraintsPost count.
     */
    function globalConstraintsCount(address _avatar) external view returns(uint, uint);

    function isGlobalConstraintRegistered(address _globalConstraint, address _avatar) external view returns(bool);
}

// File: contracts/libs/RealMath.sol

/**
 * RealMath: fixed-point math library, based on fractional and integer parts.
 * Using int256 as real216x40, which isn't in Solidity yet.
 * 40 fractional bits gets us down to 1E-12 precision, while still letting us
 * go up to galaxy scale counting in meters.
 * Internally uses the wider int256 for some math.
 *
 * Note that for addition, subtraction, and mod (%), you should just use the
 * built-in Solidity operators. Functions for these operations are not provided.
 *
 * Note that the fancy functions like sqrt, atan2, etc. aren't as accurate as
 * they should be. They are (hopefully) Good Enough for doing orbital mechanics
 * on block timescales in a game context, but they may not be good enough for
 * other applications.
 */


library RealMath {

    /**
     * How many total bits are there?
     */
    int256 constant private REAL_BITS = 256;

    /**
     * How many fractional bits are there?
     */
    int256 constant private REAL_FBITS = 40;

    /**
     * How many integer bits are there?
     */
    int256 constant private REAL_IBITS = REAL_BITS - REAL_FBITS;

    /**
     * What's the first non-fractional bit
     */
    int256 constant private REAL_ONE = int256(1) << REAL_FBITS;

    /**
     * What's the last fractional bit?
     */
    int256 constant private REAL_HALF = REAL_ONE >> 1;

    /**
     * What's two? Two is pretty useful.
     */
    int256 constant private REAL_TWO = REAL_ONE << 1;

    /**
     * And our logarithms are based on ln(2).
     */
    int256 constant private REAL_LN_TWO = 762123384786;

    /**
     * It is also useful to have Pi around.
     */
    int256 constant private REAL_PI = 3454217652358;

    /**
     * And half Pi, to save on divides.
     * TODO: That might not be how the compiler handles constant privates.
     */
    int256 constant private REAL_HALF_PI = 1727108826179;

    /**
     * And two pi, which happens to be odd in its most accurate representation.
     */
    int256 constant private REAL_TWO_PI = 6908435304715;

    /**
     * What's the sign bit?
     */
    int256 constant private SIGN_MASK = int256(1) << 255;

    /**
     * Convert an integer to a real. Preserves sign.
     */
    function toReal(int216 ipart) internal pure returns (int256) {
        return int256(ipart) * REAL_ONE;
    }

    /**
     * Convert a real to an integer. Preserves sign.
     */
    function fromReal(int256 realValue) internal pure returns (int216) {
        return int216(realValue / REAL_ONE);
    }

    /**
     * Round a real to the nearest integral real value.
     */
    function round(int256 realValue) internal pure returns (int256) {
        // First, truncate.
        int216 ipart = fromReal(realValue);
        if ((fractionalBits(realValue) & (uint40(1) << (REAL_FBITS - 1))) > 0) {
            // High fractional bit is set. Round up.
            if (realValue < int256(0)) {
                // Rounding up for a negative number is rounding down.
                ipart -= 1;
            } else {
                ipart += 1;
            }
        }
        return toReal(ipart);
    }

    /**
     * Get the absolute value of a real. Just the same as abs on a normal int256.
     */
    function abs(int256 realValue) internal pure returns (int256) {
        if (realValue > 0) {
            return realValue;
        } else {
            return -realValue;
        }
    }

    /**
     * Returns the fractional bits of a real. Ignores the sign of the real.
     */
    function fractionalBits(int256 realValue) internal pure returns (uint40) {
        return uint40(abs(realValue) % REAL_ONE);
    }

    /**
     * Get the fractional part of a real, as a real. Ignores sign (so fpart(-0.5) is 0.5).
     */
    function fpart(int256 realValue) internal pure returns (int256) {
        // This gets the fractional part but strips the sign
        return abs(realValue) % REAL_ONE;
    }

    /**
     * Get the fractional part of a real, as a real. Respects sign (so fpartSigned(-0.5) is -0.5).
     */
    function fpartSigned(int256 realValue) internal pure returns (int256) {
        // This gets the fractional part but strips the sign
        int256 fractional = fpart(realValue);
        if (realValue < 0) {
            // Add the negative sign back in.
            return -fractional;
        } else {
            return fractional;
        }
    }

    /**
     * Get the integer part of a fixed point value.
     */
    function ipart(int256 realValue) internal pure returns (int256) {
        // Subtract out the fractional part to get the real part.
        return realValue - fpartSigned(realValue);
    }

    /**
     * Multiply one real by another. Truncates overflows.
     */
    function mul(int256 realA, int256 realB) internal pure returns (int256) {
        // When multiplying fixed point in x.y and z.w formats we get (x+z).(y+w) format.
        // So we just have to clip off the extra REAL_FBITS fractional bits.
        return int256((int256(realA) * int256(realB)) >> REAL_FBITS);
    }

    /**
     * Divide one real by another real. Truncates overflows.
     */
    function div(int256 realNumerator, int256 realDenominator) internal pure returns (int256) {
        // We use the reverse of the multiplication trick: convert numerator from
        // x.y to (x+z).(y+w) fixed point, then divide by denom in z.w fixed point.
        return int256((int256(realNumerator) * REAL_ONE) / int256(realDenominator));
    }

    /**
     * Create a real from a rational fraction.
     */
    function fraction(int216 numerator, int216 denominator) internal pure returns (int256) {
        return div(toReal(numerator), toReal(denominator));
    }

    // Now we have some fancy math things (like pow and trig stuff). This isn't
    // in the RealMath that was deployed with the original Macroverse
    // deployment, so it needs to be linked into your contract statically.
    /**
     * Raise a number to a positive integer power in O(log power) time.
     * See <https://stackoverflow.com/a/101613>
     */
    function ipow(int256 realBase, int216 exponent) internal pure returns (int256) {
        if (exponent < 0) {
            // Negative powers are not allowed here.
            revert();
        }

        int256 tempRealBase = realBase;
        int256 tempExponent = exponent;

        // Start with the 0th power
        int256 realResult = REAL_ONE;
        while (tempExponent != 0) {
            // While there are still bits set
            if ((tempExponent & 0x1) == 0x1) {
                // If the low bit is set, multiply in the (many-times-squared) base
                realResult = mul(realResult, tempRealBase);
            }
            // Shift off the low bit
            tempExponent = tempExponent >> 1;
            // Do the squaring
            tempRealBase = mul(tempRealBase, tempRealBase);
        }

        // Return the final result.
        return realResult;
    }

    /**
     * Zero all but the highest set bit of a number.
     * See <https://stackoverflow.com/a/53184>
     */
    function hibit(uint256 _val) internal pure returns (uint256) {
        // Set all the bits below the highest set bit
        uint256 val = _val;
        val |= (val >> 1);
        val |= (val >> 2);
        val |= (val >> 4);
        val |= (val >> 8);
        val |= (val >> 16);
        val |= (val >> 32);
        val |= (val >> 64);
        val |= (val >> 128);
        return val ^ (val >> 1);
    }

    /**
     * Given a number with one bit set, finds the index of that bit.
     */
    // solhint-disable-next-line code-complexity
    function findbit(uint256 val) internal pure returns (uint8 index) {
        index = 0;
        // We and the value with alternating bit patters of various pitches to find it.
        if (val & 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA != 0) {
            // Picth 1
            index |= 1;
        }
        if (val & 0xCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC != 0) {
            // Pitch 2
            index |= 2;
        }
        if (val & 0xF0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0 != 0) {
            // Pitch 4
            index |= 4;
        }
        if (val & 0xFF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00FF00 != 0) {
            // Pitch 8
            index |= 8;
        }
        if (val & 0xFFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF0000 != 0) {
            // Pitch 16
            index |= 16;
        }
        if (val & 0xFFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000 != 0) {
            // Pitch 32
            index |= 32;
        }
        if (val & 0xFFFFFFFFFFFFFFFF0000000000000000FFFFFFFFFFFFFFFF0000000000000000 != 0) {
            // Pitch 64
            index |= 64;
        }
        if (val & 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF00000000000000000000000000000000 != 0) {
            // Pitch 128
            index |= 128;
        }
    }

    /**
     * Shift realArg left or right until it is between 1 and 2. Return the
     * rescaled value, and the number of bits of right shift applied. Shift may be negative.
     *
     * Expresses realArg as realScaled * 2^shift, setting shift to put realArg between [1 and 2).
     *
     * Rejects 0 or negative arguments.
     */
    function rescale(int256 realArg) internal pure returns (int256 realScaled, int216 shift) {
        if (realArg <= 0) {
            // Not in domain!
            revert();
        }

        // Find the high bit
        int216 highBit = findbit(hibit(uint256(realArg)));

        // We'll shift so the high bit is the lowest non-fractional bit.
        shift = highBit - int216(REAL_FBITS);

        if (shift < 0) {
            // Shift left
            realScaled = realArg << -shift;
        } else if (shift >= 0) {
            // Shift right
            realScaled = realArg >> shift;
        }
    }

    /**
     * Calculate the natural log of a number. Rescales the input value and uses
     * the algorithm outlined at <https://math.stackexchange.com/a/977836> and
     * the ipow implementation.
     *
     * Lets you artificially limit the number of iterations.
     *
     * Note that it is potentially possible to get an un-converged value; lack
     * of convergence does not throw.
     */
    function lnLimited(int256 realArg, int256 maxIterations) internal pure returns (int256) {
        if (realArg <= 0) {
            // Outside of acceptable domain
            revert();
        }

        if (realArg == REAL_ONE) {
            // Handle this case specially because people will want exactly 0 and
            // not ~2^-39 ish.
            return 0;
        }

        // We know it's positive, so rescale it to be between [1 and 2)
        int256 realRescaled;
        int216 shift;
        (realRescaled, shift) = rescale(realArg);

        // Compute the argument to iterate on
        int256 realSeriesArg = div(realRescaled - REAL_ONE, realRescaled + REAL_ONE);

        // We will accumulate the result here
        int256 realSeriesResult = 0;

        for (int216 n = 0; n < maxIterations; n++) {
            // Compute term n of the series
            int256 realTerm = div(ipow(realSeriesArg, 2 * n + 1), toReal(2 * n + 1));
            // And add it in
            realSeriesResult += realTerm;
            if (realTerm == 0) {
                // We must have converged. Next term is too small to represent.
                break;
            }
            // If we somehow never converge I guess we will run out of gas
        }

        // Double it to account for the factor of 2 outside the sum
        realSeriesResult = mul(realSeriesResult, REAL_TWO);

        // Now compute and return the overall result
        return mul(toReal(shift), REAL_LN_TWO) + realSeriesResult;

    }

    /**
     * Calculate a natural logarithm with a sensible maximum iteration count to
     * wait until convergence. Note that it is potentially possible to get an
     * un-converged value; lack of convergence does not throw.
     */
    function ln(int256 realArg) internal pure returns (int256) {
        return lnLimited(realArg, 100);
    }

    /**
     * Calculate e^x. Uses the series given at
     * <http://pages.mtu.edu/~shene/COURSES/cs201/NOTES/chap04/exp.html>.
     *
     * Lets you artificially limit the number of iterations.
     *
     * Note that it is potentially possible to get an un-converged value; lack
     * of convergence does not throw.
     */
    function expLimited(int256 realArg, int256 maxIterations) internal pure returns (int256) {
        // We will accumulate the result here
        int256 realResult = 0;

        // We use this to save work computing terms
        int256 realTerm = REAL_ONE;

        for (int216 n = 0; n < maxIterations; n++) {
            // Add in the term
            realResult += realTerm;

            // Compute the next term
            realTerm = mul(realTerm, div(realArg, toReal(n + 1)));

            if (realTerm == 0) {
                // We must have converged. Next term is too small to represent.
                break;
            }
            // If we somehow never converge I guess we will run out of gas
        }

        // Return the result
        return realResult;

    }

    /**
     * Calculate e^x with a sensible maximum iteration count to wait until
     * convergence. Note that it is potentially possible to get an un-converged
     * value; lack of convergence does not throw.
     */
    function exp(int256 realArg) internal pure returns (int256) {
        return expLimited(realArg, 100);
    }

    /**
     * Raise any number to any power, except for negative bases to fractional powers.
     */
    function pow(int256 realBase, int256 realExponent) internal pure returns (int256) {
        if (realExponent == 0) {
            // Anything to the 0 is 1
            return REAL_ONE;
        }

        if (realBase == 0) {
            if (realExponent < 0) {
                // Outside of domain!
                revert();
            }
            // Otherwise it's 0
            return 0;
        }

        if (fpart(realExponent) == 0) {
            // Anything (even a negative base) is super easy to do to an integer power.

            if (realExponent > 0) {
                // Positive integer power is easy
                return ipow(realBase, fromReal(realExponent));
            } else {
                // Negative integer power is harder
                return div(REAL_ONE, ipow(realBase, fromReal(-realExponent)));
            }
        }

        if (realBase < 0) {
            // It's a negative base to a non-integer power.
            // In general pow(-x^y) is undefined, unless y is an int256 or some
            // weird rational-number-based relationship holds.
            revert();
        }

        // If it's not a special case, actually do it.
        return exp(mul(realExponent, ln(realBase)));
    }

    /**
     * Compute the square root of a number.
     */
    function sqrt(int256 realArg) internal pure returns (int256) {
        return pow(realArg, REAL_HALF);
    }

    /**
     * Compute the sin of a number to a certain number of Taylor series terms.
     */
    function sinLimited(int256 _realArg, int216 maxIterations) internal pure returns (int256) {
        // First bring the number into 0 to 2 pi
        // TODO: This will introduce an error for very large numbers, because the error in our Pi will compound.
        // But for actual reasonable angle values we should be fine.
        int256 realArg = _realArg;
        realArg = realArg % REAL_TWO_PI;

        int256 accumulator = REAL_ONE;

        // We sum from large to small iteration so that we can have higher powers in later terms
        for (int216 iteration = maxIterations - 1; iteration >= 0; iteration--) {
            accumulator = REAL_ONE - mul(div(mul(realArg, realArg),
            toReal((2 * iteration + 2) * (2 * iteration + 3))), accumulator);
            // We can't stop early; we need to make it to the first term.
        }

        return mul(realArg, accumulator);
    }

    /**
     * Calculate sin(x) with a sensible maximum iteration count to wait until
     * convergence.
     */
    function sin(int256 realArg) internal pure returns (int256) {
        return sinLimited(realArg, 15);
    }

    /**
     * Calculate cos(x).
     */
    function cos(int256 realArg) internal pure returns (int256) {
        return sin(realArg + REAL_HALF_PI);
    }

    /**
     * Calculate tan(x). May overflow for large results. May throw if tan(x)
     * would be infinite, or return an approximation, or overflow.
     */
    function tan(int256 realArg) internal pure returns (int256) {
        return div(sin(realArg), cos(realArg));
    }
}

// File: contracts/schemes/Locking4Reputation.sol

/**
 * @title A locker contract
 */

contract Locking4Reputation {
    using SafeMath for uint;
    using RealMath for int216;
    using RealMath for int256;

    event Redeem(address indexed _beneficiary, uint256 _amount);
    event Release(bytes32 indexed _lockingId, address indexed _beneficiary, uint256 _amount);
    event Lock(address indexed _locker, bytes32 indexed _lockingId, uint256 _amount, uint256 _period);

    struct Locker {
        uint256 amount;
        uint256 releaseTime;
    }

    Avatar public avatar;

    // A mapping from lockers addresses their lock balances.
    mapping(address => mapping(bytes32=>Locker)) public lockers;
    // A mapping from lockers addresses to their scores.
    mapping(address => uint) public scores;

    uint256 public totalLocked;
    uint256 public totalLockedLeft;
    uint256 public totalScore;
    uint256 public lockingsCounter; // Total number of lockings
    uint256 public reputationReward;
    uint256 public reputationRewardLeft;
    uint256 public lockingEndTime;
    uint256 public maxLockingPeriod;
    uint256 public lockingStartTime;
    uint256 public redeemEnableTime;

    /**
     * @dev redeem reputation function
     * @param _beneficiary the beneficiary for the release
     * @return uint256 reputation rewarded
     */
    function redeem(address _beneficiary) public returns(uint256 reputation) {
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp > redeemEnableTime, "now > redeemEnableTime");
        require(scores[_beneficiary] > 0, "score should be > 0");
        uint256 score = scores[_beneficiary];
        scores[_beneficiary] = 0;
        int256 repRelation = int216(score).toReal().mul(int216(reputationReward).toReal());
        reputation = uint256(repRelation.div(int216(totalScore).toReal()).fromReal());

        //check that the reputation is sum zero
        reputationRewardLeft = reputationRewardLeft.sub(reputation);
        require(
        ControllerInterface(
        avatar.owner())
        .mintReputation(reputation, _beneficiary, address(avatar)), "mint reputation should success");

        emit Redeem(_beneficiary, reputation);
    }

    /**
     * @dev release function
     * @param _beneficiary the beneficiary for the release
     * @param _lockingId the locking id to release
     * @return bool
     */
    function _release(address _beneficiary, bytes32 _lockingId) internal returns(uint256 amount) {
        Locker storage locker = lockers[_beneficiary][_lockingId];
        require(locker.amount > 0, "amount should be > 0");
        amount = locker.amount;
        locker.amount = 0;
        // solhint-disable-next-line not-rely-on-time
        require(block.timestamp > locker.releaseTime, "check the lock period pass");
        totalLockedLeft = totalLockedLeft.sub(amount);

        emit Release(_lockingId, _beneficiary, amount);
    }

    /**
     * @dev lock function
     * @param _amount the amount to lock
     * @param _period the locking period
     * @param _locker the locker
     * @param _numerator price numerator
     * @param _denominator price denominator
     * @return lockingId
     */
    function _lock(
        uint256 _amount,
        uint256 _period,
        address _locker,
        uint256 _numerator,
        uint256 _denominator)
        internal
        returns(bytes32 lockingId)
        {
        require(_amount > 0, "locking amount should be > 0");
        require(_period <= maxLockingPeriod, "locking period should be <= maxLockingPeriod");
        require(_period > 0, "locking period should be > 0");
        // solhint-disable-next-line not-rely-on-time
        require(now <= lockingEndTime, "lock should be within the allowed locking period");
        // solhint-disable-next-line not-rely-on-time
        require(now >= lockingStartTime, "lock should start after lockingStartTime");

        lockingId = keccak256(abi.encodePacked(address(this), lockingsCounter));
        lockingsCounter = lockingsCounter.add(1);

        Locker storage locker = lockers[_locker][lockingId];
        locker.amount = _amount;
        // solhint-disable-next-line not-rely-on-time
        locker.releaseTime = now + _period;
        totalLocked = totalLocked.add(_amount);
        totalLockedLeft = totalLocked;
        uint256 score = _period.mul(_amount).mul(_numerator).div(_denominator);
        require(score > 0, "score must me > 0");
        scores[_locker] = scores[_locker].add(score);
        totalScore = totalScore.add(score);

        emit Lock(_locker, lockingId, _amount, _period);
    }

    /**
     * @dev _initialize
     * @param _avatar the avatar to mint reputation from
     * @param _reputationReward the total reputation this contract will reward
     *        for eth/token locking
     * @param _lockingStartTime the locking start time.
     * @param _lockingEndTime the locking end time.
     *        locking is disable after this time.
     * @param _redeemEnableTime redeem enable time .
     *        redeem reputation can be done after this time.
     * @param _maxLockingPeriod maximum locking period allowed.
     */
    function _initialize(
        Avatar _avatar,
        uint256 _reputationReward,
        uint256 _lockingStartTime,
        uint256 _lockingEndTime,
        uint256 _redeemEnableTime,
        uint256 _maxLockingPeriod)
    internal
    {
        require(avatar == Avatar(0), "can be called only one time");
        require(_avatar != Avatar(0), "avatar cannot be zero");
        require(_lockingEndTime > _lockingStartTime, "locking end time should be greater than locking start time");
        require(_redeemEnableTime >= _lockingEndTime, "redeemEnableTime >= lockingEndTime");

        reputationReward = _reputationReward;
        reputationRewardLeft = _reputationReward;
        lockingEndTime = _lockingEndTime;
        maxLockingPeriod = _maxLockingPeriod;
        avatar = _avatar;
        lockingStartTime = _lockingStartTime;
        redeemEnableTime = _redeemEnableTime;
    }

}

// File: contracts/schemes/ExternalLocking4Reputation.sol

/**
 * @title A scheme for external locking Tokens for reputation
 */

contract ExternalLocking4Reputation is Locking4Reputation, Ownable {

    event Register(address indexed _beneficiary);

    address public externalLockingContract;
    string public getBalanceFuncSignature;

    // locker -> bool
    mapping(address => bool) public externalLockers;
    //      beneficiary -> bool
    mapping(address     => bool) public registrar;

    /**
     * @dev initialize
     * @param _avatar the avatar to mint reputation from
     * @param _reputationReward the total reputation this contract will reward
     *        for the token locking
     * @param _claimingStartTime claiming starting period time.
     * @param _claimingEndTime the claiming end time.
     *        claiming is disable after this time.
     * @param _redeemEnableTime redeem enable time .
     *        redeem reputation can be done after this time.
     * @param _externalLockingContract the contract which lock the token.
     * @param _getBalanceFuncSignature get balance function signature
     *        e.g "lockedTokenBalances(address)"
     */
    function initialize(
        Avatar _avatar,
        uint256 _reputationReward,
        uint256 _claimingStartTime,
        uint256 _claimingEndTime,
        uint256 _redeemEnableTime,
        address _externalLockingContract,
        string calldata _getBalanceFuncSignature)
    external
    onlyOwner
    {
        require(_claimingEndTime > _claimingStartTime, "_claimingEndTime should be greater than _claimingStartTime");
        externalLockingContract = _externalLockingContract;
        getBalanceFuncSignature = _getBalanceFuncSignature;
        super._initialize(
        _avatar,
        _reputationReward,
        _claimingStartTime,
        _claimingEndTime,
        _redeemEnableTime,
        1);
    }

    /**
     * @dev claim function
     * @param _beneficiary the beneficiary address to claim for
     *        if _beneficiary == 0 the claim will be for the msg.sender.
     * @return claimId
     */
    function claim(address _beneficiary) public returns(bytes32) {
        require(avatar != Avatar(0), "should initialize first");
        address beneficiary;
        if (_beneficiary == address(0)) {
            beneficiary = msg.sender;
        } else {
            require(registrar[_beneficiary], "beneficiary should be register");
            beneficiary = _beneficiary;
        }
        require(externalLockers[beneficiary] == false, "claiming twice for the same beneficiary is not allowed");
        externalLockers[beneficiary] = true;
        (bool result, bytes memory returnValue) =
        // solhint-disable-next-line avoid-call-value,avoid-low-level-calls
        externalLockingContract.call(abi.encodeWithSignature(getBalanceFuncSignature, beneficiary));
        require(result, "call to external contract should success");
        uint256 lockedAmount;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            lockedAmount := mload(add(returnValue, add(0x20, 0)))
        }
        return super._lock(lockedAmount, 1, beneficiary, 1, 1);
    }

   /**
    * @dev register function
    *      register for external locking claim
    */
    function register() public {
        registrar[msg.sender] = true;
        emit Register(msg.sender);
    }
}
