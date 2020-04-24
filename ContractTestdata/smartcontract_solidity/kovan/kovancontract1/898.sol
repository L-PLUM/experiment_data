/**
 *Submitted for verification at Etherscan.io on 2018-12-18
*/

pragma solidity ^0.5.1;

contract Test {
    uint256 public tmp;
    function incTmp() external {
        tmp += 1;
    }

     function destroy() external {
        selfdestruct(msg.sender);
    }
//bla-bla
}
