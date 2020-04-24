/**
 *Submitted for verification at Etherscan.io on 2019-02-17
*/

pragma solidity >=0.4.22 <0.6.0;

library testlib
    {
        function publicfx()
        pure
        public
        returns (uint res)
        
        {
            res = 2*2;
        }
    }
contract MetaCoin
    {
       mapping (address => uint) public balances;
       bool public val;
        function FxName(address _to, uint _from)
        internal
        returns(bool result)
        {
            balances[_to] = _from;
            result = true;
        }
        function publicfx( )
                public
        returns(bool res)
        {
           res  = FxName(0x71fDb9BC0d22bdD5EDA3586De4Aa0Bd0C1E22C6e, 1234);
        }
    }
