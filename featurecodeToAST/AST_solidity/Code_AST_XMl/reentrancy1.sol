pragma solidity 0.4.25;
contract Bank{
    mapping(address => uint) balance;
	
    function deposit() public payable {
        balance[msg.sender] += msg.value; 
    }

    function withraw(uint amount) public payable{
            require(balance[msg.sender] >= amount);
               msg.sender.call.value(amount)("");
				balance[msg.sender] -=amount;                       
        } 
	
}