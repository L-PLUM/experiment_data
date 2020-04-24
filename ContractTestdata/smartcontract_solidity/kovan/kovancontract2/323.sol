/**
 *Submitted for verification at Etherscan.io on 2019-07-17
*/

pragma solidity ^0.5.6;

contract TubLike {
    function tab(bytes32) public view returns (uint);
}

contract TestContractViewFunc {
    function tubTab(bytes32 cup) public returns (uint) {
        return TubLike(0xa71937147b55Deb8a530C7229C442Fd3F31b7db2).tab(cup);
    }
}
