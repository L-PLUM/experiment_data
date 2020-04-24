/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.4.24;


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
     */
    event Dispute(Arbitrator indexed _arbitrator, uint indexed _disputeID, uint _metaEvidenceID);

    /** @dev To be raised when evidence are submitted. Should point to the ressource (evidences are not to be stored on chain due to gas considerations).
     *  @param _arbitrator The arbitrator of the contract.
     *  @param _disputeID ID of the dispute in the Arbitrator contract.
     *  @param _party The address of the party submiting the evidence. Note that 0x0 refers to evidence not submitted by any party.
     *  @param _evidence A URI to the evidence JSON file whose name should be its keccak256 hash followed by .json.
     */
    event Evidence(Arbitrator indexed _arbitrator, uint indexed _disputeID, address indexed _party, string _evidence);

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
    function rule(uint _disputeID, uint _ruling) public;
}


/** @title Arbitrable
 *  Arbitrable abstract contract.
 *  When developing arbitrable contracts, we need to:
 *  -Define the action taken when a ruling is received by the contract. We should do so in executeRuling.
 *  -Allow dispute creation. For this a function must:
 *      -Call arbitrator.createDispute.value(_fee)(_choices,_extraData);
 *      -Create the event Dispute(_arbitrator,_disputeID,_rulingOptions);
 */
contract Arbitrable is IArbitrable {
    Arbitrator public arbitrator;
    bytes public arbitratorExtraData; // Extra data to require particular dispute and appeal behaviour.

    modifier onlyArbitrator {require(msg.sender == address(arbitrator), "Can only be called by the arbitrator."); _;}

    /** @dev Constructor. Choose the arbitrator.
     *  @param _arbitrator The arbitrator of the contract.
     *  @param _arbitratorExtraData Extra data for the arbitrator.
     */
    constructor(Arbitrator _arbitrator, bytes _arbitratorExtraData) public {
        arbitrator = _arbitrator;
        arbitratorExtraData = _arbitratorExtraData;
    }

    /** @dev Give a ruling for a dispute. Must be called by the arbitrator.
     *  The purpose of this function is to ensure that the address calling it has the right to rule on the contract.
     *  @param _disputeID ID of the dispute in the Arbitrator contract.
     *  @param _ruling Ruling given by the arbitrator. Note that 0 is reserved for "Not able/wanting to make a decision".
     */
    function rule(uint _disputeID, uint _ruling) public onlyArbitrator {
        emit Ruling(Arbitrator(msg.sender),_disputeID,_ruling);

        executeRuling(_disputeID,_ruling);
    }


    /** @dev Execute a ruling of a dispute.
     *  @param _disputeID ID of the dispute in the Arbitrator contract.
     *  @param _ruling Ruling given by the arbitrator. Note that 0 is reserved for "Not able/wanting to make a decision".
     */
    function executeRuling(uint _disputeID, uint _ruling) internal;
}


/** @title Arbitrator
 *  Arbitrator abstract contract.
 *  When developing arbitrator contracts we need to:
 *  -Define the functions for dispute creation (createDispute) and appeal (appeal). Don't forget to store the arbitrated contract and the disputeID (which should be unique, use nbDisputes).
 *  -Define the functions for cost display (arbitrationCost and appealCost).
 *  -Allow giving rulings. For this a function must call arbitrable.rule(disputeID,ruling).
 */
contract Arbitrator{

    enum DisputeStatus {Waiting, Appealable, Solved}

    modifier requireArbitrationFee(bytes _extraData) {
        require(msg.value >= arbitrationCost(_extraData), "Not enough ETH to cover arbitration costs.");
        _;
    }
    modifier requireAppealFee(uint _disputeID, bytes _extraData) {
        require(msg.value >= appealCost(_disputeID, _extraData), "Not enough ETH to cover appeal costs.");
        _;
    }

    /** @dev To be raised when a dispute is created.
     *  @param _disputeID ID of the dispute.
     *  @param _arbitrable The contract which created the dispute.
     */
    event DisputeCreation(uint indexed _disputeID, Arbitrable indexed _arbitrable);

    /** @dev To be raised when a dispute can be appealed.
     *  @param _disputeID ID of the dispute.
     */
    event AppealPossible(uint indexed _disputeID, Arbitrable indexed _arbitrable);

    /** @dev To be raised when the current ruling is appealed.
     *  @param _disputeID ID of the dispute.
     *  @param _arbitrable The contract which created the dispute.
     */
    event AppealDecision(uint indexed _disputeID, Arbitrable indexed _arbitrable);

    /** @dev Create a dispute. Must be called by the arbitrable contract.
     *  Must be paid at least arbitrationCost(_extraData).
     *  @param _choices Amount of choices the arbitrator can make in this dispute.
     *  @param _extraData Can be used to give additional info on the dispute to be created.
     *  @return disputeID ID of the dispute created.
     */
    function createDispute(uint _choices, bytes _extraData) public requireArbitrationFee(_extraData) payable returns(uint disputeID) {}

    /** @dev Compute the cost of arbitration. It is recommended not to increase it often, as it can be highly time and gas consuming for the arbitrated contracts to cope with fee augmentation.
     *  @param _extraData Can be used to give additional info on the dispute to be created.
     *  @return fee Amount to be paid.
     */
    function arbitrationCost(bytes _extraData) public view returns(uint fee);

    /** @dev Appeal a ruling. Note that it has to be called before the arbitrator contract calls rule.
     *  @param _disputeID ID of the dispute to be appealed.
     *  @param _extraData Can be used to give extra info on the appeal.
     */
    function appeal(uint _disputeID, bytes _extraData) public requireAppealFee(_disputeID,_extraData) payable {
        emit AppealDecision(_disputeID, Arbitrable(msg.sender));
    }

    /** @dev Compute the cost of appeal. It is recommended not to increase it often, as it can be higly time and gas consuming for the arbitrated contracts to cope with fee augmentation.
     *  @param _disputeID ID of the dispute to be appealed.
     *  @param _extraData Can be used to give additional info on the dispute to be created.
     *  @return fee Amount to be paid.
     */
    function appealCost(uint _disputeID, bytes _extraData) public view returns(uint fee);

    /** @dev Compute the start and end of the dispute's current or next appeal period, if possible.
     *  @param _disputeID ID of the dispute.
     *  @return The start and end of the period.
     */
    function appealPeriod(uint _disputeID) public view returns(uint start, uint end) {}

    /** @dev Return the status of a dispute.
     *  @param _disputeID ID of the dispute to rule.
     *  @return status The status of the dispute.
     */
    function disputeStatus(uint _disputeID) public view returns(DisputeStatus status);

    /** @dev Return the current ruling of a dispute. This is useful for parties to know if they should appeal.
     *  @param _disputeID ID of the dispute.
     *  @return ruling The ruling which has been given or the one which will be given if there is no appeal.
     */
    function currentRuling(uint _disputeID) public view returns(uint ruling);
}


/**
 *  @title Permission Interface
 *  This is a permission interface for arbitrary values. The values can be cast to the required types.
 */
interface PermissionInterface{
    /* External */

    /**
     *  @dev Return true if the value is allowed.
     *  @param _value The value we want to check.
     *  @return allowed True if the value is allowed, false otherwise.
     */
    function isPermitted(bytes32 _value) external view returns (bool allowed);
}

/**
 * @title CappedMath
 * @dev Math operations with caps for under and overflow.
 */
library CappedMath {
    uint constant private UINT_MAX = 2**256 - 1;

    /**
    * @dev Adds two unsigned integers, returns 2^256 - 1 on overflow.
    */
    function addCap(uint _a, uint _b) internal pure returns (uint) {
        uint c = _a + _b;
        return c >= _a ? c : UINT_MAX;
    }

    /**
    * @dev Subtracts two integers, returns 0 on underflow.
    */
    function subCap(uint _a, uint _b) internal pure returns (uint) {
        if (_b > _a)
            return 0;
        else
            return _a - _b;
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


/**
 *  @title ArbitrableTokenList
 *  This contract is an arbitrable token curated registry for tokens, sometimes referred to as a Token² Curated Registry. Users can send requests to register or remove tokens from the registry which can, in turn, be challenged by parties that disagree with the request.
 *  A crowdsourced insurance system allows parties to contribute to arbitration fees and win rewards if the side they backed ultimately wins a dispute.
 *  NOTE: This contract trusts that the Arbitrator will not reenter or modify its costs during a call. The governor contract (which will be a DAO) is also to be trusted.
 */
contract ArbitrableTokenList is PermissionInterface, Arbitrable {
    using CappedMath for uint;
    /* solium-disable max-len*/

    /* Enums */

    enum TokenStatus {
        Absent, // The token is not in the registry.
        Registered, // The token is in the registry.
        RegistrationRequested, // The token has a request to be added to the registry.
        ClearingRequested // The token has a request to be removed from the registry.
    }

    enum RulingOption {
        Other, // Arbitrator did not rule or refused to rule.
        Accept, // Execute request. Rule in favor of requester.
        Refuse // Refuse request. Rule in favor of challenger.
    }

    enum Party {
        None,
        Requester, // Party that made a request to change a token status.
        Challenger // Party challenging a request.
    }

    // ************************ //
    // *  Request Life Cycle  * //
    // ************************ //
    // Changes to the token status are made via requests for either listing or removing a token from the Token² Curated Registry.
    // The total cost of a request varies depending on whether a party challenges that request and on the number of appeals.
    // To make or challenge a request, a party must pay a deposit. This value will be rewarded to the party that ultimately wins a dispute. If no one challenges the request, the value will be reimbursed to the requester.
    // Additionally to the challenge reward, in the case a party challenges a request, both sides must fully pay the amount of arbitration fees required to raise a dispute. The party that ultimately wins the case will be reimbursed.
    // Finally, arbitration fees can be crowdsourced. To incentivise insurers, an additional value must be deposited. Contributors that fund the side that ultimately wins a dispute will be reimbursed and rewarded with the other side's fee stake proportinally to their contribution.
    // In summary, costs for placing or challenging a request are the following:
    // - A challenge reward given to the party that wins a potential dispute.
    // - Arbitration fees used to pay jurors.
    // - A fee stake that is distributed among insurers of the side that ultimately wins a dispute.

    /* Structs */
    struct Token {
        string name; // The token name (e.g. Pinakion).
        string ticker; // The token ticker (e.g. PNK).
        address addr; // The Ethereum address of the token.
        string symbolMultihash; // The multihash of the token symbol.
        TokenStatus status;
        Request[] requests; // List of status change requests made for the token.
    }

    // Some arrays below have 3 elements to map with the Party enums for better readability.
    // - 0 is unused, matches Party.None.
    // - 1 for Party.Requester.
    // - 2 for Party.Challenger.
    struct Request {
        bool disputed; // True if a dispute was raised.
        uint disputeID; // ID of the dispute, if any.
        uint submissionTime; // Time when the request was made. Used to track when the challenge period ends.
        uint challengeRewardBalance; // The summation of requester's and challenger's deposit. This value will be given to the party that ultimately wins a potential dispute, or be reimbursed to the requester if no one challenges.
        uint challengerDepositTime; // The time when a challenger paid the deposit. Used to track when the request left the challenge period and entered the arbitration fees funding period.
        bool resolved; // True if the request was executed and/or any disputes raised were resolved.
        address[3] parties; // Address of requester and challenger, if any.
        Round[] rounds; // Tracks each round of a dispute.
        RulingOption ruling; // The final ruling given, if any.
        Arbitrator arbitrator; // The arbitrator trusted to solve disputes for this request.
        bytes arbitratorExtraData; // The extra data for the trusted arbitrator of this request.
    }

    struct Round {
        bool appealed; // True if this round was appealed.
        uint[3] paidFees; // Tracks the fees paid by each side on this round.
        uint[3] requiredForSide; // The total amount required to fully fund each side. It is the summation of the dispute or appeal cost and the fee stake.
        bool[3] requiredForSideSet; // Tracks if the amount of fees required for each side has been set.
        uint feeRewards; // Summation of reimbursable fees and stake rewards available to the parties that made contributions to the side that ultimately wins a dispute.
        Party sidePendingFunds; // The side that must receive fee contributions to not lose the case.
        mapping(address => uint[3]) contributions; // Maps contributors to their contributions for each side.
    }

    /* Modifiers */

    modifier onlyGovernor {require(msg.sender == governor, "The caller is not the governor."); _;}

    /* Events */

    /**
     *  @dev Emitted when a party submits a new token.
     *  @param _name The token name (e.g. Pinakion).
     *  @param _ticker The token ticker (e.g. PNK).
     *  @param _symbolMultihash The keccak256 multihash of the token symbol image.
     *  @param _address The token address.
     */
    event TokenSubmitted(string _name, string _ticker, string _symbolMultihash, address indexed _address);

    /** @dev Emitted when a party makes a request to change a token status.
     *  @param _tokenID The ID of the affected token.
     *  @param _registrationRequest Whether the request is a registration request. False means it is a clearing request.
     */
    event RequestSubmitted(bytes32 indexed _tokenID, bool indexed _registrationRequest);

    /**
     *  @dev Emitted when a party makes a request, dispute or appeals are raised or when a request is resolved.
     *  @param _requester Address of the party that submitted the request.
     *  @param _challenger Address of the party that has challenged the request, if any.
     *  @param _tokenID The token ID. It is the keccak256 hash of it's data.
     *  @param _status The status of the token.
     *  @param _disputed Whether the token is disputed.
     *  @param _appealed Whether the current round was appealed.
     */
    event TokenStatusChange(
        address indexed _requester,
        address indexed _challenger,
        bytes32 indexed _tokenID,
        TokenStatus _status,
        bool _disputed,
        bool _appealed
    );

    /** @dev Emitted when a deposit is made to challenge a request.
     *  @param _tokenID The ID of the token that has the challenged request.
     *  @param _challenger The address that paid the deposit.
     */
    event ChallengeDepositPlaced(bytes32 indexed _tokenID, address indexed _challenger);

    /** @dev Emitted when a reimbursements and/or contribution rewards are withdrawn.
     *  @param _tokenID The ID of the token from which the withdrawal was made.
     *  @param _contributor The address that sent the contribution.
     *  @param _request The request from which the withdrawal was made.
     *  @param _round The round from which the reward was taken.
     *  @param _value The value of the reward.
     */
    event RewardWithdrawal(bytes32 indexed _tokenID, address indexed _contributor, uint indexed _request, uint _round, uint _value);

    /** @dev Emitted when a side surpassed the adversary in funding and the opponent must fund his side to not lose the case.
     *  @param _tokenID The ID of the token with the request in the fee funding period.
     *  @param _side The side that must receive contributions to not lose the case.
     *  @param _party The account of the side that must receive contributions to not lose the case.
     */
    event WaitingOpponent(bytes32 indexed _tokenID, Party indexed _side, address indexed _party);

    /* Storage */

    // Settings
    uint public challengeReward; // The deposit required for making and/or challenging a request. A party that wins a disputed request will be reimbursed and will receive the other's deposit.
    uint public challengePeriodDuration; // The time before a request becomes executable if not challenged.
    uint public arbitrationFeesWaitingTime; // The time available to fund arbitration fees and fee stake for a dispute.
    uint public metaEvidenceUpdates; // The number of times the meta evidence has been updated. Used to track the latest meta evidence ID.
    address public governor; // The address that can make governance changes to the parameters of the Token² Curated Registry.

    // The required fee stake that a party must pay depends on who won the previous round and is proportional to the arbitration cost such that the fee stake for a round is stake multiplier * arbitration cost for that round.
    // The value is the percentage in 2 digits precision (e.g. a multiplier of 5000 results the fee stake being 50% of the arbitration cost for that round).
    uint public winnerStakeMultiplier; // Multiplier for calculating the fee stake paid by the party that won the previous round.
    uint public loserStakeMultiplier; // Multiplier for calculating the fee stake paid by the party that lost the previous round.
    uint public sharedStakeMultiplier; // Multiplier for calculating the fee stake that must be paid in the case where there isn't a winner and loser (e.g. when it's the first round or the arbitrator ruled "refused to rule"/"could not rule").
    uint public constant MULTIPLIER_PRECISION = 10000; // Precision parameter for multipliers.

    // Registry data.
    mapping(bytes32 => Token) public tokens; // Maps the token ID to the token data.
    mapping(uint => bytes32) public disputeIDToTokenID; // Maps a dispute ID to the ID of the token with the disputed request.
    bytes32[] public tokensList; // List of IDs of submitted tokens.

    // Token list
    mapping(address => bytes32[]) public addressToSubmissions; // Maps addresses to submitted token IDs.

    /* Constructor */

    /**
     *  @dev Constructs the arbitrable token curated registry.
     *  @param _arbitrator The trusted arbitrator to resolve potential disputes.
     *  @param _arbitratorExtraData Extra data for the trusted arbitrator contract.
     *  @param _registrationMetaEvidence The URI of the meta evidence object for registration requests.
     *  @param _clearingMetaEvidence The URI of the meta evidence object for clearing requests.
     *  @param _governor The trusted governor of this contract.
     *  @param _arbitrationFeesWaitingTime The maximum time in seconds to wait for arbitration fees if the dispute is raised.
     *  @param _challengeReward The amount in weis required to submit or challenge a request.
     *  @param _challengePeriodDuration The time in seconds, parties have to challenge a request.
     *  @param _sharedStakeMultiplier Percentage of the arbitration cost that each party must pay as fee stake for a round when there isn't a winner/loser in the previous round (e.g. when it's the first round or the arbitrator refused to or did not rule). Value in 2 digits precision (e.g. 2500 results in a fee stake that is 25% of the arbitration cost value of that round).
     *  @param _winnerStakeMultiplier Percentage of the arbitration cost that the winner has to pay as fee stake for a round. Value in 2 digits precision (e.g. 5000 results in a fee stake that is 50% of the arbitration cost value of that round).
     *  @param _loserStakeMultiplier Percentage of the arbitration cost that the loser has to pay as fee stake for a round. Value in 2 digits precision (e.g. 10000 results in a fee stake that is 100% of the arbitration cost value of that round).
     */
    constructor(
        Arbitrator _arbitrator,
        bytes _arbitratorExtraData,
        string _registrationMetaEvidence,
        string _clearingMetaEvidence,
        address _governor,
        uint _arbitrationFeesWaitingTime,
        uint _challengeReward,
        uint _challengePeriodDuration,
        uint _sharedStakeMultiplier,
        uint _winnerStakeMultiplier,
        uint _loserStakeMultiplier
    ) Arbitrable(_arbitrator, _arbitratorExtraData) public {
        emit MetaEvidence(0, _registrationMetaEvidence);
        emit MetaEvidence(1, _clearingMetaEvidence);

        governor = _governor;
        arbitrationFeesWaitingTime = _arbitrationFeesWaitingTime;
        challengeReward = _challengeReward;
        challengePeriodDuration = _challengePeriodDuration;
        sharedStakeMultiplier = _sharedStakeMultiplier;
        winnerStakeMultiplier = _winnerStakeMultiplier;
        loserStakeMultiplier = _loserStakeMultiplier;
    }

    /* Public */

    // ************************ //
    // *       Requests       * //
    // ************************ //

    /** @dev Submit a request to change a token status. Accepts enough ETH to fund a potential dispute considering the current required amount and reimburses the rest. TRUSTED.
     *  @param _name The token name (e.g. Pinakion).
     *  @param _ticker The token ticker (e.g. PNK).
     *  @param _addr The Ethereum address of the token.
     *  @param _symbolMultihash The multihash of the token symbol.
     */
    function requestStatusChange(
        string _name,
        string _ticker,
        address _addr,
        string _symbolMultihash
    )
        external
        payable
    {
        require(msg.value >= challengeReward, "Not enough ETH.");
        bytes32 tokenID = keccak256(
            abi.encodePacked(
                _name,
                _ticker,
                _addr,
                _symbolMultihash
            )
        );

        Token storage token = tokens[tokenID];
        if (token.requests.length == 0) {
            // Initial token registration
            token.name = _name;
            token.ticker = _ticker;
            token.addr = _addr;
            token.symbolMultihash = _symbolMultihash;
            tokensList.push(tokenID);
            addressToSubmissions[_addr].push(tokenID);
            emit TokenSubmitted(_name, _ticker, _symbolMultihash, _addr);
        }

        // Update token status.
        if (token.status == TokenStatus.Absent)
            token.status = TokenStatus.RegistrationRequested;
        else if (token.status == TokenStatus.Registered)
            token.status = TokenStatus.ClearingRequested;
        else
            revert("Token is in wrong status for request.");

        // Setup request.
        token.requests.length++;
        Request storage request = token.requests[token.requests.length - 1];
        request.parties[uint(Party.Requester)] = msg.sender;
        request.submissionTime = now;
        request.rounds.length++;
        request.challengeRewardBalance = challengeReward;
        request.arbitrator = arbitrator;
        request.arbitratorExtraData = arbitratorExtraData;
        emit RequestSubmitted(tokenID, token.status == TokenStatus.RegistrationRequested);

        // Calculate total amount required to fully fund the each side.
        // The amount required for each side is:
        //   total = arbitration cost + fee stake
        // where:
        //   fee stake = arbitration cost * multiplier
        Round storage round = request.rounds[request.rounds.length - 1];
        uint arbitrationCost = request.arbitrator.arbitrationCost(request.arbitratorExtraData);
        round.requiredForSide[uint(Party.Requester)] = arbitrationCost.addCap((arbitrationCost.mulCap(sharedStakeMultiplier)) / MULTIPLIER_PRECISION);
        round.requiredForSide[uint(Party.Challenger)] = arbitrationCost.addCap((arbitrationCost.mulCap(sharedStakeMultiplier)) / MULTIPLIER_PRECISION);
        round.requiredForSideSet[uint(Party.Requester)] = true;
        round.requiredForSideSet[uint(Party.Challenger)] = true;

        // Take up to the amount necessary to fund the current round at the current costs.
        uint contribution;
        uint remainingETH = msg.value - challengeReward;
        (contribution, remainingETH) = calculateContribution(remainingETH, round.requiredForSide[uint(Party.Requester)]);
        round.contributions[msg.sender][uint(Party.Requester)] = contribution;
        round.paidFees[uint(Party.Requester)] = contribution;
        round.feeRewards = contribution;

        // Reimburse leftover ETH.
        msg.sender.send(remainingETH); // Deliberate use of send in order to not block the contract in case of reverting fallback.

        emit TokenStatusChange(
            request.parties[uint(Party.Requester)],
            address(0x0),
            tokenID,
            token.status,
            false,
            false
        );
    }

    /** @dev Challenges the latest request of a token. Accepts enough ETH to fund a potential dispute considering the current required amount. Reimburses unused ETH. TRUSTED.
     *  @param _tokenID The ID of the token with the request to challenge.
     */
    function challengeRequest(bytes32 _tokenID) external payable {
        Token storage token = tokens[_tokenID];
        require(
            token.status == TokenStatus.RegistrationRequested || token.status == TokenStatus.ClearingRequested,
            "The token does not have any pending requests."
        );
        Request storage request = token.requests[token.requests.length - 1];
        require(now - request.submissionTime < challengePeriodDuration, "The challenge period has already passed.");
        require(request.challengerDepositTime == 0, "Request should have only the requester's deposit.");
        require(
            msg.value >= request.challengeRewardBalance,
            "Not enough ETH. The party challenging the request must pay the challenge deposit in full."
        );

        // Take the deposit and save the challenger's address.
        uint remainingETH = msg.value - request.challengeRewardBalance;
        request.challengeRewardBalance += request.challengeRewardBalance;
        request.parties[uint(Party.Challenger)] = msg.sender;
        request.challengerDepositTime = now; // Save the time the request left the challenge period and entered the arbitration fees funding period.
        emit ChallengeDepositPlaced(_tokenID, msg.sender);

        // Update the total amount required to fully fund the each side.
        // The amount required for each side is:
        //   total = arbitration cost + fee stake
        // where:
        //   fee stake = arbitration cost * multiplier
        Round storage round = request.rounds[request.rounds.length - 1];
        uint arbitrationCost = request.arbitrator.arbitrationCost(request.arbitratorExtraData);
        round.requiredForSide[uint(Party.Requester)] = arbitrationCost.addCap((arbitrationCost.mulCap(sharedStakeMultiplier)) / MULTIPLIER_PRECISION);
        round.requiredForSide[uint(Party.Challenger)] = arbitrationCost.addCap((arbitrationCost.mulCap(sharedStakeMultiplier)) / MULTIPLIER_PRECISION);

        // Take up to the amount necessary to fund the current round at the current costs.
        uint contribution;
        (contribution, remainingETH) = calculateContribution(remainingETH, round.requiredForSide[uint(Party.Challenger)]);
        round.contributions[msg.sender][uint(Party.Challenger)] = contribution;
        round.paidFees[uint(Party.Challenger)] = contribution;
        round.feeRewards += contribution;

        // Reimburse leftover ETH.
        msg.sender.send(remainingETH); // Deliberate use of send in order to not block the contract in case of reverting fallback.

        // Raise dispute if both sides are fully funded.
        if (round.paidFees[uint(Party.Requester)] >= round.requiredForSide[uint(Party.Requester)] &&
            round.paidFees[uint(Party.Challenger)] >= round.requiredForSide[uint(Party.Challenger)]) {

            request.disputeID = request.arbitrator.createDispute.value(arbitrationCost)(2, request.arbitratorExtraData);
            disputeIDToTokenID[request.disputeID] = _tokenID;
            request.disputed = true;
            emit Dispute(
                arbitrator,
                request.disputeID,
                token.status == TokenStatus.RegistrationRequested
                    ? metaEvidenceUpdates
                    : metaEvidenceUpdates + 1
            );

            request.rounds.length++;
            round.feeRewards -= arbitrationCost;

            emit TokenStatusChange(
                request.parties[uint(Party.Requester)],
                request.parties[uint(Party.Challenger)],
                _tokenID,
                token.status,
                true,
                false
            );
        } else if (round.paidFees[uint(Party.Requester)] >= round.paidFees[uint(Party.Challenger)]) {
            // Notify challenger if he must receive contributions to not lose the case.
            round.sidePendingFunds = Party.Challenger;
            emit WaitingOpponent(
                _tokenID,
                Party.Challenger,
                request.parties[uint(Party.Challenger)]
            );
        } else if (round.paidFees[uint(Party.Challenger)] > round.paidFees[uint(Party.Requester)] && round.sidePendingFunds == Party.Challenger) {
            // Notify requester if he must receive contributions to not lose the case.
            round.sidePendingFunds = Party.Requester;
            emit WaitingOpponent(
                _tokenID,
                Party.Requester,
                request.parties[uint(Party.Requester)]
            );
        }
    }

    /** @dev Takes up to the total amount required of arbitration fees and fee stakes required to create a dispute. Reimburses the rest. Creates a dispute if both sides are fully funded. TRUSTED.
     *  @param _tokenID The ID of the token with the request to fund.
     *  @param _side The recipient of the contribution.
     */
    function fundDispute(bytes32 _tokenID, Party _side) external payable {
        require(
            _side == Party.Requester || _side == Party.Challenger,
            "Recipient must be either the requester or challenger."
        );
        Token storage token = tokens[_tokenID];
        require(
            token.status == TokenStatus.RegistrationRequested || token.status == TokenStatus.ClearingRequested,
            "The token does not have any pending requests."
        );
        Request storage request = token.requests[token.requests.length - 1];
        require(!request.disputed, "The request must not be already disputed.");
        require(
            now - request.challengerDepositTime < arbitrationFeesWaitingTime,
            "The arbitration fees funding period is over."
        );
        if (_side == Party.Challenger)
            require(
                request.challengerDepositTime > 0,
                "A challenge deposit must be paid before the challenger can accept contributions."
            );

        // Update the total amount required for each side.
        // The amount required for each side is:
        //   total = arbitration cost + fee stake
        // where:
        //   fee stake = arbitration cost * multiplier
        Round storage round = request.rounds[request.rounds.length - 1];
        uint arbitrationCost = request.arbitrator.arbitrationCost(request.arbitratorExtraData);
        round.requiredForSide[uint(Party.Requester)] = arbitrationCost.addCap((arbitrationCost.mulCap(sharedStakeMultiplier)) / MULTIPLIER_PRECISION);
        round.requiredForSide[uint(Party.Challenger)] = arbitrationCost.addCap((arbitrationCost.mulCap(sharedStakeMultiplier)) / MULTIPLIER_PRECISION);

        // Take contribution.
        uint contribution;
        uint remainingETH = msg.value;
        (contribution, remainingETH) = calculateContribution(
            remainingETH,
            round.requiredForSide[uint(_side)].subCap(round.paidFees[uint(_side)])
        );
        round.contributions[msg.sender][uint(_side)] += contribution;
        round.paidFees[uint(_side)] += contribution;
        round.feeRewards += contribution;

        // Reimburse leftover ETH.
        msg.sender.send(remainingETH); // Deliberate use of send in order to not block the contract in case of reverting fallback.

        // Raise dispute if both sides are fully funded.
        if (round.paidFees[uint(Party.Requester)] >= round.requiredForSide[uint(Party.Requester)] &&
            round.paidFees[uint(Party.Challenger)] >= round.requiredForSide[uint(Party.Challenger)]) {

            request.disputeID = request.arbitrator.createDispute.value(arbitrationCost)(2, request.arbitratorExtraData);
            disputeIDToTokenID[request.disputeID] = _tokenID;
            request.disputed = true;
            emit Dispute(
                arbitrator,
                request.disputeID,
                token.status == TokenStatus.RegistrationRequested
                    ? metaEvidenceUpdates
                    : metaEvidenceUpdates + 1
            );

            request.rounds.length++;
            round.feeRewards -= arbitrationCost;

            emit TokenStatusChange(
                request.parties[uint(Party.Requester)],
                request.parties[uint(Party.Challenger)],
                _tokenID,
                token.status,
                true,
                false
            );
        } else if (round.paidFees[uint(Party.Requester)] >= round.paidFees[uint(Party.Challenger)] && round.sidePendingFunds == Party.Requester) {
            // Notify challenger if he must receive contributions to not lose the case.
            round.sidePendingFunds = Party.Challenger;
            emit WaitingOpponent(
                _tokenID,
                Party.Challenger,
                request.parties[uint(Party.Challenger)]
            );
        } else if (round.paidFees[uint(Party.Challenger)] > round.paidFees[uint(Party.Requester)] && round.sidePendingFunds == Party.Challenger) {
            // Notify requester if he must receive contributions to not lose the case.
            round.sidePendingFunds = Party.Requester;
            emit WaitingOpponent(
                _tokenID,
                Party.Requester,
                request.parties[uint(Party.Requester)]
            );
        }

    }

    /** @dev Takes up to the total amount required to fund a side of an appeal. Reimburses the rest. Creates an appeal if both sides are fully funded. TRUSTED.
     *  @param _tokenID The ID of the token with the request to fund.
     *  @param _side The recipient of the contribution.
     */
    function fundAppeal(bytes32 _tokenID, Party _side) external payable {
        require(
            _side == Party.Requester || _side == Party.Challenger,
            "Recipient must be either the requester or challenger."
        );
        Token storage token = tokens[_tokenID];
        require(
            token.status == TokenStatus.RegistrationRequested || token.status == TokenStatus.ClearingRequested,
            "The token does not have any pending requests."
        );
        Request storage request = token.requests[token.requests.length - 1];
        require(request.disputed, "A dispute must have been raised to fund an appeal.");
        (uint appealPeriodStart, uint appealPeriodEnd) = request.arbitrator.appealPeriod(request.disputeID);
        require(
            now >= appealPeriodStart && now < appealPeriodEnd,
            "Contributions must be made within the appeal period."
        );

        // Calculate the total amount required to fully fund the each side.
        // The amount required for each side is:
        //   total = arbitration cost + fee stake
        // where:
        //   fee stake = arbitration cost * multiplier
        Party winner;
        Party loser;
        Round storage round = request.rounds[request.rounds.length - 1];
        if (RulingOption(request.arbitrator.currentRuling(request.disputeID)) == RulingOption.Accept) {
            winner = Party.Requester;
            loser = Party.Challenger;
        } else if (RulingOption(request.arbitrator.currentRuling(request.disputeID)) == RulingOption.Refuse) {
            winner = Party.Challenger;
            loser = Party.Requester;
        }

        uint appealCost = request.arbitrator.appealCost(request.disputeID, request.arbitratorExtraData);
        if (winner == Party.None) {
            // Arbitrator did not rule or refused to rule.
            round.requiredForSide[uint(Party.Requester)] = appealCost.addCap((appealCost.mulCap(sharedStakeMultiplier)) / MULTIPLIER_PRECISION);
            round.requiredForSide[uint(Party.Challenger)] = appealCost.addCap((appealCost.mulCap(sharedStakeMultiplier)) / MULTIPLIER_PRECISION);
            round.requiredForSideSet[uint(Party.Requester)] = true;
            round.requiredForSideSet[uint(Party.Challenger)] = true;
        } else {
            // Arbitrator gave a decisive ruling.
            if (_side == loser)
                require(
                    now - appealPeriodStart < (appealPeriodEnd - appealPeriodStart) / 2,
                    "Contributions to the loser must be done in the first half of the appeal period."
                );


            if (now - appealPeriodStart < (appealPeriodEnd - appealPeriodStart) / 2) {
                // In first half of the appeal period. Update the amount required for each side.
                round.requiredForSide[uint(loser)] = appealCost.addCap((appealCost.mulCap(loserStakeMultiplier)) / MULTIPLIER_PRECISION);
                round.requiredForSide[uint(winner)] = appealCost.addCap((appealCost.mulCap(winnerStakeMultiplier)) / MULTIPLIER_PRECISION);
                round.requiredForSideSet[uint(winner)] = true;
                round.requiredForSideSet[uint(loser)] = true;
            } else {
                // In second half of appeal period. Update only the amount required to fully fund the winner.
                // The amount that must be paid by the winner is max(old appeal cost + old winner stake, new appeal cost).
                round.requiredForSide[uint(winner)] = round.requiredForSide[uint(winner)] > appealCost
                    ? round.requiredForSide[uint(winner)]
                    : appealCost;

                round.requiredForSideSet[uint(winner)] = true;
            }
        }

        // Take only the necessary ETH.
        uint contribution;
        uint remainingETH = msg.value;
        (contribution, remainingETH) = calculateContribution(
            remainingETH,
            round.requiredForSide[uint(_side)].subCap(round.paidFees[uint(_side)])
        );
        round.contributions[msg.sender][uint(_side)] += contribution;
        round.paidFees[uint(_side)] += contribution;
        round.feeRewards += contribution;

        // Reimburse leftover ETH.
        msg.sender.send(remainingETH); // Deliberate use of send in order to not block the contract in case of reverting fallback.

        // Raise appeal if both sides are fully funded.
        if (round.requiredForSideSet[uint(Party.Requester)] &&
            round.requiredForSideSet[uint(Party.Challenger)] &&
            round.paidFees[uint(Party.Requester)] >= round.requiredForSide[uint(Party.Requester)] &&
            round.paidFees[uint(Party.Challenger)] >= round.requiredForSide[uint(Party.Challenger)]) {

            round.appealed = true;
            request.arbitrator.appeal.value(appealCost)(request.disputeID, request.arbitratorExtraData);

            request.rounds.length++;
            round.feeRewards -= appealCost;

            emit TokenStatusChange(
                request.parties[uint(Party.Requester)],
                request.parties[uint(Party.Challenger)],
                _tokenID,
                token.status,
                true,
                true
            );
        } else if (round.paidFees[uint(Party.Requester)] >= round.paidFees[uint(Party.Challenger)] && round.sidePendingFunds == Party.Requester) {
            // Notify challenger if he must receive contributions to not lose the case.
            round.sidePendingFunds = Party.Challenger;
            emit WaitingOpponent(
                _tokenID,
                Party.Challenger,
                request.parties[uint(Party.Challenger)]
            );
        } else if (round.paidFees[uint(Party.Challenger)] > round.paidFees[uint(Party.Requester)] && round.sidePendingFunds == Party.Challenger) {
            // Notify requester if he must receive contributions to not lose the case.
            round.sidePendingFunds = Party.Requester;
            emit WaitingOpponent(
                _tokenID,
                Party.Requester,
                request.parties[uint(Party.Requester)]
            );
        }
    }

    /** @dev Reimburses contributions if no disputes were raised. If a dispute was raised, sends the fee stake rewards and reimbursements proportional to the contribtutions made to the winner of a dispute.
     *  @param _beneficiary The address that made contributions to a request.
     *  @param _tokenID The ID of the token submission with the request from which to withdraw.
     *  @param _request The request from which to withdraw.
     *  @param _round The round from which to withdraw.
     */
    function withdrawFeesAndRewards(address _beneficiary, bytes32 _tokenID, uint _request, uint _round) public {
        Token storage token = tokens[_tokenID];
        Request storage request = token.requests[_request];
        Round storage round = request.rounds[_round];
        require(
            request.resolved,
            "The request was not executed and/or there are disputes pending resolution."
        );

        uint reward;
        if (!request.disputed || request.ruling == RulingOption.Other) {
            // No disputes were raised, or there isn't a winner and loser. Reimburse contributions.
            uint rewardRequester = round.paidFees[uint(Party.Requester)] > 0
                ? (round.contributions[_beneficiary][uint(Party.Requester)] * round.feeRewards) / round.paidFees[uint(Party.Requester)]
                : 0;
            uint rewardChallenger = round.paidFees[uint(Party.Challenger)] > 0
                ? (round.contributions[_beneficiary][uint(Party.Challenger)] * round.feeRewards) / round.paidFees[uint(Party.Challenger)]
                : 0;

            reward = rewardRequester + rewardChallenger;
            round.contributions[_beneficiary][uint(Party.Requester)] = 0;
            round.contributions[_beneficiary][uint(Party.Challenger)] = 0;
        } else {
            Party winner;
            if (request.ruling == RulingOption.Accept)
                winner = Party.Requester;
            else
                winner = Party.Challenger;

            // Take rewards for funding the winner.
            reward = round.paidFees[uint(winner)] > 0
                ? (round.contributions[_beneficiary][uint(winner)] * round.feeRewards) / round.paidFees[uint(winner)]
                : 0;

            round.contributions[_beneficiary][uint(winner)] = 0;
        }

        emit RewardWithdrawal(_tokenID, _beneficiary, _request, _round,  reward);
        _beneficiary.transfer(reward);
    }

    /** @dev Withdraws rewards and reimbursements of multiple rounds at once. This function is O(n) where n is the number of rounds. This could exceed gas limits, therefore this function should be used only as a utility and not be relied upon by other contracts.
     *  @param _beneficiary The address that made contributions to the request.
     *  @param _tokenID The token ID with funds to be withdrawn.
     *  @param _request The request from which to withdraw contributions.
     *  @param _cursor The round from where to start withdrawing.
     *  @param _count The number of rounds to iterate. If set to 0 or a value larger than the number of rounds, iterates until the last round.
     */
    function batchRoundWithdraw(address _beneficiary, bytes32 _tokenID, uint _request, uint _cursor, uint _count) public {
        Token storage token = tokens[_tokenID];
        Request storage request = token.requests[_request];
        for (uint i = _cursor; (_count == 0 && i < request.rounds.length) || (_count > 0 && i < request.rounds.length && i < _count); i++)
            withdrawFeesAndRewards(_beneficiary, _tokenID, _request, _cursor);
    }

    /** @dev Withdraws rewards and reimbursements of multiple requests at once. This function is O(n*m) where n is the number of requests and m is the number of rounds. This could exceed gas limits, therefore this function should be used only as a utility and not be relied upon by other contracts.
     *  @param _beneficiary The address that made contributions to the request.
     *  @param _tokenID The token ID with funds to be withdrawn.
     *  @param _cursor The request from which to start withdrawing.
     *  @param _count The number of requests o iterate. If set to 0 or a value larger than the number of request, iterates until the last request.
     *  @param _roundCursor The round of each request from where to start withdrawing.
     *  @param _roundCount The number of rounds to iterate on each request. If set to 0 or a value larger than the number of rounds a request has, iteration for that request will stop at the last round.
     */
    function batchRequestWithdraw(
        address _beneficiary,
        bytes32 _tokenID,
        uint _cursor,
        uint _count,
        uint _roundCursor,
        uint _roundCount
    ) external {
        Token storage token = tokens[_tokenID];
        for (uint i = _cursor; (_count == 0 && i < token.requests.length) || (_count > 0 && i < token.requests.length && i < _count); i++)
            batchRoundWithdraw(_beneficiary, _tokenID, i, _roundCursor, _roundCount);
    }

    /** @dev Executes a request if the challenge period passed and no one challenged the request.
     *  @param _tokenID The ID of the token with the request to execute.
     */
    function executeRequest(bytes32 _tokenID) external {
        Token storage token = tokens[_tokenID];
        Request storage request = token.requests[token.requests.length - 1];
        require(request.challengerDepositTime == 0, "A party challenged the request.");
        require(
            now - request.submissionTime > challengePeriodDuration,
            "The time to challenge has not passed yet."
        );

        if (token.status == TokenStatus.RegistrationRequested)
            token.status = TokenStatus.Registered;
        else if (token.status == TokenStatus.ClearingRequested)
            token.status = TokenStatus.Absent;
        else
            revert("The token is in the wrong status for executing request.");

        // Deliberate use of send in order to not block the contract in case of reverting fallback.
        request.parties[uint(Party.Requester)].send(request.challengeRewardBalance);
        request.challengeRewardBalance = 0;
        request.resolved = true;

        emit TokenStatusChange(
            request.parties[uint(Party.Requester)],
            address(0x0),
            _tokenID,
            token.status,
            false,
            false
        );
    }

    /** @dev Rules in favor of the side that received the most fee contributions. Raises a dispute if decreases in arbitration cost mean both parties are fully funded. TRUSTED.
     *  @param _tokenID The ID of the token with the request to execute.
     */
    function timeout(bytes32 _tokenID) external {
        Token storage token = tokens[_tokenID];
        Request storage request = token.requests[token.requests.length - 1];
        require(!request.resolved, "The request is already resolved.");
        require(!request.disputed, "A dispute was raised for this request.");
        require(request.challengerDepositTime > 0, "A party must have challenged the request.");
        require(
            now - request.challengerDepositTime > arbitrationFeesWaitingTime,
            "There is still time to make a contribution."
        );

        // Decreases in arbitration costs could mean both sides are fully funded, in which case a dispute should be raised.
        // Update required amount for each side to check for this case.
        // The amount required for each side is:
        //   total = arbitration cost + fee stake
        // where:
        //   fee stake = arbitration cost * multiplier
        Round storage round = request.rounds[request.rounds.length - 1];
        uint arbitrationCost = request.arbitrator.arbitrationCost(request.arbitratorExtraData);
        round.requiredForSide[uint(Party.Requester)] = arbitrationCost.addCap((arbitrationCost.mulCap(sharedStakeMultiplier)) / MULTIPLIER_PRECISION);
        round.requiredForSide[uint(Party.Challenger)] = arbitrationCost.addCap((arbitrationCost.mulCap(sharedStakeMultiplier)) / MULTIPLIER_PRECISION);

        // Raise dispute if both sides are fully funded.
        if (round.paidFees[uint(Party.Requester)] >= round.requiredForSide[uint(Party.Requester)] &&
            round.paidFees[uint(Party.Challenger)] >= round.requiredForSide[uint(Party.Challenger)]) {

            request.disputeID = request.arbitrator.createDispute.value(arbitrationCost)(2, request.arbitratorExtraData);
            disputeIDToTokenID[request.disputeID] = _tokenID;
            request.disputed = true;
            emit Dispute(
                arbitrator,
                request.disputeID,
                token.status == TokenStatus.RegistrationRequested
                    ? metaEvidenceUpdates
                    : metaEvidenceUpdates + 1
            );

            request.rounds.length++;
            round.feeRewards -= arbitrationCost;

            emit TokenStatusChange(
                request.parties[uint(Party.Requester)],
                request.parties[uint(Party.Challenger)],
                _tokenID,
                token.status,
                true,
                false
            );
            return;
        }

        // Rule in favor of requester if he paid more or the same amount of the challenger. Rule in favor of challenger otherwise.
        Party winner;
        if (round.paidFees[uint(Party.Requester)] >= round.paidFees[uint(Party.Challenger)])
            winner = Party.Requester;
        else
            winner = Party.Challenger;

        // Update token state
        if (winner == Party.Requester) // Execute Request
            if (token.status == TokenStatus.RegistrationRequested)
                token.status = TokenStatus.Registered;
            else
                token.status = TokenStatus.Absent;
        else // Revert to previous state.
            if (token.status == TokenStatus.RegistrationRequested)
                token.status = TokenStatus.Absent;
            else if (token.status == TokenStatus.ClearingRequested)
                token.status = TokenStatus.Registered;

        // Reimburse deposit and send challenge reward.
        // Deliberate use of send in order to not block the contract in case the recipient refuses payments.
        if (winner == Party.Requester)
            request.parties[uint(Party.Requester)].send(request.challengeRewardBalance);
        else
            request.parties[uint(Party.Challenger)].send(request.challengeRewardBalance);

        request.challengeRewardBalance = 0;
        request.resolved = true;

        emit TokenStatusChange(
            request.parties[uint(Party.Requester)],
            request.parties[uint(Party.Challenger)],
            _tokenID,
            token.status,
            false,
            false
        );
    }

    /** @dev Give a ruling for a dispute. Can only be called by the arbitrator. TRUSTED.
     *  Overrides parent function to account for the situation where the winner loses a case due to paying less appeal fees than expected.
     *  @param _disputeID ID of the dispute in the arbitrator contract.
     *  @param _ruling Ruling given by the arbitrator. Note that 0 is reserved for "Not able/wanting to make a decision".
     */
    function rule(uint _disputeID, uint _ruling) public onlyArbitrator {
        RulingOption resultRuling = RulingOption(_ruling);
        bytes32 tokenID = disputeIDToTokenID[_disputeID];
        Token storage token = tokens[tokenID];
        Request storage request = token.requests[token.requests.length - 1];
        Round storage round = request.rounds[request.rounds.length - 1];

        // The ruling may be inverted depending on the amount of fee contributions received by each side.
        // Rule in favor of the party that received the most contributions, if there were contributions at all. Respect the ruling otherwise.
        // If the required amount for a party was never set, it means that side never received a contribution.
        if (round.requiredForSideSet[uint(Party.Requester)] && round.requiredForSideSet[uint(Party.Challenger)]) {
            // The amount required from both parties was set. Compare amounts.
            if (resultRuling == RulingOption.Other) {
                // Rule in favor of the requester if he received more or the same amount of contributions as the challenger. Rule in favor of the challenger otherwise.
                if (round.paidFees[uint(Party.Requester)] >= round.paidFees[uint(Party.Challenger)])
                    resultRuling = RulingOption.Accept;
                else
                    resultRuling = RulingOption.Refuse;
            } else {
                // Invert ruling if the loser fully funded but the winner did not. Respect the ruling otherwise.
                Party winner;
                Party loser;
                if (resultRuling == RulingOption.Accept) {
                    winner = Party.Requester;
                    loser = Party.Challenger;
                } else {
                    winner = Party.Challenger;
                    loser = Party.Requester;
                }

                if (round.paidFees[uint(loser)] >= round.requiredForSide[uint(loser)]) {
                    if (resultRuling == RulingOption.Refuse)
                        resultRuling = RulingOption.Accept;
                    else
                        resultRuling = RulingOption.Refuse;
                }
            }
        }

        emit Ruling(Arbitrator(msg.sender), _disputeID, uint(resultRuling));
        executeRuling(_disputeID, uint(resultRuling));
    }

    /** @dev Submit a reference to evidence. EVENT.
     *  @param _evidence A link to an evidence using its URI.
     */
    function submitEvidence(bytes32 _tokenID, string _evidence) external {
        Token storage token = tokens[_tokenID];
        Request storage request = token.requests[token.requests.length - 1];
        require(request.disputed, "The request is not disputed.");
        require(!request.resolved, "The dispute was resolved.");

        emit Evidence(arbitrator, request.disputeID, msg.sender, _evidence);
    }

    // ************************ //
    // *      Governance      * //
    // ************************ //

    /** @dev Change the duration of the challenge period.
     *  @param _challengePeriodDuration The new duration of the challenge period.
     */
    function changeTimeToChallenge(uint _challengePeriodDuration) external onlyGovernor {
        challengePeriodDuration = _challengePeriodDuration;
    }

    /** @dev Change the required amount required as deposit to make or challenge a request.
     *  @param _challengeReward The new amount of wei required to make or challenge a request.
     */
    function changeChallengeReward(uint _challengeReward) external onlyGovernor {
        challengeReward = _challengeReward;
    }

    /** @dev Change the governor of the token curated registry.
     *  @param _governor The address of the new governor.
     */
    function changeGovernor(address _governor) external onlyGovernor {
        governor = _governor;
    }

    /** @dev Change duration of the arbitration fees funding period.
     *  @param _arbitrationFeesWaitingTime The new duration of the arbitration fees funding period in seconds.
     */
    function changeArbitrationFeesWaitingTime(uint _arbitrationFeesWaitingTime) external onlyGovernor {
        arbitrationFeesWaitingTime = _arbitrationFeesWaitingTime;
    }

    /** @dev Change the percentage of arbitration fees that must be paid as fee stake by parties when there isn't a winner or loser.
     *  @param _sharedStakeMultiplier The new percentage of arbitration fees that must be paid as fee stake with 2 digits precision (e.g. a value of 1000 will result in 10% of the arbitration fees required as fee stake in that round).
     */
    function changeSharedStakeMultiplier(uint _sharedStakeMultiplier) external onlyGovernor {
        sharedStakeMultiplier = _sharedStakeMultiplier;
    }

    /** @dev Change the percentage of arbitration fees that must be paid as fee stake by winner of the previous round.
     *  @param _winnerStakeMultiplier The new percentage of arbitration fees that must be paid as fee stake with 2 digits precision (e.g. a value of 5000 will result in 50% of the arbitration fees required in that round).
     */
    function changeWinnerStakeMultiplier(uint _winnerStakeMultiplier) external onlyGovernor {
        winnerStakeMultiplier = _winnerStakeMultiplier;
    }

    /** @dev Change the percentage of arbitration fees that must be paid as fee stake by party that lost the previous round.
     *  @param _loserStakeMultiplier The new percentage of arbitration fees that must be paid as fee stake with 2 digits precision (e.g. a value of 10000 will result in 100% of the arbitration fees as fee stake required in that round).
     */
    function changeLoserStakeMultiplier(uint _loserStakeMultiplier) external onlyGovernor {
        loserStakeMultiplier = _loserStakeMultiplier;
    }

    /** @dev Change the arbitrator to be used for disputes that may be raised in the next requests. The arbitrator is trusted to support appeal periods and not reenter.
     *  @param _arbitrator The new trusted arbitrator to be used in the next requests.
     *  @param _arbitratorExtraData The extra data used by the new arbitrator.
     */
    function changeArbitrator(Arbitrator _arbitrator, bytes _arbitratorExtraData) external onlyGovernor {
        arbitrator = _arbitrator;
        arbitratorExtraData = _arbitratorExtraData;
    }

    /** @dev Update the meta evidence used for disputes.
     *  @param _registrationMetaEvidence The meta evidence to be used for future registration request disputes.
     *  @param _clearingMetaEvidence The meta evidence to be used for future clearing request disputes.
     */
    function changeMetaEvidence(string _registrationMetaEvidence, string _clearingMetaEvidence) external onlyGovernor {
        metaEvidenceUpdates++;
        emit MetaEvidence(metaEvidenceUpdates, _registrationMetaEvidence);
        emit MetaEvidence(metaEvidenceUpdates + 1, _clearingMetaEvidence);
    }

    /* Public Views */

    /** @dev Return true if the token is on the list.
     *  @param _tokenID The ID of the token to be queried.
     *  @return allowed True if the token is allowed, false otherwise.
     */
    function isPermitted(bytes32 _tokenID) external view returns (bool allowed) {
        Token storage token = tokens[_tokenID];
        return token.status == TokenStatus.Registered || token.status == TokenStatus.ClearingRequested;
    }

    /** @dev Returns token information. Includes length of requests array.
     *  @param _tokenID The ID of the queried token.
     *  @return The token information.
     */
    function getTokenInfo(bytes32 _tokenID)
        external
        view
        returns (
            string name,
            string ticker,
            address addr,
            string symbolMultihash,
            TokenStatus status,
            uint numberOfRequests
        )
    {
        Token storage token = tokens[_tokenID];
        return (
            token.name,
            token.ticker,
            token.addr,
            token.symbolMultihash,
            token.status,
            token.requests.length
        );
    }

    /** @dev Gets information on a request made for a token.
     *  @param _tokenID The ID of the queried token.
     *  @param _request The request to be queried.
     *  @return The request information.
     */
    function getRequestInfo(bytes32 _tokenID, uint _request)
        external
        view
        returns (
            bool disputed,
            uint disputeID,
            uint submissionTime,
            uint challengeRewardBalance,
            uint challengerDepositTime,
            bool resolved,
            address[3] parties,
            uint numberOfRounds,
            RulingOption ruling,
            Arbitrator arbitrator,
            bytes arbitratorExtraData
        )
    {
        Request storage request = tokens[_tokenID].requests[_request];
        return (
            request.disputed,
            request.disputeID,
            request.submissionTime,
            request.challengeRewardBalance,
            request.challengerDepositTime,
            request.resolved,
            request.parties,
            request.rounds.length,
            request.ruling,
            request.arbitrator,
            request.arbitratorExtraData
        );
    }

    /** @dev Gets the information on a round of a request.
     *  @param _tokenID The ID of the queried token.
     *  @param _request The request to be queried.
     *  @param _round The round to be queried.
     *  @return The round information.
     */
    function getRoundInfo(bytes32 _tokenID, uint _request, uint _round)
        external
        view
        returns (
            bool appealed,
            uint[3] paidFees,
            uint[3] requiredForSide,
            uint feeRewards
        )
    {
        Token storage token = tokens[_tokenID];
        Request storage request = token.requests[_request];
        Round storage round = request.rounds[_round];
        return (
            round.appealed,
            round.paidFees,
            round.requiredForSide,
            round.feeRewards
        );
    }

    /** @dev Gets the contributions made by a party for a given round of a request.
     *  @param _tokenID The ID of the token.
     *  @param _request The position of the request.
     *  @param _round The position of the round.
     *  @param _contributor The address of the contributor.
     *  @return The contributions.
     */
    function getContributions(
        bytes32 _tokenID,
        uint _request,
        uint _round,
        address _contributor
    ) external view returns(uint[3] contributions) {
        Token storage token = tokens[_tokenID];
        Request storage request = token.requests[_request];
        Round storage round = request.rounds[_round];
        contributions = round.contributions[_contributor];
    }

    /** @dev Return the numbers of tokens that were submitted. Includes tokens that never made it to the list or were later removed.
     *  @return The numbers of tokens in the list.
     */
    function tokenCount() external view returns (uint count) {
        return tokensList.length;
    }

    /* Internal */

    /**
     *  @dev Execute the ruling of a dispute.
     *  @param _disputeID ID of the dispute in the Arbitrator contract.
     *  @param _ruling Ruling given by the arbitrator. Note that 0 is reserved for "Not able/wanting to make a decision".
     */
    function executeRuling(uint _disputeID, uint _ruling) internal {
        bytes32 tokenID = disputeIDToTokenID[_disputeID];
        Token storage token = tokens[tokenID];
        Request storage request = token.requests[token.requests.length - 1];

        Party winner;
        if (RulingOption(_ruling) == RulingOption.Accept)
            winner = Party.Requester;
        else if (RulingOption(_ruling) == RulingOption.Refuse)
            winner = Party.Challenger;

        // Update token state
        if (winner == Party.Requester) // Execute Request
            if (token.status == TokenStatus.RegistrationRequested)
                token.status = TokenStatus.Registered;
            else
                token.status = TokenStatus.Absent;
        else // Revert to previous state.
            if (token.status == TokenStatus.RegistrationRequested)
                token.status = TokenStatus.Absent;
            else if (token.status == TokenStatus.ClearingRequested)
                token.status = TokenStatus.Registered;

        // Send challenge reward.
        // Deliberate use of send in order to not block the contract in case of reverting fallback.
        if (winner == Party.Challenger)
            request.parties[uint(Party.Challenger)].send(request.challengeRewardBalance);
        else if (winner == Party.Requester)
            request.parties[uint(Party.Requester)].send(request.challengeRewardBalance);
        else {
            // Reimburse parties.
            request.parties[uint(Party.Requester)].send(request.challengeRewardBalance / 2);
            request.parties[uint(Party.Challenger)].send(request.challengeRewardBalance / 2);
        }

        request.challengeRewardBalance = 0;
        request.resolved = true;
        request.ruling = RulingOption(_ruling);

        emit TokenStatusChange(
            request.parties[uint(Party.Requester)],
            request.parties[uint(Party.Challenger)],
            tokenID,
            token.status,
            request.disputed,
            false
        );
    }

     /** @dev Returns the contribution value and remainder from available ETH and required amount.
     *  @param _available The amount of ETH available for the contribution.
     *  @param _requiredAmount The amount of ETH required for the contribution.
     *  @return The amount of ETH taken.
     *  @return The amount of ETH left from the contribution.
     */
    function calculateContribution(uint _available, uint _requiredAmount)
        internal
        pure
        returns(uint taken, uint remainder)
    {
        if (_requiredAmount > _available)
            return (_available, 0); // Take whatever is available, return 0 as leftover ETH.

        remainder = _available - _requiredAmount;
        return (_requiredAmount, remainder);
    }

    /* Interface Views */

    /** @dev Return the summation of withdrawable wei of a request an account is elegible to. This function is O(n), where n is the number of rounds of the request. This could exceed the gas limit, therefore this function should only be used for interface display and not by other contracts.
     *  @param _tokenID The ID of the token to query.
     *  @param _beneficiary The contributor for which to query.
     *  @param _request The request from which to query for contributions.
     *  @return The total amount of wei available to withdraw.
     */
    function amountWithdrawable(bytes32 _tokenID, address _beneficiary, uint _request) external view returns (uint total){
        Request storage request = tokens[_tokenID].requests[_request];
        if (!request.resolved) return total;

        Party winner;
        if (request.ruling == RulingOption.Accept)
            winner = Party.Requester;
        else if (request.ruling == RulingOption.Refuse)
            winner = Party.Challenger;

        for (uint i = 0; i < request.rounds.length; i++) {
            Round storage round = request.rounds[i];
            if (!request.disputed || request.ruling == RulingOption.Other) {
                uint rewardRequester = round.paidFees[uint(Party.Requester)] > 0
                    ? (round.contributions[_beneficiary][uint(Party.Requester)] * round.feeRewards) / round.paidFees[uint(Party.Requester)]
                    : 0;
                uint rewardChallenger = round.paidFees[uint(Party.Challenger)] > 0
                    ? (round.contributions[_beneficiary][uint(Party.Challenger)] * round.feeRewards) / round.paidFees[uint(Party.Challenger)]
                    : 0;

                total += rewardRequester + rewardChallenger;
            } else {
                total += round.paidFees[uint(winner)] > 0
                    ? (round.contributions[_beneficiary][uint(winner)] * round.feeRewards) / round.paidFees[uint(winner)]
                    : 0;
            }
        }

        return total;
    }

    /** @dev Return the numbers of tokens with each status. This function is O(n), where n is the number of tokens. This could exceed the gas limit, therefore this function should only be used for interface display and not by other contracts.
     *  @return The numbers of tokens in the list per status.
     */
    function countByStatus()
        external
        view
        returns (
            uint absent,
            uint registered,
            uint registrationRequest,
            uint clearingRequest,
            uint challengedRegistrationRequest,
            uint challengedClearingRequest
        )
    {
        for (uint i = 0; i < tokensList.length; i++) {
            Token storage token = tokens[tokensList[i]];
            Request storage request = token.requests[token.requests.length - 1];

            if (token.status == TokenStatus.Absent) absent++;
            else if (token.status == TokenStatus.Registered) registered++;
            else if (token.status == TokenStatus.RegistrationRequested && !request.disputed) registrationRequest++;
            else if (token.status == TokenStatus.ClearingRequested && !request.disputed) clearingRequest++;
            else if (token.status == TokenStatus.RegistrationRequested && request.disputed) challengedRegistrationRequest++;
            else if (token.status == TokenStatus.ClearingRequested && request.disputed) challengedClearingRequest++;
        }
    }

    /** @dev Return the values of the tokens the query finds. This function is O(n), where n is the number of tokens. This could exceed the gas limit, therefore this function should only be used for interface display and not by other contracts.
     *  @param _cursor The ID of the token from which to start iterating. To start from either the oldest or newest item.
     *  @param _count The number of tokens to return.
     *  @param _filter The filter to use. Each element of the array in sequence means:
     *  - Include absent tokens in result.
     *  - Include registered tokens in result.
     *  - Include tokens with registration requests that are not disputed in result.
     *  - Include tokens with clearing requests that are not disputed in result.
     *  - Include disputed tokens with registration requests in result.
     *  - Include disputed tokens with clearing requests in result.
     *  - Include tokens submitted by the caller.
     *  - Include tokens challenged by the caller.
     *  @param _oldestFirst Whether to sort from oldest to the newest item.
     *  @param _tokenAddr A token addess. If set, will query all submissions for that address.
     *  @return The values of the tokens found and whether there are more tokens for the current filter and sort.
     */
    function queryTokens(bytes32 _cursor, uint _count, bool[8] _filter, bool _oldestFirst, address _tokenAddr)
        external
        view
        returns (bytes32[] values, bool hasMore)
    {
        uint cursorIndex;
        values = new bytes32[](_count);
        uint index = 0;

        bytes32[] storage list = _tokenAddr == address(0x0)
            ? tokensList
            : addressToSubmissions[_tokenAddr];

        if (_cursor == 0)
            cursorIndex = 0;
        else {
            for (uint j = 0; j < list.length; j++) {
                if (list[j] == _cursor) {
                    cursorIndex = j;
                    break;
                }
            }
            require(cursorIndex != 0, "The cursor is invalid.");
        }

        for (
                uint i = cursorIndex == 0 ? (_oldestFirst ? 0 : 1) : (_oldestFirst ? cursorIndex + 1 : list.length - cursorIndex + 1);
                _oldestFirst ? i < list.length : i <= list.length;
                i++
            ) { // Oldest or newest first.
            bytes32 tokenID = list[_oldestFirst ? i : list.length - i];
            Token storage token = tokens[tokenID];
            Request storage request = token.requests[token.requests.length - 1];
            if (
                /* solium-disable operator-whitespace */
                (_filter[0] && token.status == TokenStatus.Absent) ||
                (_filter[1] && token.status == TokenStatus.Registered) ||
                (_filter[2] && token.status == TokenStatus.RegistrationRequested && !request.disputed) ||
                (_filter[3] && token.status == TokenStatus.ClearingRequested && !request.disputed) ||
                (_filter[4] && token.status == TokenStatus.RegistrationRequested && request.disputed) ||
                (_filter[5] && token.status == TokenStatus.ClearingRequested && request.disputed) ||
                (_filter[6] && request.parties[uint(Party.Requester)] == msg.sender) || // My Submissions.
                (_filter[7] && request.parties[uint(Party.Challenger)] == msg.sender) // My Challenges.
                /* solium-enable operator-whitespace */
            ) {
                if (index < _count) {
                    values[index] = list[_oldestFirst ? i : list.length - i];
                    index++;
                } else {
                    hasMore = true;
                    break;
                }
            }
        }
    }
}
