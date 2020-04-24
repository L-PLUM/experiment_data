/**
 *Submitted for verification at Etherscan.io on 2019-08-02
*/

pragma solidity ^ 0.5.0;

contract FICO_test {
    
    
    
    address owner;
    
    
    constructor()public{
     owner = msg.sender; 
    }
    
    
    
    //查詢ETH餘額
    function balance_of( address user_balance)public view returns(uint) {
        return user_balance.balance;
        
    }
    
}
