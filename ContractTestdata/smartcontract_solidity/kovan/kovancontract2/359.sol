/**
 *Submitted for verification at Etherscan.io on 2019-07-15
*/

pragma solidity ^0.5.7;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract paymentChannel is Ownable{

    constructor () public Ownable() {
        // do nothing
    }
    event channelOpen(
        bytes32 channelID,
        address payable person1,
        address payable person2,
        uint deposit,
        uint256 challengePeriod
    );
    
    event channelJoined(
        bytes32 channelID,
        address payable person1,
        address payable person2,
        uint256 deposit1,
        uint256 deposit2
    );
    
    event channelChallenge(
        bytes32 channelID,
        address payable challengeStartedBy,
        uint256 challengePeriod
    );
    
    event channelUpdate(
        bytes32 channelID,
        uint256 nonce,
        uint256 balance1,
        uint256 balance2
    );
    
    event channelClosed(bytes32 channelID);

    enum channelStatus {
        open,
        joined,
        challenge,
        closed
    }
    
    struct channelStruct {
        uint256 nonce;
        address payable person1;
        address payable person2;
        uint256 minDeposit;
        uint256 deposit1;
        uint256 deposit2;
        uint256 challengePeriod;
        uint256 balance1;
        uint256 balance2;
        channelStatus status;
        uint256 closeTime;
    }
    
    mapping(bytes32 => channelStruct) public channels;
    mapping(address => mapping(address => bytes32)) public activeID;
    
    function openChannel(address payable _person1, address payable _person2, uint256 _deposit, uint256 _challengePeriod) public payable {
        require(_challengePeriod != 0, "Challenge period cannot be 0");
        require(_person1 != address(0) && _person2 != address(0), "address cannot be null");
        require(_person1 != _person2, "cannot create channel with self");
        require(activeID[_person1][_person2] == bytes32(0), "channel already exists");
        require(activeID[_person2][_person1] == bytes32(0), "channel already exists");
        
        bytes32 id = keccak256(abi.encodePacked(_person1, _person2, now));
        
        channels[id] = channelStruct(0, _person1, _person2, _deposit, 0, 0, _challengePeriod, 0, 0, channelStatus.open, 0);
        activeID[_person1][_person2] = id;
        
        emit channelOpen(id, _person1, _person2, _deposit, _challengePeriod);
    }
    
    function joinChannel(bytes32 _id, uint256 _deposit1, uint256 _deposit2, address payable _person1, address payable _person2) public payable {
        
        channelStruct storage channel = channels[_id];
        
        require(channel.status == channelStatus.open, "channel not open");
        require(_person1 == channel.person1, "not your channel");
        require(_person2 == channel.person2, "not your channel");
        require(channel.challengePeriod != 0, "challenge period is over");
        
        channel.deposit1 = _deposit1;
        channel.balance1 = _deposit1;
        channel.deposit2 = _deposit2;
        channel.balance2 = _deposit2;
        channel.status = channelStatus.joined;
        channel.nonce += 1;
        emit channelJoined(_id, channel.person1, channel.person2, _deposit1, _deposit2);
    }
    
    function balanceUpdate(bytes32 _id, uint256 _balance1, uint256 _balance2) public {
        
        channelStruct storage channel = channels[_id];
        
        require(channel.status != channelStatus.closed, "Channel not available");
        require(msg.sender == channel.person1 || msg.sender == channel.person2 , "Not your channel");
        require(channel.deposit1 >= channel.minDeposit && channel.deposit2 >= channel.minDeposit, "Deposit less than minimum required");
        
        channel.nonce += 1;
        channel.balance1 = _balance1;
        channel.balance2 = _balance2;
        
        emit channelUpdate(_id, channel.nonce, _balance1, _balance2);
    }
    
    function challengeStart(bytes32 _id) public payable {
        
        channelStruct storage channel = channels[_id];
        
        require(msg.sender == channel.person1 || msg.sender == channel.person2 , "Not your channel");
        require(channel.status == channelStatus.open || channel.status == channelStatus.joined , "Channel not available");
        
        channel.nonce += 1;
        channel.status = channelStatus.challenge;
        channel.closeTime = now + channel.challengePeriod;
        
        emit channelChallenge(_id, msg.sender, channel.closeTime);
    }
    
    function closeChannel(bytes32 _id) public payable {
        
        channelStruct storage channel = channels[_id];
        
        require(msg.sender == channel.person1 || msg.sender == channel.person2, "Not your channel");
        require(channel.status == channelStatus.challenge, "channel not in challenge");
        require(channel.closeTime < now, "Challenge period not over");
        
        uint256 balance1 = channel.balance1;
        uint256 balance2 = channel.balance2;
        
        channel.balance1 = 0;
        channel.balance2 = 0;
        
        channel.person1.transfer(balance1);
        channel.person2.transfer(balance2);
        
        channel.status = channelStatus.closed;
        
        delete activeID[channel.person1][channel.person2];
        delete channels[_id];
        
        emit channelClosed(_id);
    }
    
}
