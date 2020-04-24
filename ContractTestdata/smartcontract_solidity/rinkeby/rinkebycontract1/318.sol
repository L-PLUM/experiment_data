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
        require(msg.sender == owners) ;
        _;
    }

    modifier mod_isValidValue(uint256 a){
        uint256 ab = 100;
        require(a>50);
        _;
    }
    
    
}

contract test{
    uint256 public value;
    
    constructor(uint256 _a)
        public
    {
        value = _a;
    }    

}

contract MetaCoin is changeOwner {
    
    test t1;
    uint256 counter;
    mapping( address => uint256 ) public contracts;
    mapping( uint256 => address ) public contractsinv;
     
    constructor()
        public
    {
        owners = msg.sender;
    }    

    function FxName( uint _a ) 
        mod_isOwner
        mod_isValidValue(_a)
        public
        returns ( bool res )
    {
        valuer = _a;
        res = true;
    }
    
    function addContract (uint256 _a)
        public
        mod_isOwner        
    {
        t1 = test(_a);
    }
}
