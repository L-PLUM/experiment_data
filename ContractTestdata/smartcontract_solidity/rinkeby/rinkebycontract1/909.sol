/**
 *Submitted for verification at Etherscan.io on 2019-02-04
*/

pragma solidity ^0.4.22;

contract CouponManager {
  enum Answers { NoAnswer, Approved, Denied, Pending }

  struct Batch {
    string description;
    uint   expiresAt;
    uint24 amount;
    uint24 free;
    uint   payPerPublication;
    uint   payPerClaim;
    address issuer;
    bool   isLocked;
    uint   remainingBalance;
    mapping(address => uint24) reservations;
    mapping(address => uint24) claimsFor;
  }

  struct Claim {
    Answers answer;
    uint24 couponBatchId;
    uint24 amount;
    address publisher;
    address vendor;
  }

  address private creator;

  uint24 private currentBatchId;
  uint private currentClaimId;

  mapping(uint24 => Batch) public batches;
  mapping(uint => Claim) public claims;
  mapping(address => uint) public balances;

  event Issued(uint24 couponBatchId, address issuer, uint amount);
  event Reserved(uint24 couponBatchId, address publisher, uint amount);
  event Claimed (uint claimId, uint24 couponBatchId, address vendor, address publisher, uint amount);
  event Acknowledged (uint claimId, Answers answer);

  modifier notExpired(uint24 couponBatchId) {
    require(isActive(couponBatchId));
    _;
  }

  constructor() public {
    creator = msg.sender;
  }

  function issue(string _name,
                 uint _expiresAt,
                 uint24 _amount,
                 uint _payPerPublication,
                 uint _payPerClaim) public  payable {
    require(_amount > 0);
    require(_payPerPublication > 0);
    require(_payPerClaim > 0);
    require((_amount * (_payPerPublication + _payPerClaim)) == msg.value);

    currentBatchId += 1;
    batches[currentBatchId] = Batch(
      _name,
      _expiresAt,
      _amount,
      _amount, // At initialization 'free' equals amount: all coupons are free
      _payPerPublication,
      _payPerClaim,
      msg.sender,
      false,
      msg.value
    );
    emit Issued(currentBatchId, msg.sender, _amount);
  }

  function reserve(uint24 couponBatchId, uint24 _amount) public notExpired(couponBatchId) {
    require(batches[couponBatchId].free >= _amount);

    // TODO: replace addition and substraction with SafeMath to avoid overflows.
    batches[couponBatchId].free -= _amount;
    batches[couponBatchId].reservations[msg.sender] += _amount;
    emit Reserved(couponBatchId, msg.sender, _amount);
  }

  function claim(uint24 couponBatchId,
                 uint24 _amount,
                 address publisher) public notExpired(couponBatchId) {
    // Check that there are enough claimable coupons left on the reservation
    //  for this publisher.
    // TODO: has an overflow issue, in which we cannot ensure that a - b > 0.
    Batch storage batch = batches[couponBatchId];
    require((batch.reservations[publisher] -
             batch.claimsFor[publisher]) > _amount);

    currentClaimId += 1;
    // Set the acknowledgement for this claim to the default value.
    // This allows us to differ between 0 - noAnswer and 3 - Pending
    claims[currentClaimId] = Claim(
      Answers.Pending,
      couponBatchId,
      _amount,
      publisher,
      msg.sender
    );

    // TODO: Is now stored twice; once in claimsFor and once in claims.
    // claims.filter((claim) => claim.publisher == publisher).sum is the
    // same as this amount.
    batch.claimsFor[publisher] += _amount;

    emit Claimed(currentClaimId, couponBatchId, msg.sender, publisher, _amount);
  }

  function acknowledge(uint24 claimId, bool answer) public {
    Claim memory acknowledgebleClaim = claims[claimId];

    // Checking for Undecided determins wethe no aswer was given yet;
    // and also the claimId was registered as claim already.
    require(acknowledgebleClaim.answer == Answers.Pending);

    Batch storage batch = batches[acknowledgebleClaim.couponBatchId];
    if (isActive(acknowledgebleClaim.couponBatchId)) {
      // When batch is still active, only issuer can acknowledge
      require(batch.issuer == msg.sender);
    }
    else {
      // When batch is expired, any participant can acknowledge
      require(
        (batch.issuer == msg.sender) ||
        (acknowledgebleClaim.vendor == msg.sender) ||
        (acknowledgebleClaim.publisher == msg.sender)
      );
    }

    uint payToPublisher = acknowledgebleClaim.amount * batch.payPerPublication;
    uint payToVendor   = acknowledgebleClaim.amount * batch.payPerClaim;

    // TODO: determine whether we want As Cheap As Possible, or
    // equalized gas-costs: currently, denying is cheaper than
    // approving. This may influence the honesty.
    if (answer) { // True == Approved
      claims[claimId].answer = Answers.Approved;
      // TODO: extract to helper methods.
      // TODO: handle integer overflows with SafeMath
      balances[acknowledgebleClaim.publisher] += payToPublisher;
      balances[acknowledgebleClaim.vendor]    += payToVendor;

      batch.remainingBalance -= (payToPublisher + payToVendor);
    } else {
      claims[claimId].answer = Answers.Denied;
    }

    emit Acknowledged(claimId, claims[claimId].answer);
  }

  function lock(uint24 couponBatchId) public {
    Batch storage batch = batches[couponBatchId];

    // The current blocktime has passed the expiresAt.
    require(!isActive(couponBatchId));
    // Ensure we can run lock only once
    require(batch.isLocked == false);
    // Only Issuer can run
    require(batch.issuer == msg.sender);

    batch.isLocked = true;
    balances[batch.issuer] += batch.remainingBalance;
  }

  function withdraw(uint _amount) public {
    require(balances[msg.sender] >= _amount);

    balances[msg.sender] -= _amount;

    msg.sender.transfer(_amount);
  }

  function kill() public {
    require(msg.sender == creator);
    selfdestruct(creator);
  }

  function isActive(uint24 couponBatchId) public view returns(bool) {
    return batches[couponBatchId].expiresAt > now;
  }
}
