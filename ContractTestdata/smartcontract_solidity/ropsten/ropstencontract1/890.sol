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
    
    function trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint amount) public {
    //amount is in amountGet terms
    bytes32 hash = sha256(abi.encodePacked(this, tokenGet, amountGet, tokenGive, amountGive, expires, nonce));
 

  }
}
