/**
 *Submitted for verification at Etherscan.io on 2019-02-16
*/

pragma solidity 0.4.23;

contract CapsuleEscrow {
  // pack capsule struct into 256 bits to occupy single storage slot
  struct Capsule {
    address owner;
    uint48 feeSzabo;
    uint48 depositSzabo;
  }

  // check in structure fits into single storage slot
  struct CheckIn {
    address customer;
    uint32 checkedIn;
    uint32 checkedOut;
  }

  // capsules are added and removed by their owners
  mapping(uint32 => Capsule) capsules;

  // anyone can check in into free capsule
  mapping(uint32 => CheckIn) checkIns;

  // owners get profit for their service
  mapping(address => uint256) ownerBalances;

  function addCapsule(uint32 capsuleId, uint96 feeWei, uint96 depositWei) public {
    // verify capsule doesn't exist or is modified by its owner,
    // in case of modification - verify capsule is not under check in
    require(
      capsules[capsuleId].owner == address(0)
      || capsules[capsuleId].owner == msg.sender
      && checkIns[capsuleId].customer == address(0)
    );

    // write capsule directly to the storage
    capsules[capsuleId] = Capsule({
      owner: msg.sender,
      feeSzabo: uint48(feeWei / 1 szabo),
      depositSzabo: uint48(depositWei / 1 szabo)
    });
  }

  function removeCapsule(uint32 capsuleId) public {
    // ensure capsule is removed by its owner
    // and no one currently lives in that capsule
    require(
      capsules[capsuleId].owner == msg.sender
      && (checkIns[capsuleId].customer == address(0) || checkIns[capsuleId].checkedOut != 0)
    );

    // delete capsule from the storage
    delete capsules[capsuleId];
  }

  function checkIn(uint32 capsuleId) public payable {
    // verify capsule exists and is not occupied
    require(
      capsules[capsuleId].owner != address(0)
      && (checkIns[capsuleId].customer == address(0) || checkIns[capsuleId].checkedOut != 0)
    );

    // how much ETH we need to lock
    uint256 price = (capsules[capsuleId].feeSzabo + capsules[capsuleId].depositSzabo) * 1 szabo;

    // verify enough ETH is sent
    require(price <= msg.value);

    // top up owner's balance
    ownerBalances[capsules[capsuleId].owner] += price;

    // send the change back if needed
    if(msg.value > price) {
      msg.sender.transfer(msg.value - price);
    }

    // return ETH to previously checked out customer
    checkIns[capsuleId].customer.transfer(capsules[capsuleId].depositSzabo * 1 szabo);

    // perform the check in, write directly into storage
    checkIns[capsuleId] = CheckIn({
      customer: msg.sender,
      checkedIn: uint32(now),
      checkedOut: 0
    });

  }

  function checkOut(uint32 capsuleId) public {
    // verify sender is checked in
    require(checkIns[capsuleId].customer == msg.sender && checkIns[capsuleId].checkedOut == 0);

    // perform the checkout
    checkIns[capsuleId].checkedOut = uint32(now);
  }

  function reportAnIssue(uint32 capsuleId, string description) public {
    // verify capsule exists and is not occupied
    require(
      capsules[capsuleId].owner != address(0)
      && (checkIns[capsuleId].customer == address(0) || checkIns[capsuleId].checkedOut != 0)
    );

    // empty the capsule
    delete checkIns[capsuleId];
  }

  function withdraw() {
    // withdraw to the owner
    msg.sender.transfer(ownerBalances[msg.sender]);
  }
}
