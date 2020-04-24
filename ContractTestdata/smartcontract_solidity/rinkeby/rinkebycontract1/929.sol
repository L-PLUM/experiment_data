/**
 *Submitted for verification at Etherscan.io on 2019-02-04
*/

pragma solidity ^0.5.3;


// I used only what is required in this specific project
interface ERC20 {
     
    event Transfer(address indexed _from, address indexed _to, uint _value);    
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

//You may deploy with one address and change owner to another address 
//to receiver payment

contract Owned {
    address public owner;

    constructor() public payable {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
            _;
    }

    function _transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}
    

contract WakaCoins is Owned, ERC20 {
        
    // Public variables of the token
    string public name = "WakaCoins";
    string public symbol = "WKC";
    uint256 public tokensSold; // Total tokens sold
    uint256 public tokenBought;
    uint256 tokenCosts; //Amout of ether in wei investor will pay
    uint8 public decimals = 18;  // 18 decimals is the strongly suggested default.
    uint256 softcap = 10000; //Target ICO to be a success
    
    //Keep 20% of ICO for owner.
    uint256 totalSupply = 1000000;
    uint256 ownerReserve = totalSupply * 1/5; //Solidity only support integers
    uint256 initialSupply = totalSupply - ownerReserve;
    
    //Three different prices based on quantity of WakaCoins already sold.
    //NOTE: WakaCoins Prices are in wei. 1/1000 = 0.001 ether
    uint256 bigBonusPrice =1 * 10 ** uint256(decimals-3);//0.001 ether in wei
    uint256 smallBonusPrice = bigBonusPrice * 6/5;
    uint256 wakaCoinsPrice = smallBonusPrice * 13/10;
    
    // This creates an array with all balances
    mapping (address => uint256) public ownerReserveTokens; //Contains 20% WakaCoins
    mapping (address => uint256) public balanceOf;
    
    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor() public payable {
        // Give the creator all initial tokens for the ICO
        balanceOf[msg.sender] = initialSupply;  
        ownerReserveTokens[msg.sender] = ownerReserve; // 20% not for sale
    }
    

    function invest(uint numberOfTokens) public {
        tokenBought =  numberOfTokens;
        tokensSold = tokensSold + tokenBought;
        balanceOf[msg.sender] -= tokenBought; 
    }
    

    function getBuyPrice() internal returns(uint256) {
        
     //calculate amount of wei to sent based on WakaCoins bought
        if (tokensSold < 100) {
            tokenCosts = tokenBought * bigBonusPrice;
        } 
        if (tokensSold >= 100 && tokensSold <= 300) {
            tokenCosts = tokenBought * smallBonusPrice;
        } else {
            tokenCosts = tokenBought * wakaCoinsPrice;
    } 
    }   
     
    // Buy tokens from contract by sending ether first. 
    //Admin will issue tokens at end of ICO 
    function payModule() private {
        _transfer(address(this), msg.sender, tokenCosts);   // makes the transfers
    }
    
    
     /* Internal transfer can be called by this contract to issue tokens when investor pay ether */
    function _transfer(address _from, address _to, uint256 _value) internal {
        require (_to != address(0x0));                          // Prevent transfer to 0x0 address. Use burn() instead
        require (balanceOf[_from] >= _value);                   // Check if the sender has enough
        require (balanceOf[_to] + _value >= balanceOf[_to]);    // Check for overflows
        balanceOf[_from] -= _value;                             // Subtract from the sender
        balanceOf[_to] += _value;                               // Add the same to the recipient
        emit Transfer(_from, _to, _value);
    }
    
       
    // Transfer tokens only when you received the payment of the investor through bank account.
    // Only owner can run this

    //function transfer(address _to, uint256 _value) onlyOwner public payable returns (bool success) {
     //   _transfer(owner, _to, _value);
     //   balanceOf[msg.sender] -= tokenBought;
       // return true;
   // }

//Refund ether if ICO target is not reached
//To aviod fees it is best practice for investors to call this module themselves to get a refund
    function refund() payable public {
         require(tokensSold < softcap);
         uint256 value = balanceOf[msg.sender];
         balanceOf[msg.sender] = 0;
         msg.sender.transfer(value);
    }
    
}
