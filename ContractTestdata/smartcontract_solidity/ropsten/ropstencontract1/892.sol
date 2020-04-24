/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity ^0.4.25;

contract Testing {
    
    int public a;
    int public b;
    function test (int expiry, int tokenamount) public {
        a = expiry;
        b = tokenamount;
    }
}
