/**
 *Submitted for verification at Etherscan.io on 2019-07-16
*/

pragma solidity ^0.5.10;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "addition overflow");

        return c;
    }
}

contract Hello {
    using SafeMath for uint256;
    uint value;

    constructor() public
    {
        value = value.add(100);
    }    
}
