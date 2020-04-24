/**
 *Submitted for verification at Etherscan.io on 2019-07-13
*/

/**
 *  @authors: [@n1c01a5]
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


contract IdentityList is PermissionInterface, Arbitrable {
    using CappedMath for uint; // Operations bounded between 0 and 2**256 - 1.

    /* Enums */

    enum IdentityStatus {
        Absent, // The identity is not in the registry.
        Recorded, // The token is in the registry but not certified.
        CertificationChallenged, // The token has a request to be added to the registry.
        Certified, // Certified by an arbitrator.
        ClearingChallenged // The identity has a request to be removed from the registry.
    }

    enum Party {
        None,      // Party per default when there is no challenger or requester.
                   // Also used for unconclusive ruling.
        Requester, // Party that made the request to change a token status.
        Challenger // Party that challenges the request to change a token status.
    }
    
    enum DisputeStatus {
        None, // The identity is not disputed.
        Disputed, // The identity is not disputed.
        Appealed, // The dispute of the identity is not appealed.
        Resolved // The dispute of the identity is not resolved.
    }

    // ************************ //
    // *  Request Life Cycle  * //
    // ************************ //
    // Changes to the identity status are made via requests for either certification or removing an identity
    // from the Identity Curated Registry.
    // To make or challenge a request, a party must pay a deposit. This value will be rewarded to the 
    // party that ultimately wins a dispute. If no one challenges the identity, the value will be 
    // reimbursed to the requester.
    // The user of the identity can request a certification. In this case, he must pay only the arbitration
    // cost.
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
        uint DisputeStatus; // Status of dispute if any.
        uint disputeID; // ID of the dispute, if any.
        uint submissionTime; // Time when the request was made. Used to track when the challenge period ends.
        address[3] parties; // Address of requester and challenger, if any.
        Round[] rounds; // Tracks each round of a dispute.
        Party ruling; // The final ruling given, if any.
        Arbitrator arbitrator; // The arbitrator trusted to solve disputes for this request.
        bytes arbitratorExtraData; // The extra data for the trusted arbitrator of this request.
    }
    
    struct Round {
        uint[3] requiredForSide; // Tracks the fees paid by each side on this round.
        uint[3] paidFees; // True when the side has fully paid its fee. False otherwise.
        uint feeRewards; // Sum of reimbursable fees and stake rewards available to the parties that made 
                         // contributions to the side that ultimately wins a dispute.
        mapping(address => uint[3]) contributions; // Maps contributors to their contributions for each side.
    }
    
    struct Identity {
        string typeIdentity; // Type of the identity (e.g Human, Robot, IA, Organisation).
        string knownAs; // The most common name (e.g Ethereum, Daft Punk).
        string firstname; // The firstname of the identity.
        string name; // The name of the identity.
        address addr; // The Ethereum address of the owner of the identity.
        IdentityStatus status; // The status of the identity.
        uint requests; // List of status change requests made for the identity.
    }

    /* Storage */
    
    // Constants
    
    uint RULING_OPTIONS = 2; // The amount of non 0 choices the arbitrator can give.

    // Settings
    address public governor; // The address that can make governance changes to the parameters 
                             // of the Identity Curated Registry.
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
    mapping(bytes32 => Identity) public identities; // Maps the identity ID to the identity data.
    mapping(address => mapping(uint => bytes32)) public arbitratorDisputeIDToIdentityID; // Maps a dispute ID to 
    // the ID of the identity with the disputed request. On the form arbitratorDisputeIDToIdenityID[arbitrator][disputeID].
    bytes32[] public tokensList; // List of IDs of submitted idenities.

    // Token list
    mapping(address => bytes32[]) public addressToSubmissions; // Maps addresses to submitted identity IDs.

    /* Modifiers */

    modifier onlyGovernor {require(msg.sender == governor, "The caller must be the governor."); _;}

    /* Events */

    /**
     *  @dev Emitted when a party submits a new idenity.
     *  @param _typeIdentity The token name (e.g. Pinakion).
     *  @param _knownAs The token ticker (e.g. PNK).
     *  @param _firstname The keccak256 multihash of the token symbol image.
     *  @param _name The keccak256 multihash of the token symbol image.
     *  @param _addr The token address.
     */
    event IdentitySubmitted(
        string _typeIdentity,
        string _knownAs,
        string _firstname,
        string _name,
        address indexed _addr
    );

    /** @dev Emitted when a party makes a request to change a identity status.
     *  @param _identityID The ID of the affected identity.
     *  @param _isCertificationChallenged Whether the request is a registration request. False means it is a clearing request.
     */
    event RequestSubmitted(
        bytes32 indexed _identityID, 
        bool _isCertificationChallenged
    );

    /**
     *  @dev Emitted when a party makes a request, dispute or appeals are raised, or when a request is resolved.
     *  @param _requester Address of the party that submitted the request.
     *  @param _challenger Address of the party that has challenged the request, if any.
     *  @param _identityID The identity ID. It is the keccak256 hash of it's data.
     *  @param _status The status of the token.
     *  @param _disputed Whether the token is disputed.
     *  @param _appealed Whether the current round was appealed.
     */
    event TokenStatusChange(
        address indexed _requester,
        address indexed _challenger,
        bytes32 indexed _identityID,
        IdentityStatus _status,
        bool _disputed, // FIXME
        bool _appealed // FIXME
    );

    /** @dev Emitted when a reimbursements and/or contribution rewards are withdrawn.
     *  @param _identityID The ID of the token from which the withdrawal was made.
     *  @param _contributor The address that sent the contribution.
     *  @param _request The request from which the withdrawal was made.
     *  @param _round The round from which the reward was taken.
     *  @param _value The value of the reward.
     */
    event RewardWithdrawal(bytes32 indexed _identityID, address indexed _contributor, uint indexed _request, uint _round, uint _value);

    
    /* Constructor */

    /**
     *  @dev Constructs the arbitrable token curated registry.
     *  @param _arbitrator The trusted arbitrator to resolve potential disputes.
     *  @param _arbitratorExtraData Extra data for the trusted arbitrator contract.
     */
    constructor(
        Arbitrator _arbitrator,
        bytes memory _arbitratorExtraData
    ) Arbitrable(_arbitrator, _arbitratorExtraData) public {

    }
    
    function executeRuling(uint _disputeID, uint _ruling) internal {}
    
    function isPermitted(bytes32 _value) external view returns (bool allowed) {}
}
