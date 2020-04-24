/**
 *Submitted for verification at Etherscan.io on 2019-07-27
*/

pragma solidity ^0.5.0;
// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface, add a function approveAndCall
// ----------------------------------------------------------------------------
contract ERC20Interface {
    string public symbol;
    string public name;
    uint8 public decimals;

    function totalSupply() public view returns (uint);
    function balanceOf(address _owner) public view returns (uint balance);
    function allowance(address _owner, address _spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
	function approveAndCall(address _spender, uint _value, bytes memory _data) public returns (bool success);

    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

// ----------------------------------------------------------------------------
// USDT interface
// function dose not return bool
// https://etherscan.io/address/0xdac17f958d2ee523a2206206994597c13d831ec7
// ----------------------------------------------------------------------------
contract USDTIInterface {
    uint public _totalSupply;
    function totalSupply() public view returns (uint);
    function balanceOf(address who) public view returns (uint);
	
    function transfer(address to, uint value) public;
    event Transfer(address indexed from, address indexed to, uint value);
    function allowance(address owner, address spender) public view returns (uint);
    function transferFrom(address from, address to, uint value) public;
    function approve(address spender, uint value) public;
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract MicroShopCandyBox is Owned{
	using SafeMath for uint;
	
	ERC20Interface public microToken;									// token
	address public microAddress;
	USDTIInterface public usdt;											// usdt
	
    uint256 public candies;												// microToken
	uint256 public buyBackFunds;										// usdt
	uint256 public totalPledges;										// microToken
	uint256 public maxPledges;											// default 10000000000 * 10**18
	uint256 public minimuDays;											// default 0
	uint256 public maxDays;												// default 30
	uint256 public baseRate;											// default 70
	uint256 public candyRate;											// default 50
	uint256 public sellRate;											// default 985
	mapping(address => uint256) public pledges;
	mapping(address => uint256) public pledgeDate;
	
    constructor(address tokenAddress, address usdtAddress) public {
		owner = msg.sender;
		microAddress = tokenAddress;
		microToken = ERC20Interface(tokenAddress);
		usdt = USDTIInterface(usdtAddress);
		candies = 0;
		buyBackFunds = 0;
		totalPledges = 0;
		maxPledges = 10000000000 * 10**18;
		minimuDays = 0;
		maxDays = 30;
		baseRate = 70;
		sellRate = 985;
    }
	
    // ------------------------------------------------------------------------
    // events, value means token, amount means usdt
    // ------------------------------------------------------------------------
	event BuyLogs(address indexed customer, uint value);
	event SellLogs(address indexed customer, uint value, uint rate);
	event PledgeLogs(address indexed customer, uint value);
	event RedeemLogs(address indexed customer, uint value);	
	event GetCandies(address indexed customer, uint amount);
	event AddFunds(address indexed from, uint amount);
	event AddCandies(address indexed from, uint value);
	
    // ------------------------------------------------------------------------
    // general functions
    // ------------------------------------------------------------------------	
	function howMuchYouCanGet(uint value, uint pledeDays) public view returns (uint amount){
		if (pledeDays < minimuDays || totalPledges < 10**18 || value < 10**18) return 0;
		if (pledeDays > maxDays) {
			pledeDays = maxDays;
		}
		uint base = candies.div(maxDays).div(totalPledges.div(10**18)).div(100);			//if totalPledges<10**18, throw an error
		uint rate = baseRate + pledeDays;													//max_rate = 100%, min_rate=75%
		return base.mul(pledeDays).mul(value.div(10**18)).mul(rate);						//if value<10**18, amount will be 0
	}
	
    // ------------------------------------------------------------------------
    // customer functions
    // ------------------------------------------------------------------------
	function buyTokens(address customer, uint amount) public {
		uint tokens = microToken.balanceOf(address(this));
		uint available = tokens.sub(totalPledges).sub(candies);
		uint value = amount.mul(100 * 10 ** 12);
		require(available >= value);

		usdt.transferFrom(customer, address(this), amount);
		microToken.transfer(customer, value);
		emit BuyLogs(customer, value);
	}
	
	function sellTokens(address customer, uint value) public {
		uint amount = value.div(100 * 10 ** 12).mul(sellRate).div(1000);
		uint funds = usdt.balanceOf(address(this));
		require(buyBackFunds>=amount && funds>=buyBackFunds);
		
		microToken.transferFrom(customer, address(this), value);
		buyBackFunds = buyBackFunds.sub(amount);
		usdt.transfer(customer, amount);
		emit SellLogs(customer, value, sellRate);
	}
	
	function pledge(address customer, uint value) public {
		require(maxPledges >= totalPledges.add(value));
		
		uint pledeDays = now.sub(pledgeDate[customer]).div(1 days);
		uint amount = howMuchYouCanGet(pledges[customer], pledeDays);
		if (amount > 0) {
			pledgeDate[customer] = now;
			candies = candies.sub(amount);
			pledges[customer] = pledges[customer].add(amount);
			emit GetCandies(customer, amount);
		}
		
		microToken.transferFrom(customer, address(this), value);
		totalPledges = totalPledges.add(value);
		pledgeDate[customer] = now;
		pledges[customer] = pledges[customer].add(value);
		emit PledgeLogs(customer, value);
	}
	
	function redeem(uint value) public {
		claimCandies();
		
		uint total = microToken.balanceOf(address(this));
		require(total>=pledges[msg.sender] && pledges[msg.sender] >= value);
		
		pledges[msg.sender] = pledges[msg.sender].sub(value);
		totalPledges = totalPledges.sub(value);
		microToken.transfer(msg.sender, value);
		emit RedeemLogs(msg.sender, value);
	}

	function claimCandies() public {
		uint pledeDays = now.sub(pledgeDate[msg.sender]).div(1 days);
		uint amount = howMuchYouCanGet(pledges[msg.sender], pledeDays);
		if (amount > 0) {
			pledgeDate[msg.sender] = now;
			candies = candies.sub(amount);
			pledges[msg.sender] = pledges[msg.sender].add(amount);
			emit GetCandies(msg.sender, amount);
		}
	}
	
    // ------------------------------------------------------------------------
    // receiveApproval, data=0x01 for call pledge, data=0x02 for call sellTokens
    // ------------------------------------------------------------------------		
	function receiveApproval(address from, uint value, address token, bytes memory data) public {
		require(microAddress == token);
		uint8 action = uint8(data[0]);
		if (action == 1){
			pledge(from, value);
		}else if(action == 2){
			sellTokens(from, value);
		}else{
			// do nothing
		}
	}
	
    // ------------------------------------------------------------------------
    // admin functions
    // ------------------------------------------------------------------------	
	function setParam(uint _minimu_days, uint _max_days, uint _base_rate, uint _max_pledges, uint _sell_rate) public onlyOwner{
		minimuDays = _minimu_days;
		maxDays = _max_days;
		baseRate = _base_rate;
		maxPledges = _max_pledges;
		sellRate = _sell_rate;
	}
	
	function setTokenAddress(address newAddress, address usdtAddress) public onlyOwner{
		microAddress = newAddress;
		microToken = ERC20Interface(newAddress);
		usdt = USDTIInterface(usdtAddress);	
	}
	
	// one address corresponds to one business or project
	function addBuyBackFunds(address from, uint amount) public {
		usdt.transferFrom(from, address(this), amount);
		buyBackFunds = buyBackFunds.add(amount);
		emit AddFunds(from, amount);
	}
	
	// one address corresponds to one business or project
	function addCandies(address from, uint value) public{
		microToken.transferFrom(from, address(this), value);
		candies = candies.add(value);
		emit AddCandies(from, value);
	}
	
	function withdrawUSDT(address manager, uint amount) public onlyOwner{
		uint funds = usdt.balanceOf(address(this));
		uint reserved = buyBackFunds;
		require(funds >= reserved);
		usdt.transfer(manager, amount);
	}
	
	function withdrawTokens(address manager, uint amount) public onlyOwner{
		uint funds = microToken.balanceOf(address(this));
		uint reserved = totalPledges.add(candies);	
		require(funds >= reserved);
		microToken.transfer(manager, amount);
	}
	
    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () external payable {
        revert();
    }
	
    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}
