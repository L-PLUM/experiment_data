/**
 *Submitted for verification at Etherscan.io on 2019-02-17
*/

pragma solidity >=0.4.22 <0.6.0;

contract MetaCoin {
    mapping(uint => uint256) public balances;
    function testMapping (uint _to, uint256 _from) public
    {
        balances[_to] = _from;
    }
}
