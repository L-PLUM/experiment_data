/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

pragma solidity ^0.5.3;
contract FoodecentCoin{
    event Transfer(address indexed _from,address indexed _to,uint _amount);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    string public constant name="Foodecent";
    string public constant symbol="FD";
    uint public constant decimals=2;
    uint  public constant initialSuply=100;
    uint public  totalSupply= initialSuply*10**decimals;
    address ownerOfTotalSupply;
    constructor(address _ownerOfTotalSupply)public{
        ownerOfTotalSupply = _ownerOfTotalSupply;
        balanceOf[_ownerOfTotalSupply] = totalSupply;
    }
    mapping(address=>uint)balanceOf;
    mapping(address=>mapping(address=>uint))allowed;
    function balance(address _owner)public view returns(uint){
        return(balanceOf[_owner]);
    }
    function _transfer(address _from,address _to,uint _value)public {
        require(_to != address(0x0));
        require(balanceOf[_from]>= _value);
        require(balanceOf[_to]+_value >= balanceOf[_to]);
        require(_value>0 );
        uint previosBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from]-=_value;
        balanceOf[_to]+=_value;
        emit Transfer(_from,_to,_value);
        assert(balanceOf[_from] + balanceOf[_to] == previosBalances);
    }
    function transfer(address _to,uint _value)public returns(bool success){
        _transfer(msg.sender,_to,_value);
        return true;
    }
    function transferFrom(address _from,address _to,uint _value)public returns(bool success){
        require(_value<=allowed[_from][msg.sender]);
        _transfer(_from,_to,_value);
        return true;
    }
    function approve(address _spender,uint _value)public returns(bool success){
        allowed[msg.sender][_spender]=_value;
        emit Approval(msg.sender,_spender,_value);
        return true;
    }
    function transferInc(address _to,uint _value)public {
        require(_to != address(0x0));
        require(balanceOf[_to]+_value >= balanceOf[_to]);
        require(_value>0 );
        balanceOf[_to]+=_value;
    }
    function increaseSupply(uint _value, address _to) public returns (bool success) {
      totalSupply = safeAdd(totalSupply,_value);
      balanceOf[_to] = safeAdd(balanceOf[_to],_value);
      transferInc(_to, _value);
      return true;
    }
    function safeAdd(uint _x, uint _y)internal pure returns(uint) {
      require (_x + _y<_x);
      return _x + _y;
    }
    function transferDec(address _from,uint _value)public {
        require(_from != address(0x0));
        require(balanceOf[_from]>= _value);
        require(_value>0 );
        balanceOf[_from]-=_value;
    }
    function decreaseSupply(uint _value, address _from) public returns (bool) {
      balanceOf[_from] = safeSub(balanceOf[_from], _value);
      totalSupply = safeSub(totalSupply, _value);  
      transferDec(_from, _value);
      return true;
    }
    function safeSub(uint _x, uint _y) internal pure returns (uint) {
      require(_y > _x);
      return _x - _y;
    }
}
contract profit is FoodecentCoin{
    address depositOwner;
    constructor(address _depositOwner)public{
        depositOwner = _depositOwner;
    }
    function deposit(address _owner,uint _amount)public  {
        balanceOf[_owner]-=_amount;
        balanceOf[depositOwner]+=_amount;
    }
    function showBalance(address _acc)public view returns(uint){
        return(balanceOf[_acc]);
    }
}
