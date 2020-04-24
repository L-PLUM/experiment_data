/**
 *Submitted for verification at Etherscan.io on 2019-02-17
*/

pragma solidity >=0.4.22 <0.6.0;

contract owner {
    address public owner;
}

contract changeOwner is owner {
    modifier mod_id_owner {
        require (msg.sender == owner);
        _;
    }
}

contract Me is changeOwner {
    
    uint256 public value;
    
    constructor() 
    public {
        owner = msg.sender;
    }
    
    function changeValue(uint256 _a)
        mod_id_owner
        public
        returns (bool res){
        
        value = _a;
        res = true;
            
    }
    
}
