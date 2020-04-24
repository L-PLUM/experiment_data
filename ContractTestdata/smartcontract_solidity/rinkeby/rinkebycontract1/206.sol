/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity 0.5.3;


/* Math operations with safety checks that throws an error */
library SafeMath {
    // Multiplication
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    
    // Division
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b > 0);                  // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        assert(a == b * c + a % b);    // There is no case in which this doesn't hold
        return a / b;
    }
    
    // Subraction
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }
    
    // Addition
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}


/** ** ** ** ** ** ** ** *** ** * ** ** ** ** * ***/

/* Setting owner and transferring ownership */
contract Ownable {
    address payable public owner;
    
    // OwnershipTansferred Event
    event OwnershipTransferred(address indexed previousOwner, 
                               address indexed newOwner);
    
    // Constructor sets the caller as the owner 
    constructor() public {
      owner = msg.sender;
    }
    
    // Throws if called by any account other than the owner.
    modifier onlyOwner() {
      require(msg.sender == owner);
      _;
    }
    
    // Allows the current owner to transfer control of the contract to a newOwner.
    function transferOwnership(address payable newOwner) public onlyOwner {
      require(newOwner != address(0));
      
      owner = newOwner;
      
      // Trigger Event
      emit OwnershipTransferred(owner, newOwner);
    }
}


/** ** ** ** ** ** ** ** *** ** * ** ** ** ** * ***/

/* ERC20 and ERC20Basics contract will set the ground work for creation of token */
/* Essential for creation of token */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    
    // Transfer Event
    event Transfer(address indexed from, 
                   address indexed to, 
                   uint256 value);
}

/* Desariable for creation of token */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    
    // Approval Event
    event Approval(address indexed owner, 
                   address indexed spender, 
                   uint256 value);
}


/** ** ** ** ** ** ** ** *** ** * ** ** ** ** * ***/

/* Basic version of token */
contract BasicToken is ERC20Basic {
    using SafeMath for uint256;
    uint256 totalSupply_;
    // Mapping datatype to hold which address is holding how much of token
    mapping(address => uint256) balances;
    
    
    // Total number of tokens generated, GETTER FUNCTION
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }
    
    // Gets the balance of specified account
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
    
    // Transfer token to a specific address
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        
        // Triggering transfer event
        emit Transfer(msg.sender, _to, _value);
        
        return true;
    }
}


/** ** ** ** ** ** ** ** *** ** * ** ** ** ** * ***/

/* Standard version of token */
contract StandardToken is ERC20, BasicToken {
    mapping (address => mapping (address => uint256)) internal allowed;
    
    // Returns the amount of tokens that an owner allowed to a spender. GETTER FUNCTION
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }
    
    // Approve the passed address to spend the specified amount of tokens on behalf of msg.sender
    // Changing an allowance with this method brings the risk that someone may use both the old
    // and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    // race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    // https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        
        return true;
    }
    
    // Transfer tokens from one address to another
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
    
    // Increase the amount of tokens that an owner allowed to a spender.
    // Approve should be called when allowed[_spender] == 0. To increment
    // allowed value is better to use this function to avoid 2 calls
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        
        return true;
    }
    
    // Decrease the amount of tokens that an owner allowed to a spender.
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


/** ** ** ** ** ** ** ** *** ** * ** ** ** ** * ***/

/** CROWDSALE PART OF CONTRACT */

/* Configurable information about contract */
contract Configurable {
    // No of tokens put to sale
    uint256 public constant cap = 1000000*10**18;
    
    // No of tokens avaliable for one Ether
    uint256 public constant basePrice = 100*10**18; 
    
    uint256 public tokensSold = 0;
    
    // TOken reserved for company
    uint256 public constant tokenReserve = 1000000*10**18;
    
    // Remaining tokens for sale
    uint256 public remainingTokens = 0;
}


/** ** ** ** ** ** ** ** *** ** * ** ** ** ** * ***/

/* ICO Contract */
contract CrowdsaleToken is StandardToken, Configurable, Ownable {
    // Enumeration datatype to identify the stages of ICO
    // Each value denots integer value starting from zero
    // none means ICO has not started
    enum icoStage {
        none,
        start,
        end
    }
    
    // Declaring the enumeration datatype
    icoStage currentStage;
    
    constructor() public {
        // Defining initial stage of ICO
        currentStage = icoStage.none;
        // Transfering reserved tokens to admin account
        balances[owner] = balances[owner].add(tokenReserve);
        // total generation of tokens
        totalSupply_ = totalSupply_.add(tokenReserve);
        // Tokens available for sale
        remainingTokens = cap;
        
        // Trigger transfer Event
        emit Transfer(address(this), owner, tokenReserve);
    }
    
    // Fallback function is function without name, purpose is if contract address is used to
    // sent ether without calling any function, then this function is invoked to handle the request
    function() payable external{
        require(currentStage == icoStage.start);
        require(msg.value > 0);
        require(remainingTokens > 0);
        
        // Calculate no of tokens to sent based on value and
        // how much wei is to sent back to buyer
        uint256 weiAmount = msg.value; 
        uint256 tokens = weiAmount.mul(basePrice).div(1 ether);
        uint256 returnWei = 0;
        
        if(tokensSold.add(tokens) > cap){
            uint256 newTokens = cap.sub(tokensSold);
            uint256 newWei = newTokens.div(basePrice).mul(1 ether);
            
            returnWei = weiAmount.sub(newWei);
            weiAmount = newWei;
            tokens = newTokens;
        }
        
        tokensSold = tokensSold.add(tokens); // Increment raised amount
        remainingTokens = cap.sub(tokensSold);
        if(returnWei > 0){
            // Returnng the extra amount in wei
            msg.sender.transfer(returnWei);
            // Trigger transfer event
            emit Transfer(address(this), msg.sender, returnWei);
        }
        
        balances[msg.sender] = balances[msg.sender].add(tokens);
        // Trigger Transfer event
        emit Transfer(address(this), msg.sender, tokens);
        
        totalSupply_ = totalSupply_.add(tokens);
        owner.transfer(weiAmount);// Send money to owner
    }
    
    // Starting ICO
    function startIco() public onlyOwner {
        require(currentStage != icoStage.end);
        currentStage = icoStage.start;
    }
    
    // Ending ICO
    function endIco() internal {
        currentStage = icoStage.end;
        
        // Transfer any remaining tokens
        if(remainingTokens > 0)
            balances[owner] = balances[owner].add(remainingTokens);
            
        // transfer any remaining ETH balance in the contract to the owner
        owner.transfer(address(this).balance); 
    }
    
    // Finalize ICO closes down the ICO and sets needed varriables
    function finalizeIco() public onlyOwner {
        require(currentStage != icoStage.end);
        endIco(); 
    }
}


/** ** ** ** ** ** ** ** *** ** * ** ** ** ** * ***/

/* Giving name to the token */
contract BeachToken is CrowdsaleToken {
    string public constant name = "BeachToken"; 
    string public constant symbol = "BT";
    uint32 public constant decimals = 18;
}


/** ** ** ** ** ** ** ** *** ** * ** ** ** ** * ***/
