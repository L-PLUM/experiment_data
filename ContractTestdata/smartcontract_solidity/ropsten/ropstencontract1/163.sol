/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^0.5.0;

contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 _amount, address _token, bytes memory _data) public;
}

// Abstract contract for the full ERC 20 Token standard
// https://github.com/ethereum/EIPs/issues/20

interface ERC20Token {

    /**
     * @notice send `_value` token to `_to` from `msg.sender`
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transfer(address _to, uint256 _value) external returns (bool success);

    /**
     * @notice `msg.sender` approves `_spender` to spend `_value` tokens
     * @param _spender The address of the account able to transfer the tokens
     * @param _value The amount of tokens to be approved for transfer
     * @return Whether the approval was successful or not
     */
    function approve(address _spender, uint256 _value) external returns (bool success);

    /**
     * @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value The amount of token to be transferred
     * @return Whether the transfer was successful or not
     */
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    /**
     * @param _owner The address from which the balance will be retrieved
     * @return The balance
     */
    function balanceOf(address _owner) external view returns (uint256 balance);

    /**
     * @param _owner The address of the account owning tokens
     * @param _spender The address of the account able to transfer the tokens
     * @return Amount of remaining tokens allowed to spent
     */
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    /**
     * @notice return total supply of tokens
     */
    function totalSupply() external view returns (uint256 supply);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}



/** 
 * @notice Uses ethereum signed messages
 */
contract MessageSigned {
    
    constructor() internal {}

    /**
     * @notice recovers address who signed the message
     * @param _signHash operation ethereum signed message hash
     * @param _messageSignature message `_signHash` signature
     */
    function recoverAddress(
        bytes32 _signHash, 
        bytes memory _messageSignature
    )
        internal
        pure
        returns(address) 
    {
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v,r,s) = signatureSplit(_messageSignature);
        return ecrecover(
            _signHash,
            v,
            r,
            s
        );
    }

    /**
     * @notice Hash a hash with `"\x19Ethereum Signed Message:\n32"`
     * @param _hash Sign to hash.
     * @return signHash Hash to be signed.
     */
    function getSignHash(
        bytes32 _hash
    )
        internal
        pure
        returns (bytes32 signHash)
    {
        signHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash));
    }

    /**
     * @dev divides bytes signature into `uint8 v, bytes32 r, bytes32 s` 
     */
    function signatureSplit(bytes memory _signature)
        internal
        pure
        returns (uint8 v, bytes32 r, bytes32 s)
    {
        // The signature format is a compact form of:
        //   {bytes32 r}{bytes32 s}{uint8 v}
        // Compact means, uint8 is not padded to 32 bytes.
        assembly {
            r := mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            // Here we are loading the last 32 bytes, including 31 bytes
            // of 's'. There is no 'mload8' to do this.
            //
            // 'byte' is not working due to the Solidity parser, so lets
            // use the second best option, 'and'
            v := and(mload(add(_signature, 65)), 0xff)
        }

        require(v == 27 || v == 28, "Bad signature");
    }
    
}


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



contract Pausable is Ownable {

    event Paused();
    event Unpaused();

    bool public paused;

    constructor () internal {
        paused = false;
    }

    modifier whenNotPaused() {
        require(!paused, "Contract must be unpaused");
        _;
    }

    modifier whenPaused() {
        require(paused, "Contract must be paused");
        _;
    }

    function pause() public onlyOwner whenNotPaused {
        paused = true;
        emit Paused();
    }


    function unpause() public onlyOwner whenPaused {
        paused = false;
        emit Unpaused();
    }
}




/**
* @title License
* @dev License contract for buying a license
*/
contract License is Ownable, ApproveAndCallFallBack {
    address payable private recipient;
    uint256 private price;
    uint256 private releaseDelay;
    string private constant LICENSE_ALREADY_BOUGHT = "License already bought";
    string private constant UNSUCCESSFUL_TOKEN_TRANSFER = "Unsuccessful token transfer";

    ERC20Token token;

    struct LicenseDetails {
        uint price;
        uint creationTime;
    }

    mapping(address => LicenseDetails) private licenseDetails;

    address[] public licenseOwners;
    mapping(address => uint) private idxLicenseOwners;

    event Bought(address buyer, uint256 price);
    event RecipientChanged(address _recipient);
    event PriceChanged(uint256 _price);
    event Released(address buyer);
    event ReleaseDelayChanged(uint256 _newDelay);

    uint256 public reserveAmount;

    constructor(address payable _tokenAddress, address payable _recipient, uint256 _price, uint256 _releaseDelay) public {
        recipient = _recipient;
        price = _price;
        releaseDelay = _releaseDelay;
        reserveAmount = 0;
        token = ERC20Token(_tokenAddress);
    }

    /**
    * @dev Check if the address already owns a license
    * @param _address The address to check
    * @return bool
    */
    function isLicenseOwner(address _address) public view returns (bool) {
        return licenseDetails[_address].price != 0 && licenseDetails[_address].creationTime > 0;
    }

    /**
    * @dev Buy a license
    * @notice Requires value to be equal to the price of the license.
    *         The msg.sender must not already own a license.
    */
    function buy() public {
        buyFrom(msg.sender);
    }

    /**
    * @dev Buy a license
    * @notice Requires value to be equal to the price of the license.
    *         The _owner must not already own a license.
    */
    function buyFrom(address _owner) private {
        require(licenseDetails[_owner].creationTime == 0, LICENSE_ALREADY_BOUGHT);
        require(token.allowance(_owner, address(this)) >= price, "Allowance not set for this contract to expected price");
        require(token.transferFrom(_owner, address(this), price), UNSUCCESSFUL_TOKEN_TRANSFER);

        licenseDetails[_owner].price = price;
        licenseDetails[_owner].creationTime = block.timestamp;
        reserveAmount += price;

        uint idx = licenseOwners.push(msg.sender);
        idxLicenseOwners[msg.sender] = idx;

        emit Bought(_owner, token.allowance(_owner, address(this)));
    }

    /**
    * @dev Release a license and retrieve funds
    * @notice Only the owner of a license can perform the operation after the release delay time has passed.
    */
    function release() public {
        require(licenseDetails[msg.sender].creationTime > 0, LICENSE_ALREADY_BOUGHT);
        require(licenseDetails[msg.sender].creationTime + releaseDelay < block.timestamp, "Release period not reached.");
        require(token.transfer(msg.sender, licenseDetails[msg.sender].price), UNSUCCESSFUL_TOKEN_TRANSFER);

        reserveAmount -= licenseDetails[msg.sender].price;

        uint256 position = idxLicenseOwners[msg.sender];
        delete idxLicenseOwners[msg.sender];
        address replacer = licenseOwners[licenseOwners.length - 1];
        licenseOwners[position] = replacer;
        idxLicenseOwners[replacer] = position;
        licenseOwners.length--;

        delete licenseDetails[msg.sender];

        emit Released(msg.sender);
    }

    /**
    * @dev Get the recipient of the license
    * @return address
    */
    function getRecipient() public view returns (address) {
        return recipient;
    }

    /**
    * @dev Set the recipient
    * @param _recipient The new recipient of the license
    * @notice Only the owner of the contract can perform this action
    */
    function setRecipient(address payable _recipient) public onlyOwner {
        recipient = _recipient;
        emit RecipientChanged(_recipient);
    }

    /**
    * @dev Get the current price of the license
    * @return uint
    */
    function getPrice() public view returns (uint256) {
        return price;
    }

    /**
    * @dev Set the price
    * @param _price The new price of the license
    * @notice Only the owner of the contract can perform this action
    */
    function setPrice(uint256 _price) public onlyOwner {
        price = _price;
        emit PriceChanged(_price);
    }

    /**
    * @dev Get the current release delay time in seconds
    * @return uint
    */
    function getReleaseDelay() public view returns (uint256) {
        return releaseDelay;
    }

    /**
     * @dev Get number of license owners
     * @return uint
     */
    function getNumLicenseOwners() public view returns (uint256) {
        return licenseOwners.length;
    }

    /**
    * @dev Set the minimum amount of time before a license can be released
    * @param _releaseDelay The new release delay in seconds
    * @notice Only the owner of the contract can perform this action
    */
    function setReleaseDelay(uint256 _releaseDelay) public onlyOwner {
        releaseDelay = _releaseDelay;
        emit ReleaseDelayChanged(releaseDelay);
    }

    /**
     * @notice Withdraw not reserved tokens
     * @param _token Address of ERC20 withdrawing excess, or address(0) if want ETH.
     * @param _beneficiary Address to send the funds.
     **/
    function withdrawExcessBalance(address _token, address payable _beneficiary) external onlyOwner {
        require(_beneficiary != address(0), "Cannot burn token");
        if (_token == address(0)) {
            _beneficiary.transfer(address(this).balance);
        } else {
            ERC20Token excessToken = ERC20Token(_token);
            uint256 amount = excessToken.balanceOf(address(this));
            if(_token == address(token)){
                require(amount > reserveAmount, "Is not excess");
                amount -= reserveAmount;
            } else {
                require(amount > 0, "No balance");
            }
            excessToken.transfer(_beneficiary, amount);
        }
    }


    /**
     * @notice Support for "approveAndCall". Callable only by `token()`.
     * @param _from Who approved.
     * @param _amount Amount being approved, need to be equal `getPrice()`.
     * @param _token Token being approved, need to be equal `token()`.
     * @param _data Abi encoded data with selector of `register(bytes32,address,bytes32,bytes32)`.
     */
    function receiveApproval(address _from, uint256 _amount, address _token, bytes memory _data) public {
        require(_amount == price, "Wrong value");
        require(_token == address(token), "Wrong token");
        require(_token == address(msg.sender), "Wrong call");
        require(_data.length == 4, "Wrong data length");

        bytes4 sig = abiDecodeRegister(_data);

        require(
            sig == bytes4(0xa6f2ae3a), //bytes4(keccak256("buy()"))
            "Wrong method selector"
        );

        buyFrom(_from);
    }


    /**
     * @dev Decodes abi encoded data with selector for "buy()".
     * @param _data Abi encoded data.
     * @return Decoded registry call.
     */
    function abiDecodeRegister(bytes memory _data) private pure returns(bytes4 sig) {
        assembly {
            sig := mload(add(_data, add(0x20, 0)))
        }
    }


    /**
    * @dev Fallback function
    */
    function() external {
    }
}




/**
 * @title Escrow
 * @dev Escrow contract for buying/selling ETH. Current implementation lacks arbitrage, marking trx as paid, and ERC20 support
 */
contract Escrow is Pausable, MessageSigned {
    string private constant TRANSACTION_ALREADY_RELEASED = "Transaction already released";
    string private constant TRANSACTION_ALREADY_CANCELED = "Transaction already canceled";
    string private constant INVALID_ESCROW_ID = "Invalid escrow id";
    string private constant CAN_ONLY_BE_INVOKED_BY_ESCROW_OWNER = "Function can only be invoked by the escrow owner";

    constructor(address _license, address _arbitrator) public {
        license = License(_license);
        arbitrator = _arbitrator;
    }

    struct EscrowTransaction {
        address payable seller;
        address payable buyer;
        uint amount;
        address token;
        uint expirationTime;
        bool released;
        bool canceled;
        bool paid;
        uint rating;
    }

    EscrowTransaction[] public transactions;

    License public license;

    address public arbitrator;

    event Created(address indexed seller, address indexed buyer, uint escrowId, uint expirationTime, uint amount);
    event Paid(uint escrowId);
    event Released(uint escrowId);
    event Canceled(uint escrowId);
    event Rating(address indexed seller, address indexed buyer, uint escrowId, uint rating);

    mapping(uint => ArbitrationCase) public arbitrationCases;

    struct ArbitrationCase {
        bool open;
        address openBy;
        address arbitrator;
        ArbitrationResult result;
    }

    event ArbitratorChanged(address arbitrator);
    event ArbitrationRequired(uint escrowId);
    event ArbitrationResolved(uint escrowId, ArbitrationResult result, address arbitrator);

    enum ArbitrationResult {UNSOLVED, BUYER, SELLER}

    /**
     * @notice Create a new escrow
     * @param _buyer The address that will perform the buy for the escrow
     * @param _amount How much ether/tokens will be put in escrow
     * @param _token Token address. Must be 0 for ETH
     * @param _expirationTime Unix timestamp before the transaction is considered expired
     * @dev Requires contract to be unpaused.
     *         The seller needs to be licensed.
     *         The expiration time must be at least 10min in the future
     *         For eth transfer, _amount must be equals to msg.value, for token transfer, requires an allowance and transfer valid for _amount
     */
    function create(address payable _buyer, uint _amount, address _token, uint _expirationTime) public payable whenNotPaused {
        require(_expirationTime > (block.timestamp + 600), "Expiration time must be at least 10min in the future");
        require(license.isLicenseOwner(msg.sender), "Must be a valid seller to create escrow transactions");

        if(_token == address(0)){
            require(msg.value == _amount, "ETH amount is required");
        } else {
            require(msg.value == 0, "Cannot send ETH with token address different from 0");
            ERC20Token token = ERC20Token(_token);
            require(token.allowance(msg.sender, address(this)) >= _amount, "Allowance not set for this contract for specified amount");
            require(token.transferFrom(msg.sender, address(this), _amount), "Unsuccessful token transfer");
        }


        uint escrowId = transactions.length++;

        transactions[escrowId].seller = msg.sender;
        transactions[escrowId].buyer = _buyer;
        transactions[escrowId].token = _token;
        transactions[escrowId].amount = _amount;
        transactions[escrowId].expirationTime = _expirationTime;
        transactions[escrowId].released = false;
        transactions[escrowId].canceled = false;
        transactions[escrowId].paid = false;

        emit Created(msg.sender, _buyer, escrowId, _expirationTime, _amount);
    }

    /**
     * @notice Release escrow funds to buyer
     * @param _escrowId Id of the escrow
     * @dev Requires contract to be unpaused.
     *      Can only be executed by the seller
     *      Transaction must not be expired, or previously canceled or released
     */
    function release(uint _escrowId) public {
        require(_escrowId < transactions.length, INVALID_ESCROW_ID);

        EscrowTransaction storage trx = transactions[_escrowId];

        require(trx.seller == msg.sender, CAN_ONLY_BE_INVOKED_BY_ESCROW_OWNER);
        require(!trx.released, TRANSACTION_ALREADY_RELEASED);
        require(!trx.canceled, TRANSACTION_ALREADY_CANCELED);

        _release(_escrowId, trx);
    }

    /**
     * @dev Release funds to buyer
     * @param _escrowId Id of the escrow
     * @param trx EscrowTransaction with data of transaction to be released
     */
    function _release(uint _escrowId, EscrowTransaction storage trx) private {
        trx.released = true;

        if(trx.token == address(0)){
            trx.buyer.transfer(trx.amount); // TODO: transfer fee to Status?
        } else {
            ERC20Token token = ERC20Token(trx.token);
            require(token.transfer(trx.buyer, trx.amount));
        }

        emit Released(_escrowId);
    }

    /**
     * @dev Seller/Buyer marks transaction as paid
     * @param _escrowId Id of the escrow
     * @param _sender Address marking the transaction as paid
     */
    function _pay(address _sender, uint _escrowId) private {
        require(_escrowId < transactions.length, "Invalid escrow id");

        EscrowTransaction storage trx = transactions[_escrowId];

        require(!trx.paid, "Transaction already paid");
        require(!trx.released, "Transaction already released");
        require(!trx.canceled, "Transaction already canceled");
        require(trx.expirationTime > block.timestamp, "Transaction already expired");
        require(trx.buyer == _sender || trx.seller == _sender, "Function can only be invoked by the escrow buyer or seller");

        trx.paid = true;

        emit Paid(_escrowId);
    }

    /**
     * @notice Mark transaction as paid
     * @param _escrowId Id of the escrow
     * @dev Can only be executed by the buyer
     */
    function pay(uint _escrowId) public {
        _pay(msg.sender, _escrowId);
    }

    /**
     * @notice Obtain message hash to be signed for marking a transaction as paid
     * @param _escrowId Id of the escrow
     * @return message hash
     * @dev Once message is signed, pass it as _signature of pay(uint256,bytes)
     */
    function paySignHash(uint _escrowId) public view returns(bytes32){
        return keccak256(
            abi.encodePacked(
                address(this),
                "pay(uint256)",
                _escrowId
            )
        );
    }

    /**
     * @notice Mark transaction as paid (via signed message)
     * @param _escrowId Id of the escrow
     * @param _signature Signature of the paySignHash result.
     * @dev There's a high probability of buyers not having ether to pay for the transaction.
     *      This allows anyone to relay the transaction.
     *      TODO: consider deducting funds later on release to pay the relayer (?)
     */
    function pay(uint _escrowId, bytes calldata _signature) external {
        address sender = recoverAddress(getSignHash(paySignHash(_escrowId)), _signature);
        _pay(sender, _escrowId);
    }

    /**
     * @dev Cancel an escrow operation
     * @param _escrowId Id of the escrow
     * @notice Requires contract to be unpaused.
     *         Can only be executed by the seller
     *         Transaction must be expired, or previously canceled or released
     */
    function cancel(uint _escrowId) public whenNotPaused {
        require(_escrowId < transactions.length, INVALID_ESCROW_ID);

        EscrowTransaction storage trx = transactions[_escrowId];

        require(!trx.released, TRANSACTION_ALREADY_RELEASED);
        require(!trx.canceled, TRANSACTION_ALREADY_CANCELED);
        require(trx.seller == msg.sender, CAN_ONLY_BE_INVOKED_BY_ESCROW_OWNER);
        require(trx.expirationTime < block.timestamp, "Transaction has not expired");
        require(!trx.paid, "Cannot cancel an already paid transaction. Open a case");

        _cancel(_escrowId, trx);
    }

    /**
     * @dev Cancel transaction and send funds back to seller
     * @param _escrowId Id of the escrow
     * @param trx EscrowTransaction with details of transaction to be marked as canceled
     */
    function _cancel(uint _escrowId, EscrowTransaction storage trx) private {
        trx.canceled = true;

        if(trx.token == address(0)){
            trx.seller.transfer(trx.amount);
        } else {
            ERC20Token token = ERC20Token(trx.token);
            require(token.transfer(trx.seller, trx.amount));
        }

        emit Canceled(_escrowId);
    }

    /**
     * @dev Withdraws funds to the sellers in case of emergency
     * @param _escrowId Id of the escrow
     * @notice Requires contract to be paused.
     *         Can be executed by anyone
     *         Transaction must not be canceled or released
     */
    function withdraw_emergency(uint _escrowId) public whenPaused {
        require(_escrowId < transactions.length, INVALID_ESCROW_ID);

        EscrowTransaction storage trx = transactions[_escrowId];

        require(!trx.released, TRANSACTION_ALREADY_RELEASED);
        require(!trx.canceled, TRANSACTION_ALREADY_CANCELED);
        require(!trx.paid, "Cannot withdraw an already paid transaction. Open a case");

        _cancel(_escrowId, trx);
    }

    /**
    * @dev Fallback function
    */
    function() external {
    }

    /**
     * @dev Rates a transaction
     * @param _escrowId Id of the escrow
     * @param _rate rating of the transaction from 1 to 5
     * @notice Requires contract to not be paused.
     *         Can only be executed by the buyer
     *         Transaction must released
     */
    function rateTransaction(uint _escrowId, uint _rate) public whenNotPaused {
        require(_escrowId < transactions.length, INVALID_ESCROW_ID);
        require(_rate >= 1, "Rating needs to be at least 1");
        require(_rate <= 5, "Rating needs to be at less than or equal to 5");
        require(!arbitrationCases[_escrowId].open && arbitrationCases[_escrowId].result == ArbitrationResult.UNSOLVED, "Can't rate a transaction that has an arbitration process");

        EscrowTransaction storage trx = transactions[_escrowId];

        require(trx.rating == 0, "Transaction already rated");
        require(trx.released == true, "Transaction not released yet");
        require(trx.buyer == msg.sender, "Function can only be invoked by the escrow buyer");

        trx.rating  = _rate;
        emit Rating(trx.seller, trx.buyer, _escrowId, _rate);
    }

    modifier onlyArbitrator {
        require(isArbitrator(msg.sender), "Only arbitrators can invoke this function");
        _;
    }

    /**
     * @notice Determine if address is arbitrator
     * @param _addr Address to be verified
     * @return result
     */
    function isArbitrator(address _addr) public view returns(bool){
        return arbitrator == _addr;
    }

    /**
     * @notice Set address as arbitrator
     * @param _addr New arbitrator address
     * @dev Can only be called by the owner of the controller
     */
    function setArbitrator(address _addr) public onlyOwner {
        arbitrator = _addr;
        emit ArbitratorChanged(_addr);
    }

    /**
     * @notice Open case as a buyer or seller for arbitration
     * @param _escrowId Id of the escrow
     * @dev Consider using Aragon Court for this.
     */
    function openCase(uint _escrowId) public {
        require(!arbitrationCases[_escrowId].open && arbitrationCases[_escrowId].result == ArbitrationResult.UNSOLVED, "Case already exist");
        require(transactions[_escrowId].buyer == msg.sender || transactions[_escrowId].seller == msg.sender, "Only a buyer or seller can open a case");
        require(transactions[_escrowId].paid == true, "Cases can only be open for paid transactions");

        arbitrationCases[_escrowId] = ArbitrationCase({
            open: true,
            openBy: msg.sender,
            arbitrator: address(0),
            result: ArbitrationResult.UNSOLVED
        });

        emit ArbitrationRequired(_escrowId);
    }

    /**
     * @notice Open case as a buyer or seller for arbitration via a relay account
     * @param _escrowId Id of the escrow
     * @param _signature Signed message result of openCaseSignHash(uint256)
     * @dev Consider opening a dispute in aragon court.
     */
    function openCase(uint _escrowId, bytes calldata _signature) external {
        require(!arbitrationCases[_escrowId].open && arbitrationCases[_escrowId].result == ArbitrationResult.UNSOLVED, "Case already exist");
        require(transactions[_escrowId].paid == true, "Cases can only be open for paid transactions");

        address senderAddress = recoverAddress(getSignHash(openCaseSignHash(_escrowId)), _signature);

        require(transactions[_escrowId].buyer == senderAddress || transactions[_escrowId].seller == senderAddress, "Only a buyer or seller can open a case");

        arbitrationCases[_escrowId] = ArbitrationCase({
            open: true,
            openBy: msg.sender,
            arbitrator: address(0),
            result: ArbitrationResult.UNSOLVED
        });

        emit ArbitrationRequired(_escrowId);
    }

    /**
     * @notice Set arbitration result in favour of the buyer or seller and transfer funds accordingly
     * @param _escrowId Id of the escrow
     * @param _result Result of the arbitration
     */
    function setArbitrationResult(uint _escrowId, ArbitrationResult _result) public onlyArbitrator {
        require(arbitrationCases[_escrowId].open && arbitrationCases[_escrowId].result == ArbitrationResult.UNSOLVED, "Case must be open and unsolved");
        require(_result != ArbitrationResult.UNSOLVED, "Arbitration does not have result");

        EscrowTransaction storage trx = transactions[_escrowId];

        require(trx.buyer != arbitrator && trx.seller != arbitrator, "Arbitrator cannot be part of transaction");

        arbitrationCases[_escrowId].open = false;
        arbitrationCases[_escrowId].result = _result;

        // TODO: incentive mechanism for opening arbitration process
        // if(arbitrationCases[_escrowId].openBy != trx.seller || arbitrationCases[_escrowId].openBy != trx.buyer){
            // Consider deducting a fee as reward for whoever opened the arbitration process.
        // }

        emit ArbitrationResolved(_escrowId, _result, msg.sender);

        if(_result == ArbitrationResult.BUYER){
            _release(_escrowId, trx);
        } else {
            _cancel(_escrowId, trx);
        }
    }

    /**
     * @notice Obtain message hash to be signed for opening a case
     * @param _escrowId Id of the escrow
     * @return message hash
     * @dev Once message is signed, pass it as _signature of openCase(uint256,bytes)
     */
    function openCaseSignHash(uint _escrowId) public view returns(bytes32){
        return keccak256(
            abi.encodePacked(
                address(this),
                "openCase(uint256)",
                _escrowId
            )
        );
    }
}
