/**
 *Submitted for verification at Etherscan.io on 2019-07-18
*/

pragma solidity ^0.5.10;

interface QueryInterface {
  enum QueryStatus { INVALID, OK, NOT_AVAILABLE, DISAGREEMENT }

  function query(bytes calldata input)
    external payable returns (bytes32 output, uint256 updatedAt, QueryStatus status);

  function queryPrice() external view returns (uint256);
}

contract TicketContract {
  uint256 public constant ticketPrice = 10;    /// In USD
  mapping (address => bool) public hasTicket;  /// Whether a user has a ticket

  function buyTicket() public payable {
    require(!hasTicket[msg.sender], "Must not already have a ticket");
    require(msg.value * getETHUSDRate() / 1e36 >= ticketPrice, "INSUFFICIENT_ETHER");
    hasTicket[msg.sender] = true;
  }

  function getETHUSDRate() internal returns (uint256 rate) {
    QueryInterface q = QueryInterface(0x07416E24085889082d767AF4CA09c37180A3853c);
    (bytes32 rawRate,, QueryInterface.QueryStatus status) = q.query.value(q.queryPrice())("ETH/USD");
    require(status == QueryInterface.QueryStatus.OK);
    return uint256(rawRate);
  }
}
