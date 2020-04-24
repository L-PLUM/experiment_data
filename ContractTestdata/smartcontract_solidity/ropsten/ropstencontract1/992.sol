/**
 *Submitted for verification at Etherscan.io on 2019-02-10
*/

pragma solidity >=0.4.22 <0.6.0;

interface tokenRecipient
{
	function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external;
}


interface IERC20 
{
	function totalSupply() external view returns (uint256);
	function balanceOf(address who) external view returns (uint256);
	function allowance(address owner, address spender) external view returns (uint256);
	function transfer(address to, uint256 value) external returns (bool);
	function approve(address spender, uint256 value) external returns (bool);
	function transferFrom(address from, address to, uint256 value) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC223Rtc 
{
	event Transfer(address indexed from, address indexed to, uint256 value,bytes _data);
	event tFallback(address indexed _contract,address indexed _from, uint256 _value,bytes _data);
	event tRetrive(address indexed _contract,address indexed _to, uint256 _value);
	
	
	mapping (address => bool) internal _tokenFull;	
	//	contract => user => balance
	mapping (address => mapping (address => uint256)) internal _tokenInContract;
	
	/// @notice entry to receve tokens
	function tokenFallback(address _from, uint _value, bytes memory _data) public
	{
        	_tokenFull[msg.sender]=true;
		_tokenInContract[msg.sender][_from]=_value;
		emit tFallback(msg.sender,_from, _value, _data);
	}

	function balanceOfToken(address _contract,address _owner) public view returns(uint256)
	{
		IERC20 cont=IERC20(_contract);
		uint256 tBal = cont.balanceOf(address(this));
		if(_tokenFull[_contract]==true)		//full info
		{
			uint256 uBal=_tokenInContract[_contract][_owner];	// user balans on contract
			require(tBal >= uBal);
			return(uBal);
		}
		
		return(tBal);
	}

	
	function tokeneRetrive(address _contract, address _to, uint _value) public
	{
		IERC20 cont=IERC20(_contract);
		
		uint256 tBal = cont.balanceOf(address(this));
		require(tBal >= _value);
		
		if(_tokenFull[_contract]==true)		//full info
		{
			uint256 uBal=_tokenInContract[_contract][msg.sender];	// user balans on contract
			require(uBal >= _value);
			_tokenInContract[_contract][msg.sender]-=_value;
		}
		
		cont.transfer(_to, _value);
		emit tRetrive(_contract, _to, _value);
	}
	
	//test contract is or not
	function isContract(address _addr) internal view returns (bool)
	{
        	uint length;
        	assembly
        	{
			//retrieve the size of the code on target address, this needs assembly
			length := extcodesize(_addr)
		}
		return (length>0);
	}
	
	function transfer(address _to, uint _value, bytes memory _data) public returns(bool) 
	{
		if(isContract(_to))
        	{
			ERC223Rtc receiver = ERC223Rtc(_to);
			receiver.tokenFallback(msg.sender, _value, _data);
		}
        	_transfer(msg.sender, _to, _value);
        	emit Transfer(msg.sender, _to, _value, _data);
		return true;        
	}
	
	function _transfer(address _from, address _to, uint _value) internal 
	{
		// virtual must be defined later
		bytes memory empty;
		emit Transfer(_from, _to, _value,empty);
	}
}

contract UnBasicIncome is IERC20,ERC223Rtc
{
	// Public variables of the token
	string	internal _name;
	string	internal _symbol;
	uint8	internal _decimals;
	uint256	internal _totalS;
	
	// Private variables of the token
	uint    internal _minTimeForPercent=86400;    //time in seconds
	uint    internal _timePercentDivider=86400;     //24 hour
	uint    internal _startTime;                //for calc all other
	uint    internal _timeLen1=2073600;         //24 days
	uint    internal _timeLen2=6220800;        //include _timeLen1 so 72 days

	uint256 internal _minValForPercent=1638400;
	address	payable internal _mainOwner=0x394b570584F2D37D441E669e74563CD164142930;


	struct account
	{
		uint256 balance;
		uint	timeLastAccess;
		bool	lock;
	}


	// This creates an array with all balances and it time Last Access
	mapping (address => account) internal _accounts;
	mapping (address => mapping (address => uint256)) internal _allowed;

	// This generates a public event on the blockchain that will notify clients
	event Transfer(address indexed from, address indexed to, uint256 value);
	event Approval(address indexed owner, address indexed spender, uint256 value);
	event LockAccount(address indexed acc);
	event UnLockAccount(address indexed acc);

	constructor() public 
	{
		_name="Unconditional Basic Income";	// Set the name for display purposes
		_symbol="UBI";			// Set the symbol for display purposes
		_decimals=2;                 //total = 128*1024*1024*1024
		_totalS=13743895347200;		// Update total supply with the decimal amount
		_accounts[_mainOwner].balance=_totalS;	// Give the creator all initial tokens
		_startTime=now;
		_accounts[_mainOwner].timeLastAccess=_startTime;
        	_timeLen1+=_startTime;         //calc one time !
        	_timeLen2+=_startTime;
		emit Transfer(address(0), _mainOwner, _totalS);
	}


	// entry to buy tokens
	function () external payable 
	{        
		buy();
	}

	/// @notice entry to buy tokens
	function buy() public payable returns(bool)
	{
		// reject contract buyer to avoid breaking interval limit
		require(!isContract(msg.sender));

        	uint timeNow=now;
        	uint tokensForEth;
        	uint bnsTokens=0;
        
        	if(timeNow>_timeLen2)        //after period2
        	{
			tokensForEth=3355443200;
        	}
        	else if(timeNow>_timeLen1)    //period2
        	{
			require(msg.value >= 0.001 ether);                        
            		tokensForEth=6710886400;            
			bnsTokens=409600;
		}
        	else                    //period1
        	{
			require(msg.value >= 0.0001 ether);
			tokensForEth=13421772800;
			bnsTokens=819200;            
		}

		//round to 1 token
		uint256 amount=(tokensForEth*msg.value)/100 ether;
		amount=amount*100;
		amount+=bnsTokens;
        
		_transfer(_mainOwner,msg.sender,amount);    //send tokens to buyer
        	_mainOwner.transfer(msg.value);         //send ether to _mainOwner
	}


	/**
	*  calc balans from time 
	*/
	function _calcNewBalans(address _addr) internal returns(bool)
	{
		//need min value for calc % 
        	uint256 bal=_accounts[_addr].balance;
        	if( bal< _minValForPercent)
        	{
			return false;
        	}
        	
		uint timeLa=_accounts[_addr].timeLastAccess;
		uint timeNow=now;
		if (timeLa==0)  //first access
		{
			timeLa=timeNow;
		}
        	
		uint tDiff=timeNow-timeLa;  
		uint perc=0;
		if(tDiff>_minTimeForPercent)
		{
			tDiff=tDiff-_minTimeForPercent;
			perc=tDiff/_timePercentDivider;
            		if(perc>0)
            		{
                		uint256 addVal=(bal*perc)/10000;  //calc add percent
                		addVal=addVal*100;              //round to 1 token
                		uint256 newBal=bal+addVal;
        			require(newBal > bal);          // Check for overflows
                		_accounts[_addr].balance=newBal;        		
                		newBal=_totalS+addVal;
        			require(newBal > _totalS);       // Check for overflows                
        			_totalS=newBal;
			}
		}
        	_accounts[_addr].timeLastAccess=timeNow;     //update timeLastAccess always 
        	return true;
	}
	
	/**
	* Internal transfer, only can be called by this contract
	*/
	function _transfer(address _from, address _to, uint _value) internal 
	{
		// Prevent transfer to 0x0 address. Use burn() instead
		require(_to != address(0x0));
		require(_accounts[_to].lock==false);	//send only to unlocked
		
		
		//calc % from time for _from and _to
		_calcNewBalans(_from);
		_calcNewBalans(_to);
		
		
		// Check if the sender has enough
		require(_accounts[_from].balance >= _value);
		// Check for overflows
		require(_accounts[_to].balance + _value > _accounts[_to].balance);
		// Save this for an assertion in the future
		uint256 previousBalances = _accounts[_from].balance + _accounts[_to].balance;
		// Subtract from the sender
		_accounts[_from].balance -= _value;
		// Add the same to the recipient
		_accounts[_to].balance += _value;
		// Asserts are used to use static analysis to find bugs in your code. They should never fail
		require(_accounts[_from].balance + _accounts[_to].balance == previousBalances);
		
		//get commission fee
		uint256 cfee=_value>>15;    //cfee=100/(128*256)
		if(cfee>0)                  //round fee to 1 token
		{
			cfee=cfee*100;
			require(_accounts[_from].balance >= cfee);
			_accounts[_from].balance -= cfee;
            		uint newBal=_totalS-cfee;
        		require(newBal < _totalS);       // Check for overflows                
        		_totalS=newBal;
		}
		
		_accounts[_to].timeLastAccess=now;     //update timeLastAccess 

		emit Transfer(_from, _to, _value);
	}

	//account can recive token only if lock=false
	//use for protect from balans update 
	function lockAccount() public
	{
		_accounts[msg.sender].lock=true;
		emit LockAccount(msg.sender);		
	}
	
	function unLockAccount() public
	{
		_accounts[msg.sender].lock=false;
		emit UnLockAccount(msg.sender);		
	}
	
	// get lock status 
	function isLockedAccount(address acc) public view returns (bool)
	{
		return _accounts[acc].lock;
	}
	
	
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool) 
	{
		require(_allowed[_from][msg.sender] >= _value);
        
		_allowed[_from][msg.sender] -= _value;
		_transfer(_from, _to, _value);
		emit Approval(_from, msg.sender, _allowed[_from][msg.sender]);
		return true;
	}
	
	
	function transfer(address _to, uint256 _value) public returns(bool) 
	{
		bytes memory empty;
		if(isContract(_to))
		{
			ERC223Rtc receiver = ERC223Rtc(_to);
			receiver.tokenFallback(msg.sender, _value, empty);
		}
		
		_transfer(msg.sender, _to, _value);
		return true;
	}
	
	
	function approveAndCall(address _spender, uint256 _value, bytes memory _extraData) public returns (bool)
	{
		tokenRecipient spender = tokenRecipient(_spender);
		if (approve(_spender, _value))
		{
			spender.receiveApproval(msg.sender, _value, address(this), _extraData);
			return true;
		}
	}


	function approve(address _spender, uint256 _value) public returns(bool)
	{
		require(_spender != address(0));
		_allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}

	//check the amount of tokens that an owner allowed to a spender
	function allowance(address owner, address spender) public view returns (uint256)
	{
		return _allowed[owner][spender];
	}

	//balance of the specified address
	function balanceOf(address _owner) public view returns(uint256)
	{
		return _accounts[_owner].balance;
	}

    	// Function to access total supply of tokens .
	function totalSupply() public view returns(uint256) 
	{
		return _totalS;
	}


	// the name of the token.
	function name() public view returns (string memory)
	{
		return _name;
	}

	//the symbol of the token
	function symbol() public view returns (string memory) 
	{
		return _symbol;
	}

	//number of decimals of the token
	function decimals() public view returns (uint8) 
	{
		return _decimals;
	}
}
