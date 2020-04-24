/**
 *Submitted for verification at Etherscan.io on 2019-07-16
*/

pragma solidity ^0.5.10;

contract TubLike {
    function tab() public view returns (uint);
}

contract TestContractViewFunc {
    address tub = 0xa71937147b55Deb8a530C7229C442Fd3F31b7db2;

    function tubTab() public {
        TubLike(tub).tab();
    }
}
