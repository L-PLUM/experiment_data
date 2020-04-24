/**
 *Submitted for verification at Etherscan.io on 2019-07-25
*/

pragma solidity >=0.4.22 <0.6.0;

contract ElectionContract
{
    address payable owner;
    mapping(address => bool) adminAddress;
    uint electionCount;
    //Start date tolerance in seconds
    uint startDateTolerance;
    mapping(uint => Election) elections;
    
    //Election => Position => Address => isVoted
    mapping(uint => mapping(uint => mapping(address => Vote))) electionVotes;
    
    //Election => Address => isRegistered
    mapping(uint => mapping(address => bool)) electionRegistrations;
    
    event electionCreated(uint _electionId);
    event positionCreated(uint _positionId);
    event nomineeCreated(uint _nomineeId);
    event voteReceived(address indexed _address, uint indexed _electionId, uint indexed _positionId, ElectionType _electionType, bytes32 _choiceHash);
    
    //Public = 0 (means no secret), Private = 1 (will reveal secret at the end)
    enum ElectionType
    {
        PUBLIC,
        PRIVATE
    }
    
    struct Election
    {
        address electionOwner;
        bool exist;
        string title;
        uint positionCount;
        ElectionType electionType;
        string secret;
        uint startDate;
        uint endDate;
        mapping(uint => Position) positions;
    }
    
    struct Position
    {
        bool exist;
        string description;
        uint nomineeCount;
        mapping(uint => Nominee) nominees;
        bytes32[] votes;
    }
    
    struct Nominee
    {
        bool exist;
        string identifier;
    }
    
    struct Vote
    {
        bool voted;
        bytes32 choiceHash;
    }
    
    modifier ownerOnly 
    {
        require(msg.sender == owner);
        _;
    }
    
    modifier adminOnly 
    {
        require(adminAddress[msg.sender] == true);
        _;
    }
    
    function kill() public ownerOnly
    {
        selfdestruct(owner);
    }
    
    constructor() public
    {
        electionCount = 0;
        startDateTolerance = 6;
        owner = msg.sender;
        adminAddress[msg.sender] = true;
    }
    
    function addAdmin(address _address) public adminOnly
    {
        adminAddress[_address] = true;
    }
    
    function isAdmin(address _address) public view returns (bool isAdmin_)
    {
        isAdmin_ = adminAddress[_address];
    }
    
    function getElectionVoteChoiceHash(uint _electionId, uint _positionId, address _address) public view returns (bytes32 choiceHash_)
    {
        choiceHash_ = electionVotes[_electionId][_positionId][_address].choiceHash;
    }
    
    function addElection(string memory _title, ElectionType _electionType, uint _startDate, uint _endDate, uint _electionId) public adminOnly returns (uint electionId_)
    {
        require(_endDate > _startDate, "End date is before start date");
        require(elections[_electionId].exist == false, "This election exists");
        electionCount++;
        elections[_electionId] = Election(msg.sender, true, _title, 0, _electionType, "", _startDate, _endDate);
        electionId_ = _electionId;
        
        //Emit event
        emit electionCreated(_electionId);
    }
    
    function updateElection(uint _electionId, string memory _secret) public adminOnly 
    {
        require(elections[_electionId].electionOwner == msg.sender, "You must be election owner to do this.");
        elections[_electionId].secret = _secret;
    }
    
    function addPosition(uint _electionId, string memory _description, uint _positionId) public adminOnly returns (uint positionId_)
    {
        require(elections[_electionId].electionOwner == msg.sender, "You must be election owner to do this.");
        
        Election storage election = elections[_electionId];
        
        require(election.positions[_positionId].exist == false, "This position exists");
        
        election.positionCount++;
        election.positions[_positionId] = Position(true, _description, 0, new bytes32[](0));
        positionId_ = _positionId;
        
        //emit event
        emit positionCreated(_positionId);
    }
    
    function addNominee(uint _electionId, uint _positionId, string memory _identifier, uint _nomineeId) public adminOnly returns (uint nomineeId_) 
    {
        require(elections[_electionId].electionOwner == msg.sender, "You must be election owner to do this.");
        Position storage position = elections[_electionId].positions[_positionId];
        
        require(position.nominees[_nomineeId].exist == false);
        
        position.nomineeCount++;
        position.nominees[_nomineeId] = Nominee(true, _identifier);
        nomineeId_ = _nomineeId;
        
        //emit event
        emit nomineeCreated(_nomineeId);
    }
    
    function registerVoter(uint _electionId, address _address) public adminOnly
    {
        require(elections[_electionId].electionOwner == msg.sender, "You must be election owner to do this.");
        electionRegistrations[_electionId][_address] = true;
    }
    
    function isRegistered(uint _electionId, address _address) public view returns (bool isRegistered_)
    {
        isRegistered_ = electionRegistrations[_electionId][_address];
    }
    
    function isVoted(uint _electionId, uint _positionId, address _address) public view returns (bool isVoted_)
    {
        isVoted_ = electionVotes[_electionId][_positionId][_address].voted;
    }
    
    function getElection(uint _electionId) public view returns (address owner_, 
                                                                string memory title_, 
                                                                uint positionCount_, 
                                                                ElectionType electionType_,
                                                                string memory secret_,
                                                                uint startDate_,
                                                                uint endDate_)
    {
        owner_ = elections[_electionId].electionOwner;
        title_ = elections[_electionId].title;
        positionCount_ = elections[_electionId].positionCount;
        electionType_ = elections[_electionId].electionType;
        secret_ = elections[_electionId].secret;
        startDate_ = elections[_electionId].startDate;
        endDate_ = elections[_electionId].endDate;
    }
    
    function getPosition(uint _electionId, uint _positionId) public view returns (string memory description_,
                                                                                  uint nomineeCount_)
    {
        description_ = elections[_electionId].positions[_positionId].description;
        nomineeCount_ = elections[_electionId].positions[_positionId].nomineeCount;
    }
    
    function getPositionVotes(uint _electionId, uint _positionId, uint _skip, uint _take) public view returns (bytes32[] memory votes_)
    {
        votes_ = new bytes32[](_take);
        for(uint i = 0; i < _take; i++)
            votes_[i] = elections[_electionId].positions[_positionId].votes[i + _skip];
    }
    
    function getPositionVotesCount(uint _electionId, uint _positionId) public view returns (uint count_)
    {
        count_ = elections[_electionId].positions[_positionId].votes.length;
    }
    
    function getNominee(uint _electionId, uint _positionId, uint _nomineeId) public view returns (string memory identifier_)
    {
        identifier_ = elections[_electionId].positions[_positionId].nominees[_nomineeId].identifier;
    }
    
    //If the function return 0, means the hash is invalid or the secret is not public yet
    function decodeHash(uint _electionId, uint _positionId, uint _positionDepartmentId, address _address, bytes32 _choiceHash) public view returns (uint choice_)
    {
        choice_ = 0;
        Election storage election = elections[_electionId];
        Position storage position = elections[_electionId].positions[_positionId];
        
        //Formula to decode the infromation
        //Kecak(electionId + positionId + address + choice + secret)
        for(uint i = 1; i <= position.nomineeCount; i++)
        {
            bytes32 hashCombination = keccak256(abi.encodePacked(_electionId, _positionId, _positionDepartmentId, _address, i, election.secret));
            
            //Matched
            if(hashCombination == _choiceHash)
                choice_ = i;
        }
    }
    
    //Submit vote (r,s,v for the signature)
    function submitVote(uint _electionId, uint _positionId, bytes32 _choiceHash, address _address, bytes32 _r, bytes32 _s, uint8 _v) public adminOnly
    {
        require(elections[_electionId].electionOwner == msg.sender, "You must be election owner to do this.");
        Election storage election = elections[_electionId];
        require(now > (election.startDate - startDateTolerance), "Election is not started.");
        require(now < election.endDate, "Election is ended.");
        
        //Require this user is valid for this election
        require(electionRegistrations[_electionId][_address] == true);
        
        //Require non voted user only
        require(electionVotes[_electionId][_positionId][_address].voted == false);
        
        //Require user signed transaction
        require(recoverSigner(prefixed(_choiceHash), _v, _r, _s) == _address);
        
        //Set user to isVoted true
        electionVotes[_electionId][_positionId][_address].voted = true;
        electionVotes[_electionId][_positionId][_address].choiceHash = _choiceHash;
        elections[_electionId].positions[_positionId].votes.push(_choiceHash);
        
        //Emit event
        emit voteReceived(_address, _electionId, _positionId, election.electionType, _choiceHash);
    }
    
    function getChoiceHash(uint _electionId, uint _positionId, address _address) public view returns (bytes32 choiceHash_)
    {
        choiceHash_ = electionVotes[_electionId][_positionId][_address].choiceHash;
    }
    
    function recoverSigner(bytes32 message, uint8 v, bytes32 r, bytes32 s) internal pure returns (address)
    {
        return ecrecover(message, v, r, s);
    }
    
    // Builds a prefixed hash to mimic the behavior of eth_sign.
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
    
    function getBlockchainDate() public view returns (uint currentDate_)
    {
        currentDate_ = now;
    }
}
