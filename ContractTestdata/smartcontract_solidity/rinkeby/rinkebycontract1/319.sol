/**
 *Submitted for verification at Etherscan.io on 2019-02-17
*/

pragma solidity >=0.4.22 <0.6.0;

contract Owner{
    address public owners;
    uint256 public valuer;
    
}

contract ChangeOwner is Owner{
    modifier mod_isOwner{
        require(msg.sender == owners);
        _;
    }
    
    modifier mod_isValidValue(uint256 a){
        require( a>=100);
        _;
    }
}

contract MetaCoin is ChangeOwner{
    constructor()
    public
    {
        owners = msg.sender;
    }
    
    function FxName(uint _a)
    mod_isOwner
    mod_isValidValue(_a)
    public
    returns(bool res)
    {
        valuer = _a;
        res = true;
    }
}
