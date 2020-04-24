contract Addoverflow15{
uint256 public totalSupply;
modifier icoOnly { require(msg.sender == ico); _; }
function mint(uint256 _value) external icoOnly {
    require(_value != 0);
	require(totalSupply + _value >= _value);
    require(totalSupply + _value <= this.balance);
    totalSupply += _value;
  }
  function mint1(address _to, uint256 _v) external icoOnly {
    require(_to != address(0));
    require(_v != 0);
    // <yes> <report> solidity_integer_addition_overflow add115
    require(totalSupply + _v <= this.balance);
    // <yes> <report> solidity_integer_addition_overflow add112
    balances[_to] += _v;
    // <yes> <report> solidity_integer_addition_overflow add111
    totalSupply += _v;
  }
  function mint2(address _from, uint256 _amount) external icoOnly {
    require(_from != address(0));
    require(_amount != 0);
    // <yes> <report> solidity_integer_addition_overflow add116
    require(this.balance >= totalSupply + _amount);
     // <yes> <report> solidity_integer_addition_overflow add112
    balances[_from] += _amount;
    // <yes> <report> solidity_integer_addition_overflow add111
    totalSupply += _amount;
  }
  function mint3(uint256 _amount) external icoOnly {
    require(_amount != 0);
	require(totalSupply + _amount >= _amount);
    require(this.balance >= totalSupply + _amount);
    totalSupply += _amount;
  }
}