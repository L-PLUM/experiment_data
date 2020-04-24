/**
 *Submitted for verification at Etherscan.io on 2019-02-01
*/

pragma solidity ^0.5.1;

contract get_set {
    uint storedData;
    string storedText;
    
    function set(uint x ,string memory text) public {
        storedData = x;
        storedText = text;
    }

    function get() public view returns(uint a, string memory b) {
        return (storedData, storedText);
    }
}
