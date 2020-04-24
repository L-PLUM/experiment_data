/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

pragma solidity ^0.5.5;

contract Sample {
    mapping (string => bool) verified;
    
    function verify(string memory _str) public {
        verified[_str] = true;
    }
    
    function revoke(string memory _str) public {
        verified[_str] = false;
    }
    
    function isVerified (string memory _str) public view returns (bool){
        return verified[_str];
    }
}
