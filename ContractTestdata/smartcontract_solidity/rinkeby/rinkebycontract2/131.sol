/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

pragma solidity ^0.5.8;

contract Reversion
{
    bool public storeValue;
    
    function thisWillWork(bool newValue) public
    {
        storeValue = newValue;
    }

    function thisWillSometimesWork() public
    {
        require(storeValue == true, "Store value has to be true");
        storeValue = false;
    }
}
