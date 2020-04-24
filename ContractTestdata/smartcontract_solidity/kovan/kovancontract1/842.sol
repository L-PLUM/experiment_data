/**
 *Submitted for verification at Etherscan.io on 2018-12-26
*/

pragma solidity ^0.4.24;

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
    require(account != 0);
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
    require(account != 0);
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

// File: openzeppelin-solidity/contracts/access/Roles.sol

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
  function has(Role storage role, address account)
    internal
    view
    returns (bool)
  {
    require(account != address(0));
    return role.bearer[account];
  }
}

// File: openzeppelin-solidity/contracts/access/roles/MinterRole.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Mintable.sol

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
  function mint(
    address to,
    uint256 value
  )
    public
    onlyMinter
    returns (bool)
  {
    _mint(to, value);
    return true;
  }
}

// File: contracts/ContinuousIICO.sol

/* THIS IS A WORK IN PROGRESS, DO NOT TRUST THIS CONTRACT! */


pragma solidity ^0.4.24;




contract ContinuousIICO {

    /* *** General *** */
    address public owner;       // The one setting up the contract.
    address public beneficiary = 0x801bc7c678E8C9868f9FAE4F7346A8f7e302c1cC; // The address which will get the funds.

    /* *** Bid *** */
    uint constant HEAD = 0;            // Minimum value used for both the maxValuation and bidID of the head of the linked list.
    uint constant TAIL = uint(-1);     // Maximum value used for both the maxValuation and bidID of the tail of the linked list.
    uint constant INFINITY = uint(-2); // A value so high that a bid using it is guaranteed to succeed. Still lower than TAIL to be placed before TAIL.
    // A bid to buy tokens as long as the personal maximum valuation is not exceeded.
    // Bids are in a sorted doubly linked list.
    // They are sorted in ascending order by (maxValuation,bidID) where bidID is the ID and key of the bid in the mapping.
    // The list contains two artificial bids HEAD and TAIL having respectively the minimum and maximum bidID and maxValuation.
    struct Bid {
        /* *** Linked List Members *** */
        uint prev;                              // bidID of the previous element.
        uint next;                              // bidID of the next element.
        /* ***     Bid Members     *** */
        uint maxValuation;                      // Maximum valuation in wei beyond which the contributor prefers refund.
        uint contrib;                           // Contribution in wei.
        address contributor;                    // The contributor who placed the bid.
        bool redeemed;                          // True if the ETH or tokens have been redeemed.
        uint subSaleNumber;
    }
    uint public globalLastBidID = 0;            // The last bidID not accounting TAIL.
    mapping (address => uint[]) public contributorBidIDs; // Map contributor to a list of its bid ID.
    mapping (uint => Bid) public bids;          // Map bidID to bid.

    /* *** Sale constants *** */
    uint public durationPerSubSale = 86400;     // Each sale lasts 86400 seconds (24 hours)
    uint public numberOfSubSales = 365;         // This will be a year long sale (365 days)
    uint public tokensPerSubSale;               // Will be initialized when sale gets started.

    /* *** Sale parameters *** */
    uint public startTime;                      // When the sale starts.
    uint public endTime;                        // When the sale ends.
    ERC20 public token;                         // The token which is sold.
    uint public tokensForSale;
    /* *** Finalization variables *** */
    bool[] public finalized;                    // True when the cutting bid has been found. The following variables are final only after finalized==true.
    uint[] public headBidIDs;
    uint[] public tailBidIDs;
    uint[] public cutOffBidIDs;                 // The first accepted bid. All bids after it are accepted.
    uint[] public sumAcceptedContribs;          // The sum of accepted contributions.

    /* *** Events *** */
    event BidSubmitted(address indexed contributor, uint indexed bidID, uint indexed time);

    /* *** Modifiers *** */
    modifier onlyOwner{ require(owner == msg.sender); _; }

    /* *** Functions Modifying the state *** */

    /** @dev Constructor. First contract set up (tokens will also need to be transferred to the contract and then setToken needs to be called to finish the setup).
     */
    constructor() public {
        owner = msg.sender;

    }

    function startTimeOfSubSale(uint _day) view returns (uint){
      return startTime + (_day * durationPerSubSale);
    }

    function endTimeOfSubSale(uint _day) view returns(uint){
      return startTimeOfSubSale(_day) + durationPerSubSale;
    }

    function startSale(uint _startTime) {
      require(address(token) != address(0));
      require(tokensForSale != 0);
      require(startTime > now);

      startTime = _startTime;
      endTime = startTime + (numberOfSubSales * durationPerSubSale);
      tokensPerSubSale = tokensForSale / numberOfSubSales;

      for(uint i = 0; i < numberOfSubSales; i++){
        headBidIDs[i] = 0 - i;
        tailBidIDs[i] = uint(-1) -i;
        cutOffBidIDs[i] = tailBidIDs[i];
      }
    }

    /** @dev Set the token. Must only be called after the IICO contract receives the tokens to be sold.
     *  @param _token The token to be sold.
     */
    function setToken(ERC20 _token) public onlyOwner {
        require(address(token) == address(0)); // Make sure the token is not already set.

        token = _token;
        tokensForSale = token.balanceOf(this);
    }

    function getOngoingSubSaleNumber() view returns(uint){
      return (now - startTime) / durationPerSubSale;
    }

    /** @dev Submit a bid. The caller must give the exact position the bid must be inserted into in the list.
     *  In practice, use searchAndBid to avoid the position being incorrect due to a new bid being inserted and changing the position the bid must be inserted at.
     *  @param _maxValuation The maximum valuation given by the contributor. If the amount raised is higher, the bid is cancelled and the contributor refunded because it prefers a refund instead of this level of dilution. To buy no matter what, use INFINITY.
     *  @param _next The bidID of the next bid in the list.
     */
    function submitBid(uint _maxValuation, uint _next) public payable {
        uint currentSaleNumber = getOngoingSubSaleNumber();

        Bid storage nextBid = bids[_next];

        require(nextBid.subSaleNumber == currentSaleNumber);

        uint prev = nextBid.prev;
        Bid storage prevBid = bids[prev];
        require(_maxValuation >= prevBid.maxValuation && _maxValuation < nextBid.maxValuation); // The new bid maxValuation is higher than the previous one and strictly lower than the next one.
        require(now >= startTime && now < endTime); // Check that the bids are still open.

        ++globalLastBidID; // Increment the globalLastBidID. It will be the new bid's ID.
        // Update the pointers of neighboring bids.
        prevBid.next = globalLastBidID;
        nextBid.prev = globalLastBidID;

        // Insert the bid.
        bids[globalLastBidID] = Bid({
            prev: prev,
            next: _next,
            maxValuation: _maxValuation,
            contrib: msg.value,
            contributor: msg.sender,
            redeemed: false,
            subSaleNumber: currentSaleNumber
        });

        // Add the bid to the list of bids by this contributor.
        contributorBidIDs[msg.sender].push(globalLastBidID);

        // Emit event
        emit BidSubmitted(msg.sender, globalLastBidID, now);
    }


    /** @dev Search for the correct insertion spot and submit a bid.
     *  This function is O(n), where n is the amount of bids between the initial search position and the insertion position.
     *  The UI must first call search to find the best point to start the search such that it consumes the least amount of gas possible.
     *  Using this function instead of calling submitBid directly prevents it from failing in the case where new bids are added before the transaction is executed.
     *  @param _maxValuation The maximum valuation given by the contributor. If the amount raised is higher, the bid is cancelled and the contributor refunded because it prefers a refund instead of this level of dilution. To buy no matter what, use INFINITY.
     *  @param _next The bidID of the next bid in the list.
     */
    function searchAndBid(uint _maxValuation, uint _next) public payable {
        submitBid(_maxValuation, search(_maxValuation,_next));
    }

    /** @dev Finalize by finding the cut-off bid.
     *  Since the amount of bids is not bounded, this function may have to be called multiple times.
     *  The function is O(min(n,_maxIt)) where n is the amount of bids. In total it will perform O(n) computations, possibly in multiple calls.
     *  Each call only has a O(1) storage write operations.
     *  @param _maxIt The maximum amount of bids to go through. This value must be set in order to not exceed the gas limit.
     */
    function finalize(uint _maxIt, uint _subSaleNumber) public {
        require(now >= endTimeOfSubSale(_subSaleNumber));
        require(!finalized[_subSaleNumber]);

        // Make local copies of the finalization variables in order to avoid modifying storage in order to save gas.
        uint localCutOffBidID = cutOffBidIDs[_subSaleNumber];
        uint localSumAcceptedContrib = sumAcceptedContribs[_subSaleNumber];

        // Search for the cut-off bid while adding the contributions.
        for (uint it = 0; it < _maxIt && !finalized[_subSaleNumber]; ++it) {
            Bid storage bid = bids[localCutOffBidID];
            if (bid.contrib+localSumAcceptedContrib < bid.maxValuation) { // We haven't found the cut-off yet.
                localSumAcceptedContrib        += bid.contrib;
                localCutOffBidID = bid.prev; // Go to the previous bid.
            } else { // We found the cut-off. This bid will be taken partially.
                finalized[_subSaleNumber] = true;
                uint contribCutOff = bid.maxValuation >= localSumAcceptedContrib ? bid.maxValuation - localSumAcceptedContrib : 0; // The amount of the contribution of the cut-off bid that can stay in the sale without spilling over the maxValuation.
                contribCutOff = contribCutOff < bid.contrib ? contribCutOff : bid.contrib; // The amount that stays in the sale should not be more than the original contribution. This line is not required but it is added as an extra security measure.
                bid.contributor.send(bid.contrib-contribCutOff); // Send the non-accepted part. Use send in order to not block if the contributor's fallback reverts.
                bid.contrib = contribCutOff; // Update the contribution value.
                localSumAcceptedContrib += bid.contrib;
                beneficiary.send(localSumAcceptedContrib); // Use send in order to not block if the beneficiary's fallback reverts.
            }
        }

        // Update storage.
        cutOffBidIDs[_subSaleNumber] = localCutOffBidID;
        sumAcceptedContribs[_subSaleNumber] = localSumAcceptedContrib;
    }

    /** @dev Redeem a bid. If the bid is accepted, send the tokens, otherwise refund the ETH.
     *  Note that anyone can call this function, not only the party which made the bid.
     *  @param _bidID ID of the bid to withdraw.
     */
    function redeem(uint _bidID, uint _subSaleNumber) public {

        Bid storage bid = bids[_bidID];
        Bid storage cutOffBid = bids[cutOffBidIDs[_subSaleNumber]];
        require(finalized[_subSaleNumber]);
        require(!bid.redeemed);

        bid.redeemed=true;
        if (bid.maxValuation > cutOffBid.maxValuation || (bid.maxValuation == cutOffBid.maxValuation && _bidID >= cutOffBidIDs[_subSaleNumber])) // Give tokens if the bid is accepted.
            require(token.transfer(bid.contributor, (tokensPerSubSale * (bid.contrib) / sumAcceptedContribs[_subSaleNumber])));
        else                                                                                            // Reimburse ETH otherwise.
            bid.contributor.transfer(bid.contrib);
    }

    /** @dev Fallback. Make a bid if ETH are sent. Redeem all the bids of the contributor otherwise.
     *  Note that the contributor could make this function go out of gas if it has too much bids. This in not a problem as it is still possible to redeem using the redeem function directly.
     *  This allows users to bid and get their tokens back using only send operations.
     */
    function () public payable {
        if (msg.value != 0 && now >= startTime && now < endTime) // Make a bid with an infinite maxValuation if some ETH was sent.
            submitBid(INFINITY, TAIL);
        else if (msg.value == 0)                    // Else, redeem all the non redeemed bids if no ETH was sent.
            for (uint i = 0; i < contributorBidIDs[msg.sender].length; ++i)
            {
              uint bidID = contributorBidIDs[msg.sender][i];
                if (finalized[bids[bidID].subSaleNumber] && !bids[bidID].redeemed)
                    redeem(bidID, bids[bidID].subSaleNumber);
            }
        else                                                     // Otherwise, no actions are possible.
            revert();
    }

    /* *** View Functions *** */

    /** @dev Search for the correct insertion spot of a bid.
     *  This function is O(n), where n is the amount of bids between the initial search position and the insertion position.
     *  @param _maxValuation The maximum valuation given by the contributor. Or INFINITY if no maximum valuation is given.
     *  @param _nextStart The bidID of the next bid from the initial position to start the search from.
     *  @return nextInsert The bidID of the next bid from the position the bid must be inserted at.
     */
    function search(uint _maxValuation, uint _nextStart) view public returns(uint nextInsert) {

        uint next = _nextStart;
        bool found;

        while(!found) { // While we aren't at the insertion point.
            Bid storage nextBid = bids[next];
            uint prev = nextBid.prev;
            Bid storage prevBid = bids[prev];

            if (_maxValuation < prevBid.maxValuation)       // It should be inserted before.
                next = prev;
            else if (_maxValuation >= nextBid.maxValuation) // It should be inserted after. The second value we sort by is bidID. Those are increasing, thus if the next bid is of the same maxValuation, we should insert after it.
                next = nextBid.next;
            else                                // We found the insertion point.
                found = true;
        }

        return next;
    }

    /** @dev Get the total contribution of an address.
     *  This can be used for a KYC threshold.
     *  This function is O(n) where n is the amount of bids made by the contributor.
     *  This means that the contributor can make totalContrib(contributor) revert due to an out of gas error on purpose.
     *  @param _contributor The contributor whose contribution will be returned.
     *  @return contribution The total contribution of the contributor.
     */
    function totalContrib(address _contributor, uint _subSaleNumber) public view returns (uint contribution) {
        for (uint i = 0; i < contributorBidIDs[_contributor].length; ++i)
            contribution += bids[contributorBidIDs[_contributor][i]].contrib;
    }


}
