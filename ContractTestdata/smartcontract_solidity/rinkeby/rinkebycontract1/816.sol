/**
 *Submitted for verification at Etherscan.io on 2019-02-07
*/

pragma solidity 0.5.3;

contract Convert {
    function b(uint256 _a, uint256 _b, uint256 _c) public pure returns (bytes memory) {
        return abi.encode(_a, _b, _c);
    }
    
    function s(uint256 _a, uint256 _b, uint256 _c) public pure returns (string memory) {
        return string(b(_a, _b, _c));
    }
}
