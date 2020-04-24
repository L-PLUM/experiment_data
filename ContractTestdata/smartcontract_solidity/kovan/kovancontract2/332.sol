/**
 *Submitted for verification at Etherscan.io on 2019-07-16
*/

pragma solidity ^0.5.10;

contract SafeMath {
    function add(uint256 a, uint256 b) public pure returns (uint256);
}

contract Hello {
    SafeMath safeMath = SafeMath(0xF2fD4E3A5b94f0B4D8EE74C009E12F698906420b);

    uint value;

    constructor() public
    {
        value = safeMath.add(value, 100);
    }    
}
