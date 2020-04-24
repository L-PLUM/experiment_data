/**
 *Submitted for verification at Etherscan.io on 2019-02-17
*/

pragma solidity >=0.4.22 <0.6.0;

contract owner {
    address public owners;
    uint256 public valuer;
}

contract changeOwner is owner{
    
    modifier mod_isOwner{
        require(msg.sender == owners);
        _;
    }
    
}

contract MetaCoin is changeOwner {

    constructor()
        public
    {
        owners = msg.sender;
    }    

    function FxName( uint _a ) 
        mod_isOwner
        public
        returns ( bool res )
    {
        valuer = _a;
        res = true;
    }

}
