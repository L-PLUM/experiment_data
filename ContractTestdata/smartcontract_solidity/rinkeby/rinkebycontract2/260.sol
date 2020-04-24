/**
 *Submitted for verification at Etherscan.io on 2019-08-02
*/

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.4.24;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }
}

// File: contracts/FixedSupplyToken.sol

pragma solidity ^0.4.21;



// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    } 
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and an
// initial fixed supply
// ----------------------------------------------------------------------------
contract FixedSupplyToken is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint public _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        symbol = "FAB";
        name = "Fabos Token";
        decimals = 0;
        _totalSupply = 1000000 * 10**uint(decimals);
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }


    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public constant returns (uint) {
        return _totalSupply  - balances[address(0)];
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces 
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.4.24;


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

// File: contracts/Exchange.sol

pragma solidity ^0.4.21;




contract Exchange is Ownable {

    using SafeMath for uint256;

    struct Offer {
        address trader;
        uint amount;
    }

    struct OrderBook {

        uint higherPrice;
        uint lowerPrice;

        mapping(uint => Offer) offers;

        //to represent a queue
        //offers_start == 1 ? an offer exists in the queue
        uint offers_start;
        uint offers_end;
    }

    struct Token {
        string symbolName;

        address tokenContract;

        // price is the key for order book linkedlist
        mapping(uint => OrderBook) buyOrderBook;
        //HEAD of the linked list for the buy order book
        uint highestBuyPrice;
        //TAIL of the linked list for the buy order book
        uint lowestBuyPrice;
        // buy amount across all the book
        uint amountBuy;

        // price is the key for order book linkedlist
        mapping(uint => OrderBook) sellOrderBook;
        //HEAD of the linked list for the sell order book
        uint lowestSellPrice;
        //TAIL of the linked list for the sell order book
        uint highestSellPrice;
        // sell amount across all the book
        uint amountSell;
    }

    // support a maximum of 255 contracts as we start from 1
    mapping(uint8 => Token) tokens;
    uint8 tokenIndex;

    mapping(address => mapping(uint8 => uint)) tokenBalancesForAddress;

    mapping(address => uint) etherBalanceForAddress;

    //////////////
    /// EVENTS ///
    //////////////

    event TokenAdded(address indexed _initiator, uint _timestamp, uint8 indexed _tokenIndex, string _symbolName);

    event TokenDeposited(address indexed _initiator, uint _timestamp, uint8 indexed _tokenIndex, string _symbolName, uint _amount);

    event TokenWithdrawn(address indexed _initiator, uint _timestamp, uint8 indexed _tokenIndex, string _symbolName, uint _amount);

    event EtherDeposited(address indexed _initiator, uint _timestamp, uint _amountInWei);

    event EtherWithdrawn(address indexed _initiator, uint _timestamp, uint _amountInWei);

    ////////////////////
    /// ORDER EVENTS ///
    ////////////////////

    event BuyLimitOrderCreated(address indexed _initiator, uint _timestamp, string _symbolName, uint _amount, uint _priceInWei, uint _orderIdx);

    event SellLimitOrderCreated(address indexed _initiator, uint _timestamp, string _symbolName, uint _amount, uint _priceInWei, uint _orderIdx);

    event BuyLimitOrderCanceled(address indexed _initiator, uint _timestamp, string _symbolName, uint _amount, uint _priceInWei, uint _orderIdx);

    event SellLimitOrderCanceled(address indexed _initiator, uint _timestamp, string _symbolName, uint _amount, uint _priceInWei, uint _orderIdx);

    event BuyLimitOrderFulfilled(address indexed _initiator, uint _timestamp, string _symbolName, uint _amount, uint _priceInWei, uint _orderIdx);

    event SellLimitOrderFulfilled(address indexed _initiator, uint _timestamp, string _symbolName, uint _amount, uint _priceInWei, uint _orderIdx);

    ////////////////////////////////
    /// ETHER DEPOSIT & WITHDRAW ///
    ////////////////////////////////

    function depositEther() public payable {
        etherBalanceForAddress[msg.sender] = etherBalanceForAddress[msg.sender].add(msg.value);
        emit EtherDeposited(msg.sender, now, msg.value);
    }

    function withdrawEther(uint amountInWei) public {
        require(
            amountInWei <= etherBalanceForAddress[msg.sender],
            "amountInWei less than sender ether balance "
        );
        etherBalanceForAddress[msg.sender] = etherBalanceForAddress[msg.sender].sub(amountInWei);
        msg.sender.transfer(amountInWei);

        emit EtherWithdrawn(msg.sender, now, amountInWei);
    }


    function getBalanceInWei() public constant returns (uint) {
        return etherBalanceForAddress[msg.sender];
    }

    ////////////////////////
    /// TOKEN MANAGEMENT ///
    ////////////////////////

    // Only admin function
    function addToken(string symbolName, address tokenContract) public onlyOwner {
        require(!hasToken(symbolName));
        require(tokenIndex < 255);

        tokenIndex ++;
        tokens[tokenIndex].symbolName = symbolName;
        tokens[tokenIndex].tokenContract = tokenContract;

        emit TokenAdded(msg.sender, now, tokenIndex, symbolName);
    }

    function hasToken(string symbolName) public view returns (bool) {
        uint8 index = getSymbolIndex(symbolName);
        return (index > 0);
    }

    function getSymbolIndex(string symbolName) internal view returns (uint8) {
        for (uint8 i = 1; i <= tokenIndex; i++) {
            Token storage token = tokens[i];
            if (stringsEqual(symbolName, token.symbolName)) {
                return i;
            }
        }
        return 0;
    }

    function stringsEqual(string memory strA, string storage strB) internal view returns (bool) {
        bytes memory strA_bytes = bytes(strA);
        bytes storage strB_bytes = bytes(strB);

        if (strB_bytes.length != strB_bytes.length) {
            return false;
        }
        for (uint8 i = 0; i < strA_bytes.length; i++) {
            if (strA_bytes[i] != strB_bytes[i]) {
                return false;
            }
        }
        return true;
    }


    ////////////////////////////////
    /// TOKEN DEPOSIT & WITHDRAW ///
    ////////////////////////////////


    function depositToken(string symbolName, uint amount) public {
        require(hasToken(symbolName), "token is not referenced in the exchange");

        uint8 idx = getSymbolIndex(symbolName);
        ERC20Interface token = ERC20Interface(tokens[idx].tokenContract);
        require(token.transferFrom(msg.sender, address(this), amount));

        tokenBalancesForAddress[msg.sender][idx] = tokenBalancesForAddress[msg.sender][idx].add(amount);

        emit TokenDeposited(msg.sender, now, idx, symbolName, amount);
    }

    function withdrawToken(string symbolName, uint amount) public {
        require(hasToken(symbolName), "token is not referenced in the exchange");

        uint8 idx = getSymbolIndex(symbolName);

        uint tokenBalance = tokenBalancesForAddress[msg.sender][idx];
        require(tokenBalance >= amount, "token amount less than sender token balance");

        tokenBalancesForAddress[msg.sender][idx] = tokenBalancesForAddress[msg.sender][idx].sub(amount);

        emit TokenWithdrawn(msg.sender, now, idx, symbolName, amount);

        ERC20Interface token = ERC20Interface(tokens[idx].tokenContract);
        require(token.transfer(msg.sender, amount));
    }

    function getBalanceToken(string symbolName) public view returns (uint) {
        require(hasToken(symbolName), "token is not referenced in the exchange");

        uint8 idx = getSymbolIndex(symbolName);
        return tokenBalancesForAddress[msg.sender][idx];
    }

    /////////////////////////////
    /// ORDER BOOK MANAGEMENT ///
    /////////////////////////////

    ///////// BUY ORDER /////////

    function getBuyOrderBookPricesAndAmount(string symbolName) public view returns (uint, uint, uint) {
        require(hasToken(symbolName), "token is not referenced in the exchange");

        uint8 idx = getSymbolIndex(symbolName);
        Token storage token = tokens[idx];
        return (token.highestBuyPrice, token.lowestBuyPrice, token.amountBuy);
    }

    function getBuyOrderBookOffersStartAndEnd(string symbolName, uint priceInWei) public view returns (uint, uint) {
        require(hasToken(symbolName), "token is not referenced in the exchange");

        uint8 idx = getSymbolIndex(symbolName);
        Token storage token = tokens[idx];
        return (token.buyOrderBook[priceInWei].offers_start, token.buyOrderBook[priceInWei].offers_end);
    }

    function getBuyOrderBookOffersOrderTraderAndAmount(string symbolName, uint priceInWei, uint offerIndex) public view returns (address, uint) {
        require(hasToken(symbolName), "token is not referenced in the exchange");

        uint8 idx = getSymbolIndex(symbolName);
        Token storage token = tokens[idx];
        OrderBook storage orderBook = token.buyOrderBook[priceInWei];
        Offer storage offer = orderBook.offers[offerIndex];
        return (offer.trader, offer.amount);
    }

    function matchSellOrder(Token storage token, string symbolName, uint8 idx, uint amount, uint priceInWei) internal returns (uint) {
        uint currentSellPrice = token.lowestSellPrice;
        uint remainingAmount = amount;

        while (currentSellPrice != 0 && currentSellPrice <= priceInWei && remainingAmount > 0) {
            OrderBook storage sellOrderBook = token.sellOrderBook[currentSellPrice];
            uint offer_idx = sellOrderBook.offers_start;
            while (offer_idx <= sellOrderBook.offers_end && remainingAmount > 0) {
                Offer storage offer = sellOrderBook.offers[offer_idx];

                // skip the canceled order
                if (offer.amount == 0) {
                    sellOrderBook.offers_start ++;
                    offer_idx ++;
                    continue;
                }
                // 1. take no more than remainingAmount
                uint minAmount = offer.amount;
                if (offer.amount > remainingAmount) {
                    minAmount = remainingAmount;
                }
                remainingAmount -= minAmount;
                token.amountSell -= minAmount;
                // tokens increases for the buyer
                tokenBalancesForAddress[msg.sender][idx] += minAmount;
                // ether changes hands
                etherBalanceForAddress[msg.sender] -= minAmount.mul(currentSellPrice);
                etherBalanceForAddress[offer.trader] += minAmount.mul(currentSellPrice);
                // 2. partial or complete order fulfilled ?
                if (minAmount == offer.amount) {
                    sellOrderBook.offers_start ++;
                    emit SellLimitOrderFulfilled(offer.trader, now, symbolName, offer.amount, currentSellPrice, offer_idx);
                }
                offer.amount -= minAmount;
                // 3. move to the next offer
                offer_idx ++;
            }
            currentSellPrice = sellOrderBook.higherPrice;
            token.lowestSellPrice = currentSellPrice;
        }
        return remainingAmount;
    }

    function buyToken(string symbolName, uint amount, uint priceInWei) public returns (uint) {
        require(hasToken(symbolName), "token is not referenced in the exchange");

        require(etherBalanceForAddress[msg.sender] >= amount.mul(priceInWei),
            "ether balance for msg.sender is not enough to cover amount * priceInWei");

        uint8 idx = getSymbolIndex(symbolName);
        Token storage token = tokens[idx];

        // 1. check that no matching sell orders. priceInWei <= priceInWei in sell orders
        uint remainingAmount = matchSellOrder(token, symbolName, idx, amount, priceInWei);

        if (remainingAmount == 0) {
            emit BuyLimitOrderFulfilled(msg.sender, now, symbolName, amount, priceInWei, 0);
            return 0;
        }

        // 2. place remaining unfulfilled order quantity at price in the buy order list. ordered by descending order
        uint currentPrice = token.highestBuyPrice;
        while (priceInWei < currentPrice && priceInWei >= token.lowestBuyPrice) {
            currentPrice = token.buyOrderBook[currentPrice].lowerPrice;
        }

        //3. Found the index in the buyOrderBook. Now need to insert it.
        //3.a case if first buy order in the buy order book
        if (token.amountBuy == 0) {
            token.lowestBuyPrice = priceInWei;
            token.highestBuyPrice = priceInWei;
            token.buyOrderBook[priceInWei].offers_start = 1;
            // to mention a new offer at this price
        }
        //3.b case if priceInWei is the highest price (new head of the list) or first order
        else if (priceInWei > token.highestBuyPrice) {
            token.buyOrderBook[priceInWei].lowerPrice = token.highestBuyPrice;
            token.buyOrderBook[token.highestBuyPrice].higherPrice = priceInWei;
            token.highestBuyPrice = priceInWei;
            token.buyOrderBook[priceInWei].offers_start = 1;
            // to mention a new offer at this price
        }
        //3.c case if priceInWei is the lowest price (new tail of the list)
        else if (priceInWei < token.lowestBuyPrice) {
            token.buyOrderBook[priceInWei].higherPrice = token.lowestBuyPrice;
            token.buyOrderBook[token.lowestBuyPrice].lowerPrice = priceInWei;
            token.lowestBuyPrice = priceInWei;
            token.buyOrderBook[priceInWei].offers_start = 1;
        }
        //3.d case if priceInWei does not exist in the list
        else if (priceInWei != currentPrice) {
            uint previousHigherPrice = token.buyOrderBook[currentPrice].higherPrice;
            token.buyOrderBook[currentPrice].higherPrice = priceInWei;
            token.buyOrderBook[priceInWei].lowerPrice = currentPrice;
            token.buyOrderBook[previousHigherPrice].lowerPrice = priceInWei;
            token.buyOrderBook[priceInWei].higherPrice = previousHigherPrice;
            token.buyOrderBook[priceInWei].offers_start = 1;
        }

        //4. push the offer in the offer queue
        OrderBook storage orderBook = token.buyOrderBook[priceInWei];
        orderBook.offers_end ++;
        orderBook.offers[orderBook.offers_end] = Offer(msg.sender, remainingAmount);

        //5. add to the buy order book total quantity
        token.amountBuy = token.amountBuy.add(remainingAmount);

        etherBalanceForAddress[msg.sender] = etherBalanceForAddress[msg.sender].sub(remainingAmount.mul(priceInWei));

        emit BuyLimitOrderCreated(msg.sender, now, symbolName, remainingAmount, priceInWei, orderBook.offers_end);

        // 6. return order position
        return orderBook.offers_end;
    }

    ///////// SELL ORDER /////////

    function getSellOrderBookPricesAndAmount(string symbolName) public view returns (uint, uint, uint) {
        require(hasToken(symbolName), "token is not referenced in the exchange");

        uint8 idx = getSymbolIndex(symbolName);
        Token storage token = tokens[idx];
        return (token.lowestSellPrice, token.highestSellPrice, token.amountSell);
    }

    function getSellOrderBookOffersStartAndEnd(string symbolName, uint priceInWei) public view returns (uint, uint) {
        require(hasToken(symbolName), "token is not referenced in the exchange");

        uint8 idx = getSymbolIndex(symbolName);
        Token storage token = tokens[idx];
        return (token.sellOrderBook[priceInWei].offers_start, token.sellOrderBook[priceInWei].offers_end);
    }

    function getSellOrderBookOffersOrderTraderAndAmount(string symbolName, uint priceInWei, uint offerIndex) public view returns (address, uint) {
        require(hasToken(symbolName), "token is not referenced in the exchange");

        uint8 idx = getSymbolIndex(symbolName);
        Token storage token = tokens[idx];
        OrderBook storage orderBook = token.sellOrderBook[priceInWei];
        Offer storage offer = orderBook.offers[offerIndex];
        return (offer.trader, offer.amount);
    }

    function matchBuyOrder(Token storage token, string symbolName, uint8 idx, uint amount, uint priceInWei) internal returns (uint) {
        uint currentBuyPrice = token.highestBuyPrice;
        uint remainingAmount = amount;

        while (currentBuyPrice > 0 && currentBuyPrice >= priceInWei && remainingAmount > 0) {
            OrderBook storage buyOrderBook = token.buyOrderBook[currentBuyPrice];
            uint offer_idx = buyOrderBook.offers_start;
            while (offer_idx <= buyOrderBook.offers_end && remainingAmount > 0) {
                Offer storage offer = buyOrderBook.offers[offer_idx];

                // skip the canceled order
                if (offer.amount == 0) {
                    buyOrderBook.offers_start ++;
                    offer_idx ++;
                    continue;
                }
                // 1. take no more than remainingAmount
                uint minAmount = offer.amount;
                if (offer.amount > remainingAmount) {
                    minAmount = remainingAmount;
                }
                remainingAmount -= minAmount;
                token.amountBuy -= minAmount;
                // tokens change hands
                tokenBalancesForAddress[msg.sender][idx] -= minAmount;
                tokenBalancesForAddress[offer.trader][idx] += minAmount;
                // ether increase for the seller
                etherBalanceForAddress[msg.sender] += minAmount.mul(currentBuyPrice);

                // 2. partial or complete order fulfilled ?
                if (minAmount == offer.amount) {
                    buyOrderBook.offers_start ++;
                    emit BuyLimitOrderFulfilled(offer.trader, now, symbolName, offer.amount, currentBuyPrice, offer_idx);
                }
                offer.amount -= minAmount;
                // 3. move to the next offer
                offer_idx ++;
            }
            currentBuyPrice = buyOrderBook.lowerPrice;
            if (buyOrderBook.lowerPrice != 0) {
                token.highestBuyPrice = buyOrderBook.lowerPrice;
            }
        }
        return remainingAmount;
    }

    function sellToken(string symbolName, uint amount, uint priceInWei) public returns (uint) {
        require(hasToken(symbolName), "token is not referenced in the exchange");

        uint256 tokenBalance = getBalanceToken(symbolName);
        require(amount <= tokenBalance, 'token balance for msg.sender is not enough to cover the sell order');
        uint8 idx = getSymbolIndex(symbolName);
        Token storage token = tokens[idx];

        // 1. check that no matching buy orders. priceInWei >= priceInWei in buy orders
        uint remainingAmount = matchBuyOrder(token, symbolName, idx, amount, priceInWei);

        if (remainingAmount == 0) {
            emit SellLimitOrderFulfilled(msg.sender, now, symbolName, amount, priceInWei, 0);
            return 0;
        }

        // 2. place remaining unfulfilled order quantity in the sell order book sorted by ascending order
        uint currentPrice = token.lowestSellPrice;
        while (priceInWei > currentPrice && priceInWei <= token.highestSellPrice) {
            currentPrice = token.sellOrderBook[currentPrice].higherPrice;
        }

        //3. Found the index in the sellOrderBook. Now need to insert it.
        //3.a case if first sell order in the sell order book
        if (token.amountSell == 0) {
            token.lowestSellPrice = priceInWei;
            token.highestSellPrice = priceInWei;
            token.sellOrderBook[priceInWei].offers_start = 1;
            // to mention a new offer at this price
        }
        //3.b case if priceInWei is the lowest price (new head of the list)
        else if (priceInWei < token.lowestSellPrice) {
            token.sellOrderBook[priceInWei].higherPrice = token.lowestSellPrice;
            token.sellOrderBook[token.lowestSellPrice].lowerPrice = priceInWei;
            token.lowestSellPrice = priceInWei;
            token.sellOrderBook[priceInWei].offers_start = 1;
            // to mention a new offer at this price
        }
        //3.c case if priceInWei is the highest price (new tail of the list)
        else if (priceInWei > token.highestSellPrice) {
            token.sellOrderBook[priceInWei].lowerPrice = token.highestSellPrice;
            token.sellOrderBook[token.highestSellPrice].higherPrice = priceInWei;
            token.highestSellPrice = priceInWei;
            token.sellOrderBook[priceInWei].offers_start = 1;
            // to mention a new offer at this price
        }
        //3.d case if priceInWei does not exist in the list
        else if (priceInWei != currentPrice) {
            uint previousLowerPrice = token.sellOrderBook[currentPrice].lowerPrice;
            token.sellOrderBook[currentPrice].lowerPrice = priceInWei;
            token.sellOrderBook[priceInWei].higherPrice = currentPrice;
            token.sellOrderBook[previousLowerPrice].higherPrice = priceInWei;
            token.sellOrderBook[priceInWei].lowerPrice = previousLowerPrice;
            token.sellOrderBook[priceInWei].offers_start = 1;
            // to mention a new offer at this price
        }

        // 4 push the offer in the offer queue
        OrderBook storage orderBook = token.sellOrderBook[priceInWei];
        orderBook.offers_end ++;
        orderBook.offers[orderBook.offers_end] = Offer(msg.sender, remainingAmount);

        //5. add to the sell order book total quantity
        token.amountSell = token.amountSell.add(remainingAmount);

        tokenBalancesForAddress[msg.sender][idx] = tokenBalancesForAddress[msg.sender][idx].sub(remainingAmount);
        emit SellLimitOrderCreated(msg.sender, now, symbolName, remainingAmount, priceInWei, orderBook.offers_end);

        // 6. return order position
        return orderBook.offers_end;
    }


    //////// CANCEL ORDER ////////

    // can a cancel be run at the same time than an execution because many transactions can happen in the same block ?
    // can a cancel front run an execution and put the exchange into an inconsistent state ?
    function cancelBuyLimitOrder(string symbolName, uint priceInWei, uint orderPosition) {
        require(hasToken(symbolName), "token is not referenced in the exchange");
        uint256 tokenBalance = getBalanceToken(symbolName);
        uint8 idx = getSymbolIndex(symbolName);
        Token storage token = tokens[idx];
        Offer storage offer = token.buyOrderBook[priceInWei].offers[orderPosition];
        require(offer.trader == msg.sender, "the offer trader is not the sender");
        require(offer.amount != 0, "the order has already been canceled");
        etherBalanceForAddress[msg.sender] = etherBalanceForAddress[msg.sender].add(offer.amount.sub(priceInWei));
        token.amountBuy = token.amountBuy.sub(offer.amount);
        emit BuyLimitOrderCanceled(msg.sender, now, symbolName, offer.amount, priceInWei, orderPosition);
        offer.amount = 0;
    }

    // can a cancel be run at the same time than an execution because many transactions can happen in the same block ?
    // can a cancel front run an execution and put the exchange into an inconsistent state ?
    function cancelSellLimitOrder(string symbolName, uint priceInWei, uint orderPosition) {
        require(hasToken(symbolName), "token is not referenced in the exchange");
        uint256 tokenBalance = getBalanceToken(symbolName);
        uint8 idx = getSymbolIndex(symbolName);
        Token storage token = tokens[idx];
        Offer storage offer = token.sellOrderBook[priceInWei].offers[orderPosition];
        require(offer.trader == msg.sender, "the offer trader is not the sender");
        require(offer.amount != 0, "the order has already been canceled");
        tokenBalancesForAddress[msg.sender][idx] = tokenBalancesForAddress[msg.sender][idx].sub(offer.amount);
        token.amountSell = token.amountSell.sub(offer.amount);
        emit BuyLimitOrderCanceled(msg.sender, now, symbolName, offer.amount, priceInWei, orderPosition);
        offer.amount = 0;
    }
}
