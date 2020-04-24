/**
 *Submitted for verification at Etherscan.io on 2019-02-23
*/

pragma solidity >=0.4.0 <0.6.0;


contract myEvent {
    
    address payable owner;
    uint public tickets;
    uint constant price = 1 ether;
    mapping (address => uint) public purchasers;
    
    constructor (myEvent) public{
        owner = msg.sender;
        tickets = 500;
        
    }
    
    function () external payable {
        buyTickets(1);
    }
    
    function buyTickets(uint amount) public payable returns (bool){
        require((msg.value == amount * price), "Invalid Transaction!");
        require(amount <= tickets, "Not Enough tickets!");
        
        purchasers[msg.sender] += amount;
        tickets -= amount;
        /**Refund function breaks with this line*/
        /**owner.transfer(msg.value);*/
        
        
        if (tickets == 0){
            /**selfdestruct(owner);*/
            owner.transfer(address(this).balance);
        
        }
    return true;

    }
    
    function refunding (uint numTickets) external returns (bool){
        require((numTickets > 0) || purchasers[msg.sender] >= numTickets);
        
        msg.sender.transfer(numTickets * price);
        
        purchasers[msg.sender] -= numTickets;
        tickets += numTickets;
        
        return true;
    }
    
    function website () public view returns(string memory){
        return "www.myawesomeconcert.com";
    }
    
    function msgSenderViewer () external payable returns(uint){
        return(msg.value);
    }
    
    
}
