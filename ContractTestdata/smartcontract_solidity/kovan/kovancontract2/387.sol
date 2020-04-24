/**
 *Submitted for verification at Etherscan.io on 2019-07-12
*/

pragma solidity ^0.4.25;

contract Add {
    uint public x;
    
    function add(uint a, uint b) public returns (uint y) {
        x = a + b;
        y = x;
    }
}
