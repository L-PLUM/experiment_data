/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity ^0.4.24;

contract counter {
    
    uint256 myNumber = 0;
    
    function add() public {
        myNumber++;
    }
    function subtract() public {
        if (myNumber >= 0){
            myNumber--;   
        }
    }
    
}

contract whatNumber is counter {
    bytes32 numberName = "the number is lower than 10";
    
    function checkNumber() public {
        if (myNumber <= 10){
            numberName = "the number is lower than 10";
        }
        if (myNumber == 10){
            numberName = "the number is 10";
        }
         if (myNumber >= 10){
            numberName = "the number is higher than 10";
        }
    } 
}
