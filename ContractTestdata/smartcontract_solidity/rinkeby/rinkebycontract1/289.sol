/**
 *Submitted for verification at Etherscan.io on 2019-02-18
*/

// File: contracts/ownership/multiowned.sol

// Code taken from https://github.com/ethereum/dapp-bin/blob/master/wallet/wallet.sol
// Audit, refactoring and improvements by github.com/Eenae

// @authors:
// Gav Wood <[email protected]>
// inheritable "property" contract that enables methods to be protected by requiring the acquiescence of either a
// single, or, crucially, each of a number of, designated owners.
// usage:
// use modifiers onlyowner (just own owned) or onlymanyowners(hash), whereby the same hash must be provided by
// some number (specified in constructor) of the set of owners (specified in the constructor, modifiable) before the
// interior is executed.

pragma solidity ^0.4.15;


/// note: during any ownership changes all pending operations (waiting for more signatures) are cancelled
// TODO acceptOwnership
contract multiowned {

	// TYPES

    // struct for the status of a pending operation.
    struct MultiOwnedOperationPendingState {
        // count of confirmations needed
        uint yetNeeded;

        // bitmap of confirmations where owner #ownerIndex's decision corresponds to 2**ownerIndex bit
        uint ownersDone;

        // position of this operation key in m_multiOwnedPendingIndex
        uint index;
    }

	// EVENTS

    event Confirmation(address owner, bytes32 operation);
    event Revoke(address owner, bytes32 operation);
    event FinalConfirmation(address owner, bytes32 operation);

    // some others are in the case of an owner changing.
    event OwnerChanged(address oldOwner, address newOwner);
    event OwnerAdded(address newOwner);
    event OwnerRemoved(address oldOwner);

    // the last one is emitted if the required signatures change
    event RequirementChanged(uint newRequirement);

	// MODIFIERS

    // simple single-sig function modifier.
    modifier onlyowner {
        require(isOwner(msg.sender));
        _;
    }
    // multi-sig function modifier: the operation must have an intrinsic hash in order
    // that later attempts can be realised as the same underlying operation and
    // thus count as confirmations.
    modifier onlymanyowners(bytes32 _operation) {
        if (confirmAndCheck(_operation)) {
            _;
        }
        // Even if required number of confirmations has't been collected yet,
        // we can't throw here - because changes to the state have to be preserved.
        // But, confirmAndCheck itself will throw in case sender is not an owner.
    }

    modifier validNumOwners(uint _numOwners) {
        require(_numOwners > 0 && _numOwners <= c_maxOwners);
        _;
    }

    modifier multiOwnedValidRequirement(uint _required, uint _numOwners) {
        require(_required > 0 && _required <= _numOwners);
        _;
    }

    modifier ownerExists(address _address) {
        require(isOwner(_address));
        _;
    }

    modifier ownerDoesNotExist(address _address) {
        require(!isOwner(_address));
        _;
    }

    modifier multiOwnedOperationIsActive(bytes32 _operation) {
        require(isOperationActive(_operation));
        _;
    }

	// METHODS

    // constructor is given number of sigs required to do protected "onlymanyowners" transactions
    // as well as the selection of addresses capable of confirming them (msg.sender is not added to the owners!).
    function multiowned(address[] _owners, uint _required)
        validNumOwners(_owners.length)
        multiOwnedValidRequirement(_required, _owners.length)
    {
        assert(c_maxOwners <= 255);

        m_numOwners = _owners.length;
        m_multiOwnedRequired = _required;

        for (uint i = 0; i < _owners.length; ++i)
        {
            address owner = _owners[i];
            // invalid and duplicate addresses are not allowed
            require(0 != owner && !isOwner(owner) /* not isOwner yet! */);

            uint currentOwnerIndex = checkOwnerIndex(i + 1 /* first slot is unused */);
            m_owners[currentOwnerIndex] = owner;
            m_ownerIndex[owner] = currentOwnerIndex;
        }

        assertOwnersAreConsistent();
    }

    /// @notice replaces an owner `_from` with another `_to`.
    /// @param _from address of owner to replace
    /// @param _to address of new owner
    // All pending operations will be canceled!
    function changeOwner(address _from, address _to)
        external
        ownerExists(_from)
        ownerDoesNotExist(_to)
        onlymanyowners(sha3(msg.data))
    {
        assertOwnersAreConsistent();

        clearPending();
        uint ownerIndex = checkOwnerIndex(m_ownerIndex[_from]);
        m_owners[ownerIndex] = _to;
        m_ownerIndex[_from] = 0;
        m_ownerIndex[_to] = ownerIndex;

        assertOwnersAreConsistent();
        OwnerChanged(_from, _to);
    }

    /// @notice adds an owner
    /// @param _owner address of new owner
    // All pending operations will be canceled!
    function addOwner(address _owner)
        external
        ownerDoesNotExist(_owner)
        validNumOwners(m_numOwners + 1)
        onlymanyowners(sha3(msg.data))
    {
        assertOwnersAreConsistent();

        clearPending();
        m_numOwners++;
        m_owners[m_numOwners] = _owner;
        m_ownerIndex[_owner] = checkOwnerIndex(m_numOwners);

        assertOwnersAreConsistent();
        OwnerAdded(_owner);
    }

    /// @notice removes an owner
    /// @param _owner address of owner to remove
    // All pending operations will be canceled!
    function removeOwner(address _owner)
        external
        ownerExists(_owner)
        validNumOwners(m_numOwners - 1)
        multiOwnedValidRequirement(m_multiOwnedRequired, m_numOwners - 1)
        onlymanyowners(sha3(msg.data))
    {
        assertOwnersAreConsistent();

        clearPending();
        uint ownerIndex = checkOwnerIndex(m_ownerIndex[_owner]);
        m_owners[ownerIndex] = 0;
        m_ownerIndex[_owner] = 0;
        //make sure m_numOwners is equal to the number of owners and always points to the last owner
        reorganizeOwners();

        assertOwnersAreConsistent();
        OwnerRemoved(_owner);
    }

    /// @notice changes the required number of owner signatures
    /// @param _newRequired new number of signatures required
    // All pending operations will be canceled!
    function changeRequirement(uint _newRequired)
        external
        multiOwnedValidRequirement(_newRequired, m_numOwners)
        onlymanyowners(sha3(msg.data))
    {
        m_multiOwnedRequired = _newRequired;
        clearPending();
        RequirementChanged(_newRequired);
    }

    /// @notice Gets an owner by 0-indexed position
    /// @param ownerIndex 0-indexed owner position
    function getOwner(uint ownerIndex) public constant returns (address) {
        return m_owners[ownerIndex + 1];
    }

    /// @notice Gets owners
    /// @return memory array of owners
    function getOwners() public constant returns (address[]) {
        address[] memory result = new address[](m_numOwners);
        for (uint i = 0; i < m_numOwners; i++)
            result[i] = getOwner(i);

        return result;
    }

    /// @notice checks if provided address is an owner address
    /// @param _addr address to check
    /// @return true if it's an owner
    function isOwner(address _addr) public constant returns (bool) {
        return m_ownerIndex[_addr] > 0;
    }

    /// @notice Tests ownership of the current caller.
    /// @return true if it's an owner
    // It's advisable to call it by new owner to make sure that the same erroneous address is not copy-pasted to
    // addOwner/changeOwner and to isOwner.
    function amIOwner() external constant onlyowner returns (bool) {
        return true;
    }

    /// @notice Revokes a prior confirmation of the given operation
    /// @param _operation operation value, typically sha3(msg.data)
    function revoke(bytes32 _operation)
        external
        multiOwnedOperationIsActive(_operation)
        onlyowner
    {
        uint ownerIndexBit = makeOwnerBitmapBit(msg.sender);
        var pending = m_multiOwnedPending[_operation];
        require(pending.ownersDone & ownerIndexBit > 0);

        assertOperationIsConsistent(_operation);

        pending.yetNeeded++;
        pending.ownersDone -= ownerIndexBit;

        assertOperationIsConsistent(_operation);
        Revoke(msg.sender, _operation);
    }

    /// @notice Checks if owner confirmed given operation
    /// @param _operation operation value, typically sha3(msg.data)
    /// @param _owner an owner address
    function hasConfirmed(bytes32 _operation, address _owner)
        external
        constant
        multiOwnedOperationIsActive(_operation)
        ownerExists(_owner)
        returns (bool)
    {
        return !(m_multiOwnedPending[_operation].ownersDone & makeOwnerBitmapBit(_owner) == 0);
    }

    // INTERNAL METHODS

    function confirmAndCheck(bytes32 _operation)
        private
        onlyowner
        returns (bool)
    {
        if (512 == m_multiOwnedPendingIndex.length)
            // In case m_multiOwnedPendingIndex grows too much we have to shrink it: otherwise at some point
            // we won't be able to do it because of block gas limit.
            // Yes, pending confirmations will be lost. Dont see any security or stability implications.
            // TODO use more graceful approach like compact or removal of clearPending completely
            clearPending();

        var pending = m_multiOwnedPending[_operation];

        // if we're not yet working on this operation, switch over and reset the confirmation status.
        if (! isOperationActive(_operation)) {
            // reset count of confirmations needed.
            pending.yetNeeded = m_multiOwnedRequired;
            // reset which owners have confirmed (none) - set our bitmap to 0.
            pending.ownersDone = 0;
            pending.index = m_multiOwnedPendingIndex.length++;
            m_multiOwnedPendingIndex[pending.index] = _operation;
            assertOperationIsConsistent(_operation);
        }

        // determine the bit to set for this owner.
        uint ownerIndexBit = makeOwnerBitmapBit(msg.sender);
        // make sure we (the message sender) haven't confirmed this operation previously.
        if (pending.ownersDone & ownerIndexBit == 0) {
            // ok - check if count is enough to go ahead.
            assert(pending.yetNeeded > 0);
            if (pending.yetNeeded == 1) {
                // enough confirmations: reset and run interior.
                delete m_multiOwnedPendingIndex[m_multiOwnedPending[_operation].index];
                delete m_multiOwnedPending[_operation];
                FinalConfirmation(msg.sender, _operation);
                return true;
            }
            else
            {
                // not enough: record that this owner in particular confirmed.
                pending.yetNeeded--;
                pending.ownersDone |= ownerIndexBit;
                assertOperationIsConsistent(_operation);
                Confirmation(msg.sender, _operation);
            }
        }
    }

    // Reclaims free slots between valid owners in m_owners.
    // TODO given that its called after each removal, it could be simplified.
    function reorganizeOwners() private {
        uint free = 1;
        while (free < m_numOwners)
        {
            // iterating to the first free slot from the beginning
            while (free < m_numOwners && m_owners[free] != 0) free++;

            // iterating to the first occupied slot from the end
            while (m_numOwners > 1 && m_owners[m_numOwners] == 0) m_numOwners--;

            // swap, if possible, so free slot is located at the end after the swap
            if (free < m_numOwners && m_owners[m_numOwners] != 0 && m_owners[free] == 0)
            {
                // owners between swapped slots should't be renumbered - that saves a lot of gas
                m_owners[free] = m_owners[m_numOwners];
                m_ownerIndex[m_owners[free]] = free;
                m_owners[m_numOwners] = 0;
            }
        }
    }

    function clearPending() private onlyowner {
        uint length = m_multiOwnedPendingIndex.length;
        // TODO block gas limit
        for (uint i = 0; i < length; ++i) {
            if (m_multiOwnedPendingIndex[i] != 0)
                delete m_multiOwnedPending[m_multiOwnedPendingIndex[i]];
        }
        delete m_multiOwnedPendingIndex;
    }

    function checkOwnerIndex(uint ownerIndex) private constant returns (uint) {
        assert(0 != ownerIndex && ownerIndex <= c_maxOwners);
        return ownerIndex;
    }

    function makeOwnerBitmapBit(address owner) private constant returns (uint) {
        uint ownerIndex = checkOwnerIndex(m_ownerIndex[owner]);
        return 2 ** ownerIndex;
    }

    function isOperationActive(bytes32 _operation) private constant returns (bool) {
        return 0 != m_multiOwnedPending[_operation].yetNeeded;
    }


    function assertOwnersAreConsistent() private constant {
        assert(m_numOwners > 0);
        assert(m_numOwners <= c_maxOwners);
        assert(m_owners[0] == 0);
        assert(0 != m_multiOwnedRequired && m_multiOwnedRequired <= m_numOwners);
    }

    function assertOperationIsConsistent(bytes32 _operation) private constant {
        var pending = m_multiOwnedPending[_operation];
        assert(0 != pending.yetNeeded);
        assert(m_multiOwnedPendingIndex[pending.index] == _operation);
        assert(pending.yetNeeded <= m_multiOwnedRequired);
    }


   	// FIELDS

    uint constant c_maxOwners = 250;

    // the number of owners that must confirm the same operation before it is run.
    uint public m_multiOwnedRequired;


    // pointer used to find a free slot in m_owners
    uint public m_numOwners;

    // list of owners (addresses),
    // slot 0 is unused so there are no owner which index is 0.
    // TODO could we save space at the end of the array for the common case of <10 owners? and should we?
    address[256] internal m_owners;

    // index on the list of owners to allow reverse lookup: owner address => index in m_owners
    mapping(address => uint) internal m_ownerIndex;


    // the ongoing operations.
    mapping(bytes32 => MultiOwnedOperationPendingState) internal m_multiOwnedPending;
    bytes32[] internal m_multiOwnedPendingIndex;
}

// File: contracts/crowdsale/FixedTimeBonuses.sol

pragma solidity ^0.4.15;


library FixedTimeBonuses {

    struct Bonus {
        uint endTime;
        uint bonus;
    }

    struct Data {
        Bonus[] bonuses;
    }

    /// @dev validates consistency of data structure
    /// @param self data structure
    /// @param shouldDecrease additionally check if bonuses are decreasing over time
    function validate(Data storage self, bool shouldDecrease) internal constant {
        uint length = self.bonuses.length;
        require(length > 0);

        Bonus storage last = self.bonuses[0];
        for (uint i = 1; i < length; i++) {
            Bonus storage current = self.bonuses[i];
            require(current.endTime > last.endTime);
            if (shouldDecrease)
                require(current.bonus < last.bonus);
            last = current;
        }
    }

    /// @dev get ending time of the last bonus
    /// @param self data structure
    function getLastTime(Data storage self) internal constant returns (uint) {
        return self.bonuses[self.bonuses.length - 1].endTime;
    }

    /// @dev validates consistency of data structure
    /// @param self data structure
    /// @param time time for which bonus must be computed (assuming time <= getLastTime())
    function getBonus(Data storage self, uint time) internal constant returns (uint) {
        // TODO binary search?
        uint length = self.bonuses.length;
        for (uint i = 0; i < length; i++) {
            if (self.bonuses[i].endTime >= time)
                return self.bonuses[i].bonus;
        }
        assert(false);  // must be unreachable
    }
}

// File: contracts/ownership/MultiownedControlled.sol

pragma solidity ^0.4.15;



/**
 * @title Contract which is owned by owners and operated by controller.
 *
 * @notice Provides a way to set up an entity (typically other contract) entitled to control actions of this contract.
 * Controller is set up by owners or during construction.
 *
 * @dev controller check is performed by onlyController modifier.
 */
contract MultiownedControlled is multiowned {

    event ControllerSet(address controller);
    event ControllerRetired(address was);


    modifier onlyController {
        require(msg.sender == m_controller);
        _;
    }


    // PUBLIC interface

    function MultiownedControlled(address[] _owners, uint _signaturesRequired, address _controller)
        multiowned(_owners, _signaturesRequired)
    {
        m_controller = _controller;
        ControllerSet(m_controller);
    }

    /// @dev sets the controller
    function setController(address _controller) external onlymanyowners(sha3(msg.data)) {
        m_controller = _controller;
        ControllerSet(m_controller);
    }

    /// @dev ability for controller to step down
    function detachController() external onlyController {
        address was = m_controller;
        m_controller = address(0);
        ControllerRetired(was);
    }


    // FIELDS

    /// @notice address of entity entitled to mint new tokens
    address public m_controller;
}

// File: contracts/security/ArgumentsChecker.sol

pragma solidity ^0.4.15;


/// @title utility methods and modifiers of arguments validation
contract ArgumentsChecker {

    /// @dev check which prevents short address attack
    modifier payloadSizeIs(uint size) {
       require(msg.data.length == size + 4 /* function selector */);
       _;
    }

    /// @dev check that address is valid
    modifier validAddress(address addr) {
        require(addr != address(0));
        _;
    }
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.4.18;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: zeppelin-solidity/contracts/ReentrancyGuard.sol

pragma solidity ^0.4.18;

/**
 * @title Helps contracts guard agains rentrancy attacks.
 * @author Remco Bloemen <[email protected]π.com>
 * @notice If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /**
   * @dev We use a single lock for the whole contract.
   */
  bool private rentrancy_lock = false;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * @notice If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one nonReentrant function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and a `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(!rentrancy_lock);
    rentrancy_lock = true;
    _;
    rentrancy_lock = false;
  }

}

// File: contracts/crowdsale/FundsRegistry.sol

pragma solidity ^0.4.15;






/// @title registry of funds sent by investors
contract FundsRegistry is ArgumentsChecker, MultiownedControlled, ReentrancyGuard {
    using SafeMath for uint256;

    enum State {
        // gathering funds
        GATHERING,
        // returning funds to investors
        REFUNDING,
        // funds can be pulled by owners
        SUCCEEDED
    }

    event StateChanged(State _state);
    event Invested(address indexed investor, uint256 amount);
    event EtherSent(address indexed to, uint value);
    event RefundSent(address indexed to, uint value);


    modifier requiresState(State _state) {
        require(m_state == _state);
        _;
    }


    // PUBLIC interface

    function FundsRegistry(address[] _owners, uint _signaturesRequired, address _controller)
        MultiownedControlled(_owners, _signaturesRequired, _controller)
    {
    }

    /// @dev performs only allowed state transitions
    function changeState(State _newState)
        external
        onlyController
    {
        assert(m_state != _newState);

        if (State.GATHERING == m_state) {   assert(State.REFUNDING == _newState || State.SUCCEEDED == _newState); }
        else assert(false);

        m_state = _newState;
        StateChanged(m_state);
    }

    /// @dev records an investment
    function invested(address _investor)
        external
        payable
        onlyController
        requiresState(State.GATHERING)
    {
        uint256 amount = msg.value;
        require(0 != amount);
        assert(_investor != m_controller);

        // register investor
        if (0 == m_weiBalances[_investor])
            m_investors.push(_investor);

        // register payment
        totalInvested = totalInvested.add(amount);
        m_weiBalances[_investor] = m_weiBalances[_investor].add(amount);

        Invested(_investor, amount);
    }

    /// @notice owners: send `value` of ether to address `to`, can be called if crowdsale succeeded
    /// @param to where to send ether
    /// @param value amount of wei to send
    function sendEther(address to, uint value)
        external
        validAddress(to)
        onlymanyowners(sha3(msg.data))
        requiresState(State.SUCCEEDED)
    {
        require(value > 0 && this.balance >= value);
        to.transfer(value);
        EtherSent(to, value);
    }

    /// @notice withdraw accumulated balance, called by payee in case crowdsale failed
    function withdrawPayments()
        external
        nonReentrant
        requiresState(State.REFUNDING)
    {
        address payee = msg.sender;
        uint256 payment = m_weiBalances[payee];

        require(payment != 0);
        require(this.balance >= payment);

        totalInvested = totalInvested.sub(payment);
        m_weiBalances[payee] = 0;

        payee.transfer(payment);
        RefundSent(payee, payment);
    }

    function getInvestorsCount() external constant returns (uint) { return m_investors.length; }


    // FIELDS

    /// @notice total amount of investments in wei
    uint256 public totalInvested;

    /// @notice state of the registry
    State public m_state = State.GATHERING;

    /// @dev balances of investors in wei
    mapping(address => uint256) public m_weiBalances;

    /// @dev list of unique investors
    address[] public m_investors;
}

// File: zeppelin-solidity/contracts/token/ERC20Basic.sol

pragma solidity ^0.4.18;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: zeppelin-solidity/contracts/token/BasicToken.sol

pragma solidity ^0.4.18;




/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

// File: zeppelin-solidity/contracts/token/ERC20.sol

pragma solidity ^0.4.18;



/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: zeppelin-solidity/contracts/token/StandardToken.sol

pragma solidity ^0.4.18;




/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

// File: contracts/token/CirculatingToken.sol

pragma solidity ^0.4.15;



/// @title StandardToken which circulation can be delayed and started by another contract.
/// @dev To be used as a mixin contract.
/// The contract is created in disabled state: circulation is disabled.
contract CirculatingToken is StandardToken {

    event CirculationEnabled();

    modifier requiresCirculation {
        require(m_isCirculating);
        _;
    }


    // PUBLIC interface

    function transfer(address _to, uint256 _value) requiresCirculation returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) requiresCirculation returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) requiresCirculation returns (bool) {
        return super.approve(_spender, _value);
    }


    // INTERNAL functions

    function enableCirculation() internal returns (bool) {
        if (m_isCirculating)
            return false;

        m_isCirculating = true;
        CirculationEnabled();
        return true;
    }


    // FIELDS

    /// @notice are the circulation started?
    bool public m_isCirculating;
}

// File: contracts/token/MintableMultiownedToken.sol

pragma solidity ^0.4.15;




/// @title StandardToken which can be minted by another contract.
contract MintableMultiownedToken is MultiownedControlled, StandardToken {

    event Mint(address indexed to, uint256 amount);


    // PUBLIC interface

    function MintableMultiownedToken(address[] _owners, uint _signaturesRequired, address _minter)
        MultiownedControlled(_owners, _signaturesRequired, _minter)
    {
    }

    /// @dev mints new tokens
    function mint(address _to, uint256 _amount) external onlyController {
        require(m_externalMintingEnabled);
        mintInternal(_to, _amount);
    }

    /// @dev disables mint(), irreversible!
    function disableMinting() external onlyController {
        require(m_externalMintingEnabled);
        m_externalMintingEnabled = false;
    }


    // INTERNAL functions

    function mintInternal(address _to, uint256 _amount) internal {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(this, _to, _amount);
        Mint(_to, _amount);
    }


    // FIELDS

    /// @notice if this true then token is still externally mintable (but this flag does't affect emissions!)
    bool public m_externalMintingEnabled = true;
}

// File: contracts/NanoToken.sol

pragma solidity ^0.4.15;




/// @title Storiqa coin contract
contract NanoToken is CirculatingToken, MintableMultiownedToken {


    // PUBLIC interface

    function NanoToken(address[] _owners)
        MintableMultiownedToken(_owners, 2, /* minter: */ address(0))
    {
        require(3 == _owners.length);
    }

    /// @dev Allows token transfers
    function startCirculation() external onlyController {
        assert(enableCirculation());    // must be called once
    }


    // FIELDS

    string public constant name = 'Nano Token';
    string public constant symbol = 'NNT';
    uint8 public constant decimals = 18;
}

// File: zeppelin-solidity/contracts/math/Math.sol

pragma solidity ^0.4.18;

/**
 * @title Math
 * @dev Assorted math operations
 */

library Math {
  function max64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal pure returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal pure returns (uint256) {
    return a < b ? a : b;
  }
}

// File: contracts/Crowdsale.sol

pragma solidity ^0.4.15;










/// @title Nano ICO contract
contract Crowdsale is ArgumentsChecker, ReentrancyGuard, multiowned {
    using Math for uint256;
    using SafeMath for uint256;
    using FixedTimeBonuses for FixedTimeBonuses.Data;

    enum IcoState { INIT, ICO, PAUSED, FAILED, SUCCEEDED }


    event StateChanged(IcoState _state);
    event FundTransfer(address backer, uint amount, bool isContribution);


    modifier requiresState(IcoState _state) {
        require(m_state == _state);
        _;
    }

    /// @dev triggers some state changes based on current time
    /// @param investor optional refund parameter
    /// @param payment optional refund parameter
    /// note: function body could be skipped!
    modifier timedStateChange(address investor, uint payment) {
        if (IcoState.INIT == m_state && getCurrentTime() >= getStartTime())
            changeState(IcoState.ICO);

        if (IcoState.ICO == m_state && getCurrentTime() >= getEndTime()) {
            finishICO();

            if (payment > 0)
                investor.transfer(payment);
            // note that execution of further (but not preceding!) modifiers and functions ends here
        } else {
            _;
        }
    }

    /// @dev automatic check for unaccounted withdrawals
    /// @param investor optional refund parameter
    /// @param payment optional refund parameter
    modifier fundsChecker(address investor, uint payment) {
        uint atTheBeginning = m_funds.balance;
        if (atTheBeginning < m_lastFundsAmount) {
            changeState(IcoState.PAUSED);
            if (payment > 0)
                investor.transfer(payment);     // we cant throw (have to save state), so refunding this way
            // note that execution of further (but not preceding!) modifiers and functions ends here
        } else {
            _;

            if (m_funds.balance < atTheBeginning) {
                changeState(IcoState.PAUSED);
            } else {
                m_lastFundsAmount = m_funds.balance;
            }
        }
    }


    // PUBLIC interface

    function Crowdsale(address[] _owners, address _token, address _funds, address _teamTokens)
        multiowned(_owners, 2)
        validAddress(_token)
        validAddress(_funds)
        validAddress(_teamTokens)
    {
        require(3 == _owners.length);

        m_token = NanoToken(_token);
        m_funds = FundsRegistry(_funds);
        m_teamTokens = _teamTokens;

        m_bonuses.bonuses.push(FixedTimeBonuses.Bonus({endTime: c_startTime + (1 weeks), bonus: 30}));
        m_bonuses.bonuses.push(FixedTimeBonuses.Bonus({endTime: c_startTime + (2 weeks), bonus: 25}));
        m_bonuses.bonuses.push(FixedTimeBonuses.Bonus({endTime: c_startTime + (3 weeks), bonus: 20}));
        m_bonuses.bonuses.push(FixedTimeBonuses.Bonus({endTime: c_startTime + (4 weeks), bonus: 15}));
        m_bonuses.bonuses.push(FixedTimeBonuses.Bonus({endTime: c_startTime + (5 weeks), bonus: 10}));
        m_bonuses.bonuses.push(FixedTimeBonuses.Bonus({endTime: c_startTime + (8 weeks), bonus: 5}));
        m_bonuses.bonuses.push(FixedTimeBonuses.Bonus({endTime: 1535760000, bonus: 0}));
        m_bonuses.validate(true);

        deployer = msg.sender;
    }


    // PUBLIC interface: payments

    // fallback function as a shortcut
    function() payable {
        require(0 == msg.data.length);
        buy();  // only internal call here!
    }

    /// @notice ICO participation
    function buy() public payable {     // dont mark as external!
        iaOnInvested(msg.sender, msg.value, false);
    }

    function iaOnInvested(address investor, uint payment, bool usingPaymentChannel)
        internal
        nonReentrant
        timedStateChange(investor, payment)
        fundsChecker(investor, payment)
    {
        require(m_state == IcoState.ICO || m_state == IcoState.INIT && isOwner(investor) /* for final test */);

        require(payment >= c_MinInvestment);

        uint startingInvariant = this.balance.add(m_funds.balance);

        // checking for max cap
        uint fundsAllowed = getMaximumFunds().sub(getTotalInvested());
        assert(0 != fundsAllowed);  // in this case state must not be IcoState.ICO
        payment = fundsAllowed.min256(payment);
        uint256 change = msg.value.sub(payment);

        // issue tokens
        var (nano, timeBonus) = calcAmount(payment, usingPaymentChannel ? c_paymentChannelBonusPercent : 0);
        m_token.mint(investor, nano);

        // record payment
        m_funds.invested.value(payment)(investor);
        FundTransfer(investor, payment, true);

        // check if ICO must be closed early
        if (change > 0)
        {
            assert(getMaximumFunds() == getTotalInvested());
            finishICO();

            // send change
            investor.transfer(change);
            assert(startingInvariant == this.balance.add(m_funds.balance).add(change));
        }
        else
            assert(startingInvariant == this.balance.add(m_funds.balance));
    }


    // PUBLIC interface: owners: maintenance

    /// @notice pauses ICO
    function pause()
        external
        timedStateChange(address(0), 0)
        requiresState(IcoState.ICO)
        onlyowner
    {
        changeState(IcoState.PAUSED);
    }

    /// @notice resume paused ICO
    function unpause()
        external
        timedStateChange(address(0), 0)
        requiresState(IcoState.PAUSED)
        onlymanyowners(sha3(msg.data))
    {
        changeState(IcoState.ICO);
        checkTime();
    }

    /// @notice consider paused ICO as failed
    function fail()
        external
        timedStateChange(address(0), 0)
        requiresState(IcoState.PAUSED)
        onlymanyowners(sha3(msg.data))
    {
        changeState(IcoState.FAILED);
    }

    /// @notice In case we need to attach to existent token
    function setToken(address _token)
        external
        validAddress(_token)
        timedStateChange(address(0), 0)
        requiresState(IcoState.PAUSED)
        onlymanyowners(sha3(msg.data))
    {
        m_token = NanoToken(_token);
    }

    /// @notice In case we need to attach to existent funds
    function setFundsRegistry(address _funds)
        external
        validAddress(_funds)
        timedStateChange(address(0), 0)
        requiresState(IcoState.PAUSED)
        onlymanyowners(sha3(msg.data))
    {
        m_funds = FundsRegistry(_funds);
    }

    /// @notice explicit trigger for timed state changes
    function checkTime()
        public
        timedStateChange(address(0), 0)
        onlyowner
    {
    }


    // INTERNAL functions

    function finishICO() private {
        if (getTotalInvested() < getMinFunds())
            changeState(IcoState.FAILED);
        else
            changeState(IcoState.SUCCEEDED);
    }

    /// @dev performs only allowed state transitions
    function changeState(IcoState _newState) private {
        assert(m_state != _newState);

        if (IcoState.INIT == m_state) {        assert(IcoState.ICO == _newState); }
        else if (IcoState.ICO == m_state) {    assert(IcoState.PAUSED == _newState || IcoState.FAILED == _newState || IcoState.SUCCEEDED == _newState); }
        else if (IcoState.PAUSED == m_state) { assert(IcoState.ICO == _newState || IcoState.FAILED == _newState); }
        else assert(false);

        m_state = _newState;
        StateChanged(m_state);

        // this should be tightly linked
        if (IcoState.SUCCEEDED == m_state) {
            onSuccess();
        } else if (IcoState.FAILED == m_state) {
            onFailure();
        }
    }

    function onSuccess() private {
        // mint tokens for owners
        uint tokensForTeam = m_token.totalSupply().mul(40).div(60);
        m_token.mint(m_teamTokens, tokensForTeam);

        m_funds.detachController();

        m_token.disableMinting();
        m_token.startCirculation();
        m_token.detachController();
    }

    function onFailure() private {
        m_funds.changeState(FundsRegistry.State.REFUNDING);
        m_funds.detachController();
    }


    function getLargePaymentBonus(uint payment) private constant returns (uint) {
        if (payment > 5000 ether) return 20;
        if (payment > 3000 ether) return 15;
        if (payment > 1000 ether) return 10;
        if (payment > 800 ether) return 8;
        if (payment > 500 ether) return 5;
        if (payment > 200 ether) return 2;
        return 0;
    }

    /// @dev calculates amount of nano to which payer of _wei is entitled
    function calcAmount(uint _wei, uint extraBonus) private constant returns (uint nano, uint timeBonus) {
        timeBonus = m_bonuses.getBonus(getCurrentTime());
        uint bonus = extraBonus.add(timeBonus).add(getLargePaymentBonus(_wei));

        // apply bonus
        nano = _wei.mul(c_NANOperETH).mul(bonus.add(100)).div(100);
    }


    /// @dev start time of the ICO, inclusive
    function getStartTime() private constant returns (uint) {
        return c_startTime;
    }

    /// @dev end time of the ICO, inclusive
    function getEndTime() private constant returns (uint) {
        return m_bonuses.getLastTime();
    }

    /// @dev to be overridden in tests
    function getCurrentTime() internal constant returns (uint) {
        return now;
    }

    /// @dev to be overridden in tests
    function getMinFunds() internal constant returns (uint) {
        return c_MinFunds;
    }

    /// @dev to be overridden in tests
    function getMaximumFunds() internal constant returns (uint) {
        return c_MaximumFunds;
    }

    /// @dev amount of investments during all crowdsales
    function getTotalInvested() internal constant returns (uint) {
        return m_funds.totalInvested();
    }


    // FIELDS

    /// @notice starting exchange rate of Nano
    uint public constant c_NANOperETH = 100000;

    /// @notice minimum investment
    uint public constant c_MinInvestment = 10 finney;

    /// @notice minimum investments to consider ICO as a success
    uint public constant c_MinFunds = 30000 ether;

    /// @notice maximum investments to be accepted during ICO
    uint public constant c_MaximumFunds = 90000 ether;

    /// @notice start time of the ICO
    uint public constant c_startTime = 1527811200;

    /// @notice authorised payment bonus
    uint public constant c_paymentChannelBonusPercent = 2;

    /// @notice timed bonuses
    FixedTimeBonuses.Data m_bonuses;


    /// @dev state of the ICO
    IcoState public m_state = IcoState.INIT;

    /// @dev contract responsible for token accounting
    NanoToken public m_token;

    address public m_teamTokens;

    address public deployer;

    /// @dev contract responsible for investments accounting
    FundsRegistry public m_funds;

    /// @dev last recorded funds
    uint256 public m_lastFundsAmount;
}
