/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

pragma solidity ^0.5.3;

contract A {

    B b;

    constructor(address _bAddr) public {
        require (_bAddr != address(0));
        b = B(_bAddr);
    }

    function aggiornaBAddr(address _bAddr) public {
        require (_bAddr != address(0));
        b = B(_bAddr);
    }

    function chiamaBcheChiamaC() public {
        b.chiamaC();
    }

    function eseguiIstruzione(string memory _istruzione) public pure returns(string memory) {
        return _istruzione;
    }

}

contract B {
    function istanziaC(address _cAddr) public;
    function chiamaC() public;
}
