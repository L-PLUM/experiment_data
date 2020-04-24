/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity >=0.5.0;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20OptionTrade {
    
    enum TradeState {None, Sell, Buy, Matched, Closed}
    
    struct Trade {
        address payable buyer;
        address payable seller;
        string symbol;
        uint256 payment;
        uint256 deposit;
        uint256 amountOfTokens;
        uint256 expiration;
        TradeState state;
    }
    
    event OpenTrade(uint256 tradeId, address buyer, address seller, string symbol, uint256 payment, uint256 deposit, uint256 amount, uint256 expiration, TradeState state);
    event MatchTrade(uint256 tradeId, address buyer, address seller);
    event CloseTrade(uint256 tradeId, address buyer, address seller, bool expired);

    address owner;
    uint256 feesGathered = 0;
    uint256 public tradeCounter = 0;
    
    mapping (uint256 => Trade) public trades;
    mapping (bytes32 => IERC20) private tokens;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }
    
    function() external payable {}
    
    function convert(string memory key) private pure returns (bytes32 ret) {
        require(bytes(key).length <= 32);
        assembly {
          ret := mload(add(key, 32))
        }
    }
    
    function setTokenProduct(string memory symbol, address token) public onlyOwner {
        tokens[convert(symbol)] = IERC20(token);
    }
    
    function getTokenInfo(string memory symbol) public view returns (IERC20) {
        return tokens[convert(symbol)];
    }
    
    function openTrade(string memory side, string memory symbol, uint256 amountOfTokens, uint256 priceOfOneToken, uint256 depositPercentage, uint256 expireAfterHours, address payable other) public payable {
        require(tokens[convert(symbol)] != IERC20(0x0));
        uint256 payment = amountOfTokens * priceOfOneToken;
        uint256 depositRequired = depositPercentage * payment / 100;
        uint256 fee = computeFee(payment);
        if (convert(side) == convert("WTB")) {
            require(msg.value >= payment + fee);
            if (msg.value > payment + fee) {
                msg.sender.transfer(msg.value - payment - fee);
            }
            tradeCounter++;
            trades[tradeCounter] = Trade(msg.sender, other, symbol, payment, depositRequired, amountOfTokens, now + expireAfterHours * 1 hours, TradeState.Buy);
            emit OpenTrade(tradeCounter, msg.sender, other, symbol, payment, depositRequired, amountOfTokens, now + expireAfterHours * 1 hours, TradeState.Buy);
        } else if (convert(side) == convert("WTS")) {
            require(msg.value >= depositRequired + fee);
            if (msg.value > depositRequired + fee) {
                msg.sender.transfer(msg.value - depositRequired - fee);
            }
            tradeCounter++;
            trades[tradeCounter] = Trade(other, msg.sender, symbol, payment, depositRequired, amountOfTokens, now + expireAfterHours * 1 hours, TradeState.Sell);
            emit OpenTrade(tradeCounter, other, msg.sender, symbol, payment, depositRequired, amountOfTokens, now + expireAfterHours * 1 hours, TradeState.Sell);
        } else {
            revert();
        }
    }
    
    function cancelOpenTrade(uint256 tradeId) public {
        if (trades[tradeId].state == TradeState.Sell) {
            require(trades[tradeId].seller == msg.sender);
            msg.sender.transfer(trades[tradeId].deposit + computeFee(trades[tradeId].payment));
        } else if (trades[tradeId].state == TradeState.Buy) {
            require(trades[tradeId].buyer == msg.sender);
            msg.sender.transfer(trades[tradeId].payment + computeFee(trades[tradeId].payment));
        } else {
            revert();
        }
        trades[tradeId].state = TradeState.Closed;
        emit CloseTrade(tradeId, trades[tradeId].buyer, trades[tradeId].seller, false);
    }
    
    function matchTrade(uint256 tradeId) public payable {
        require(trades[tradeId].state == TradeState.Sell || trades[tradeId].state == TradeState.Buy);
        if (trades[tradeId].buyer == address(0x0)) {
            trades[tradeId].buyer = msg.sender;
        } else if (trades[tradeId].seller == address(0x0)) {
            trades[tradeId].seller = msg.sender;
        }
        uint256 deposit = trades[tradeId].deposit;
        uint256 payment = trades[tradeId].payment;
        deposit += computeFee(payment);
        payment += computeFee(payment);
        if (msg.sender == trades[tradeId].seller) {
            require(msg.value >= deposit);
            if (msg.value > deposit) {
                msg.sender.transfer(msg.value - deposit);
            }
        } else if (msg.sender == trades[tradeId].buyer) {
           require(msg.value >= payment);
           if (msg.value > payment) {
                msg.sender.transfer(msg.value - payment);
           }
        } else {
            revert("You cannot interact with this trade!");
        }
        trades[tradeId].state = TradeState.Matched;
        emit MatchTrade(tradeId, trades[tradeId].buyer, trades[tradeId].seller);
    }
    
    function completeTrade(uint256 tradeId) public payable {
        require(tokens[convert(trades[tradeId].symbol)] != IERC20(0x4));
        require(trades[tradeId].state == TradeState.Matched);
        trades[tradeId].state = TradeState.Closed;
        require(tokens[convert(trades[tradeId].symbol)].transferFrom(trades[tradeId].seller, trades[tradeId].buyer, trades[tradeId].amountOfTokens));
        trades[tradeId].seller.transfer(trades[tradeId].payment + trades[tradeId].deposit);
        feesGathered += 2 * computeFee(trades[tradeId].payment);
        emit CloseTrade(tradeId, trades[tradeId].buyer, trades[tradeId].seller, false);
    }
    
    function claimDeposit(uint256 tradeId) public payable {
        require(trades[tradeId].state == TradeState.Matched);
        require(trades[tradeId].buyer == msg.sender && trades[tradeId].expiration < now);
        trades[tradeId].state = TradeState.Closed;
        trades[tradeId].buyer.transfer(trades[tradeId].payment + trades[tradeId].deposit);
        feesGathered += 2 * computeFee(trades[tradeId].payment);
        emit CloseTrade(tradeId, trades[tradeId].buyer, trades[tradeId].seller, true);
    }
    
    function withdrawFees(uint256 amount) public onlyOwner {
        require(feesGathered >= amount);
        feesGathered -= amount;
        msg.sender.transfer(amount);
    }
    
    function computeFee(uint256 value) private pure returns (uint256) {
        uint256 fee = value * 5;
        require(fee / 5 == value); // Check overflow
        return fee / 1000; // This is the fee we take on each side (0.5% * payment)
    }
}
