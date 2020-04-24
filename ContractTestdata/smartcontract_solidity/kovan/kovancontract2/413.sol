/**
 *Submitted for verification at Etherscan.io on 2019-07-09
*/

pragma solidity ^0.5.8;

contract KingAutomaton {
  //////////////////////////////////////////////////////////////////////////////////////////////////
  // Initialization
  //////////////////////////////////////////////////////////////////////////////////////////////////

  constructor(uint numSlots, uint8 minDifficultyBits, uint predefinedMask, uint initialDailySupply) public {
    initMining(numSlots, minDifficultyBits, predefinedMask, initialDailySupply);
    initNames();
    initTreasury();

    // Check if we're on a testnet (We will not using predefined mask when going live)
    if (predefinedMask != 0) {
      // If so, fund the owner for debugging purposes.
      mint(msg.sender, 1000000 ether);
    }
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // ERC20 Token
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Special purpose community managed addresses.
  address treasuryAddress = address(1);
  address exchangeAddress = address(2);

  string public constant name = "Automaton Network Validator Bootstrap";
  string public constant symbol = "AUTO";
  uint8 public constant decimals = 18;
  uint public totalSupply = 0;

  // solhint-disable-next-line no-simple-event-func-name
  event Transfer(address indexed _from, address indexed _to, uint _value);
  event Approval(address indexed _owner, address indexed _spender, uint _value);

  uint constant private MAX_uint = 2**256 - 1;
  mapping (address => uint) public balances;
  mapping (address => mapping (address => uint)) public allowed;

  function transfer(address _to, uint _value) public returns (bool success) {
    require(balances[msg.sender] >= _value);
    balances[msg.sender] -= _value;
    balances[_to] += _value;
    emit Transfer(msg.sender, _to, _value); //solhint-disable-line indent, no-unused-vars
    return true;
  }

  function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
    uint allowance = allowed[_from][msg.sender];
    require(balances[_from] >= _value && allowance >= _value);
    balances[_to] += _value;
    balances[_from] -= _value;
    if (allowance < MAX_uint) {
        allowed[_from][msg.sender] -= _value;
    }
    emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
    return true;
  }

  function balanceOf(address _owner) public view returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) public returns (bool success) {
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value); //solhint-disable-line indent, no-unused-vars
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint remaining) {
    return allowed[_owner][_spender];
  }

  // This is only to be used with special purpose community accounts like Treasury, Exchange.
  // Those accounts help to represent the total supply correctly.
  function transferInternal(address _from, address _to, uint _value) private returns (bool success) {
    require(balances[_from] >= _value, "Insufficient balance");
    balances[_to] += _value;
    balances[_from] -= _value;
    emit Transfer(_from, _to, _value); //solhint-disable-line indent, no-unused-vars
    return true;
  }

  function mint(address _receiver, uint _value) private {
    balances[_receiver] += _value;
    totalSupply += _value;
    emit Transfer(address(0), _receiver, _value); //solhint-disable-line indent, no-unused-vars
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // Treasury
  //////////////////////////////////////////////////////////////////////////////////////////////////

  enum State {
    Proposed,
    Approved,
    Rejected,
    Accepted,
    Terminated,
    Completed
  }

  struct Proposal {
    address payable contributor;
    string title;
    string documentsLink;
    bytes documentsHash;

    uint yesVotes;
    uint noVotes;
  }

  Proposal[] proposals;

  function initTreasury() private {
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // Mining
  //////////////////////////////////////////////////////////////////////////////////////////////////

  event NewSlotKing(uint slot, address newOwner);

  struct ValidatorSlot {
    address owner;
    uint difficulty;
    uint last_claim_time;
  }
  ValidatorSlot[] public slots;

  uint public minDifficulty;          // Minimum difficulty
  uint public mask;                   // Prevents premine
  uint public numTakeOvers;           // Number of times a slot was taken over by a new king.
  uint public rewardPerSlotPerSecond; // Validator reward per slot per second.

  function initMining(uint numSlots, uint8 minDifficultyBits, uint predefinedMask, uint initialDailySupply) private {
    require(numSlots > 0);
    require(minDifficultyBits > 0);

    slots.length = numSlots;
    minDifficulty = (2 ** uint(minDifficultyBits) - 1) << (256 - minDifficultyBits);
    if (predefinedMask == 0) {
      // Prevents premining with a known predefined mask.
      mask = uint(keccak256(abi.encodePacked(now, msg.sender)));
    } else {
      // Setup predefined mask, useful for testing purposes.
      mask = predefinedMask;
    }

    rewardPerSlotPerSecond = (1 ether * initialDailySupply) / 1 days / numSlots;
  }

  function getSlotsNumber() public view returns(uint) {
    return slots.length;
  }

  function getSlotOwner(uint slot) public view returns(address) {
    return slots[slot].owner;
  }

  function getSlotDifficulty(uint slot) public view returns(uint) {
    return slots[slot].difficulty;
  }

  function getSlotLastClaimTime(uint slot) public view returns(uint) {
    return slots[slot].last_claim_time;
  }

  function getMask() public view returns(uint) {
    return mask;
  }

  function getClaimed() public view returns(uint) {
    return numTakeOvers;
  }

  /** Claims slot based on a signature.
    * @param pubKeyX X coordinate of the public key used to claim the slot
    * @param pubKeyY Y coordinate of the public key used to claim the slot
    * @param v recId of the signature needed for ecrecover
    * @param r R portion of the signature
    * @param s S portion of the signature
    */
  function claimSlot(
    bytes32 pubKeyX,
    bytes32 pubKeyY,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) public {
    uint slot = uint(pubKeyX) % slots.length;
    uint key = uint(pubKeyX) ^ mask;

    // Check if the key can take over the slot and become the new king.
    require(key > minDifficulty && key > slots[slot].difficulty, "Low key difficulty");

    // Make sure the signature is valid.
    require(verifySignature(pubKeyX, pubKeyY, bytes32(uint(msg.sender)), v, r, s), "Signature not valid");

    // TODO(asen): Implement reward decaying over time.

    // Kick out prior king if any and reward them.
    uint last_time = slots[slot].last_claim_time;
    if (last_time != 0) {
      require (last_time < now, "mining same slot in same block or clock is wrong");
      uint value = (now - last_time) * rewardPerSlotPerSecond;
      mint(address(treasuryAddress), value);
      mint(slots[slot].owner, value);
    } else {
      // Reward first time validators as if they held the slot for 1 hour.
      uint value = (3600) * rewardPerSlotPerSecond;
      mint(address(treasuryAddress), value);
      mint(msg.sender, value);
    }

    // Update the slot with data for the new king.
    slots[slot].owner = msg.sender;
    slots[slot].difficulty = key;
    slots[slot].last_claim_time = now;

    numTakeOvers++;
    emit NewSlotKing(slot, msg.sender);
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // User Registration
  //////////////////////////////////////////////////////////////////////////////////////////////////

  struct UserInfo {
    string userName;
    string info;
  }

  mapping (string => address) public mapNameToUser;
  mapping (address => UserInfo) public mapUsersInfo;
  address[] public userAddresses;

  function initNames() private {
    registerUserInternal(treasuryAddress, "Treasury", "");
  }

  function getUserName(address addr) public view returns (string memory) {
    return mapUsersInfo[addr].userName;
  }

  function registerUserInternal(address addr, string memory userName, string memory info) private {
    userAddresses.push(addr);
    mapNameToUser[userName] = addr;
    mapUsersInfo[addr].userName = userName;
    mapUsersInfo[addr].info = info;
  }

  function registerUser(string memory userName, string memory info) public {
    require(mapNameToUser[userName] == address(0));
    registerUserInternal(msg.sender, userName, info);
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // DEX
  //////////////////////////////////////////////////////////////////////////////////////////////////

  uint public minOrderETH = 1 ether / 10;
  uint public minOrderAUTO = 1000 ether;

  enum OrderType { Buy, Sell, Auction }

  struct Order {
    uint AUTO;
    uint ETH;
    address payable owner;
    OrderType orderType;
  }

  Order[] public orders;

  function getExchangeBalance() public view returns (uint) {
    return balanceOf(exchangeAddress);
  }

  function removeOrder(uint _id) private {
    orders[_id] = orders[orders.length - 1];
    orders.length--;
  }

  function getOrdersLength() public view returns (uint) {
    return orders.length;
  }

  function buy(uint _AUTO) public payable returns (uint _id) {
    require(msg.value >= minOrderETH, "Minimum ETH requirement not met");
    require(_AUTO >= minOrderAUTO, "Minimum AUTO requirement not met");
    _id = orders.length;
    orders.push(Order(_AUTO, msg.value, msg.sender, OrderType.Buy));
  }

  function sellNow(uint _id, uint _AUTO, uint _ETH) public {
    require(_id < orders.length, "Invalid Order ID");
    Order memory o = orders[_id];
    require(o.AUTO == _AUTO, "Order AUTO does not match requested size");
    require(o.ETH == _ETH, "Order ETH does not match requested size");
    require(o.orderType == OrderType.Buy, "Invalid order type");
    transfer(o.owner, _AUTO);
    msg.sender.transfer(_ETH);
    removeOrder(_id);
  }

  function sell(uint _AUTO, uint _ETH) public returns (uint _id){
    require(_AUTO >= minOrderAUTO, "Minimum AUTO requirement not met");
    require(_ETH >= minOrderETH, "Minimum ETH requirement not met");
    transfer(exchangeAddress, _AUTO);
    _id = orders.length;
    orders.push(Order(_AUTO, _ETH, msg.sender, OrderType.Sell));
  }

  function buyNow(uint _id, uint _AUTO) public payable {
    require(_id < orders.length, "Invalid Order ID");
    Order memory o = orders[_id];
    require(o.AUTO == _AUTO, "Order AUTO does not match requested size");
    require(o.ETH == msg.value, "Order ETH does not match requested size");
    require(o.orderType == OrderType.Sell, "Invalid order type");
    o.owner.transfer(msg.value);
    transferInternal(exchangeAddress, msg.sender, _AUTO);
    removeOrder(_id);
  }

  function cancelOrder(uint _id) public {
    Order memory o = orders[_id];
    require(o.owner == msg.sender);

    if (o.orderType == OrderType.Buy) {
      msg.sender.transfer(o.ETH);
    }

    if (o.orderType == OrderType.Sell) {
      transferInternal(exchangeAddress, msg.sender, o.AUTO);
    }

    removeOrder(_id);
  }

  //////////////////////////////////////////////////////////////////////////////////////////////////
  // Internal Helpers
  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Returns the Ethereum address corresponding to the input public key.
  function getAddressFromPubKey(bytes32 pubkeyX, bytes32 pubkeyY) private pure returns (uint) {
    return uint(keccak256(abi.encodePacked(pubkeyX, pubkeyY))) & 0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
  }

  // Verifies that signature of a message matches the given public key.
  function verifySignature(bytes32 pubkeyX, bytes32 pubkeyY, bytes32 hash,
      uint8 v, bytes32 r, bytes32 s) private pure returns (bool) {
    uint addr = getAddressFromPubKey(pubkeyX, pubkeyY);
    address addr_r = ecrecover(hash, v, r, s);
    return addr == uint(addr_r);
  }
}
