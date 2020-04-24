/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.4.0;

//la idea de este token es participar de consorcios de bienes raices
//implementa funciones MINT y REDEMPT
//en un futuro contrato, los acres dan derecho a los dividendos del consorcio

    contract Token {
    address internal _amo; 
    string public _symbol;
    string public _name;
    uint8 public _decimals;
    uint public _totalSupply;
    mapping (address => uint) public _balanceOf;
    mapping (address => mapping (address => uint)) public _allowances;
    mapping (address => bool) public _apoderaDos;
    mapping (address => uint) public _AserQuemados;
    
    function Token(string symbol, string name, uint8 decimals, uint totalSupply) public {
        _symbol = symbol;
        _name = name;
        _decimals = decimals;
        _totalSupply = totalSupply;
        _amo = msg.sender; 
    }

    modifier Autorizado {
        require (_amo == msg.sender || _apoderaDos[msg.sender]);
        _;
    }

    function ApoDerar(address _addr) public returns (bool) {
        require (_amo == msg.sender);
        _apoderaDos[_addr] = true;
        return true;
        
    }
    
    function ReVocar(address _addr) public returns (bool) {
        require (_amo == msg.sender && _apoderaDos[_addr]);
        _apoderaDos[_addr] = false;
        return true;

    }

    function transfer(address _to, uint _value) public returns (bool);
    function Mint(address _to, uint _value, bytes _data) Autorizado public returns(bool);
    function Redempt(address _owner, bool _seaAsi, bytes _data) Autorizado public returns(bool);
    function SolicitoQuemar(uint _value, bytes _data) public returns (bool);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Quema(address indexed _owner, bytes indexed _data, bool _seaAsi);
    event Emision(address indexed _to, bytes indexed _data, uint _value);
}


interface ERC20 {
    function transferFrom(address _from, address _to, uint _value) public returns (bool);
    function approve(address _spender, uint _value) public returns (bool);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

interface ERC223 {
    function transfer(address _to, uint _value, bytes _data) public returns (bool);
    event Transfer(address indexed _from, address indexed _to, uint _value, bytes indexed _data);
}

contract ERC223ReceivingContract {
    function tokenFallback(address _from, uint _value, bytes _data) public;
}

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b > 0);
    uint256 c = a / b;
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

contract ACRES is Token("ACR", "Participaciones Fiduciarias", 18, 1), ERC20, ERC223 {

    using SafeMath for uint;
    
    constructor () public {
        _balanceOf[msg.sender] = _totalSupply;
    }
    
    function transfer(address _to, uint _value) public returns (bool) {
        if (_value > 0 &&
            _value <= _balanceOf[msg.sender] &&
            !isContract(_to)) {
            _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(_value);
            _balanceOf[_to] = _balanceOf[_to].add(_value);
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    function transfer(address _to, uint _value, bytes _data) public returns (bool) {
        if (_value > 0 &&
            _value <= _balanceOf[msg.sender] &&
            isContract(_to)) {
            _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(_value);
            _balanceOf[_to] = _balanceOf[_to].add(_value);
            ERC223ReceivingContract _contract = ERC223ReceivingContract(_to);
            _contract.tokenFallback(msg.sender, _value, _data);
            Transfer(msg.sender, _to, _value, _data);
            return true;
        }
        return false;
    }

    function isContract(address _addr) private constant returns (bool) {
        uint codeSize;
        assembly {
            codeSize := extcodesize(_addr)
        }
        return codeSize > 0;
    }
    
    function Mint(address _to, uint _value, bytes _data) Autorizado public returns(bool){
        if (_value > 0 &&
            !isContract(_to)) {
            _totalSupply = _totalSupply.add(_value);
            _balanceOf[_to] = _balanceOf[_to].add(_value);
            Emision(_to, _data, _value);
            return true;
        } else if (_value > 0 &&
            isContract(_to)) {
            _totalSupply = _totalSupply.add(_value);
            _balanceOf[_to] = _balanceOf[_to].add(_value);
            ERC223ReceivingContract _contract = ERC223ReceivingContract(_to);
            _contract.tokenFallback(msg.sender, _value, _data);
            Emision(_to, _data, _value);
            return true;
        }
        return false; 
    }

    function Redempt(address _owner, bool _seaAsi, bytes _data) Autorizado public returns(bool) {
        assert (_AserQuemados[_owner] > 0);
        if (_seaAsi) {
            _totalSupply = _totalSupply.sub(_AserQuemados[_owner]);
            _AserQuemados[_owner] = 0;
            Quema(_owner, _data, _seaAsi);
            return true;
        } else {
            _balanceOf[_owner] = _balanceOf[_owner].add(_AserQuemados[_owner]);
            _AserQuemados[_owner] = 0;
            Quema(_owner, _data, _seaAsi);
            return false;
            }

    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool) {
        if (_allowances[_from][msg.sender] > 0 &&
            _value > 0 &&
            _allowances[_from][msg.sender] >= _value &&
            _balanceOf[_from] >= _value) {
            _balanceOf[_from] = _balanceOf[_from].sub(_value);
            _balanceOf[_to] = _balanceOf[_to].add(_value);
            _allowances[_from][msg.sender] = _allowances[_from][msg.sender].sub(_value);
            Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    function SolicitoQuemar(uint _value, bytes _data) public returns (bool) {
        require(_value > 0 &&
                _balanceOf[msg.sender] >= _value);
        _AserQuemados[msg.sender] = _AserQuemados[msg.sender].add(_value);
        _balanceOf[msg.sender] = _balanceOf[msg.sender].sub(_value);
        return true;
    }

    function approve(address _spender, uint _value) public returns (bool) {
        require(_value > 0 &&
                _balanceOf[msg.sender] >= _value);
        _allowances[msg.sender][_spender] = _allowances[msg.sender][_spender].add(_value);
        Approval(msg.sender, _spender, _value);
        return true;
    }
}
