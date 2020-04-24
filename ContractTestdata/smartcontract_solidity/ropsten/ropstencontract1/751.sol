/**
 *Submitted for verification at Etherscan.io on 2019-02-14
*/

pragma solidity ^0.4.24;

contract SimpleBank {

    bytes32 _id;
    mapping (address => uint256) public funds;

    constructor() public payable {
        //require(msg.value == 1 ether, "Must send 1 Ether");
    }

    /** Stores your Eth in a secure contract
     */
    function deposit() public payable {
        require(msg.value > 0);
        
        funds[msg.sender] += msg.value;
    }

    /** Call this to donate some stored funds to the contract
     */
    function donate(uint256 amount) public {
        require(funds[msg.sender] > 0);
        
        funds[msg.sender] -= amount;
    }

    /** Send stored Eth back
     */
    function refund() public {
        require(funds[msg.sender] > 0);

        uint256 refund = funds[msg.sender];

        funds[msg.sender] = 0;

        msg.sender.transfer(refund);
    }

    /** CTF helper function
     *  Used to check if challenge is complete
     */
    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

}
