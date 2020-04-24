/**
 *Submitted for verification at Etherscan.io on 2019-07-16
*/

pragma solidity ^0.5.10;

contract SafeMath {
    function add(uint256 a, uint256 b) external pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "addition overflow");

        return c;
    }
}
