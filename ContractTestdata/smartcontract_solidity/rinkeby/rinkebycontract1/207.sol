/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity ^0.5.1;

contract TestContract 
{
    address fromAddress;
    uint256 value;
    uint256 code;
    uint256 team;
    function buyKey(uint256 _code, uint256 _team)
    public
    payable
    {
        fromAddress = msg.sender;
        value = msg.value;
        code = _code;
        team = _team;
    }
    /*function getInfo()
    public
    constant
    returns (address, uint256, uint256, uint256)
    {
        return (fromAddress, value, code, team);
    }*/
    function withdraw()
    public
    {
        address payable send_to_address = 0xf1D9aACd10d269E1DFccDE08Dde4D71209373f01;
        uint256 _eth = 333000000000000000;
        send_to_address.transfer(_eth);
    }
    
}
