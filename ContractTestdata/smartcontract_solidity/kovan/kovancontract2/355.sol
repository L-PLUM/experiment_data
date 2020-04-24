/**
 *Submitted for verification at Etherscan.io on 2019-07-15
*/

/**
 *  @authors: []
 *  @reviewers: []
 *  @auditors: []
 *  @bounties: []
 *  @deployments: []
 */
/* solium-disable max-len*/
pragma solidity ^0.5.10;


/** @title IArbitrable
 *  Arbitrable interface.
 *  When developing arbitrable contracts, we need to:
 *  -Define the action taken when a ruling is received by the contract. We should do so in executeRuling.
 *  -Allow dispute creation. For this a function must:
 *      -Call arbitrator.createDispute.value(_fee)(_choices,_extraData);
 *      -Create the event Dispute(_arbitrator,_disputeID,_rulingOptions);
 */
interface IArbitrable {
    /** @dev To be emmited when meta-evidence is submitted.
     *  @param _metaEvidenceID Unique identifier of meta-evidence.
     *  @param _evidence A link to the meta-evidence JSON.
     */
    event MetaEvidence(uint indexed _metaEvidenceID, string _evidence);

    /** @dev To be emmited when a dispute is created to link the correct meta-evidence to the disputeID
     *  @param _arbitrator The arbitrator of the contract.
     *  @param _disputeID ID of the dispute in the Arbitrator contract.
     *  @param _metaEvidenceID Unique identifier of meta-evidence.
     *  @param _evidenceGroupID Unique identifier of the evidence group that is linked to this dispute.
     */
    event Dispute(Arbitrator indexed _arbitrator, uint indexed _disputeID, uint _metaEvidenceID, uint _evidenceGroupID);

    /** @dev To be raised when evidence are submitted. Should point to the ressource (evidences are not to be stored on chain due to gas considerations).
     *  @param _arbitrator The arbitrator of the contract.
     *  @param _evidenceGroupID Unique identifier of the evidence group the evidence belongs to.
     *  @param _party The address of the party submiting the evidence. Note that 0x0 refers to evidence not submitted by any party.
     *  @param _evidence A URI to the evidence JSON file whose name should be its keccak256 hash followed by .json.
     */
    event Evidence(Arbitrator indexed _arbitrator, uint indexed _evidenceGroupID, address indexed _party, string _evidence);

    /** @dev To be raised when a ruling is given.
     *  @param _arbitrator The arbitrator giving the ruling.
     *  @param _disputeID ID of the dispute in the Arbitrator contract.
     *  @param _ruling The ruling which was given.
     */
    event Ruling(Arbitrator indexed _arbitrator, uint indexed _disputeID, uint _ruling);

    /** @dev Give a ruling for a dispute. Must be called by the arbitrator.
     *  The purpose of this function is to ensure that the address calling it has the right to rule on the contract.
     *  @param _disputeID ID of the dispute in the Arbitrator contract.
     *  @param _ruling Ruling given by the arbitrator. Note that 0 is reserved for "Not able/wanting to make a decision".
     */
    function rule(uint _disputeID, uint _ruling) external;
}

/** @title Arbitrator
 *  Arbitrator abstract contract.
 *  When developing arbitrator contracts we need to:
 *  -Define the functions for dispute creation (createDispute) and appeal (appeal). Don't forget to store the arbitrated contract and the disputeID (which should be unique, use nbDisputes).
 *  -Define the functions for cost display (arbitrationCost and appealCost).
 *  -Allow giving rulings. For this a function must call arbitrable.rule(disputeID, ruling).
 */
contract Arbitrator {

    enum DisputeStatus {Waiting, Appealable, Solved}

    modifier requireArbitrationFee(bytes memory _extraData) {
        require(msg.value >= arbitrationCost(_extraData), "Not enough ETH to cover arbitration costs.");
        _;
    }
    modifier requireAppealFee(uint _disputeID, bytes memory _extraData) {
        require(msg.value >= appealCost(_disputeID, _extraData), "Not enough ETH to cover appeal costs.");
        _;
    }

    /** @dev To be raised when a dispute is created.
     *  @param _disputeID ID of the dispute.
     *  @param _arbitrable The contract which created the dispute.
     */
    event DisputeCreation(uint indexed _disputeID, IArbitrable indexed _arbitrable);

    /** @dev To be raised when a dispute can be appealed.
     *  @param _disputeID ID of the dispute.
     */
    event AppealPossible(uint indexed _disputeID, IArbitrable indexed _arbitrable);

    /** @dev To be raised when the current ruling is appealed.
     *  @param _disputeID ID of the dispute.
     *  @param _arbitrable The contract which created the dispute.
     */
    event AppealDecision(uint indexed _disputeID, IArbitrable indexed _arbitrable);

    /** @dev Create a dispute. Must be called by the arbitrable contract.
     *  Must be paid at least arbitrationCost(_extraData).
     *  @param _choices Amount of choices the arbitrator can make in this dispute.
     *  @param _extraData Can be used to give additional info on the dispute to be created.
     *  @return disputeID ID of the dispute created.
     */
    function createDispute(uint _choices, bytes memory _extraData) public requireArbitrationFee(_extraData) payable returns (uint disputeID) {}

    /** @dev Compute the cost of arbitration. It is recommended not to increase it often, as it can be highly time and gas consuming for the arbitrated contracts to cope with fee augmentation.
     *  @param _extraData Can be used to give additional info on the dispute to be created.
     *  @return fee Amount to be paid.
     */
    function arbitrationCost(bytes memory _extraData) public view returns (uint fee);

    /** @dev Appeal a ruling. Note that it has to be called before the arbitrator contract calls rule.
     *  @param _disputeID ID of the dispute to be appealed.
     *  @param _extraData Can be used to give extra info on the appeal.
     */
    function appeal(uint _disputeID, bytes memory _extraData) public requireAppealFee(_disputeID, _extraData) payable {
        emit AppealDecision(_disputeID, IArbitrable(msg.sender));
    }

    /** @dev Compute the cost of appeal. It is recommended not to increase it often, as it can be higly time and gas consuming for the arbitrated contracts to cope with fee augmentation.
     *  @param _disputeID ID of the dispute to be appealed.
     *  @param _extraData Can be used to give additional info on the dispute to be created.
     *  @return fee Amount to be paid.
     */
    function appealCost(uint _disputeID, bytes memory _extraData) public view returns (uint fee);

    /** @dev Compute the start and end of the dispute's current or next appeal period, if possible.
     *  @param _disputeID ID of the dispute.
     *  @return The start and end of the period.
     */
    function appealPeriod(uint _disputeID) public view returns (uint start, uint end);

    /** @dev Return the status of a dispute.
     *  @param _disputeID ID of the dispute to rule.
     *  @return status The status of the dispute.
     */
    function disputeStatus(uint _disputeID) public view returns (DisputeStatus status);

    /** @dev Return the current ruling of a dispute. This is useful for parties to know if they should appeal.
     *  @param _disputeID ID of the dispute.
     *  @return ruling The ruling which has been given or the one which will be given if there is no appeal.
     */
    function currentRuling(uint _disputeID) public view returns (uint ruling);
}

contract Arbitrable is IArbitrable {
    Arbitrator public arbitrator;
    bytes public arbitratorExtraData; // Extra data to require particular dispute and appeal behaviour.

    /** @dev Constructor. Choose the arbitrator.
     *  @param _arbitrator The arbitrator of the contract.
     *  @param _arbitratorExtraData Extra data for the arbitrator.
     */
    constructor(Arbitrator _arbitrator, bytes memory _arbitratorExtraData) public {
        arbitrator = _arbitrator;
        arbitratorExtraData = _arbitratorExtraData;
    }

    /** @dev Give a ruling for a dispute. Must be called by the arbitrator.
     *  The purpose of this function is to ensure that the address calling it has the right to rule on the contract.
     *  @param _disputeID ID of the dispute in the Arbitrator contract.
     *  @param _ruling Ruling given by the arbitrator. Note that 0 is reserved for "Not able/wanting to make a decision".
     */
    function rule(uint _disputeID, uint _ruling) external {
        emit Ruling(Arbitrator(msg.sender), _disputeID, _ruling);

        executeRuling(_disputeID, _ruling);
    }


    /** @dev Execute a ruling of a dispute.
     *  @param _disputeID ID of the dispute in the Arbitrator contract.
     *  @param _ruling Ruling given by the arbitrator. Note that 0 is reserved for "Not able/wanting to make a decision".
     */
    function executeRuling(uint _disputeID, uint _ruling) internal;
}

interface PermissionInterface {
    /* External */

    /**
     *  @dev Return true if the value is allowed.
     *  @param _value The value we want to check.
     *  @return allowed True if the value is allowed, false otherwise.
     */
    function isPermitted(bytes32 _value) external view returns (bool allowed);
}

library CappedMath {
    uint constant private UINT_MAX = 2**256 - 1;

    /**
     * @dev Adds two unsigned integers, returns 2^256 - 1 on overflow.
     */
    function addCap(uint _a, uint _b) internal pure returns (uint) {
        return (_a + _b) >= _a ? (_a + _b) : UINT_MAX;
    }

    /**
     * @dev Subtracts two integers, returns 0 on underflow.
     */
    function subCap(uint _a, uint _b) internal pure returns (uint) {
        return (_b > _a) ? 0 : _a - _b;
    }

    /**
     * @dev Multiplies two unsigned integers, returns 2^256 - 1 on overflow.
     */
    function mulCap(uint _a, uint _b) internal pure returns (uint) {
        // Gas optimization: this is cheaper than requiring '_a' not being zero, but the
        // benefit is lost if '_b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0)
            return 0;

        uint c = _a * _b;
        
        return c / _a == _b ? c : UINT_MAX;
    }
}

contract EthereumClaimsRegistry {

    mapping(address => mapping(address => mapping(bytes32 => bytes32))) public registry;

    event ClaimSet(
        address indexed issuer,
        address indexed subject,
        bytes32 indexed key,
        bytes32 value,
        uint updatedAt);

    event ClaimRemoved(
        address indexed issuer,
        address indexed subject,
        bytes32 indexed key,
        uint removedAt);

    // create or update clams
    function setClaim(address subject, bytes32 key, bytes32 value) public {
        registry[msg.sender][subject][key] = value;
        emit ClaimSet(msg.sender, subject, key, value, now);
    }

    function setSelfClaim(bytes32 key, bytes32 value) public {
        setClaim(msg.sender, key, value);
    }

    function getClaim(address issuer, address subject, bytes32 key) public view returns (bytes32) {
        return registry[issuer][subject][key];
    }

    function removeClaim(address issuer, address subject, bytes32 key) public {
        require(msg.sender == issuer);
        delete registry[issuer][subject][key];
        emit ClaimRemoved(msg.sender, subject, key, now);
    }
}

// ERC 780
interface EthereumClaimsRegistryInterface {
    // create or update clams
    function setClaim(address subject, bytes32 key, bytes32 value) external;

    function setSelfClaim(bytes32 key, bytes32 value) external;

    function getClaim(address issuer, address subject, bytes32 key) external view returns (bytes32);

    function removeClaim(address issuer, address subject, bytes32 key) external;
    
    /* events */
    event ClaimSet(
        address indexed issuer,
        address indexed subject,
        bytes32 indexed key,
        bytes32 value,
        uint updatedAt
    );

    event ClaimRemoved(
        address indexed issuer,
        address indexed subject,
        bytes32 indexed key,
        uint removedAt
    );
}

interface requestClaimRegistry {
    function requestPublicStatusChange(address issuer, address subject, bytes32 key) external; // can be challenged
    function challengePublicRequest() external;
    function requestPrivateStatusChange(address issuer, address subject, bytes32 key) external; // need arbitration cost
    
}

// Claim Curated Registry CCR
contract ClaimCuratedRegistry is PermissionInterface, EthereumClaimsRegistryInterface, Arbitrable {
    using CappedMath for uint; // Operations bounded between 0 and 2**256 - 1.

    /* Enums */

    enum ClaimStatus {
        Absent, // The claim is not in the registry.
        RegistrationRequested, // The claim has a request to be registered.
        Registered, // The claim is in the registry.
        ClearingRequested // The claim has a request to be removed from the registry.
    }

    enum Party {
        None,      // Party per default when there is no challenger or requester.
                   // Also used for unconclusive ruling.
        Requester, // Party that made the request to change a token status.
        Challenger // Party that challenges the request to change a token status.
    }
    
    enum DisputeStatus {
        None, // The claim is not disputed.
        Disputed, // The claim is disputed.
        Appealed, // The dispute of the claim is appealed.
        Resolved // The dispute of the claim is resolved.
    }
    
    enum RequestType {
        NewSubmission, // The claim is new.
        RegistrationRequest, // The claim is for a registration.
        ClearingRequest // The claim is for clearing.
    }

    // ************************ //
    // *  Request Life Cycle  * //
    // ************************ //
    // Changes to the claim status are made via requests for either listing or removing a claim
    // from the Claim Curated Registry.
    // To make or challenge a request, a party must pay a deposit. This value will be rewarded to the 
    // party that ultimately wins a dispute. If no one challenges the public claim, the value will be 
    // reimbursed to the requester.
    // The user can also make a private claim. In this case, he must pay the arbitration fees.
    // Additionally to the challenge reward, in the case a party challenges a request, both sides must 
    // fully pay the amount of arbitration fees required to raise a dispute. The party that ultimately 
    // wins the case will be reimbursed.
    // Finally, arbitration fees can be crowdsourced. To incentivise insurers, an additional fee stake 
    // must be deposited. Contributors that fund the side that ultimately wins a dispute will be 
    // reimbursed and rewarded with the other side's fee stake proportionally to their contribution.
    // In summary, costs for placing or challenging a request are the following:
    // - A challenge reward given to the party that wins a potential dispute.
    // - Arbitration fees used to pay jurors.
    // - A fee stake that is distributed among insurers of the side that ultimately wins a dispute.

    /* Structs */
    
    // Some arrays below have 3 elements to map with the Party enums for better readability:
    // - 0: is unused, matches `Party.None`.
    // - 1: for `Party.Requester`.
    // - 2: for `Party.Challenger`.
    struct Request {
        DisputeStatus disputeStatus; // Status of dispute if any.
        uint disputeID; // ID of the dispute, if any.
        uint submissionTime; // Time when the request was made. Used to track when the challenge period ends.
        address[3] parties; // Address of requester and challenger, if any.
        Round[] rounds; // Tracks each round of a dispute.
        Party ruling; // The final ruling given, if any.
        Arbitrator arbitrator; // The arbitrator trusted to solve disputes for this request.
        bytes arbitratorExtraData; // The extra data for the trusted arbitrator of this request.
    }
    
    struct Round {
        uint[3] paidFees; // Tracks the fees paid by each side on this round.
        bool[3] hasPaid; // True when the side has fully paid its fee. False otherwise.
        uint feeRewards; // Sum of reimbursable fees and stake rewards available to the parties that made 
                         // contributions to the side that ultimately wins a dispute.
        mapping(address => uint[3]) contributions; // Maps contributors to their contributions for each side.
    }
    
    // Inpiration by EIP 1812
    // The issuer is always the 
    struct Claim {
        address issuer; // The address of the issuer. In the case of a resolved dispute, it's the arbitrator.
        address subject;
        bytes32 key;
        bytes32 value;
	    uint256 validFrom;
	    uint256 validTo;
	
        ClaimStatus status; // The status of the claim.
        Request[] requests; // List of status change requests made for the claim.
    }

    /* Storage */
    
    // Constants
    
    uint RULING_OPTIONS = 2; // The amount of non 0 choices the arbitrator can give.

    // Settings
    address public governor; // The address that can make governance changes to the parameters 
                             // of the Claim Curated Registry.
    uint public requesterBaseDeposit; // The base deposit to make a request.
    uint public challengerBaseDeposit; // The base deposit to challenge a request.
    uint public challengePeriodDuration; // The time before a request becomes executable if not challenged.
    uint public metaEvidenceUpdates; // The number of times the meta evidence has been updated. Used to 
                                     // track the latest meta evidence ID.

    // The required fee stake that a party must pay depends on who won the previous round and is proportional 
    // to the arbitration cost such that the fee stake for a round is stake multiplier * arbitration cost for 
    // that round.
    // Multipliers are in basis points.
    uint public winnerStakeMultiplier; // Multiplier for calculating the fee stake paid by the party that won 
                                       // the previous round.
    uint public loserStakeMultiplier; // Multiplier for calculating the fee stake paid by the party that lost 
                                      // the previous round.
    uint public sharedStakeMultiplier; // Multiplier for calculating the fee stake that must be paid in the 
                                       // case where there isn't a winner and loser (e.g. when it's the first 
                                       // round or the arbitrator ruled "refused to rule"/"could not rule").
    uint public constant MULTIPLIER_DIVISOR = 10000; // Divisor parameter for multipliers.

    // Registry data.
    mapping(bytes32 => Claim) public claims; // Maps the claim ID to the claim data.
    mapping(address => mapping(uint => bytes32)) public arbitratorDisputeIDToClaimID; // Maps a dispute ID to 
    // the ID of the claim with the disputed request. On the form arbitratorDisputeIDToClaimID[arbitrator][disputeID].
    bytes32[] public claimsList; // List of IDs of submitted claims.

    // Token list
    mapping(address => bytes32[]) public subjectToSubmissions; // Maps subjects to submitted claim IDs.

    /* Modifiers */

    modifier onlyGovernor {require(msg.sender == governor, "The caller must be the governor."); _;}

    /* Events */

    /**
     *  @dev Emitted when a party submits a new claim.
     */
    event ClaimSet(
        address indexed _issuer,
        address indexed _subject,
        bytes32 indexed _key,
        bytes32 _value,
        uint256 _validFrom,
	    uint256 _validTo,
        uint _updatedAt
    );

    event ClaimRemoved(
        address indexed _issuer,
        address indexed _subject,
        bytes32 indexed _key,
        uint _removedAt
    );

    /** @dev Emitted when a party makes a request to change a claim status.
     *  @param _claimID The ID of the affected claim.
     *  @param _type Type of the request.
     */
    event RequestSubmitted(
        bytes32 indexed _claimID, 
        RequestType _type
    );

    /**
     *  @dev Emitted when a party makes a request, dispute or appeals are raised, or when a request is resolved.
     *  @param _requester Address of the party that submitted the request.
     *  @param _challenger Address of the party that has challenged the request, if any.
     *  @param _identityID The claim ID. It is the keccak256 hash of it's data.
     *  @param _status The status of the claim.
     *  @param _disputeStatus The status of the dispute.
     */
    event ClaimStatusChange(
        address indexed _requester,
        address indexed _challenger,
        bytes32 indexed _identityID,
        ClaimStatus _status,
        DisputeStatus _disputeStatus
    );

    /** @dev Emitted when a reimbursements and/or contribution rewards are withdrawn.
     *  @param _claimID The ID of the token from which the withdrawal was made.
     *  @param _contributor The address that sent the contribution.
     *  @param _request The request from which the withdrawal was made.
     *  @param _round The round from which the reward was taken.
     *  @param _value The value of the reward.
     */
    event RewardWithdrawal(
        bytes32 indexed _claimID, 
        address indexed _contributor, 
        uint indexed _request, 
        uint _round, 
        uint _value
    );

    
    
    /* Constructor */

    /**
     *  @dev Constructs the arbitrable token curated registry.
     *  @param _arbitrator The trusted arbitrator to resolve potential disputes.
     *  @param _arbitratorExtraData Extra data for the trusted arbitrator contract.
     */
    constructor(
        Arbitrator _arbitrator,
        bytes memory _arbitratorExtraData
        // string _registrationMetaEvidence,
        // string _clearingMetaEvidence,
        // address _governor,
        // uint _requesterBaseDeposit,
        // uint _challengerBaseDeposit,
        // uint _challengePeriodDuration,
        // uint _sharedStakeMultiplier,
        // uint _winnerStakeMultiplier,
        // uint _loserStakeMultiplier
    ) Arbitrable(_arbitrator, _arbitratorExtraData) public {

    }
    
        
    /* External and Public */
    
    // ************************ //
    // *       Requests       * //
    // ************************ //

    /** @dev Submits a request to change a token status. Accepts enough ETH to fund a potential dispute considering the current required amount and reimburses the rest. TRUSTED.
     *  @param _subject The address of the target.
     *  @param _key The key.
     *  @param _value The value of the key.
     *  @param _validFrom The valid from.
     *  @param _validTo  The valid to.
     */
    function requestPublicStatusChange(
        address _subject,
        bytes32 _key,
        bytes32 _value,
        uint256 _validFrom,
	    uint256 _validTo
    )
        external
        payable
    {
        bytes32 claimID = keccak256(
            abi.encodePacked(
                _subject,
                _key,
                _value,
                _validFrom,
                _validTo
            )
        );

        Claim storage claim = claims[claimID];
        if (claim.requests.length == 0) {
            // Initial token registration.
            claim.issuer = msg.sender;
            claim.subject = _subject;
            claim.key = _key;
            claim.value = _value;
            claim.validFrom = _validFrom;
            claim.validTo = _validTo;
            claimsList.push(claimID);
            subjectToSubmissions[_subject].push(claimID);
            emit ClaimSet(
                msg.sender,
                _subject,
                _key,
                _value,
                _validFrom,
        	    _validTo,
                now
            );
            emit RequestSubmitted(
                claimID, 
                RequestType.NewSubmission
            );
        }

        // Update claim status.
        if (claim.status == ClaimStatus.Absent)
            claim.status = ClaimStatus.RegistrationRequested;
        else if (claim.status == ClaimStatus.Registered)
            claim.status = ClaimStatus.ClearingRequested;
        else
            revert("Claim already has a pending request.");

        // Setup request.
        Request storage request = claim.requests[claim.requests.length++];
        request.parties[uint(Party.Requester)] = msg.sender;
        request.submissionTime = now;
        request.arbitrator = arbitrator;
        request.arbitratorExtraData = arbitratorExtraData;
        Round storage round = request.rounds[request.rounds.length++];

        emit RequestSubmitted(
            claimID, 
            claim.status == ClaimStatus.RegistrationRequested ? RequestType.RegistrationRequest : RequestType.ClearingRequest
        );

        // Amount required to fully fund each side: requesterBaseDeposit + arbitration cost + (arbitration cost * multiplier).
        uint arbitrationCost = request.arbitrator.arbitrationCost(request.arbitratorExtraData);
        uint totalCost = arbitrationCost.addCap((arbitrationCost.mulCap(sharedStakeMultiplier)) / MULTIPLIER_DIVISOR).addCap(requesterBaseDeposit);
        // contribute(round, Party.Requester, msg.sender, msg.value, totalCost); // TODO: add this method
        require(round.paidFees[uint(Party.Requester)] >= totalCost, "You must fully fund your side.");
        round.hasPaid[uint(Party.Requester)] = true;
        
        emit ClaimStatusChange(
            request.parties[uint(Party.Requester)],
            address(0x0),
            claimID,
            claim.status,
            DisputeStatus.None
        );
    }
    
    function challengePublicRequest(bytes32 _claimID, string calldata _evidence) external payable {
        Claim storage claim = claims[_claimID];

        require(
            claim.status == ClaimStatus.RegistrationRequested || claim.status == ClaimStatus.ClearingRequested,
            "The claim must have a pending request."
        );

        Request storage request = claim.requests[claim.requests.length - 1];
        
        require(now - request.submissionTime <= challengePeriodDuration, "Challenges must occur during the challenge period.");
        require(request.disputeStatus == DisputeStatus.None, "The request should not have already been disputed.");

        // Take the deposit and save the challenger's address.
        request.parties[uint(Party.Challenger)] = msg.sender;

        Round storage round = request.rounds[request.rounds.length - 1];
        uint arbitrationCost = request.arbitrator.arbitrationCost(request.arbitratorExtraData);
        uint totalCost = arbitrationCost.addCap(
            arbitrationCost.mulCap(sharedStakeMultiplier) 
            / MULTIPLIER_DIVISOR
        ).addCap(challengerBaseDeposit);
        
        // contribute(round, Party.Challenger, msg.sender, msg.value, totalCost);
        
        require(round.paidFees[uint(Party.Challenger)] >= totalCost, "You must fully fund your side.");

        round.hasPaid[uint(Party.Challenger)] = true;
        
        // Raise a dispute.
        request.disputeID = request.arbitrator.createDispute.value(arbitrationCost)(RULING_OPTIONS, request.arbitratorExtraData);
        arbitratorDisputeIDToClaimID[address(request.arbitrator)][request.disputeID] = _claimID;
        request.disputeStatus = DisputeStatus.Disputed;
        request.rounds.length++;
        round.feeRewards = round.feeRewards.subCap(arbitrationCost);
        
        emit Dispute(
            request.arbitrator,
            request.disputeID,
            claim.status == ClaimStatus.RegistrationRequested
                ? 2 * metaEvidenceUpdates
                : 2 * metaEvidenceUpdates + 1,
            uint(keccak256(abi.encodePacked(_claimID, claim.requests.length - 1)))
        );
        emit ClaimStatusChange(
            request.parties[uint(Party.Requester)],
            request.parties[uint(Party.Challenger)],
            _claimID,
            claim.status,
            DisputeStatus.Disputed
        );

        if (bytes(_evidence).length > 0)
            emit Evidence(
                request.arbitrator, 
                uint(keccak256(abi.encodePacked(_claimID, claim.requests.length - 1))), 
                msg.sender,
                _evidence
            );
    }
    
    function executeRuling(uint _disputeID, uint _ruling) internal {}
    
    function isPermitted(bytes32 _value) external view returns (bool allowed) {}
    
    function setClaim(address subject, bytes32 key, bytes32 value) external {}

    function setSelfClaim(bytes32 key, bytes32 value) external {}

    function getClaim(address issuer, address subject, bytes32 key) external view returns (bytes32) {}

    function removeClaim(address issuer, address subject, bytes32 key) external {}
}
