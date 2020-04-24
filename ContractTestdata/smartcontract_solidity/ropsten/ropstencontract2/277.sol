/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

/**
 *Submitted for verification at Etherscan.io on 2018-07-15
*/

pragma solidity 0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
     * @dev Multiplies two numbers, throws on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
     * @dev Integer division of two numbers, truncating the quotient.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
     * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
     * @dev Adds two numbers, throws on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

     

 

}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


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


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint256 public totalSupply_;

    /**
     * @dev total number of tokens in existence
     */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
     * @dev transfer token for a specified address
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(msg.data.length>=(2*32)+4);
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer (msg.sender, _to, _value);
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
        emit Transfer(_from, _to, _value);
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
        require(_value==0||allowed[msg.sender][_spender]==0);
        require(msg.data.length>=(2*32)+4);
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
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
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _addedValue The amount of tokens to increase the allowance by.
     */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     *
     * approve should be called when allowed[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * @param _spender The address which will spend the funds.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}


/**
 * @title Pausable token
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken, Pausable {

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}

/**
 * @title Lock token
 * @dev Lock  which is defined the lock logic
 **/
contract  Lock is PausableToken{

    mapping(address => uint256) public teamLockTime; // Lock start time
    uint256 public issueDate =0 ;//issueDate
    mapping(address => uint256) public teamLocked;// Total Team lock 
    mapping(address => uint256) public teamUsed;   // Team Used
    mapping(address => uint256) public teamReverse;   // Team reserve


   /**
    * @dev Calculate the number of Tokens available for teamAccount
    * @param _to teamAccount's address
   */
    function teamAvailable(address _to) internal constant returns (uint256) {
        require(teamLockTime[_to]>0);
        //Cover the start time of the lock before the release is the issueDate
        if(teamLockTime[_to] != issueDate)
        {
            teamLockTime[_to]= issueDate;
        }
        uint256 now1 = block.timestamp;
        uint256 lockTime = teamLockTime[_to];
        uint256 time = now1.sub(lockTime);
        uint256 percent = 0;
        //locks team account for 1 year
        if(time >= 30 minutes) {
          percent = percent.add(((time.sub(30 minutes)).div (30 minutes)).add (1));
        }
        percent = percent > 8 ? 8 : percent;
        uint256 avail = teamLocked[_to];
        require(avail>0);
        avail = avail.mul(percent).div(8).sub(teamUsed[_to]);
      
        return avail;
    }
    
  
    /**
      * @dev Team lock
      * @param _to  team lock account's address
      * @param _value the number of Token
     */
    function teamLock(address _to,uint256 _value) internal {
        require(_value>0);
        teamLocked[_to] = teamLocked[_to].add(_value);
        teamReverse[_to] = teamReverse[_to].add(_value);
        teamLockTime[_to] = block.timestamp;  // Lock start time
    }
  
    /**
     * @dev Team account transaction
     * @param _to  The accept token address
     * @param _value Number of transactions
     */
    function teamLockTransfer(address _to, uint256 _value) internal returns (bool) {
        //The remaining part
       uint256 availReverse = balances[msg.sender].sub(teamLocked[msg.sender].sub(teamUsed[msg.sender]));
       uint256 totalAvail=0;
       uint256 availTeam =0;
       if(issueDate==0)
        {
             totalAvail = availReverse;
        }
        else{
            //the number of Tokens available for teamAccount'Locked part
             availTeam = teamAvailable(msg.sender);
             //the number of Tokens available for teamAccount
             totalAvail = availTeam.add(availReverse);
        }
        require(_value <= totalAvail);
        bool ret = super.transfer(_to,_value);
        if(ret == true && issueDate>0) {
            //If over the teamAccount's released part
            if(_value > availTeam){
                teamUsed[msg.sender] = teamUsed[msg.sender].add(availTeam);
                 teamReverse[msg.sender] = teamReverse[msg.sender].sub(availTeam);
          }
            //If in the teamAccount's released part
            else{
                teamUsed[msg.sender] = teamUsed[msg.sender].add(_value);
                teamReverse[msg.sender] = teamReverse[msg.sender].sub(_value);
            }
        }
        if(teamUsed[msg.sender] >= teamLocked[msg.sender]){
            delete teamLockTime[msg.sender];
            delete teamReverse[msg.sender];
        }
        return ret;
    }

    /**
     * @dev Team account authorization transaction
     * @param _from The give token address
     * @param _to  The accept token address
     * @param _value Number of transactions
     */
    function teamLockTransferFrom(address _from,address _to, uint256 _value) internal returns (bool) {
       //The remaining part
       uint256 availReverse = balances[_from].sub(teamLocked[_from].sub(teamUsed[_from]));
       uint256 totalAvail=0;
       uint256 availTeam =0;
        if(issueDate==0)
        {
             totalAvail = availReverse;
        }
        else{
            //the number of Tokens available for teamAccount'Locked part
             availTeam = teamAvailable(_from);
              //the number of Tokens available for teamAccount
             totalAvail = availTeam.add(availReverse);
        }
       require(_value <= totalAvail);
        bool ret = super.transferFrom(_from,_to,_value);
        if(ret == true && issueDate>0) {
            //If over the teamAccount's released part
            if(_value > availTeam){
                teamUsed[_from] = teamUsed[_from].add(availTeam);
                teamReverse[_from] = teamReverse[_from].sub(availTeam);
           }
            //If in the teamAccount's released part
            else{
                teamUsed[_from] = teamUsed[_from].add(_value);
                teamReverse[_from] = teamReverse[_from].sub(_value);
            }
        }
        if(teamUsed[_from] >= teamLocked[_from]){
            delete teamLockTime[_from];
            delete teamReverse[_from];
        }
        return ret;
    }
}

/**
 * @title TROYToken
 * @dev TROYToken Contract
 **/
contract TROYToken is Lock {
    string public name;
    string public symbol;
    uint8 public decimals;
    // Proportional accuracy
    uint256  public precentDecimal = 2;
    // mainFundPrecent  私募
    uint256 public mainFundPrecent = 1000;  
    //subFundPrecent  公募
    uint256 public subFundPrecent = 1000;   
    //devTeamPrecent  开发团队
    uint256 public devTeamPrecent = 7000;
    //hitFoundationPrecent  社区 
    uint256 public hitFoundationPrecent = 1000;
    //mainFundBalance
    uint256 public  mainFundBalance;
    //subFundBalance
    uint256 public subFundBalance;
    //devTeamBalance
    uint256 public  devTeamBalance;
    //hitFoundationBalance
    uint256 public hitFoundationBalance;
    //subFundAccount
    address public subFundAccount;
    //mainFundAccount
    address public mainFundAccount;
    

    /**
     *  @dev Contract constructor
     *  @param _name token's name
     *  @param _symbol token's symbol
     *  @param _decimals token's decimals
     *  @param _initialSupply token's initialSupply
     *  @param _teamAccount  teamAccount
     *  @param _subFundAccount subFundAccount
     *  @param _mainFundAccount mainFundAccount
     *  @param _hitFoundationAccount hitFoundationAccount
    */
    function TROYToken(string _name, string _symbol, uint8 _decimals, uint256 _initialSupply,address _teamAccount,address _subFundAccount,address _mainFundAccount,address _hitFoundationAccount) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        //Define a subFundAccount
        subFundAccount = _subFundAccount;
        //Define a mainFundAccount
        mainFundAccount = _mainFundAccount;
        //Calculated according to accuracy, if the precision is 18, it is _initialSupply x 10 to the power of 18
        totalSupply_ = _initialSupply * 10 ** uint256(_decimals);
        //Calculate the total value of mainFund
        mainFundBalance =  totalSupply_.mul(mainFundPrecent).div(100* 10 ** precentDecimal) ;
        //Calculate the total value of subFund
        subFundBalance =  totalSupply_.mul(subFundPrecent).div(100* 10 ** precentDecimal);
        //Calculate the total value of devTeamBalance
        devTeamBalance =  totalSupply_.mul(devTeamPrecent).div(100* 10 ** precentDecimal);
        //Calculate the total value of  hitFoundationBalance
        hitFoundationBalance = totalSupply_.mul(hitFoundationPrecent).div(100* 10 ** precentDecimal) ;
        //Initially put the hitFoundationBalance into the hitFoundationAccount
        balances[_hitFoundationAccount] = hitFoundationBalance; 
        //Initially put the devTeamBalance into the teamAccount
        balances[_teamAccount] = devTeamBalance;
        //Initially put the subFundBalance into the subFundAccount
        balances[_subFundAccount] = subFundBalance;
         //Initially put the mainFundBalance into the mainFundAccount
        balances[_mainFundAccount]=mainFundBalance;
        //Initially lock the team account
        teamLock(_teamAccount,devTeamBalance);
        
    }

    /**
      * @dev destroy the msg sender's token onlyOwner
      * @param _value the number of the destroy token
     */
    function burn(uint256 _value) public onlyOwner returns (bool) {
        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        balances[address(0)] = balances[address(0)].add(_value);
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }

    /**
     * @dev Transfer token
     * @param _to the accept token address
     * @param _value the number of transfer token
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        if(issueDate==0)
        {
             //the mainFundAccounts is not allowed to transfer before issued
            require(msg.sender != mainFundAccount);
        }

        if(teamLockTime[msg.sender] > 0){
             return super.teamLockTransfer(_to,_value);
            }else {
               return super.transfer(_to, _value);

        }
    }

    /**
     * @dev Transfer token
     * @param _from the give token address
     * @param _to the accept token address
     * @param _value the number of transfer token
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
          if(issueDate==0)
        {
              //the mainFundAccounts is not allowed to transfer before issued
            require(_from != mainFundAccount);
        }
      
        if(teamLockTime[_from] > 0){
            return super.teamLockTransferFrom(_from,_to,_value);
        }else{
            return super.transferFrom(_from, _to, _value);
        }
    }


     /**
      * @dev Issue the token 
     */
     function issue() public onlyOwner  returns (uint){
         //Only one time 
         require(issueDate==0);
         issueDate = now;
         return now;
     }
     
     /**avoid mis-transfer*/
     function() public payable{
         revert();
     }
     
   
}
