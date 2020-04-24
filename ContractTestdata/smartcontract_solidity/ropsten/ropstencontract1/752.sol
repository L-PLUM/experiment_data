/**
 *Submitted for verification at Etherscan.io on 2019-02-14
*/

pragma solidity ^0.4.24;

contract Example {

    constructor() public payable {
        //require(msg.value == 1 ether, "Must send 1 Ether");
    }

    function receiveFunds() public {
        msg.sender.transfer(address(this).balance);
    }

    /** Returns balance of this contract
     */
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /** CTF helper function
     *  Used to check if challenge is complete
     */
    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

}
