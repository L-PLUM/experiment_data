/**
 *Submitted for verification at Etherscan.io on 2019-08-06
*/

pragma solidity ^0.5.0;

contract Bytes32Test {

    function test(bytes32[] memory data, uint256 i) public pure returns (bytes32) {
        return data[i];
    }
    
    
    function test(bytes32 data) public pure returns (bytes32) {
        return data;
    }
    
    function zeroHash() public pure returns (bytes32) {
        return keccak256(abi.encodePacked(int256(0x0)));
    }
    
    
    function zeroHashBytes32() public pure returns (bytes32) {
        return keccak256(abi.encodePacked(bytes32(0x0)));
    }

}
