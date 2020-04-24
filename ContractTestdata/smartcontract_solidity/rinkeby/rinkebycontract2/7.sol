/**
 *Submitted for verification at Etherscan.io on 2019-08-13
*/

pragma solidity ^0.5.0;

// import "./fest.sol";
contract Test{
    bytes32 private _symbol;
    function symbol() public view returns (bytes32) {
        return _symbol;
    }
}
