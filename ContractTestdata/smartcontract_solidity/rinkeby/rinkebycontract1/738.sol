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

// File: contracts/BountyNestStorage.sol

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
