/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

pragma solidity ^0.5.3;
contract profit{
    address depositOwner;
    constructor(address _depositOwner)public{
        depositOwner = _depositOwner;
    }
    mapping(address=>uint)public balanceOf;
    function deposit(address _owner,uint _amount)public  {
        balanceOf[_owner]-=_amount;
        balanceOf[depositOwner]+=_amount;
    }
}
