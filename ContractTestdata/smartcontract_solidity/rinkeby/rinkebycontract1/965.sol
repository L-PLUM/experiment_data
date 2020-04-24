/**
 *Submitted for verification at Etherscan.io on 2019-02-01
*/

pragma solidity 0.5.2;

contract Contract_C {
    
    address payable [5] public target = [address(0), address(0),address(0),address(0),address(0)];
    uint8 public max = 5;
    uint public amountToPaid = 1;
    
    event Sent(address destination, uint amount);
    
    // constructor () internal {
    // }
    
    function setTarget(uint8 i, address payable newTarget) public {
        if(i < 5) {
            target[i] = newTarget;
        }
    }

    function () payable external {
        
        for(uint8 i; i < max; i++) {
            amountToPaid++;
            if(target[i] != address(0)) {
                target[i].call.value(amountToPaid).gas(gasleft());
                emit Sent(target[i], amountToPaid);
            }
        }
        
    }
}
