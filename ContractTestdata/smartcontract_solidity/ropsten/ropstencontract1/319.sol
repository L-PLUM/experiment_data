/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

pragma solidity ^0.4.24;

contract SomeContract {
    
    address public owner;
    
    constructor(address _owner) public {
        owner = _owner;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    
    function setOwner(address _owner) onlyOwner public {
        owner = _owner;
    }
    
    function kill() onlyOwner public {
        selfdestruct(owner);
    }
}
