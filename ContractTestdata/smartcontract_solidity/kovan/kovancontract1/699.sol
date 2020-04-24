/**
 *Submitted for verification at Etherscan.io on 2019-01-14
*/

pragma solidity >0.4.99 <0.6.0;

/*
* http://ethedge.tech
* http://epictoken.dnsup.net/ (backup)
*
* Decentralized token exchange concept
* rebalancing eth contract value trade module with DAI (marketdao)
*
* ---How to use:
*  1. Send from ETH wallet to the smart contract address any amount ETH.
*  2.   1) Reinvest your profit by sending 0.00000001 ETH transaction to contract address
*       2) Claim your profit by sending 0.00000002 ETH transaction to contract address
*       3) Full exit (sell all and withdraw) by sending 0.00000003 ETH transaction to contract address
*  3. If you have innactive period more than 1 year - your account can be burned. Funds divided for token holders.
*  4. We use trade capital to invest to different crypto assets
*  5. Top big token holders can request audit.
*/


    interface ParentInterface {
        function payDividends(string calldata _sourceDesc) external payable;
//        function payDividends(string  _sourceDesc) public payable;
        function totalSupply() external view returns (uint256);
        function calculateEthereumReceived(uint256 _tokensToSell) external view returns (uint256);
    }

    interface OasisInterface {
        function getBestOffer(address sell_gem, address buy_gem) external view returns(uint256);
        function getOffer(uint256 id) external view returns(uint256,address,uint256,address);
        function sellAllAmount(address pay_gem, uint pay_amt, address buy_gem, uint min_fill_amount) external returns (uint fill_amt);
    }

    interface TokenInterface {
        function balanceOf(address) external view returns (uint);
        function allowance(address, address) external returns (uint);
        function approve(address, uint) external;
        function transfer(address,uint) external returns (bool);
        function transferFrom(address, address, uint) external returns (bool);
        function deposit() external payable;
        function withdraw(uint) external;
    }

contract rebalance {
    
    using SafeMath for uint256;

    event onCheckRebalance(
        uint256 bestBid,
        uint256 bestAsk,
        address indexed customerAddress,
        uint timestamp
);

    //Modifier that only allows owner of the bag to Smart Contract AKA Good to use the function
    modifier onlyOwner{
        require(msg.sender == owner_, "Only owner can do this!");
        _;
    }
    

    address public dai_=0xC4375B7De8af5a38a93548eb8453a498222C4fF2; //kovan
    //address public dai_=0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359; //mainnet
    address public oasis_=0xdB3b642eBc6Ff85A3AB335CFf9af2954F9215994; //kovan
    //address public oasis_=0xB7ac09C2c0217B07d7c103029B4918a2C401eeCB; //mainnet
    address public weth_=0xd0A1E359811322d97991E03f863a0C30C2cF029C; //kovan
    //address public weth_=0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; //mainnet
    
    //address public ethedge_=0xfc81655585F2F3935895C1409b332AB797D90B33; //this is contract!
    address public ethedge_=0xd6C6ff1e45648B9c4448dab15B9C04057D24D2a6; //kovan testnet!
    address payable public devsReward_=0x97c081214752944f19C8bAb1a3D4b9AdCe5B1cbE; // this is dev address for reward from profit
    address private owner_=msg.sender;
    uint256 public minLegsDisbalance_=20; // from 10% to 100% - safe values
    uint256 public pricePrecision_=1e5;
    uint256 public dividends_=75;
    uint256 public devReward_=10;
    uint256 public lastSellPrice_=0;
    uint256 public lastBuyPrice_=0;
    //stat section
    uint256 public sellETHvolume_=0;
    uint256 public buyETHvolume_=0;
    uint256 public sellDAIvolume_=0;
    uint256 public buyDAIvolume_=0;
    uint256 public totalProfit_=0;
    uint256 public totalDivs_=0;
    //end stat section

    OasisInterface oasisDex_=OasisInterface(oasis_);
    TokenInterface wethToken_=TokenInterface(weth_);
    TokenInterface daiToken_=TokenInterface(dai_);
    ParentInterface ethedgeToken_=ParentInterface(ethedge_);

    // This is the constructor whose code is
    // run only when the contract is created.
    constructor() public {
        (lastSellPrice_,lastBuyPrice_)=getPrice();
    }



    function() external payable {
        if (gasleft()>300000){
            checkRebalance();
        }
    }
    
    //This function transfer ownership of contract from one entity to another
    function transferOwnership(address _newOwner) public onlyOwner{
        require(_newOwner != address(0));
        owner_ = _newOwner;
    }
    
    //This function change addresses for devs reward
    function changeOuts(address payable _newDevs) public onlyOwner{
        //check if not empty
        require(_newDevs != address(0));
        devsReward_ = _newDevs;
    }

    //This function set minimun price change % to do rebalance. 10%<value<100%
    function changeMinLegsDisbalance(uint _minLegsDisbalance) public onlyOwner{
        require(_minLegsDisbalance>=10 && _minLegsDisbalance<=100);
        minLegsDisbalance_ = _minLegsDisbalance;
    }

    
    function getPrice() public view returns (uint256,uint256){
        uint bestBid=oasisDex_.getBestOffer(weth_,dai_);
        uint bestAsk=oasisDex_.getBestOffer(dai_,weth_);
        (uint amountWEth,,uint amountDai,)=oasisDex_.getOffer(bestBid);
        uint bestBuyPrice=amountDai.mul(pricePrecision_).div(amountWEth);
        (amountDai,,amountWEth,)=oasisDex_.getOffer(bestAsk);
        uint bestSellPrice=amountDai.mul(pricePrecision_).div(amountWEth);
        return (bestBuyPrice,bestSellPrice);
    }

    function totalBalances() public view returns(uint,uint,uint){
        (uint bestBuyPrice,uint bestSellPrice)=getPrice();
        uint avgPrice=bestBuyPrice.add(bestSellPrice).div(2);
        uint ethedgeSupply=ethedgeToken_.totalSupply();
        uint ethedgeBalance=ethedgeToken_.calculateEthereumReceived(ethedgeSupply);
        uint totalETHbalance=ethedgeBalance.add(address(this).balance);
        uint totalDAIbalance=daiToken_.balanceOf(address(this));
        uint totalDAIbalanceAtETH=totalDAIbalance.mul(pricePrecision_).div(avgPrice);
        return (totalETHbalance,totalDAIbalanceAtETH,totalDAIbalance);
    }

    //Check if rebalance needed and do swap
    function checkRebalance() public payable{
        (uint totalETHbalance,uint totalDAIbalanceAtETH,)=totalBalances();
        if (totalETHbalance>totalDAIbalanceAtETH.mul(100+minLegsDisbalance_).div(100)){
            //sell ETH for DAI. Rebalance event occurs
            uint amount=totalETHbalance.sub(totalDAIbalanceAtETH).div(2);
            if (address(this).balance>0){
                if (amount>address(this).balance){
                    amount=address(this).balance;
                }
                sellETHbuyDAI(amount);
            }
        }
        if (totalDAIbalanceAtETH>totalETHbalance.mul(100+minLegsDisbalance_).div(100)){
            //buy ETH with DAI. Rebalance event occurs
            uint amount=totalDAIbalanceAtETH.sub(totalETHbalance).div(2);
            (uint bestBuyPrice,uint bestSellPrice)=getPrice();
            uint avgPrice=bestBuyPrice.add(bestSellPrice).div(2);
            uint amountDAI=amount.mul(avgPrice).div(pricePrecision_);
            sellDAIbuyETH(amountDAI);
        }

        emit onCheckRebalance(lastBuyPrice_,lastSellPrice_,msg.sender,now);
    }
    
    //sell ETH for DAI
    function sellETHbuyDAI(uint _amount) private {
        wethToken_.deposit.value(_amount)();
        if (wethToken_.allowance(address(this), oasis_) < _amount) {
            wethToken_.approve(oasis_, uint(-1));
        }
        uint buyDAIamt = oasisDex_.sellAllAmount(weth_, _amount, dai_, 0);
        //require(daiToken.transfer(msg.sender,buyAmt));
        uint lastSellPrice=buyDAIamt.mul(pricePrecision_).div(_amount);
        if (lastSellPrice>lastSellPrice_){ //we have profits, calculate and send back
            uint profit=_amount.mul(lastSellPrice).div(lastSellPrice_);
            distributeProfit(profit);
        }
        lastSellPrice_=lastSellPrice;
        sellETHvolume_=sellETHvolume_.add(_amount);
        buyDAIvolume_=buyDAIvolume_.add(buyDAIamt);
        
    }

    //buy ETH with DAI
    function sellDAIbuyETH(uint _amountDAI) private {
        uint payAmt=_amountDAI;
        //require(payToken.transferFrom(msg.sender, this, payAmt));
        if (daiToken_.allowance(address(this), oasis_) < payAmt) {
            daiToken_.approve(oasis_, uint(-1));
        }
        uint wethAmt = oasisDex_.sellAllAmount(dai_, payAmt, weth_,0);
        wethToken_.withdraw(wethAmt);
//        require(msg.sender.call.value(wethAmt)());
        uint lastBuyPrice=payAmt.mul(pricePrecision_).div(wethAmt);
        if (lastBuyPrice<lastBuyPrice_){ //we have profits, calculate and send back
            uint profit=wethAmt.mul(lastBuyPrice_).div(lastBuyPrice);
            distributeProfit(profit);
        }
        lastBuyPrice_=lastBuyPrice;
        buyETHvolume_=buyETHvolume_.add(wethAmt);
        sellDAIvolume_=sellDAIvolume_.add(payAmt);
        
    }
        
    function distributeProfit(uint _profit) private {
        uint divs=_profit.mul(dividends_).div(100);
        uint devs=_profit.mul(devReward_).div(100);
        ethedgeToken_.payDividends.value(divs)('contract trade bot source');
        devsReward_.call.value(devs)("");
        totalProfit_=totalProfit_.add(_profit);
        totalDivs_=totalDivs_.add(divs);
    }
    

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
