/**
 *Submitted for verification at Etherscan.io on 2019-02-23
*/

pragma solidity >=0.4.22 <0.6.0;

contract Asset {
    address public owner;
    address public creator;
    string public name="red car";

    constructor(address _owner) public {
        owner = _owner;
        creator = msg.sender;
    }

}
