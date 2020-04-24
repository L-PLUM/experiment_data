/**
 *Submitted for verification at Etherscan.io on 2019-07-28
*/

pragma solidity ^0.5.0;

contract Lesson03 {
    //Typy danych
    
    //bool public vote;
    bool private vote;
    uint private number; //0-2^256-1
    uint8 private number8; //0-2^8-1
    int numberSign = -1;
    address owner; //2^160
    
    constructor(address _owner) public payable {
        number = 10;
        number8 = 200;
        owner = _owner;
        //owner = 0xca35b7d915458ef540ade6068dfe2f44e8fa733c; //F12 console: web3.toChecksumAddress("0xca35b7d915458ef540ade6068dfe2f44e8fa733c")
    }
    
    
    //Bool
    function display() public view returns(bool) {
        return vote;
    }
    
    
    function voteTrue( ) public{
        vote = true;
    }
    
    
    function voteToggle( ) public{
        vote = !vote;
    }
    
    
    //Number
    function displayNumber() public view returns(uint) {
        return number;
    }
    
    
    //uint8
    function diaplayUint8( ) public view returns(uint8){
        return number8 + 200;
    }
    
    
    //address
    function displayOwner() public view returns(address) {
        return owner;
    }
    
    function displayContractAddr() public view returns(address) {
        return address(this);
    }
    
    //Balance
    function displayBalance() public view returns(uint256) {
        return address(this).balance;
        //return owner.balance;
    }
    
    function getBack() public {
        uint256 currBalance = displayBalance( );
        address(msg.sender).transfer(currBalance);
    }
}
