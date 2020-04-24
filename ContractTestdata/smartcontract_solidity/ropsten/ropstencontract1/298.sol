/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

pragma solidity ^0.5.3;

contract Ownable {
    
    address public _owner;

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
        require(msg.sender == _owner);
        _;
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
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
    function pause() public onlyOwner whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyOwner whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

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


library AddressMakePayable {
   function makePayable(address x) internal pure returns (address payable) {
      return address(uint160(x));
   }
}


contract EthTradingPool is Pausable {
    
    
    using AddressMakePayable for address;
    using SafeMath for uint;
    
    //Keeps track of how much ETH all users have. This variable is 
    //updated with every deposit, withdrawal and when a user's profit
    //is added to the user's balance. 
    uint private _totalBalances;
    

    //---------------------------- MAPPINGS ----------------------------//
    //A mapping from user IDs to the minimum and maximum deposits 
    mapping (uint => uint[2]) private _userMinMaxDeposit;
    
    //A mapping from user addresses to user IDs
    mapping (address => uint) private _userID;
    
    //A mapping from user IDs to their primary address (i.e., the address 
    //which will receive ETH from withdrawals and payments).
    mapping (uint => address) private _paymentAddressOfID;
    
    //A mapping to keep track of all registered IDs
    mapping (uint => bool)    private _registeredUserID;
    
    //A mapping to keep track of all bot addresses 
    mapping (address => bool) private _isBotAddress;
    
    //A mapping of the user ID to the balance of the user 
    mapping (uint => uint)    private _balance;
    
    //A mapping to keep track of which users are blacklisted given their ID. 
    mapping (uint => bool)    private _blacklist;



    //----------------------------- EVENTS -----------------------------//
    /**
    * Event for maintaining a record of all deposits made by users. The 
    * event includes the ID of the user, the total deposited in Wei, the
    * new balance of the user, and the unix timestamp of the deposit.
    * */
    event DepositMade(
        uint indexed by, 
        uint totalDeposit,
        uint newBalance,
        uint unixTimestamp
    );



    /**
    * Event for maintaining a record of every occurrence when a new 
    * address has been associated with an already existing user on 
    * the smart contract. The event includes the users new address,
    * the users ID, and the unix timestamp of the event.
    * */
    event NewAddressAssociatedWithUserID(
        address indexed addr,
        uint indexed ID,
        uint unixTimestamp
    );
    


    /**
    * Event for maintaining a record of every occurrence when a user's 
    * minimum and maximum depost allowance is updated. The event includes 
    * the ID of the user, the new minimum deposit, the new maximum deposit, 
    * and the unix timestapm of the update. 
    * */
    event MinMaxDepositUpdated(
        uint indexed ID, 
        uint minDeposit, 
        uint maxDeposit, 
        uint unixTimestamp
    );
    
    
    
    /**
    * Event for maintaining a record of when new users have been added 
    * to the smart contract. The event includes the user's address, the 
    * unique ID of the user, the minimum deposit, the maximum deposit,
    * and the unix timestamp of the event. 
    * */
    event NewUserAdded(
        address indexed addr,
        uint indexed ID,
        uint minDeposit,
        uint maxDeposit,
        uint unixTimestamp
    );
    
    
    
    /**
    * Event for maintaining a record of all withdrawals made. The event 
    * includes the ID of the user, the total withdrawn in Wei, the new 
    * balance of the user, and the unix timestamp of the withdrawal. 
    * */
    event WithdrawalMade(
        address indexed to,
        uint indexed ID,
        uint totalWithdrawn,
        uint newBalance,
        uint unixTimestamp
    );
    
    
    
    /**
    * Event for maintaining a record of every ooccurrence of when a 
    * user's profit is added the user's balance. The event includes 
    * the ID of the user, the total profit added the users balance 
    * in wei, the new updated balance of the user, and the unix 
    * timestamp of the event. 
    * */
    event UserProfitAddedToBalance (
        uint indexed ID,
        uint profitAdded,
        uint newBalance,
        uint unixTimestamp
    );
    
    
    
    /**
    * Event for maintaining a record of every occurence of when a 
    * user's payment address has been changed. The event includes 
    * the old payment address of the user, the new payment address
    * of the user, the user's ID, and the unix timestamp of the 
    * event. 
    **/
    event PaymentAddressOfUserChanged(
        address indexed from,
        address indexed to,
        uint indexed ID, 
        uint unixTimestamp
    );
    
    
    
    //--------------------- ONLY OWNER FUNCTIONS -----------------------//
    /**
    * Allows the owner of the contract to add a bot address
    * 
    * @param _botAddress The bot address which is being added
    * */
    function addBotAddress(address _botAddress) public onlyOwner {
        require(!isBotAddress(_botAddress));
        _isBotAddress[_botAddress] = true;
    }
    


    /**
    * Allows the owner of the contract to remove a bot address 
    * 
    * @param _botAddress The bot address which is being removed
    */
    function removeBotAddress(address _botAddress) public onlyOwner  {
        require(isBotAddress(_botAddress));
        _isBotAddress[_botAddress] = false;
    }
    
    
    
    /**
    * Allows the owner of the contract to blacklist a user.
    * 
    * @param _usrID The ID of the user. 
    * */
    function addUserToBlacklist(uint _usrID) public onlyOwner {
        require(!userIsBlacklisted(_usrID));
        _blacklist[_usrID] = true;
    }
    
    
    
    /**
    * Allows the owner of the contract to remove a user from 
    * the blacklist.
    * 
    * @param _usrID The ID of the user.
    * */
    function removeUserFromBlacklist(uint _usrID) public onlyOwner {
        require(userIsBlacklisted(_usrID));
        _blacklist[_usrID] = false;
    }
    
    

    //--------------------- RESTRICTED FUNCTIONS -----------------------//
    /**
    * Functions with this modifier can only be invoked by either one of the bot  
    * addresses or the owner of the contract. 
    * */
    modifier restricted {
        require(isBotAddress(msg.sender) || msg.sender == owner());
        _;
    }
    
    
    
    /**
    * Allows the owner of the contract or any of the bot addresses to add profits 
    * to a user's balance. 
    * 
    * @param _usrID The unique ID of the user.
    * @param _wei The total amount of wei to increase the user's balance by.
    **/
    function addProfitToUserBalance(uint256 _usrID, uint256 _wei) public restricted {
        //Check that the ID is registered on the smart contract.
        require(userIdIsRegistered(_usrID));
        //Broadcast event to the network.
        emit UserProfitAddedToBalance(_usrID, _wei, _balance[_usrID].add(_wei), now);
        //Add the user's profit to his or her balance.
        _balance[_usrID] = _balance[_usrID].add(_wei);
        //Total deposits serves the same purpose as totalBalances. Therefore, 
        //this must also be updated. 
        _totalBalances = _totalBalances.add(_wei);
    }
    
    
    
    /**
    * Allows the owner of the contract or any of the bot addresses to add profits 
    * to the balances of users in large batches (maybe around 150 - 200 at a time).
    * 
    * @param _usrIDs The unique identifiers of the users.
    * @param _weiAmounts The total amounts of wei to increase the user balances. 
    **/
    function addProfitToUserBalancesInBatches(uint256[] memory _usrIDs, uint256[] memory _weiAmounts) public restricted {
        require(_usrIDs.length == _weiAmounts.length);
        for(uint256 i = 0; i < _usrIDs.length; i++) {
            //If the ID is registered on the smart contract.
            if(userIdIsRegistered(_usrIDs[i])) {
                //Add the user's profit to his or her balance.
                addProfitToUserBalance(_usrIDs[i], _weiAmounts[i]);
            }
        }
    }
    
    
    
    /**
    * Allows the owner of the contract or any of the bot addresses to change the 
    * payment address of a user. The function will succeed if the payment address 
    * being switched to is already registered on the smart contract and associated 
    * with the user's ID.
    * 
    * @param _newPaymentAddress The address which the user will receive payments to.
    * @param _usrID The unique ID of the user.
    **/
    function changePaymentAddressOfUser(address _newPaymentAddress, uint256 _usrID) public restricted {
        //Check that the address is already registered on the smart contract and 
        //associated with the ID of the user.
        require(addrToUserID(_newPaymentAddress) == _usrID);
        //Check that the ID is registered on the smart contract.
        require(userIdIsRegistered(_usrID));
        //Broadcast event to the network.
        emit PaymentAddressOfUserChanged(getPaymentAddressOfUserID(_usrID), _newPaymentAddress, _usrID, now);
        //Update the payment address of the user. 
        _paymentAddressOfID[_usrID] = _newPaymentAddress;
    }
    
    
    
    /**
    * Allows the owner of the contract or any of the bot addresses to associate
    * a new address with a user ID. 
    * 
    * @param _addr The address of the new user. The address must not be already in use.
    * @param _usrID The unique ID of the user. 
    * */
    function associateNewAddressWithUserID(address _addr, uint _usrID) public restricted {
        //Check that the address passed is non-zero
        require(_addr != address(0x0));
        //Check that the address has not already been linked to another user id. 
        require(addrToUserID(_addr) == 0);
        //Check taht the user id is a registered one 
        require(userIdIsRegistered(_usrID));
        _userID[_addr] = _usrID;
        //The primary address associated with the user ID is the one which the user 
        //will receive payments to (i.e., withdrawals and share of profits).
        _paymentAddressOfID[_usrID] = _addr;
        emit NewAddressAssociatedWithUserID(_addr, _usrID, now);
    }
    
    
    
    /**
    * Allows the owner of the contract or any bot addresses to add new users to the 
    * smart contract. 
    * 
    * @param _addr The address of the new user. The address must not be already in use. 
    * @param _usrID The new ID which is assigned to the user. The ID must be unique.
    * @param _minDeposit The minimum amount of ETH the user can deposit.
    * @param _maxDeposit The maximum amount of ETH the user can deposit.
    **/
    function addNewUser(address _addr, uint _usrID, uint _minDeposit, uint _maxDeposit) public restricted {
        //Check that the address is not already associated with a user ID.
        require(addrToUserID(_addr) == 0);
        //Check if the user ID is available
        require(!userIdIsRegistered(_usrID));
        //Min can never be larger than the max but it can be the same.
        require(_minDeposit <= _maxDeposit); 
        //Register the user ID to the contract.
        _registeredUserID[_usrID] = true;
        //Map the address of the new user to the new unique user ID. 
        _userID[_addr] = _usrID;
        //Map the users minimum and maxiimum deposit values to the 
        //user ID. 
        _userMinMaxDeposit[_usrID] = [_minDeposit, _maxDeposit];
        _paymentAddressOfID[_usrID] = _addr;
        emit NewUserAdded(_addr, _usrID, _minDeposit, _maxDeposit, now);
    }
    
    
    
    /**
    * Allows the owner of the contract or any bot address to update the minimum and 
    * maximum deposits which users can make.
    * 
    * @param _usrID The ID of the who's min and max deposit allowance is being 
    * updated.
    * @param _minDeposit The minimum amount of ETH the user can deposit.
    * @param _maxDeposit The maximum amount of ETH the user can deposit.
    */
    function updateUserMinMaxDeposit(uint _usrID, uint _minDeposit, uint _maxDeposit) public restricted {
        //Check if the user id has been registered 
        require(userIdIsRegistered(_usrID));
        //Min can never be larger than the max but it can be the same
        require(_minDeposit <= _maxDeposit); 
        //Pass through the new minimum and maximum deposit values of the user
        //to the mapping. 
        _userMinMaxDeposit[_usrID] = [_minDeposit, _maxDeposit];
        emit MinMaxDepositUpdated(_usrID, _minDeposit, _maxDeposit, now);
    }
    
    
    
    /**
    * Allows the owner of the contract or any of the bot addresses to process withdrawals in 
    * large batches (approximately 100 at a time but maybe more). For this method the user 
    * addresses must be passed as an argument. 
    * 
    * @param _addrs The list of recipient addresses 
    * @param _vals The amounts of ETH to send each address in Wei. 
    * */
    function processWithdrawals(address[] memory _addrs, uint[] memory _vals) public restricted {
        require(_addrs.length == _vals.length);
        for(uint i=0; i<_addrs.length; i++) {
            //Check if the user has enough balance and also if the user id is registered.
            if(getBalanceOf(addrToUserID(_addrs[i])) < _vals[i]) { 
                //Make transaction fail if the above condition is not met
                revert();
            }
            //Stores the balance of the user before sending ETH to the user and then 
            //sets the user's balance to 0. Once the user receives the ETH, if the they 
            //did not withdraw their full balance, then they will be re-credit with the
            //remaineder. This will end up costing a little bit more gas but adds a good  
            //level of security which mitigates reentrancy (or race condition) attacks
            //similar to the DAO hack. 
            uint oldBalance = _balance[addrToUserID(_addrs[i])] ;
            _balance[addrToUserID(_addrs[i])] = 0;
            _addrs[i].makePayable().transfer(_vals[i]);
            _totalBalances = _totalBalances.sub(_vals[i]);
            if(oldBalance.sub(_vals[i]) > 0) {
                _balance[addrToUserID(_addrs[i])] = oldBalance.sub(_vals[i]);
            }
            emit WithdrawalMade(
                _addrs[i], 
                addrToUserID(_addrs[i]), 
                _vals[i],
                _balance[addrToUserID(_addrs[i])],
                now
            );
        }
    }
    
    
    
    /**
    * Allows the owner of the contract or any of the bot addresses to process withdrawals in 
    * large batches (approximately 100 at a time but maybe more). For this method the user 
    * IDs must be passed as an argument. 
    * 
    * @param _usrIDs The list of recipient user IDs 
    * @param _vals The amounts of ETH to send each address in Wei. 
    * */
    function processWithdrawals(uint[] memory _usrIDs, uint[] memory _vals) public restricted {
        require(_usrIDs.length == _vals.length);
        for(uint i=0; i<_usrIDs.length; i++) {
            //Check if the user has enough balance.
            if(getBalanceOf(_usrIDs[i]) < _vals[i]) { 
                //Make transaction fail if the above condition is not met
                revert();
            }
            //Stores the balance of the user before sending ETH to the user and then 
            //sets the user's balance to 0. Once the user receives the ETH, if the they 
            //did not withdraw their full balance, then they will be re-credit with the
            //remaineder. This will end up costing a little bit more gas but adds a good  
            //level of security which mitigates reentrancy (or race condition) attacks
            //similar to the DAO hack. 
            uint oldBalance = _balance[_usrIDs[i]] ;
            _balance[_usrIDs[i]] = 0;
            getPaymentAddressOfUserID(_usrIDs[i]).makePayable().transfer(_vals[i]);
            _totalBalances = _totalBalances.sub(_vals[i]);
            if(oldBalance.sub(_vals[i]) > 0) {
                _balance[_usrIDs[i]] = oldBalance.sub(_vals[i]);
            }
            emit WithdrawalMade(
                getPaymentAddressOfUserID(_usrIDs[i]), 
                _usrIDs[i], 
                _vals[i],
                _balance[_usrIDs[i]],
                now
            );
        }
    }
    
    
    
    //------------------------- VIEW FUNCTIONS -------------------------//
    /**
    * Function used for checking how much ETH is owned by all users.  
    *
    * @return The total amount of ETH owned by all users. 
    */
    function getTotalBalances() public view returns(uint) {
        return _totalBalances;
    }
    
    
    
    /**
    * Function gets the payment address of a user with the user's ID.
    * 
    * @param _usrID The ID of the user. 
    * @return The payment address of the user.
    * */
    function getPaymentAddressOfUserID(uint _usrID) public view returns(address) {
        return _paymentAddressOfID[_usrID];
    }
    
    
    
    /**
    * Function for checking the balance of a user given the user's ID.
    * 
    * @param _usrID The ID of the user. 
    * @return The balance of the user. 
    * */
    function getBalanceOf(uint _usrID) public view returns(uint) {
        return _balance[_usrID];
    }
    
    
    
    /**
    * Function for checking if an ID is registered in the smart contract. 
    * 
    * @param _usrID The ID being checked 
    * @return True if the ID is registered, false otherwise.
    * */
    function userIdIsRegistered(uint _usrID) public view returns(bool) {
        return _registeredUserID[_usrID] == true;
    }
    
    
    
    /**
    * Queries the user ID associated with a given address 
    * 
    * @param _addr The address of which the user ID is being queried 
    * @return The user ID associated with _addr.
    * */
    function addrToUserID(address _addr) public view returns(uint) {
        return _userID[_addr];
    }
    
    
    
    /**
    * Checks if the given address is of a bot. 
    * 
    * @param _addr the address which is being queried
    * @return True if the given address is that of a bot, false otherwise
    * */
    function isBotAddress(address _addr) public view returns(bool) {
        return _isBotAddress[_addr];
    }
    
    
    
    /**
    * Function to query the minimum and maximum deposit of a user.
    * 
    * @param _usrID The ID of the user who's minimum and maximum deposit is being queried.
    * @return (min deposit, max depost)
    */
    function getUserMinMaxDeposit(uint _usrID) public view returns (uint min, uint max) {
        min = _userMinMaxDeposit[_usrID][0];
        max = _userMinMaxDeposit[_usrID][1];
        return(min, max);
    }
    
    
    
    /**
    * Funciton to query if a user is blacklisted or not.
    * 
    * @param _usrID the ID of the user.
    * @return True if the user is blacklisted, false otherwise. 
    * */
    function userIsBlacklisted(uint _usrID) public view returns(bool) {
        return _blacklist[_usrID];
    }
    
    
    
    /**
    * Fallback function invokes the makeDeposit funciton automatically when 
    * the contract receives ETH.
    * */
    function() external payable {
        makeDeposit(msg.sender);
    }
    
    
    
    /**
    * Function is either internally invoked by the fallback funciton when
    * ETH is received, or can be invoked manually from the user interface
    * (both options are good). It allows users to make a deposit of ETH. 
    * 
    * @param _addr This parameter is used to map the address of the user
    * to the user's ID because it is the balance of the user ID which will
    * be updated from the total deposited. 
    * */
    function makeDeposit(address _addr) public payable whenNotPaused() {
        //Check that the user is not blacklisted before allowing deposit.
        require(!userIsBlacklisted(addrToUserID(_addr)));
        //Check that the user has a registered ID. 
        require(addrToUserID(_addr) != 0);
        require( //Check if investor meets the min deposit requirement
            getBalanceOf(addrToUserID(_addr)).add(msg.value) >= _userMinMaxDeposit[addrToUserID(_addr)][0]
        );
        require( //Check if investor meets the max deposit requirement
            getBalanceOf(addrToUserID(_addr)).add(msg.value) <= _userMinMaxDeposit[addrToUserID(_addr)][1]
        );
        //Add the total deposited to the user's balance. 
        _balance[addrToUserID(_addr)] = _balance[addrToUserID(_addr)].add(msg.value);
        //Update the total deposited variable. 
        _totalBalances = _totalBalances.add(msg.value);
        emit DepositMade(addrToUserID(_addr), msg.value, _balance[addrToUserID(_addr)], now);
    }
}
