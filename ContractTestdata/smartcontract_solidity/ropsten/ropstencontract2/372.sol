pragma solidity ^0.5.0;
import "./provableAPI.sol";


contract UptimeVerification is usingProvable{

    /** Owner of contract */
    address public owner;

    /** Caller of Update function */
    address caller;

    /** Check if update has been called */
    bool updateCalled;

    /** Registration Status of Customer */
    mapping(address => Customer) customerStatus;

    /** An Oracle call returns a query. Map to Boolean to check if it has been called earlier */
    mapping(bytes32=>bool) pendingQueries;

    /** Set returned Oracle call to offTimeValue */
    uint public offTimeValue;

    /** Create a struct named Customer.
    *   Here, add Registration Status, call status and call time
    */
    struct Customer {
        bool registerStatus;
        bool callerStatus;
        uint256 callTime;
    }

    //
    // Events - publicize actions to external listeners
    //
    event NewProvableQuery(string description);
    event NewOffTimeValue(string value);
    event LogUpdate(address indexed _owner, uint indexed _balance);

    //
    // Modifiers
    //
    modifier isOwner{require(msg.sender == owner, "Message Sender should be the owner of the contract"); _;}
    modifier isRegistered(address _address){require(customerStatus[_address].registerStatus == true, "Require address to be registered"); _;}
    modifier isUpdateNotCalled{require(updateCalled == false, "Check if update has been called, False check"); _;}
    modifier isUpdateCalled{require(updateCalled == true, "Check if update has been called, True check"); _;}
    modifier isCallerNull{require(caller == address(0x0), "Check if caller address is Null"); _;}
    modifier isCallerNotNull{require(caller != address(0x0), "Check if caller address is Not Null"); _;}
    modifier allowUpdate(address _address){require(now >= (customerStatus[_address].callTime) + 2 minutes, "2 minutes has passed since last update call"); _;}

    //
    // Functions
    //

    // Counstructor
    constructor() public payable {
        owner = msg.sender;
        customerStatus[owner].registerStatus = true;
        emit LogUpdate(owner, address(this).balance);
        update(); // Update views on contract creation...
    }

    /// @notice Callback function
    // Emit the appropriate event
    function __callback(bytes32 _myid, string memory _result) public {
        require(msg.sender == provable_cbAddress(), "Message sender should be equal to contract address");
        require(pendingQueries[_myid] == true, "This should be an already emitted ID");
        emit NewOffTimeValue(_result);
        offTimeValue = parseInt(_result);
        delete pendingQueries[_myid];
        // Do something with offTimeValue, like debiting the ISP if offTimeValue > X?
        if(offTimeValue > 75){
            this.debitisp();
        }
        updateCalled = false;
        customerStatus[caller].callerStatus == false;
        caller = address(0x0);
    }

    /// @notice Transfer ether to Customer if contract is breached
    /// @notice 1 finney = 10e15
    /// @notice Contract balance should be more than 5 finney
    /// @notice Caller registration status and caller status should be set to True
    function debitisp() public payable isUpdateCalled isCallerNotNull {
        require(address(this).balance >= 5 finney, "Check Balance of Contract");
        require(customerStatus[caller].registerStatus == true, "Check if caller is registered");
        require(customerStatus[caller].callerStatus == true, "Check if caller has called the update function");
        address(uint160(caller)).transfer(5 finney);
    }

    /// @notice Get balance of contract
    /// @return _balance The balance of the contract
    function getBalance() public view isRegistered(msg.sender) returns (uint _balance) {
        return address(this).balance;
    }

    /// @notice Get balance of Customer account
    //  Can only be called by a Registered Customer
    /// @return _balance The balance of the registered msg.sender
    function getCustomerBalance() public view isRegistered(msg.sender) returns (uint _balance) {
        return msg.sender.balance;
    }

    /// @notice Check registration Status of Customer
    /// @return _stat The registration status of the msg.sender
    function registrationStatus() public view returns (bool _stat) {
        return customerStatus[msg.sender].registerStatus;
    }

    /// @notice Register customer
    //  Can only be called by owner of contract
    function registerCustomer (address _address) public isOwner {
        customerStatus[_address].registerStatus = true;
    }

    /// @notice Un-Register customer
    //  Can only be called by owner of contract
    function deRegisterCustomer (address _address) public isOwner {
        customerStatus[_address].registerStatus = false;
    }

    /// @notice Update the uptime value by running the Provable service
    //  Emit the appropriate event
    //  Can only be called by a registered customer
    //  Modifier checks if update has been called by another Registered customer and prevents another call
    //  Modifier checks if 2 minutes has passed since last call from msg.sender who is a registered customer
    function update() public payable isRegistered(msg.sender) isUpdateNotCalled isCallerNull allowUpdate(msg.sender) {
        // Check if we have enough remaining funds
        if (provable_getPrice("URL") > address(this).balance) {
            emit NewProvableQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            updateCalled = true;
            caller = msg.sender;
            customerStatus[caller].callerStatus = true;
            customerStatus[caller].callTime = now;
            emit NewProvableQuery("Provable query was sent, standing by for the answer...");
            // Using XPath to to fetch the right element in the XML response
            bytes32 queryId = provable_query("URL", "xml(https://api.thingspeak.com/channels/800450/fields/6/last.xml).feed.field6");
            pendingQueries[queryId] = true;
        }
    }

}
