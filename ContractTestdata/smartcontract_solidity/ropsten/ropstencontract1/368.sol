/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity ^0.5.4;

// File: contracts/utility/Ownable.sol

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/utility/Approvable.sol

contract Approvable is Ownable {
    mapping(address => bool) private _approvedAddress;


    modifier onlyApproved() {
        require(isApproved());
        _;
    }

    function isApproved() public view returns(bool) {
        return _approvedAddress[msg.sender] || isOwner();
    }

    function approveAddress(address _address) public onlyOwner {
        _approvedAddress[_address] = true;
    }

    function revokeApproval(address _address) public onlyOwner {
        _approvedAddress[_address] = false;
    }
}

// File: contracts/VerityInsurance.sol

interface Resolver {
    function getResults() external view returns(bytes32[] memory);
}


contract VerityInsurance is Approvable {
    uint constant public minPremiumGrace = 1 hours;
    uint constant public minExpiryTime = 1 days;

    struct Balance {
        uint reserved;
        uint free;
    }
    Balance globalBalance;
    mapping(address => Balance) userBalance;

    enum PolicyState {
        AwaitingPayment,
        Active,
        ClaimOpened,
        AwaitingResolution,
        Claimable,
        ClaimRejected,
        Claimed
    }

    struct Policy {
        address insured;
        address insurer;
        uint premiumAmount;
        uint payoutAmount;
        uint paymentDueAt;
        uint expiresAt;
        PolicyState state;
        uint claimPos; // Storing position instead of index because default == 0
    }
    Policy[] policies;

    struct Claim {
        uint policyId;
        string proof;
        address resolver;
        bool validity;
    }
    Claim[] claims;

    // Indices of policies where an address acts as an 'insured'
    mapping(address => uint[]) insuredPolicies;

    // Indices of policies where an address acts as an 'insurer'
    mapping(address => uint[]) insurerPolicies;

    event PremiumPaymentReceived(uint indexed _policyId);
    event ClaimOpened(uint indexed _policyId);
    event ClaimResolverSet(uint indexed _policyId, address _resolver);
    event ClaimResolved(uint indexed _policyId, bool _accepted);
    event PayoutCalimed(uint indexed _policyId);

    constructor() public payable {
        // Store creators balance
        _addFreeBalance(msg.sender, msg.value);
    }

    function getPoliciesLen() public view returns(uint) {
        return policies.length;
    }

    function getPolicy(uint _policyId) public view returns(
        address insured,
        address insurer,
        uint premiumAmount,
        uint payoutAmount,
        uint paymentDueAt,
        uint expiresAt,
        PolicyState state
    ) {
        Policy memory _policy = policies[_policyId];

        insured = _policy.insured;
        insurer = _policy.insurer;
        premiumAmount = _policy.premiumAmount;
        payoutAmount = _policy.payoutAmount;
        paymentDueAt = _policy.paymentDueAt;
        expiresAt = _policy.expiresAt;
        state = _policy.state;
    }

    function getInsuredPolicies(address _address) public view returns(uint[] memory) {
        return insuredPolicies[_address];
    }

    function getInsurerPolicies(address _address) public view returns(uint[] memory) {
        return insurerPolicies[_address];
    }

    function getUserBalance(address _address) public view returns(uint[2] memory) {
        return [userBalance[_address].free, userBalance[_address].reserved];
    }

    function getGlobalBalance() public view returns(uint[2] memory) {
        return [globalBalance.free, globalBalance.reserved];
    }

    function createPolicy
    (
        address _insured,
        uint _premiumAmount,
        uint _paymentDueIn,
        uint _expiresAt,
        uint _payoutAmount
    )
        public
        payable
        onlyApproved
    {
        _addFreeBalance(msg.sender, msg.value);
        _reserveBalance(msg.sender, _payoutAmount);

        Policy memory _policy;
        _policy.insured = _insured;
        _policy.insurer = msg.sender;
        _policy.premiumAmount = _premiumAmount;
        _policy.payoutAmount = _payoutAmount;
        _policy.state = PolicyState.AwaitingPayment;

        // Ensure a minimum premium payment grace period
        _policy.paymentDueAt = now + (_paymentDueIn > minPremiumGrace ? _paymentDueIn : minPremiumGrace);

        // Ensure a minimum expiry time of 1 day from transaction mined time
        _policy.expiresAt = _expiresAt - now < minExpiryTime ? now + minExpiryTime : _expiresAt;

        //TODO: _policy.paymentDueAt < _policy.expiresAt ???

        insuredPolicies[_insured].push(policies.length);
        insurerPolicies[msg.sender].push(policies.length);
        policies.push(_policy);
    }

    function payPremium(uint _policyId) public payable {
        Policy storage _policy = policies[_policyId];

        require(
            msg.sender == _policy.insured,
            "Only insured person can pay premium."
        );
        require(
            now <= _policy.paymentDueAt,
            "Premium payment time expired."
        );
        require(
            msg.value >= _policy.premiumAmount,
            "Not enough balance sent."
        );

        // Activate the policy
        _addFreeBalance(_policy.insurer, _policy.premiumAmount);
        _policy.state = PolicyState.Active;
        emit PremiumPaymentReceived(_policyId);

        // Return the remaining balance
        uint _remainingBalance = msg.value - _policy.premiumAmount;
        if(_remainingBalance > 0) {
            msg.sender.transfer(_remainingBalance);
        }
    }

    function openClaim(uint _policyId, string memory _proof) public {
        Policy storage _policy = policies[_policyId];

        require(
            now < _policy.expiresAt,
            "Policy expired."
        );
        require(
            msg.sender == _policy.insured,
            "Only the insured person can open a claim."
        );
        require(
            _policy.state == PolicyState.Active,
            "Policy not active."
        );

        _policy.state = PolicyState.ClaimOpened;
        emit ClaimOpened(_policyId);

        Claim memory _claim;
        _claim.policyId = _policyId;
        _claim.proof = _proof;

        claims.push(_claim);

        _policy.claimPos = claims.length;
    }

    function getClaim(uint _policyId) public view returns(string memory proof, address resolver) {
        if(policies[_policyId].claimPos != 0) {
            return (
                claims[policies[_policyId].claimPos - 1].proof,
                claims[policies[_policyId].claimPos - 1].resolver
            );
        } else {
            return ("", address(0x0));
        }
    }

    function setResolver(uint _policyId, address _resolver) public onlyApproved {
        require(
            policies[_policyId].state == PolicyState.ClaimOpened,
            "No active claim."
        );

        claims[policies[_policyId].claimPos - 1].resolver = _resolver;
        policies[_policyId].state = PolicyState.AwaitingResolution;
        emit ClaimResolverSet(_policyId, _resolver);
    }

    function setResolution(uint _policyId, bool _validity) public onlyApproved {
        require(
            policies[_policyId].state == PolicyState.AwaitingResolution,
            "Not awaiting resolution."
        );

        Policy storage _policy = policies[_policyId];
        claims[_policy.claimPos - 1].validity = _validity;

        if(_validity) {
            _policy.state = PolicyState.Claimable;
        } else {
            _policy.state = PolicyState.ClaimRejected;
        }

        emit ClaimResolved(_policyId, _validity);
    }

    function checkResolution(uint _policyId) public {
        require(
            policies[_policyId].state == PolicyState.AwaitingResolution,
            "Not awaiting resolution."
        );
        address _resolver = claims[policies[_policyId].claimPos - 1].resolver;
        bytes32[] memory _results = Resolver(_resolver).getResults();

        Policy storage _policy = policies[_policyId];
        bool _validity;

        if(_results[0] == "true") {
            _validity = true;
            _policy.state = PolicyState.Claimable;
        } else if(_results[0] == "false") {
            _validity = false;
            _policy.state = PolicyState.ClaimRejected;
        } else {
            return;
        }

        claims[_policy.claimPos - 1].validity = _validity;
        emit ClaimResolved(_policyId, _validity);
    }

    function claimPayout(uint _policyId) public {
        Policy storage _policy = policies[_policyId];

        require(_policy.state == PolicyState.Claimable, "Can not claim.");
        require(_policy.insured == msg.sender, "Not the insured.");

        msg.sender.transfer(_policy.payoutAmount);
        _spendReserveBalance(_policy.insurer, _policy.payoutAmount);
        _policy.state = PolicyState.Claimed;
    }

    function withdrawFunds() public {
        if(userBalance[msg.sender].free > 0) {
            msg.sender.transfer(userBalance[msg.sender].free);
            _removeFreeBalance(msg.sender, userBalance[msg.sender].free);
        }
    }

    function depositFunds() public payable {
        if(msg.value > 0) {
            _addFreeBalance(msg.sender, msg.value);
        }
    }

    function _reserveBalance(address _user, uint _amount) private {
        require(
            userBalance[_user].free >= _amount,
            "Not enough balance to reserve amount."
        );
        userBalance[_user].free -= _amount;
        userBalance[_user].reserved += _amount;

        globalBalance.free -= _amount;
        globalBalance.reserved += _amount;
    }

    function _spendReserveBalance(address _user, uint _amount ) private {
        globalBalance.reserved -= _amount;
        userBalance[_user].reserved -= _amount;
    }

    function _addFreeBalance(address _user, uint _amount) private {
        globalBalance.free += _amount;
        userBalance[_user].free += _amount;
    }

    function _removeFreeBalance(address _user, uint _amount) private {
        _addFreeBalance(_user, -_amount);
    }
}
