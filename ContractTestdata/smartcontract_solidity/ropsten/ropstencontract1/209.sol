/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^0.4.0;

contract Elevator {
    function goTo(uint) public {}
}

contract Building {
    bool done = false;

    function isLastFloor(uint floor) view public returns (bool) {
        if (!done) {
            done = true;
            return false;
        } else {
            return true;
        }
    }

    function goTo(address elevator, uint floor) public {
        Elevator e = Elevator(elevator);
        e.goTo(floor);
    }
}
