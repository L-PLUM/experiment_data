/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity >=0.4.22 <0.6.0;
contract Send {

    struct recipient {
       string mess;
    }
    

    mapping(address => recipient) recipients;
  
    function message(string memory m) public {
        recipient memory r;
        r.mess = m;
        
    }
}
