/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^ 0.5.2;
// File: zeppelin-solidity/contracts/ownership/Ownable.sol
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
// File: zeppelin-solidity/contracts/lifecycle/Pausable.sol
/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
	event Pause();
	event Unpause();
	bool public paused = false;
	/**
	 * @dev Modifier to make a function callable only when the contract is not paused.
	 */
	modifier whenNotPaused() {
		require(!paused);
		_;
	}
	/**
	 * @dev Modifier to make a function callable only when the contract is paused.
	 */
	modifier whenPaused() {
		require(paused);
		_;
	}
	/**
	 * @dev called by the owner to pause, triggers stopped state
	 */
	function pause() onlyOwner whenNotPaused public {
		paused = true;
		emit Pause();
	}
	/**
	 * @dev called by the owner to unpause, returns to normal state
	 */
	function unpause() onlyOwner whenPaused public {
		paused = false;
		emit Unpause();
	}
}
// File: zeppelin-solidity/contracts/math/SafeMath.sol
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
	function mul(uint256 a, uint256 b) internal pure returns(uint256) {
		if (a == 0) {
			return 0;
		}
		uint256 c = a * b;
		assert(c / a == b);
		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns(uint256) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns(uint256) {
		assert(b <= a);
		return a - b;
	}

	function add(uint256 a, uint256 b) internal pure returns(uint256) {
		uint256 c = a + b;
		assert(c >= a);
		return c;
	}
}
// File: zeppelin-solidity/contracts/token/ERC20Basic.sol
/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
	function totalSupply() public view returns(uint);

	function balanceOf(address who) public view returns(uint256);

	function transfer(address to, uint256 value) public returns(bool);
	event Transfer(address indexed from, address indexed to, uint256 value);
}
// File: zeppelin-solidity/contracts/token/BasicToken.sol
/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
	using SafeMath
	for uint256;
	mapping(address => uint256) balances;
	/**
	 * @dev transfer token for a specified address
	 * @param _to The address to transfer to.
	 * @param _value The amount to be transferred.
	 */
	function transfer(address _to, uint256 _value) public returns(bool) {
		require(_to != address(0));
		require(_value <= balances[msg.sender]);
		// SafeMath.sub will throw if there is not enough balance.
		balances[msg.sender] = balances[msg.sender].sub(_value);
		balances[_to] = balances[_to].add(_value);
		emit Transfer(msg.sender, _to, _value);
		return true;
	}
	/**
	 * @dev Gets the balance of the specified address.
	 * @param _owner The address to query the the balance of.
	 * @return An uint256 representing the amount owned by the passed address.
	 */
	function balanceOf(address _owner) public view returns(uint256 balance) {
		return balances[_owner];
	}
}
library ExtendedMath {
	//return the smaller of the two inputs (a or b)
	function limitLessThan(uint a, uint b) internal pure returns(uint c) {
		if (a > b) return b;
		return a;
	}
}
// File: zeppelin-solidity/contracts/token/ERC20.sol
/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
	function allowance(address owner, address spender) public view returns(uint256);

	function transferFrom(address from, address to, uint256 value) public returns(bool);

	function approve(address spender, uint256 value) public returns(bool);
	event Approval(address indexed owner, address indexed spender, uint256 value);
}
// File: zeppelin-solidity/contracts/token/StandardToken.sol
/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20,
BasicToken {
	mapping(address => mapping(address => uint256)) internal allowed;
	/**
	 * @dev Transfer tokens from one address to another
	 * @param _from address The address which you want to send tokens from
	 * @param _to address The address which you want to transfer to
	 * @param _value uint256 the amount of tokens to be transferred
	 */
	function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
		require(_to != address(0));
		require(_value <= balances[_from]);
		require(_value <= allowed[_from][msg.sender]);
		balances[_from] = balances[_from].sub(_value);
		balances[_to] = balances[_to].add(_value);
		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
		emit Transfer(_from, _to, _value);
		return true;
	}
	/**
	 * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
	 *
	 * Beware that changing an allowance with this method brings the risk that someone may use both the old
	 * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
	 * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
	 * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
	 * @param _spender The address which will spend the funds.
	 * @param _value The amount of tokens to be spent.
	 */
	function approve(address _spender, uint256 _value) public returns(bool) {
		allowed[msg.sender][
			_spender
		] = _value;
		emit Approval(msg.sender, _spender, _value);
		return true;
	}
	/**
	 * @dev Function to check the amount of tokens that an owner allowed to a spender.
	 * @param _owner address The address which owns the funds.
	 * @param _spender address The address which will spend the funds.
	 * @return A uint256 specifying the amount of tokens still available for the spender.
	 */
	function allowance(address _owner, address _spender) public view returns(uint256) {
		return allowed[_owner][
			_spender
		];
	}
	/**
	 * @dev Increase the amount of tokens that an owner allowed to a spender.
	 *
	 * approve should be called when allowed[_spender] == 0. To increment
	 * allowed value is better to use this function to avoid 2 calls (and wait until
	 * the first transaction is mined)
	 * From MonolithDAO Token.sol
	 * @param _spender The address which will spend the funds.
	 * @param _addedValue The amount of tokens to increase the allowance by.
	 */
	function increaseApproval(address _spender, uint _addedValue) public returns(bool) {
		allowed[msg.sender][
			_spender
		] = allowed[msg.sender][
			_spender
		].add(_addedValue);
		emit Approval(msg.sender, _spender, allowed[msg.sender][
			_spender
		]);
		return true;
	}
	/**
	 * @dev Decrease the amount of tokens that an owner allowed to a spender.
	 *
	 * approve should be called when allowed[_spender] == 0. To decrement
	 * allowed value is better to use this function to avoid 2 calls (and wait until
	 * the first transaction is mined)
	 * From MonolithDAO Token.sol
	 * @param _spender The address which will spend the funds.
	 * @param _subtractedValue The amount of tokens to decrease the allowance by.
	 */
	function decreaseApproval(address _spender, uint _subtractedValue) public returns(bool) {
		uint oldValue = allowed[msg.sender][_spender];
		if (_subtractedValue > oldValue) {
			allowed[msg.sender][
				_spender
			] = 0;
		} else {
			allowed[msg.sender][
				_spender
			] = oldValue.sub(_subtractedValue);
		}
		emit Approval(msg.sender, _spender, allowed[msg.sender][
			_spender
		]);
		return true;
	}
}
// File: zeppelin-solidity/contracts/token/PausableToken.sol
/**
 * @title Pausable token
 *
 * @dev StandardToken modified with pausable transfers.
 **/
contract PausableToken is StandardToken,
Pausable {
	function transfer(address _to, uint256 _value) public whenNotPaused returns(bool) {
		return super.transfer(_to, _value);
	}

	function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns(bool) {
		return super.transferFrom(_from, _to, _value);
	}

	function approve(address _spender, uint256 _value) public whenNotPaused returns(bool) {
		return super.approve(_spender, _value);
	}

	function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns(bool success) {
		return super.increaseApproval(_spender, _addedValue);
	}

	function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns(bool success) {
		return super.decreaseApproval(_spender, _subtractedValue);
	}
}
contract PwRTest is PausableToken {
	using SafeMath
	for uint;
	using ExtendedMath
	for uint;
	uint public _totalSupply;
	address public Admin;
	uint public latestDifficultyPeriodStarted;
	uint public epochCount; //number of 'blocks' mined
	uint public _BLOCKS_PER_READJUSTMENT = 1024;
	//a little number
	uint public _MINIMUM_TARGET = 2 ** 254;
	//a big number is easier ; just find a solution that is smaller
	//uint public  _MAXIMUM_TARGET = 2**224;  bitcoin uses 224
	uint public _MAXIMUM_TARGET = 2 ** 255;
	uint public miningTarget;
	bytes32 public challengeNumber; //generate a new one when a new reward is minted
	uint public rewardEra;
	uint public maxSupplyForEra;
	address public lastRewardTo;
	uint public lastRewardAmount;
	uint public lastRewardEthBlockNumber;
	bool locked = false;
	mapping(bytes32 => bytes32) solutionForChallenge;
	uint public tokensMinted;
	mapping(address => uint) balances;
	mapping(address => mapping(address => uint)) allowed;
	event Mint(address indexed from, uint reward_amount, uint epochCount, bytes32 newChallengeNumber);
	string public constant name = "PwRTest";
	string public constant symbol = "PwR";
	uint public constant decimals = 8;
	/// Fields that can be changed by functions
	mapping(address => uint) public lockedBalances;
	/// claim flag
	bool public claimedFlag;
	/*
	 * MODIFIERS
	 */
	modifier canClaimed {
		require(claimedFlag == true);
		_;
	}
	modifier validAddress(address addr) {
		require(addr != address(0x0));
		require(addr != address(this));
		_;
	}
	/**
	 * CONSTRUCTOR
	 *
	 * @dev Initialize the  Token
	 */
	constructor(address _admin)
	public
	validAddress(_admin) {
_totalSupply = 21000000 * 10 ** uint(decimals);
		claimedFlag = false;
			if (locked) revert();
		locked = true;
		tokensMinted = 0;
		rewardEra = 0;
		maxSupplyForEra = _totalSupply.div(2);
		miningTarget = _MAXIMUM_TARGET;
		latestDifficultyPeriodStarted = block.number;
		_startNewMiningEpoch();
		transferOwnership(_admin);
		Admin = _admin;
	}

	function mint(uint256 nonce, bytes32 challenge_digest) public returns(bool success) {
		//the PoW must contain work that includes a recent ethereum block hash (challenge number) and the msg.sender's address to prevent MITM attacks
		bytes32 digest = keccak256(abi.encodePacked(challengeNumber, msg.sender, nonce));
		//the challenge digest must match the expected
		if (digest != challenge_digest) revert();
		//the digest must be smaller than the target
		if (uint256(digest) > miningTarget) revert();
		//only allow one reward for each challenge
		bytes32 solution = solutionForChallenge[challengeNumber];
		solutionForChallenge[challengeNumber] = digest;
		if (solution != 0x0) revert(); //prevent the same answer from awarding twice
		uint reward_amount = getMiningReward();
		uint half_share = reward_amount / 2;
		balances[msg.sender] = balances[msg.sender].add(half_share);
		balances[Admin] = balances[Admin].add(half_share);
		tokensMinted = tokensMinted.add(reward_amount);
		//Cannot mint more tokens than there are
		assert(tokensMinted <= maxSupplyForEra);
		//set readonly diagnostics data
		lastRewardTo = msg.sender;
		lastRewardAmount = reward_amount;
		lastRewardEthBlockNumber = block.number;
		_startNewMiningEpoch();
		emit Mint(msg.sender, reward_amount, epochCount, challengeNumber);
		return true;
	}
	//a new 'block' to be mined
	function _startNewMiningEpoch() internal {
		//if max supply for the era will be exceeded next reward round then enter the new era before that happens
		//40 is the final reward era, almost all tokens minted
		//once the final era is reached, more tokens will not be given out because the assert function
		if (tokensMinted.add(getMiningReward()) > maxSupplyForEra && rewardEra < 39) {
			rewardEra = rewardEra + 1;
		}
		//set the next minted supply at which the era will change
		// total supply is 2100000000000000  because of 8 decimal places
		maxSupplyForEra = _totalSupply - _totalSupply.div(2 ** (rewardEra + 1));
		epochCount = epochCount.add(1);
		//every so often, readjust difficulty. Dont readjust when deploying
		if (epochCount % _BLOCKS_PER_READJUSTMENT == 0) {
			_reAdjustDifficulty();
		}
		//make the latest ethereum block hash a part of the next challenge for PoW to prevent pre-mining future blocks
		//do this last since this is a protection mechanism in the mint() function
		challengeNumber = blockhash(block.number - 1);
	}
	//https://en.bitcoin.it/wiki/Difficulty#What_is_the_formula_for_difficulty.3F
	//as of 2017 the bitcoin difficulty was up to 17 zeroes, it was only 8 in the early days
	//readjust the target by 5 percent
	function _reAdjustDifficulty() internal {
		uint ethBlocksSinceLastDifficultyPeriod = block.number - latestDifficultyPeriodStarted;
		//assume 360 ethereum blocks per hour
		//we want miners to spend 10 minutes to mine each 'block', about 60 ethereum blocks = one 0xbitcoin epoch
		uint epochsMined = _BLOCKS_PER_READJUSTMENT; //256
		uint targetEthBlocksPerDiffPeriod = epochsMined * 60; //should be 60 times slower than ethereum
		//if there were less eth blocks passed in time than expected
		if (ethBlocksSinceLastDifficultyPeriod < targetEthBlocksPerDiffPeriod) {
			uint excess_block_pct = (targetEthBlocksPerDiffPeriod.mul(100)).div(ethBlocksSinceLastDifficultyPeriod);
			uint excess_block_pct_extra = excess_block_pct.sub(100).limitLessThan(1000);
			// If there were 5% more blocks mined than expected then this is 5.  If there were 100% more blocks mined than expected then this is 100.
			//make it harder
			miningTarget = miningTarget.sub(miningTarget.div(2000).mul(excess_block_pct_extra)); //by up to 50 %
		} else {
			uint shortage_block_pct = (ethBlocksSinceLastDifficultyPeriod.mul(100)).div(targetEthBlocksPerDiffPeriod);
			uint shortage_block_pct_extra = shortage_block_pct.sub(100).limitLessThan(1000); //always between 0 and 1000
			//make it easier
			miningTarget = miningTarget.add(miningTarget.div(2000).mul(shortage_block_pct_extra)); //by up to 50 %
		}
		latestDifficultyPeriodStarted = block.number;
		if (miningTarget < _MINIMUM_TARGET) //very difficult
		{
			miningTarget = _MINIMUM_TARGET;
		}
		if (miningTarget > _MAXIMUM_TARGET) //very easy
		{
			miningTarget = _MAXIMUM_TARGET;
		}
	}
	//this is a recent ethereum block hash, used to prevent pre-mining future blocks
	function getChallengeNumber() public returns(bytes32) {
		return challengeNumber;
	}
	//the number of zeroes the digest of the PoW solution requires.  Auto adjusts
	function getMiningDifficulty() public returns(uint) {
		return _MAXIMUM_TARGET.div(miningTarget);
	}

	function getMiningTarget() public returns(uint) {
		return miningTarget;
	}
	//21m coins total
	//reward begins at 50 and is cut in half every reward era (as tokens are mined)
	function getMiningReward() public returns(uint) {
		//once we get half way thru the coins, only get 25 per block
		//every reward era, the reward amount halves.
		return (50 * 10 ** uint(decimals)).div(2 ** rewardEra);
	}
	//help debug mining software
	function getMintDigest(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number) public view returns(bytes32 digesttest) {
		bytes32 digest = keccak256(abi.encodePacked(challenge_number, msg.sender, nonce));
		return digest;
	}
	//help debug mining software
	function checkMintSolution(uint256 nonce, bytes32 challenge_digest, bytes32 challenge_number, uint testTarget) public view returns(bool success) {
		bytes32 digest = keccak256(abi.encodePacked(challenge_number, msg.sender, nonce));
		if (uint256(digest) > testTarget) revert();
		return (digest == challenge_digest);
	}
		function totalSupply() public view returns(uint) {
		return _totalSupply - balances[address(0)];
	}
}
