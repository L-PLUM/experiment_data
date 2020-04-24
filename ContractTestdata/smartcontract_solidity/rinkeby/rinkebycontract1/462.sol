/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.5.4;

contract RejectTest {
    
    constructor() public {
    }
    
    function getEtherBalance() public view returns(uint) {
        return address(this).balance;
    }
    
    function() external payable {
        revert();
    }
}
