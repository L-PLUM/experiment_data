/**
 *Submitted for verification at Etherscan.io on 2019-02-17
*/

pragma solidity ^0.5.1;

contract DocumentRegistry {
    mapping (string => uint256) documents;
    address contractOwner = msg.sender;

    function add(string memory hash) public {
        require (msg.sender == contractOwner);
        documents[hash] = block.timestamp;
    }

    function verify(string memory hash) view public
        returns (uint256 dateAdded) {
        return documents[hash];
    }
}
