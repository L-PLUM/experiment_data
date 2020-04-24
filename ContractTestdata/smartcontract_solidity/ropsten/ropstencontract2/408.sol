/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

pragma solidity ^0.5.10;

contract ExitScamUs {

    uint public constant INITIALEXPIRYBLOCKS = 100;
    uint public constant BUMP = 3;

    address public lastContributor;
    uint public expiryBlock;
    uint public minimumAmount = 0.1 ether;

    constructor () public {
        expiryBlock = block.number + INITIALEXPIRYBLOCKS;
    }

    function () payable external {
        lastContributor = msg.sender;
        require(msg.value > minimumAmount);
        require(block.number <= expiryBlock);
        minimumAmount = msg.value * 110 / 100;
        expiryBlock += BUMP;
    }

    function claim() public {
        require(block.number > expiryBlock);
        address(uint160(lastContributor)).transfer(address(this).balance);
    }

}
