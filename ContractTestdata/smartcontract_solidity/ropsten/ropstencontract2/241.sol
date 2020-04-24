/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity ^0.5.10;

contract Jackpot {
    
    address public owner;
    
    constructor() public payable {
        owner = msg.sender;
    }
    
    function destroyme() public {
        require(msg.sender == owner);
        selfdestruct(msg.sender);
    }

    function hackme(address _address) public {
        _address.delegatecall("0x12345678");
    }
}
