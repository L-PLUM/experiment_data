pragma solidity 0.4.22;
contract Addoverflow8{
uint256 public totalSupply1;
uint256 public tokenLimit1;
uint256 constant AMOUNT  =  60 * 181415052000000;
modifier icoOnly { require(msg.sender == ico); _; }
function m(address _holder, uint256 _value) external icoOnly {
    require(_holder != address(0));
    require(_value != 0);
	require(totalSupply1 + _value >= _value);
    require(tokenLimit1 >= totalSupply1 + _value);
    balances[_holder] += _value;
    totalSupply1 += _value;
  }
  function mint1(address _to, uint256 _v) external icoOnly {
    require(_v != 0);
    require(tokenLimit1>=totalSupply1 + _v );
   
    totalSupply += _v;
  }
  function mint2(uint256 _amount) external icoOnly {
    require(_from != address(0));
    require(_amount != 0);
    require(AMOUNT >= totalSupply1 + _amount);
    totalSupply1 += _amount;
  }
}
