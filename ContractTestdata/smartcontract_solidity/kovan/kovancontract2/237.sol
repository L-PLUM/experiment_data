/**
 *Submitted for verification at Etherscan.io on 2019-07-25
*/

pragma solidity >=0.4.22 <0.6.0;
contract SimpleContract {
    
    //global variable
    uint count;
    
    //event
    event IncrementedCount(uint count);
    
    //constructor
    constructor() public{
        count = 0;
    }
    
    function incrementCountValue(uint _value) public returns(uint count_){
        count += _value;
        
        emit IncrementedCount(count);
        count_ = count;
    }
    
    function getPresentCount() public view returns (uint count_){
        count_ = count;
    }
    
    
}
