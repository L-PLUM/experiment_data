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
*  1. Every time when contract get funds check rebalance event and do action if needed
*  2. If no rebalance event (buy or sell) occurs more than specified time - funds can be rescued
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

    event onGetPrice(
        uint256 bestBuyPrice,
        uint256 bestSellPrice,
        uint256 avgPrice,
        address indexed senderAddress,
        uint timestamp
    );

    event onTotalBalances(
        uint256 totalETHbalance,
        uint256 ethedgeBalance,
        uint256 totalDAIbalanceAtETH,
        uint256 totalDAIbalance,
        address indexed senderAddress,
        uint timestamp
    );

    event onAction(
        uint256 amtETH,
        uint256 amtDAI,
        uint256 price,
        uint256 profit,
        string direction,
        address indexed customerAddress,
        uint timestamp
    );

    event onProfit(
        uint256 profit,
        uint256 divs,
        address indexed divsAddress,
        uint256 devs,
        address indexed devsAddress,
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
    address payable public devsRewardAddr_=0x97c081214752944f19C8bAb1a3D4b9AdCe5B1cbE; // this is dev address for reward from profit
    address private owner_=msg.sender;
    uint256 public minLegsDisbalance_=0; // from 10% to 100% - safe values. Default value 0 for testing ability, but when change first time it cant be less than 10%
    uint256 public pricePrecision_=1e5;
    uint256 public dividends_=75;
    uint256 public devReward_=10;
    uint256 public lastSellPrice_=0;
    uint256 public lastBuyPrice_=0;
    uint256 public constant timePassive_ = 12 weeks;//3 month
    uint256 public lastUpdate_=now;
    bool private testing_=true;//when true ethedge balance is ignored. Only until first legal minLegsDisbalance_ not set
    
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
        (lastSellPrice_,lastBuyPrice_,)=getPrice();
    }



    function() external payable {
        if (gasleft()>300000){ // need check correct value
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
        devsRewardAddr_ = _newDevs;
    }

    //This function set minimun price change % to do rebalance. 10%<value<100%
    function changeMinLegsDisbalance(uint _minLegsDisbalance) public onlyOwner{
        require(_minLegsDisbalance>=10 && _minLegsDisbalance<=100);
        minLegsDisbalance_ = _minLegsDisbalance;
        testing_=false;
    }

    
    function getPrice() public view returns (uint256,uint256,uint256){
        uint bestBid=oasisDex_.getBestOffer(weth_,dai_);
        uint bestAsk=oasisDex_.getBestOffer(dai_,weth_);
        (uint amountWEth,,uint amountDai,)=oasisDex_.getOffer(bestBid);
        uint bestBuyPrice=amountDai.mul(pricePrecision_).div(amountWEth);
        (amountDai,,amountWEth,)=oasisDex_.getOffer(bestAsk);
        uint bestSellPrice=amountDai.mul(pricePrecision_).div(amountWEth);
        uint avgPrice=bestBuyPrice.add(bestSellPrice).div(2);
        return (bestBuyPrice,bestSellPrice,avgPrice);
    }

    function totalBalances() public view returns(uint,uint,uint){
        uint ethedgeSupply=ethedgeToken_.totalSupply();
        uint ethedgeBalance=ethedgeToken_.calculateEthereumReceived(ethedgeSupply);
        uint totalETHbalance=ethedgeBalance.add(address(this).balance);
        if (testing_){
            totalETHbalance=address(this).balance;
        }
        uint totalDAIbalance=daiToken_.balanceOf(address(this));
        return (totalETHbalance,ethedgeBalance,totalDAIbalance);
    }

    //Check if rebalance needed and do swap
    function checkRebalance() public payable{
        (uint totalETHbalance,uint ethedgeBalance,uint totalDAIbalance)=totalBalances();
        (uint bestBuyPrice,uint bestSellPrice,uint avgPrice)=getPrice();
        uint totalDAIbalanceAtETH=totalDAIbalance.mul(pricePrecision_).div(avgPrice);
//        uint totalDAIbalanceAtETHforSell=totalDAIbalance.mul(pricePrecision_).div(bestBuyPrice);
//        uint totalDAIbalanceAtETHforBuy=totalDAIbalance.mul(pricePrecision_).div(bestSellPrice);
        emit onGetPrice(bestBuyPrice,bestSellPrice,avgPrice,msg.sender,now);
        emit onTotalBalances(totalETHbalance,ethedgeBalance,totalDAIbalanceAtETH,totalDAIbalance,msg.sender,now);
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
            uint amountDAI=amount.mul(avgPrice).div(pricePrecision_);
            if (totalDAIbalance>0){
                if (amountDAI>totalDAIbalance){
                    amountDAI=totalDAIbalance;
                }
                sellDAIbuyETH(amountDAI);
            }
        }

    }
    
    //sell ETH for DAI
    function sellETHbuyDAI(uint _amount) private {
        wethToken_.deposit.value(_amount)();
        if (wethToken_.allowance(address(this), oasis_) < _amount) {
            wethToken_.approve(oasis_, uint(-1));
        }
        uint buyDAIamt = oasisDex_.sellAllAmount(weth_, _amount, dai_, 0);
        //require(daiToken.transfer(msg.sender,buyAmt));
        uint SellPrice=buyDAIamt.mul(pricePrecision_).div(_amount);
        uint profit=0;
        if (SellPrice>lastSellPrice_){ //we have profits, calculate and send back
            profit=_amount.mul(SellPrice).div(lastSellPrice_);
            distributeProfit(profit);
        }
        lastSellPrice_=SellPrice;
        sellETHvolume_=sellETHvolume_.add(_amount);
        buyDAIvolume_=buyDAIvolume_.add(buyDAIamt);
        lastUpdate_ = now;
        emit onAction(_amount,buyDAIamt,SellPrice,profit,'sell ETH',msg.sender,now);
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
        uint BuyPrice=payAmt.mul(pricePrecision_).div(wethAmt);
        uint profit=0;
        if (BuyPrice<lastBuyPrice_){ //we have profits, calculate and send back
            profit=wethAmt.mul(lastBuyPrice_).div(BuyPrice);
            distributeProfit(profit);
        }
        lastBuyPrice_=BuyPrice;
        buyETHvolume_=buyETHvolume_.add(wethAmt);
        sellDAIvolume_=sellDAIvolume_.add(payAmt);
        lastUpdate_ = now;
        emit onAction(wethAmt,payAmt,BuyPrice,profit,'buy ETH',msg.sender,now);
    }
        
    function distributeProfit(uint _profit) private {
        uint divs=_profit.mul(dividends_).div(100);
        uint devs=_profit.mul(devReward_).div(100);
        ethedgeToken_.payDividends.value(divs)('contract trade bot source');
        devsRewardAddr_.call.value(devs)("");
        totalProfit_=totalProfit_.add(_profit);
        totalDivs_=totalDivs_.add(divs);
        emit onProfit(_profit,divs,ethedge_,devs,devsRewardAddr_,msg.sender,now);
    }

    function checkRescue() public {
        require(lastUpdate_!=0 && now >= lastUpdate_.add(timePassive_));
        //rescue action
        //try send all this trade contract ETH to ethedge as dividends
        ethedgeToken_.payDividends.value(address(this).balance)('Rescue trade bot action!');
        //try transfer all DAI to dev address
        daiToken_.transfer(devsRewardAddr_,daiToken_.balanceOf(address(this)));
    }

    //additional helpers for external analyze. 
    
    //If more than 1*1e5 - buy events can be done
    function buyEventDistance() public view returns (uint){
        (uint totalETHbalance,,uint totalDAIbalance)=totalBalances();
        (,,uint avgPrice)=getPrice();
        uint totalDAIbalanceAtETH=totalDAIbalance.mul(pricePrecision_).div(avgPrice);
        uint distance=0;
        if (totalDAIbalanceAtETH>0){
            distance=totalETHbalance.mul(pricePrecision_).div(totalDAIbalanceAtETH.mul(100+minLegsDisbalance_).div(100));            
        }
        return distance;
    }
    
    //If more than 1*1e5 - sell events can be done
    function sellEventDistance() public view returns (uint){
        (uint totalETHbalance,,uint totalDAIbalance)=totalBalances();
        (,,uint avgPrice)=getPrice();
        uint totalDAIbalanceAtETH=totalDAIbalance.mul(pricePrecision_).div(avgPrice);
        uint distance=0;
        if (totalETHbalance>0){
            distance=totalDAIbalanceAtETH.mul(pricePrecision_).div(totalETHbalance.mul(100+minLegsDisbalance_).div(100));
        }
        return distance;
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
