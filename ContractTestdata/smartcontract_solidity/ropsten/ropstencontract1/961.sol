/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

/**
 * Congress contract for Blockcoach Community Shell
 * 
 * Author: Evan Liu ([email protected])
 * Release version: 0.2.0
 * Last revision date: 2019-02-11
 */
 pragma solidity >=0.4.22 <0.6.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
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

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

/**
 * @title Congress
 * NOTICE: this contract has many functions, lift Gas limit when deploy it!
 */
contract BCCongress {
    using SafeMath for uint;

    // public vars of congress members
    ERC20Interface public token;

    // struct proposals
    struct BudgetProposal {
        uint id; //starts from 1
        uint newBudget; //will be appended
        uint stakeFor;
        uint stakeAgainst;
    }

    struct OwnerProposal {
        uint id; //starts from 1
        address newOwner; //will be replaced with
        uint stakeFor;
        uint stakeAgainst;
    }

    struct CongressProposal {
        uint id; //starts from 1
        address newCongress; //will be replaced with
        uint stakeFor;
        uint stakeAgainst;
    }

    // proposal id for/against, used by voter
    struct ForAgainst {
        uint id; //proposalId
        bool votedFor; //true == For; false = Against; proposalId cleared = Abstain.
    }

    // struct voter and his/her votes
    struct Voter {
        uint stake; // BCS stake this voter put in this contract as voting weights

        ForAgainst budgetProposal;
        ForAgainst ownerProposal;
        ForAgainst congressProposal;
    }

    // public vars of proposals
    BudgetProposal public budgetProposal;
    OwnerProposal public ownerProposal;
    CongressProposal public congressProposal;

    // public vars of decisions
    uint256 public budgetApproved;
    address public ownerApproved;
    address public congressApproved;

    // congress members
    mapping(address => Voter) members;

    /*
     * specify which DAO this congress would work with.
     */
    constructor (address _token) public {
        token = ERC20Interface(_token);
    }

    function checkMemberStake(address _member) public view returns (uint256) {
        return members[_member].stake;
    }
    
    function checkTotalStake() public view returns (uint256) {
        return token.balanceOf(address(this));
    }
    
    /* check if there is still enough budget approved by the congress.
     * this function should be idempotent.
     */
    function isBudgetApproved(uint256 amount) public view returns (bool) {
        return (budgetApproved >= amount);
    }

    /* consume the approved budget, i.e. deduct the number.
     * CANNOT be internal. how to limit the consumer to token owner?
     */
    function consumeBudget(uint256 amount) public {
        require(msg.sender == address(token), "only minter can consume");
        require(budgetApproved >= amount, "not enough budget approved");
        budgetApproved = budgetApproved.sub(amount);
    }

    /* check if the specified new owner has been approved by the congress.
     * this function should be idempotent.
     */
    function isOwnerApproved(address newOwner) public view returns (bool) {
        require(newOwner != address(0), "non-empty owner required");
        return (ownerApproved == newOwner);
    }

    /* check if the specified new congress has been approved by the congress.
     * this function should be idempotent.
     */
    function isCongressApproved(address newCongress) public view returns (bool) {
        require(newCongress != address(0), "non-empty congress required");
        return (congressApproved == newCongress);
    }

    /* ****************************************************************** */
    /* anyone with stake can propose to be voted
     */
    function proposeNewBudget(uint256 _budget) public {
        require(_budget > 0, "cannot propose 0 budget");
        require(members[msg.sender].stake > 0, "only stakeholder can propose");

        require(budgetProposal.stakeFor == 0 && budgetProposal.stakeAgainst == 0, "current proposal is in progress");

        budgetProposal.id = budgetProposal.id.add(1);
        budgetProposal.newBudget = _budget;
    }

    function proposeNewOwner(address _owner) public {
        require(_owner != address(0), "cannot propose empty owner");
        require(members[msg.sender].stake > 0, "only stakeholder can propose");

        require(ownerProposal.stakeFor == 0 && ownerProposal.stakeAgainst == 0, "current proposal is in progress");

        ownerProposal.id = ownerProposal.id.add(1);
        ownerProposal.newOwner = _owner;
    }

    function proposeNewCongress(address _congress) public {
        require(_congress != address(0), "cannot propose empty congress");
        require(members[msg.sender].stake > 0, "only stakeholder can propose");

        require(congressProposal.stakeFor == 0 && congressProposal.stakeAgainst == 0, "current proposal is in progress");

        congressProposal.id = congressProposal.id.add(1);
        congressProposal.newCongress = _congress;
    }

    /* ****************************************************************** */
    /* congress member to deposit BCS as stake for voting weights.
     * MUST call token's approve(congress address, amount) first,
     * then call deposit to put stake in.
     */
    function deposit(uint256 amount) public {
        token.transferFrom(msg.sender, address(this), amount);
        members[msg.sender].stake = members[msg.sender].stake.add(amount);
    }

    function withdraw(uint256 amount) public {
        address m = msg.sender;
        require(amount <= members[m].stake, "not enough funds deposited");
        
        require(members[m].budgetProposal.id == 0, "cannot withdraw while voting on budget proposal");
        require(members[m].ownerProposal.id == 0, "cannot withdraw while voting on owner proposal");
        require(members[m].congressProposal.id == 0, "cannot withdraw while voting on congress proposal");
        
        members[m].stake = members[m].stake.sub(amount);
        token.transfer(m, amount);
    }

    /* ****************************************************************** */
    /* congress members to vote
     */
    function voteForNewBudget() public {
        require(budgetProposal.newBudget > 0, "invalid proposal"); // valid proposal exists to vote

        address m = msg.sender;
        require(members[m].budgetProposal.id != budgetProposal.id, "already voted"); //not yet voted

        members[m].budgetProposal.id = budgetProposal.id;
        members[m].budgetProposal.votedFor = true;
        
        budgetProposal.stakeFor = budgetProposal.stakeFor.add(members[m].stake);

        if (budgetProposal.stakeFor.mul(2) >= token.balanceOf(address(this))) {
            // win if >= 50% stakes support
            budgetApproved = budgetApproved.add(budgetProposal.newBudget);

            //clear votes
            budgetProposal.newBudget = 0;
            budgetProposal.stakeFor = 0;
            budgetProposal.stakeAgainst = 0;
        }
    }

    function voteAgainstNewBudget() public {
        require(budgetProposal.newBudget > 0, "invalid proposal"); // valid proposal exists to vote

        address m = msg.sender;
        require(members[m].budgetProposal.id != budgetProposal.id, "already voted"); //not yet voted

        members[m].budgetProposal.id = budgetProposal.id;
        members[m].budgetProposal.votedFor = false;

        budgetProposal.stakeAgainst = budgetProposal.stakeAgainst.add(members[m].stake);

        if (budgetProposal.stakeAgainst.mul(2) >= token.balanceOf(address(this))) {
            // win if >= 50% stakes support

            //clear votes
            budgetProposal.newBudget = 0;
            budgetProposal.stakeFor = 0;
            budgetProposal.stakeAgainst = 0;
        }
    }

    function clearVoteOnNewBudget() public {
        require(budgetProposal.newBudget > 0, "invalid proposal"); // valid proposal exists to vote

        address m = msg.sender;
        require(members[m].budgetProposal.id == budgetProposal.id, "should vote first"); //already voted

        members[m].budgetProposal.id = 0;
        if (members[m].budgetProposal.votedFor == true) {
            budgetProposal.stakeFor = budgetProposal.stakeFor.sub(members[m].stake);
        } else {
            budgetProposal.stakeAgainst = budgetProposal.stakeAgainst.sub(members[m].stake);
        }
    }

    function voteForNewOwner() public {
        require(ownerProposal.newOwner != address(0), "invalid proposal"); // valid proposal exists to vote

        address m = msg.sender;
        require(members[m].ownerProposal.id != ownerProposal.id, "already voted"); //not yet voted

        members[m].ownerProposal.id = ownerProposal.id;
        members[m].ownerProposal.votedFor = true;

        ownerProposal.stakeFor = ownerProposal.stakeFor.add(members[m].stake);

        if (ownerProposal.stakeFor.mul(2) >= token.balanceOf(address(this))) {
            // win if >= 50% stakes support
            ownerApproved = ownerProposal.newOwner;

            //clear votes
            ownerProposal.newOwner = address(0);
            ownerProposal.stakeFor = 0;
            ownerProposal.stakeAgainst = 0;
        }
    }

    function voteAgainstNewOwner() public {
        require(ownerProposal.newOwner != address(0), "invalid proposal"); // valid proposal exists to vote

        address m = msg.sender;
        require(members[m].ownerProposal.id != ownerProposal.id, "already voted"); //not yet voted

        members[m].ownerProposal.id = ownerProposal.id;
        members[m].ownerProposal.votedFor = false;

        ownerProposal.stakeAgainst = ownerProposal.stakeAgainst.add(members[m].stake);

        if (ownerProposal.stakeAgainst.mul(2) >= token.balanceOf(address(this))) {
            // win if >= 50% stakes support

            //clear votes
            ownerProposal.newOwner = address(0);
            ownerProposal.stakeFor = 0;
            ownerProposal.stakeAgainst = 0;
        }
    }

    function clearVoteOnNewOwner() public {
        require(ownerProposal.newOwner != address(0), "invalid proposal"); // valid proposal exists to vote

        address m = msg.sender;
        require(members[m].ownerProposal.id == ownerProposal.id, "should vote first"); //already voted

        members[m].ownerProposal.id = 0;
        if (members[m].ownerProposal.votedFor == true) {
            ownerProposal.stakeFor = ownerProposal.stakeFor.sub(members[m].stake);
        } else {
            ownerProposal.stakeAgainst = ownerProposal.stakeAgainst.sub(members[m].stake);
        }
    }

    function voteForNewCongress() public {
        require(congressProposal.newCongress != address(0), "invalid proposal"); // valid proposal exists to vote

        address m = msg.sender;
        require(members[m].congressProposal.id != congressProposal.id, "already voted"); //not yet voted

        members[m].congressProposal.id = congressProposal.id;
        members[m].congressProposal.votedFor = true;

        congressProposal.stakeFor = congressProposal.stakeFor.add(members[m].stake);

        if (congressProposal.stakeFor.mul(2) >= token.balanceOf(address(this))) {
            // win if >= 50% stakes support
            congressApproved = congressProposal.newCongress;

            //clear votes
            congressProposal.newCongress = address(0);
            congressProposal.stakeFor = 0;
            congressProposal.stakeAgainst = 0;
        }
    }

    function voteAgainstNewCongress() public {
        require(congressProposal.newCongress != address(0), "invalid proposal"); // valid proposal exists to vote

        address m = msg.sender;
        require(members[m].congressProposal.id != congressProposal.id, "already voted"); //not yet voted

        members[m].congressProposal.id = congressProposal.id;
        members[m].congressProposal.votedFor = false;

        congressProposal.stakeAgainst = congressProposal.stakeAgainst.add(members[m].stake);

        if (congressProposal.stakeAgainst.mul(2) >= token.balanceOf(address(this))) {
            // win if >= 50% stakes support

            //clear votes
            congressProposal.newCongress = address(0);
            congressProposal.stakeFor = 0;
            congressProposal.stakeAgainst = 0;
        }
    }

    function clearVoteOnNewCongress() public {
        require(congressProposal.newCongress != address(0), "invalid proposal"); // valid proposal exists to vote

        address m = msg.sender;
        require(members[m].congressProposal.id == congressProposal.id, "should vote first"); //already voted

        members[m].congressProposal.id = 0;
        if (members[m].congressProposal.votedFor == true) {
            congressProposal.stakeFor = congressProposal.stakeFor.sub(members[m].stake);
        } else {
            congressProposal.stakeAgainst = congressProposal.stakeAgainst.sub(members[m].stake);
        }
    }

}
