pragma solidity ^0.5.0;

contract Test{
    uint256 public a ;
    // bytes32 public b;
    // uint256 public c = b.length;
    constructor() public{
        add(1,2);
    }
    function add (uint256 first, uint256 second) public {
        a = first + second;
    }
}
