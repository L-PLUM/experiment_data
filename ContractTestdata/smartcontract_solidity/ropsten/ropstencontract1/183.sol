/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity 0.5.1;
contract SecretMessage {
    string private secret;
    
    function SetSecret(string memory _secret) public {
        secret = _secret;
    }
}
