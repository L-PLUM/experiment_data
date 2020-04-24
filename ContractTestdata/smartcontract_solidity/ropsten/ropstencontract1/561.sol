/**
 *Submitted for verification at Etherscan.io on 2019-02-17
*/

pragma solidity 0.5.4;

library SafeMath {
  
  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint256 a, uint256 b) internal pure  returns (uint256) {
    uint c = a + b;
    assert(c>=a);
    return c;
  }
  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }
}


interface Token {
  function balanceOf(address who) pure external returns (uint256 _user);
  function transfer(address _to, uint256 _value) external returns (bool);
  function transferFrom(address _from,address _to, uint256 _value) external returns (bool);
  function approve(address _spender, uint256 _value) external returns (bool);
}

contract TokenDistributor{
    using SafeMath for uint256;
    string public constant name = "TokenConnect";
    
  event TokensTransferred(address indexed _from, address indexed to, uint256 value);
  
  constructor() public {
      
  }
  
  function getContractName() pure public returns(string memory){
     return name; 
  }

  function sendTokens(address _contract, address[] memory _to, uint _value) public returns(bool){
    Token token = Token(_contract);
    uint bal = token.balanceOf(msg.sender);
    uint len = _to.length;
    uint total_required_balance = len.safeMul(_value);
    require(bal >= total_required_balance);
    require(len <= 230);
    
    for(uint i =0; i < len; i++)
    {
        token.transferFrom(msg.sender, _to[i], _value);
        emit TokensTransferred(msg.sender, _to[i], _value);
    }
    return true;  
  }
 
}
