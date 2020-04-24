/**
 *Submitted for verification at Etherscan.io on 2019-02-14
*/

pragma solidity >= 0.4.16;


interface tokenRecipient 
{ 
    function receiveApproval(address  _from, uint256 _value, address _token, bytes _extraData)  external; 
}

contract SpeedPropERC20Token02 
{
    // Public variables of the token
    string  public name;
    string  public symbol;
    uint8   public decimals = 0;    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public _totalSupply;
    address private owner;
    address private currAddr ;
    uint    public tokenPrice;
    // This creates an array with all balances
    mapping (address => uint256) public  balanceOf;
    mapping (address => mapping (address => uint256)) public _allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    // This generates a public event on the blockchain that will notify clients
    event RejectTransfer(address indexed from, address indexed to, uint256 value, string message);
    
    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    //This is if purchase is invalid
    event RejectPurchase(address account, string message);

    //This is if Fallback function is called
    event FallbackEvent(address account, string message);

    //This is if purchase is invalid
    event contractDiactivated(string message);
    
    //This is a memo Message
     event memoIt (string message);
    //This is a memo Message
     event memoIt2(string message, address, address);

    //This is to inform when price is updated
     event PriceUpdated  (string message);
     
     
     //This is to inform when Regulator address is updated
     event AddressUpdated (string message);

     
    /**
     * Constructor function
     *
     * Initializes contract with initial supply tokens to the creator of the contract
     */
    constructor ( uint256 initialSupply,  string memory tokenName, string memory tokenSymbol ) public payable
    {
        _totalSupply = initialSupply ;  // Update total supply with the decimal amount
        balanceOf[msg.sender] = _totalSupply;                // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;                               // Set the symbol for display purposes
        owner = msg.sender;
        tokenPrice = 500000000000000000 wei;
        currAddr = address(0x692a70D2e424a56D2C6C27aA97D1a86395877b3A);
    }

    function () payable external 
    {
        refund(msg.sender, msg.value) ;
        emit FallbackEvent(msg.sender, "fallback(): amount refunded!");
    }

    function refund(address toAddress, uint amountToRefund) public returns (bool )
    {
        address(toAddress).transfer(amountToRefund);
        return true;
    }

    function buyTokens(uint amount) public payable
    {
        if(amount<balanceOf[owner] && msg.value == (amount * tokenPrice) )
        {
            //----------------------------------------------------------------------------------------------------------------
            
            SageRegulator regulator = SageRegulator(currAddr);
            address addr1;
            address addr2;
            bool isValid= false;
            string memory retMsg = "";
            string memory ss;
            (isValid, retMsg, addr1, addr2) = regulator.isValidated(owner, msg.sender , amount);
            
            if( isValid )
            {
                ss = string(abi.encodePacked("Tokens bought:",retMsg));
                balanceOf[owner] -= amount;
                balanceOf[msg.sender] = balanceOf[msg.sender] + amount;
                emit memoIt2(ss, addr1, addr2);
            }
            else
            {
                ss = string(abi.encodePacked("Tokens bought:",retMsg));
                balanceOf[owner] -= amount;
                balanceOf[msg.sender] = balanceOf[msg.sender] + amount;
                emit memoIt2(ss, addr1, addr2);
            }
            //----------------------------------------------------------------------------------------------------------------

        }
        else
        {
            emit RejectPurchase(msg.sender, "invalid payment or Tokens out of stock!");
            revert();
        }
    }


    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal 
    {
        
        require(_to != address(0x0));                                   // Prevent transfer to 0x0 address. Use burn() instead
        require(balanceOf[_from] >= _value);                            // Check if the sender has enough
        require(balanceOf[_to] + _value >= balanceOf[_to]);             // Check for overflows
        uint previousBalances = balanceOf[_from] + balanceOf[_to];      // Save this for an assertion in the future
        balanceOf[_from] -= _value;                                     // Subtract from the sender
        balanceOf[_to] += _value;                                       // Add the same to the recipient
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);  // Asserts are used to use static analysis to find bugs in your code. They should never fail
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool ) 
    {

        SageRegulator regulator = SageRegulator(currAddr);
        address addr1;
        address addr2;
        bool isValid= false;
        string memory retMsg = "";
        (isValid, retMsg, addr1, addr2) = regulator.isValidated(msg.sender, msg.sender , _value);
        
        if( isValid )
        {
            string memory ss = string(abi.encodePacked("Tokens transferred:",retMsg));
            _transfer(msg.sender, _to, _value);
            emit memoIt2(ss, msg.sender, _to);
            return true;
        }
        else
        {
            emit RejectTransfer( msg.sender, _to, _value, retMsg);
            revert();
        }
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` on behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool ) 
    {
        require(_value <= _allowance[_from][msg.sender]);     // Check _allowance

        SageRegulator regulator = SageRegulator(currAddr);
        address addr1;
        address addr2;
        bool isValid= false;
        string memory retMsg = "";
        (isValid, retMsg, addr1, addr2) = regulator.isValidated(msg.sender, _from , _value);
        
        if( isValid )
        {
            string memory ss = string(abi.encodePacked("Tokens transferred:",retMsg));

            _allowance[_from][msg.sender] -= _value;
            _transfer(_from, _to, _value);
            emit memoIt2(ss, msg.sender, _to);
            return true;
        }
        else
        {
            emit RejectTransfer( _from, _to, _value, retMsg);
            revert();
        }
    }

    /**
     * Set _allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public returns (bool ) 
    {
        _allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
     * Set _allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens on your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)  public  returns (bool ) 
    {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) 
        {
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }


    /**
     * return _totalSupply of a token
     *
     *
     */
    function totalSupply() public view returns (uint256 ) 
    {
        return _totalSupply;
    }

    /**
     * return remain_allowance of an address
     *@param _owner
     *@param _spender
     */
    function allowance(address _owner, address _spender) public view returns (uint256 ) 
    {
        return _allowance[_owner][_spender];
    }

 //---------------------------------------------------------------------------------------------------------------- 

    function setPrice(uint newTokenPrice) public payable 
    {
        if(msg.sender==owner)
        {
            tokenPrice = newTokenPrice;
            emit PriceUpdated("The price is being updated...");
        }
        else
            emit PriceUpdated("You are not the contract owner and you can not update price!");
        
    }  

 //----------------------------------------------------------------
    function setCurrentAddr(address newAddr) public 
    {
        if(msg.sender==owner)
        {
            currAddr = newAddr;
            emit AddressUpdated("The Regulator address is being changed...");
        }
        else
            emit AddressUpdated("You are not the contract owner and you can not change Regulator address!");
    }
 
 //----------------------------------------------------------------
    function getCurrentParams() public view returns (address, uint) 
    {
        return (currAddr, tokenPrice);
    }
 //----------------------------------------------------------------------------------------------------------------   

    function deactivateIt() public payable 
    {
        if(msg.sender==owner)
        {
            emit contractDiactivated("The contract is being deactivated...");
            selfdestruct(address(owner));
        }
        else
        {
            emit contractDiactivated("You are not the contract owner and you can not deactivate it!");
            selfdestruct(address(owner));
        }
    }


}


contract SageRegulator{
    function isValidated(address qOwner, address sender, uint amount ) view public returns (bool , string  , address, address);
}
