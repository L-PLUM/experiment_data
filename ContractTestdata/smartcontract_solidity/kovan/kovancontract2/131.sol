/**
 *Submitted for verification at Etherscan.io on 2019-07-31
*/

pragma solidity >=0.5.0 <0.6.0;

contract SimpleStorage {
    
    uint256 private number;
    
    constructor() public {
        number = 10;
    }
    
    function getNumber() public view returns(uint256) {
        return number;
    }
    
    function setNumber(uint256 _number) public {
        number = _number;
    }
    
}
