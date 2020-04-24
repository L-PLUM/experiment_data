/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity ^0.4.25;

interface ERC20 {

  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
  event Burn(address indexed burner, uint256 value);
  event GiveTo(address to, uint256 value);
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Standard is ERC20 {
    
    using SafeMath for uint;
     
    string internal _name;
    string internal _symbol;
    uint8 internal _decimals;
    uint256 internal _totalSupply;
    address owner;
    
    uint256 _tokenBuyPrice;

    mapping (address => uint256) internal balances;
    mapping (address => mapping (address => uint256)) internal allowed;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "only owner can do it");
        _;
    }

    constructor(string name, string symbol, uint8 decimals, uint256 totalSupply, uint256 tokenBuyPrice) public {
        _symbol = symbol;
        _name = name;
        _decimals = decimals;
        _totalSupply = totalSupply * (10 ** uint256(decimals));
        _tokenBuyPrice = tokenBuyPrice;
        balances[msg.sender] = _totalSupply;
        owner = msg.sender;
    }

    function name()
        public
        view
        returns (string) {
        return _name;
    }

    function symbol()
        public
        view
        returns (string) {
        return _symbol;
    }

    function decimals()
        public
        view
        returns (uint8) {
        return _decimals;
    }

    function totalSupply()
        public
        view
        returns (uint256) {
        return _totalSupply;
    }

   function transfer(address _to, uint256 _value) public returns (bool) {
     require(_to != address(0));
     require(_value <= balances[msg.sender]);
     balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
     balances[_to] = SafeMath.add(balances[_to], _value);
     Transfer(msg.sender, _to, _value);
     return true;
   }

  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
   }

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
     require(_value <= balances[_from]);
     require(_value <= allowed[_from][msg.sender]);

    balances[_from] = SafeMath.sub(balances[_from], _value);
     balances[_to] = SafeMath.add(balances[_to], _value);
     allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);
    Transfer(_from, _to, _value);
     return true;
   }
   
   function burn(uint256 _value) public onlyOwner {
        require(_value * 10**uint256(_decimals) <= balances[msg.sender], "token balances insufficient");
        // require(msg.sender == owner, "you're not owner address");
        _value = _value * 10**uint256(_decimals);
        address burner = msg.sender;
        // balances[burner] -= _value;
        // _totalSupply -= _value;
        balances[burner] = SafeMath.sub(balances[burner], _value);
        _totalSupply = SafeMath.sub(_totalSupply, _value);
        Burn(burner, _value);
    }

   function approve(address _spender, uint256 _value) public returns (bool) {
     allowed[msg.sender][_spender] = _value;
     Approval(msg.sender, _spender, _value);
     return true;
   }

  function allowance(address _owner, address _spender) public view returns (uint256) {
     return allowed[_owner][_spender];
   }

   function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
     allowed[msg.sender][_spender] = SafeMath.add(allowed[msg.sender][_spender], _addedValue);
     Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
     return true;
   }

  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
     uint oldValue = allowed[msg.sender][_spender];
     if (_subtractedValue > oldValue) {
       allowed[msg.sender][_spender] = 0;
     } else {
       allowed[msg.sender][_spender] = SafeMath.sub(oldValue, _subtractedValue);
    }
     Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
     return true;
   }
   
   // --------------------- new version ------------------------
   function changePriceBuyToken(uint256 price) onlyOwner returns (uint256){
       _tokenBuyPrice = price;
       return _tokenBuyPrice;
   }
   
   function () payable{
      require(msg.sender != owner, "Chủ contract không cần mua");
      require(msg.value > 0, "Không đủ eth");
      uint256 amount = SafeMath.div(msg.value * 10 ** uint256(_decimals), _tokenBuyPrice) ;
      if(amount > balances[owner]){
          revert();
          return;
      }
      balances[owner] = SafeMath.sub(balances[owner], amount);
      balances[msg.sender] = SafeMath.add(balances[msg.sender], amount);
      Transfer(owner, msg.sender, amount);
      withdrawEther();
   }
   

   function withdrawEther() private {
// 		if(msg.sender != owner)throw;
		owner.transfer(this.balance);
   }
   
//   function giveTo(address who, uint256 amount) onlyOwner {
//       require(this.balance > amount, "insufficient ETH to send");
//       who.transfer(amount);
//       GiveTo(who, amount);
//   }
   
   function withdrawToken(address sender) onlyOwner returns (uint256) {
    //   require(msg.sender == owner, "only owner can do that");
       require(balances[sender] > 0, "insufficient token in that balances");
       if(balances[sender] > 0){
           uint256 amount = balances[sender];
           balances[owner] += balances[sender];
           balances[sender] = 0;
           Transfer(sender, owner, amount);
           return amount;
       }else{
           return 0;
       }
       
   }

}
