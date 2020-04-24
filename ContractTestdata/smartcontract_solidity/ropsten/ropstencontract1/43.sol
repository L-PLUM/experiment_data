/**
 *Submitted for verification at Etherscan.io on 2019-02-23
*/

pragma solidity ^0.5.1;

contract InternalTransaction {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    function transferBack() payable public {
        msg.sender.transfer(msg.value);
    }
}
