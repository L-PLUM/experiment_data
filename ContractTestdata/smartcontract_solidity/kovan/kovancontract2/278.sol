/**
 *Submitted for verification at Etherscan.io on 2019-07-18
*/

pragma solidity 0.5.10;


interface QueryInterface {
    enum QueryStatus { INVALID, OK, NOT_AVAILABLE, DISAGREEMENT }
    
    function query(bytes calldata input) external payable
        returns (bytes32 output, uint256 updatedAt, QueryStatus status);
        
    function queryPrice() external view returns (uint256);
}


contract TicketSeller {
    uint256 public constant TICKET_PRICE_IN_USD = 10;
    
    mapping (address => bool) public hasTicket;
    
    function buyTicket() public payable {
        require(!hasTicket[msg.sender]);
        uint256 ticketPriceInWei = 1e36 * TICKET_PRICE_IN_USD / getETHUSDPriceTimes10to18();
        require(msg.value >= ticketPriceInWei);
        if (msg.value > ticketPriceInWei) {
            msg.sender.transfer(msg.value - ticketPriceInWei);
        }
        hasTicket[msg.sender] = true;
    }
    
    function getETHUSDPriceTimes10to18() internal returns (uint256) {
        QueryInterface q = QueryInterface(0x07416E24085889082d767AF4CA09c37180A3853c);
        (bytes32 output,, QueryInterface.QueryStatus status) = q.query.value(q.queryPrice())("ETH/USD");
        require(status == QueryInterface.QueryStatus.OK);
        return uint256(output);
    }
}
