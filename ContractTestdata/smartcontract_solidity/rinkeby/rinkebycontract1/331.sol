/**
 *Submitted for verification at Etherscan.io on 2019-02-17
*/

pragma solidity >=0.4.22 <0.6.0;

contract MetaCoin {

    mapping (address => uint) public balances;

    bool public val;
    
    function FxName(address _to, uint _from ) 
        internal
        returns(bool result)
    {
        balances[_to] = _from; 
        result = true;
    }
    function pulicFx ( )
        public
    {
        val = FxName(0x8De6A98F7b6266b6eba4E5E73C30289d7Bc3633f,11231231);
    }
}
