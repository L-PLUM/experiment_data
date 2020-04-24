/**
 *Submitted for verification at Etherscan.io on 2019-01-25
*/

pragma solidity ^0.5.0;

library TestLibrary {
    function x(uint z) public {
        address payable p = address(uint160(address(this)));
        p.transfer(z);
    }
}

contract TestContract {
    using TestLibrary for uint;
    
    function y() public {
        uint(5).x();
    }
}
