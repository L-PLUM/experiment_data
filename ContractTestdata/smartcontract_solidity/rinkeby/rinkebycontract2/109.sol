/**
 *Submitted for verification at Etherscan.io on 2019-08-08
*/

pragma solidity ^0.5.0;

contract Try {
    
    mapping(uint => uint) details;
    
    function setValue(uint index,uint value) public returns (bool) {
        details[index] = value;
        return true;
    }
    
    function getValue(uint index) public view returns(uint) {
        require(details[index] > 0);
        return details[index];
    }
}
