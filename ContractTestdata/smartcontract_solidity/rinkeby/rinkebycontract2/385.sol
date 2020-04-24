/**
 *Submitted for verification at Etherscan.io on 2019-07-28
*/

pragma solidity ^0.5.0;

contract Lesson03 {
    
    address public owner;
    
    constructor() public payable {
        owner = 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c;
    }
    
    function display() public view returns(uint256){
        return address(this).balance;
    }
    
    function getBack() public payable {
        uint currBalance = display();
        address(msg.sender).transfer(currBalance);
    }
}
