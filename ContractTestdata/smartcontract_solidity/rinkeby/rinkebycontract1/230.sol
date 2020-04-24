/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity ^0.5.1;
contract class23{
        uint256 public integer_1 = 1;
        uint256 public integer_2 = 2;
        string public string_1;
    
        event setNumber(string _from);
  
        function function_3(string memory x)public returns (string memory){
            string_1 = x;
            emit setNumber(string_1); //新版規定事件一定要加emit
            return string_1;
        }
}
