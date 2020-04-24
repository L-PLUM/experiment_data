/**
 *Submitted for verification at Etherscan.io on 2019-02-23
*/

pragma solidity ^0.4.25;
// ----------------------------------------------------------------------------
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
library ExtendedMath {
    //return the smaller of the two inputs (a or b)
    function limitLessThan(uint a, uint b) internal pure returns (uint c) {
        if(a > b) return b;
        return a;
    }
}
// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract EIP918Interface {

    /*
     * Externally facing mint function that is called by miners to validate challenge digests, calculate reward,
     * populate statistics, mutate epoch variables and adjust the solution difficulty as required. Once complete,
     * a Mint event is emitted before returning a success indicator.
     **/
    function mint(uint256 nonce, bytes32 challenge_digest) public returns (bool success);

    /*
     * Optional
     * Externally facing merge function that is called by miners to validate challenge digests, calculate reward,
     * populate statistics, mutate epoch variables and adjust the solution difficulty as required. Additionally, the
     * merge function takes an array of target token addresses to be used in merged rewards. Once complete,
     * a Mint event is emitted before returning a success indicator.
     **/
    //function merge(uint256 nonce, bytes32 challenge_digest, address[] mineTokens) public returns (bool);

    /*
     * Returns the challenge number
     **/
    function getChallengeNumber() public view returns (bytes32);

    /*
     * Returns the mining difficulty. The number of digits that the digest of the PoW solution requires which 
     * typically auto adjusts during reward generation.
     **/
    function getMiningDifficulty() public view returns (uint);

    /*
     * Returns the mining target
     **/
    function getMiningTarget() public view returns (uint);

    /*
     * Return the current reward amount. Depending on the algorithm, typically rewards are divided every reward era 
     * as tokens are mined to provide scarcity
     **/
    function getMiningReward() public view returns (uint);
    
    /*
     * Upon successful verification and reward the mint method dispatches a Mint Event indicating the reward address, 
     * the reward amount, the epoch count and newest challenge number.
     **/
    event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);

}
// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
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
// ERC20 Token, with the addition of symbol, name and decimals and an
// initial fixed supply
// ----------------------------------------------------------------------------
contract _PASPOWTOKEN is ERC20Interface, EIP918Interface, Owned {
    using SafeMath for uint;
    using ExtendedMath for uint;
    string public symbol;
    string public  name;
	address public Admin;
    uint8 public decimals;
    uint public _totalSupply;
	uint public tokensMinted;
    uint public latestDifficultyPeriodStarted;
    uint public epochCount;//number of 'blocks' mined
    //a little number
    uint public  _MINIMUM_TARGET = 2**230;
	//a big number is easier ; just find a solution that is smaller
    //uint public  _MAXIMUM_TARGET = 2**224;  bitcoin uses 224
    uint public  _MAXIMUM_TARGET = 2**238;
    uint public miningTarget;
    bytes32 public challengeNumber;   //generate a new one when a new reward is minted
    address public lastRewardTo;
    uint public lastRewardAmount;
    uint public lastRewardEthBlockNumber;
    // a bunch of maps to know where this is going (pun intended)
    
    mapping(bytes32 => bytes32) public solutionForChallenge;
    mapping(uint => uint) public targetForEpoch;
    mapping(uint => uint) public timeStampForEpoch;
    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);

    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public{
        symbol = "PAS";
        name = "PAS POW Token";
        Admin = 0x3CbC8adcc7aa403324020a6535fdb2C8314Fe5b4;
        decimals = 8;
        epochCount = 0;
       _totalSupply = 21000000 * 10**uint(decimals);
		tokensMinted = 0;
        
        targetForEpoch[epochCount] = _MAXIMUM_TARGET;
        challengeNumber = "GENESIS_BLOCK";
        solutionForChallenge[challengeNumber] = "42"; // ahah yes
        timeStampForEpoch[epochCount] = block.timestamp;
        latestDifficultyPeriodStarted = block.number;
        
        epochCount = epochCount.add(1);
        targetForEpoch[epochCount] = _MAXIMUM_TARGET;
        miningTarget = _MAXIMUM_TARGET;
        
       

    }

    function mint(uint256 nonce, bytes32 challenge_digest) public returns (bool success) {
        //the PoW must contain work that includes a recent ethereum block hash (challenge number) and the msg.sender's address to prevent MITM attacks
        bytes32 digest =  keccak256(challengeNumber, msg.sender, nonce );
		
		//check total supply
            if( tokensMinted > _totalSupply) revert();

        //the challenge digest must match the expected
        if (digest != challenge_digest) revert();
        //the digest must be smaller than the target
        if(uint256(digest) > miningTarget) revert();
        //only allow one reward for each challenge
        bytes32 solution = solutionForChallenge[challenge_digest];
        solutionForChallenge[challengeNumber] = digest;
        if(solution != 0x0) revert();  //prevent the same answer from awarding twice
        uint reward_amount = getMiningReward();
		tokensMinted = tokensMinted.add(reward_amount);
		uint balance_add = reward_amount / 2;
		
        balances[msg.sender] = balances[msg.sender].add(balance_add);
     
        //set readonly diagnostics data
        lastRewardTo = msg.sender;
        lastRewardAmount = reward_amount;
        lastRewardEthBlockNumber = block.number;
        _startNewMiningEpoch();
        emit Mint(msg.sender, reward_amount, epochCount, challengeNumber );
       return true;
    }

    //a new 'block' to be mined
    function _startNewMiningEpoch() internal {
        
        timeStampForEpoch[epochCount] = block.timestamp;
        epochCount = epochCount.add(1);
    
      //Difficulty adjustment following the DigiChieldv3 implementation (Tempered-SMA)
      // Allows more thorough protection against multi-pool hash attacks
      // https://github.com/zawy12/difficulty-algorithms/issues/9
        miningTarget = _reAdjustDifficulty(epochCount);
      //make the latest ethereum block hash a part of the next challenge for PoW to prevent pre-mining future blocks
      //do this last since this is a protection mechanism in the mint() function
      challengeNumber = blockhash(block.number.sub(1));
    }

    //https://github.com/zawy12/difficulty-algorithms/issues/21
    //readjust the target via a tempered EMA
    function _reAdjustDifficulty(uint epoch) internal returns (uint) {
    
        uint timeTarget = 300;  // We want miners to spend 5 minutes to mine each 'block'
        uint N = 6180;          //N = 1000*n, ratio between timeTarget and windowTime (31-ish minutes)
                                // (Ethereum doesn't handle floating point numbers very well)
        uint elapsedTime = timeStampForEpoch[epoch.sub(1)].sub(timeStampForEpoch[epoch.sub(2)]); // will revert if current timestamp is smaller than the previous one
        targetForEpoch[epoch] = (targetForEpoch[epoch.sub(1)].mul(10000)).div( N.mul(3920).div(N.sub(1000).add(elapsedTime.mul(1042).div(timeTarget))).add(N));
        //              newTarget   =   Tampered EMA-retarget on the last 6 blocks (a bit more, it's an approximation)
	// 				Also, there's an adjust factor, in order to correct the delays induced by the time it takes for transactions to confirm
	//				Difficulty is adjusted to the time it takes to produce a valid hash. Here, if we set it to take 300 seconds, it will actually take 
	//				300 seconds + TxConfirmTime to validate that block. So, we wad a little % to correct that lag time.
	//				Once Ethereum scales, it will actually make block times go a tad faster. There's no perfect answer to this problem at the moment
        latestDifficultyPeriodStarted = block.number;
        return targetForEpoch[epoch];
    }

    //this is a recent ethereum block hash, used to prevent pre-mining future blocks
    function getChallengeNumber() public constant returns (bytes32) {
        return challengeNumber;
    }

    //the number of zeroes the digest of the PoW solution requires.  Auto adjusts
     function getMiningDifficulty() public constant returns (uint) {
        return _MAXIMUM_TARGET.div(targetForEpoch[epochCount]);
    }

    function getMiningTarget() public constant returns (uint) {
       return targetForEpoch[epochCount];
    }

    function getMiningReward() public constant returns (uint) {
         //total block reward 0.05
		return (5000000) ;
	}


    //help debug mining software (even though challenge_digest isn't used, this function is constant and helps troubleshooting mining issues)
    function getMintDigest(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number) public view returns (bytes32 digesttest) {
        bytes32 digest = keccak256(challenge_number,msg.sender,nonce);
        return digest;
    }

    //help debug mining software
    function checkMintSolution(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number, uint testTarget) public view returns (bool success) {
      bytes32 digest = keccak256(challenge_number,msg.sender,nonce);
      if(uint256(digest) > testTarget) revert();
      return (digest == challenge_digest);
    }

    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }

    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }
    

    
   

    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {

        balances[msg.sender] = balances[msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        Transfer(msg.sender, to, tokens);

        return true;

    }
    
  
    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
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
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {

        balances[from] = balances[from].sub(tokens);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        Transfer(from, to, tokens);

        return true;

    }

    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }

    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }

    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }
    
    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}
