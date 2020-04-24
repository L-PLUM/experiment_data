pragma solidity 0.4.22;
contract Addoverflow9{
uint public presaleSoldTokens = 0;
uint public icoSoldTokens = 0;
uint public totalSoldTokens = 0;
uint public constant PRESALE_PRICE = 30000;
uint public constant ICO_PRICE1 = 40000;
uint public constant TOTAL_LIMIT = 50000;
function buyTokensPresale() public payable
    {
		require(msg.value * PRESALE_PRICE /msg.value == PRESALE_PRICE);
        uint newTokens = msg.value * PRESALE_PRICE;
		// <yes> <report> solidity_integer_addition_overflow add109
        require(presaleSoldTokens + newTokens <= TOTAL_LIMIT);
        balances[msg.sender] += newTokens;
        presaleSoldTokens+= newTokens;
    }
    function buyTokensICO() public payable onlyInState(State.ICORunning)
    {
		uint newTokens1 = msg.value * getPrice();
		require(newTokens1/msg.value == getPrice());
        require(newTokens1 <= totalSoldTokens + newTokens1  );
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

contract Addoverflow10 is Addoverflow9{
  function buyICO() public payable onlyInState(State.ICORunning)
    {
		uint newTokens2 = msg.value * getPrice();
		require(newTokens2/msg.value == getPrice());
       // <yes> <report> solidity_integer_addition_overflow add110
        require(TOTAL_LIMIT >=totalSoldTokens + newTokens2);
        totalSoldTokens+= newTokens2;
    }
}