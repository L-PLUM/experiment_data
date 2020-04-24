/**
 *Submitted for verification at Etherscan.io on 2019-01-11
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


    interface DevsInterface {
        function payDividends(string calldata _sourceDesc) external payable;
//        function payDividends(string  _sourceDesc) public payable;
    }

    interface OasisInterface {
        function getBestOffer(address sell_gem, address buy_gem) external view returns(uint256);
        function getOffer(uint256 id) external view returns(uint256,address,uint256,address);
        function sellAllAmount(address pay_gem, uint pay_amt, address buy_gem, uint min_fill_amount) external returns (uint fill_amt);
    }

    interface TokenInterface {
        function balanceOf(address) external returns (uint);
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
    //address public pricefeed_=0x9FfFE440258B79c5d6604001674A4722FfC0f7Bc; //kovan NOT NEEDED!
    //address public pricefeed_=0x729D19f657BD0614b4985Cf1D82531c67569197B; //mainnet NOT NEEDED!
    address public oasis_=0xdB3b642eBc6Ff85A3AB335CFf9af2954F9215994; //kovan
    //address public oasis_=0xB7ac09C2c0217B07d7c103029B4918a2C401eeCB; //mainnet
    address public weth_=0xd0A1E359811322d97991E03f863a0C30C2cF029C; //kovan
    //address public weth_=0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; //mainnet
    
    address public devsReward_=0xfc81655585F2F3935895C1409b332AB797D90B33; //this is contract!
    address private owner_=msg.sender;
    uint256 public lastSellPrice_=0;
    uint256 public lastBuyPrice_=0;
    uint256 public lastETHamount_=0;
    uint256 public lastDAIamount_=0;

    
    //This function transfer ownership of contract from one entity to another
    function transferOwnership(address _newOwner) public onlyOwner{
        require(_newOwner != address(0));
        owner_ = _newOwner;
    }
    
    //Check if rebalance needed and do swap
    function checkRebalance() public payable{
        OasisInterface oasis=OasisInterface(oasis_);
        uint bestBid=oasis.getBestOffer(weth_,dai_);
        uint bestAsk=oasis.getBestOffer(dai_,weth_);
        (uint amountWEth,,uint amountDai,)=oasis.getOffer(bestBid);
        lastBuyPrice_=amountDai.mul(1e18).div(amountWEth);
        (amountDai,,amountWEth,)=oasis.getOffer(bestAsk);
        lastSellPrice_=amountDai.mul(1e18).div(amountWEth);
        
        TokenInterface wethToken=TokenInterface(weth_);
        TokenInterface daiToken=TokenInterface(dai_);

//buy DAI for ETH        
        wethToken.deposit.value(msg.value)();
        if (wethToken.allowance(address(this), oasis_) < msg.value) {
            wethToken.approve(oasis_, uint(-1));
        }
        uint buyAmt = oasis.sellAllAmount(weth_, msg.value, dai_, 1e15);
        //require(daiToken.transfer(msg.sender,buyAmt));
        
        lastETHamount_=address(this).balance;
        lastDAIamount_=daiToken.balanceOf(address(this));
        
        emit onCheckRebalance(lastBuyPrice_,lastSellPrice_,msg.sender,now);
    }
    
        //try sell
    function sell() public {
        OasisInterface oasis=OasisInterface(oasis_);
        TokenInterface wethToken=TokenInterface(weth_);
        TokenInterface daiToken=TokenInterface(dai_);

        //uint payAmt=1e16;
        uint payAmt=lastDAIamount_;
        //sell DAI for ETH
        //require(payToken.transferFrom(msg.sender, this, payAmt));
        if (daiToken.allowance(address(this), oasis_) < payAmt) {
            daiToken.approve(oasis_, uint(-1));
        }
        uint wethAmt = oasis.sellAllAmount(dai_, payAmt, weth_, 1e12);
        wethAmt=lastDAIamount_=daiToken.balanceOf(address(this));
        wethToken.withdraw(wethAmt);
//        require(msg.sender.call.value(wethAmt)());

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
