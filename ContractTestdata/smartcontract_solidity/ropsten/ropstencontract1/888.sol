/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity ^0.5.3;

contract A {

    address bAddr;

    constructor(address _bAddr) public {
        require (_bAddr != address(0));
        bAddr = _bAddr;
    }

    function aggiornaBAddr(address _bAddr) public {
        require (_bAddr != address(0));
        bAddr = _bAddr;
    }

    function chiamaBcheChiamaC() public returns(bool, bytes memory) {
         (bool success, bytes memory data) = bAddr.delegatecall(abi.encodeWithSignature("chiamaC(address)", address(this)));
         return (success, data);
    }

    function eseguiIstruzione(string memory _istruzione) public pure returns(string memory) {
        return _istruzione;
    }

}
