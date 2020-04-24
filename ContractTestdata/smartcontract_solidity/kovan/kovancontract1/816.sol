/**
 *Submitted for verification at Etherscan.io on 2018-12-31
*/

pragma solidity ^0.5.0;

contract TestContract {

    event TestEvent(uint256 _uint, string _string);

    function test(uint256 _uint, string memory _string) public returns (uint256 _result) {
        _result = _uint * 2;
        emit TestEvent(_uint, _string);
    }

}
