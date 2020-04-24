/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity >= 0.4.16;


interface tokenRecipient { 
                            function receiveApproval(address  _from, uint256 _value, address _token, bytes  _extraData)  external; 
                        }

contract SpeedProp{
    // Public variables of the token
    string  public name;
    string  public symbol;
    uint8   public decimals = 0;    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public _totalSupply;
    address private  owner ;
    address private currAddr ;
    uint    public tokenPrice;


    SageTokenData stData;






    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    // This generates a public event on the blockchain that will notify clients
    event RejectTransfer(address indexed from, address indexed to, uint256 value, string message);
    
    // This generates a public event on the blockchain that will notify clients
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    //This is if purchase is invalid
    event RejectPurchase(address account, string message);

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
    constructor ( address tknAddr) public payable
    {
        stData = SageTokenData(tknAddr);
        _totalSupply = stData.getTotalSupply() ;  // Update total supply with the decimal amount
        name = stData.getName();                                   // Set the name for display purposes
        symbol = stData.getSymbol();                               // Set the symbol for display purposes
        owner = msg.sender;
        tokenPrice = 500000000000000000 wei;
        currAddr = address(0x692a70D2e424a56D2C6C27aA97D1a86395877b3A);
    }

    function () payable external {
        refund(msg.sender, msg.value) ;
        emit RejectPurchase(msg.sender, "amount refunded!");
    }

    function refund(address toAddress, uint amountToRefund) public returns (bool success){
        address(toAddress).transfer(amountToRefund);
        return true;
    }

    function buyTokens(uint amount) public payable{
        if(amount<stData.getBalance(owner) && msg.value == (amount * tokenPrice) )
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
                
                transferFrom(owner,msg.sender,amount);
                
                emit memoIt2(ss, addr1, addr2);
            }
            else
            {
                ss = string(abi.encodePacked("Tokens not bought:",retMsg));
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
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {

        SageRegulator regulator = SageRegulator(currAddr);
        address addr1;
        address addr2;
        bool isValid= false;
        string memory retMsg = "";
        (isValid, retMsg, addr1, addr2) = regulator.isValidated(msg.sender, msg.sender , _value);
        
        if( isValid )
        {
            string memory ss = string(abi.encodePacked("Tokens transferred:",retMsg));
            stData._transfer(msg.sender, _to, _value);
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
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= stData._getAllowanc(_from,msg.sender));     // Check _allowance

        SageRegulator regulator = SageRegulator(currAddr);
        address addr1;
        address addr2;
        bool isValid= false;
        string memory retMsg = "";
        (isValid, retMsg, addr1, addr2) = regulator.isValidated(msg.sender, _from , _value);
        
        if( isValid )
        {
            string memory ss = string(abi.encodePacked("Tokens transferred:",retMsg));
            uint256 newVal = stData._getAllowanc(_from,msg.sender)-_value;
            
            stData._transfer(_from, _to, _value);
            stData._setAllowanc(_from,msg.sender, newVal);
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
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        stData._setAllowanc(msg.sender,_spender,_value);
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
    function approveAndCall(address _spender, uint256 _value, bytes memory _extraData)  public  returns (bool success) 
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
    function totalSupply() public view returns (uint256 tSupply) {
        return _totalSupply;
    }

    /**
     * return remain_allowance of an address
     *@param _owner
     *@param _spender
     */
    function allowance(address _owner, address _spender) public view returns (uint256 remain_allowance) {
        return stData._getAllowanc(_owner,_spender);
    }
	
	
	 /**
     * return balance of an address
     *@param _owner
     */
    function balanceOf(address _owner) public view returns (uint256 _balance) {
        return stData.getBalance(_owner);
    }
    
    function deactivateIt() public payable {
        if(msg.sender==owner)
        {
            emit contractDiactivated("The contract is being deactivated...");
            selfdestruct(address(owner));
        }
        else
            emit contractDiactivated("You are not the contract owner and you can not deactivate it!");
        
    }

 //---------------------------------------------------------------------------------------------------------------- 

    function setPrice(uint newTokenPrice) public payable {
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
    function getCurrentParams() public view returns (address _addr, uint _val) 
    {
        return (currAddr, tokenPrice);
    }
 //----------------------------------------------------------------------------------------------------------------   

}


contract SageRegulator{
    function isValidated(address qOwner, address sender, uint amount ) view public returns (bool isValid, string memory retMsg, address _addr1, address _addr2);
}


//--------------------------------------------------------------------------------------------------------------------

contract SageTokenData
{

        function getBalance(address _to) public view returns (uint _val);
        function getName() public view returns (string memory _txt);
        function getSymbol() public view returns (string memory _txt);
        function getTotalSupply() public view returns (uint _val);
        
    function _transfer(address _from, address _to, uint _value) public ;
    function _setAllowanc(address _holder,address _spender, uint256 _value) public;
    function _getAllowanc(address _holder,address _spender) public view returns (uint _val);
   
}
