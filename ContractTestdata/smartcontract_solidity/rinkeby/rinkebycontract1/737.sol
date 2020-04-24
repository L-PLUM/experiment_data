/**
 *Submitted for verification at Etherscan.io on 2019-02-08
*/

pragma solidity ^0.5.0;

// File: /home/mohammad/Dev/block_chain/projects/final-project-moahelmy/contracts/Owned.sol

/**
    @author moahelmy
    @title owned contract to save contract creator. will be inherited by other contracts
*/
contract Owned {
    address public owner;
    constructor() public {
        owner = msg.sender;
    }

    /* modifier to verify the caller is contract owner */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can access this");
        _;
    }
}

// File: /home/mohammad/Dev/block_chain/projects/final-project-moahelmy/contracts/Admin.sol

/**
    @author moahelmy
    @title Admin managers
*/ 
contract Admin is Owned {
    mapping(address => bool) admins;
    
    /* modifier to verify caller is admin */
    modifier onlyAdmin() {
        require(isAdmin(msg.sender), "Only admin can access this");
        _;
    }

    /**
        Events to monitor adding/removing admins
     */
    event AdminAdded(address indexed admin);
    event AdminRemoved(address indexed admin);

    constructor() public {
        admins[msg.sender] = true;
    }

    /**
        @notice Add new admin. only admin can call it
        @param _admin address of new admin to be added
        @return success flag
     */
    function addAdmin(address _admin)
        public
        onlyAdmin
        returns(bool)
    {
        require(admins[_admin] == false, "Already admin");
        admins[_admin] = true;
        emit AdminAdded(_admin);
        return true;
    }

    /**
        @notice Remove existing admin. only owner can call it
        @param _admin address of admin to be removed
        @return success flag
     */
    function removeAdmin(address _admin)
        public
        onlyOwner
        returns(bool)
    {
        require(admins[_admin] == true, "Not admin");
        admins[_admin] = false;        
        emit AdminRemoved(_admin);
        return true;
    }

    /**
        @notice Check if user is admin        
        @param user address of user to be checked
     */
    function isAdmin(address user)
        public
        view
        returns(bool)
    {
        return admins[user];
    }
}

// File: /home/mohammad/Dev/block_chain/projects/final-project-moahelmy/contracts/CircuitBreaker.sol

/**
    @author moahelmy
    @title Allow derived contract to implement circuit breaker pattern
*/
contract CircuitBreaker is Owned {
    
    bool private stopped = false;

    /**
        stops functionality in emergency
     */     
    modifier stopInEmergency { require (!stopped); _; }

    /**
        only functionality working in emergency
     */
    modifier onlyInEmergency { require (stopped); _; }

    function toggle() 
        public
        onlyOwner()
    {
        stopped = !stopped;
    }
}

// File: /home/mohammad/Dev/block_chain/projects/final-project-moahelmy/contracts/SimpleBank.sol

/*
    Simple Bank copied from excercise to manage balance and apply withrawal pattern
    A new method to transfer balance will be added    
*/

pragma solidity ^0.5.0;

contract SimpleBank {

    //
    // State variables
    //
    
    /* Fill in the keyword. Hint: We want to protect our users balance from other contracts*/
    mapping (address => uint) private balances;
    
    /* Fill in the keyword. We want to create a getter function and allow contracts to be able to see if a user is enrolled.  */
    mapping (address => bool) public enrolled;

    /* Let's make sure everyone knows who owns the bank. Use the appropriate keyword for this*/
    address public owner;
    
    //
    // Events - publicize actions to external listeners
    //
    
    /* Add an argument for this event, an accountAddress */
    event LogEnrolled(address indexed accountAddress);

    /* Add 2 arguments for this event, an accountAddress and an amount */
    event LogDepositMade(address indexed accountAddress, uint indexed amount);

    /* Create an event called LogWithdrawal */
    /* Add 3 arguments for this event, an accountAddress, withdrawAmount and a newBalance */
    event LogWithdrawal(address indexed accountAddress, uint indexed withdrawAmount, uint indexed newBalance);

    /* transfer money from account to another */
    event LogTransferDone(address indexed from, address indexed to, uint amount, uint fromBalance, uint toBalance);

    //
    // Functions
    //

    /* Use the appropriate global variable to get the sender of the transaction */
    constructor() public {
        /* Set the owner to the creator of this contract */
        owner = msg.sender;
    }

    /// @notice Get balance
    /// @return The balance of the user
    // A SPECIAL KEYWORD prevents function from editing state variables;
    // allows function to run locally/off blockchain
    function balance() public view returns (uint) {
        /* Get the balance of the sender of this transaction */
        require(enrolled[msg.sender], "user not entrolled");
        return balances[msg.sender];
    }

    /// @notice Enroll a customer with the bank
    /// @return The users enrolled status
    // Emit the appropriate event
    function enroll() public returns (bool){        
        return enroll(msg.sender);
    }

    /// @notice Enroll a customer with the bank (address passed)
    /// @return The users enrolled status
    // Emit the appropriate event
    function enroll(address _newMember)
        internal
        returns(bool)
    {
        if(!enrolled[_newMember]) {
            enrolled[_newMember] = true;
            balances[_newMember] = 0;
            emit LogEnrolled(_newMember);
            return true;
        }
        return false;
    }

    /// @notice transfer from account to another    
    /// @param from from account
    /// @param to to account    
    function transfer(address from, address to, uint amount)
        public
    {
        require(enrolled[from], "from not enrolled");
        require(enrolled[to], "to not enrolled");
        uint fromNewBalance = balances[from] - amount;
        require(fromNewBalance >= 0, "insufficient balance");
        uint toNewBalance = amount + balances[to];
        require(toNewBalance > 0, "integer overflow");        
        balances[from] = fromNewBalance;
        balances[to] = toNewBalance;
        emit LogTransferDone(from, to, amount, fromNewBalance, toNewBalance);        
    }

    /// @notice Deposit ether into bank
    /// @return The balance of the user after the deposit is made
    // Add the appropriate keyword so that this function can receive ether
    // Use the appropriate global variables to get the transaction sender and value
    // Emit the appropriate event    
    function deposit() public payable returns (uint) {
        /* Add the amount to the user's balance, call the event associated with a deposit,
          then return the balance of the user */
        require(enrolled[msg.sender], "user not enrolled");
        require(msg.value > 0, "amount must be positive");
        uint newBalance = msg.value + balances[msg.sender];
        require(newBalance > 0, "integer overflow");
        balances[msg.sender] = newBalance;
        emit LogDepositMade(msg.sender, msg.value);
        return newBalance;
    }

    /// @notice Withdraw ether from bank
    /// @dev This does not return any excess ether sent to it
    /// @param withdrawAmount amount you want to withdraw
    /// @return The balance remaining for the user
    // Emit the appropriate event    
    function withdraw(uint withdrawAmount) public returns (uint) {
        /* If the sender's balance is at least the amount they want to withdraw,
           Subtract the amount from the sender's balance, and try to send that amount of ether
           to the user attempting to withdraw. 
           return the user's balance.*/
        require(enrolled[msg.sender], "user not entrolled");
        require(withdrawAmount > 0 && withdrawAmount <= balances[msg.sender], "insufficient fund");
        uint newBalance = balances[msg.sender] - withdrawAmount;
        balances[msg.sender] = newBalance;
        msg.sender.transfer(withdrawAmount);
        emit LogWithdrawal(msg.sender, withdrawAmount, newBalance);
        return newBalance;
    }

    // Fallback function - Called if other functions don't match call or
    // sent ether without data
    // Typically, called when invalid data is sent
    // Added so ether sent to this contract is reverted if the contract fails
    // otherwise, the sender's money is transferred to contract
    function() external {
        revert();
    }
}

// File: /home/mohammad/Dev/block_chain/projects/final-project-moahelmy/contracts/BountyNestStorage.sol

/**
    @author moahelmy
    @title used to store data for bounty nest
 */
contract BountyNestStorage is Owned, CircuitBreaker {
    /**
        Bounty List
    */    
    uint bountiesCount;
    /// actuall list of bounties that will be looked up
    mapping(uint => Bounty) bountyList;        
    /// contains bouties grouped by poster
    mapping(address => uint[]) myBounties;

    /**
        Submissions
     */
    uint submissionsCount;
    /// list of submissions
    mapping(uint => Submission) submissions;
    /// group submissions by bounty hunters
    mapping(address => uint[]) mySubmissions;    

    /// enum to track state of bounty
    enum BountyState { Open, Closed, Resolved }

    struct Bounty {
        uint id;
        string description;
        address poster;
        uint reward;
        BountyState state;
        uint accepted;
        uint[] submissions;
    }

    /// enum to track state of submission
    enum SubmissionState { Pending, Accepted, Rejected }
    struct Submission {
        uint id;
        uint bountyId;        
        string resolution;
        address submitter;
        SubmissionState state;
    }

    /**
        @notice modifier to check if bounty exists
        @param bountyId id of bounty
     */
    modifier bountyExists(uint bountyId)
    {
        require(bountyList[bountyId].id == bountyId, "not exists");
        _;
    }

    /**
        @notice modifier to check if submission exists
        @param id id of submission
     */
    modifier submissionExists(uint id)
    {
        require(submissions[id].id == id, "not exists");
        _;
    }

    constructor () public {
        bountiesCount = 0;
        submissionsCount = 0;
    }

    /**
        @notice add new bounty to storage
        @param _description the description of bounty
        @param _reward the reward to be paid
     */
    function addBounty(address poster, string memory _description, uint _reward)
        public
        stopInEmergency()
        returns(uint bountyId)
    {
        bountyId = ++bountiesCount;
        bountyList[bountyId] = Bounty({
            id: bountyId,
            description: _description,
            reward: _reward,
            state: BountyState.Open,
            poster: poster,
            accepted: 0,
            submissions: new uint[](0)
        });        
        myBounties[poster].push(bountyId);        
    }

    /**
        @notice mark bounty as closed
        @param bountyId id of bounty
     */
    function closeBounty(uint bountyId) public
    {
        bountyList[bountyId].state = BountyState.Closed;
    }

    /**
        @notice mark bounty as resolved
        @param bountyId id of bounty
     */
    function markAsResolved(uint bountyId) public
    {
        bountyList[bountyId].state = BountyState.Resolved;        
    }

    /**
        @notice set the accepted submission for bounty
        @param bountyId id of bounty
        @param acceptedSubmission the accepted submission id
     */
    function setAcceptedSubmission(uint bountyId, uint acceptedSubmission) public
    {
        bountyList[bountyId].accepted = acceptedSubmission;
    }

    /**
        @notice Add new submission
        @param bountyId id of related bounty
        @param resolution submission itself
        @return the id of the created submission
     */
    function addSubmission(uint bountyId, string memory resolution)
        public
        stopInEmergency()
        returns(uint submissionId)
    {
        submissionId = ++submissionsCount;
        submissions[submissionId] = Submission({
            id: submissionId,
            bountyId: bountyId,
            resolution: resolution,
            submitter: msg.sender,
            state: SubmissionState.Pending
        });
        mySubmissions[msg.sender].push(submissionId);
        bountyList[bountyId].submissions.push(submissionId);       
    }

    /**
        @notice mark submission as accepted
        @param submissionId id of submission
     */
    function markAsAccepted(uint submissionId) public
    {
        submissions[submissionId].state = SubmissionState.Accepted;
    }

    /**
        @notice mark submission as rejected
        @param submissionId id of submission
     */
    function markAsRejected(uint submissionId) public
    {
        submissions[submissionId].state = SubmissionState.Rejected;
    }

    /**
        @notice List all bounties listed by sender
     */
    function listMyBounties(address poster)
        public
        view        
        returns(uint[] memory bounties)
    {
        return myBounties[poster];
    }

    /**
        @notice List all submissions listed by sender
     */
    function listMySubmissions(address hunter)
        public
        view
        returns(uint[] memory bounties)
    {
        return mySubmissions[hunter];
    }

    /**
        @notice fetch bounty information
        @param bountyId id of bounty
     */
    function fetchBounty(uint bountyId)
        public
        view
        bountyExists(bountyId)
        returns(string memory desc, uint reward, address poster, uint state, uint[] memory _submissions)
    {
        Bounty memory bounty = bountyList[bountyId];        
        desc = bounty.description;
        reward = bounty.reward;
        poster = bounty.poster;
        if (bounty.state == BountyState.Open) {
            state = 1;
        }
        if (bounty.state == BountyState.Closed) {
            state = 2;
        }
        if (bounty.state == BountyState.Resolved) {
            state = 3;
        }
        _submissions = bounty.submissions;        
    }

    /**
        @notice fetch submission information
        @param submissionId id of submission
     */
    function fetchSubmission(uint submissionId)
        public
        view
        submissionExists(submissionId)
        returns(uint bountyId, string memory resolution, address submitter, uint state)
    {
        Submission memory submission = submissions[submissionId];        
        bountyId = submission.bountyId;
        resolution = submission.resolution;
        submitter = submission.submitter;
        if (submission.state == SubmissionState.Pending) {
            state = 1;
        }
        if (submission.state == SubmissionState.Accepted) {
            state = 2;
        }
        if (submission.state == SubmissionState.Rejected) {
            state = 3;
        }        
    }

    /**
        @notice returns count of bounties
     */
    function getCount()
        public
        view
        returns(uint)
    {
        return bountiesCount;
    }
}

// File: contracts/BountyNest.sol

/**
    @author moahelmy
    @title manage bounties contract
 */
contract BountyNest is Admin, CircuitBreaker, SimpleBank
{
    BountyNestStorage private bnStorage;

    /**
        Events to track amendement of bounties states
     */    
    event Opened(uint indexed bountyId);
    event Closed(uint indexed bountyId);
    event Resolved(uint indexed bountyId);

    /**
        Events to track modifications of submissions
     */
    event SubmissionAdded(uint indexed bountyId, uint indexed submissionId);
    event SubmissionAccepted(uint indexed submissionId, uint indexed bountyId);
    event SubmissionRejected(uint indexed submissionId, uint indexed bountyId);

    /**
        modifier to confirm that the caller is bounty poster
     */
    modifier onlyPoster(uint bountyId)
    {
        require(getPoster(bountyId) == msg.sender, "not poster");
        _;
    }
    /**
        modifier to confirm that paid amound less than value
     */
    modifier paidEnough(uint _reward) {
        require(msg.value >= _reward, "not enough"); 
        _;
    }    
    /**
        modifier to confirms if bounty still open
     */
    modifier opened(uint bountyId)
    {
        require(isOpen(bountyId), "bounty is not open");
        _;
    }    
    /**
        modifer to confirm that submission still open
     */
    modifier pending(uint submissionId)
    {
        require(isPending(submissionId), "submission is not pending");
        _;
    }

    /**
        check if caller not address(0)
     */
    modifier validSender()
    {
        require(msg.sender != address(0), "not valid sender");
        _;
    }    

    constructor (address _externalStorage) public
    {
        bnStorage = BountyNestStorage(_externalStorage);
        // enroll contract itself into the simple bank to hold deposit sent by job posters
        enroll(address(this));
    }

    /**
        @notice Add new bounty.
        @param _description details of the bounty.
        @param _reward reward to who gonna resolve it. must be gt zero and lt msg.value
        @return the bounty id to be used in further interactions.
     */
    function add(string memory _description, uint _reward)
        public
        payable
        stopInEmergency()
        validSender()
        paidEnough(_reward)        
        returns(uint bountyId)
    {
        require(_reward > 0, "reward can not be zero");
        bountyId = bnStorage.addBounty(msg.sender, _description, _reward);
        emit Opened(bountyId);
        enroll(msg.sender);
        deposit();
        transfer(msg.sender, address(this), _reward);        
    }

    /**
        @notice Close existing bounty by poster
        @param bountyId id of bounty to get closed
     */
    function close(uint bountyId)
        public
        onlyPoster(bountyId)
        opened(bountyId)
        returns(bool)
    {
        bnStorage.closeBounty(bountyId);             
        emit Closed(bountyId);
        (,uint reward,address poster,,) = bnStorage.fetchBounty(bountyId);
        transfer(address(this), poster, reward);
        return true;
    }

    /**
        @notice Add new submission to existing bounty
        @param bountyId id of related bounty
        @param resolution submission itself
        @return the id of the created submission
     */
    function submit(uint bountyId, string memory resolution)
        public
        stopInEmergency()
        validSender()
        opened(bountyId)
        returns(uint submissionId)
    {
        submissionId = bnStorage.addSubmission(bountyId, resolution);
        emit SubmissionAdded(bountyId, submissionId);
    }

    /**
        @notice Accept submission by bounty poster
        @dev it uses inherited simple bank to manager payments
        @param submissionId id of submission to be accepted
     */
    function accept(uint submissionId)
        public
        stopInEmergency()        
        pending(submissionId)        
    {
        (uint bountyId,,address submitter,) = bnStorage.fetchSubmission(submissionId);
        (,uint reward,address poster,,) = bnStorage.fetchBounty(bountyId);
        require(isOpen(bountyId));
        require(poster == msg.sender);
        bnStorage.markAsResolved(bountyId);
        bnStorage.setAcceptedSubmission(bountyId, submissionId);
        bnStorage.markAsAccepted(submissionId);        
        enroll(submitter);
        transfer(address(this), submitter, reward);
        emit SubmissionAccepted(submissionId, bountyId);
    }

    /**
        @notice Reject submission by bounty poster
        @dev it uses inherited simple bank to manager payments
        @param submissionId id of submission to be rejected
     */
    function reject(uint submissionId)
        public
        pending(submissionId)
    {
        (uint bountyId,,,) = bnStorage.fetchSubmission(submissionId);
        (,,address poster,,) = bnStorage.fetchBounty(bountyId);
        require(isOpen(bountyId));
        require(poster == msg.sender);                
        bnStorage.markAsRejected(submissionId);                
        emit SubmissionRejected(submissionId, bountyId);
    }

    /**
        @notice List all bounties listed by sender
     */
    function listMyBounties()
        public
        view
        validSender()
        returns(uint[] memory bounties)
    {
        return bnStorage.listMyBounties(msg.sender);
    }

    /**
        @notice List all submissions listed by sender
     */
    function listMySubmissions()
        public
        view
        validSender()        
        returns(uint[] memory bounties)
    {
        return bnStorage.listMySubmissions(msg.sender);
    }

    /**
        @notice fetch bounty information
        @param bountyId id of bounty
     */
    function fetchBounty(uint bountyId)
        public
        view
        returns(string memory desc, uint reward, address poster, uint state, uint[] memory submissions)
    {
        return bnStorage.fetchBounty(bountyId);
    }

    /**
        @notice fetch submission information
        @param submissionId id of submission
     */
    function fetchSubmission(uint submissionId)
        public
        view        
        returns(uint bountyId, string memory resolution, address submitter, uint state)
    {
        return bnStorage.fetchSubmission(submissionId);        
    }

    /**
        @notice get bounties count    
     */
    function bountiesCount()
        public
        view
        returns(uint)
    {
        return bnStorage.getCount();
    }

    /**
        Debutes to be coded later. It's the reason why admin contract is coded so that admins only
        can resolve debutes
     */
    /*
    function createDepute(uint submissionId, string memory description)
        public
        returns(uint deputeId)
    {
    }

    function resolveDepute(uint id, bool isPostRight, bool isBountyHunterRight, string memory comment)
        public
        returns(bool success)
    {        
    }*/

    /**
        Enroll should not be supported. Better to use a new base class that only allow withdraw if have time.
     */
    function enroll() public returns (bool){
        return false;
    }

    function getPoster(uint bountyId) 
        internal
        view
        returns(address) {
        (,,address poster,,) = bnStorage.fetchBounty(bountyId);
        return poster;
    }

    /**
        These functions to check status of bounty and submission. used more by tests
        they will be deleted in the future
        no need to expose internal state
     */
    function isOpen(uint bountyId)
        public
        view        
        returns(bool)
    {
        (,,,uint state,) = bnStorage.fetchBounty(bountyId);
        return state == 1;
    }

    function isClosed(uint bountyId)
        public
        view 
        returns(bool)
    {
        (,,,uint state,) = bnStorage.fetchBounty(bountyId);
        return state == 2;
    }

    function isResolved(uint bountyId)
        public
        view        
        returns(bool)
    {
        (,,,uint state,) = bnStorage.fetchBounty(bountyId);
        return state == 3;
    }

    function isPending(uint submissionId)
        public
        view        
        returns(bool)
    {
        (,,,uint state) = bnStorage.fetchSubmission(submissionId);
        return state == 1;
    }

    function isAccepted(uint submissionId)
        public
        view        
        returns(bool)
    {
        (,,,uint state) = bnStorage.fetchSubmission(submissionId);
        return state == 2;
    }

    function isRejected(uint submissionId)
        public
        view        
        returns(bool)
    {
        (,,,uint state) = bnStorage.fetchSubmission(submissionId);
        return state == 3;
    }
}
