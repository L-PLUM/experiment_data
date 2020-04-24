/**
 *Submitted for verification at Etherscan.io on 2019-08-04
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
    
    menber[]public menbership_array;
    uint public count = menbership_array.length;
    
    mapping(address=>menber)public menbership;
    
    
  
    
    function set_name(string memory name,uint value)public {
        
       menbership[msg.sender]=menber(name,msg.sender,value);
       menbership_array.push(menbership[msg.sender]);
       
    }
    
    

    
}
