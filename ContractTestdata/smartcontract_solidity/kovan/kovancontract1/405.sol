/**
 *Submitted for verification at Etherscan.io on 2019-01-30
*/

pragma solidity ^0.4.24;

//interface
contract Compliance {

    function canTransfer(address _from, address _to, uint256 value) public view returns(bool);
}
contract DefaultCompliance is Compliance {
    function canTransfer(address _from, address _to, uint256 _value) public view returns (bool) {
        return true;
    }
}
