/**
 *Submitted for verification at Etherscan.io on 2019-01-10
*/

pragma solidity ^0.4.25;


library SafeMathLib {

/**
* Issue: Change to internal constant
**/
  function minus(uint a, uint b) internal pure returns (uint) {
    return a - b;
  }

/**
* Issue: Change to internal constant
**/
  function plus(uint a, uint b) internal pure returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function times(uint a, uint b) internal pure returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function min(uint a, uint b) internal pure returns (uint) {
      if(a<b){
          return a;
      }
      else{
          return b;
      }
  }

}

/**
 * @title Ownable
 * @notice The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {

  address public owner;
  mapping (address => bool) public accessHolder;
  event RevokeStaffStatus(address admin, address user);

  /**
   * @notice The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @notice Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner || msg.sender == address(this));
    _;
  }

  /**
   * @notice Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    owner = newOwner;
  }

  /**
   * @notice Adds the provided addresses to Access List.
   * @param user The address to user to whom access is to be granted.
   */
  function addToAccesslist(address user) public isStaff {
    accessHolder[user] = true;
  }

  function revokeStaffStatus(address user) public isStaff {
    accessHolder[user] = false;
    emit RevokeStaffStatus(msg.sender, user);
  }

  modifier isStaff() {
      require(checkStaffStatus(msg.sender));
      _;
  }

  function checkStaffStatus(address user) public view returns(bool){
      return accessHolder[user] ||  user == owner || user == address(this);
  }
}


contract MahindraLendingPOC is Ownable{
    using SafeMathLib for uint;
    mapping(string => mapping(address => bool)) mapAuthorizedUsers;
    mapping(string => bool) mapRegisteredCompanies;
    mapping(string => uint) companyLendingMargins;     // Utilized Lending margins
    mapping(string => uint) companyBorrowMargins;      // Utilized Borrowing margins
    mapping(string => uint) mapCompanyBorrowLimit;     // Borrowing Limit
    mapping(string => uint) mapCompanyLendingLimit;    // Lending Limit

    mapping(string => bool) mapOffersAccepted;         // Notorized Offers  // an offer can be notorized only once

    bool public checkSignature = false;

    mapping(string => uint) mapLoanPendingAmount;

    uint public etherIssuance = 1*10**16;

    event ApprovedTransaction(address admin,string offerId, string lender, string borrower, uint amount, uint roi, uint tenure);
    event CompanyRegistered(string company);
    event AuthorizerAddition(string company, string userid, address auth_user, bool status);
    event AuthorizerRemoval(address admin, string company, address auth_user, string userid);
    event CompanyBanned(address admin, string company);
    event companyBanRemoved(address admin, string company);
    event CompanyLimitsUpdated(address admin, string company, uint oldBorrowLimit, uint newBorrowLimit, uint oldLendingLimit, uint newLendingLimit);
    event LoanPrincipalRepayment(address sender, string offerId, string borrowerCompany, string lendingCompany, uint amount);
    event AdminAdded(address sender, address admin_user);

    function validateMargin(string company, uint amount, bool isBorrow) public view returns(bool){
        uint limitVal = 0;
        if(isBorrow){
            limitVal = mapCompanyBorrowLimit[company];
            return companyBorrowMargins[company].plus(amount) <= limitVal;
        }
        else {
            limitVal = mapCompanyLendingLimit[company];
            return companyLendingMargins[company].plus(amount) <= limitVal;
        }
        return false;
    }

    function getCompanyBorrowLimit(string company) public view returns(uint){
        return mapCompanyBorrowLimit[company];
    }

    function getCompanyLendingLimit(string company) public view returns(uint){
        return mapCompanyLendingLimit[company];
    }

    constructor() payable public {
    }

    function () payable public{
    }

    function checkAuthorisedUser(string company, address auth_user, bool isBorrow, uint amount) public view returns(bool){
        require(mapRegisteredCompanies[company]);
        require(mapAuthorizedUsers[company][auth_user] || checkStaffStatus(auth_user));
        require(validateMargin(company, amount, isBorrow));
        return true;
    }

    function registerCompany(string company) isStaff public{
        mapRegisteredCompanies[company] = true;
        emit CompanyRegistered(company);
    }

    function addAuthorizer(string company, string userid, address auth_user) isStaff public{
        mapAuthorizedUsers[company][auth_user] = true;
        emit AuthorizerAddition(company, userid, auth_user, true);
        auth_user.transfer(etherIssuance);
    }

    function addAdmin(address admin_user) public {
        addToAccesslist(admin_user);
        emit AdminAdded(msg.sender, admin_user);
        admin_user.transfer(etherIssuance);
    }

    function removeAuthorizer(string company, string userid, address auth_user) isStaff public {
        mapAuthorizedUsers[company][auth_user] = false;
        emit AuthorizerRemoval(msg.sender, company, auth_user, userid);
    }

    function validateSignature(address auth_user, string offerId, string lendingCompany, string borrowerCompany, uint amount, uint roi, uint tenure, uint8 v1, bytes32 r1, bytes32 s1) internal pure returns(bool) {
        bytes32 hash = keccak256(abi.encodePacked(offerId, lendingCompany, borrowerCompany, amount, roi, tenure));
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 msgHash = keccak256(abi.encodePacked(prefix, hash));
        return auth_user == ecrecover(msgHash, v1, r1, s1);
    }


    function notarizeTransaction(string offerId, address lender_auth_user, address borrower_auth_user, string lendingCompany, string borrowerCompany, uint amount, uint roi, uint tenure, uint8 v1, bytes32 r1, bytes32 s1, uint8 v2, bytes32 r2, bytes32 s2) isStaff public{
        require(!mapOffersAccepted[offerId]);
        require(validateSignature(lender_auth_user, offerId, lendingCompany, borrowerCompany, amount, roi, tenure, v1,r1,s1));
        require(validateSignature(borrower_auth_user, offerId, lendingCompany, borrowerCompany, amount, roi, tenure, v2,r2,s2));
        mapOffersAccepted[offerId] = true;
        mapLoanPendingAmount[offerId] = amount;
        require(checkAuthorisedUser(lendingCompany, lender_auth_user, false, amount));
        require(checkAuthorisedUser(borrowerCompany, borrower_auth_user, true, amount));
        companyLendingMargins[lendingCompany] = companyLendingMargins[lendingCompany].plus(amount);
        companyBorrowMargins[borrowerCompany] = companyBorrowMargins[borrowerCompany].plus(amount);
        emit ApprovedTransaction(msg.sender, offerId, lendingCompany, borrowerCompany, amount, roi, tenure);
    }

    function updateLimits(string company, uint newLendingLimit, uint newBorrowLimit) public {
        require(mapAuthorizedUsers[company][msg.sender] || checkStaffStatus(msg.sender));
        uint oldBorrowLimit = mapCompanyBorrowLimit[company];
        uint oldLendingLimit = mapCompanyLendingLimit[company];
        mapCompanyLendingLimit[company] = newLendingLimit;
        mapCompanyBorrowLimit[company] = newBorrowLimit;
        emit CompanyLimitsUpdated(msg.sender, company, oldBorrowLimit, newBorrowLimit, oldLendingLimit, newLendingLimit);
    }

    function repayPrincipal(string borrowerCompany, string lendingCompany, uint amount, string offerId) public {
        require(mapAuthorizedUsers[borrowerCompany][msg.sender] || mapAuthorizedUsers[lendingCompany][msg.sender] || checkStaffStatus(msg.sender));
        mapLoanPendingAmount[offerId] = mapLoanPendingAmount[offerId].minus(amount);
        companyLendingMargins[lendingCompany] = companyLendingMargins[lendingCompany].minus(amount);
        companyBorrowMargins[borrowerCompany] = companyBorrowMargins[borrowerCompany].minus(amount);
        emit LoanPrincipalRepayment(msg.sender, offerId, borrowerCompany, lendingCompany, amount);
    }

    function pendingLoanPrincipalAmount(string offerId) public view returns(uint) {
        return mapLoanPendingAmount[offerId];
    }

    function getUsedBorrowMargin(string company) public view returns(uint) {
        return companyBorrowMargins[company];
    }

    function getUsedLendingMargin(string company) public view returns(uint) {
        return companyLendingMargins[company];
    }


    function checkSignature(bool status) public onlyOwner{
        checkSignature= status;
    }

    function balance() view public returns(uint) {
        return address(this).balance/(1 ether);
    }

    function refundBalance() public onlyOwner{
        owner.transfer(address(this).balance);
    }

    function updateEtherIssuance(uint newValue) public isStaff {
        etherIssuance = newValue;
    }
}
