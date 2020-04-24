/**
 *Submitted for verification at Etherscan.io on 2019-02-01
*/

pragma solidity ^0.5.0;


contract AA {
    
    uint public a = 2;
    function b(uint _a) public {
        require(_a == 5);
        a= _a;
    }
    
}
