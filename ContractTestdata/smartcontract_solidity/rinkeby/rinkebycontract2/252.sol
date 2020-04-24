/**
 *Submitted for verification at Etherscan.io on 2019-08-02
*/

pragma solidity ^ 0.5.0;

contract FICO_test {
    
    
    
    address owner;
    
    
    constructor()public{
     owner = msg.sender; 
    }
    
    
    
    struct menber {
        string user_name;
        address user_address;
        uint token_count;
    }
    
    mapping(address=>menber)public menbership;
    
    function set_name(string memory name,uint value)public {
       menbership[msg.sender]=menber(name,msg.sender,value);
       
    }
    
    
}
