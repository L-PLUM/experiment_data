pragma solidity ^0.5.0;
import "./provableAPI.sol";


contract UptimeVerification is usingProvable{

    address public owner;

    address caller;

    bool updateCalled;

    /** An Oracle call returns a query. Map to Boolean to check if it has been called earlier */
    mapping(bytes32=>bool) pendingQueries;

    //mapping(address => bool) registerStatus;
    mapping(address => Customer) customerStatus;

    /* Create a struct named Customer.
    Here, add Registration Status and call status
  */
    struct Customer {
        bool registerStatus;
        bool callerStatus;
        uint256 callTime;
    }

    /** Set returned Oracle call to offTimeValue */
    uint public offTimeValue;

    //  uint public debitAmount;
    //  mapping (address => uint) private balances;
    //
    // Events - publicize actions to external listeners
    //
    event NewOraclizeQuery(string description);
    event NewOffTimeValue(string value);
    event LogUpdate(address indexed _owner, uint indexed _balance);

    modifier isOwner{ require(msg.sender == owner); _;}
    modifier isRegistered(address _address){ require(customerStatus[_address].registerStatus == true); _;}
    modifier isUpdateNotCalled{ require(updateCalled == false); _;}
    modifier isUpdateCalled{ require(updateCalled == true); _;}
    modifier isCallerNull{require(caller == address(0x0)); _;}
    modifier isCallerNotNull{require(caller != address(0x0)); _;}
    modifier allowUpdate(address _address){require(now >= (customerStatus[_address].callTime) + 5 minutes); _;}

    //
    // Functions
    //

    // Counstructor
    constructor() public payable{
    //      debitAmount = 20;
        owner = msg.sender;
        customerStatus[owner].registerStatus = true;
        emit LogUpdate(owner, address(this).balance);
        //OAR = ProvableAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);
        update(); // Update views on contract creation...
    }

    // Fallback function - Called if other functions don't match call or
    // sent ether without data
    // Typically, called when invalid data is sent
    // Added so ether sent to this contract is reverted if the contract fails
    // otherwise, the sender's money is transferred to contract
    // function() external {
    //     revert();
    // }

    function __callback(bytes32 _myid, string memory _result) public {
        require(msg.sender == provable_cbAddress(), "Message sender should be equal to contract address");
        require(pendingQueries[_myid] == true, "This should be an already emitted ID");
        emit NewOffTimeValue(_result);
        offTimeValue = parseInt(_result);
        delete pendingQueries[_myid];
        // Do something with viewsCount, like tipping the author if viewsCount > X?
        if(offTimeValue > 75){
            this.debitisp();
        }
        updateCalled = false;
        customerStatus[caller].callerStatus == false;
        caller = address(0x0);
    }

    function debitisp() public payable isUpdateCalled isCallerNotNull {
        require(address(this).balance >= 5000000, "Check Balance of Contract");
        require(customerStatus[caller].registerStatus == true, "Check if caller is registered");
        require(customerStatus[caller].callerStatus == true, "Check if caller has called the update function");
        address(uint160(caller)).transfer(5000000);
    }

    function getBalance() public view isRegistered(msg.sender) returns (uint _balance) {
        return address(this).balance;
    }

    function getCustomerBalance() public view isRegistered(msg.sender) returns (uint _balance) {
        return msg.sender.balance;
    }

    function registrationStatus() public view returns (bool _stat) {
        return customerStatus[msg.sender].registerStatus;
    }

    function registerCustomer (address _address) public isOwner {
        customerStatus[_address].registerStatus = true;
    }

    function deRegisterCustomer (address _address) public isOwner {
        customerStatus[_address].registerStatus = false;
    }

    // function withdrawGood(uint amount) {
    //     require(balances[msg.sender] >= amount);
    //     balances[msg.sender] -= amount;
    //     msg.sender.transfer(amount);
    // }

    /// @notice Update the uptime value by running the Oracle service
    // Emit the appropriate event
    function update() public payable isRegistered(msg.sender) isUpdateNotCalled isCallerNull allowUpdate(msg.sender) {
        // Check if we have enough remaining funds
        if (provable_getPrice("URL") > address(this).balance) {
            emit NewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            updateCalled = true;
            caller = msg.sender;
            customerStatus[caller].callerStatus = true;
            customerStatus[caller].callTime = now;
            emit NewOraclizeQuery("Oraclize query was sent, standing by for the answer...");
            //oraclize_query("URL", "json(https://api.thingspeak.com/channels/800450/fields/6/last.json).field6");
            // Using XPath to to fetch the right element in the XML response
            bytes32 queryId = provable_query("URL", "xml(https://api.thingspeak.com/channels/800450/fields/6/last.xml).feed.field6");
            pendingQueries[queryId] = true;
        }
    }

}
