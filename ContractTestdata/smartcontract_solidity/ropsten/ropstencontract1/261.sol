/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

pragma solidity ^0.4.24;
contract Employee {
string fName;
uint age;
function setEmployee(string _fName, uint _age) public
{
    fName = _fName;
    age = _age;
}
function getEmployee() public constant returns (string, uint)
{
    return (fName, age);
}
}
