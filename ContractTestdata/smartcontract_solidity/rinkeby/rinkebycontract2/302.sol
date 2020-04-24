/**
 *Submitted for verification at Etherscan.io on 2019-07-31
*/

pragma solidity ^0.4.17;

contract Sample {
    uint data;

    function set(uint d) public{
        data = d;
    }

    function get() public constant returns (uint retVal) {
        return data;
    }
}
