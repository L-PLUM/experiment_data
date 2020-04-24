pragma solidity 0.4.22;
contract Muloverflow6{
uint public presaleSoldTokens = 0;
uint public icoSoldTokens = 0;
uint public totalSoldTokens = 0;
uint public constant PRESALE_PRICE = 30000;
uint public constant ICO_PRICE1 = 40000;  
uint public constant TOTAL_LIMIT = 50000; 
uint newTokens;
uint newTokens1;
function buyTokensPresale() public payable
    { 
		require(msg.value * PRESALE_PRICE /msg.value == PRESALE_PRICE);
        newTokens = msg.value * PRESALE_PRICE;
		require(newTokens/msg.value == PRESALE_PRICE);
		require(presaleSoldTokens + newTokens >= newTokens);
        require(presaleSoldTokens + newTokens <= TOTAL_LIMIT);
        balances[msg.sender] += newTokens;
        presaleSoldTokens+= newTokens;
    }

    function buyTokensICO() public payable onlyInState(State.ICORunning)
    {
        require(msg.value * getPrice()/msg.value == getPrice());
		newTokens1 = msg.value * getPrice();
		require(newTokens1/msg.value == getPrice());
        require(newTokens1 <= totalSoldTokens + newTokens  );
        require(totalSoldTokens + newTokens1 <= TOTAL_LIMIT);
        totalSoldTokens+= newTokens1;
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