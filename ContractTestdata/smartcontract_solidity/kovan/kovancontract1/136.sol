/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity ^0.5.0;

library Test {
    
    event LogA(uint256 _a);
    
    function check(uint256 _param) public {
        emit LogA(_param);
    }
}

contract ABC {
    
    event LogB(uint256 _c, uint256 _timestamp);
    
    function checkLibrary(uint256 _checkParam) public {
        Test.check(_checkParam);
        emit LogB(_checkParam, now);
    }
}
