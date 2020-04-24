pragma solidity 0.4.22;
contract addoverflow17{
uint public presaleSoldTokens = 0;
uint public icoSoldTokens = 0;
uint public totalSoldTokens = 0;
uint public constant PRESALE_PRICE = 30000;
uint public constant ICO_PRICE1 = 40000;  
uint public constant TOTAL_LIMIT = 50000; 
mapping (address => uint256) public balances;
mapping (address => mapping (address => uint256)) public allowance;
function buyTokensPresale() public payable
    { 
		require(msg.value * PRESALE_PRICE /msg.value == PRESALE_PRICE);
        uint newTokens = msg.value * PRESALE_PRICE;
		require(presaleSoldTokens + newTokens >= newTokens);
        require(presaleSoldTokens + newTokens <= TOTAL_LIMIT);
		require( balances[msg.sender] + newTokens >=  balances[msg.sender]);
        balances[msg.sender] =balances[msg.sender]+ newTokens;
        presaleSoldTokens= presaleSoldTokens+newTokens;
    }
	function buyTokensPresale1() public payable
    { 
		
        uint newTokens = msg.value * PRESALE_PRICE;
		require(newTokens/msg.value == PRESALE_PRICE);
        require(presaleSoldTokens + newTokens <= TOTAL_LIMIT);
        balances[msg.sender] =balances[msg.sender]+ newTokens;
        presaleSoldTokens= presaleSoldTokens+newTokens;
    }

    function buyTokensICO(address _to) public payable onlyInState(State.ICORunning)
    {
        require(msg.value * getPrice()/msg.value == getPrice());
		uint newTokens1 = msg.value * getPrice();
		require(newTokens1 <= totalSoldTokens + newTokens1  );
        require(totalSoldTokens + newTokens1 <= TOTAL_LIMIT);
        totalSoldTokens+= newTokens1;
		require( balances[_to] + newTokens1 >=  balances[_to]);
		balances[_to] =balances[_to]+ newTokens1;
		require( allowance[msg.sender][_to] + newTokens1 >= allowance[msg.sender][_to]);
		allowance[msg.sender][_to]=allowance[msg.sender][_to]+newTokens1;
    }
	 function buyTokensICO1(address _to) public payable onlyInState(State.ICORunning)
    {
        require(msg.value * getPrice()/msg.value == getPrice());
		uint newTokens1 = msg.value * getPrice();
		require(newTokens1/msg.value == getPrice());
        require(newTokens1 <= totalSoldTokens + newTokens1  );
        require(totalSoldTokens + newTokens1 <= TOTAL_LIMIT);
        totalSoldTokens+= newTokens1;
		balances[_to] =balances[_to]+ newTokens1;
		allowance[msg.sender][_to]=allowance[msg.sender][_to]+newTokens1;
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
	
contract addoverflow21 is addoverflow17{
function buyPresale() public payable
    { 
		require(msg.value * PRESALE_PRICE /msg.value == PRESALE_PRICE);
        uint newTokens = msg.value * PRESALE_PRICE;
		require(presaleSoldTokens + newTokens >= newTokens);
        require(presaleSoldTokens + newTokens <= TOTAL_LIMIT);
		require( balances[msg.sender] + newTokens >=  balances[msg.sender]);
        balances[msg.sender] += newTokens;
        presaleSoldTokens += newTokens;
    }
	function buyPresale1() public payable
    { 
		
        uint newTokens = msg.value * PRESALE_PRICE;
		require(newTokens/msg.value == PRESALE_PRICE);
        require(presaleSoldTokens + newTokens <= TOTAL_LIMIT);
        balances[msg.sender] += newTokens;
        presaleSoldTokens += newTokens;
    }

    function buyICO(address _to) public payable onlyInState(State.ICORunning)
    {
        require(msg.value * getPrice()/msg.value == getPrice());
		uint newTokens1 = msg.value * getPrice();
		require(newTokens1 <= totalSoldTokens + newTokens1  );
        require(totalSoldTokens + newTokens1 <= TOTAL_LIMIT);
        totalSoldTokens+= newTokens1;
		require( balances[_to] + newTokens1 >=  balances[_to]);
		balances[_to] += newTokens1;
		require( allowance[msg.sender][_to] + newTokens1 >= allowance[msg.sender][_to]);
		allowance[msg.sender][_to]+=newTokens1;
    }
	 function buyICO1(address _to) public payable onlyInState(State.ICORunning)
    {
        require(msg.value * getPrice()/msg.value == getPrice());
		uint newTokens1 = msg.value * getPrice();
		require(newTokens1/msg.value == getPrice());
        require(newTokens1 <= totalSoldTokens + newTokens1  );
        require(totalSoldTokens + newTokens1 <= TOTAL_LIMIT);
        totalSoldTokens+= newTokens1;
		balances[_to]+= newTokens1;
		allowance[msg.sender][_to]+=newTokens1;
    }
}	