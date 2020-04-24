/**
 *Submitted for verification at Etherscan.io on 2019-02-17
*/

pragma solidity >=0.4.22 <0.6.0;

contract testLib{
   uint256 public changeVar;
   function mul ( uint a )
       public
       returns( bool res )
   {
       changeVar = a;
       res = true;
   }
}
contract MetaCoin {
   
   testLib T1;

   function init(address _lib)public {
       T1 = testLib(_lib);
   }
   function FxName( uint _a ) 
       public
   {
       T1.mul(_a);
   }

}
