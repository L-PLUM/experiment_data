/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity ^0.5.2;

// File: contracts/whitelisting/MgnBasicMock.sol

contract MgnBasicMock {

    // user => amount
    mapping (address => uint) public lockedTokenBalances;

    function lock(uint256 _amount) public {
        lockedTokenBalances[msg.sender] = _amount;
    }
}
