/**
 *Submitted for verification at Etherscan.io on 2019-02-17
*/

pragma solidity >=0.4.22 <0.6.0;

contract MetaCoin {
    mapping (address => uint256) public balances;
    // function testMapping(address _to, uint _rol, uint256 _marks)
    // public{
    //     balances[_to][_rol] = _marks;
    // }
    
    function () public {
        balances[0x0] = 1;
    }
    
    struct marker{
        uint Rol;
        uint256 marks;
        address student;
    }
    marker public marker1;
}
