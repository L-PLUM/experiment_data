/**
 *Submitted for verification at Etherscan.io on 2019-02-23
*/

pragma solidity ^0.5.2;
pragma experimental ABIEncoderV2;

contract SmartStore {
    address public owner;
    struct Proof {
        uint timestamp;
        string origin;
    }
    mapping (string => Proof) private hashstore;

    constructor() public {
        owner = msg.sender;
    }

    function store(string memory hash, string memory origin) public returns (Proof memory) {
        require(msg.sender == owner, "Only contract owner can update hashes");
        require(hashstore[hash].timestamp == 0, "This hash was already stored, you can only get it");
        hashstore[hash] = Proof(block.timestamp, origin);
        return hashstore[hash];
    }

    function get(string memory hash) public view returns (Proof memory) {
        return hashstore[hash];
    }
}
