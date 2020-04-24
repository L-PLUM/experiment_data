/**
 *Submitted for verification at Etherscan.io on 2019-01-29
*/

pragma solidity ^0.5.1;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
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

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title ERC20
 * @dev Used to interact with a token contract
 */
contract ERC20 {
    function totalSupply() public pure returns (uint);
    function balanceOf(address tokenOwner) public pure returns (uint balance);
    function allowance(address tokenOwner, address spender) public pure returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    function owner() public pure returns (address);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

/**
 * @title InvestmentPlatform
 * @dev Send tokens to this contract and receive roi when project is completed
 */
contract InvestmentPlatform is Ownable {
    using SafeMath for uint256;

    /** PROJECT VARIABLES
     * @dev These will depend on the project requirements.
     */
     // Token Address
    address public token = 0xf8d75D3b9Eeddc16EACc0c9D6380B0c5ea4Ced5C;
    // Platform Owner Address
    address public platformowner = 0xe3de74151CbDFB47d214F7E6Bcb8F5EfDCf99636;
    // Required funds in token units
    uint256 public requirement = 1000 * 10**uint256(18);
    // Return on investment in percentage
    uint256 public  roi = 30;
    // How much should be the roi
    uint256 public expected = calculateroi(requirement);

    /** INTERNAL VARIABLES
     */
    // Total funds received
    uint256 public totalfunds = 0;
    // Funds to be returned
    uint256 public returnfunds = requirement;
    // Total fees incurred
    uint256 public totalfee = 0;
    // Funding fee in percentage
    uint256 private fundingfee = 3;
    // Cashout fee in percentage
    uint256 private cashoutfee = 0;
    
    // Records the investor deposit
    mapping ( address => uint256 ) public balances;

    /** STATE VARIABLES
     * @dev Holds boolean states of the contract
     * activated: Requires insurance tokens before investors can send tokens.
     * funded: Funding requirement has been reached.
     * withdrawn: Contract owner has received token funds.
     * completed: Investors can now cashout their tokens with roi.
     * failed: Investors can retrieve their invested token without the roi.
     */
    bool public funded = false;
    bool public withdrawn = false;
    bool public completed = false;
    bool public failed = false;
    bool public paused = false;

    /** EVENTS
     */
    event Invest(address investor, uint256 amount);
    event WithdrawFunds(address projectmanager, uint256 amount);
    event CompleteProject(address completer, uint256 amount);
    event CashOut(address investor, uint256 amount);

    event WithdrawFee(address receiver, uint256 amount);
    event UnstuckFunds(address receiver, uint256 amount);

    event FailProject();
    event RetrieveFunds(address investor, uint256 amount);
    
    event Pause();
    event Unpause();

    /** MODIFIERS
     */
    modifier onlyPlatformOwner() {
        require(msg.sender == platformowner);
        _;
    }

    modifier onlyInvestor() {
        require(msg.sender != owner && msg.sender != platformowner);
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == owner || msg.sender == platformowner);
        _;
    }

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused() {
        require(paused);
        _;
    }
  
    /**
    * @dev Calculates the ROI
    * @param amount The value to be added with the roi.
    */
    function calculateroi(uint256 amount) internal view returns(uint256) {
        uint256 roiamount;
        roiamount = amount.mul(roi).div(100).add(amount);
        return roiamount;
    }

    /**
    * @dev Calculates the fee
    * @param amount The value to be applied with the fee.
    */
    function calculatefee(uint256 amount, uint256 feepercent) internal pure returns(uint256) {
        uint256 feeamount;
        feeamount = amount.mul(feepercent).div(100);
        return feeamount;
    }


    /** 
     * COMPLETED CONTRACT EXTERNAL FUNCTIONS
     */



    /**
    * @dev Sends tokens to this contract.
    * Requires token approval to work.
    * Sets funded to true when totalfunds reaches requirement.
    * 
    * @param amount The token amount to invest in this contract.
    */
    function invest(uint256 amount) external onlyInvestor whenNotPaused {
        
        require(!funded);
        require(!failed);
        
        // Prevents overfunding When requirement is reached
        if (totalfunds.add(amount) >= requirement) {
            uint256 investamount = requirement.sub(totalfunds);
            balances[msg.sender] = balances[msg.sender].add(investamount);
            totalfunds = requirement;
            funded = true;
            ERC20(token).transferFrom(msg.sender,address(this),investamount);
            emit Invest(msg.sender,investamount);
        }
        else {
        totalfunds = totalfunds.add(amount);
        balances[msg.sender] = balances[msg.sender].add(amount);
        ERC20(token).transferFrom(msg.sender,address(this),amount);
        emit Invest(msg.sender,amount);
        }
    }

    /**
    * @dev Receives all tokens invested in this contract.
    * Sets withdrawn to true.
    */
    function withdrawfunds() external onlyOwner whenNotPaused {
        require(funded);
        require(!failed);
        require(!withdrawn);
        uint256 withdrawalfee = calculatefee(totalfunds,fundingfee);
        uint256 totalwithdrawal = totalfunds.sub(withdrawalfee);
        totalfee = totalfee.add(withdrawalfee);
        withdrawn = true;
        ERC20(token).transfer(msg.sender, totalwithdrawal);
        emit WithdrawFunds(msg.sender,totalwithdrawal);
    }

    /**
    * @dev Sends expected tokens to be returned to investors.
    * Owner will send token profit for investors.
    * PlatformOwner must send token insurance for investors if Owner was unable to comply.
    * Requires token approval to work.
    * Sets completed to true.
    */
    function completeproject() external onlyAdmin whenNotPaused {
        require(withdrawn);
        require(!completed);
        completed = true;
        paused = true;
        ERC20(token).transferFrom(msg.sender,address(this),expected);
        emit CompleteProject(msg.sender,expected);
    }

    /**
    * @dev Receives tokens based on invested amount and roi.
    */
    function cashout() external onlyInvestor whenNotPaused {
        require(completed);
        uint256 investingfee = calculatefee(calculateroi(balances[msg.sender]),cashoutfee);
        uint256 cashoutamount = calculateroi(balances[msg.sender]).sub(investingfee);
        totalfee = totalfee.add(investingfee);
        returnfunds = returnfunds.sub(balances[msg.sender]);
        balances[msg.sender] = 0;
        ERC20(token).transfer(msg.sender, cashoutamount);
        emit CashOut(msg.sender, cashoutamount);
    }



    /** 
     * PLATFORM OWNER EXTERNAL FUNCTIONS
     */



    /**
    * @dev Pause the contract
    */
    function pause() external onlyPlatformOwner whenNotPaused {
        paused = true;
        emit Pause();
    }

    /**
    * @dev Unpause the contract
    */
    function unpause() external onlyPlatformOwner whenPaused {
        paused = false;
        emit Unpause();
    }

    /**
    * @dev Receive all fees.
    */
    function withdrawfee() external onlyPlatformOwner whenNotPaused {
        require(withdrawn);
        ERC20(token).transfer(msg.sender,totalfee);
        emit WithdrawFee(msg.sender, totalfee);
        totalfee = 0;
    }

    /**
    * @dev Receives extra tokens not cashed out in this contract.
    * Extra tokens happen because of rounding down during roi calculation.
    * @param amount The extra token amount.
    */
    function unstuckfunds(uint256 amount) external onlyPlatformOwner whenNotPaused {
        require(returnfunds == 0);
        ERC20(token).transfer(msg.sender,amount);
        emit UnstuckFunds(msg.sender, amount);
    }



    /** 
     * FAILED CONTRACT EXTERNAL FUNCTIONS
     */



    /**
    * @dev Receives insurance tokens sent to activate this contract.
    * Sets failed to true.
    */
    function failproject() external onlyPlatformOwner whenNotPaused {
        require(!withdrawn);
        require(!failed);
        failed = true;
        paused = true;
        emit FailProject();
    }

    /**
    * @dev Receives tokens based on invested amount.
    */
    function retrievefunds() external onlyInvestor whenNotPaused {
        require(failed);
        ERC20(token).transfer(msg.sender, balances[msg.sender]);
        emit RetrieveFunds(msg.sender, balances[msg.sender]);
        balances[msg.sender] = 0;
    }
}
