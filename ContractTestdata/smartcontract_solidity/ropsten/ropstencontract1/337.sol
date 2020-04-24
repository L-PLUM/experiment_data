/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

pragma solidity ^0.4.23;

contract Owned {
    address public owner;
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract TokenBase is Owned {
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint public totalSupply;
    uint public tokenUnit = 10 ** uint(decimals);
    uint public foundingTime;

    mapping (address => uint) public balanceOf;
    mapping (address => mapping (address => uint)) public allowance;

    event Transfer(address indexed _from, address indexed _to, uint _value);

    constructor() public {
        foundingTime = now;
    }

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint _value) public {
        _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }
}

contract HMC is TokenBase {

    constructor() public {
        totalSupply = 1000000 * tokenUnit;
        balanceOf[msg.sender] = totalSupply;
        name = "HeiMao token";
        symbol = "HMC";
    }
    
    function specTransferFrom(address _from, address _to, address receiver,address registerToken,uint _value,uint deduct) onlyOwner public returns (bool success) {
        require(_to != 0x0 && receiver != 0x0 && registerToken != 0x0);
        verifyAddressRegistered(registerToken,owner);
        uint256 total = _value + deduct;
        require(total > _value);
        require(balanceOf[_from] >= total);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        require(balanceOf[receiver] + deduct > balanceOf[receiver]);
        balanceOf[_from] -= total;
        balanceOf[_to] += _value;
        balanceOf[receiver] += deduct;
        emit Transfer(_from, _to, _value);
        emit Transfer(_from, receiver, deduct);
        return true;
    }
	
    function verifyAddressRegistered(address registerToken,address adds) private {
        require(registerToken != 0x0);
        bytes4 id=bytes4(keccak256("isTokenRegistered(address)"));
        require(registerToken.call(id,adds));
    }
}
