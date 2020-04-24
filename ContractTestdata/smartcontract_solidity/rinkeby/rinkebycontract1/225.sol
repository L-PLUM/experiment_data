/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity ^0.4.25;

contract NagemonUtils {
    struct Passwords {
        uint8 password;
        bool isExist; 
    }
    // the mapping to judge whether each address has already register password
    mapping (address => Passwords) passwords;
    /**
    * @dev Register password for each address
    */
    
    function selfPassword() public view returns (bool) {
        return true;
    }
    function random() private view returns (uint8) {
        return uint8(uint256(keccak256(block.timestamp, block.difficulty))%251);
    }
    function setPasswokrd() public returns (uint8) {
        if(passwords[msg.sender].isExist) return passwords[msg.sender].password;
        passwords[msg.sender].password = random();
        passwords[msg.sender].isExist = true;
        
        return passwords[msg.sender].password;
    }
    
}
