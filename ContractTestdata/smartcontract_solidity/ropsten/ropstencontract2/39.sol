/**
 *Submitted for verification at Etherscan.io on 2019-08-12
*/

pragma solidity 0.5.10;

contract Receiver{
    
        function() payable external {}
        
        function addEtherToContract() external payable{}
    
}


contract Sender {
    
    Receiver receiver;
    
    constructor() public {
        receiver = new Receiver();
    }
    
    function sendToReceiver() payable external returns(bool){
       return address(receiver).send(msg.value);
    }
    
    function transferToReceiver() payable external{
        address(receiver).transfer(msg.value);
    }
    
    function addEtherToReceiverContract() payable external{
        receiver.addEtherToContract.value(msg.value)();
    }
    
}
