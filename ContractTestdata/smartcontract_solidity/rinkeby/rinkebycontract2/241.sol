pragma solidity ^0.5.8;

import "./ERC20Token.sol";

contract makeDCO is ERC20Token {
  string public constant name = "makeDCO";
  string public constant symbol = "mDCO";
  uint8 public constant decimals = 0;
  uint public _totalSupply;
  address public burnAddress;

  mapping (address => uint) public balances;
  mapping (address => mapping(address => uint)) allowed;

  uint public creationTimestamp;

  constructor(uint _cycleLengthSeconds, uint _cyclesForSale, uint _maxSupply) public {
    if (_cycleLengthSeconds != 0) {
      cycleLengthSeconds = _cycleLengthSeconds;
    }
    if (_cyclesForSale != 0) {
      cyclesForSale = _cyclesForSale;
    }
    if (_maxSupply != 0) {
      maxSupply = _maxSupply;
    }
    _totalSupply = 0;
    burnAddress = address(0x0);
    creationTimestamp = block.timestamp;
    // The genesis auction
    auctions.push(Auction({
      creator: msg.sender,
      startCycle: currentCycle(),
      endCycle: uint(-1),
      totalTokensSold: 0,
      name: 'makeDCO',
      url: 'https://gitlab.com/makedco/contracts/blob/master/README.md#makedco',
      totalWeiIngested: 0
    }));
  }

  function totalSupply() public view returns (uint) {
    return _totalSupply - balances[burnAddress];
  }

  function burn(uint tokens) public returns (bool success) {
    if (balances[msg.sender] < tokens) return false;
    return transfer(burnAddress, tokens);
  }

  function balanceOf(address tokenOwner) public view returns (uint balance) {
    return balances[tokenOwner];
  }

  function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
    return allowed[tokenOwner][spender];
  }

  function transfer(address to, uint tokens) public returns (bool success) {
    if (balances[msg.sender] < tokens) return false;
    balances[msg.sender] -= tokens;
    balances[to] += tokens;
    emit Transfer(msg.sender, to, tokens);
    return true;
  }

  function transferFrom(address from, address to, uint tokens) public returns (bool success) {
    if (balances[from] < tokens) return false;
    if (allowed[from][msg.sender] < tokens) return false;
    balances[from] -= tokens;
    allowed[from][msg.sender] -= tokens;
    balances[to] += tokens;
    emit Transfer(from, to, tokens);
    return true;
  }

  function approve(address spender, uint tokens) public returns (bool success) {
    allowed[msg.sender][spender] += tokens;
    emit Approval(msg.sender, spender, tokens);
    return true;
  }

  /**
   * mDCO
   **/
  struct Auction {
    uint startCycle;
    uint endCycle;
    mapping (uint => uint) tokensSoldByCycle;
    uint totalTokensSold;
    uint totalWeiIngested;
    address payable creator;
    string name;
    string url;
  }

  Auction[] public auctions;

  /// 6 hour cycles
  uint public cycleLengthSeconds = 21600;

  /// Distribute 1000 tokens per cycle
  uint public constant tokensOfferedPerCycle = 1000;

  /// Individual auctions last for 120 cycles ~30 days
  uint public cyclesForSale = 120;

  /// Total wei ingested for token; for calculation of real price
  uint public totalWeiIngested = 0;

  uint public maxSupply = 3510426920;

  mapping (address => uint) public auctionByAddress;

  event Purchase(address buyer, uint auctionIndex, uint tokenCount);
  event AuctionCreated(uint auctionIndex);

  /// Adds an item to the auctions array and purchases msg.value worth of token
  /// from the genesis auction
  function createAuction(string memory _name, string memory _url) public payable {
    /// require at least 1 ether to create an auction
    require(msg.value == 10**17);
    require(msg.sender != auctions[0].creator);
    uint cycle = currentCycle();
    uint auctionIndex = auctionByAddress[msg.sender];
    if (auctionIndex != 0) {
      require(auctions[auctionIndex].endCycle <= cycle);
    }
    auctionByAddress[msg.sender] = auctions.length;
    // Round up to the start of the next cycle so ui's can be logically synchronized
    uint startCycle = cycle + 1;
    uint finalCycle = startCycle + cyclesForSale;
    auctions.push(Auction({
      creator: msg.sender,
      startCycle: startCycle,
      endCycle: finalCycle,
      totalTokensSold: 0,
      name: _name,
      url: _url,
      totalWeiIngested: 0
    }));
    emit AuctionCreated(auctions.length - 1);

    // Buy from the genesis auction
    uint weiPrice = currentWeiPrice();
    uint tokenCount = msg.value / weiPrice;
    _buyTokens(0, tokenCount);
    msg.sender.transfer(msg.value - tokenCount * weiPrice);
  }

  /// Set the name for an auction
  function setName(uint auctionIndex, string memory _name) public {
    require(auctionIndex < auctions.length);
    require(msg.sender == auctions[auctionIndex].creator);
    auctions[auctionIndex].name = _name;
  }

  /// Set the url for an auction
  function setUrl(uint auctionIndex, string memory _url) public {
    require(auctionIndex < auctions.length);
    require(msg.sender == auctions[auctionIndex].creator);
    auctions[auctionIndex].url = _url;
  }

  /// Returns the current cycle number
  function currentCycle() public view returns (uint) {
    return (block.timestamp - creationTimestamp) / cycleLengthSeconds;
  }

  /// Buy tokenCount at currentWeiPrice()
  /// Remaining wei is refunded
  function _buyTokens(uint auctionIndex, uint tokenCount) private {
    requireAuctionActive(auctionIndex);
    Auction storage auction = auctions[auctionIndex];
    uint weiPrice = currentWeiPrice();
    if (auction.creator == msg.sender) {
      // Only allow purchase from own auction below the real price
      // Hopefully to prevent artificial inflation of price
      require(weiPrice < realWeiPrice());
    }
    uint cycle = currentCycle();
    uint remainingTokens = tokensAvailableForAuction(auctionIndex);
    require(remainingTokens >= tokenCount);

    uint ingestedWei = tokenCount * weiPrice;
    require(msg.value >= ingestedWei);
    totalWeiIngested += ingestedWei;
    balances[msg.sender] += tokenCount;
    emit Transfer(burnAddress, msg.sender, tokenCount);
    auction.tokensSoldByCycle[cycle] += tokenCount;
    auction.totalTokensSold += tokenCount;
    auction.totalWeiIngested += ingestedWei;
    _totalSupply += tokenCount;
    require(_totalSupply <= maxSupply);
    emit Purchase(msg.sender, auctionIndex, tokenCount);
    auction.creator.transfer(ingestedWei);
  }

  /// A wrapper to prevent purchase from the genesis auction
  function buyTokens(uint auctionIndex, uint tokenCount) public payable {
    require(auctionIndex > 0);
    _buyTokens(auctionIndex, tokenCount);
    msg.sender.transfer(msg.value - tokenCount * currentWeiPrice());
  }

  /// Batch buy as many tokens as possible with the given msg.value
  function batchBuyTokens() public payable {
    require(auctionCount() > 1);
    uint weiPrice = currentWeiPrice();
    uint realPrice = realWeiPrice();
    uint tokenCount = msg.value / weiPrice;
    require(tokenCount > 0);
    uint deliveredTokens = 0;
    for (uint x = auctionCount() - 1; x > 0; x--) {
      uint remainingTokens = tokenCount - deliveredTokens;
      if (remainingTokens == 0) break;
      uint availableTokens = tokensAvailableForAuction(x);
      if (availableTokens == 0) continue;
      if (auctionByAddress[msg.sender] == x && weiPrice >= realPrice) {
        /// If the auction is owned by the message sender only buy from own
        /// auction if the price is below the real price, otherwise it will throw
        continue;
      }
      uint tokens = min(remainingTokens, availableTokens);
      _buyTokens(x, tokens);
      deliveredTokens += tokens;
    }
    msg.sender.transfer(msg.value - deliveredTokens * weiPrice);
  }

  /// Current sell price, uses an algebraic sigmoid for price decay over time
  /// It would be nice to allow an offset for customizing the price range in a later version
  function currentWeiPrice(/*uint offset*/) public view returns (uint) {
    uint cycleSecondsRemaining = cycleLengthSeconds - (block.timestamp - (creationTimestamp + currentCycle() * cycleLengthSeconds));
    assert(cycleSecondsRemaining <= cycleLengthSeconds);
    assert(cycleSecondsRemaining >= 0);
    // 1 ether upper bound
    uint yMax = 10**18 / tokensOfferedPerCycle;
    // 0.1 ether lower bound
    uint yMin = 10**17 / tokensOfferedPerCycle;

    uint xMax = cycleLengthSeconds;
    uint yRange = yMax - yMin;
    /// Controls sigmoid steepness
    uint k = 4000000;
    uint x = cycleSecondsRemaining;

    uint b = 4 * sqrt(k + x * x + (xMax * xMax) / 4 - x * xMax);
    uint s = yRange / 2 + (2 * x * yRange) / b - (xMax * yRange) / b;

    uint weiPrice = yMin + s;
    return weiPrice;
  }

  function realWeiPrice() public view returns (uint) {
    if (totalSupply() == 0) return 0;
    return totalWeiIngested / totalSupply();
  }

  /// Returns the number of tokens currently available for a given auctionIndex
  /// Does not throw if auction is inactive
  function tokensAvailableForAuction(uint auctionIndex) public view returns (uint) {
    require(auctionIndex < auctions.length);
    Auction storage auction = auctions[auctionIndex];
    uint cycle = currentCycle();
    if (cycle < auction.startCycle) return 0;
    if (cycle > auction.endCycle) return 0;
    return min(tokensOfferedPerCycle - auction.tokensSoldByCycle[cycle], maxSupply - _totalSupply);
  }

  /// Require the given auctionIndex to exist and the current time to be ahead of it's start time
  /// Throws if provided auctionIndex is not valid and active
  function requireAuctionActive(uint auctionIndex) public view {
    require(auctionIndex < auctions.length);
    uint cycle = currentCycle();
    Auction memory auction = auctions[auctionIndex];
    require(cycle >= auction.startCycle);
    require(cycle <= auction.endCycle);
  }

  /// Getter for clients
  function auctionCount() public view returns (uint) {
    return auctions.length;
  }

  /// Return the smaller of two numbers
  function min(uint a, uint b) private pure returns (uint) {
    return a < b ? a : b;
  }

  /// Babylonian square root implementation
  function sqrt(uint x) private pure returns (uint y) {
    uint z = (x + 1) / 2;
    y = x;
    while (z < y) {
      y = z;
      z = (x / z + z) / 2;
    }
  }

  /// Used to manipulate ERC20's owned by this contract
  function withdrawToken(address tokenContract, uint8 tokenDecimals, uint tokens, address receiver) public {
    require(msg.sender == auctions[0].creator);
    bool success = ERC20Token(tokenContract).transfer(receiver, tokens * 10**uint(tokenDecimals));
    require(success);
  }
}
