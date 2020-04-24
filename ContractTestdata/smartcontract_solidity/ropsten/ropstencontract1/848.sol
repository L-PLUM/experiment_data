/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity ^0.5.0;

// File: /Users/jamesmorgan/Dropbox/workspace-blockrocket/digital-oracles-prototype/node_modules/openzeppelin-solidity/contracts/access/Roles.sol

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: /Users/jamesmorgan/Dropbox/workspace-blockrocket/digital-oracles-prototype/node_modules/openzeppelin-solidity/contracts/access/roles/WhitelistAdminRole.sol

/**
 * @title WhitelistAdminRole
 * @dev WhitelistAdmins are responsible for assigning and removing Whitelisted accounts.
 */
contract WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistAdminAdded(address indexed account);
    event WhitelistAdminRemoved(address indexed account);

    Roles.Role private _whitelistAdmins;

    constructor () internal {
        _addWhitelistAdmin(msg.sender);
    }

    modifier onlyWhitelistAdmin() {
        require(isWhitelistAdmin(msg.sender));
        _;
    }

    function isWhitelistAdmin(address account) public view returns (bool) {
        return _whitelistAdmins.has(account);
    }

    function addWhitelistAdmin(address account) public onlyWhitelistAdmin {
        _addWhitelistAdmin(account);
    }

    function renounceWhitelistAdmin() public {
        _removeWhitelistAdmin(msg.sender);
    }

    function _addWhitelistAdmin(address account) internal {
        _whitelistAdmins.add(account);
        emit WhitelistAdminAdded(account);
    }

    function _removeWhitelistAdmin(address account) internal {
        _whitelistAdmins.remove(account);
        emit WhitelistAdminRemoved(account);
    }
}

// File: openzeppelin-solidity/contracts/access/roles/WhitelistedRole.sol

/**
 * @title WhitelistedRole
 * @dev Whitelisted accounts have been approved by a WhitelistAdmin to perform certain actions (e.g. participate in a
 * crowdsale). This role is special in that the only accounts that can add it are WhitelistAdmins (who can also remove
 * it), and not Whitelisteds themselves.
 */
contract WhitelistedRole is WhitelistAdminRole {
    using Roles for Roles.Role;

    event WhitelistedAdded(address indexed account);
    event WhitelistedRemoved(address indexed account);

    Roles.Role private _whitelisteds;

    modifier onlyWhitelisted() {
        require(isWhitelisted(msg.sender));
        _;
    }

    function isWhitelisted(address account) public view returns (bool) {
        return _whitelisteds.has(account);
    }

    function addWhitelisted(address account) public onlyWhitelistAdmin {
        _addWhitelisted(account);
    }

    function removeWhitelisted(address account) public onlyWhitelistAdmin {
        _removeWhitelisted(account);
    }

    function renounceWhitelisted() public {
        _removeWhitelisted(msg.sender);
    }

    function _addWhitelisted(address account) internal {
        _whitelisteds.add(account);
        emit WhitelistedAdded(account);
    }

    function _removeWhitelisted(address account) internal {
        _whitelisteds.remove(account);
        emit WhitelistedRemoved(account);
    }
}

// File: contracts/DigitalOracles.sol

contract DigitalOracles is WhitelistedRole {

    struct Contract {
        uint256 contractId;          // The contract ID
        uint256 creationDate;        // When the contract was created
        uint256 partyA;              // Party B ID
        uint256 partyB;              // Party A ID
        string contractData;         // The IPFS hash of the approved contract
        State state;                 // The contract state

        uint256 replacementContractId; // This ID will be set when the contract moves into the state

        uint256 startDate;           // Project start date
        uint256 endDate;             // Project end date

        ContractDuration duration;  // Duration of the project (indefinitely or fixed term)
        bool contractHasValue;      // Will the Parties receive remuneration for work done?

        PaymentFrequency paymentFrequency;  // When will the client be paid?
        uint256 paymentFrequencyValue;      // The corresponding payment terms value e.g. a percentage, a date or a monetary value

        ClientPaymentTerms clientPaymentTerms;  // The client will pay the invoice
        uint256 clientPaymentTermsValue;        // The corresponding client payment terms value e.g. a number of dates
    }

    enum State {
        Blank, // not set
        Pending, // pending awaiting details
        Approved, // approved, details received
        Terminated, // terminated the contract
        Replaced    // replaced by new contract
    }

    enum ContractDuration {
        Blank, // not set
        Indefinite, // indefinitely until termination
        FixedTerm // based on project start/end
    }

    enum PaymentFrequency {
        Blank, // not set
        HourlyRate, // A set hourly rate
        Daily, // invoiceable daily
        Weekly, // invoiceable weekly
        Monthly, // invoiceable monthly
        Yearly, // invoiceable yearly
        OnCompletion, // when work is complete
        PercentageUpFront, // a percentage upfront, remaining on completion
        OnDate // On a specific date
    }

    enum ClientPaymentTerms {
        Blank, // not set
        UponReceipt, // when receipt is received
        WithXDays // within a certain number of days
    }

    enum InvoiceStatus {
        Blank,
        Pending,
        Paid,
        Refunded,
        Delayed
    }

    ////////////
    // Events //
    ////////////

    // Contract created - fired only one per contract
    event ContractCreated(uint256 indexed contractId, uint256 indexed partyA, uint256 indexed partyB, string contractData);

    // Contract state updates
    event ContractApproved(uint256 indexed contractId);
    event ContractTerminated(uint256 indexed contractId);
    event ContractReplaced(uint256 indexed contractId, uint256 indexed replacementContractId);

    // Contract property update events
    event ContractStateChanged(uint256 indexed contractId, State originalValue, State newValue);
    event ContractStartDateChanged(uint256 indexed contractId, uint256 originalValue, uint256 newValue);
    event ContractEndDateChanged(uint256 indexed contractId, uint256 originalValue, uint256 newValue);
    event ContractHasValueChanged(uint256 indexed contractId, bool originalValue, bool newValue);

    // Invoice events
    event InvoiceAdded(uint256 indexed contractId, uint256 indexed invoiceId, InvoiceStatus indexed invoiceStatus);
    event InvoiceStateChanged(uint256 indexed contractId, uint256 indexed invoiceId, InvoiceStatus originalState, InvoiceStatus newStatus);

    // Contract ID -> Contract
    mapping(uint256 => Contract) contracts;

    // Contract ID -> Invoice IDs
    mapping(uint256 => uint256[]) invoicesIds;

    // Invoice ID -> Invoice
    mapping(uint256 => InvoiceStatus) invoiceToInvoiceStatus; // once in state Pending, dont allow to move back to this state

    // Invoice ID => Contract ID
    mapping(uint256 => uint256) invoiceToContractId; // reverse lookups and checking if invoice is attached to another contract

    /////////////////
    // Constructor //
    /////////////////

    constructor () public{
        super.addWhitelisted(msg.sender);
    }

    /////////////////////
    // Contract Setup //
    /////////////////////

    function createContract(
        uint256 _contractId,
        uint256 _startDate,
        uint256 _endDate,
        uint256 _partyA,
        uint256 _partyB,
        string memory _contractData,
        ContractDuration _duration,
        bool _contractHasValue,
        PaymentFrequency _paymentFrequency,
        uint256 _paymentFrequencyValue,
        ClientPaymentTerms _clientPaymentTerms,
        uint256 _clientPaymentTermsValue
    )
    onlyWhitelisted
    public returns (uint256 _id) {
        require(_contractId != 0, "Invalid contract ID");
        require(_partyA != 0, "Invalid party ID");
        require(_partyB != 0, "Invalid party ID");
        require(contracts[_contractId].state == State.Blank, "Contract already created");

        // Create Contract
        contracts[_contractId] = Contract(
            _contractId,
            now, // creation date
            _partyA,
            _partyB,
            _contractData,
            State.Pending,
            0, // set replacement ID to blank on creation
            _startDate,
            _endDate,
            _duration,
            _contractHasValue,
            _paymentFrequency,
            _paymentFrequencyValue,
            _clientPaymentTerms,
            _clientPaymentTermsValue
        );

        emit ContractCreated(_contractId, _partyA, _partyB, _contractData);

        return _contractId;
    }

    function updateContractState(uint256 _contractId, State _state)
    onlyWhitelisted
    public returns (uint256 _id) {
        require(_contractId != 0, "Invalid contract ID");
        require(contracts[_contractId].state != State.Blank, "Contract not created");

        State originalState = contracts[_contractId].state;

        contracts[_contractId].state = _state;

        emit ContractStateChanged(_contractId, originalState, _state);

        return _contractId;
    }

    function updateContractStartDate(uint256 _contractId, uint256 _startDate)
    onlyWhitelisted
    public returns (uint256 _id) {
        require(_contractId != 0, "Invalid contract ID");
        require(_startDate != 0, "Start date not valid");
        require(contracts[_contractId].state != State.Blank, "Contract not created");

        uint256 originalStartDate = contracts[_contractId].startDate;

        contracts[_contractId].startDate = _startDate;

        emit ContractStartDateChanged(_contractId, originalStartDate, _startDate);

        return _contractId;
    }

    function updateContractEndDate(uint256 _contractId, uint256 _endDate)
    onlyWhitelisted
    public returns (uint256 _id) {
        require(_contractId != 0, "Invalid contract ID");
        require(_endDate != 0, "End date not valid");
        require(contracts[_contractId].state != State.Blank, "Contract not created");

        uint256 originalEndDate = contracts[_contractId].endDate;

        contracts[_contractId].endDate = _endDate;

        emit ContractEndDateChanged(_contractId, originalEndDate, _endDate);

        return _contractId;
    }

    function updateContractHasValue(uint256 _contractId, bool _contractHasValue)
    onlyWhitelisted
    public returns (uint256 _id) {
        require(_contractId != 0, "Invalid contract ID");
        require(contracts[_contractId].state != State.Blank, "Contract not created");

        bool originalContractHasValue = contracts[_contractId].contractHasValue;

        contracts[_contractId].contractHasValue = _contractHasValue;

        emit ContractHasValueChanged(_contractId, originalContractHasValue, _contractHasValue);

        return _contractId;
    }

    function replaceContract(uint256 _contractId, uint256 _replacementContractId)
    onlyWhitelisted
    public returns (uint256 _id) {
        require(_contractId != 0, "Invalid contract ID");
        require(contracts[_contractId].state != State.Terminated, "Contract is already terminated");
        require(contracts[_replacementContractId].state != State.Blank, "Replacement contract not created");

        contracts[_contractId].state = State.Replaced;
        contracts[_contractId].replacementContractId = _replacementContractId;

        emit ContractReplaced(_contractId, _replacementContractId);

        return _contractId;
    }

    function approveContract(uint256 _contractId)
    onlyWhitelisted
    public returns (uint256 _id) {
        require(_contractId != 0, "Invalid contract ID");
        require(contracts[_contractId].state == State.Pending, "Contract not in pending state");

        contracts[_contractId].state = State.Approved;

        emit ContractApproved(_contractId);

        return _contractId;
    }

    function terminateContract(uint256 _contractId)
    onlyWhitelisted
    public returns (uint256 _id) {
        require(_contractId != 0, "Invalid contract ID");
        require(contracts[_contractId].state == State.Pending || contracts[_contractId].state == State.Approved, "Contract not in pending or approved state");

        contracts[_contractId].state = State.Terminated;

        emit ContractTerminated(_contractId);

        return _contractId;
    }

    function addInvoiceToContract(uint256 _contractId, uint256 _invoiceId, InvoiceStatus _invoiceStatus)
    onlyWhitelisted
    public returns (uint256 _id) {
        // Method arg validation
        require(_contractId != 0, "Invalid contract ID");
        require(_invoiceId != 0, "Invalid invoice ID");
        require(_invoiceStatus != InvoiceStatus.Blank, "Cannot add a invoice in the state blank");

        // Invoice mapping validation
        require(contracts[_contractId].state == State.Pending || contracts[_contractId].state == State.Approved, "Contract not in pending or approved state");
        require(invoiceToContractId[_invoiceId] == 0, "Cannot add invoice to multiple contracts");
        require(invoiceToInvoiceStatus[_invoiceId] == InvoiceStatus.Blank, "Cannot add a invoice as already created");

        // TODO the below is GAS expensive (check for optimisations)

        // Update contract to invoice mapping
        invoicesIds[_contractId].push(_invoiceId);

        // Update invoice to contract mapping
        invoiceToContractId[_invoiceId] = _contractId;

        // Update invoice state
        invoiceToInvoiceStatus[_invoiceId] = _invoiceStatus;

        emit InvoiceAdded(_contractId, _invoiceId, _invoiceStatus);

        return _invoiceId;
    }

    function updateInvoiceState(uint256 _contractId, uint256 _invoiceId, InvoiceStatus _invoiceStatus)
    onlyWhitelisted
    public returns (uint256 _id) {
        // Method arg validation
        require(_contractId != 0, "Invalid contract ID");
        require(_invoiceId != 0, "Invalid invoice ID");
        require(_invoiceStatus != InvoiceStatus.Blank, "Cannot add a invoice in the state blank");
        require(_invoiceStatus != InvoiceStatus.Pending, "Cannot move back to pending");

        // Invoice mapping validation
        require(contracts[_contractId].state == State.Pending || contracts[_contractId].state == State.Approved, "Contract not in pending or approved state");
        require(invoiceToContractId[_invoiceId] == _contractId, "Contract not associated to invoice");
        require(invoiceToInvoiceStatus[_invoiceId] != InvoiceStatus.Blank, "Invoice not created yet");

        InvoiceStatus originalStatus = invoiceToInvoiceStatus[_invoiceId];

        // Update invoice state
        invoiceToInvoiceStatus[_invoiceId] = _invoiceStatus;

        emit InvoiceStateChanged(_contractId, _invoiceId, originalStatus, _invoiceStatus);

        return _invoiceId;
    }

    ///////////////////
    // Query Methods //
    ///////////////////

    function getContractDetails(uint256 _contractId)
    external view
    returns (
        uint256 creationDate,
        uint256 startDate,
        uint256 endDate,
        uint256 partyA,
        uint256 partyB,
        State state,
        ContractDuration duration,
        string memory contractData
    ) {
        Contract memory _contract = contracts[_contractId];
        return (
        _contract.creationDate,
        _contract.startDate,
        _contract.endDate,
        _contract.partyA,
        _contract.partyB,
        _contract.state,
        _contract.duration,
        _contract.contractData
        );
    }

    function getContractTerms(uint256 _contractId)
    external view
    returns (
        bool contractHasValue,
        PaymentFrequency paymentFrequency,
        uint256 paymentFrequencyValue,
        ClientPaymentTerms clientPaymentTerms,
        uint256 clientPaymentTermsValue
    ) {
        Contract memory _contract = contracts[_contractId];
        return (
        _contract.contractHasValue,
        _contract.paymentFrequency,
        _contract.paymentFrequencyValue,
        _contract.clientPaymentTerms,
        _contract.clientPaymentTermsValue
        );
    }

    function getContractInvoices(uint256 _contractId)
    external view
    returns (uint256[] memory invoiceIds) {
        return invoicesIds[_contractId];
    }

    function getContractInvoiceDetails(uint256 _invoiceId)
    external view
    returns (
        InvoiceStatus invoiceStatus,
        uint256 contractId
    ) {
        return (
        invoiceToInvoiceStatus[_invoiceId],
        invoiceToContractId[_invoiceId]
        );
    }

}
