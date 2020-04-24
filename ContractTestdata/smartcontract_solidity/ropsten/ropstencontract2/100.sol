/**
 *Submitted for verification at Etherscan.io on 2019-08-12
*/

pragma solidity ^0.4.13;

interface ERC20 {
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}

contract EscrowFund {
    using SafeMath for uint256;

    // BCNT token contract
    ERC20 public BCNTToken;
    ERC20 public StableToken;

    // Roles
    address public bincentiveHot; // i.e., Platform Owner
    address public bincentiveCold;
    address[] public investors; // implicitly first investor is the lead investor
    address public accountManager;
    address public fundManager; // i.e., Exchange Deposit and Withdraw Manager

    // Contract(Fund) Status
    // 0: not initialized
    // 1: initialized
    // 2: not enough fund came in in time
    // 3: fundStarted
    // 4: running
    // 5: stoppped
    // 6: closed
    // 32: terminated
    uint256 public fundStatus;

    // Money
    uint256 public currentInvestedAmount;
    mapping(address => uint256) public investedAmount;
    uint256 public BCNTLockAmount;
    uint256 public returnedStableTokenAmounts;
    uint256 public returnedBCNTAmounts;

    // Fund Parameters
    uint256 public minInvestAmount;
    // Risk management Parameters...
    uint256 public investPaymentDueTime;
    uint256 public softCap;
    uint256 public hardCap;

    // Events
    event Deposit(address indexed investor, uint256 amount);
    event StartFund(uint256 num_investors, uint256 totalInvestedAmount, uint256 BCNTLockAmount);
    event AbortFund(uint256 num_investors, uint256 totalInvestedAmount);
    event MidwayQuit(address indexed investor, uint256 investAmount, uint256 BCNTWithdrawAmount);
    event DesignateFundManager(address indexed fundManager);
    event Allocate(address indexed to, uint256 amountForInvestment);
    event ReturnAUM(uint256 amountStableToken, uint256 amountBCNT);
    event DistributeProfit(address indexed to, uint256 amountStableToken, uint256 amountBCNT);


    // Modifiers
    modifier initialized() {
        require(fundStatus == 1);
        _;
    }

    modifier fundStarted() {
        require(fundStatus == 3);
        _;
    }

    modifier running() {
        require(fundStatus == 4);
        _;
    }

    modifier stopped() {
        require(fundStatus == 5);
        _;
    }

    modifier afterStartedBeforeClosed() {
        require((fundStatus >= 3) && (fundStatus < 6));
        _;
    }

    modifier closed() {
        require(fundStatus == 6);
        _;
    }

    modifier isBincentive() {
        require(
            (msg.sender == bincentiveHot) || (msg.sender == bincentiveCold)
        );
        _;
    }

    modifier isBincentiveCold() {
        require(msg.sender == bincentiveCold);
        _;
    }

    modifier isInvestor() {
        // bincentive is not investor
        require(msg.sender != bincentiveHot);
        require(msg.sender != bincentiveCold);
        require(investedAmount[msg.sender] > 0);
        _;
    }

    modifier isAccountManager() {
        require(msg.sender == accountManager);
        _;
    }

    modifier isFundManager() {
        require(msg.sender == fundManager);
        _;
    }

    // Getter Functions


    // Investor Deposit
    function deposit(address investor, uint256 deposit_amount) initialized public {
        require(now < investPaymentDueTime);
        require(currentInvestedAmount < hardCap);

        uint256 amount;
        if(currentInvestedAmount.add(deposit_amount) <= hardCap) {
            amount = deposit_amount;
        } else {
            amount = hardCap.sub(currentInvestedAmount);
        }
        require(amount >= minInvestAmount);

        // Transfer Stable Token to this contract
        require(StableToken.transferFrom(msg.sender, address(this), amount));

        currentInvestedAmount = currentInvestedAmount.add(amount);
        if(investedAmount[investor] == 0) {
            investors.push(investor);
        }
        investedAmount[investor] = investedAmount[investor].add(amount);

        emit Deposit(investor, amount);
    }

    // Start Investing
    function start(uint256 _BCNTLockAmount) initialized isBincentive public {
        require(currentInvestedAmount >= softCap);

        // Transfer and lock BCNT into the contract
        require(BCNTToken.transferFrom(bincentiveCold, address(this), _BCNTLockAmount));
        BCNTLockAmount = _BCNTLockAmount;

        // Start the contract
        fundStatus = 3;
        emit StartFund(investors.length, currentInvestedAmount, BCNTLockAmount);
    }

    // NOTE: might consider changing to withdrawal pattern
    // Not Enough Fund
    function notEnoughFund() initialized isBincentive public {
        require(now >= investPaymentDueTime);
        require(currentInvestedAmount < softCap);

        // End the contract due to not enough fund
        fundStatus = 2;

        address investor;
        // Return Stable Token to investors
        for(uint i = 0; i < investors.length; i++) {
            investor = investors[i];
            require(StableToken.transfer(investor, investedAmount[investor]));
        }

        emit AbortFund(investors.length, currentInvestedAmount);
    }

    // Investor quit and withdraw
    function midwayQuit() afterStartedBeforeClosed isInvestor public {
        uint256 investor_amount = investedAmount[msg.sender];
        investedAmount[msg.sender] = 0;

        uint256 totalAmount = currentInvestedAmount;
        currentInvestedAmount = currentInvestedAmount.sub(investor_amount);

        uint256 BCNTWithdrawAmount = BCNTLockAmount.mul(investor_amount).div(totalAmount);
        BCNTLockAmount = BCNTLockAmount.sub(BCNTWithdrawAmount);
        require(BCNTToken.transfer(msg.sender, BCNTWithdrawAmount));

        // Terminate the contract if every investor has quit
        if(currentInvestedAmount == 0) {
            fundStatus = 32;
        }

        emit MidwayQuit(msg.sender, investor_amount, BCNTWithdrawAmount);
    }

    // Account manager designate fund manager
    function designateFundManager(address _fundManager) fundStarted isAccountManager public {
        require(fundManager == address(0), "Fund manager is already declared.");
        fundManager = _fundManager;

        emit DesignateFundManager(_fundManager);
    }

    // Fund manager allocate the resources
    function allocateFund(address[] traders, uint256[] receiveAmounts) fundStarted isFundManager public {
        require(traders.length == receiveAmounts.length, "Input not of the same length");
        require(traders.length > 0, "Must has at least one recipient");

        uint256 totalAllocatedAmount;
        for(uint i = 0; i < traders.length; i++) {
            totalAllocatedAmount = totalAllocatedAmount.add(receiveAmounts[i]);

            // Transfer the fund to trader
            require(StableToken.transfer(traders[i], receiveAmounts[i]));

            emit Allocate(traders[i], receiveAmounts[i]);
        }

        require(totalAllocatedAmount == currentInvestedAmount, "Must allocate the full invested amount");
        fundStatus = 4;
    }

    // Return AUM
    function returnAUM(uint256 stableTokenAmount, uint256 BCNTAmount) running isBincentiveCold public {

        returnedStableTokenAmounts = stableTokenAmount;
        returnedBCNTAmounts = BCNTAmount;

        // Transfer stable token AUM to trader
        require(StableToken.transferFrom(bincentiveCold, address(this), stableTokenAmount));

        // Transfer BCNT AUM to trader
        require(BCNTToken.transferFrom(bincentiveCold, address(this), BCNTAmount));

        emit ReturnAUM(stableTokenAmount, BCNTAmount);

        fundStatus = 5;
    }

    // Distribute AUM
    function distributeAUM() stopped isBincentive public {
        uint256 totalStableTokenReturned = returnedStableTokenAmounts;
        returnedStableTokenAmounts = 0;
        uint256 totalBCNTReturned = returnedBCNTAmounts;
        returnedBCNTAmounts = 0;
        uint256 totalAmount = currentInvestedAmount;
        currentInvestedAmount = 0;

        uint256 stableTokenDistributeAmount;
        uint256 BCNTDistributeAmount;
        address investor;
        uint256 investor_amount;
        // Distribute Stable Token and BCNT to investors
        for(uint i = 0; i < investors.length; i++) {
            investor = investors[i];
            if(investedAmount[investor] == 0) continue;
            investor_amount = investedAmount[investor];
            investedAmount[investor] = 0;

            stableTokenDistributeAmount = totalStableTokenReturned.mul(investor_amount).div(totalAmount);
            require(StableToken.transfer(investor, stableTokenDistributeAmount));

            BCNTDistributeAmount = totalBCNTReturned.mul(investor_amount).div(totalAmount);
            require(BCNTToken.transfer(investor, BCNTDistributeAmount));

            emit DistributeProfit(investor, stableTokenDistributeAmount, BCNTDistributeAmount);
        }

        uint256 _BCNTLockAmount = BCNTLockAmount;
        BCNTLockAmount = 0;
        require(BCNTToken.transfer(bincentiveCold, _BCNTLockAmount));

        fundStatus = 6;
    }

    function claimWronglyTransferredFund() closed isBincentive public {
        uint256 leftOverAmount;
        leftOverAmount = StableToken.balanceOf(address(this));
        if(leftOverAmount > 0) {
            require(StableToken.transfer(bincentiveCold, leftOverAmount));
        }
        leftOverAmount = BCNTToken.balanceOf(address(this));
        if(leftOverAmount > 0) {
            require(BCNTToken.transfer(bincentiveCold, leftOverAmount));
        }
    }


    // Constructor
    constructor(
        address _BCNTToken,
        address _StableToken,
        address _bincentiveHot,
        address _bincentiveCold,
        address _accountManager,
        uint256 _minInvestAmount,
        uint256 _investPaymentPeriod,
        uint256 _softCap,
        uint256 _hardCap) public {

        bincentiveHot = _bincentiveHot;
        bincentiveCold = _bincentiveCold;
        BCNTToken = ERC20(_BCNTToken);
        StableToken = ERC20(_StableToken);

        // Assign roles
        accountManager = _accountManager;

        // Set parameters
        minInvestAmount = _minInvestAmount;
        investPaymentDueTime = now.add(_investPaymentPeriod);
        softCap = _softCap;
        hardCap = _hardCap;

        // Initialized the contract
        fundStatus = 1;
    }
}

library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}
