/**
 *Submitted for verification at Etherscan.io on 2019-08-11
*/

pragma solidity ^0.5.0;

contract PublicKeyRegistry {
    
    address owner;
    mapping(address => bytes) public pubkeys;
    
    event KeyAdded(address indexed actor, address indexed subject);
    
    constructor() public {
        owner = msg.sender;
    }
    
    function addKey(address addr, bytes memory pubkey) public {
        require(msg.sender == owner || msg.sender == addr, "Not owner or user");
        pubkeys[addr] = pubkey;
        emit KeyAdded(msg.sender, addr);
    }
}
