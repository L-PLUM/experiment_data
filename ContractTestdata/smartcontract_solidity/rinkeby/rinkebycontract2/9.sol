/**
 *Submitted for verification at Etherscan.io on 2019-08-12
*/

// File: contracts/erc721.sol

pragma solidity >=0.4.21 <0.6.0;

contract ERC721 {
  event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

  function balanceOf(address _owner) external view returns (uint256);

  function ownerOf(uint256 _tokenId) external view returns (address);

  function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

  function approve(address _approved, uint256 _tokenId) external payable;
}

// File: contracts/safemath.sol

pragma solidity >=0.4.21 <0.6.0;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title SafeMath32
 * @dev SafeMath library implemented for uint32
 */
library SafeMath32 {

  function mul(uint32 a, uint32 b) internal pure returns (uint32) {
    if (a == 0) {
      return 0;
    }
    uint32 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint32 a, uint32 b) internal pure returns (uint32) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint32 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint32 a, uint32 b) internal pure returns (uint32) {
    assert(b <= a);
    return a - b;
  }

  function add(uint32 a, uint32 b) internal pure returns (uint32) {
    uint32 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title SafeMath16
 * @dev SafeMath library implemented for uint16
 */
library SafeMath16 {

  function mul(uint16 a, uint16 b) internal pure returns (uint16) {
    if (a == 0) {
      return 0;
    }
    uint16 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint16 a, uint16 b) internal pure returns (uint16) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint16 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint16 a, uint16 b) internal pure returns (uint16) {
    assert(b <= a);
    return a - b;
  }

  function add(uint16 a, uint16 b) internal pure returns (uint16) {
    uint16 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/TicketCreation.sol

pragma solidity >=0.4.21 <0.6.0;



contract TicketCreation is ERC721 {

  using SafeMath for uint256;

  /* Emit events when new accounts and new tickets have been created */
  event NewTicket(uint256 indexed ticketId, string eventName, string description, uint256 price, uint256 status);

   address payable contractDeployer;
   bool public contractPaused;

   constructor() public {
    contractDeployer = msg.sender;
    contractPaused = false;
    }

  /* Struct for User */
  struct User {
    address userAd;
    string firstName;
    string lastName;
  }

  /* Struct for Ticket, ticket ID is stored in a mapping below in ticketsToOwner */
  struct Ticket {
    string eventName;
    string description;
    uint256 price;
    uint256 marketStatus;
  }

  User[] users; /* Array of Users */
  Ticket[] public tickets; /* Array of Tickets */

  /* Maps address to user ID */
  mapping (address => uint256) public adToUserId;
  /* Maps ticket IDs to user addresses */
  mapping (uint256 => address) public ticketsToOwner;
  /* Maps users to their number of tickets held */
  mapping (address => uint256) public ownerToQuantity;

  modifier onlyContractDeployer() {
    require(msg.sender == contractDeployer, 'You are not the contract deployer.');
    _;
  }

  modifier checkIfPaused() {
    require(contractPaused == false, 'Contract already paused.');
    _;
  }

  function circuitBreaker() public onlyContractDeployer() returns(bool){
    if(contractPaused == false) {
      contractPaused = true;
    } else{contractPaused = false;}
    return contractPaused;
  }

  function createAccount(string calldata _firstName, string calldata _lastName) external checkIfPaused() returns (uint256) {
    uint256 userId = users.push(User(msg.sender, _firstName, _lastName));
    adToUserId[msg.sender] = userId;
    return userId;
  }

  function createTicket(string calldata _eventName, string calldata _description, uint256 _price) external onlyContractDeployer() {
    uint256 ticketId = tickets.push(Ticket(_eventName, _description, _price, 0))-1;
    ticketsToOwner[ticketId] = msg.sender;
    ownerToQuantity[msg.sender] = ownerToQuantity[msg.sender].add(1);
    emit NewTicket(ticketId, _eventName, _description, _price, 0); /* Event emitter */
  }

}

// File: contracts/TicketTransfer.sol

pragma solidity >=0.4.21 <0.6.0;


contract TicketTransfer is TicketCreation {

    enum SecondaryMarketStatus {
    PendingApproval,
    ApprovedByBuyer,
    OwnershipTransferred,
    DoneDeal
    }

    uint64 commissionFactor;

    constructor() public {
        commissionFactor = 30;
    }

    event Transfer(address indexed _from, address indexed _to, uint256 indexed _ticketId);
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _ticketId);

    mapping (uint256 => uint256) ticketIdToPending;
    mapping (uint256 => address) ticketIdToOldOwner;
    mapping (uint256 => address) public approvedBuyers;

    /* This modifier does not allow the msg.sender to be the seller */
    modifier notSeller(uint256 _ticketId){
        require(msg.sender != ticketsToOwner[_ticketId], "You are not the buyer.");
        _;
    }

    /* This modifier requires the ticket holder to be msg.sender */
    modifier ownsTicket(uint256 _ticketId){
        require(ticketsToOwner[_ticketId] == msg.sender, "You don't own the ticket.");
        _;
    }

    function getContractDeployer() public view returns (address) {
        return contractDeployer;
    }

    function getTicketCount() public view returns (uint256) {
        return tickets.length;
    }

    function balanceOf(address _owner) external view returns (uint256){
        return ownerToQuantity[_owner];
    }

    function ownerOf(uint256 _ticketId) external view returns (address){
        return ticketsToOwner[_ticketId];
    }

    function getPrice(uint256 _ticketId) public view returns (uint256) {
        return tickets[_ticketId].price;
    }

    function getStatus(uint256 _ticketId) public view returns (uint256) {
        return tickets[_ticketId].marketStatus;
    }

    /* 1st TIME PURCHASE FROM PLATFORM - this is called when 1st time buyer presses the 'Purchase' button */
    function transferFrom(address _from, address _to, uint256 _ticketId) external payable checkIfPaused() notSeller(_ticketId) {
        require(msg.value == (tickets[_ticketId].price)*1 ether, "Not enough money."); /* Requires buyer to pay the price of ticket */
        require(adToUserId[_to] > 0, "Please create an account first."); /* Requires user to have an account */
        ticketsToOwner[_ticketId] = _to;
        ownerToQuantity[_from] = ownerToQuantity[_from].sub(1);
        ownerToQuantity[_to] = ownerToQuantity[_to].add(1);
        emit Transfer(_from, _to, _ticketId);
    }

    function transferEthToCD(uint256 _ticketId) external payable checkIfPaused() {
        contractDeployer.transfer((tickets[_ticketId].price) * 1 ether);
    }

    /* Buyer revises the price */
    function priceRevise(uint256 _ticketId, uint256 _newPrice) external checkIfPaused() ownsTicket(_ticketId) returns(uint256) {
        tickets[_ticketId].price = _newPrice;
    }

    /* SECONDARY MARKET - a person looking to resell his/her ticket can only sell to a willing/approved buyer. This function is called by buyer. */
    function approve(address _approved, uint256 _ticketId) external payable checkIfPaused() notSeller(_ticketId) {
        require(adToUserId[msg.sender] > 0, "Please create an account first.");
        require(msg.value == (tickets[_ticketId].price) * 1 ether, "Not enough money."); /* Requires buyer to pay the price of ticket */
        approvedBuyers[_ticketId] = _approved; /* Buyer approves him/herself for the ticket, goes into the approved buyer mapping */
        ticketIdToPending[_ticketId] = msg.value; /* Buyer's money gets stored in the contract, so we store it in a temp mapping */
        tickets[_ticketId].marketStatus = 1;
        emit Approval(ticketsToOwner[_ticketId], _approved, _ticketId);
    }

    /* Returning the approved buyer's address of a particular ticket ID */
    function getApprovedBuyer(uint256 _ticketId) public view returns(address){
        return approvedBuyers[_ticketId];
    }

    /* SECONDARY MARKET - after the buyer is approved, seller presses 'Sell' button, and then the ticket's ownership gets transferred. Seller also gets money from contract. */
    function transferFromSecond(address _to, uint256 _ticketId) external checkIfPaused() ownsTicket(_ticketId) {
        require(adToUserId[msg.sender] > 0, "Please create an account first.");
        require(tickets[_ticketId].marketStatus == 1, "Not yet approved by any buyer.");
        require(approvedBuyers[_ticketId] == _to, "This is not an approved buyer.");
        ticketsToOwner[_ticketId] = _to;
        ticketIdToOldOwner[_ticketId] = msg.sender;
        ownerToQuantity[msg.sender] = ownerToQuantity[msg.sender].sub(1);
        ownerToQuantity[_to] = ownerToQuantity[_to].add(1);
        tickets[_ticketId].marketStatus = 2;
        delete(approvedBuyers[_ticketId]); /* Can be deleted to refund gas */
        emit Transfer(msg.sender, _to, _ticketId);
        }

    function transferEthSecond(uint256 _ticketId) external payable checkIfPaused() {
        require(tickets[_ticketId].marketStatus == 2, "Ticket not yet transferred.");
        require(ticketIdToOldOwner[_ticketId] == msg.sender, "You cannot run this operation.");
        address payable receiver = msg.sender;
        uint256 commissionAmount = ticketIdToPending[_ticketId]/commissionFactor;
        uint256 sellerAmount = ticketIdToPending[_ticketId] - commissionAmount;
        contractDeployer.transfer(commissionAmount);
        receiver.transfer(sellerAmount);
        tickets[_ticketId].marketStatus = 3;
        delete(ticketIdToPending[_ticketId]); /* Can be deleted to refund gas */
        delete(ticketIdToOldOwner[_ticketId]); /* Can be deleted to refund gas */
    }

    function kill() external onlyContractDeployer() {
        selfdestruct(contractDeployer);
    }
}
