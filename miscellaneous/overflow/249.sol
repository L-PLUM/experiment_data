pragma solidity ^0.5.7;

contract LINIX_Seedblock
{
    string public name;
    string public symbol;
    uint public decimals;
    
    uint constant private zeroAfterDecimal = 10**18;
    
    uint constant public maxSupply             = 2625000 * zeroAfterDecimal;
    
    uint constant public maxSupply_SeedBlock        =   2625000 * zeroAfterDecimal;

    
    uint public issueToken_Total;
    
    uint public issueToken_SeedBlock;
    
    
    mapping (address => uint) public balances;
    mapping (address => mapping ( address => uint )) public allowed;

    event Burn(address indexed _from, uint _value);
    
    event Issue_SeedBlock(address indexed _to, uint _tokens);
    
    event TokenUnLock(address indexed _to, uint _tokens);

    
    constructor() public
    {
        name        = "LNXSB";
        decimals    = 18;
        symbol      = "LNSB";
        
        issueToken_Total      = 0;
        
        issueToken_SeedBlock     = 0;

        
        require(maxSupply == maxSupply_SeedBlock);

    }
    
    // Issue Function -----

    function issue_noVesting(address _to, uint _value)  public
    {
        require( _value * zeroAfterDecimal/ _value == zeroAfterDecimal);
		uint tokens = _value * zeroAfterDecimal;
		require(issueToken_SeedBlock + tokens >= tokens);
        require(maxSupply_SeedBlock >= issueToken_SeedBlock + tokens);
        require(balances[_to]+ tokens >= tokens);
        balances[_to] = balances[_to]+ tokens;
        require(issueToken_Total+ tokens >= tokens);
        issueToken_Total = issueToken_Total+ tokens;
        issueToken_SeedBlock = issueToken_SeedBlock+ tokens;
        
        emit Issue_SeedBlock(_to, tokens);
    }
	function issue_noVesting1(address _to, uint _value)  public
    {
        require( _value * zeroAfterDecimal/ _value == zeroAfterDecimal);
		uint tokens = _value * zeroAfterDecimal;
		require(issueToken_SeedBlock + tokens >= tokens);
        require(issueToken_SeedBlock + tokens <= maxSupply_SeedBlock );
        require( balances[_to] + tokens >=  balances[_to]);
        balances[_to] += tokens;
        issueToken_Total += tokens;
        issueToken_SeedBlock += tokens;
        
        emit Issue_SeedBlock(_to, tokens);
    }
     function issue(address _to, uint _value)  public
    {
        require( _value * zeroAfterDecimal/ _value == zeroAfterDecimal);
		uint tokens = _value * zeroAfterDecimal;
		require(issueToken_SeedBlock + tokens >= tokens);
		require(this.balance >= issueToken_SeedBlock + tokens);
		
        balances[msg.sender] = balances[msg.sender] + tokens;
        require(allowed[_to][msg.sender] + tokens >= allowed[_to][msg.sender]);
        allowed[_to][msg.sender] =  allowed[_to][msg.sender]  + tokens;
        issueToken_SeedBlock = issueToken_SeedBlock + tokens;
        
        emit Issue_SeedBlock(_to, tokens);
    }        
    function issue1(address _to, uint _value)  public
    {
        require( _value * zeroAfterDecimal/ _value == zeroAfterDecimal);
		uint tokens = _value * zeroAfterDecimal;
		require(issueToken_SeedBlock + tokens >= tokens);
		require(issueToken_SeedBlock + tokens <= this.balance);
		require(balances[msg.sender] + tokens >= tokens);
        balances[msg.sender] += tokens;
        
        allowed[_to][msg.sender] += tokens;
		
        issueToken_SeedBlock += tokens;
        
        emit Issue_SeedBlock(_to, tokens);
    }      
	
    function burnToken(uint _value)  public
    {
        require( _value * zeroAfterDecimal/ _value == zeroAfterDecimal);
		uint tokens = _value * zeroAfterDecimal;
        
        require(balances[msg.sender] >= tokens);
        balances[msg.sender] = balances[msg.sender] - tokens;
        
        
        issueToken_Total = issueToken_Total- tokens;
        
        emit Burn(msg.sender, tokens);
    }
    function burnToken1(uint _value)  public
    {
	    require( _value * zeroAfterDecimal/ _value == zeroAfterDecimal);
        uint tokens = _value * zeroAfterDecimal;
        
        require(balances[msg.sender] >= tokens);
        
        balances[msg.sender] -= tokens;
        issueToken_Total -= tokens;
        
        emit Burn(msg.sender, tokens);
    }
	  function burnToken2(address _to,uint _value)  public
    {
        require( _value * zeroAfterDecimal/ _value == zeroAfterDecimal);
		uint tokens = _value * zeroAfterDecimal;
        
        require(balances[_to] >= tokens);
        
        balances[_to] = balances[_to] - tokens;
        require(allowed[_to][msg.sender] >= tokens);
		allowed[_to][msg.sender] = allowed[_to][msg.sender] - tokens;
       
        issueToken_Total = issueToken_Total- tokens;
        
        emit Burn(msg.sender, tokens);
    }
	  function burnToken3(address _to,uint _value)  public
    {
        require( _value * zeroAfterDecimal/ _value == zeroAfterDecimal);
		uint tokens = _value * zeroAfterDecimal;
        
        require(balances[_to] >= tokens);
        
        balances[_to] -= tokens;
        
		allowed[_to][msg.sender] -=tokens;
       require(issueToken_Total >= tokens;
        issueToken_Total -=  tokens;
        
        emit Burn(msg.sender, tokens);
    }
  
}
