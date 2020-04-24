/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^0.4.0;

contract ERC20 {
  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public  returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract Leewayhertz is ERC20 {

    //using SafeMath for uint256;

        /* Contain all user address and balance */
       mapping (address => uint256) public balances;

        uint256 totalTokens;
        string public name;
        string public symbol;
        uint8 public decimals;

        /*
         *this function will create token with a initial amount by the owner of the contract
         *uint40 initialSupply,string token_name,string token_symbol,uint8 decimalUnit
         */
        constructor() public {
         totalTokens = 50000 * 10**18;
         balances[msg.sender] = totalTokens;
         name = "MYOS";
         symbol = "MYOS";
         decimals = 18;
       }

       /*
        *Transfer token from the caller account to some other address
        */
        function transfer(address _to, uint256 value) public returns (bool){
          require(balances[msg.sender]>=value);
          balances[msg.sender] = balances[msg.sender]-value;
          balances[_to] = balances[_to]+value;
          //emit Transfer(msg.sender, _to, value);
          return true;
        }

       function totalSupply() public view returns (uint256){
           return totalTokens;
       }

       function balanceOf(address _who) public view returns (uint256){
         return (balances[_who]);
       }
}
