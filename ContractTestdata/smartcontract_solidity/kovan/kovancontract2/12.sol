/**
 *Submitted for verification at Etherscan.io on 2019-08-10
*/

pragma solidity 0.5.10;

interface Oracle {
    enum QueryStatus { INVALID, OK, NOT_AVAILABLE, DISAGREEMENT }
    
    function query(bytes calldata input)
        external payable
        returns (bytes32 output, uint256 updatedAt, QueryStatus status);
        
    function queryPrice()
        external view returns (uint256);
}

contract TicketSeller {
    uint256 public remainingTicketCount;
    mapping (address => uint256) public tickets;
    
    constructor(uint256 totalTicket) public {
        remainingTicketCount = totalTicket;
    }
    
    function ticketCount(address owner) public view returns (uint256) {
        return tickets[owner];
    }
    
    function transfer(address to) public {
        require(tickets[msg.sender] > 0, "ERROR_NO_TICKET_TO_SEND");
        tickets[msg.sender] -= 1;
        tickets[to] += 1;
    }
    
    function buyTicket() public payable {
        uint256 ticketPrice = getTicketPrice();
        require(msg.value >= ticketPrice, "ERROR_NOT_ENOUGH_PAYMENT");
        require(remainingTicketCount > 0, "ERROR_NO_TICKET_TO_SELL");
        remainingTicketCount -= 1;
        tickets[msg.sender] += 1;
    }
    
    function getTicketPrice() public payable returns (uint256) {
        // 1. Get THB/USD exchange rate
        Oracle oracle1 = Oracle(0x61Ab2054381206d7660000821176F2A798F031de);
        (bytes32 thbUsd,,) = oracle1.query.value(oracle1.queryPrice())("THB/USD");
        // 2. Get ETH/USD exchange rate
        Oracle oracle2 = Oracle(0x07416E24085889082d767AF4CA09c37180A3853c);
        (bytes32 ethUsd,,) = oracle2.query.value(oracle2.queryPrice())("ETH/USD");
        // 3. Return 100 * (1) * 1e18 * / (2)
        return 100 * uint256(thbUsd) * 1e18 / uint256(ethUsd);
    }
}
