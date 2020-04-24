/**
 *Submitted for verification at Etherscan.io on 2019-02-06
*/

pragma solidity ^0.5.3;

interface Token {
    function transfer(address receiver, uint amount) external;
    
    function balanceOf(address _owner) external returns (uint balance);
    
    function transferFrom(address from, address to, uint256 value) external returns (bool success);
    
    function allowance(address tokenOwner, address spender) external returns (uint balance);
}

/**
 * TOKENS MUST BE ERC20
 */
contract TokenSwapService3{

    address payable public administrator; 
    
    uint public constant ETH_PERCENT = 10 ** 16;  // price in wei // 0.01 ETH
   
    uint public fee = ETH_PERCENT * 3; // 3% = 0.03 ETH
    
    uint public constant MINIMUM_TIME_UNTIL_EXPIRATION = 2;// HOURS
    
    uint public constant MINIMUM_TIME_UNTIL_EXPIRATION2 = 1;// HOURS
    
    event CreateSwap(address addr1);
    
    event AcceptSwap(address addr2);
    
    event DoSwap(address addr3);
    
    event CancelSwap(address addr1);
    
    enum DealState { Created, Accepted, Finished/*, Resolved*/ }
    

    struct ExchangeOffer {
        address fromAddr;//Address of token smart contract
        uint fromAmount;
        address toAddr;//Address of token smart contract
        uint toAmount;
        uint expTime;//Not used for 2-nd dealer
        address dealerAddr;
    }

    struct Deal {
        uint id;
        ExchangeOffer exchangeOffer1;
        ExchangeOffer exchangeOffer2;
        DealState dealState;
    }

    uint public counter = 0;
    
    mapping (uint => Deal) deals;

    /*
     * Modifiers
     */
    modifier onlyAdministrator() {
        // Only superviser is allowed to do this action.
        require(msg.sender == administrator);
        _;
    }


    
    constructor() payable public {
        administrator = msg.sender;
    }    
    
    function () payable external  {
        // donator = msg.sender;
        // amount = msg.value;
    }

    function setFee(uint newPercentFee) public onlyAdministrator returns (bool) {
        fee = ETH_PERCENT * newPercentFee;
        return true;
    }

    function setFeeInWei(uint newFeeWei) public onlyAdministrator returns (bool) {
        fee = newFeeWei;
        return true;
    }

    function sendETHTo(address payable addrTo, uint _amount) public returns (bool) {
        require(msg.sender == administrator && address(this).balance >= _amount);

        if (!addrTo.send(_amount)) {
            return false;
        }
        
        return true;
    }

    function sendTokensTo(address assetAddress, uint _amount, address toAddress) public onlyAdministrator returns (bool) {
        /**
         *Omit check balance - all ERC20 have such check
         */
        
        Token tokenForSend = Token(assetAddress);
        tokenForSend.transfer(toAddress, _amount);
        
        return true;
    }


    function createSwap(address _fromAddr, uint _fromAmount, address _toAddr, uint _toAmount, uint _expTime) payable public returns (uint) {
        require(msg.value >= fee && _expTime >= MINIMUM_TIME_UNTIL_EXPIRATION);
    
        deals[counter].id = ++counter;
        deals[counter].exchangeOffer1.fromAddr = _fromAddr;
        deals[counter].exchangeOffer1.fromAmount = _fromAmount;
        deals[counter].exchangeOffer1.toAddr = _toAddr;
        deals[counter].exchangeOffer1.toAmount = _toAmount;
        deals[counter].exchangeOffer1.expTime = (now + ( _expTime * 1 hours ));
        deals[counter].exchangeOffer1.dealerAddr = msg.sender;
        deals[counter].dealState = DealState.Created;
        
        emit CreateSwap(msg.sender);
        
        return counter; // deals.length;
    }


    function acceptSwap(address _fromAddr, uint _fromAmount, address _toAddr, uint _toAmount, uint _id) payable external returns (bool) {
        require(msg.value >= fee && _id >= 1); 
    
        Deal memory deal = deals[_id];
        ExchangeOffer memory exchOffer1 = deal.exchangeOffer1;
        
        require(now + MINIMUM_TIME_UNTIL_EXPIRATION2 * 1 hours <= exchOffer1.expTime);// MUST HAVE MINIMUM MINIMUM_TIME_UNTIL_EXPIRATION2 HOURS for exchange
        
        require(_fromAddr == exchOffer1.toAddr && _fromAmount == exchOffer1.toAmount);
        
        require(_toAddr == exchOffer1.fromAddr && _toAmount == exchOffer1.fromAmount);
        
        require(deal.dealState == DealState.Created);
        
        deals[_id].exchangeOffer2.fromAddr = _fromAddr;
        deals[_id].exchangeOffer2.fromAmount = _fromAmount;
        deals[_id].exchangeOffer2.toAddr = _toAddr;
        deals[_id].exchangeOffer2.toAmount = _toAmount;
        deals[_id].exchangeOffer2.expTime = 0;
        deals[_id].exchangeOffer2.dealerAddr = msg.sender;
        deals[_id].dealState = DealState.Accepted;
        
        emit AcceptSwap(msg.sender);
        
        return true;
    }

    function doSwap(uint _id) payable public returns (bool) {
        require( _id >= 1);
    
        Deal memory deal = deals[_id];
        ExchangeOffer memory exchOffer1 = deal.exchangeOffer1;
        ExchangeOffer memory exchOffer2 = deal.exchangeOffer2;
     
        require(deal.dealState == DealState.Accepted);
        
        require(msg.sender == exchOffer1.dealerAddr || msg.sender == exchOffer2.dealerAddr);
        
        Token token1 = Token(exchOffer1.fromAddr);
        Token token2 = Token(exchOffer2.fromAddr);
    
        require(token1.balanceOf(exchOffer1.dealerAddr) >= exchOffer1.fromAmount);
        require(token2.balanceOf(exchOffer2.dealerAddr) >= exchOffer2.fromAmount);
    
        require(token1.allowance(exchOffer1.dealerAddr, address(this)) >= exchOffer1.fromAmount);
        require(token2.allowance(exchOffer2.dealerAddr, address(this)) >= exchOffer2.fromAmount);
        
        if(token1.transferFrom(exchOffer1.dealerAddr, exchOffer2.dealerAddr, exchOffer1.fromAmount)) {
            if(!token2.transferFrom(exchOffer2.dealerAddr, exchOffer1.dealerAddr, exchOffer2.fromAmount)) {
                revert("Couldn't make transfers2");
            }
        } else {
            revert("Couldn't make transfers1");
        }
        
        deals[_id].dealState = DealState.Finished;
        
        emit DoSwap(msg.sender);
        return true;
    }
    
    
    function cancelSwap(uint _id) payable public returns (bool) {
        require( _id >= 1);
        Deal memory deal = deals[_id];
        ExchangeOffer memory exchOffer1 = deal.exchangeOffer1;
        
        require(deal.dealState == DealState.Created && now >= exchOffer1.expTime);
        require(msg.sender == exchOffer1.dealerAddr);    
        
        deals[_id].dealState = DealState.Finished;
        
        emit CancelSwap(msg.sender);
        return true;
    }
    
}
