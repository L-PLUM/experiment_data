/**
 *Submitted for verification at Etherscan.io on 2019-08-10
*/

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/QuadraticPoll.sol

pragma solidity ^0.5.0;



/// @title Quadratic Voting
/// @author Johns Beharry
/// @notice Please don't use this contract in an actual democratic election.
contract QuadraticPoll is Ownable {
	using SafeMath for uint256;

	bool private stopped;
	uint256 public issueCount;

	// constants
	uint256 constant STARTING_CREDIT = 16;
	uint256 constant TOTAL_SUPPLY = 1024;

	enum Status {
		UNKNOWN,
		REGISTERED
	}

	struct Issue {
		string title;
		uint256 credits;
	}

	struct Voter {
		Status status;
		uint256 credits;
		uint256 count;
		mapping(uint256 => Issue) votes;
	}

	mapping(address => Voter) public voters;
	mapping(uint256 => Issue) public issues;

	event IssueAdded(
		string _name,
		address creator
	);

	event Voted(
		uint256 _issueId,
		uint256 cost,
		address _voter
	);

	// Rejects if contract has been stopped
	modifier stopInEmergency {
		require(!stopped, "Democracy has stopped...");
		_;
	}

	// Check if a voter has been registered
	modifier isRegistered() {
		require(voters[msg.sender].status == Status.REGISTERED);
		_;
	}

	constructor()
	public {
		stopped = false;
		issueCount = 0;
		newIssue('The development of domestic institutions');
		newIssue('The representatives in the international sphere');
		newIssue('Inclusion Caribbean nations in the African Union');
	}

	/// Create a new issue
	/// @param _title The name of the issue
	/// @return id of the issue
	function newIssue(string memory _title)
	public
	stopInEmergency
	returns (uint256) {
		issueCount = issueCount + 1;
		issues[issueCount].title = _title;
		issues[issueCount].credits = 0;
		emit IssueAdded(_title, msg.sender);
		return issueCount;
	}

	/// Get an new issue
	/// @param _issueId The name of the issue
	/// @return title ofv the issue
	function getIssue(uint256 _issueId)
	external
	view
	returns (uint256, string memory, uint256) {
		return(_issueId, issues[_issueId].title, issues[_issueId].credits);
	}

	/// Get an new issue
	/// @param _issueId The name of the issue
	/// @return title ofv the issue
	function vote(
		uint256 _issueId,
		uint256 _votes
	)
	external
	stopInEmergency
	isRegistered
	returns (uint256)
	{
		uint256 cost = _votes.mul(_votes);

		require(cost <= TOTAL_SUPPLY); // so we can mitigate an overflow error with user input
		require(voters[msg.sender].credits >= cost); // voter has enough credits 

		voters[msg.sender].count += 1;
		voters[msg.sender].credits = voters[msg.sender].credits.sub(cost);
		issues[_issueId].credits = issues[_issueId].credits.add(cost);

		emit Voted(_issueId, cost, msg.sender);
	}

	/// Allocate credits to new voters
	/// @return title of the issue
	function register()
	external
	stopInEmergency
	returns (bool)
	{
		if(voters[msg.sender].count == 0) {
			voters[msg.sender].credits = STARTING_CREDIT;
			voters[msg.sender].status = Status.REGISTERED;
		}
	}

	/// Circuit Breaker for emergancy stopping of democracy. Use carefully
	function toggleContractActive()
	public
	onlyOwner
	{
		stopped = !stopped;
	}

}
