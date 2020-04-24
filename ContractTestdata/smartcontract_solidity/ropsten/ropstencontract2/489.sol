/**
 *Submitted for verification at Etherscan.io on 2019-08-06
*/

pragma solidity ^0.5.10;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;
  address private _killer;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor(address killer) internal {
    _owner = msg.sender;
    _killer = killer;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the killer.
   */
  function killer() public view returns(address) {
    return _killer;
  }
  
  /**
   * @dev Throws if called by any account other than the killer.
   */
  modifier onlyKiller() {
    require(isKiller(), "Only killer wallet call that function");
    _;
  }
  
  /**
   * @return true if `msg.sender` is the killer of the contract.
   */
  function isKiller() public view returns(bool) {
    return msg.sender == _killer;
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
    require(isOwner(), "Only owner wallet call that function");
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

/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   * as the code is not actually created until after the constructor finishes.
   * @param addr address to check
   * @return whether the target address is a contract
   */
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    // XXX Currently there is no better way to check if there is a contract in an address
    // than to check the size of the code at that address.
    // See https://ethereum.stackexchange.com/a/14016/36603
    // for more details about how this works.
    // TODO Check this again before the Serenity release, because all addresses will be
    // contracts then.
    // solium-disable-next-line security/no-inline-assembly
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

}

contract STORAGE is Ownable{
    
    bytes32 constant private ZERO_BYTES = bytes32(0);
    bytes32 constant private TRUE_BYTES = 0x0000000000000000000000000000000000000000000000000000000000000001;
    address constant private ZERO_ADDRESS = address(0);
    address private _creosafeContract;
    
    bool public _frozen = false;
    bool public _dead = false;
     
    struct Contract{
        bool isAdded;
        uint256 numberOfDeal;
        bool isBlocked;
    }
    
    mapping(address => Contract) private contractList;
    
    struct TokenDeal{
        uint tokenAmount;   // Transfered token Amount
        bool isPaid;
        bool isFailed; // Starts False, When it is failed, contract is ready for refund
        bool isRefundtoBuyer; // Starts False, When contract refunded to buyer, it ll be True   
        bool isCompleted; //Starts False, When token transfer is complated, it ll be True
    }
    
    struct TokenDealPayment{
        uint _amount;
        bool _type; //true => ETH false => TOKEN
        address _tokenAddress; // it is ZERO_ADDRESS for ETH, Depand Type 
    }
    
    struct TokenDealMembers{
        address payable seller;
        bytes32 sellerSignature; // Empty
        bool sellerConfirmation; // Starts False, if it is confirmated signature will be hash otherwise error hash
        address payable buyer;
        bytes32 buyerSignature; // Empty
        bool buyerConfirmation; // Starts False, if it is confirmated signature will be hash otherwise error hash
    }
    
    struct TokenDealBD{
        address brokerDealer;
        bytes32 brokerDealerSignature; // Empty
        bool brokerDealerConfirmation; // Starts False, if it is confirmated signature will be hash otherwise error hash
    }
    
    mapping(address => mapping(uint => TokenDeal)) private _tokenDealList;
    mapping(address => mapping(uint => TokenDealMembers)) private _tokenDealMembersList;
    mapping(address => mapping(uint => TokenDealBD)) private _tokenDealBDList;
    mapping(address => mapping(uint => TokenDealPayment)) private _tokenDealPaymentList;
    
    modifier available(){
        require(!_frozen && !_dead, "Contract is not available");
        _;
    }
    
    modifier isValidAddress(address addr) {
        require(addr != ZERO_ADDRESS, "Wallet address is not valid");
        _;
    }
    
    modifier isContract(address addr){
        require(AddressUtils.isContract(addr), "Contract address is not valid");
        _;
    }
    
    modifier isContractExist(address addr){
        require(AddressUtils.isContract(addr), "Contract address is not valid");
        require(contractList[addr].isAdded, "Contract address is not added" ); 
        _;
    }
    
    modifier checkTrade(address addr, uint256 index){
        require(AddressUtils.isContract(addr), "Contract address is not valid");
        require(contractList[addr].isAdded, "Contract address is not added" ); 
        Contract memory C = contractList[msg.sender];
        require(!C.isBlocked,"Contract is blocked");
        require(index >0 && index <= C.numberOfDeal,"Trade number is not valid");
        TokenDeal memory TD = _tokenDealList[msg.sender][index];
        require(!TD.isFailed, "Trade already failed");
        _;
    }
    
    modifier isCreosafeAdmin(address addr){
        require(addr != ZERO_ADDRESS);
        bytes memory payload = abi.encodeWithSignature("isProviderAdmin(address)", addr);
        (bool success, bytes memory returnData) = address(_creosafeContract).staticcall(payload);
        require(success, "Creo contract reverted that isCreoAdmin");
        require(keccak256(returnData) ==  keccak256(abi.encodePacked(TRUE_BYTES)),"Wallet address has not authorization in Creo Contract"); 
        _;
    }
    
    constructor (address creosafeContract, address killer) Ownable(killer) public 
    isValidAddress(killer)
    isContract(creosafeContract){
        _creosafeContract = creosafeContract;
    }
    
    function killEmAll() public onlyKiller {
        _dead = true;
    }
    
    function freeze() public isCreosafeAdmin(msg.sender){
        require(!_dead);
        _frozen = true;
    }
    
    function defrost() public isCreosafeAdmin(msg.sender){
        require(!_dead);
        _frozen = false;
    }
    
    function getCreosafeContract() public view returns(address){
        return _creosafeContract;
    }
    
    function setCreosafeContract(address creosafeContract) public available isCreosafeAdmin(msg.sender) isContract(creosafeContract){
        _creosafeContract = creosafeContract;
    }
    
    function addContract(address _contractAddress) public available{
        require(!contractList[_contractAddress].isAdded);
        contractList[_contractAddress] = Contract(true, 0, false);
    }
    
    function setContractStatus(address _contractAddress, bool _status) public available isCreosafeAdmin(msg.sender) isContractExist(_contractAddress){
        Contract storage C = contractList[_contractAddress];
        C.isBlocked = _status;
    }
    
    function blockContract(bool status) public isContractExist(msg.sender){
        Contract storage C = contractList[msg.sender];
        C.isBlocked = status;
    }
    
    function getContract(address _contractAddress) public view isContractExist(_contractAddress) returns(address, uint256, bool){
        Contract memory C = contractList[_contractAddress];
        return (_contractAddress, C.numberOfDeal, C.isBlocked);
    }
    
    //BEGIN OF DEAL FUNCTIONS
    
    function setDeal(uint tokenAmount, address payable[] memory addresses) public 
        available isContractExist(msg.sender) returns(uint){
            Contract storage C = contractList[msg.sender];
            require(!C.isBlocked,"Contract is blocked");
            C.numberOfDeal++;
            _tokenDealList[msg.sender][C.numberOfDeal] = TokenDeal(tokenAmount, false, false, false, false);
            _tokenDealMembersList[msg.sender][C.numberOfDeal] = TokenDealMembers(addresses[0], "", false, addresses[1], "", false);
            _tokenDealBDList[msg.sender][C.numberOfDeal] = TokenDealBD( addresses[2], "", false);
            return C.numberOfDeal;
    }
    
    function sellerApprove(address seller, uint index, bytes32 signature) 
    public 
    available
    checkTrade(msg.sender, index) returns(bool){
        require(signature != ZERO_BYTES ,"Seller signature is empty");
        TokenDeal memory TD = _tokenDealList[msg.sender][index];
        TokenDealMembers storage TDM = _tokenDealMembersList[msg.sender][index];
        require(seller == TDM.seller, "Seller is not matched");
        require(!TDM.sellerConfirmation, "Seller already confirmated");
        TDM.sellerConfirmation = true;
        TDM.sellerSignature = signature;
        TokenDealBD memory TDBD = _tokenDealBDList[msg.sender][index];
        return (TD.isPaid && TDM.buyerConfirmation && TDBD.brokerDealerConfirmation);
    }
    
    
    function buyerApprove(address buyer, uint index, bytes32 signature) 
    public 
    available 
    checkTrade(msg.sender, index) returns(bool){
        require(signature != ZERO_BYTES ,"Buyer signature is empty");
        TokenDeal memory TD = _tokenDealList[msg.sender][index];
        TokenDealMembers storage TDM = _tokenDealMembersList[msg.sender][index];
        require(TDM.buyer == buyer, "Buyer is not matched");
        TDM.buyerConfirmation = true;
        TDM.buyerSignature = signature;
        TokenDealBD memory TDBD = _tokenDealBDList[msg.sender][index];
        return (TD.isPaid && TDM.sellerConfirmation && TDBD.brokerDealerConfirmation);
    }
    
    
    /*
    If we deployed broker dealler contract use it...
    
    function setBDApprove(address _brokerDealer, uint _index, bytes32 _signature) public isContractExist(msg.sender) 
        returns(address, address, uint256){
            require(_signature.length > 0);
            Contract memory C = contractList[msg.sender];
            require(!C.isBlocked);
            require(_index >0 && _index <= C.numberOfDeal);
            TokenDeal memory TD = tokenDealList[msg.sender][_index];
            require(!TD.isFailed);
            TokenDealMembers memory TDM = tokenDealMembersList[msg.sender][_index];
            require(TDM.buyerConfirmation);
            TokenDealBD storage TDBD = tokenDealBDList[msg.sender][_index];
            //require(TDBD.brokerDealerCA.call(bytes4(keccak256("isValidBrokerDealer(address)")), _brokerDealer) );
            bytes memory payload = abi.encodeWithSignature("isValidBrokerDealer(address)", _brokerDealer);
            (bool success, bytes memory returnData) = _addr.staticcall(payload);
            require(success);
            require(!TDBD.brokerDealerConfirmation);
            TDBD.brokerDealerConfirmation = true;
            TDBD.brokerDealerSignature = _signature;
            TD.isCompleted = true;
            return (TDM.seller, TDM.buyer, TD.tokenAmount);
    }
    
    */
    
    function setBDApprove(address brokerDealer, uint index, bytes32 signature) 
    public 
    available 
    checkTrade(msg.sender, index) returns(bool){
        require(signature != ZERO_BYTES ,"BD signature is empty");
        TokenDeal memory TD = _tokenDealList[msg.sender][index];
        TokenDealMembers memory TDM = _tokenDealMembersList[msg.sender][index];
        TokenDealBD storage TDBD = _tokenDealBDList[msg.sender][index];
        require(TDBD.brokerDealer == brokerDealer);
        require(!TDBD.brokerDealerConfirmation);
        TDBD.brokerDealerConfirmation = true;
        TDBD.brokerDealerSignature = signature;
        return (TD.isPaid && TDM.sellerConfirmation && TDM.buyerConfirmation);
    }
    
    
    //END OF DEAL FUNCTIONS
    
    //START OF CREO FUNCTIONS
    
    function changedBrokerDealer( uint index, address brokerDealer) public available isContractExist(msg.sender) returns(bool){
        Contract memory C = contractList[msg.sender];
        require(!C.isBlocked);
        require(index > 0 && index <=C.numberOfDeal);
        TokenDeal memory TD = _tokenDealList[msg.sender][index];
        require(!TD.isFailed && !TD.isCompleted && !TD.isRefundtoBuyer);
        TokenDealBD storage TDBD = _tokenDealBDList[msg.sender][index];
        require(!TDBD.brokerDealerConfirmation);
        TDBD.brokerDealer = brokerDealer;
        return true;
    }
    
    function doFailedOffer(uint index) public available isContractExist(msg.sender) returns(address,uint256){
        Contract memory C = contractList[msg.sender];
        require(index > 0 && index <=C.numberOfDeal);
        TokenDeal storage TD = _tokenDealList[msg.sender][index];
        require(!TD.isCompleted);
        TD.isFailed = true;
        TokenDealMembers memory TDM = _tokenDealMembersList[msg.sender][index];
        return (TDM.seller,TD.tokenAmount);
    }
    
    function setPayment(uint index, uint amount, bool _type, address tokenAddress) public 
    available 
    checkTrade(msg.sender, index) returns(bool, address){
        TokenDeal storage TD = _tokenDealList[msg.sender][index];
        require(!TD.isCompleted);
        require(!TD.isPaid);
        TD.isPaid = true;
        TokenDealMembers memory TDM = _tokenDealMembersList[msg.sender][index];
        TokenDealBD memory TDBD = _tokenDealBDList[msg.sender][index];
        _tokenDealPaymentList[msg.sender][index] = TokenDealPayment( amount, _type, tokenAddress);
        return (TDM.sellerConfirmation && TDM.buyerConfirmation && TDBD.brokerDealerConfirmation, TDM.buyer);
    }
    
    function getPaymentData(uint index) public available isContractExist(msg.sender) returns(address payable, address payable, uint256, uint256, bool){
        TokenDeal storage TD = _tokenDealList[msg.sender][index];
        TD.isCompleted = true;
        TokenDealMembers memory TDM = _tokenDealMembersList[msg.sender][index];
        TokenDealPayment memory TDP = _tokenDealPaymentList[msg.sender][index];
        return (TDM.seller, TDM.buyer, TD.tokenAmount, TDP._amount, TDP._type); //TDP._tokenAddress
    }
    
    function startRefundProcess(uint256 index) public available isContractExist(msg.sender) returns(address payable){
        Contract memory C = contractList[msg.sender];
        require(index > 0 && index <= C.numberOfDeal);
        TokenDeal storage TD = _tokenDealList[msg.sender][index];
        require(!TD.isCompleted);
        require(TD.isPaid);
        TD.isRefundtoBuyer = true;
        TokenDealMembers memory TDM = _tokenDealMembersList[msg.sender][index];
        return TDM.buyer;
    }
    
    // BEGIN OF PAYABLE FUNCTIONS
    
    function() payable external{
        revert(); 
    }
    
    // END OF PAYABLE FUNCTIONS
}
