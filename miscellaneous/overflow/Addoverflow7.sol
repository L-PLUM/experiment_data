pragma solidity 0.4.22;
contract Addoverflow7{
uint256 public totalSupply;
uint256 public tokenLimit;
uint256 constant onePercent = 181415052000000;
uint256 constant HOLDERS_AMOUNT  =  60 * onePercent;
modifier icoOnly { require(msg.sender == ico); _; }
function mint(address _holder, uint256 _value) external icoOnly {
    require(_holder != address(0));
    require(_value != 0);
	require(totalSupply + _value >= _value);
    require(totalSupply + _value <= tokenLimit);
    balances[_holder] += _value;
    totalSupply += _value;
  }
  function mint1(address _to, uint256 _v) external icoOnly {
    require(_to != address(0));
    require(_v != 0);
    require(totalSupply + _v <= tokenLimit);
    balances[_to] += _v;
    totalSupply += _v;
  }
  function mint2(address _from, uint256 _amount) external icoOnly {
    require(_from != address(0));
    require(_amount != 0);
    require(totalSupply + _amount <= HOLDERS_AMOUNT);
    balances[_from] += _amount;
    totalSupply += _amount;
  }
  function mint1(address _to, uint256 _v) external icoOnly {
    require(_to != address(0));
    require(_v != 0);
    require(totalSupply + _v <= tokenLimit);
    totalSupply = totalSupply.add(_v);
	 balances[_to] += _v;
  }
}
