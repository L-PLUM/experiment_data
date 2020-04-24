/**
 *Submitted for verification at Etherscan.io on 2019-08-12
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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
}

contract ERC20OptionTrade {
    using SafeMath for uint256;
    
    enum TradeState {None, SellPaid, BuyPaid, Matched, Closed}
    
    struct Trade {
        address payable buyer;
        address payable seller;
        string symbol;
        uint256 payment;
        uint256 amountOfTokens;
        uint256 deposit;
        uint256 expiration;
        TradeState state;
    }
    event OpenTrade(uint256 tradeId, address buyer, address seller, string symbol, uint256 pricePerToken, uint256 amountOfTokens, uint256 depositPercentage, uint256 expiration, TradeState state);
    event MatchTrade(uint256 tradeId, address buyer, address seller);
    event CloseTrade(uint256 tradeId, address buyer, address seller, bool expired);
    
    address private owner;
    uint256 public feesGathered;

    mapping (uint256 => Trade) public trades;
    mapping (bytes32 => IERC20) private tokens;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    constructor() public {
        owner = msg.sender;
    }
    
    function() external payable {
        revert();
    }
    
    function AB_trade(bool wantToBuy, string memory symbol, uint256 amountOfTokens, uint256 pricePerToken, uint256 depositPercentage, uint256 expiration, address payable other) public payable {
        require(tokens[convert(symbol)] != IERC20(0x0));
        require(pricePerToken >= 1000); // min price so that divisions with 1000 never give remainder
        Trade memory t;
        (t.symbol, t.payment, t.amountOfTokens, t.deposit, t.expiration)
        = (symbol, pricePerToken.mul(amountOfTokens), amountOfTokens, pricePerToken.mul(amountOfTokens).mul(depositPercentage) / 100, expiration);
        
        uint256 paymentRequired;
        (t.buyer, t.seller, t.state, paymentRequired) = wantToBuy 
        ? (msg.sender, other, TradeState.BuyPaid, t.payment.add(computeFee(t.payment))) 
        : (other, msg.sender, TradeState.SellPaid, t.deposit.add(computeFee(t.payment)));
        
        require(msg.value >= paymentRequired);
        uint256 tradeId = uint256(keccak256(abi.encodePacked(t.buyer, t.seller, t.symbol, t.amountOfTokens, pricePerToken, depositPercentage, t.expiration)));
        Trade storage existingTrade = trades[tradeId];
        if (existingTrade.state == TradeState.None) {
            emit OpenTrade(tradeId, t.buyer, t.seller, t.symbol, pricePerToken, t.amountOfTokens, depositPercentage, t.expiration, t.state);
            trades[tradeId] = t;
        } else if (t.state == TradeState.BuyPaid && existingTrade.state == TradeState.SellPaid 
                || t.state == TradeState.SellPaid && existingTrade.state == TradeState.BuyPaid) {
            emit MatchTrade(tradeId, t.buyer, t.seller);
            existingTrade.state = TradeState.Matched;
        } else {
            revert();
        }
        msg.sender.transfer(msg.value - paymentRequired);
    }
    
    function B_matchTrade(uint256 tradeId) public payable {
        Trade storage t = trades[tradeId];
        uint256 paymentRequired;

        if(t.state == TradeState.SellPaid) {
            if (t.buyer == address(0x0)) {
                t.buyer = msg.sender;
            } else {
                require(msg.sender ==  t.buyer);
            }
            paymentRequired = t.payment.add(computeFee(t.payment));
        } else if(t.state == TradeState.BuyPaid) {
            if (t.seller == address(0x0)) {
                t.seller = msg.sender;
            } else {
                require(msg.sender ==  t.seller);
            }
            paymentRequired = t.deposit.add(computeFee(t.payment));
        } else {
            revert();
        }
        require(msg.value >= paymentRequired);
        emit MatchTrade(tradeId, t.buyer, t.seller);
        t.state = TradeState.Matched;
        msg.sender.transfer(msg.value - paymentRequired);
    }
    
    function C_cancelOpenTrade(uint256 tradeId) public {
        Trade storage t = trades[tradeId];
        require(t.state == TradeState.SellPaid || t.state == TradeState.BuyPaid);
        
        address payable actor;
        uint256 refund;

        (actor, refund) = (t.state == TradeState.SellPaid) 
        ? (t.seller, t.deposit.add(computeFee(t.payment)))
        : (t.buyer, t.payment.add(computeFee(t.payment)));
        
        require(msg.sender == actor);
        t.state = TradeState.Closed;
        emit CloseTrade(tradeId, t.buyer, t.seller, false);
        msg.sender.transfer(refund);
    }
    
    function D_completeTrade(uint256 tradeId) public {
        Trade storage t = trades[tradeId];
        require(t.state == TradeState.Matched);
        IERC20 token = tokens[convert(t.symbol)];
        require(token != IERC20(0x4));
        t.state = TradeState.Closed;
        require(token.transferFrom(t.seller, t.buyer, t.amountOfTokens));
        payClosedTrade(tradeId, false);
    }
    
    function D_claimDeposit(uint256 tradeId) public {
        Trade storage t = trades[tradeId];        
        require(t.state == TradeState.Matched);
        require(t.buyer == msg.sender && t.expiration < now);
        t.state = TradeState.Closed;
        payClosedTrade(tradeId, true);
    }
    
    function payClosedTrade(uint256 tradeId, bool expired) internal {
        Trade storage t = trades[tradeId]; 
        feesGathered += computeFee(t.payment).mul(2);
        emit CloseTrade(tradeId, t.buyer, t.seller, expired);
        (expired ? t.buyer : t.seller).transfer(t.payment + t.deposit);
    }
    
    function _withdrawFees(uint256 amount) public onlyOwner {
        require(feesGathered >= amount);
        feesGathered -= amount;
        msg.sender.transfer(amount);
    }
    
    function computeFee(uint256 value) private pure returns (uint256) {
        return value.mul(5) / 1000; // This is the fee we take on each side (0.5%)
    }
     
    function convert(string memory key) private pure returns (bytes32 ret) {
        require(bytes(key).length <= 32);
        assembly {
          ret := mload(add(key, 32))
        }
    }
    
    function getExpirationAfter(uint256 amountOfHours) public view returns (uint256) {
        return now.add(amountOfHours.mul(1 hours));
    }
    
    function tradeInfo(bool wantToBuy, string memory symbol, uint256 amountOfTokens, 
        uint256 priceOfOneToken, uint256 depositPercentage, uint256 expiration, address payable other) public view 
    returns (uint256 _tradeId, uint256 _buySideTotal, uint256 _sellSideTotal, TradeState _state) {
        _buySideTotal = amountOfTokens.mul(priceOfOneToken);
        _sellSideTotal = depositPercentage.mul(_buySideTotal) / 100;
        _sellSideTotal = _sellSideTotal.add(computeFee(_buySideTotal));
        _buySideTotal = _buySideTotal.add(computeFee(_buySideTotal));
        
        address payable buyer; address payable seller; (buyer, seller) = wantToBuy ? (msg.sender, other) : (other, msg.sender);
        
        uint256 tradeId = uint256(keccak256(abi.encodePacked(buyer, seller, symbol, amountOfTokens, priceOfOneToken, depositPercentage, expiration)));
        return (tradeId, _buySideTotal, _sellSideTotal, trades[tradeId].state);
    }
    
    function _setTokenAddress(string memory symbol, address token) public onlyOwner {
        tokens[convert(symbol)] = IERC20(token);
    }
    
    function getTokenAddress(string memory symbol) public view returns (IERC20) {
        return tokens[convert(symbol)];
    }
}
