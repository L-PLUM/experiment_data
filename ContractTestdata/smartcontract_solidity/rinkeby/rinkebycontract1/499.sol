/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity ^ 0.4.25;

contract Test_Game{
    
    uint public aa ;
    address owner = msg.sender;
    address public player = msg.sender ;
    
    constructor() public {
        require ( owner == msg.sender, "sorry , you aren't user");
    }
    
    
    function add_01 () public payable{
         aa++;
    }
    
   
}
