/**
 *Submitted for verification at Etherscan.io on 2019-02-08
*/

pragma solidity ^0.5.0;

library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface HydroInterface {
    function balances(address) external view returns (uint);
    function allowed(address, address) external view returns (uint);
    function transfer(address _to, uint256 _amount) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function approve(address _spender, uint256 _amount) external returns (bool success);
    function approveAndCall(address _spender, uint256 _value, bytes calldata _extraData)
        external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function totalSupply() external view returns (uint);

    function authenticate(uint _value, uint _challenge, uint _partnerId) external;
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
    * @dev The Ownable constructor sets the original `owner` of the contract to the sender
    * account.
    */
    constructor() public {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
    * @return the address of the owner.
    */
    function owner() public view returns(address) {
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
    function isOwner() public view returns(bool) {
        return msg.sender == _owner;
    }

    /**
    * @dev Allows the current owner to relinquish control of the contract.
    * @notice Renouncing to ownership will leave the contract without an owner.
    * It will not be possible to call the functions with the `onlyOwner`
    * modifier anymore.
    */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
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


interface IdentityRegistryInterface {
    function isSigned(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
        external pure returns (bool);

    // Identity View Functions /////////////////////////////////////////////////////////////////////////////////////////
    function identityExists(uint ein) external view returns (bool);
    function hasIdentity(address _address) external view returns (bool);
    function getEIN(address _address) external view returns (uint ein);
    function isAssociatedAddressFor(uint ein, address _address) external view returns (bool);
    function isProviderFor(uint ein, address provider) external view returns (bool);
    function isResolverFor(uint ein, address resolver) external view returns (bool);
    function getIdentity(uint ein) external view returns (
        address recoveryAddress,
        address[] memory associatedAddresses, address[] memory providers, address[] memory resolvers
    );

    // Identity Management Functions ///////////////////////////////////////////////////////////////////////////////////
    function createIdentity(address recoveryAddress, address[] calldata providers, address[] calldata resolvers)
        external returns (uint ein);
    function createIdentityDelegated(
        address recoveryAddress, address associatedAddress, address[] calldata providers, address[] calldata resolvers,
        uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external returns (uint ein);
    function addAssociatedAddress(
        address approvingAddress, address addressToAdd, uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;
    function addAssociatedAddressDelegated(
        address approvingAddress, address addressToAdd,
        uint8[2] calldata v, bytes32[2] calldata r, bytes32[2] calldata s, uint[2] calldata timestamp
    ) external;
    function removeAssociatedAddress() external;
    function removeAssociatedAddressDelegated(address addressToRemove, uint8 v, bytes32 r, bytes32 s, uint timestamp)
        external;
    function addProviders(address[] calldata providers) external;
    function addProvidersFor(uint ein, address[] calldata providers) external;
    function removeProviders(address[] calldata providers) external;
    function removeProvidersFor(uint ein, address[] calldata providers) external;
    function addResolvers(address[] calldata resolvers) external;
    function addResolversFor(uint ein, address[] calldata resolvers) external;
    function removeResolvers(address[] calldata resolvers) external;
    function removeResolversFor(uint ein, address[] calldata resolvers) external;

    // Recovery Management Functions ///////////////////////////////////////////////////////////////////////////////////
    function triggerRecoveryAddressChange(address newRecoveryAddress) external;
    function triggerRecoveryAddressChangeFor(uint ein, address newRecoveryAddress) external;
    function triggerRecovery(uint ein, address newAssociatedAddress, uint8 v, bytes32 r, bytes32 s, uint timestamp)
        external;
    function triggerDestruction(
        uint ein, address[] calldata firstChunk, address[] calldata lastChunk, bool resetResolvers
    ) external;
}

interface SnowflakeInterface {
    function deposits(uint) external view returns (uint);
    function resolverAllowances(uint, address) external view returns (uint);

    function identityRegistryAddress() external returns (address);
    function hydroTokenAddress() external returns (address);
    function clientRaindropAddress() external returns (address);

    function setAddresses(address _identityRegistryAddress, address _hydroTokenAddress) external;
    function setClientRaindropAddress(address _clientRaindropAddress) external;

    function createIdentityDelegated(
        address recoveryAddress, address associatedAddress, address[] calldata providers, string calldata casedHydroId,
        uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external returns (uint ein);
    function addProvidersFor(
        address approvingAddress, address[] calldata providers, uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;
    function removeProvidersFor(
        address approvingAddress, address[] calldata providers, uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;
    function upgradeProvidersFor(
        address approvingAddress, address[] calldata newProviders, address[] calldata oldProviders,
        uint8[2] calldata v, bytes32[2] calldata r, bytes32[2] calldata s, uint[2] calldata timestamp
    ) external;
    function addResolver(address resolver, bool isSnowflake, uint withdrawAllowance, bytes calldata extraData) external;
    function addResolverAsProvider(
        uint ein, address resolver, bool isSnowflake, uint withdrawAllowance, bytes calldata extraData
    ) external;
    function addResolverFor(
        address approvingAddress, address resolver, bool isSnowflake, uint withdrawAllowance, bytes calldata extraData,
        uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;
    function changeResolverAllowances(address[] calldata resolvers, uint[] calldata withdrawAllowances) external;
    function changeResolverAllowancesDelegated(
        address approvingAddress, address[] calldata resolvers, uint[] calldata withdrawAllowances,
        uint8 v, bytes32 r, bytes32 s
    ) external;
    function removeResolver(address resolver, bool isSnowflake, bytes calldata extraData) external;
    function removeResolverFor(
        address approvingAddress, address resolver, bool isSnowflake, bytes calldata extraData,
        uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;

    function triggerRecoveryAddressChangeFor(
        address approvingAddress, address newRecoveryAddress, uint8 v, bytes32 r, bytes32 s
    ) external;

    function transferSnowflakeBalance(uint einTo, uint amount) external;
    function withdrawSnowflakeBalance(address to, uint amount) external;
    function transferSnowflakeBalanceFrom(uint einFrom, uint einTo, uint amount) external;
    function withdrawSnowflakeBalanceFrom(uint einFrom, address to, uint amount) external;
    function transferSnowflakeBalanceFromVia(uint einFrom, address via, uint einTo, uint amount, bytes calldata _bytes)
        external;
    function withdrawSnowflakeBalanceFromVia(uint einFrom, address via, address to, uint amount, bytes calldata _bytes)
        external;
}

contract SnowflakeResolver is Ownable {
    string public snowflakeName;
    string public snowflakeDescription;

    address public snowflakeAddress;

    bool public callOnAddition;
    bool public callOnRemoval;

    constructor(
        string memory _snowflakeName, string memory _snowflakeDescription,
        address _snowflakeAddress,
        bool _callOnAddition, bool _callOnRemoval
    )
        public
    {
        snowflakeName = _snowflakeName;
        snowflakeDescription = _snowflakeDescription;

        setSnowflakeAddress(_snowflakeAddress);

        callOnAddition = _callOnAddition;
        callOnRemoval = _callOnRemoval;
    }

    modifier senderIsSnowflake() {
        require(msg.sender == snowflakeAddress, "Did not originate from Snowflake.");
        _;
    }

    // this can be overriden to initialize other variables, such as e.g. an ERC20 object to wrap the HYDRO token
    function setSnowflakeAddress(address _snowflakeAddress) public onlyOwner {
        snowflakeAddress = _snowflakeAddress;
    }

    // if callOnAddition is true, onAddition is called every time a user adds the contract as a resolver
    // this implementation **must** use the senderIsSnowflake modifier
    // returning false will disallow users from adding the contract as a resolver
    function onAddition(uint ein, uint allowance, bytes memory extraData) public returns (bool);

    // if callOnRemoval is true, onRemoval is called every time a user removes the contract as a resolver
    // this function **must** use the senderIsSnowflake modifier
    // returning false soft prevents users from removing the contract as a resolver
    // however, note that they can force remove the resolver, bypassing onRemoval
    function onRemoval(uint ein, bytes memory extraData) public returns (bool);

    function transferHydroBalanceTo(uint einTo, uint amount) internal {
        HydroInterface hydro = HydroInterface(SnowflakeInterface(snowflakeAddress).hydroTokenAddress());
        require(hydro.approveAndCall(snowflakeAddress, amount, abi.encode(einTo)), "Unsuccessful approveAndCall.");
    }

    function withdrawHydroBalanceTo(address to, uint amount) internal {
        HydroInterface hydro = HydroInterface(SnowflakeInterface(snowflakeAddress).hydroTokenAddress());
        require(hydro.transfer(to, amount), "Unsuccessful transfer.");
    }

    function transferHydroBalanceToVia(address via, uint einTo, uint amount, bytes memory snowflakeCallBytes) internal {
        HydroInterface hydro = HydroInterface(SnowflakeInterface(snowflakeAddress).hydroTokenAddress());
        require(
            hydro.approveAndCall(
                snowflakeAddress, amount, abi.encode(true, address(this), via, einTo, snowflakeCallBytes)
            ),
            "Unsuccessful approveAndCall."
        );
    }

    function withdrawHydroBalanceToVia(address via, address to, uint amount, bytes memory snowflakeCallBytes) internal {
        HydroInterface hydro = HydroInterface(SnowflakeInterface(snowflakeAddress).hydroTokenAddress());
        require(
            hydro.approveAndCall(
                snowflakeAddress, amount, abi.encode(false, address(this), via, to, snowflakeCallBytes)
            ),
            "Unsuccessful approveAndCall."
        );
    }
}

contract PetFriendResolver is SnowflakeResolver {
    //Revision history
    //v0.3:
    //   -add method unclaimLostReport => changes report status from Found to Pending
    //   -remove PetChanged event 
    //   -add modifier _lostReportActive  
    //   -add getOwner method
    //v0.4:
    //   -add method updateOwner => updates owners data
    //v0.5:
    //   -add method getPetOwner(string petId)
     //v0.51
    //   -add ownerId to getPetOwner(string petId)
    //v0.52 private modifier to all state vars, to disable public methods on compile
    //v0.53 
    //   -canUnclaim modifier for unclaim verify
    //v.6:
    //   -extraParams to initialize state
    //v.0.7: implementation on "use-case level" verifications
    //v.0.8:
    //   - bug correction, deleted escrow mapping.
    //   - added _canModifyReward modifier
    //   - added getMaxAllowedReward public function
    //   - added FundsChanged event and emitFundsChanged function
    //v1.0.1:
    //   - optimization issues: remove string[] dependencies
    //   - petId changed from string (chipId) to uint
    //   - added chipId to pet (before was petId)
    
    
    //using stringSet for stringSet._stringSet;
    using SafeMath for uint;
    
    //Owner Fields
    struct Owner{
        //string snowflakeId; //PK
        uint ein; //PK
        string contactName;
        string contactData;
        uint[] petIds;
    }

 
    //Pet fields
    struct Pet {
        uint ownerId;
        string chipId; //PK
        string petType;
        string name;
        string desc;
        string imgUrl;
    }
    
   //Pet Reports
    struct LostReport{
        uint petId; //PK
        Status status;
        string sceneDesc;
        uint reward;
        uint claimerEin;
    }

    //one hydro is represented as 1000000000000000000
    uint private signUpFee = uint(1).mul(10**18);

    enum Status {None, Pending, Found, Removed, Rewarded}
    
    //enum FundMovement {Deposit, Withdraw}
    
     //pets registry by petId(PK)
    //mapping (uint => Pet)  private pets; //
    Pet[] pets;
    
    uint totalPets;
    
    //owners registry by ein
    mapping (uint => Owner) private owners;
    
    //lost report Struct of a petId
    mapping (uint => LostReport) private lostReports; 
    
    //all active lost report keys; used to list in frontend
    uint[] private lostReportKeys;
    
     //Events
  
    //event FundsChanged(
    //    uint indexed ein,
    //    string petId,
    //    uint date,
    //    Status status,
    //    uint funds,
    //    FundMovement movement
    //);
    
    // function emitFundsChanged( uint ownerId, string memory petId, Status status, FundMovement movement)
    //private{
    //   SnowflakeInterface snowflake = SnowflakeInterface(snowflakeAddress);
    //    uint funds = snowflake.resolverAllowances(ownerId,address(this));
    //    emit FundsChanged(ownerId, petId, now, status,funds, movement);
    //} 
    
    //when lost report changes: reports, modifies, claimed, closed...
    //to be used to list an historic of pet incidences
    event LostReportChanged(
        uint indexed petId,
        string chipId, 
        uint date,
        Status status,
        string sceneDesc,
        uint reward,
        uint claimerEin
    );
    
    function emitEventNewPet(uint petId) 
    private{
        //bytes32 hashedPetId = keccak256(abi.encode(petId));
        emit LostReportChanged(petId,pets[petId].chipId, now,Status.None,"",0,0);
    }
    
    function  emitEventV2 (  uint petId, LostReport memory lostReport) 
    private{
        //bytes32 hashedPetId = keccak256(abi.encode(petId));
        emit LostReportChanged(petId,pets[petId].chipId, now,lostReport.status,lostReport.sceneDesc,lostReport.reward,lostReport.claimerEin);
    }
      
        //modifiers
     //verify if transaction sender is the owner himself
     modifier _onlyOwner(uint ownerId)
     {   
         SnowflakeInterface snowflake = SnowflakeInterface(snowflakeAddress);
         IdentityRegistryInterface identityRegistry = IdentityRegistryInterface(snowflake.identityRegistryAddress());
         require(ownerId == identityRegistry.getEIN(msg.sender));
         _;
     }
     
      //modifiers
     //verify if transaction sender is the pet owner
     modifier _onlyPetOwner(uint petId)
     {   
         SnowflakeInterface snowflake = SnowflakeInterface(snowflakeAddress);
         IdentityRegistryInterface identityRegistry = IdentityRegistryInterface(snowflake.identityRegistryAddress());
         require(pets[petId].ownerId == identityRegistry.getEIN(msg.sender));
         _;
     }
     
     //verify if transaction sender is not the pet owner
     modifier _onlyNotPetOwner(uint petId)
     {   
         SnowflakeInterface snowflake = SnowflakeInterface(snowflakeAddress);
         IdentityRegistryInterface identityRegistry = IdentityRegistryInterface(snowflake.identityRegistryAddress());
         require(pets[petId].ownerId != identityRegistry.getEIN(msg.sender));
         _;
     }
     
     modifier _reportNotActive(uint petId)
     {
        //require(bytes(pets[petId].desc).length >0,"No pet exists with that petId");
        //require(!lostReportKeys.contains(petId));
        require(lostReports[petId].status == Status.None 
            || lostReports[petId].status == Status.Rewarded
            || lostReports[petId].status == Status.Removed);
        _;
     }
    
    modifier _petExists(uint petId)
     {
         //pets is a uint[], pet[petId] exists if pet.length > petId
        require(petId < pets.length,"No pet exists with that petId");
        _;
     }
     
  
    //only can reward if:
    //snowflake funds >= reward
    //and  reward <= snowflake resolver allowance
    modifier _canReward(uint ownerId,uint reward){
        require(reward >=0);
        if(reward > 0){
            SnowflakeInterface snowflake = SnowflakeInterface(snowflakeAddress);
            require(snowflake.resolverAllowances(ownerId,address(this)) >= reward);
            require(snowflake.deposits(ownerId) >= reward);
        }
        _;   
    }
    
    //if new reward is greater, 
    //snowflake funds >= reward increment
    //and  reward increment <= snowflake resolver allowance
    modifier _canModifyReward(uint ownerId,uint petId, uint newreward){
        if(lostReports[petId].reward < newreward){
            //new reward is greater than last
            uint diff = newreward - lostReports[petId].reward;
            SnowflakeInterface snowflake = SnowflakeInterface(snowflakeAddress);
            require(snowflake.resolverAllowances(ownerId,address(this)) >= diff);
            require(snowflake.deposits(ownerId) >= diff);
        }
       _;
    }
    
    //debug method to get max reward
    
    modifier _reportStatusMustBe(uint petId, Status status){
        require(lostReports[petId].status == status,"Unexpected report status");
        _;
    }
    
     modifier _canUnclaim(uint petId)
     {   
        SnowflakeInterface snowflake = SnowflakeInterface(snowflakeAddress);
        IdentityRegistryInterface identityRegistry = IdentityRegistryInterface(snowflake.identityRegistryAddress());
        uint ownerId = pets[petId].ownerId;
        uint claimerHydroId = lostReports[petId].claimerEin;
        require(
            (identityRegistry.getEIN(msg.sender) == ownerId)
            ||
           (identityRegistry.getEIN(msg.sender) == claimerHydroId)
        );
         _;
     }
     
    constructor (address snowflakeAddress)
        SnowflakeResolver("Pet Owner Resolver v1.0.1 - get your Pet Friend membership", "Become a member of Pet Friends community and register your pets!", snowflakeAddress, true, false) public
    {  
        totalPets=0;
    }
    
       // implement signup function
    function onAddition(uint ein, uint, bytes memory extraData) 
    public 
    senderIsSnowflake() 
    returns (bool) {
        SnowflakeInterface snowflake = SnowflakeInterface(snowflakeAddress);
        snowflake.withdrawSnowflakeBalanceFrom(ein, owner(), signUpFee);

      	//3. update the mapping owners
      	 (string memory contactName, string memory contactData) = abi.decode(extraData, (string, string));
		owners[ein].contactName = contactName;
		owners[ein].contactData = contactData;

       // emit StatusSignUp(ein);
        return true;
    }
     
    function onRemoval(uint, bytes memory) 
    public 
    senderIsSnowflake() returns (bool) {
        //delete all pets
       // for(uint i=0;i<owners[ein].petIds.length;i++){
        //    string memory petId = owners[ein].petIds[i];
        //    Pet apet = pets[petId];
        //    if(lostReportKeys.contains(petId)){
        //        //remove report
        //        //if Pending, Found or Claimed:
        //        
        //    }
        //}
        //delete all reports
        //return all escrow if any
        //delete owner
         return true;
    }

     //event StatusSignUp(uint ein);
    
    //function getMaxAllowedReward(uint ownerId)
    //public 
    //returns (uint maxAllowedReward){
    //      SnowflakeInterface snowflake = SnowflakeInterface(snowflakeAddress);
    //      uint allowance = snowflake.resolverAllowances(ownerId,address(this));
    //      uint deposits = snowflake.deposits(ownerId);
    //      if(allowance > deposits) 
    //        return (deposits);
    //      else{
    //          return (allowance);
    //      }
    //}
    
    function getOwner(uint ownerId)
    public view 
    returns (string memory contactName, string memory contactData ){
        return( owners[ownerId].contactName,
                owners[ownerId].contactData)  ;  
    }
    
    function getPetOwner(uint petId)  
    public view 
    returns (uint ownerId,string memory contactName, string memory contactData ){
        return(
            pets[petId].ownerId,
            owners[pets[petId].ownerId].contactName,
            owners[pets[petId].ownerId].contactData
        );
        
    }
    
    function updateOwner(uint ownerId, string memory contactName, string memory contactData) 
    public
    _onlyOwner(ownerId)
    returns (bool success)
    {
        owners[ownerId].contactName = contactName;
        owners[ownerId].contactData = contactData;  
        return(true);
    }
    
    function getOwnerPets(uint ownerId) 
    public view 
    returns(uint[] memory){
         return owners[ownerId].petIds;
    }
    
      
     //get pet data from petId
    function getPet(uint petId) 
    public view 
    returns (string memory chipId, string memory petType, string memory name, string memory desc, string memory imgUrl) 
    {
       return( 
            pets[petId].chipId,
            pets[petId].petType, 
            pets[petId].name, 
            pets[petId].desc, 
            pets[petId].imgUrl
       	);
    }

    //The owner creates a new pet
    function addPet(uint ownerId, string memory chipId, string memory petType, string memory name, string memory desc, string memory imgUrl) 
    public 
    _onlyOwner(ownerId) //0. sender must be ownerId 
    returns (bool success)  
    {
      	//1. verify all required fields
		 //require(bytes(pets[petId].desc).length == 0,"A pet already registered with this petId");
		//3. update the data
		Pet memory newPet = Pet({ownerId:ownerId,chipId:chipId,petType:petType,name:name,desc:desc,imgUrl:imgUrl});
		pets.push(newPet);
		totalPets++;

		//4. register pet ownership
		owners[ownerId].petIds.push(totalPets-1);
		
		emitEventV2(totalPets-1, lostReports[totalPets-1]);

		return (true);
    }
    
    function updatePet(uint petId, string memory chipId, string memory petType,  string memory name, string memory desc, string memory imgUrl) 
    public 
    _onlyPetOwner(petId)
    _petExists(petId)
    returns (bool success)  
    {
        //0. sender must be ownerId
      	//1. verify all required fields
		//2. verify   petId already exists
		//3. update the data
			pets[petId].chipId = chipId;
			pets[petId].petType = petType;
			pets[petId].name=name;
			pets[petId].desc=desc;
			pets[petId].imgUrl=imgUrl;
		
			return (true);
		//}else{
		//	return (false);
		//}
    }

    //Returning key array is possible to query by key element
    function getAllLostReportKeys() 
    public view 
    returns(uint[] memory){
        return lostReportKeys;
    }
    
    function getLostReport(uint petId)  
    public view 
    returns(
        Status status,
        string memory sceneDesc,
        uint reward,
        uint claimerHydroId
        ){
        return (
            lostReports[petId].status,
            lostReports[petId].sceneDesc,
            lostReports[petId].reward,
            lostReports[petId].claimerEin
        );
    }
    
    

    //new LostReport
    function putLostReport(uint ownerId, uint petId, string memory sceneDesc, uint reward ) 
    public 
    _onlyPetOwner(petId)
    //_petExists(petId)
    _canReward(ownerId,reward)
    _reportNotActive(petId)
    returns (bool){
        //1. report dont exists
       require(bytes(lostReports[petId].sceneDesc).length==0,"Lost Report already exists.");
        //2. create new struct, assign to storate mapping
        //persist on storage
        lostReports[petId].sceneDesc = sceneDesc;
        lostReports[petId].reward = reward;
        lostReports[petId].status = Status.Pending;

        lostReportKeys.push(petId); //can exists?
        
        //escrow reward from snowflake to resolver
        SnowflakeInterface snowflake = SnowflakeInterface(snowflakeAddress);
        snowflake.withdrawSnowflakeBalanceFrom(ownerId, address(this), reward.mul(10**18));
        //emitFundsChanged(ownerId, petId, Status.Pending, FundMovement.Withdraw);
        emitEventV2(petId, lostReports[petId]);
        return true;
    }
    
    
    //new LostReport
    function updateLostReport(uint ownerId, uint petId, string memory sceneDesc, uint reward ) 
    public 
    _onlyPetOwner(petId) 
    _canModifyReward(ownerId,petId,reward)
    _reportStatusMustBe(petId,Status.Pending)
    returns (bool){
     
        //1. report dont exists
        //require(bytes(lostReports[petId].sceneDesc).length>0,"Lost Report don't exists.");

        //update escrow reward, transferring or withdrawing from/to resolver if needed
        updateEscrowReward(ownerId,petId,reward);
        
        //2. create new struct, assign to storate mapping
        //persist on storage
        lostReports[petId].sceneDesc = sceneDesc;
        lostReports[petId].reward = reward;
        lostReports[petId].status = Status.Pending;
        
        emitEventV2(petId, lostReports[petId]);
        return true;
    }
    
    //Update escrow for owner
    function updateEscrowReward(uint ownerId,uint petId, uint reward)
    private{
         //escrow reward from snowflake to resolver
         if(lostReports[petId].reward != reward){
             if(lostReports[petId].reward < reward){
                 //Handle withdraw of remaining esscrow
                 SnowflakeInterface snowflake = SnowflakeInterface(snowflakeAddress);
                 snowflake.withdrawSnowflakeBalanceFrom(ownerId, address(this), (reward - lostReports[petId].reward).mul(10**18));
                 //emitFundsChanged(ownerId, petId, Status.Pending, FundMovement.Withdraw);
             }else{
                 //Handle transfer of necessary escrow
                transferHydroBalanceTo(ownerId,(lostReports[petId].reward - reward).mul(10**18));
                //emitFundsChanged(ownerId, petId, Status.Pending, FundMovement.Deposit);
             }
         }
    }
 
    //owner can remove a lost report, when he finds the pen again, for example, o is found dead, etc.
    function removeLostReport(uint ownerId, uint petId) 
    public 
    _onlyPetOwner(petId)
    _reportStatusMustBe(petId,Status.Pending)
    returns (bool){
        //petId must have a report
        //require(bytes(lostReports[petId].sceneDesc).length > 0,"Active LostReport doesn't exists");
        lostReports[petId].status = Status.Removed;
       
        //return escrow
        if(lostReports[petId].reward > 0){
             //return reward to owner
             transferHydroBalanceTo(ownerId,lostReports[petId].reward.mul(10**18));
             //emitFundsChanged(ownerId, petId, Status.Removed, FundMovement.Deposit);
        }
       
        emitEventV2(petId, lostReports[petId]);
        
        //delete all struct elements for hydroId
        delete lostReports[petId];
        //delete key and compress uint array
        removeLostReportKeys(petId);
        return true;
    }
    
    function removeLostReportKeys(uint key) 
    private 
    returns(bool success){
        require(lostReportKeys.length>0);
        for(uint i=0;i<lostReportKeys.length;i++){
            if(lostReportKeys[i] == key){
                lostReportKeys[i] = lostReportKeys[lostReportKeys.length-1];
                lostReportKeys.length--;
                return true;
            }
        }
        return false;
    }
    

    //somebody claims the pet found
    function claimLostReport(uint petId, uint claimerHydroId /*,string notesOnClaim*/) 
    public
    _onlyNotPetOwner(petId)
    _reportStatusMustBe(petId,Status.Pending)
    returns (bool){
        require(bytes(lostReports[petId].sceneDesc).length > 0,"Lost Report doesn't exist");
        //change status and snowflakeDescription
        lostReports[petId].claimerEin =claimerHydroId;
        lostReports[petId].status =Status.Found;
        emitEventV2(petId, lostReports[petId]);
        return true;
    }
    
    
    //unclaim previos claimed report: only can unclaim the owner or the claimer or pet owner   
    function unclaimLostReport(uint petId) 
    public 
    _canUnclaim (petId) 
    _reportStatusMustBe(petId,Status.Found)
    returns (bool){
        require(bytes(lostReports[petId].sceneDesc).length > 0,"Lost Report doesn't exist");

        //change status and snowflakeDescription
        lostReports[petId].claimerEin =0;
        lostReports[petId].status =Status.Pending;
       
        emitEventV2(petId, lostReports[petId]);
        return true;
    }
    
    function confirmReward(uint , uint petId) 
    public 
    _onlyPetOwner(petId)
    _reportStatusMustBe(petId,Status.Found)
    returns (bool){
        //report must exists
        //require(bytes(lostReports[petId].sceneDesc).length > 0,"LosReport doesn't exists");

        //change state to Closed
        lostReports[petId].status = Status.Rewarded;
       
        //as a good pattern, always call other contracts the last thing
        //make the transfer
        //snowflake.transferSnowflakeBalanceFrom(ownerId,  claimerHydroId, reward.mul(10**18));
        transferHydroBalanceTo(lostReports[petId].claimerEin,lostReports[petId].reward.mul(10**18));
        //emitFundsChanged(lostReports[petId].claimerEin, petId, Status.Rewarded, FundMovement.Deposit);
        //LostReportChanged event
        emitEventV2(petId, lostReports[petId]);
        
        //delete all struct elements for hydroOwnerId
        delete lostReports[petId];
        //delete key
        removeLostReportKeys(petId);
    
        return true;
    }

   

}
