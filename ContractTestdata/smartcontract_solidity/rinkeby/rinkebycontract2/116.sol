/**
 *Submitted for verification at Etherscan.io on 2019-08-08
*/

/**
 *Submitted for verification at Etherscan.io on 2019-07-17
*/

/**
 *Submitted for verification at Etherscan.io on 2019-03-21
*/

pragma solidity 0.5.8; /*


___________________________________________________________________
  _      _                                        ______           
  |  |  /          /                                /              
--|-/|-/-----__---/----__----__---_--_----__-------/-------__------
  |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     
__/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_
    
       
        .----------------.  .----------------.  .----------------. 
    | .--------------. || .--------------. || .--------------. |
    | |    _______   | || |      __      | || | ____    ____ | |
    | |   /  ___  |  | || |     /  \     | || ||_   \  /   _|| |
    | |  |  (__ \_|  | || |    / /\ \    | || |  |   \/   |  | |
    | |   '.___`-.   | || |   / ____ \   | || |  | |\  /| |  | |
    | |  |`\____) |  | || | _/ /    \ \_ | || | _| |_\/_| |_ | |
    | |  |_______.'  | || ||____|  |____|| || ||_____||_____|| |
    | |              | || |              | || |              | |
    | '--------------' || '--------------' || '--------------' |
     '----------------'  '----------------'  '----------------'  
       
   
// ======================= CORE FUNCTIONS ============================//

    'Software Assent Management' smart contract with following functions
        => Multi-ownership control
        => Higher degree of control by owner
        => Upgradeability using Unstructured Storage

// ========================= CORE LOGIC ==============================//
    
    (1) Four types of account management -
        (a) Software vendors/developers
        (b) businesses
        (c) employees
        (d) owner of the contract
    (2) Owner of the contract is supreme controller, who is highest authority to change
    addresses of all other types of accounts/wallets.
        (a) Process begins when owner of contract creates SW vendor account (which is
        just an ETH wallet address).
        (b) Then that authorised vendor can add/remove/update businesses account
        information (which again is ethereum wallet address) to whom licence is
        provided.
        (c) Businesses then can add/remove/update employees to view licence
        information.
    (3) Software vendor or developer will first submit licence information in smart contract.
    (4) Authorised employees of the company (business, vendor, owner) can look up for
    any licence information.
    (5) There will not events will be logged, because all the data is private to view for the Authorised bodies.


// Copyright (c) 2019 onwards Neocor AI Inc. ( https://neocor.ai )
// Contract designed by EtherAuthority ( https://EtherAuthority.io )
// Special thanks to openzeppelin for upgration inspiration: 
// https://github.com/zeppelinos/labs/tree/master/upgradeability_using_unstructured_storage
// =========================================================================================
*/ 



//*********************************************************************************//
//---------------------------- Contract to Manage Ownership -----------------------//
//*********************************************************************************//
//                                                                                 //
// Owner is set while deploying this contract as well as..                         //
// When this contract is used as implementation by the proxy contract              //
//                                                                                 //
//---------------------------------------------------------------------------------//
contract owned {
    address public owner;
    address public newOwner;

    /**
        Signer is deligated admin wallet, which can do sub-owner functions.
        Signer calls following four functions:
            => request fund from game contract
    */
    address public signer;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
        signer = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    modifier onlySigner {
        require(msg.sender == signer);
        _;
    }

    function changeSigner(address _signer) public onlyOwner {
        signer = _signer;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    //this flow is to prevent transferring ownership to wrong wallet by mistake
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}
    
    
//********************************************************************************//
//----------------  SAM_v1 SMART CONTRACT - MAIN CODE STARTS HERE ----------------//
//********************************************************************************//
    
contract SAM_v1 is owned {
    
    
    
    /*===============================
    =         DATA STORAGE          =
    ===============================*/
    
    //Struct for software information
    struct softwareInfo
    {
        string softwareName;
        string companyName;
        string softwareVersion;
    } 

    /* business => array */
    mapping (address => softwareInfo[]) public softwareInfos;

    /* This variable stores total number of licences */
    uint256 public totalLicences;
    
    /* Struct holds all the software asset data */
    struct SoftwareAsset {
        string licenceKey;              // Unique numeric ID of software asset
        string businessName;            // Business Name to whome licence is issued
        address businessWallet;         // Wallet address of the business
        address addNewEmployeeWallet;   // Wallet address of the employee
        uint256 licenceIssueDate;       // Licence Issue Date
        uint256 licenceRenewDate;       // Licence Renew Date
        string licenceStatus;           // Current licence status. eg, Issued, Revoked, Blacklisted, etc.
    }
    
    /* Mapping holds SoftwareAsset (Licence) data as:  business => employees => Licence key => SoftwareAsset */
    mapping (address => mapping( address => mapping(string => SoftwareAsset))) softwareAssetMapping;
    
    /* business => array */
    mapping (address => string[]) internal businessLicences_;
    
    /* business => employee => array */
    mapping (address => mapping(address => string[]) ) internal employeesLicences_;
    
    /* Mapping for vendor => bool */
    mapping (address => bool) internal vendorsMapping;
    
    /* Mapping for vendor => business => bool */
    mapping (address => bool) public businessesMapping;
    
    /* Mapping for business => employees => bool */
    mapping (address => mapping(address => bool)) public employeesMapping;


    /* constructor function, which does not do really anything */
    constructor () public {}
    
    /* Fallback function is not necessary as incoming ether will be automatically rejected */
    //function () external {}

    event addNewVendorEv(address _vendorAddress);
    /*===============================
    =         WRITE FUNCTIONS       =
    ===============================*/
    /**
     * @notice Function to add new vendor. This is called by only Owner
     * @param _vendorAddress Address of vendor
     * @return bool True for successful transaction otherwise false
     */
    function addNewVendor(address _vendorAddress) public onlySigner returns(bool) {
        
        require(!vendorsMapping[_vendorAddress], 'Vendor is already added');
        require(_vendorAddress != address(0), 'Invalid vendor address');
        
        vendorsMapping[_vendorAddress] = true;
        emit addNewVendorEv(_vendorAddress);
        return true;
    }

    event updateVendorEv(address _currentVendorAddress, address _newVendorAddress);
    /**
     * @notice Function to update any existing vendor. This is called by only Owner
     * @param _currentVendorAddress Current address of vendor, which owner want to update
     * @param _newVendorAddress New address of vendor
     * @return bool True for successful transaction otherwise false
     */
    function updateVendor(address _currentVendorAddress, address _newVendorAddress) public onlySigner returns(bool){
        
        require(vendorsMapping[_currentVendorAddress], 'Vendor does not exist');
        require(_currentVendorAddress != address(0), 'Invalid vendor address');
        require(_newVendorAddress != address(0), 'Invalid vendor address');
        
        vendorsMapping[_currentVendorAddress] = false;
        vendorsMapping[_newVendorAddress] = true;
        emit updateVendorEv( _currentVendorAddress, _newVendorAddress);
        return true;
    }
    
    event addNewBusinessWalletEv(address _businessAddress);
    
    /**
     * @notice Function to add new Business. This can be called by Vendor 
     * @param _businessAddress Address of business owner
     * @return bool True for successful transaction otherwise false
     */
    function addNewBusinessWallet(address _businessAddress) public onlySigner returns(bool) {
        
        //require(vendorsMapping[msg.sender], 'Caller is not authenticated');
        require(!businessesMapping[_businessAddress], 'Business is already added');
        require(_businessAddress != address(0), 'Invalid business address');
        
        businessesMapping[_businessAddress]= true;
        emit addNewBusinessWalletEv(_businessAddress);
        return true;
    }
    
    event updateBusinessWalletEv( address _newBusinessAddress);
    /**
     * @notice Function to update Business wallet. This can be called by business
     * @param _newBusinessAddress New Address of business owner, which needs to be updated
     * @return bool True for successful transaction otherwise false
     */
    function updateBusinessWallet( address _newBusinessAddress) onlySigner public  returns(bool) {
        
        //require(vendorsMapping[msg.sender], 'Caller is not authenticated');
        //require(businessesMapping[msg.sender], 'Caller is not authenticated');
        require(businessesMapping[msg.sender], 'Business does not exist');
        require(_newBusinessAddress != address(0), 'Address is invalid');
        
        businessesMapping[msg.sender] = false;
        businessesMapping[_newBusinessAddress] = true;
        emit updateBusinessWalletEv( _newBusinessAddress);
        return true;
    }

  event addSoftwareDataEv(address _businessAddress,uint256 arrayIndex, string _softwareName,string _companyName,string _softwareVersion);
  
  function addSoftwareData(address _businessAddress,string memory _softwareName,string memory _companyName,string memory _softwareVersion) onlySigner public returns(bool)
  {
        //caller must be business
        require(businessesMapping[_businessAddress], 'Caller is not authenticated');
        softwareInfo memory temp;
        uint256 thisID;
        temp.softwareName = _softwareName;
        temp.companyName = _companyName;
        temp.softwareVersion = _softwareVersion;
        thisID = softwareInfos[_businessAddress].push(temp);
        thisID--;
        emit addSoftwareDataEv(_businessAddress,thisID, _softwareName,_companyName,_softwareVersion); 
        return true;     
  }
   
   
   
   
   
    event addNewLicenseDataEv(address employee_,string businessName_, uint256 licenceIssueDate_, uint256 licenceRenewDate_, string status_ ,  address _businessAddress);
 

    /**
     * @notice Function to add/update the software licence data. This function called only by business
     * @param licenceKey_ software asset ID
     * @param businessName_ Name of the business
     * @param licenceIssueDate_ Date of licence issue in timestamp
     * @param licenceRenewDate_ Date of licence to renew in timestamp
     * @param status_ Status of the licence. It could be valid, pending, Blacklisted, etc.
     * @param _businessAddress  address of business
     * @return bool It returns true for successful transaction else false
     */
   function addNewLicenseData(address employee_, string memory  licenceKey_, string memory businessName_, uint256 licenceIssueDate_, uint256 licenceRenewDate_, string memory status_ ,  address _businessAddress) onlySigner public returns(bool){
        
        address businessWallet_ = _businessAddress;
        
        //caller must be business
        require(businessesMapping[businessWallet_], 'Caller is not authenticated');
        
        //licence key sring should be valid
        require(bytes(licenceKey_).length != 0, 'Licence ID is invalid');
        
        //adding data to softwareAssetMapping
        softwareAssetMapping[businessWallet_][employee_][licenceKey_].licenceKey = licenceKey_;
        softwareAssetMapping[businessWallet_][employee_][licenceKey_].businessName = businessName_;
        softwareAssetMapping[businessWallet_][employee_][licenceKey_].businessWallet = businessWallet_;
        softwareAssetMapping[businessWallet_][employee_][licenceKey_].addNewEmployeeWallet = employee_;
        softwareAssetMapping[businessWallet_][employee_][licenceKey_].licenceIssueDate = licenceIssueDate_;
        softwareAssetMapping[businessWallet_][employee_][licenceKey_].licenceRenewDate = licenceRenewDate_;
        softwareAssetMapping[businessWallet_][employee_][licenceKey_].licenceStatus = status_;
        
        //adding licence key to business and employees licences array
        businessLicences_[_businessAddress].push(licenceKey_);
        employeesLicences_[_businessAddress][employee_].push(licenceKey_);
        
        totalLicences++;

        emit addNewLicenseDataEv(employee_,businessName_,licenceIssueDate_,licenceRenewDate_,status_ , _businessAddress);
       
        return true;
    }
    
     event addNewEmployeeWalletEv(address _employeeAddress, address _businessAddress); 
        
    /**
     * @notice Function to add new employee. This can be called by business 
     * @param _employeeAddress Address of employee who can access the software licence data
     * @return bool True for successful transaction otherwise false
     */

    function addNewEmployeeWallet(address _employeeAddress, address _businessAddress) onlySigner public returns(bool) {
        
       // require(businessesMapping[msg.sender], 'Caller is not authenticated');
        require(!employeesMapping[_businessAddress][_employeeAddress], 'Employee is already added');
        require(_employeeAddress != address(0), 'Invalid Employee address');
        
        employeesMapping[_businessAddress][_employeeAddress] = true;
        emit addNewEmployeeWalletEv(_employeeAddress,_businessAddress);
        return true;

    }
    
    event updateEmployeeWalletEv( address _currentEmployeeAddress, address _newEmployeeAddress);
    /**
     * @notice Function to update existing employee wallet address. This can be called by business only
     * @param _currentEmployeeAddress Address of existing employee, whose wallet address needs to be updated 
     * @param _newEmployeeAddress New Address of employee 
     * @return bool True for successful transaction otherwise false
     */
    function updateEmployeeWallet( address _currentEmployeeAddress, address _newEmployeeAddress) onlySigner public returns(bool) {
        
        require(businessesMapping[msg.sender], 'Caller is not authenticated');
        require(employeesMapping[msg.sender][_currentEmployeeAddress], 'Employee does not exist');
        require(_newEmployeeAddress != address(0), 'Invalid Employee address');
        
        employeesMapping[msg.sender][_currentEmployeeAddress] = false;
        employeesMapping[msg.sender][_newEmployeeAddress] = true;
        emit updateEmployeeWalletEv(_currentEmployeeAddress,  _newEmployeeAddress);
        return true;
    }
    
    
    /*===============================
    =         READ FUNCTIONS        =
    ===============================*/
    
    /**
     * Returns licenceKey of particular index of Business
     */
    function businessLicences(address businessWallet, uint256 index) public view returns(string memory){
        return businessLicences_[businessWallet][index];
    }
    
    /**
     * Returns licenceKey of particular index of employees
     */
    function employeesLicences(address businessWallet, address employeeWallet, uint256 index) public view returns(string memory){
        return employeesLicences_[businessWallet][employeeWallet][index];
    }
    
    /**
     * @notice This function is to request software related information
     * @notice This can be called by owner, vendor, business and employees and they receive their specific information if exist
     * @dev It first validates all the information requests. and once validated, it sends the information 
     * 
     * @param business is business wallet Address
     * @param employee is employee wallet Address
     * @param licenceKey unique software asset ID
     * 
     * @return array of software information
     */
    function readLicenceInformation(address business, address employee, string memory licenceKey) public view returns(string memory, string memory, address, uint256, uint256, string memory) {

        // validates requester of the information
        require(
            msg.sender == owner || 
            (softwareAssetMapping[msg.sender][employee][licenceKey].licenceIssueDate > 0) ||
            (softwareAssetMapping[business][msg.sender][licenceKey].licenceIssueDate > 0),
            'Unauthenticated caller'
        );
        
        // once caller is validated, then send the information
        return (
            softwareAssetMapping[business][employee][licenceKey].licenceKey, 
            softwareAssetMapping[business][employee][licenceKey].businessName, 
            softwareAssetMapping[business][employee][licenceKey].addNewEmployeeWallet, 
            softwareAssetMapping[business][employee][licenceKey].licenceIssueDate, 
            softwareAssetMapping[business][employee][licenceKey].licenceRenewDate, 
            softwareAssetMapping[business][employee][licenceKey].licenceStatus
        );
    }
    
    /**
     * Called by busines owner. and it will display all the licenses issued by business.
     * Owner can call this function and get the data.
     * 
     */
    function getTotalLicenceNumberOfBusiness(address businessWallet) public view returns(uint256){
        /*require(
            msg.sender == owner || 
            businessesMapping[msg.sender],
            'Unauthenticated caller'
        ); */
        
        return businessLicences_[businessWallet].length;
        
    }
    
    
    function getTotalLicenceNumberOfEmployee(address businessWallet, address employeeWallet) public view returns(uint256){
        /*require(
            msg.sender == owner || 
            employeesLicences_[business][msg.sender].length > 0,
            'Unauthenticated caller'
        );*/
        
        return employeesLicences_[businessWallet][employeeWallet].length;
    }
    
    
    /*===============================
    =     UPGRADE CONTRACT CODE     =
    ===============================*/
    bool internal initialized;
    
    /**
     * @notice This is initialize function would be called only once while contract initialisation
     * @notice It will just set owner address
     */
    function initialize(
        address _owner
    ) public {
        
        require(!initialized);
        require(owner == address(0)); //When this methods called, then owner address must be zero

        owner = _owner;
        initialized = true;
    }
    
}


//********************************************************************************//
//----------------------  MAIN PROXY CONTRACTS SECTION STARTS --------------------//
//********************************************************************************//


/****************************************/
/*            Proxy Contract            */
/****************************************/
/**
 * @title Proxy
 * @dev Gives the possibility to delegate any call to a foreign implementation.
 */
contract Proxy {
  /**
  * @dev Tells the address of the implementation where every call will be delegated.
  * @return address of the implementation to which it will be delegated
  */
  function implementation() public view returns (address);

  /**
  * @dev Fallback function allowing to perform a delegatecall to the given implementation.
  * This function will return whatever the implementation call returns
  */
  function () payable external {
    address _impl = implementation();
    require(_impl != address(0));

    assembly {
      let ptr := mload(0x40)
      calldatacopy(ptr, 0, calldatasize)
      let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
      let size := returndatasize
      returndatacopy(ptr, 0, size)

      switch result
      case 0 { revert(ptr, size) }
      default { return(ptr, size) }
    }
  }
  
}


/****************************************/
/*    UpgradeabilityProxy Contract      */
/****************************************/
/**
 * @title UpgradeabilityProxy
 * @dev This contract represents a proxy where the implementation address to which it will delegate can be upgraded
 */
contract UpgradeabilityProxy is Proxy {
  /**
   * @dev This event will be emitted every time the implementation gets upgraded
   * @param implementation representing the address of the upgraded implementation
   */
  event Upgraded(address indexed implementation);

  // Storage position of the address of the current implementation
  bytes32 private constant implementationPosition = keccak256("org.zeppelinos.proxy.implementation");

  /**
   * @dev Constructor function
   */
  constructor () public {}

  /**
   * @dev Tells the address of the current implementation
   * @return address of the current implementation
   */
  function implementation() public view returns (address impl) {
    bytes32 position = implementationPosition;
    assembly {
      impl := sload(position)
    }
  }

  /**
   * @dev Sets the address of the current implementation
   * @param newImplementation address representing the new implementation to be set
   */
  function setImplementation(address newImplementation) internal {
    bytes32 position = implementationPosition;
    assembly {
      sstore(position, newImplementation)
    }
  }

  /**
   * @dev Upgrades the implementation address
   * @param newImplementation representing the address of the new implementation to be set
   */
  function _upgradeTo(address newImplementation) internal {
    address currentImplementation = implementation();
    require(currentImplementation != newImplementation);
    setImplementation(newImplementation);
    emit Upgraded(newImplementation);
  }
}

/****************************************/
/*  OwnedUpgradeabilityProxy contract   */
/****************************************/
/**
 * @title OwnedUpgradeabilityProxy
 * @dev This contract combines an upgradeability proxy with basic authorization control functionalities
 */
contract OwnedUpgradeabilityProxy is UpgradeabilityProxy {
  /**
  * @dev Event to show ownership has been transferred
  * @param previousOwner representing the address of the previous owner
  * @param newOwner representing the address of the new owner
  */
  event ProxyOwnershipTransferred(address previousOwner, address newOwner);

  // Storage position of the owner of the contract
  bytes32 private constant proxyOwnerPosition = keccak256("org.zeppelinos.proxy.owner");

  /**
  * @dev the constructor sets the original owner of the contract to the sender account.
  */
  constructor () public {
    setUpgradeabilityOwner(msg.sender);
  }

  /**
  * @dev Throws if called by any account other than the owner.
  */
  modifier onlyProxyOwner() {
    require(msg.sender == proxyOwner());
    _;
  }

  /**
   * @dev Tells the address of the owner
   * @return the address of the owner
   */
  function proxyOwner() public view returns (address owner) {
    bytes32 position = proxyOwnerPosition;
    assembly {
      owner := sload(position)
    }
  }

  /**
   * @dev Sets the address of the owner
   */
  function setUpgradeabilityOwner(address newProxyOwner) internal {
    bytes32 position = proxyOwnerPosition;
    assembly {
      sstore(position, newProxyOwner)
    }
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferProxyOwnership(address newOwner) public onlyProxyOwner {
    require(newOwner != address(0));
    emit ProxyOwnershipTransferred(proxyOwner(), newOwner);
    setUpgradeabilityOwner(newOwner);
  }

  /**
   * @dev Allows the proxy owner to upgrade the current version of the proxy.
   * @param implementation representing the address of the new implementation to be set.
   */
  function upgradeTo(address implementation) public onlyProxyOwner {
    _upgradeTo(implementation);
  }

  /**
   * @dev Allows the proxy owner to upgrade the current version of the proxy and call the new implementation
   * to initialize whatever is needed through a low level call.
   * @param implementation representing the address of the new implementation to be set.
   * @param data represents the msg.data to bet sent in the low level call. This parameter may include the function
   * signature of the implementation to be called with the needed payload
   */
  function upgradeToAndCall(address implementation, bytes memory data) payable public onlyProxyOwner {
    _upgradeTo(implementation);
    (bool success,) = address(this).call.value(msg.value).gas(200000)(data);
    require(success);
  }
}


/****************************************/
/*        SAM PROXY Contract         */
/****************************************/

/**
 * @title SAM_proxy
 * @dev This contract proxies FiatToken calls and enables FiatToken upgrades
*/ 
contract SAM_proxy is OwnedUpgradeabilityProxy {
    constructor() public OwnedUpgradeabilityProxy() {
    }
    function returnInitialiseData(address payable owner ) public pure returns(bytes memory){
        
    return abi.encodeWithSignature("initialize(address)",owner);
      
}
}
