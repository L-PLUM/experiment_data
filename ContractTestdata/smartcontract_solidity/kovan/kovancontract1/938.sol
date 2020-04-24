/**
 *Submitted for verification at Etherscan.io on 2018-12-14
*/

pragma solidity ^0.4.24;

// File: contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

// File: contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
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
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/token/ERC20Cutted.sol

contract ERC20Cutted {

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

}

// File: contracts/Room2Online.sol

contract Room2Online is Ownable {

  event TicketPurchased(address lotAddr, uint ticketNumber, address player, uint ticketPrice);

  event TicketPayed(address lotAddr, uint lotIndex, uint ticketNumber, address player, uint win);

  event LotFinished(address lotAddr, uint lotIndex);

  event ParametersUpdated(address feeWallet, uint feePercent, uint minInvestLimit);

  using SafeMath for uint;

  uint public PERCENT_RATE = 100;

  uint public minInvestLimit;

  uint public feePercent;

  address public feeWallet;

  struct Ticket {
    address owner;
    uint purchased;
    uint win;
    bool finished;
  }

  struct Lot {
    uint balance;
    uint[] ticketNumbers;
    uint finishedTime;
  }

  Ticket[] public tickets;

  uint public lotIndex;

  mapping(uint => Lot) public lots;

  modifier notContract(address to) {
    uint codeLength;
    assembly {
      codeLength := extcodesize(to)
    }
    require(codeLength == 0, "Contracts not supported!");
    _;
  }

  function updateParameters(address newFeeWallet, uint newFeePercent, uint newMinInvestLimit) public onlyOwner {
    feeWallet = newFeeWallet;
    feePercent = newFeePercent;
    minInvestLimit = newMinInvestLimit;
    emit ParametersUpdated(newFeeWallet, newFeePercent, newMinInvestLimit);
  }

  function getTicketInfo(uint ticketNumber) view public returns(address, uint, uint, bool) {
    Ticket storage ticket = tickets[ticketNumber];
    return (ticket.owner, ticket.purchased, ticket.win, ticket.finished);
  }

  constructor() public {
    minInvestLimit = 100000000000000000;
    feePercent = 30;
    feeWallet = 0x53F22b8f420317E7CDcbf2A180A12534286CB578;
    emit ParametersUpdated(feeWallet, feePercent, minInvestLimit);
  }

  function setFeeWallet(address newFeeWallet) public onlyOwner {
    feeWallet = newFeeWallet;
  }

  function () public payable notContract(msg.sender) {
    require(msg.value >= minInvestLimit);
    tickets.push(Ticket(msg.sender, msg.value, 0, false));    
    emit TicketPurchased(address(this), tickets.length.sub(1), msg.sender, msg.value);
    uint fee = msg.value.mul(feePercent).div(PERCENT_RATE);
    feeWallet.transfer(fee);
  }

  function processRewards(uint[] ticketNumbers, uint[] wins) public onlyOwner {
    Lot storage lot = lots[lotIndex];
    for(uint i = 0; i<ticketNumbers.length; i++) {
      uint ticketNumber = ticketNumbers[i];
      Ticket storage ticket = tickets[ticketNumber];
      if(!ticket.finished) {
        ticket.win = wins[i];
        ticket.finished = true;
        lot.ticketNumbers.push(ticketNumber);
        lot.balance = lot.balance.add(wins[i]);
        ticket.owner.transfer(wins[i]);
        emit TicketPayed(address(this), lotIndex, ticketNumber, ticket.owner, wins[i]);
      }
    }
  }

  function finishLot(uint lotFinishedTime) public onlyOwner {
    Lot storage lot = lots[lotIndex];
    lot.finishedTime = lotFinishedTime;
    emit LotFinished(address(this), lotIndex);
    lotIndex++;
  }

  function retrieveTokens(address tokenAddr, address to) public onlyOwner {
    ERC20Cutted token = ERC20Cutted(tokenAddr);
    token.transfer(to, token.balanceOf(address(this)));
  }

}
