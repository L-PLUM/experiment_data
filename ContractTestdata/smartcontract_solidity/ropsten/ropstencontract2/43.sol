/**
 *Submitted for verification at Etherscan.io on 2019-08-12
*/

/**
 *Submitted for verification at Etherscan.io on 2019-07-02
*/

/* file: openzeppelin-solidity/contracts/ownership/Ownable.sol */
pragma solidity ^0.4.24;

/**
 * @title Ownable
 *  The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   *  The Ownable constructor sets the original `owner` of the contract to the sender
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
   *  Throws if called by any account other than the owner.
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
   *  Allows the current owner to relinquish control of the contract.
   *  Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipTransferred(_owner, address(0));
    _owner = address(0);
  }

  /**
   *  Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    _transferOwnership(newOwner);
  }

  /**
   *  Transfers control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address newOwner) internal {
    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }
}

/* eof (openzeppelin-solidity/contracts/ownership/Ownable.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol */
pragma solidity ^0.4.24;

/**
 * @title ERC20 interface
 *  see https://github.com/ethereum/EIPs/issues/20
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

/* eof (openzeppelin-solidity/contracts/token/ERC20/IERC20.sol) */
/* file: openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol */
pragma solidity ^0.4.24;


/**
 * @title ERC20Detailed token
 *  The decimals are only for visualization purposes.
 * All the operations are done using the smallest and indivisible token unit,
 * just as on Ethereum all the operations are done in wei.
 */
contract ERC20Detailed is IERC20 {
  string private _name;
  string private _symbol;
  uint8 private _decimals;

  constructor(string name, string symbol, uint8 decimals) public {
    _name = name;
    _symbol = symbol;
    _decimals = decimals;
  }

  /**
   * @return the name of the token.
   */
  function name() public view returns(string) {
    return _name;
  }

  /**
   * @return the symbol of the token.
   */
  function symbol() public view returns(string) {
    return _symbol;
  }

  /**
   * @return the number of decimals of the token.
   */
  function decimals() public view returns(uint8) {
    return _decimals;
  }
}

/* eof (openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol) */
/* file: openzeppelin-solidity/contracts/math/SafeMath.sol */
pragma solidity ^0.4.24;

/**
 * @title SafeMath
 *  Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  *  Multiplies two numbers, reverts on overflow.
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
  *  Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  *  Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  *  Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  *  Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

/* eof (openzeppelin-solidity/contracts/math/SafeMath.sol) */
/* file: ./contracts/token/ERC20/ERC20Custom.sol */
pragma solidity 0.4.24;



// solhint-disable
/**
* @title Standard ERC20 token
*
*  Implementation of the basic standard token.
* https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
* Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
*/
// solhint-enable
contract ERC20Custom is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /** 
    *  sets the starting total supply cap
    * @param _initialSupply uint256 initial total supply cap
    */
    constructor(uint256 _initialSupply) public {
        _totalSupply = _initialSupply;
    }

    /**
    *  Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    *  Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
    *  Function to check the amount of tokens that an owner allowed to a spender.
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
    *  Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
    *  Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
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
    *  Transfer tokens from one address to another
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
    *  Increase the amount of tokens that an owner allowed to a spender.
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
    *  Decrease the amount of tokens that an owner allowed to a spender.
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
    *  Transfer token for a specified addresses
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

    //*** CUSTOM IMPLEMENTATION BELOW ***/
    /**
    * 
    * 
    * @param account address
    * @param value uint256
    */
    function _increaseMintedSupply(address account, uint256 value) internal {
        _balances[account] = _balances[account].add(value);

        emit Transfer(address(0), account, value);
    }

    /**
    *  decreases the account's held tokens and decreases the amount from _mintedSupply
    * @param account address
    * @param value uint256
    */
    function _decreaseMintedSupply(address account, uint256 value) internal {
        require(value <= _balances[account], "value > balance");

        _balances[account] = _balances[account].sub(value);

        emit Transfer(account, address(0), value);
    }

    /**
    *  allows another account, with previous permissions, to decrease another accounts balance
    * @param account address
    * @param value uint256
    */
    function _decreaseMintedSupplyFrom(address account, uint256 value) internal {
        require(value <= _allowed[account][msg.sender], "value > balance");

        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _decreaseMintedSupply(account, value);
    }

    /**
    *  increases _totalSupply by value amount
    *  adds value to the previous totalSupply's value
    * @param value uint256 value to be added 
    */
    function _increaseTotalSupply(uint256 value) internal {
        require(value > 0, "value must be > 0");

        _totalSupply = _totalSupply.add(value);
    }
}

/* eof (./contracts/token/ERC20/ERC20Custom.sol) */
/* file: openzeppelin-solidity/contracts/access/Roles.sol */
pragma solidity ^0.4.24;

/**
 * @title Roles
 *  Library for managing addresses assigned to a Role.
 */
library Roles {
  struct Role {
    mapping (address => bool) bearer;
  }

  /**
   *  give an account access to this role
   */
  function add(Role storage role, address account) internal {
    require(account != address(0));
    require(!has(role, account));

    role.bearer[account] = true;
  }

  /**
   *  remove an account's access to this role
   */
  function remove(Role storage role, address account) internal {
    require(account != address(0));
    require(has(role, account));

    role.bearer[account] = false;
  }

  /**
   *  check if an account has this role
   * @return bool
   */
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}

/* eof (openzeppelin-solidity/contracts/access/Roles.sol) */
/* file: openzeppelin-solidity/contracts/access/roles/PauserRole.sol */
pragma solidity ^0.4.24;


contract PauserRole {
  using Roles for Roles.Role;

  event PauserAdded(address indexed account);
  event PauserRemoved(address indexed account);

  Roles.Role private pausers;

  constructor() internal {
    _addPauser(msg.sender);
  }

  modifier onlyPauser() {
    require(isPauser(msg.sender));
    _;
  }

  function isPauser(address account) public view returns (bool) {
    return pausers.has(account);
  }

  function addPauser(address account) public onlyPauser {
    _addPauser(account);
  }

  function renouncePauser() public {
    _removePauser(msg.sender);
  }

  function _addPauser(address account) internal {
    pausers.add(account);
    emit PauserAdded(account);
  }

  function _removePauser(address account) internal {
    pausers.remove(account);
    emit PauserRemoved(account);
  }
}

/* eof (openzeppelin-solidity/contracts/access/roles/PauserRole.sol) */
/* file: openzeppelin-solidity/contracts/lifecycle/Pausable.sol */
pragma solidity ^0.4.24;


/**
 * @title Pausable
 *  Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is PauserRole {
  event Paused(address account);
  event Unpaused(address account);

  bool private _paused;

  constructor() internal {
    _paused = false;
  }

  /**
   * @return true if the contract is paused, false otherwise.
   */
  function paused() public view returns(bool) {
    return _paused;
  }

  /**
   *  Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!_paused);
    _;
  }

  /**
   *  Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(_paused);
    _;
  }

  /**
   *  called by the owner to pause, triggers stopped state
   */
  function pause() public onlyPauser whenNotPaused {
    _paused = true;
    emit Paused(msg.sender);
  }

  /**
   *  called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyPauser whenPaused {
    _paused = false;
    emit Unpaused(msg.sender);
  }
}

/* eof (openzeppelin-solidity/contracts/lifecycle/Pausable.sol) */
/* file: ./contracts/token/ERC20/ERC20PausableCustom.sol */
pragma solidity ^0.4.24;



/**
 * @title Pausable token
 *  ERC20 modified with pausable transfers.
 **/
contract ERC20PausableCustom is ERC20Custom, Pausable {

    function transfer(
        address to,
        uint256 value
    )
        public
        whenNotPaused
        returns (bool)
    {
        return super.transfer(to, value);
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        whenNotPaused
        returns (bool)
    {
        return super.transferFrom(from, to, value);
    }

    function approve(
        address spender,
        uint256 value
    )
        public
        whenNotPaused
        returns (bool)
    {
        return super.approve(spender, value);
    }

    function increaseAllowance(
        address spender,
        uint addedValue
    )
        public
        whenNotPaused
        returns (bool success)
    {
        return super.increaseAllowance(spender, addedValue);
    }

    function decreaseAllowance(
        address spender,
        uint subtractedValue
    )
        public
        whenNotPaused
        returns (bool success)
    {
        return super.decreaseAllowance(spender, subtractedValue);
    }
}

/* eof (./contracts/token/ERC20/ERC20PausableCustom.sol) */
/* file: ./contracts/token/ERC20/IERC20Snapshot.sol */
/**
 * @title Interface ERC20 SnapshotToken (abstract contract)
 * @author Validity Labs AG <[email protected]>
 */

pragma solidity 0.4.24;  


/* solhint-disable no-empty-blocks */
contract IERC20Snapshot {   
    /**
    *  Queries the balance of `_owner` at a specific `_blockNumber`
    * @param _owner The address from which the balance will be retrieved
    * @param _blockNumber The block number when the balance is queried
    * @return The balance at `_blockNumber`
    */
    function balanceOfAt(address _owner, uint _blockNumber) public view returns (uint256) {}

    /**
    *  Total amount of tokens at a specific `_blockNumber`.
    * @param _blockNumber The block number when the totalSupply is queried
    * @return The total amount of tokens at `_blockNumber`
    */
    function totalSupplyAt(uint _blockNumber) public view returns(uint256) {}
}

/* eof (./contracts/token/ERC20/IERC20Snapshot.sol) */
/* file: openzeppelin-solidity/contracts/access/roles/MinterRole.sol */
pragma solidity ^0.4.24;


contract MinterRole {
  using Roles for Roles.Role;

  event MinterAdded(address indexed account);
  event MinterRemoved(address indexed account);

  Roles.Role private minters;

  constructor() internal {
    _addMinter(msg.sender);
  }

  modifier onlyMinter() {
    require(isMinter(msg.sender));
    _;
  }

  function isMinter(address account) public view returns (bool) {
    return minters.has(account);
  }

  function addMinter(address account) public onlyMinter {
    _addMinter(account);
  }

  function renounceMinter() public {
    _removeMinter(msg.sender);
  }

  function _addMinter(address account) internal {
    minters.add(account);
    emit MinterAdded(account);
  }

  function _removeMinter(address account) internal {
    minters.remove(account);
    emit MinterRemoved(account);
  }
}

/* eof (openzeppelin-solidity/contracts/access/roles/MinterRole.sol) */
/* file: ./contracts/token/ERC20/ERC20Confiscatable.sol */
/**
 * @title ERC20Confiscatable
 * @author Validity Labs AG <[email protected]>
 */

pragma solidity 0.4.24;  



/* solhint-disable no-empty-blocks */
contract ERC20Confiscatable is ERC20Custom {
    bool public canConfiscate;

    address public multisigProxy;

    mapping(address => bool) public isFrozen;

    /*** EVENTS ***/
    event FreezeToggled(address indexed account, bool isFrozen);
    event ConfiscatableToggled(bool isActive);
    event ConfiscateTriggered(address indexed account, uint256 amount, address indexed receiver);

    /*** MODIFIERS ***/
    modifier onlyMultisigProxy() {
        require(msg.sender == multisigProxy, "not multisig contract");
        _;
    }
   
    modifier onlyCanConfiscate() {
        require(canConfiscate, "cannot confiscate");
        _;
    }

    /*** FUNCTIONS ***/
    /**
    *  freezes Sygnum token on the parameterized account
    * @param _account address of the account to be frozen
    */
    function toggleFreeze(address _account) public onlyMultisigProxy {
        isFrozen[_account] ? isFrozen[_account] = false : isFrozen[_account] = true;
        emit FreezeToggled(_account, isFrozen[_account]);
    }

    /**
    *  toggles bool canConfiscate; allows the call to confiscate funds
    */
    function toggleConfiscatable() public onlyMultisigProxy {
        !canConfiscate ? canConfiscate = true : canConfiscate = false;
        emit ConfiscatableToggled(canConfiscate);
    }

    /**
    *  depends on canConfiscate; takes funds from address and sends them 
    * to the receiving address
    * @param _confiscatee address who's funds are being confiscated
    * @param _receiver address who's receiving the funds 
    */
    function confiscate(address _confiscatee, address _receiver) 
        public 
        onlyMultisigProxy 
        onlyCanConfiscate {
            uint256 balance = balanceOf(_confiscatee);
            _transfer(_confiscatee, _receiver, balance);
            emit ConfiscateTriggered(_confiscatee, balance, _receiver);
        }

    /** OVERRIDE
    *  transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    * @return bool
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        checkIfFrozen(msg.sender, _to);
        return super.transfer(_to, _value);
    }

    /** OVERRIDE
    *  Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    * @return bool
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        checkIfFrozen(msg.sender, _to);
        return super.transferFrom(_from, _to, _value);
    }

    /*** INTERNAL/PRIVATE ***/
    /**
    *  is either to or from addresses marked as frozen
    * @param _from address 
    * @param _to address
    */
    function checkIfFrozen(address _from, address _to) internal view {
        require(!isFrozen[_from], "from has been frozen");
        require(!isFrozen[_to], "to has been frozen");
    }
}

/* eof (./contracts/token/ERC20/ERC20Confiscatable.sol) */
/* file: ./contracts/token/ERC20/ERC20SupplyManagement.sol */
/**
 * @title ERC20 Supply Management Contract
 * @author Validity Labs AG <[email protected]>
 */

pragma solidity 0.4.24;



/**
*  3 different actions described below
* 1) client owner has the ability to "transform" tokens increasing "mintedSupply" up to the cap, "totalSupply"
* 2) multisig contract has the ability to "increaseTotalSupply" (totalSupply)
* 3) token holders have the ability to "detransform" decreasing "mintedSupply"
*/
contract ERC20SupplyManagement is ERC20Custom, MinterRole, ERC20Confiscatable {

    // total minted supply that is held by accounts
    uint256 private _mintedSupply;

    event Transformed(address indexed to, uint256 value);
    event Detransformed(address indexed from, uint256 value);
    event TotalSupplyIncreased(uint256 totalSupply);

    /**
     *  Total number of tokens in currently minted
     */
    function mintedSupply() public view returns (uint256) {
        return _mintedSupply;
    }

    /**
    *  allows client owner to mint new tokens up to the totalSupply
    * @param to The address that will receive the minted tokens.
    * @param value The amount of tokens to mint.
    */
    function transform(address to, uint256 value) public onlyMinter {
        require(to != address(0), "invalid account");

        uint256 tempMintedSupply = _mintedSupply.add(value);
        require(tempMintedSupply <= totalSupply(), "respect the totalSupply limit");

        _mintedSupply = tempMintedSupply;
        _increaseMintedSupply(to, value);
        
        emit Transformed(to, value);
    }

    /**
    *  allows token holder to burn their tokens decreasing mintedSupply
    * @param value The amount of tokens to burn.
    */
    function detransform(uint256 value) public {
        _mintedSupply = _mintedSupply.sub(value);
        _decreaseMintedSupply(msg.sender, value);
        
        emit Detransformed(msg.sender, value);
    }

    /**
    *  allows token holder to burn their tokens decreasing mintedSupply
    * @param from address The address which you want to send tokens from
    * @param value uint256 The amount of token to be burned
    */
    function detransformFrom(address from, uint256 value) public {
        require(from != address(0), "invalid account");

        _mintedSupply = _mintedSupply.sub(value);
        _decreaseMintedSupplyFrom(from, value);
        
        emit Detransformed(from, value);
    }

    /** 
    *  allows multisig to increase supply cap of the token without minting new tokens
    *  increases the totalSupply variable
    * @param value uint256 the amount to increase to cap by
    */
    function increaseSupply(uint256 value) public onlyMultisigProxy {
        _increaseTotalSupply(value);

        emit TotalSupplyIncreased(totalSupply());
    }
}

/* eof (./contracts/token/ERC20/ERC20SupplyManagement.sol) */
/* file: ./contracts/token/ERC20/ERC20Snapshot.sol */
/**
 * @title ERC20 Snapshot Token
 * inspired by Jordi Baylina's MiniMeToken to record historical balances
 * @author Validity Labs AG <[email protected]>
 */

pragma solidity 0.4.24;  



contract ERC20Snapshot is IERC20Snapshot, ERC20SupplyManagement {   
    using SafeMath for uint256;

    /**
    *  `Snapshot` is the structure that attaches a block number to a
    * given value. The block number attached is the one that last changed the value
    */
    struct Snapshot {
        uint128 fromBlock;  // `fromBlock` is the block number at which the value was generated from
        uint128 value;  // `value` is the amount of tokens at a specific block number
    }

    /**
    *  `_snapshotBalances` is the map that tracks the balance of each address, in this
    * contract when the balance changes the block number that the change
    * occurred is also included in the map
    */
    mapping (address => Snapshot[]) private _snapshotBalances;

    // Tracks the history of the `_totalSupply` & '_mintedSupply' of the token
    Snapshot[] private _snapshotTotalSupply;
    Snapshot[] private _snapshotMintedSupply;

    /*** FUNCTIONS ***/
    /** OVERRIDE
    *  Send `_value` tokens to `_to` from `msg.sender`
    * @param _to The address of the recipient
    * @param _value The amount of tokens to be transferred
    * @return Whether the transfer was successful or not
    */
    function transfer(address _to, uint256 _value) public returns (bool result) {
        result = super.transfer(_to, _value);
        createSnapshot(msg.sender, _to);
    }

    /** OVERRIDE
    *  Send `_value` tokens to `_to` from `_from` on the condition it is approved by `_from`
    * @param _from The address holding the tokens being transferred
    * @param _to The address of the recipient
    * @param _value The amount of tokens to be transferred
    * @return True if the transfer was successful
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool result) {
        result = super.transferFrom(_from, _to, _value);
        createSnapshot(_from, _to);
    }

    /**
    *  Queries the balance of `_owner` at a specific `_blockNumber`
    * @param _owner The address from which the balance will be retrieved
    * @param _blockNumber The block number when the balance is queried
    * @return The balance at `_blockNumber`
    */
    function balanceOfAt(address _owner, uint _blockNumber) public view returns (uint256) {
        return getValueAt(_snapshotBalances[_owner], _blockNumber);
    }

    /**
    *  Total supply cap of tokens at a specific `_blockNumber`.
    * @param _blockNumber The block number when the totalSupply is queried
    * @return The total supply cap of tokens at `_blockNumber`
    */
    function totalSupplyAt(uint _blockNumber) public view returns(uint256) {
        return getValueAt(_snapshotTotalSupply, _blockNumber);
    }

    /**
    *  Total amount of minted tokens at a specific `_blockNumber`.
    * @param _blockNumber The block number when the totalSupply is queried
    * @return The total amount of tokens at `_blockNumber`
    */
    function mintedSupplyAt(uint _blockNumber) public view returns(uint256) {
        return getValueAt(_snapshotMintedSupply, _blockNumber);
    }

    /*** Internal functions ***/
    /**
    *  Updates snapshot mappings for _from and _to and emit an event
    * @param _from The address holding the tokens being transferred
    * @param _to The address of the recipient
    * @return True if the transfer was successful
    */
    function createSnapshot(address _from, address _to) internal {
        updateValueAtNow(_snapshotBalances[_from], balanceOf(_from));
        updateValueAtNow(_snapshotBalances[_to], balanceOf(_to));
    }

    /**
    *  `getValueAt` retrieves the number of tokens at a given block number
    * @param checkpoints The history of values being queried
    * @param _block The block number to retrieve the value at
    * @return The number of tokens being queried
    */
    function getValueAt(Snapshot[] storage checkpoints, uint _block) internal view returns (uint) {
        if (checkpoints.length == 0) return 0;

        // Shortcut for the actual value
        if (_block >= checkpoints[checkpoints.length.sub(1)].fromBlock) {
            return checkpoints[checkpoints.length.sub(1)].value;
        }

        if (_block < checkpoints[0].fromBlock) {
            return 0;
        } 

        // Binary search of the value in the array
        uint min;
        uint max = checkpoints.length.sub(1);

        while (max > min) {
            uint mid = (max.add(min).add(1)).div(2);
            if (checkpoints[mid].fromBlock <= _block) {
                min = mid;
            } else {
                max = mid.sub(1);
            }
        }

        return checkpoints[min].value;
    }

    /**
    *  `updateValueAtNow` used to update the `_snapshotBalances` map and the `_snapshotTotalSupply`
    * @param checkpoints The history of data being updated
    * @param _value The new number of tokens
    */
    function updateValueAtNow(Snapshot[] storage checkpoints, uint _value) internal {
        if ((checkpoints.length == 0) || (checkpoints[checkpoints.length.sub(1)].fromBlock < block.number)) {
            checkpoints.push(Snapshot(uint128(block.number), uint128(_value)));
        } else {
            checkpoints[checkpoints.length.sub(1)].value = uint128(_value);
        }
    }

    /** OVERRIDE
    *  Internal function that mints an amount of the token and assigns it to
    * an account. This encapsulates the modification of balances such that the
    * proper events are emitted.
    * @param account The account that will receive the created tokens.
    * @param amount The amount that will be created.
    */
    function _increaseMintedSupply(address account, uint256 amount) internal {
        super._increaseMintedSupply(account, amount);
        updateValueAtNow(_snapshotMintedSupply, mintedSupply());
        updateValueAtNow(_snapshotBalances[account], balanceOf(account));
    }

    /** OVERRIDE
    *  Internal function that burns an amount of the token of a given
    * account.
    * @param account The account whose tokens will be burnt.
    * @param amount The amount that will be burnt.
    */
    function _decreaseMintedSupply(address account, uint256 amount) internal {
        super._decreaseMintedSupply(account, amount);
        updateValueAtNow(_snapshotMintedSupply, mintedSupply());
        updateValueAtNow(_snapshotBalances[account], balanceOf(account));
    }

    /** OVERRIDE
    *  Internal function that burns an amount of the token of a given
    * account, deducting from the sender's allowance for said account. Uses the
    * internal burn function.
    * @param account The account whose tokens will be burnt.
    * @param amount The amount that will be burnt.
    */
    function _decreaseMintedSupplyFrom(address account, uint256 amount) internal {
        super._decreaseMintedSupplyFrom(account, amount);
        updateValueAtNow(_snapshotMintedSupply, mintedSupply());
        updateValueAtNow(_snapshotBalances[account], balanceOf(account));
    }

    /** OVERRIDE
    *  creates a snapshot for the totalSupply 
    * @param value uint256
    */
    function _increaseTotalSupply(uint256 value) internal {
        super._increaseTotalSupply(value);
        updateValueAtNow(_snapshotTotalSupply, totalSupply());
    }
}

/* eof (./contracts/token/ERC20/ERC20Snapshot.sol) */
/* file: ./contracts/whitelist/Whitelist.sol */
/**
 * @title Global Whitelist Contract
 * @author Validity Labs AG <[email protected]>
 */

pragma solidity 0.4.24;



contract Whitelist is Ownable {
    using SafeMath for uint256;

    address public multisigProxy;

    mapping(address => bool) public isWhitelisted;

    // allow managers add/update whitelist registrants
    // managers can be set and altered by owner, multiple manager accounts are possible
    mapping(address => bool) public isManager;

    // enable whitelist restrictions by default
    bool public isWhitelisting = true;

    /** EVENTS **/
    event ChangedManager(address indexed manager, bool active);
    event ChangedWhitelisting(address indexed registrant, bool whitelisted);
    event WhitelistDisabled();

    /** MODIFIERS **/
    modifier onlyManager() {
        require(isManager[msg.sender], "is not manager");
        _;
    }

    modifier onlyValidAddress(address _address) {
        require(_address != address(0), "invalid address");
        _;
    }

    modifier onlyMultisig() {
        require(msg.sender == multisigProxy);
        _;
    }

    /**
    *  constructor 
    */
    constructor(address _multisigProxy) public onlyValidAddress(_multisigProxy) {
        multisigProxy = _multisigProxy;
        setManager(msg.sender, true);
    }

    /**
     *  Set / alter manager / whitelister "account". This can be done from owner only
     * @param _manager address address of the manager to create/alter
     * @param _active bool flag that shows if the manager account is active
     */
    function setManager(address _manager, bool _active) public onlyOwner onlyValidAddress(_manager) {
        isManager[_manager] = _active;
        emit ChangedManager(_manager, _active);
    }

    /**
    *  getter to determine if address is in whitelist
    * @param _address address to check against whitelist mapping
    * @return bool is whitelisted
    */
    function whitelist(address _address) public view returns (bool) {
        return isWhitelisted[_address];
    }

    /**
    *  add an address to the whitelist
    * @param _address address
    */
    function addAddressToWhitelist(address _address) public onlyManager onlyValidAddress(_address) {
        isWhitelisted[_address] = true;
        emit ChangedWhitelisting(_address, true);
    }

    /**
    *  add addresses to the whitelist
    * @param _addresses addresses array
    */
    function addAddressesToWhitelist(address[] _addresses) public {
        for (uint256 i = 0; i < _addresses.length; i++) {
            addAddressToWhitelist(_addresses[i]);
        }
    }

    /**
    *  remove an address from the whitelist
    * @param _address address
    */
    function removeAddressFromWhitelist(address _address) public onlyManager onlyValidAddress(_address) {
        isWhitelisted[_address] = false;
        emit ChangedWhitelisting(_address, false);
    }

    /**
    *  remove addresses from the whitelist
    * @param _addresses addresses
    */
    function removeAddressesFromWhitelist(address[] _addresses) public {
        for (uint256 i = 0; i < _addresses.length; i++) {
            removeAddressFromWhitelist(_addresses[i]);
        }
    }

    /** 
    *  disable the whitelist, once done cannot be reversed
    */
    function disableWhitelist() public onlyMultisig {
        isWhitelisting = false;
        emit WhitelistDisabled();
    }
}

/* eof (./contracts/whitelist/Whitelist.sol) */
/* file: ./contracts/token/ERC20/ERC20Whitelist.sol */
/**
 * @title ERC20Whitelist
 * @author Validity Labs AG <[email protected]>
 */

pragma solidity 0.4.24;  



contract ERC20Whitelist is ERC20Custom {   
    bool public whitelistDisabled;
    Whitelist public whitelist;

    /*** EVENTS ***/
    event WhitelistDisabled();

    /*** FUNCTIONS ***/
    /** OVERRIDE
    *  transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    * @return bool
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        if (!whitelistDisabled && checkWhitelistEnabled()) {
            checkIfWhitelisted(msg.sender);
            checkIfWhitelisted(_to);
        }
        return super.transfer(_to, _value);
    }

    /** OVERRIDE
    *  Transfer tokens from one address to another
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the amount of tokens to be transferred
    * @return bool
    */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        if (!whitelistDisabled && checkWhitelistEnabled()) {
            checkIfWhitelisted(_from);
            checkIfWhitelisted(_to);
        }
        return super.transferFrom(_from, _to, _value);
    }

    /*** INTERNAL/PRIVATE ***/
    /**
    *  check if Global Whitelist is in effect. If not, update state to save gas
    * on external call
    * @return bool
    */
    function checkWhitelistEnabled() internal returns (bool) {
        if (!whitelist.isWhitelisting()) {
            whitelistDisabled = true;
            emit WhitelistDisabled();
            return false;
        } else {
            return true;
        }
    }

    /**
    *  check if the address has been whitelisted by the Whitelist contract
    * @param _account address of the account to check
    */
    function checkIfWhitelisted(address _account) internal view {
        require(whitelist.whitelist(_account), "not whitelisted");
    }
}

/* eof (./contracts/token/ERC20/ERC20Whitelist.sol) */
/* file: ./contracts/sygnum/SygnumToken.sol */
/**
 * @title Sygnum Token Contract
 * @author Validity Labs AG <[email protected]>
 */

pragma solidity 0.4.24;



contract SygnumToken is ERC20Detailed, ERC20Snapshot, ERC20PausableCustom, ERC20Whitelist {
    /*** FUNCTIONS ***/
    /**
    *  constructor
    * @param _name string
    * @param _symbol string
    * @param _decimal uint8
    * @param _multisigProxy address
    * @param _whitelist address
    * @param _newOwner address
    * @param _initialSupply uint256 initial total supply cap. can be 0
    */
    /* solhint-disable */
    constructor(string _name, string _symbol, uint8 _decimal, address _multisigProxy, address _whitelist, address _newOwner, uint256 _initialSupply)
        public 
        ERC20Custom(_initialSupply)
        ERC20Detailed(_name, _symbol, _decimal) {
            whitelist = Whitelist(_whitelist);
            multisigProxy = _multisigProxy;
            roleSetup(_newOwner);
        }
    /* solhint-enable */

    /**
    *  Transfers the current balance to the _recipient and terminates the contract.
    * @param _recipient address
    */
    function destroy(address _recipient) public onlyMultisigProxy {
        selfdestruct(_recipient);
    }

    /*** INTERNAL/PRIVATE ***/
    /** 
    *  setup roles for new Sygnum token
    * @param _newOwner address of the client owner
    */
    function roleSetup(address _newOwner) internal {
        addPauser(multisigProxy);
        _removePauser(msg.sender);

        addMinter(_newOwner);
        _removeMinter(msg.sender);
    }
}

/* eof (./contracts/sygnum/SygnumToken.sol) */
/* file: ./contracts/sygnum/TokenFactory.sol */
/**
 * @title Token Factory Contract
 * @author Validity Labs AG <[email protected]>
 */

pragma solidity 0.4.24;



/* solhint-disable max-line-length */
/* solhint-disable separate-by-one-line-in-contract */
contract TokenFactory is Ownable {
    address public whitelist;
    address public multisigProxy;

    /*** EVENTS ***/
    event NewTokenDeployed(address indexed contractAddress, string name, string symbol, uint8 decimals, 
        address indexed clientOwner);
    event UpdatedWhitelist(address indexed whitelist);

    /*** EVENTS ***/
    modifier onlyValidAddress(address _address) {
        require(_address != address(0));
        _;
    }

    /*** FUNCTIONS ***/
    /**
    *  constructor
    * @param _whitelist address of the whitelist
    * @param _multisigProxy address of the proxy contract
    */
    constructor(address _whitelist, address _multisigProxy) 
        public 
        onlyValidAddress(_whitelist)
        onlyValidAddress(_multisigProxy) {
            whitelist = _whitelist;
            multisigProxy = _multisigProxy;
        }

    /**
    *  allows owner to launch a new token with a new name, symbol, and decimals.
    * Defaults to using whitelist stored in this contract. If _whitelist is address(0), else it will use
    * _whitelist as the param to pass into the new token's constructor upon deployment 
    * @param _name string
    * @param _symbol string
    * @param _decimals uint8 
    * @param _clientOwner address
    * @param _whitelist address allowed to be 0x0, meaning use the contract's whitelist variable. Otherwise override
    * @param _initialSupply uint256 initial total supply cap
    */
    function newToken(string _name, string _symbol, uint8 _decimals, address _clientOwner, address _whitelist, uint256 _initialSupply) 
        public 
        onlyOwner 
        onlyValidAddress(_clientOwner) 
        returns (address) {
            require(bytes(_name).length > 0, "name cannot be blank");
            require(bytes(_symbol).length > 0, "symbol cannot be blank");

            address whitelistAddress;
            _whitelist == address(0) ? whitelistAddress = whitelist : whitelistAddress = _whitelist;

            SygnumToken token = new SygnumToken(_name, _symbol, _decimals, multisigProxy, whitelistAddress, _clientOwner, _initialSupply);
            emit NewTokenDeployed(address(token), _name, _symbol, _decimals, _clientOwner);
            return address(token);
        }

    /**
    *  updates the whitelist to be used for future generated tokens
    * @param _whitelist address
    */
    function updateWhitelist(address _whitelist) public onlyOwner onlyValidAddress(_whitelist) {
        whitelist = _whitelist;
        emit UpdatedWhitelist(whitelist);
    }
}

/* eof (./contracts/sygnum/TokenFactory.sol) */
