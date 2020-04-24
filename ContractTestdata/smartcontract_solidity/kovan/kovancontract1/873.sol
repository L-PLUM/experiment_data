/**
 *Submitted for verification at Etherscan.io on 2018-12-19
*/

pragma solidity 0.4.25;

contract Test {
    string public testString;

    function setString(string _string) public returns(bool) {
        testString = _string;
        return true;
    }
    
    function getString() public view returns(string) {
        return testString;
    }
}
