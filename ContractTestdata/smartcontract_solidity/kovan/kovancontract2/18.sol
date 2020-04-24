/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity ^0.5.1;
contract TestContract {

    uint256 public num = 0;
    event Added(uint indexed num, uint anotherNum);
    
    constructor() public {
        
    }
    
    function addOne() public {
        num += 1;
        uint doubledNum = num * 2;
        emit Added(num, doubledNum);
    }
    
    function getNum() public view returns (uint256) {
        return num;
    }
    
    function helloWorld() public pure returns (string memory) {
        return "hello world!";
    }
    
    function addNumbers(uint a, uint b) public pure returns (uint) {
        return a+b;
    }
}
