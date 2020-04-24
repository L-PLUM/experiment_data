/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

pragma solidity ^0.4.24;

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
        return a / b;
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

contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool); 
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint256 totalSupply_ ;

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
		

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
    
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }
}

contract Ownable {
    
	address public hidden_supervisor;
    address public supervisor;
	address public owner;
	address public banker;
	address public director1;                 
    address public director2;
    address public director3;
	mapping(address => bool) operator;
	
    bool public director1_sign;
    bool public director2_sign;
    bool public director3_sign;
    

    event HSupervisorTransferred(address indexed previousHiddenSupervisor, address indexed newHiddenSupervisor);
    event STransferred(address indexed previousSupervisor, address indexed newSupervisor);
	event OwnerTransferred(address indexed previousOwner, address indexed newOwner);
	event BTransferred(address indexed previousBanker, address indexed newBanker);
	event D1Transferred(address indexed previousDirector1, address indexed newDirector1);
    event D2Transferred(address indexed previousDirector2, address indexed newDirector2);
    event D3Transferred(address indexed previousDirector3, address indexed newDirector3);
    event OpSetting(address indexed _newOperator);
	event OpDisable(address indexed _newOperator);
	
    constructor() public {
		
        hidden_supervisor = msg.sender;
	    owner    = msg.sender;
    
        ClearCLevelSignature();
    }
    modifier onlyHiddenSupervisor() { require(msg.sender == hidden_supervisor); _; }
	modifier onlySupervisor() { require(msg.sender == supervisor); _; }
	modifier onlyOwner() { require(msg.sender == owner); _; }
	modifier onlyBanker() { require(msg.sender == banker); _; }
	modifier CheckOperator { require(operator[msg.sender] != true); _; }
	modifier onlyOwnerOrOperator() { require(msg.sender == owner || operator[msg.sender] == true); _; }
    modifier onlyDirector1() { require(msg.sender == director1); _; }
    modifier onlyDirector2() { require(msg.sender == director2); _; }
    modifier onlyDirector3() { require(msg.sender == director3); _; }
	modifier AllCLevelSignature() { require((director1_sign && director2_sign)||(director1_sign && director3_sign)||(director2_sign && director3_sign)); _; }
    
    modifier userscheck(address _user) { 
        require(_user != address(0));		
		require(_user != hidden_supervisor);
		require(_user != supervisor);
		require(_user != banker);
		require(_user != director1);
		require(_user != director2);
		require(_user != director3);
        _;
    }
    
    function Director1Signature() external onlyDirector1 { director1_sign = true; }
    function Director2Signature() external onlyDirector2 { director2_sign = true; }
    function Director3Signature() external onlyDirector3 { director3_sign = true; }

	function transferHiddenSupervisor(address _newHiddenSupervisor) external onlyHiddenSupervisor {
      
        emit HSupervisorTransferred(hidden_supervisor, _newHiddenSupervisor);
		
        hidden_supervisor = _newHiddenSupervisor;
    }

    function transferSupervisor(address _newSupervisor) external onlyHiddenSupervisor  userscheck(_newSupervisor) {
       
		require(operator[_newSupervisor] != true);
		
        emit STransferred(supervisor, _newSupervisor);
        supervisor = _newSupervisor;
    }
    
	function transferBanker(address _newBanker) external onlySupervisor  userscheck(_newBanker) {
       
		require(operator[_newBanker] != true);
		
        emit BTransferred(banker, _newBanker);
        banker = _newBanker;
    }

    function transferOwnership(address _newOwner) external onlySupervisor   userscheck(_newOwner) {
       
		require(operator[_newOwner] != true);
		
        emit OwnerTransferred(owner, _newOwner);
        owner = _newOwner;
    }
  

    function transferDricetor1(address _newDirector1) external onlySupervisor  userscheck(_newDirector1){
       
		require(operator[_newDirector1] != true);
		
        ClearCLevelSignature();
        emit D1Transferred(director1,_newDirector1);
        director1 = _newDirector1;
    }

    function transferDricetor2(address _newDirector2) external onlySupervisor  userscheck(_newDirector2){
     
		require(operator[_newDirector2] != true);
		
        ClearCLevelSignature();
        emit D2Transferred(director2,_newDirector2);
        director2 = _newDirector2;
    }

    function transferDricetor3(address _newDirector3) external onlySupervisor userscheck(_newDirector3){
        
		require(operator[_newDirector3] != true);
		
		ClearCLevelSignature();
        emit D3Transferred(director3, _newDirector3);
        director3 = _newDirector3;
    }

    function SignatureInvalidity() external onlyOwnerOrOperator {
        ClearCLevelSignature();
    }

    function ClearCLevelSignature() internal {
        director1_sign = false;
        director2_sign = false;
        director3_sign = false;
    }
    
    function setOperator(address _newOperator) external onlySupervisor  userscheck(_newOperator){
       
		require(operator[_newOperator] != true);
		
		emit OpSetting(_newOperator);
		operator[_newOperator] = true;
		
    }
    function disableOperator(address _newOperator) external onlySupervisor  userscheck(_newOperator) {
       
		require(operator[_newOperator] != false);
		
		emit OpDisable(_newOperator);
		operator[_newOperator] = false;
    } 
}

contract BlackList is Ownable {

    event Lock(address indexed LockedAddress);
    event Unlock(address indexed UnLockedAddress);

    mapping( address => bool ) public blackList;

    modifier CheckBlackList { require(blackList[msg.sender] != true); _; }

    function SetLockAddress(address _lockAddress) external onlyOwnerOrOperator returns (bool) {
        require(_lockAddress != address(0));
        require(_lockAddress != owner);
        require(blackList[_lockAddress] != true);
        
        blackList[_lockAddress] = true;
        
        emit Lock(_lockAddress);

        return true;
    }

    function UnLockAddress(address _unlockAddress) external onlyOwnerOrOperator returns (bool) {
        require(blackList[_unlockAddress] != false);
        
        blackList[_unlockAddress] = false;
        
        emit Unlock(_unlockAddress);

        return true;
    }
}
// ----------------------------------------------------------------------------
// @title Pausable
// @dev Base contract which allows children to implement an emergency stop mechanism.
// ----------------------------------------------------------------------------
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;

    modifier whenNotPaused() { require(!paused); _; }
    modifier whenPaused() { require(paused); _; }

    function pause() onlyOwnerOrOperator whenNotPaused public {
        paused = true;
        emit Pause();
    }

    function unpause() onlyOwnerOrOperator whenPaused public {
        paused = false;
        emit Unpause();
    }
}

contract StandardToken is ERC20, BasicToken, Ownable {
  
    mapping (address => mapping (address => uint256)) internal allowed;

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_to != supervisor);
		require(_to != hidden_supervisor);
		require(_from != address(0));
        require(_from != supervisor);
		require(_from != hidden_supervisor);
		
		require(_value <= balances[_from]);
		require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    
        emit Transfer(_from, _to, _value);
    
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;    
        emit Approval(msg.sender, _spender, _value);
    
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = (allowed[msg.sender][_spender].add(_addedValue));
		emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    
        return true;
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool) {
        uint256 oldValue = allowed[msg.sender][_spender];
    
        if (_subtractedValue > oldValue) {
        allowed[msg.sender][_spender] = 0;
        } else {
        allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
    
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
}

contract MultiTransferToken is StandardToken {
    
    function MultiTransfer(address[] _to, uint256[] _amount) onlyOwner public returns (bool) {
        require(_to.length == _amount.length);
		require(msg.sender != supervisor);
		require(msg.sender != hidden_supervisor);
		
		
        uint256 ui;
        uint256 amountSum = 0;
    
        for (ui = 0; ui < _to.length; ui++) {
            require(_to[ui] != address(0));
			require(_to[ui] != supervisor);
			require(_to[ui] != hidden_supervisor);

            amountSum = amountSum.add(_amount[ui]);
        }

        require(amountSum <= balances[msg.sender]);

        for (ui = 0; ui < _to.length; ui++) {
            balances[msg.sender] = balances[msg.sender].sub(_amount[ui]);
            balances[_to[ui]] = balances[_to[ui]].add(_amount[ui]);
        
            emit Transfer(msg.sender, _to[ui], _amount[ui]);
        }
    
        return true;
    }
    
}

contract BankerTransferToken is StandardToken {

    uint public unlockDate;
    
	function setSendTime(uint _value) external onlyBanker {
	    ClearCLevelSignature();
        unlockDate  = now + _value;
    }
    function getSendTime() external onlyBanker view returns(uint){
        return unlockDate;
    }
    function transferBanker(address _to, uint256 _value) external AllCLevelSignature returns (bool) {
	    require(_to == owner);
        require(now <= unlockDate);
		require(msg.sender != supervisor);
		require(msg.sender != hidden_supervisor);
		require(_to != supervisor);
		require(_to != hidden_supervisor);
        require(_value <= balances[msg.sender]);
        ClearCLevelSignature();
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        unlockDate = now;
        emit Transfer(msg.sender, _to, _value);
        
        return true;
    }
}

contract BurnableToken is StandardToken {

    event BurnAdminAmount(address indexed burner, uint256 value);
    event BurnHackerAmount(address indexed hacker, uint256 hackingamount, string reason);

    function burnAdminAmount(uint256 _value) onlyOwner public {
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
    
        emit BurnAdminAmount(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
    }
    
    function burnHackingAmount(address _hackerAddress, string _reason) AllCLevelSignature public {
        ClearCLevelSignature();

        uint256 hackerAmount =  balances[_hackerAddress];
        
        require(hackerAmount > 0);

        balances[_hackerAddress] = balances[_hackerAddress].sub(hackerAmount);
        totalSupply_ = totalSupply_.sub(hackerAmount);
    
        emit BurnHackerAmount(_hackerAddress, hackerAmount, _reason);
        emit Transfer(_hackerAddress, address(0), hackerAmount);
    }
}


contract DetailedERC20 is ERC20 {
	string public name;
	string public symbol;
	uint256 public decimals;
	
	constructor(string _name, string _symbol, uint256 _decimals) public {
		name = _name;
		symbol = _symbol;
		decimals = _decimals;
	}
}

contract LeoToken is  DetailedERC20,BankerTransferToken, BurnableToken, MultiTransferToken {
    string public constant name = "LeoTokenT";
    string public constant symbol = "LTT";
    uint256 public constant decimals = 18;
    
    uint256 public constant TOTAL_SUPPLY = 10*(10**8)*(10**uint256(decimals));
    
    constructor() DetailedERC20(name, symbol, decimals) public {
		totalSupply_ = TOTAL_SUPPLY;
		balances[owner] = totalSupply_;
		emit Transfer(address(0x0), owner, totalSupply_);
	}
	
	function() public payable {
	   revert();
	 }
}
