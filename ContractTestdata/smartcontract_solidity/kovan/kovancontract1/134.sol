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
