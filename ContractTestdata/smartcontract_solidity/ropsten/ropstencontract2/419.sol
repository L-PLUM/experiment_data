/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

pragma solidity ^0.5.10;

contract Test {
    uint256 public count;
    
    function increment () public {
        count++;
    }
    
    function () external {
        increment();
    }
}
