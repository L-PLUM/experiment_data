/**
 *Submitted for verification at Etherscan.io on 2019-02-17
*/

pragma solidity ^0.5.1;


/**
 * Math operations with safety checks
 */
library SafeMath {
    
  function mul(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint a, uint b) internal pure returns (uint) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint a, uint b) internal pure returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function add(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c >= a);
    return c;
  }
}

contract owned {
    address payable public owner;
    address payable public reclaimablePocket; //**this will hold any of this contract token that is sent to this contract by mistake, and can be claimed back
    constructor(address payable _reclaimablePocket) public {
        owner = msg.sender;
        reclaimablePocket = _reclaimablePocket;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address payable newOwner) onlyOwner public { owner = newOwner; }
    function changeRecPocket(address payable _newRecPocket) onlyOwner public { reclaimablePocket = _newRecPocket; }
}

interface ERC20 {
    function transferFrom(address _from, address _to, uint _value) external returns (bool); //3rd party transfer
    function approve(address _spender, uint _value) external returns (bool); //set allowance
    function allowance(address _owner, address _spender) external view returns (uint); //get allowance value
    event Approval(address indexed _owner, address indexed _spender, uint _value); //emits approval activities
}
interface ERC223 {
    function transfer(address _to, uint _value, bytes calldata _data) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint value, bytes indexed data);
}
contract ERC223ReceivingContract { function tokenFallback(address _from, uint _value, bytes memory _data) public; }

contract Token {
    
    using SafeMath for uint;
    
    string internal _symbol;
    string internal _name;
    uint256 internal _decimals = 18;
    uint internal _totalSupply;
    mapping (address => uint) internal _balanceOf;
    mapping (address => mapping (address => uint)) internal _allowances;
    
    //Configurables
    uint256 public cap ;
    uint256 public tokensSold = 0;
    uint256 public remainingTokens = 0;
    uint256 public teamReserve;
    uint256 public buyPrice;    //eth per Token
    
    constructor(string memory name, string memory symbol, uint totalSupply) public {
        _symbol = symbol;
        _name = name;
        _totalSupply = totalSupply * 10 ** uint256(_decimals);  // Update total supply with the decimal amount
        teamReserve = (_totalSupply * 15)/100;
        remainingTokens = (_totalSupply * 45)/100;
        cap = remainingTokens ;
    }
    
    function name() public view returns (string memory) { return _name; }
    function symbol() public view returns (string memory) { return _symbol; }
    function decimals() public view returns (uint256) { return _decimals; }
    function totalSupply() public view returns (uint) { return _totalSupply; }
    function balanceOf(address _addr) public view returns (uint);
    function transfer(address _to, uint _value) public returns (bool);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    // To emit direct purchase of token transaction from contract.
    event purchaseInvoice(address indexed _buyer, uint _tokenReceived, uint _weiSent, uint _weiCost, uint _weiReturned );
}


interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external; }

contract SiBiCryptToken is Token, ERC20, ERC223, owned {
    
    using SafeMath for uint;
    /**
     * @dev enum of current crowd sale state
     **/
     enum Stages {none, icoStart, icoPaused, icoResumed, icoEnd} 
     Stages currentStage;
     
    function balanceOf(address _addr) public view returns (uint) {
        return _balanceOf[_addr];
    }
    
    event thirdPartyTransfer( address indexed _from, address indexed _to, uint _value, address indexed _sentBy ) ;
    event returnedWei(address indexed _fromContract, address indexed _toSender, uint _value);

    function transfer(address _to, uint _value) public returns (bool) {
        bytes memory empty ;
        transfer(_to, _value, empty);
        return true;
    }

    function transfer(address _to, uint _value, bytes memory _data) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        if(isContract(_to)){
            if(_to == address(this)){
                require (_balanceOf[address(this)] >= _value) ;
                _balanceOf[address(this)] -= _value;
                _balanceOf[reclaimablePocket] += _value;
            }
            else
            {
                ERC223ReceivingContract _contract = ERC223ReceivingContract(_to);
                    _contract.tokenFallback(msg.sender, _value, _data);
            }
        }
        emit Transfer(msg.sender, _to, _value, _data);
        emit Transfer(_to, reclaimablePocket, _value, _data);
        return true;
        //return false;
    }

    function isContract(address _addr) public view returns (bool) {
        uint codeSize;
        assembly {
            codeSize := extcodesize(_addr)
        }
        return codeSize > 0;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        require (_allowances[_from][msg.sender] >= _value, "insufficient allowance");
        require ( _value > 0 );
        require (_balanceOf[_from] >= _value, "insufficient funds");
        _balanceOf[_from] = _balanceOf[_from].sub(_value);
        _balanceOf[_to] = _balanceOf[_to].add(_value);
        _allowances[_from][msg.sender] = _allowances[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        emit thirdPartyTransfer(_from, _to, _value, msg.sender);
        return true;
    }
    
    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        //require(_value > 0 );
        require(currentStage == Stages.icoPaused || currentStage == Stages.icoEnd, "Pls, try again after ICO");
        require(_to != address(0x0), "invalid 'to' address"); // Prevent transfer to 0x0 address. Use burn() instead
        require(_balanceOf[_from] >= _value, "insufficient balance"); // Check if the sender has enough
        require(_balanceOf[_to] + _value > _balanceOf[_to], "overflow err"); // Check for overflows
        uint previousBalances = _balanceOf[_from] + _balanceOf[_to]; // Save this for an assertion in the future
        // Subtract from the sender
        _balanceOf[_from] = _balanceOf[_from].sub(_value); 
        _balanceOf[_to] = _balanceOf[_to].add(_value); // Add the same to the recipient

        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(_balanceOf[_from] + _balanceOf[_to] == previousBalances);
    }
    
    function approve(address _spender, uint _value) public returns (bool) {
        require(_balanceOf[msg.sender]>=_value);
        _allowances[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint) {
        return _allowances[_owner][_spender];
    }
}



contract SiBiCryptICO is SiBiCryptToken {
    
  
    /**
     * @dev constructor of CrowdsaleToken
     **/
      /* Initializes contract with initial supply tokens and sharesPercent to the creator _owner of the contract */
    constructor(
        string memory tokenName,
        string memory tokenSymbol,
        uint256 initialSupply,
        address payable reclaimablePocket
    ) Token(tokenName, tokenSymbol, initialSupply) owned(reclaimablePocket) public {
        uint inTopup = (_totalSupply*40)/100;
         _balanceOf[msg.sender] += inTopup;
         currentStage = Stages.none;
    }
    
  
    /// @param newBuyPrice Price users can buy token from the contract
    function setPrices(uint256 newBuyPrice) onlyOwner public {
        buyPrice = newBuyPrice;   //ETH per Token
    }
    /**
     * @dev fallback function to send ether to for Crowd sale
     **/
    function () external payable {
        require(currentStage == Stages.icoStart || currentStage == Stages.icoResumed, "Oops! ICO is not running");
        require(msg.value > 0);
        require(remainingTokens > 0, "Tokens sold out! you may proceed to buy from Token holders");
        
        uint256 weiAmount = msg.value; // Calculate tokens to sell
        uint256 tokens = (weiAmount.div(buyPrice)).mul(1*10**_decimals);
        uint256 returnWei;
        
        if(tokensSold.add(tokens) > cap){
            uint256 newTokens = cap.sub(tokensSold);
            uint256 newWei = (newTokens.mul(buyPrice)).div(1*10**_decimals);
            returnWei = weiAmount.sub(newWei);
            weiAmount = newWei;
            tokens = newTokens;
        }
        
        tokensSold = tokensSold.add(tokens); // Increment raised amount
        remainingTokens = cap.sub(tokensSold); //decrease remaining token
        if(returnWei > 0){
            msg.sender.transfer(returnWei);
            emit Transfer(address(this), msg.sender, returnWei);
        }
        
        _balanceOf[msg.sender] = _balanceOf[msg.sender].add(tokens);
        emit Transfer(address(this), msg.sender, tokens);
        emit purchaseInvoice(msg.sender, tokens, msg.value, weiAmount, returnWei);
       
        owner.transfer(weiAmount); // Send money for project execution
    }
    
    /**
     * @dev startIco starts the public ICO
     **/
    function startIco() public onlyOwner {
        require(currentStage != Stages.icoEnd, "Oops! ICO has been finalized.");
        require(currentStage == Stages.none, "ICO is running already");
        currentStage = Stages.icoStart;
    }
    
    function pauseIco() internal {
        require(currentStage != Stages.icoEnd, "Oops! ICO has been finalized.");
        currentStage = Stages.icoPaused;
        owner.transfer(address(this).balance);
    }
    
    function resumeIco() public onlyOwner {
        require(currentStage == Stages.icoPaused, "call denied");
        currentStage = Stages.icoResumed;
    }
    
    function ICO_State() public view returns(string memory) {
        if(currentStage == Stages.none) return "Initializing...";
        if(currentStage == Stages.icoStart) return "ICO is running...";
        if(currentStage == Stages.icoPaused) return "Paused!";
        if(currentStage == Stages.icoResumed) return "running...";
        if(currentStage == Stages.icoEnd) return "ICO Stopped!";
    }
    

    /**
     * @dev endIco closes down the ICO 
     **/
    function endIco() internal {
        currentStage = Stages.icoEnd;
        // Transfer any remaining tokens
        if(remainingTokens > 0)
            _balanceOf[owner] = _balanceOf[owner].add(remainingTokens);
        // transfer any remaining ETH balance in the contract to the owner
        owner.transfer(address(this).balance); 
    }

    /**
     * @dev finalizeIco closes down the ICO and sets needed varriables
     **/
    function finalizeIco() public onlyOwner returns(string memory){
        require(currentStage != Stages.icoEnd );
        if(currentStage == Stages.icoPaused){
        endIco();
        return "ICO Closed succefully!";
        }
        else{
            pauseIco();
            return "ICO Paused";
        }
    }
}
