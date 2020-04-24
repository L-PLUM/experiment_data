/**
 *Submitted for verification at Etherscan.io on 2019-08-06
*/

// version: 1-56pm Aug 6

pragma solidity ^0.4.25;

contract FancyCenterItem {

  event ItemBecomeAvailable(
    string itemId,
    uint256 ticketsTotal,
    uint256 itemPrice,
    uint256 ticketPrice,
    uint256 finalTimestamp
  );

  event TicketSold(
    string itemId,
    uint256 ticketsSoldNow,
    uint256 ticketsSoldTotal,
    uint256 ticketsLeft,
    address user_address,
    uint256 timestamp,
    uint256 ticketPrice,
    bool hasReferrer,
    address referrer,
    uint256 referrerEarning
  );

  event ItemBecomeReadyForWinner(
    string itemId,
    uint256 timestamp,
    uint256 finalBlockNumber
  );

  event PayoutSentToWinners(
    string itemId,
    bool hasReferrer,
    address winnerAddress,
    address winnerReferrerAddress,
    uint256 winnerPayout,
    uint256 winnerReferrerPayout
  );

  address dividendsContractAddress = 0x103bA92b1ceF441d016CCBc36e66338B1a108f9b;
  string itemCaption;
  string itemUrl;
  string itemId;
  uint256 ticketsTotal;
  uint256 ticketsAvailable;
  uint256 ticketsSold;
  uint256 ticketPrice;
  uint256 itemPrice;
  uint256 finalTimestamp;
  uint256 payoutToWinner;
  address winnerAddress;
  uint256 payoutToReferrerWinner;
  address winnerReferrerAddress;
  bytes32 itemNonceHash; // keccak256 of randomNonce for good random algorithm. Check details at https://fancy.center/how-it-works
  uint256 finalBlockNumber;
  address[] participants;
  address[] referrers;
  address owner;
  uint8 hasWinnerReferrer; // 0 -> not defined, 1 - yes, 2 - no
  uint8 itemStatus = 0; // 0 -> Did not start, 1 -> Started, 2 -> All tickets sold (or timed out) and finalBlock defined, 10 -->  Payout already made
  bool finishLotteryRequiresPasscode = true;

  // FinaceInfo according to https://fancy.center/investor
  uint256 pieUserPrize = 700;             // 70%    - big payout once, after draw
  uint256 pieInstantReferralPayout = 90;  // 9%     - instant payout (% from ticket price)
  uint256 pieBonusDrawing = 21;           // 2.1%   - big payout once, after draw
  uint256 pieCashback = 9;                // 0.9%   - instant payout (% from ticket price)
  uint256 pieDividends = 180;             // 18%    - dividends (payout to shareholders)
  uint256 pieToPercentageDiv = 1000;      // Example: 700 / 1000 = 0.7 = 70%
  bool hasCashback = false;
  
  constructor() public {
    owner = msg.sender;
  }  

  function startLottery(
    string _itemCaption, string _itemId, uint256 _ticketsTotal,
    uint256 _ticketPrice, uint256 _duration, bytes32 _itemNonceHash,
    bool _hasUserCashback
  ) public {
    require(msg.sender == owner, "Allowed only for owner");
    require(itemStatus == 0, "Already active");

    itemCaption = _itemCaption;
    itemUrl = string(abi.encodePacked("https://fancy.center/item/", _itemId));
    itemId = _itemId;
    ticketsTotal = _ticketsTotal;
    ticketsAvailable = _ticketsTotal;
    ticketPrice = _ticketPrice;
    finalTimestamp = block.timestamp + _duration * 24 * 60 * 60 / 100; // example 3000 -> 30days 
    ticketsSold = 0;
    itemNonceHash = _itemNonceHash;
    itemPrice = ticketsTotal * ticketPrice;
    hasCashback = _hasUserCashback;
    itemStatus = 1;

    emit ItemBecomeAvailable(
      itemId,
      ticketsTotal,
      itemPrice,
      ticketPrice,
      finalTimestamp
    );
  } 

  function finishLottery(uint256 _itemNonce) public returns(uint8) {
    /*
      fancyCenter backend will call finishLottery once availble.
      We want our users feel safe, that's why introduced following rule:
        if facyCenter(we) didn't call finishLottery within last 256 blocks after all tickers were sold out,
        we allow ANYONE to call finishLottery without a passcode. In this case as _itemNonce we'll use 0.
    */

    require(( (itemStatus == 1 && block.timestamp > finalTimestamp) || (itemStatus == 2 && block.number > finalBlockNumber) ), "Item not ready or payout already made.");

    if (itemStatus == 1) {
      // Let's schedule the draw
      itemStatus = 2;
      finalBlockNumber = block.number + 2;
      return itemStatus;
    } else if (itemStatus == 2) {
      // Check block number
      uint256 blockDiff = block.number - finalBlockNumber; 

      if (blockDiff > 252) { // Schedule and allow anyone to call finishLottery
        finishLotteryRequiresPasscode = false;
        finalBlockNumber = block.number + 2;
        return itemStatus;
      }

      uint256 itemNonce = _itemNonce;

      if (finishLotteryRequiresPasscode) {
        bytes32 itemNonceHashGenerated = keccak256(abi.encode(itemNonce));
        require(itemNonceHash == itemNonceHashGenerated, "Wrong Item Nonce");
      } else {
        itemNonce = 0;
      }

      // Good, let's choose random winner
      uint256 winnerRandId = (itemNonce + uint256(blockhash(finalBlockNumber))) % ticketsSold;
      payoutToWinner = (ticketsSold * ticketPrice) / pieToPercentageDiv * pieUserPrize;

      // This won't happen, but for the eye- and mind- confort let's check this condition
      if (payoutToWinner > address(this).balance) {
        payoutToWinner = address(this).balance;
      }

      winnerAddress = address(participants[winnerRandId]);
      itemStatus = 10;
      winnerAddress.send(payoutToWinner);

      // Bonus Winner
      if (referrers.length > 0) {
        uint256 winnerReferrerRandId = (itemNonce + uint256(blockhash(finalBlockNumber))) % referrers.length;
        payoutToReferrerWinner = (ticketsSold * ticketPrice) / pieToPercentageDiv * pieBonusDrawing;
        winnerReferrerAddress = address(referrers[winnerReferrerRandId]);
        hasWinnerReferrer = 1;

        // This won't happen, but for the eye- and mind- confort let's check this condition
        if (payoutToReferrerWinner > address(this).balance) {
          payoutToReferrerWinner = address(this).balance;
        }

        winnerReferrerAddress.send(payoutToReferrerWinner);
      } else {
        hasWinnerReferrer = 2;
      }

      // Maybe few weis left on balance (could be possible because of div operations above)
      if (address(this).balance > 0) {
        dividendsContractAddress.send(address(this).balance);
      }

      emit PayoutSentToWinners(
        itemId,
        referrers.length > 0,
        winnerAddress,
        winnerReferrerAddress,
        payoutToWinner,
        payoutToReferrerWinner
      );

      return itemStatus;
    }
  }

  function buyTicket(uint256 ticketsToBuy, bool hasReferrer, address referrer) public payable {
    require(itemStatus == 1, "Tickers are not available now.");
    require(ticketsToBuy <= ticketsTotal && ticketsToBuy > 0, "Wrong tickets count");
    require(block.timestamp <= finalTimestamp, "Timed out");

    uint256 ticketsRequiredAmount = ticketsToBuy * ticketPrice;
    require(msg.value >= ticketsRequiredAmount, "Wrong wei amount");

    uint256 correctNumberOfTickets = ticketsToBuy;
    
    if (correctNumberOfTickets > ticketsAvailable) {
      correctNumberOfTickets = ticketsAvailable;
      // Send change back
      // uint256 ticketsDiff = ...
      // will be implemented in next versions
    }

    ticketsSold += correctNumberOfTickets;
    ticketsAvailable -= correctNumberOfTickets;

    for (uint256 i = 0; i < correctNumberOfTickets; i++) {
      participants.push(msg.sender);
      if (hasReferrer) {
        referrers.push(referrer);
      }
    }

    if (ticketsAvailable == 0) {
      itemStatus = 2;
      finalBlockNumber = block.number + 2;
      emit ItemBecomeReadyForWinner(
        itemId,
        block.timestamp,
        finalBlockNumber
      );
    }

    uint256 dividendsInstantPayout = ticketsRequiredAmount / pieToPercentageDiv * pieDividends;
    // limit of local vars (stack too deep), sol let's inline cashback and ref payout caclulations

    emit TicketSold(
      itemId,
      correctNumberOfTickets,
      (ticketsTotal - ticketsAvailable),
      ticketsAvailable,
      msg.sender,
      block.timestamp,
      ticketPrice,
      hasReferrer,
      referrer,
      hasReferrer ? (ticketsRequiredAmount / pieToPercentageDiv * pieInstantReferralPayout) : 0
    );
    
    if (hasCashback) {
      address(msg.sender).send(ticketsRequiredAmount / pieToPercentageDiv * pieCashback);
    } else {
      dividendsInstantPayout += (ticketsRequiredAmount / pieToPercentageDiv * pieCashback);
    }

    if (hasReferrer) {
      address(referrer).send(ticketsRequiredAmount / pieToPercentageDiv * pieInstantReferralPayout);
    } else {
      dividendsInstantPayout += (ticketsRequiredAmount / pieToPercentageDiv * pieInstantReferralPayout);
    }

    dividendsContractAddress.send(dividendsInstantPayout);
  }

  function checkFinishLotteryStatus() public view returns(uint8 _status, uint256 _finalBlock, uint256 _currentBlock, uint256 _finalTimestamp, uint256 _currentTimestamp) {
    return (
      itemStatus,
      finalBlockNumber,
      block.number,
      finalTimestamp,
      block.timestamp
    );
  }

  /* https://etherscan.io - friendly output functions. For section "Read Contract" */

  function getItemId() public view returns (string _itemId) {
    return itemId;
  }

  function getItemCaption() public view returns (string _itemCaption) {
    return itemCaption;
  }

  function getItemUrl() public view returns (string _itemUrl) {
    return itemUrl;
  }

  function getTicketPrice() public view returns (uint256) {
    return ticketPrice;
  }

  function getFinalTimestamp() public view returns (uint256) {
    return finalTimestamp;
  }
  
  function getPieFinanceInfo() public view returns(bool _hasCashback, address _dividendsContractAddress) {
    return (
      hasCashback,
      dividendsContractAddress
    );
  }

  function getParticipants() public view returns (address[] _participants) {
    return participants;
  }

  function getReferrers() public view returns (address[] _referrers) {
    return referrers;
  }

  function getItemStatus() public view returns (uint8 _itemStatus) {
    return itemStatus;
  }

  function getItemStatusHuman() public view returns (string _itemStatusHuman) {
    if (itemStatus == 0) return "Not started";
    else if (itemStatus == 1) return "Started";
    else if (itemStatus == 2) return "All tickets sold (or timed out), waiting for the draw";
    else if (itemStatus == 10) return "Payout made";
    else return "N/A";
  }

  function getItemPrice() public view returns (uint256 _itemPrice) {
    return itemPrice;
  }

  function getTicketsInfo() public view returns (uint256 _ticketsTotal, uint256 _ticketsAvailable, uint256 _ticketsSold) {
    return (ticketsTotal, ticketsAvailable, ticketsSold);
  }

  function getWinDetails() public view returns (address _winnerAddress, uint256 _payoutToWinner, uint8 _hasWinnerReferrer, address _winnerReferrerAddress, uint256 _payoutToReferrerWinner) {
    return (winnerAddress, payoutToWinner, hasWinnerReferrer, winnerReferrerAddress, payoutToReferrerWinner);
  }

  function() public payable {
    uint256 ticketsNumber = msg.value / ticketPrice;
    require(ticketsNumber > 0, "Wrong number of tickets");
    buyTicket(ticketsNumber, false, address(0));
  }
  
}
