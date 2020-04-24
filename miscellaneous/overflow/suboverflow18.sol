pragma solidity 0.4.22;
contract suboverflow18{
uint public presaleSoldTokens = 0;
uint public amount = 8000000*10**8;
uint public icoSoldTokens = 0;
uint public totalSoldTokens = 0;
uint public constant PRESALE_PRICE = 30000;
uint public constant ICO_PRICE1 = 40000;  
uint public constant TOTAL_LIMIT = 50000; 
mapping (address => uint256) public balances;
mapping (address => mapping (address => uint256)) public allowance;
function sellTokensPresale() public payable
    { 
		require(msg.value * PRESALE_PRICE /msg.value == PRESALE_PRICE);
        uint newTokens = msg.value * PRESALE_PRICE;
		require(presaleSoldTokens + newTokens >= newTokens);
        require(presaleSoldTokens + newTokens <= TOTAL_LIMIT);
		require( balances[msg.sender] >= newTokens);
        balances[msg.sender] =balances[msg.sender]- newTokens;
		require(amount  >= newTokens);
        amount= amount - newTokens;
    }
	function sellTokensPresale1() public payable
    { 
        uint newTokens = msg.value * PRESALE_PRICE;
		require(newTokens/msg.value == PRESALE_PRICE);
		require(presaleSoldTokens + newTokens >= newTokens);
        require(presaleSoldTokens + newTokens <= TOTAL_LIMIT);
        balances[msg.sender] =balances[msg.sender]- newTokens;
        amount= amount - newTokens;
    }

    function sellTokensICO(address _to) public payable onlyInState(State.ICORunning)
    {
        require(msg.value * getPrice()/msg.value == getPrice());
		uint newTokens1 = msg.value * getPrice();
		require(newTokens1 <= totalSoldTokens + newTokens1  );
        require(totalSoldTokens + newTokens1 <= TOTAL_LIMIT);
		require( balances[_to] >= newTokens1);
		balances[_to] =balances[_to]- newTokens1;
		require( allowance[msg.sender][_to] >= newTokens1);
		allowance[msg.sender][_to]=allowance[msg.sender][_to]-newTokens1;
    }
	 function sellTokensICO1(address _to) public payable onlyInState(State.ICORunning)
    {
        require(msg.value * getPrice()/msg.value == getPrice());
		uint newTokens1 = msg.value * getPrice();
		require(newTokens1/msg.value == getPrice());
        require(newTokens1 <= totalSoldTokens + newTokens1  );
        require(totalSoldTokens + newTokens1 <= TOTAL_LIMIT);
		balances[_to] =balances[_to]- newTokens1;
		allowance[msg.sender][_to]=allowance[msg.sender][_to]-newTokens1;
    }

    function getPrice()constant returns(uint)
    {
        if(currentState==State.ICORunning){
             if(icoSoldTokens<(200000000 * (1 ether / 1 wei))){
                  return ICO_PRICE1;
             }else
             return PRESALE_PRICE;
        }
    }
	}
	
contract suboverflow22 is suboverflow18{
function sellPresale() public payable
    { 
		require(msg.value * PRESALE_PRICE /msg.value == PRESALE_PRICE);
        uint newTokens = msg.value * PRESALE_PRICE;
		require(presaleSoldTokens + newTokens >= newTokens);
        require(presaleSoldTokens + newTokens <= TOTAL_LIMIT);
		require( balances[msg.sender] >= newTokens);
        balances[msg.sender] -= newTokens;
		require(amount  >= newTokens);
        amount -= newTokens;
        
    }
	function sellresale1() public payable
    { 
		
        uint newTokens = msg.value * PRESALE_PRICE;
		require(newTokens/msg.value == PRESALE_PRICE);
		require(presaleSoldTokens + newTokens >= newTokens);
        require(presaleSoldTokens + newTokens <= TOTAL_LIMIT);
        balances[msg.sender] -= newTokens;
         amount -= newTokens;
    }

    function sellICO(address _to) public payable onlyInState(State.ICORunning)
    {
        require(msg.value * getPrice()/msg.value == getPrice());
		uint newTokens1 = msg.value * getPrice();
		require(newTokens1 <= totalSoldTokens + newTokens1  );
        require(totalSoldTokens + newTokens1 <= TOTAL_LIMIT);
		require( balances[_to] >= newTokens1);
		balances[_to] -= newTokens1;
		require( allowance[msg.sender][_to] >= newTokens1);
		allowance[msg.sender][_to]-=newTokens1;
    }
	 function sellICO1(address _to) public payable onlyInState(State.ICORunning)
    {
        require(msg.value * getPrice()/msg.value == getPrice());
		uint newTokens1 = msg.value * getPrice();
		require(newTokens1/msg.value == getPrice());
        require(newTokens1 <= totalSoldTokens + newTokens1  );
        require(totalSoldTokens + newTokens1 <= TOTAL_LIMIT);
        totalSoldTokens+= newTokens1;
		balances[_to]-= newTokens1;
		allowance[msg.sender][_to]-=newTokens1;
    }
}	