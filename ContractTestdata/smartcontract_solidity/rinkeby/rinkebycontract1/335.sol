/**
 *Submitted for verification at Etherscan.io on 2019-02-17
*/

pragma solidity >=0.4.22 <0.6.0;

contract MetaCoin{
    mapping (address => mapping (uint256 => uint256)) public marks;
    
    function testMapping(address _to, uint _rol, uint _marks)
    public {
        marks[_to][_rol] = _marks;
    }
    
}
