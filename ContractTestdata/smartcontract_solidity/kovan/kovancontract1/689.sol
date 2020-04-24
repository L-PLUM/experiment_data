/**
 *Submitted for verification at Etherscan.io on 2019-01-14
*/

pragma solidity ^0.4.25;

library TestLibrary {
    function x(uint z) public {
        address p = address(uint160(address(this)));
        p.transfer(z);
    }
}

contract TestContract {
    using TestLibrary for uint;
    
    function y() public {
        uint(5).x();
    }
}
