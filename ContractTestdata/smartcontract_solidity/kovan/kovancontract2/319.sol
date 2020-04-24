/**
 *Submitted for verification at Etherscan.io on 2019-07-17
*/

pragma solidity ^0.5.10;

contract Counter {
    uint c = 0;

    function count() public returns (uint) {
        c ++;
        return c;
    }
}
