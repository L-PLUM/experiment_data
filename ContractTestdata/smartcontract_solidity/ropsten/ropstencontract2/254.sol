/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity 0.5.10;

// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address payable public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address payable from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

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

contract TestBox is Owned, ERC20Interface{
    using SafeMath for uint256;
    
    /* ERC20 public vars */
    string public constant version = 'ETHBOX 0.2';
    string public name = 'Test Box';
    string public symbol = 'TB';
    uint256 public decimals = 18;
    uint256 internal _totalSupply;

    /* ERC20 This creates an array with all balances */
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    

    /* Keeps record of Depositor's amount and deposit time */
    mapping (address => Depositor) public depositor;
    
    struct Depositor{
        uint256 amount;
        uint time;
    }

    /* feePot collects fees from quick withdrawals. This gets re-distributed to withdrawals */
    uint256 public feePot;
    
    /* reservedReward collects owner reward share */
    uint256 internal reservedReward;

    //uint256 public timeWait = 30 days;
    uint256 public timeWait = 3 minutes;                                                //  for TestNet

    uint256 public constant initialSupply = 4e7;                                        //40,000,000
    
    /* custom events to notify users */
    event Withdraw(address indexed by, uint256 amount, uint256 fee, uint256 reward);  // successful withdraw event
    event Deposited(address indexed by, uint256 amount);                                        // funds Deposited event

    /*
     * Initializes contract with initial supply tokens to the creator of the contract
     * In our case, there's no initial supply. Tokens will be created as ether is sent
     * to the fall-back function. Then tokens are burned when ether is withdrawn.
     */
    constructor () public {
        owner = msg.sender;
        _totalSupply = initialSupply * 10 ** uint(decimals);                            // Update total supply
        balances[owner] = _totalSupply;                                                 // Give the creator all initial tokens
    }

    /**
     * Fallback function when sending ether to the contract
     * Gas use: 
    */
    function () external payable {
        uint256 amount = msg.value;                                                     // amount that was sent
        require(amount > 0);                                                            // need to send some ETH
        balances[msg.sender] = balances[msg.sender].add(amount.mul(1000));            // mint new tokens
        _totalSupply = _totalSupply.add(amount.mul(1000));                                // track the supply
        depositor[msg.sender].time = now;
        depositor[msg.sender].amount = msg.value;
        emit Transfer(address(0), msg.sender, amount.mul(1000));                        // notify of the transfer event
        emit Deposited(msg.sender, amount);                                             // notify deposit event
    }
    
    function withdraw(address payable _sender) internal {
        uint256 amount = depositor[_sender].amount;                                     // check the actual deposit of the sender
        uint256 reward = calculateReward(amount);                                       // calculate reward of the sender based on actual deposit 
        if(depositor[_sender].time.add(timeWait) < now )                                // sender asked for withdraw before 30 days of purchase
            amount = quickWithdraw(amount);                                             // quick Withdraw will happen
        
        emit Transfer(_sender, address(0), amount.mul(1000));                           // burn tokens
        require(_sender.send(amount + reward));                                         // transfer tokens plus earned reward to sender
        _totalSupply = _totalSupply.sub(amount.mul(1000));                              // remove burned tokens from _totalSupply
        balances[_sender] = balances[_sender].sub(amount.mul(1000));                    // remove tokens from sender's balance
        feePot = feePot.sub(reward);                                                    // remove reward from feePot
        depositor[_sender].amount = 0;                                                  // remove deposit information from depositor record
        
        emit Withdraw(_sender, amount, depositor[_sender].amount.sub(amount), reward);
        
    }

    /**
     * Quick withdrawal, deduct 4% penalty fee due to early withdraw.
     *
     * Gas use: ? (including call to processWithdrawal)
    */
    function quickWithdraw(uint256 _amount) internal returns (uint256) {
        uint256 penaltyFee = calculateFee(_amount);                                     // deduct 4% of the actual deposit as penalty fee
        feePot =  feePot.add(penaltyFee.mul(70).mul(100)).div(10000);                   // add 70% of the penaltyFee to fee Pot to distribute later
        reservedReward = reservedReward.add(penaltyFee.mul(30).mul(100)).div(10000);    // add 30% of the penaltyFee to reserves for owner
        return _amount.sub(penaltyFee);
    }
    
    function ownerReward() external onlyOwner{
        require(owner.send(reservedReward));
        reservedReward -= reservedReward;
    }
    
    /**
     * Reward is based on the amount held, relative to total supply of tokens.
     */
    function calculateReward(uint256 _amount) public view returns (uint256) {
        uint256 reward = 0;
        if (feePot > 0) {
            reward = feePot * _amount / _totalSupply; // assuming that if feePot > 0 then also totalSupply > 0
        }
        return reward;
    }

    /** calculate the penalty fee for quick withdrawal
     */
    function calculateFee(uint256 _amount) public pure returns  (uint256) {
        uint256 feeRequired = (_amount.mul(4).mul(100)).div(10000); // 4%
        return feeRequired;
    }
    
    /***************************** ERC20 implementation **********************/
    function totalSupply() public view returns (uint){
       return _totalSupply;
    }
    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        
        require(to != address(0));                                                              // receiver address should not be zero-address
        require(balances[msg.sender] >= tokens );                                               // sender must have sufficient tokens to transfer
        
        balances[msg.sender] = balances[msg.sender].sub(tokens);                                // remove tokens from sender
        
        if( to ==  address(this)){                                                              // if tokens are sent to contract address
            
            if(depositor[msg.sender].amount == 0 && depositor[msg.sender].time == 0){           // sender must be an actual depositor
                balances[msg.sender] = balances[msg.sender].sub(tokens);                        // remove tokens from sender balance
                _totalSupply = _totalSupply.sub(tokens);                                        // remove sent tokens from totalSupply
                emit Transfer(msg.sender, address(0), tokens);                                  // emit Transfer event of burning
            } 
            else {
                require(tokens == depositor[msg.sender].amount.mul(1000));                      // sender must send exact amount of tokens they purchased
                withdraw(msg.sender);                                                           // perform withdraw 
            }
        }
        else {                                                                                  // if tokens are sent to any other wallet address
            require(balances[to] + tokens >= balances[to]);
        
            balances[to] = balances[to].add(tokens);                                            // Transfer the tokens to "to" address
        
            emit Transfer(msg.sender,to,tokens);                                                // emit Transfer event to "to" address
        }
        return true;
    }
    
    
    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address payable from, address to, uint tokens) public returns (bool success){
        require(from != address(0));
        require(to != address(0));
        require(tokens <= allowed[from][msg.sender]); //check allowance
        require(balances[from] >= tokens); // check if sufficient balance exist or not
        
        balances[from] = balances[from].sub(tokens);
        
        if( to ==  address(this)){                                                              // if tokens are sent to contract address
            
            if(depositor[from].amount == 0 && depositor[from].time == 0){                       // from must be an actual depositor
                balances[from] = balances[from].sub(tokens);                                    // remove tokens from sender balance
                _totalSupply = _totalSupply.sub(tokens);                                        // remove sent tokens from totalSupply
                emit Transfer(from, address(0), tokens);                                        // emit Transfer event of burning
            } 
            else {
                require(tokens == depositor[from].amount.mul(1000));                            // tokens must be equal to exact amount of tokens "from" purchased
                withdraw(from);                                                           // perform withdraw 
            }
        }
        else {                                                                                  // if tokens are sent to any other wallet address
            require(balances[to] + tokens >= balances[to]);
        
            balances[to] = balances[to].add(tokens);                                            // Transfer the tokens to "to" address
        
            emit Transfer(msg.sender,to,tokens);                                                // emit Transfer event to "to" address
        }
        
        
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        return true;
    }
    
    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success){
        require(spender != address(0));
        require(tokens <= balances[msg.sender]);
        require(tokens >= 0);
        require(allowed[msg.sender][spender] == 0 || tokens == 0);
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender,spender,tokens);
        return true;
    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
}
