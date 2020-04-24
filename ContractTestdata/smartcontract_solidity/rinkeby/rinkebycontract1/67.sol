/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity ^0.5.1;
contract class25{    
    
    mapping(address=>uint) balances;
    
    uint public abc = 0;
    
    function() external{
        abc++;    
    }
    // function () public payable{
    //     //可以對此合約發送以太
    // }
    
    function sendEther()public payable{
        balances[msg.sender] += msg.value;
    }

    function sendEtherNoPayable()payable public{
        balances[msg.sender] += msg.value;
    }

    function returntest()public view returns(address){
        //execution
        return msg.sender;
    }
    //無名方法
    //payable
    //兩種方法return   return, callback
}
