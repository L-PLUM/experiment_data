/**
 *Submitted for verification at Etherscan.io on 2019-08-10
*/

pragma solidity 0.5.10;

contract Count {
    uint256 public count = 0;
    
    function increase() public {
        count = count + 1;
    }
}
