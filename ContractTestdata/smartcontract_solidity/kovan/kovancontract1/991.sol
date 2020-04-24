/**
 *Submitted for verification at Etherscan.io on 2018-12-11
*/

pragma solidity ^0.4.24;

// File: ../../openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: ../../openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: ../../openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: contracts/lib/SafeMath32.sol

library SafeMath32 {

    function mul(uint32 a, uint32 b) internal pure returns (uint32) {
        if (a == 0) {
            return 0;
        }
        uint32 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint32 a, uint32 b) internal pure returns (uint32) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint32 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn’t hold
        return c;
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32) {
        assert(b <= a);
        return a - b;
    }

    function add(uint32 a, uint32 b) internal pure returns (uint32) {
        uint32 c = a + b;
        assert(c >= a);
        return c;
    }
}

// File: contracts/lib/SafeMath192.sol

library SafeMath192 {

    function mul(uint192 a, uint192 b) internal pure returns (uint192) {
        if (a == 0) {
            return 0;
        }
        uint192 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint192 a, uint192 b) internal pure returns (uint192) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint192 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn’t hold
        return c;
    }

    function sub(uint192 a, uint192 b) internal pure returns (uint192) {
        assert(b <= a);
        return a - b;
    }

    function add(uint192 a, uint192 b) internal pure returns (uint192) {
        uint192 c = a + b;
        assert(c >= a);
        return c;
    }
}

// File: contracts/lib/ECVerify.sol

library ECVerify {

    function ecverify(bytes32 hash, bytes32 r, bytes32 s, uint8 v) internal pure returns (address signature_address) {

        // Version of signature should be 27 or 28, but 0 and 1 are also possible
        if (v < 27) {
            v += 27;
        }
        require(v == 27 || v == 28);
        
	signature_address = ecrecover(hash, v, r, s);
        require(signature_address != address(0));

        return signature_address;
    }
}

// File: contracts/RightMeshContestTokenPaymentChannel.sol

contract RightMeshContestTokenPaymentChannel is Ownable {
    using SafeMath192 for uint192;
    using SafeMath32 for uint32;
    string public constant version = '0.1';
    uint32 public challengingPeriod;
    uint192 public depositLimit;
    IERC20 public token;
    mapping (bytes32 => PaymentChannel) public paymentChannels;
    mapping (bytes32 => ClosingRequest) public closingRequests;

    struct PaymentChannel {
        uint192 currentDeposit;
        uint192 totalWithdrawn;
        uint32  openedBlockNumber;
    }

    struct ClosingRequest {
        uint192 claimAmountPaid;
        uint32  earliestSettlementBlockNumber;
    }

    event ChannelCreated (
        address indexed spenderAddress,
        address indexed receiverAddress,
        uint192 currentDeposit,
        uint32  openedBlockNumber);
    event ChannelToppedUp (
        address indexed spenderAddress,
        address indexed receiverAddress,
        uint192 toppedUpDeposit,
        uint192 currentDeposit,
        uint32  toppedUpBlockNumber);
    event ChannelWithdrawn (
        address indexed spenderAddress,
        address indexed receiverAddress,
        uint192 withdrawnAmount,
        uint32  withdrawnBlockNumber);
    event ChannelCloseRequested (
        address indexed spenderAddress,
        address indexed receiverAddress,
        uint192 claimAmountPaid,
        uint32  requestedBlockNumber,
        uint32  earliestSettlementBlockNumber);
    event ChannelClosed (
        address indexed spenderAddress,
        address indexed receiverAddress,
        uint192 amountToReceiver,
        uint192 amountToSender,
        uint32  closedBlockNumber);

    constructor (
        address _tokenAddress,
        uint32 _challengingPeriod,
        uint192 _depositLimit)
    public {
        require(_tokenAddress != address(0));
        require(addressHasCode(_tokenAddress));
        token = IERC20(_tokenAddress);
        require(token.totalSupply() > 0);
        challengingPeriod = _challengingPeriod;
        depositLimit = _depositLimit;
    }

    function createPaymentChannel (
        address _receiverAddress,
        uint192 _initialDeposit)
    external {
        require(token.transferFrom(msg.sender, address(this), _initialDeposit));
        createChannel(msg.sender, _receiverAddress, _initialDeposit);
    }

    function topUpTotalDeposit (
        address _receiverAddress,
        uint192 _addedDeposit)
    external {
        require(token.transferFrom(msg.sender, address(this), _addedDeposit));
        addDeposit(msg.sender, _receiverAddress, _addedDeposit);
    }

    function updateChallengingPeriod (
        uint32 _challengingPeriod) onlyOwner
    external {
        challengingPeriod = _challengingPeriod;
    }


    function receiverWithdraw (
        address _spenderAddress,
        uint192 _totalAmountWithdraw,
        bytes32 _spenderSignatureR,
        bytes32 _spenderSignatureS,
	    uint8   _spenderSignatureV)
        external {
        bytes32 key = getChannelKey (_spenderAddress, msg.sender);
        require (paymentChannels[key].openedBlockNumber > 0);
        require (_totalAmountWithdraw <= paymentChannels[key].currentDeposit.add(paymentChannels[key].totalWithdrawn));
        require (_totalAmountWithdraw > paymentChannels[key].totalWithdrawn);
        address spender = recoverSpenderAddress (
            msg.sender, _totalAmountWithdraw, _spenderSignatureR, _spenderSignatureS, _spenderSignatureV);
        require(spender == _spenderAddress);
        uint192 amountToReceiver;
        uint32 blockNumber = uint32(block.number);
        if (closingRequests[key].earliestSettlementBlockNumber > 0 && _totalAmountWithdraw > closingRequests[key].claimAmountPaid) {
            amountToReceiver = paymentChannels[key].currentDeposit;
            require(token.transfer(msg.sender, amountToReceiver));
            delete paymentChannels[key];
            delete closingRequests[key];
            emit ChannelClosed(_spenderAddress, msg.sender, amountToReceiver, 0, blockNumber);
        } else {
            amountToReceiver = _totalAmountWithdraw.sub(paymentChannels[key].totalWithdrawn);
            require(token.transfer(msg.sender, amountToReceiver));
            paymentChannels[key].totalWithdrawn = _totalAmountWithdraw;
            paymentChannels[key].currentDeposit = paymentChannels[key].currentDeposit.sub(amountToReceiver);
            emit ChannelWithdrawn(spender, msg.sender, amountToReceiver, blockNumber);
        }
    }

    function requestToClose (
        address _receiverAddress,
        uint192 _claimAmountPaid)
    external {
        bytes32 key = getChannelKey(msg.sender, _receiverAddress);
        require(paymentChannels[key].openedBlockNumber > 0);
        require(closingRequests[key].earliestSettlementBlockNumber == 0);
        require(_claimAmountPaid <= paymentChannels[key].currentDeposit.add(paymentChannels[key].totalWithdrawn));
        uint32 blockNumber = uint32(block.number);
        if (_claimAmountPaid >= paymentChannels[key].totalWithdrawn) {
            uint32 earliestSettlementBlockNumber = blockNumber.add(challengingPeriod);
            closingRequests[key].earliestSettlementBlockNumber = earliestSettlementBlockNumber;
            closingRequests[key].claimAmountPaid = _claimAmountPaid;
            emit ChannelCloseRequested(msg.sender, _receiverAddress, _claimAmountPaid, blockNumber, earliestSettlementBlockNumber);
        } else {
            uint192 amountToReceiver = paymentChannels[key].currentDeposit;
            require(token.transfer(_receiverAddress, amountToReceiver));
            delete paymentChannels[key];
            delete closingRequests[key];
            emit ChannelClosed(msg.sender, _receiverAddress, amountToReceiver, 0, blockNumber);
        }
    }

    function recoverReceiverAddress (
        address _spenderAddress,
        uint192 _claimAmountPaid,
        bytes32 _receiverSignatureR,
	    bytes32 _receiverSignatureS,
	    uint8   _receiverSignatureV)
    private
    view
    returns (address) {
        bytes32 plainText = getTextSignedByReceiver (_spenderAddress, _claimAmountPaid);
        return ECVerify.ecverify (plainText, _receiverSignatureR, _receiverSignatureS, _receiverSignatureV);
    }

    function spenderCloseChannel (
        address _receiverAddress)
    external {
        bytes32 key = getChannelKey(msg.sender, _receiverAddress);
        require(closingRequests[key].earliestSettlementBlockNumber > 0);
        uint32 blockNumber = uint32(block.number);
	    require(blockNumber > closingRequests[key].earliestSettlementBlockNumber);
        uint192 amountToReceiver = closingRequests[key].claimAmountPaid.sub(paymentChannels[key].totalWithdrawn);
        uint192 amountToSpender = paymentChannels[key].currentDeposit.sub(amountToReceiver);
        require(token.transfer(_receiverAddress, amountToReceiver));
        require(token.transfer(msg.sender, amountToSpender));
        delete paymentChannels[key];
        delete closingRequests[key];
        emit ChannelClosed(msg.sender, _receiverAddress, amountToReceiver, amountToSpender, blockNumber);
    }

    function getChannelInfo(
        address _spenderAddress,
        address _receiverAddress)
    external
    view
    returns (bytes32, uint192, uint192, uint32) {
        bytes32 key = getChannelKey(_spenderAddress, _receiverAddress);
        return (
            key,
            paymentChannels[key].currentDeposit,
            paymentChannels[key].totalWithdrawn,
            paymentChannels[key].openedBlockNumber
        );
    }

    function recoverSpenderAddress(
        address _receiverAddress,
        uint192 _totalAmountWithdraw,
        bytes32 _spenderSignatureR,
	    bytes32 _spenderSignatureS,
	    uint8   _spenderSignatureV)
    private
    view
    returns (address) {
        bytes32 planText = getTextSignedBySender (_receiverAddress, _totalAmountWithdraw);
        return ECVerify.ecverify(planText, _spenderSignatureR, _spenderSignatureS, _spenderSignatureV);
    }

    function getTextSignedBySender (
        address _receiverAddress,
        uint192 _totalAmountWithdraw)
    private
    view
    returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256(
                    abi.encode('string paymentPrefix', 'address receiverAddress', 'uint192 amountPaid', 'address contractAddress')),
                keccak256(
                    abi.encode('spender payment signature', _receiverAddress, _totalAmountWithdraw, address(this)))
            )
        );
    }

    function getTextSignedByReceiver (
        address _spenderAddress,
        uint192 _claimAmountPaid)
    private
    view
    returns (bytes32) {
    	return keccak256(
            abi.encode(
                keccak256(
                    abi.encode('string receiptPrefix', 'address spenderAddress', 'uint192 amountReceived', 'address contractAddress')),
                keccak256(
                    abi.encode('receiver receipt signature', _spenderAddress, _claimAmountPaid, address(this)))
            )
        );
    }

    function getChannelKey(
        address _spenderAddress,
        address _receiverAddress)
    private
    pure
    returns (bytes32 data) {
        return keccak256(abi.encode(_spenderAddress, _receiverAddress));
    }

    function createChannel (
        address _spenderAddress,
        address _receiverAddress,
        uint192 _totalDeposit)
    private {
        require(_totalDeposit <= depositLimit);
        bytes32 key = getChannelKey(_spenderAddress, _receiverAddress);
        require(paymentChannels[key].openedBlockNumber == 0);
        require(closingRequests[key].earliestSettlementBlockNumber == 0);
        paymentChannels[key] = PaymentChannel({currentDeposit: _totalDeposit, totalWithdrawn: 0, openedBlockNumber: uint32(block.number)});
        emit ChannelCreated(_spenderAddress, _receiverAddress, _totalDeposit, uint32(block.number));
    }

    function addDeposit (
        address _spenderAddress,
        address _receiverAddress,
        uint192 _addedDeposit)
    private {
        require(_addedDeposit > 0);
        bytes32 key = getChannelKey(_spenderAddress, _receiverAddress);
        require(paymentChannels[key].openedBlockNumber > 0);
        require(closingRequests[key].earliestSettlementBlockNumber == 0);
        require(paymentChannels[key].currentDeposit.add(_addedDeposit) <= depositLimit);
        paymentChannels[key].currentDeposit = paymentChannels[key].currentDeposit.add(_addedDeposit);
        emit ChannelToppedUp(_spenderAddress, _receiverAddress, _addedDeposit, paymentChannels[key].currentDeposit, uint32(block.number));
    }

    function addressHasCode(address _contract) internal view returns (bool) {
        uint size;
        assembly {
            size := extcodesize(_contract)
        }
        return size > 0;
    }
}
