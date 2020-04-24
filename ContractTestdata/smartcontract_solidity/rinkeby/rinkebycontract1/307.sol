/**
 *Submitted for verification at Etherscan.io on 2019-02-17
*/

pragma solidity 0.5.2;

contract Interagieren { 

    mapping(address=>bytes32) public names; 
    mapping(address=>bool) public gateOneStatus; 
    mapping(address=>bool) public gateTwoStatus; 

    modifier nameIsFill() { 
        require(names[msg.sender] != bytes32(0), "You have to fill your name."); 
        _; 
    } 
    modifier notFromYou() { 
        require(tx.origin != msg.sender, "You can't use your address directly to interact"); 
        _; 
    } 
    modifier butStillYou(string memory yourName) { 
        require(names[tx.origin] == keccak256(abi.encode(yourName)), "You must interact with your own address"); 
        _; 
    } 

    function initial(string memory name) public { 
        names[msg.sender] = keccak256(abi.encode(name));
    } 

    function gateOne() public nameIsFill { 
        gateOneStatus[msg.sender] = true; 
    } 
    
    function gateTwo(string memory _name) public notFromYou butStillYou(_name) {
        gateTwoStatus[tx.origin] = true; 
    } 
}
