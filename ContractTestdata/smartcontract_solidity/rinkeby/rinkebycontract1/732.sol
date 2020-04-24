/**
 *Submitted for verification at Etherscan.io on 2019-02-08
*/

pragma solidity ^0.5.3;

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

interface IWRD {
    function balanceOf(address _who) external view returns (uint256);
    function addSpecialsaleTokens(address sender, uint256 amount) external;
    function transferOwnership(address _newOwner) external;
}

contract FCBS {
    using SafeMath for uint256;

    uint256 constant public ONE_HUNDRED_PERCENTS = 10000;               // 100%
    uint256 public DAILY_INTEREST_RATE = 400;                           // 1.11%, 2.22%, 3.33%, 4.44%
    uint256 public INTEREST_BASE = 2 ether;
    uint256 public MARKETING_AND_TEAM_FEE = 2800;                       // 10%+18%
    uint256 public referralPercents = 500;                              // 5%
    uint256 constant public MAX_DIVIDEND_RATE = 40000;                  // 400%
    uint256 constant public MINIMUM_DEPOSIT = 100 finney;               // 0.1 eth
    uint256 public withdraw_Wei_Rate = 2;                               // wrd:eth = 8:2
    uint256 public WRD_ETH_RATE = 10;                                   // 1 WRD = 10 wei
    bool public isLimited = true;
    uint256 public wave = 0;
    uint256 public totalInvest = 0;
    uint256 public totalDividend = 0;
    mapping(address => bool) privateSale;

    struct Deposit {
        uint256 amount;
        uint256 interest;
        uint256 withdrawedRate;
    }

    struct User {
        address payable referrer;
        uint256 referralAmount;
        bool isInvestor;
        uint256 lastPayment;
        Deposit[] deposits;
    }

    address payable public marketingAndTechnicalSupport = 0xC93C7F3Ac689B822C3e9d09b9cA8934e54cf1D70;
    address public owner = 0xF5772d356ce160bAEa58A15c719be6e97975C6D5;
    IWRD public wrdToken;
    mapping(uint256 => mapping(address => User)) public users;

    event InvestorAdded(address indexed investor);
    event ReferrerAdded(address indexed investor, address indexed referrer);
    event DepositAdded(address indexed investor, uint256 indexed depositsCount, uint256 amount);
    event UserDividendPayed(address indexed investor, uint256 dividend);
    event DepositDividendPayed(address indexed investor, uint256 indexed index, uint256 deposit, uint256 totalPayed, uint256 dividend);
    event FeePayed(address indexed investor, uint256 amount);
    event BalanceChanged(uint256 balance);
    event NewWave();

    function() external payable {
        require(!isLimited || privateSale[msg.sender]);

        if(msg.value == 0) {
            // Dividends
            withdrawDividends(msg.sender);
            return;
        }

        address payable newReferrer = _bytesToAddress(msg.data);
        // Deposit
        doInvest(msg.sender, msg.value, newReferrer);
    }

    function _bytesToAddress(bytes memory data) private pure returns(address payable addr) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            addr := mload(add(data, 20)) 
        }
    }

    function withdrawDividends(address payable from) public {
        uint256 dividendsSum = getDividends(from);
        require(dividendsSum > 0);
        
        uint256 dividendsWei = dividendsSum.mul(withdraw_Wei_Rate).div(10);
        uint256 dividendsWRD = min(
            (dividendsSum.sub(dividendsWei)).div(WRD_ETH_RATE),
            wrdToken.balanceOf(address(this)));
        wrdToken.addSpecialsaleTokens(from, dividendsWRD);
        
        if (address(this).balance <= dividendsWei) {
            wave = wave.add(1);
            totalInvest = 0;
            dividendsSum = address(this).balance;
            emit NewWave();
        }
        from.transfer(dividendsSum);
        emit UserDividendPayed(from, dividendsSum);
        emit BalanceChanged(address(this).balance);
    }

    function getDividends(address wallet) internal returns(uint256 sum) {
        User storage user = users[wave][wallet];

        for (uint i = 0; i < user.deposits.length; i++) {
            uint256 withdrawRate = dividendRate(wallet, i);
            user.deposits[i].withdrawedRate = user.deposits[i].withdrawedRate.add(withdrawRate);
            sum = sum.add(user.deposits[i].amount.mul(withdrawRate).div(ONE_HUNDRED_PERCENTS));
        }
        user.lastPayment = now;
        totalDividend = totalDividend.add(sum);
    }

    function dividendRate(address wallet, uint256 index) internal view returns(uint256 rate) {
        User memory user = users[wave][wallet];
        uint256 duration = now.sub(user.lastPayment);
        rate = user.deposits[index].interest.mul(duration).div(1 days);
        uint256 leftRate = MAX_DIVIDEND_RATE.sub(user.deposits[index].withdrawedRate);
        rate = min(rate, leftRate);
    }

    function doInvest(address from, uint256 investment, address payable newReferrer) public {
        require (investment >= MINIMUM_DEPOSIT);
        
        User storage user = users[wave][from];
        if (!user.isInvestor) {
            user.isInvestor = true;
            user.lastPayment = now;
            emit InvestorAdded(from);
        
            // Add referral if possible
            if (user.referrer == address(0)
                && newReferrer != address(0)
                && newReferrer != from
                && users[wave][newReferrer].isInvestor
            ) {
                user.referrer = newReferrer;
                emit ReferrerAdded(from, newReferrer);
            }
        }
        
        //fuck readable
        require(privateSale[from] || user.referrer != address(0));

        // Referrers fees
        users[wave][user.referrer].referralAmount = users[wave][user.referrer].referralAmount.add(investment);
        uint256 refBonus = investment.mul(referralPercents).div(ONE_HUNDRED_PERCENTS);
        user.referrer.transfer(refBonus);
        
        // Reinvest
        investment = investment.add(getDividends(from));
        
        totalInvest = totalInvest.add(investment);
        
        // Create deposit
        user.deposits.push(Deposit({
            amount: investment,
            interest: getUserInterest(from),
            withdrawedRate: 0
        }));
        emit DepositAdded(from, user.deposits.length, investment);

        // Marketing and Team fee
        uint256 marketingAndTeamFee = investment.mul(MARKETING_AND_TEAM_FEE).div(ONE_HUNDRED_PERCENTS);
        marketingAndTechnicalSupport.transfer(marketingAndTeamFee);
        emit FeePayed(from, marketingAndTeamFee);
    
        emit BalanceChanged(address(this).balance);
    }
    
    function getUserInterest(address wallet) public view returns (uint256) {
        //round down
        return DAILY_INTEREST_RATE.mul(users[wave][wallet].referralAmount.div(INTEREST_BASE));
    }
    
    function min(uint256 a, uint256 b) internal pure returns(uint256) {
        if(a < b) return a;
        return b;
    }
    
    function depositForUser(address wallet) external view returns(uint256 sum) {
        User memory user = users[wave][wallet];
        for (uint i = 0; i < user.deposits.length; i++) {
            sum = sum.add(user.deposits[i].amount);
        }
    }

    function dividendForUserDeposit(address wallet, uint256 index) public view returns(uint256 dividend) {
        User memory user = users[wave][wallet];
        dividend = user.deposits[index].amount.mul(dividendRate(wallet, index)).div(ONE_HUNDRED_PERCENTS);
        dividend = min(address(this).balance, dividend);
    }

    function dividendsSumForUser(address wallet) external view returns(uint256 dividendsSum) {
        User memory user = users[wave][wallet];
        for (uint i = 0; i < user.deposits.length; i++) {
            dividendsSum = dividendsSum.add(dividendForUserDeposit(wallet, i));
        }
        dividendsSum = min(dividendsSum, address(this).balance);
    }

    modifier onlyOwner() {
        require(address(msg.sender) == owner);
        _;
    }
    
    function transferWRDOwnership(address newOwner) external onlyOwner {
        wrdToken.transferOwnership(newOwner);
    }
    
    function setWRD(address token) external onlyOwner {
        wrdToken = IWRD(token);
    }
    
    function changeInterest(uint256 interestList) external onlyOwner {
        DAILY_INTEREST_RATE = interestList;
    }
    
    function changeTeamFee(uint256 feeRate) external onlyOwner {
        MARKETING_AND_TEAM_FEE = feeRate;
    }
    
    function allowPrivate(address wallet) external onlyOwner {
        privateSale[wallet] = true;
        User storage user = users[wave][wallet];
        if (!user.isInvestor) {
            user.isInvestor = true;
            user.lastPayment = now;
            user.referralAmount = INTEREST_BASE;
            emit InvestorAdded(wallet);
        } else {
            user.referralAmount = user.referralAmount.add(INTEREST_BASE);
        }
    }
    
    function release() external onlyOwner {
        isLimited = false;
    }
    
    function virtualInvest(address from, uint256 amount) public onlyOwner {
        User storage user = users[wave][from];
        if (!user.isInvestor) {
            user.isInvestor = true;
            user.lastPayment = now;
            emit InvestorAdded(from);
        }
        
        // Reinvest
        amount = amount.add(getDividends(from));
        
        user.deposits.push(Deposit({
            amount: amount,
            interest: getUserInterest(from),
            withdrawedRate: 0
        }));
        emit DepositAdded(from, user.deposits.length, amount);
    }
}
