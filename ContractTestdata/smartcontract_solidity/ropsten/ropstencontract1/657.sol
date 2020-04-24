/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.4.24;

// File: /Users/sherazarshad/Documents/iFunded/new security token/security-token/contracts/ERC20/IERC20.sol

contract IERC20 {
    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) external view returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) external returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) external returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);

    // solhint-disable-next-line no-simple-event-func-name
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

// File: /Users/sherazarshad/Documents/iFunded/new security token/security-token/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
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
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: /Users/sherazarshad/Documents/iFunded/new security token/security-token/contracts/math/KindMath.sol

/**
 * @title KindMath
 * @notice ref. https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/math/SafeMath.sol
 * @dev Math operations with safety checks that returns boolean
 */
library KindMath {

    /**
     * @dev Multiplies two numbers, return false on overflow.
     */
    function checkMul(uint256 a, uint256 b) internal pure returns (bool) {
        // Gas optimization: this is cheaper than requireing 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return true;
        }

        uint256 c = a * b;
        if (c / a == b)
            return true;
        else 
            return false;
    }

    /**
    * @dev Subtracts two numbers, return false on overflow (i.e. if subtrahend is greater than minuend).
    */
    function checkSub(uint256 a, uint256 b) internal pure returns (bool) {
        if (b <= a)
            return true;
        else
            return false;
    }

    /**
    * @dev Adds two numbers, return false on overflow.
    */
    function checkAdd(uint256 a, uint256 b) internal pure returns (bool) {
        uint256 c = a + b;
        if (c < a)
            return false;
        else
            return true;
    }
}

// File: /Users/sherazarshad/Documents/iFunded/new security token/security-token/contracts/ERC1410/ERC1410Basic.sol

contract ERC1410Basic {

    using SafeMath for uint256;

    // Represents a fungible set of tokens.
    struct Partition {
        uint256 amount;
        bytes32 partition;
    }

    uint256 _totalSupply;

    // Mapping from investor to aggregated balance across all investor token sets
    mapping (address => uint256) balances;

    // Mapping from investor to their partitions
    mapping (address => Partition[]) partitions;

    // Mapping from (investor, partition) to index of corresponding partition in partitions
    // @dev Stored value is always greater by 1 to avoid the 0 value of every index
    mapping (address => mapping (bytes32 => uint256)) partitionToIndex;

    event TransferByPartition(
        bytes32 indexed _fromPartition,
        address _operator,
        address indexed _from,
        address indexed _to,
        uint256 _value,
        bytes _data,
        bytes _operatorData
    );

    /**
     * @dev Total number of tokens in existence
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /// @notice Counts the sum of all partitions balances assigned to an owner
    /// @param _tokenHolder An address for whom to query the balance
    /// @return The number of tokens owned by `_tokenHolder`, possibly zero
    function balanceOf(address _tokenHolder) external view returns (uint256) {
        return balances[_tokenHolder];
    }

    /// @notice Counts the balance associated with a specific partition assigned to an tokenHolder
    /// @param _partition The partition for which to query the balance
    /// @param _tokenHolder An address for whom to query the balance
    /// @return The number of tokens owned by `_tokenHolder` with the metadata associated with `_partition`, possibly zero
    function balanceOfByPartition(bytes32 _partition, address _tokenHolder) external view returns (uint256) {
        if (_validPartition(_partition, _tokenHolder))
            return partitions[_tokenHolder][partitionToIndex[_tokenHolder][_partition] - 1].amount;
        else
            return 0;
    }

    /// @notice Use to get the list of partitions `_tokenHolder` is associated with
    /// @param _tokenHolder An address corresponds whom partition list is queried
    /// @return List of partitions
    function partitionsOf(address _tokenHolder) external view returns (bytes32[]) {
        bytes32[] memory partitionsList = new bytes32[](partitions[_tokenHolder].length);
        for (uint256 i = 0; i < partitions[_tokenHolder].length; i++) {
            partitionsList[i] = partitions[_tokenHolder][i].partition;
        } 
        return partitionsList;
    }

    /// @notice Transfers the ownership of tokens from a specified partition from one address to another address
    /// @param _partition The partition from which to transfer tokens
    /// @param _to The address to which to transfer tokens to
    /// @param _value The amount of tokens to transfer from `_partition`
    /// @param _data Additional data attached to the transfer of tokens
    /// @return The partition to which the transferred tokens were allocated for the _to address
    function transferByPartition(bytes32 _partition, address _to, uint256 _value, bytes _data) internal returns (bytes32) {
        // Add a function to verify the `_data` parameter
        // TODO: Need to create the bytes division of the `_partition` so it can be easily findout in which receiver's partition
        // token will transfered. For current implementation we are assuming that the receiver's partition will be same as sender's
        // as well as it also pass the `_validPartition()` check. In this particular case we are also assuming that reciever has the
        // some tokens of the same partition as well (To avoid the array index out of bound error).
        // Note- There is no operator used for the execution of this call so `_operator` value in
        // in event is address(0) same for the `_operatorData`
        _transferByPartition(msg.sender, _to, _value, _partition, _data, address(0), "");
    }

    /// @notice The standard provides an on-chain function to determine whether a transfer will succeed,
    /// and return details indicating the reason if the transfer is not valid.
    /// @param _from The address from whom the tokens get transferred.
    /// @param _to The address to which to transfer tokens to.
    /// @param _partition The partition from which to transfer tokens
    /// @param _value The amount of tokens to transfer from `_partition`
    /// @param _data Additional data attached to the transfer of tokens
    /// @return ESC (Ethereum Status Code) following the EIP-1066 standard
    /// @return Application specific reason codes with additional details
    /// @return The partition to which the transferred tokens were allocated for the _to address
    function canTransferByPartition(address _from, address _to, bytes32 _partition, uint256 _value, bytes _data) internal view returns (byte, bytes32, bytes32) {
        // TODO: Applied the check over the `_data` parameter
        if (!_validPartition(_partition, _from))
            return (0x50, "Partition not exists", bytes32(""));
        else if (partitions[_from][partitionToIndex[_from][_partition]].amount < _value)
            return (0x52, "Insufficent balance", bytes32(""));
        else if (_to == address(0))
            return (0x57, "Invalid receiver", bytes32(""));
        else if (!KindMath.checkSub(balances[_from], _value) || !KindMath.checkAdd(balances[_to], _value))
            return (0x50, "Overflow", bytes32(""));
        
        // Call function to get the receiver's partition. For current implementation returning the same as sender's
        return (0x51, "Success", _partition);
    }

    function _transferByPartition(address _from, address _to, uint256 _value, bytes32 _partition, bytes _data, address _operator, bytes _operatorData) internal {
        require(_validPartition(_partition, _from), "Invalid partition"); 
        require(partitions[_from][partitionToIndex[_from][_partition] - 1].amount >= _value, "Insufficient balance");
        require(_to != address(0), "0x address not allowed");
        uint256 _fromIndex = partitionToIndex[_from][_partition] - 1;
        uint256 _toIndex = partitionToIndex[_to][_partition] - 1;
        
        // Changing the state values
        partitions[_from][_fromIndex].amount = partitions[_from][_fromIndex].amount.sub(_value);
        balances[_from] = balances[_from].sub(_value);
        partitions[_to][_toIndex].amount = partitions[_to][_toIndex].amount.add(_value);
        balances[_to] = balances[_to].add(_value);
        // Emit transfer event.
        emit TransferByPartition(_partition, _operator, _from, _to, _value, _data, _operatorData);
    }

    function _validPartition(bytes32 _partition, address _holder) internal view returns(bool) {
        if (partitions[_holder].length < partitionToIndex[_holder][_partition] || partitionToIndex[_holder][_partition] == 0)
            return false;
        else
            return true;
    }



}

// File: /Users/sherazarshad/Documents/iFunded/new security token/security-token/contracts/ERC1410/ERC1410Operator.sol

contract ERC1410Operator is ERC1410Basic {

    // Mapping from (investor, partition, operator) to approved status
    mapping (address => mapping (bytes32 => mapping (address => bool))) partitionApprovals;

    // Mapping from (investor, operator) to approved status (can be used against any partition)
    mapping (address => mapping (address => bool)) approvals;

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
    event RevokedOperator(address indexed operator, address indexed tokenHolder);

    event AuthorizedOperatorByPartition(bytes32 indexed partition, address indexed operator, address indexed tokenHolder);
    event RevokedOperatorByPartition(bytes32 indexed partition, address indexed operator, address indexed tokenHolder);

    /// @notice Determines whether `_operator` is an operator for all partitions of `_tokenHolder`
    /// @param _operator The operator to check
    /// @param _tokenHolder The token holder to check
    /// @return Whether the `_operator` is an operator for all partitions of `_tokenHolder`
    function isOperator(address _operator, address _tokenHolder) public view returns (bool) {
        return approvals[_tokenHolder][_operator];
    }

    /// @notice Determines whether `_operator` is an operator for a specified partition of `_tokenHolder`
    /// @param _partition The partition to check
    /// @param _operator The operator to check
    /// @param _tokenHolder The token holder to check
    /// @return Whether the `_operator` is an operator for a specified partition of `_tokenHolder`
    function isOperatorForPartition(bytes32 _partition, address _operator, address _tokenHolder) public view returns (bool) {
        return partitionApprovals[_tokenHolder][_partition][_operator];
    }

    ///////////////////////
    /// Operator Management
    ///////////////////////

    /// @notice Authorises an operator for all partitions of `msg.sender`
    /// @param _operator An address which is being authorised
    function authorizeOperator(address _operator) external {
        approvals[msg.sender][_operator] = true;
        emit AuthorizedOperator(_operator, msg.sender);
    }

    /// @notice Revokes authorisation of an operator previously given for all partitions of `msg.sender`
    /// @param _operator An address which is being de-authorised
    function revokeOperator(address _operator) external {
        approvals[msg.sender][_operator] = false;
        emit RevokedOperator(_operator, msg.sender);
    }

    /// @notice Authorises an operator for a given partition of `msg.sender`
    /// @param _partition The partition to which the operator is authorised
    /// @param _operator An address which is being authorised
    function authorizeOperatorByPartition(bytes32 _partition, address _operator) external {
        partitionApprovals[msg.sender][_partition][_operator] = true;
        emit AuthorizedOperatorByPartition(_partition, _operator, msg.sender);
    }

    /// @notice Revokes authorisation of an operator previously given for a specified partition of `msg.sender`
    /// @param _partition The partition to which the operator is de-authorised
    /// @param _operator An address which is being de-authorised
    function revokeOperatorByPartition(bytes32 _partition, address _operator) external {
        partitionApprovals[msg.sender][_partition][_operator] = false;
        emit RevokedOperatorByPartition(_partition, _operator, msg.sender);
    }

    /// @notice Transfers the ownership of tokens from a specified partition from one address to another address
    /// @param _partition The partition from which to transfer tokens
    /// @param _from The address from which to transfer tokens from
    /// @param _to The address to which to transfer tokens to
    /// @param _value The amount of tokens to transfer from `_partition`
    /// @param _data Additional data attached to the transfer of tokens
    /// @param _operatorData Additional data attached to the transfer of tokens by the operator
    /// @return The partition to which the transferred tokens were allocated for the _to address
    function operatorTransferByPartition(bytes32 _partition, address _from, address _to, uint256 _value, bytes _data, bytes _operatorData) internal returns (bytes32) {
        // TODO: Add a functionality of verifying the `_operatorData`
        // TODO: Add a functionality of verifying the `_data`
        require(
            isOperator(msg.sender, _from) || isOperatorForPartition(_partition, msg.sender, _from),
            "Not authorised"
        );
        _transferByPartition(_from, _to, _value, _partition, _data, msg.sender, _operatorData);
    }

}

// File: /Users/sherazarshad/Documents/iFunded/new security token/security-token/contracts/ERC1410/IERC1410.sol

interface IERC1410 {

    // Token Information
    function balanceOf(address _tokenHolder) external view returns (uint256);
    function balanceOfByPartition(bytes32 _partition, address _tokenHolder) external view returns (uint256);
    function partitionsOf(address _tokenHolder) external view returns (bytes32[]);
    function totalSupply() external view returns (uint256);

    // Token Transfers
    function transferByPartition(bytes32 _partition, address _to, uint256 _value, bytes _data) external returns (bytes32);
    function operatorTransferByPartition(bytes32 _partition, address _from, address _to, uint256 _value, bytes _data, bytes _operatorData) external returns (bytes32);
    function canTransferByPartition(address _from, address _to, bytes32 _partition, uint256 _value, bytes _data) external view returns (byte, bytes32, bytes32);    

    // Operator Information
    function isOperator(address _operator, address _tokenHolder) external view returns (bool);
    function isOperatorForPartition(bytes32 _partition, address _operator, address _tokenHolder) external view returns (bool);

    // Operator Management
    function authorizeOperator(address _operator) external;
    function revokeOperator(address _operator) external;
    function authorizeOperatorByPartition(bytes32 _partition, address _operator) external;
    function revokeOperatorByPartition(bytes32 _partition, address _operator) external;

    // Issuance / Redemption
    function issueByPartition(bytes32 _partition, address _tokenHolder, uint256 _value, bytes _data) external;
    function redeemByPartition(bytes32 _partition, uint256 _value, bytes _data) external;
    function operatorRedeemByPartition(bytes32 _partition, address _tokenHolder, uint256 _value, bytes _data, bytes _operatorData) external;

    // Transfer Events
    event TransferByPartition(
        bytes32 indexed _fromPartition,
        address _operator,
        address indexed _from,
        address indexed _to,
        uint256 _value,
        bytes _data,
        bytes _operatorData
    );

    // Operator Events
    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
    event RevokedOperator(address indexed operator, address indexed tokenHolder);
    event AuthorizedOperatorByPartition(bytes32 indexed partition, address indexed operator, address indexed tokenHolder);
    event RevokedOperatorByPartition(bytes32 indexed partition, address indexed operator, address indexed tokenHolder);

    // Issuance / Redemption Events
    event IssuedByPartition(bytes32 indexed partition, address indexed to, uint256 value, bytes data);
    event RedeemedByPartition(bytes32 indexed partition, address indexed operator, address indexed from, uint256 value, bytes data, bytes operatorData);

}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: /Users/sherazarshad/Documents/iFunded/new security token/security-token/contracts/ERC1410/ERC1410Standard.sol

contract ERC1410Standard is IERC1410, ERC1410Operator, Ownable {

    /// @notice Increases totalSupply and the corresponding amount of the specified owners partition
    /// @param _partition The partition to allocate the increase in balance
    /// @param _tokenHolder The token holder whose balance should be increased
    /// @param _value The amount by which to increase the balance
    /// @param _data Additional data attached to the minting of tokens
    function issueByPartition(bytes32 _partition, address _tokenHolder, uint256 _value, bytes _data) internal onlyOwner {
        // Add the function to validate the `_data` parameter
        _validateParams(_partition, _value);
        require(_tokenHolder != address(0), "Invalid token receiver");
        uint256 index = partitionToIndex[_tokenHolder][_partition];
        if (index == 0) {
            partitions[_tokenHolder].push(Partition(_value, _partition));
            partitionToIndex[_tokenHolder][_partition] = partitions[_tokenHolder].length;
        } else {
            partitions[_tokenHolder][index - 1].amount = partitions[_tokenHolder][index - 1].amount.add(_value);
        }
        _totalSupply = _totalSupply.add(_value);
        balances[_tokenHolder] = balances[_tokenHolder].add(_value);
        emit IssuedByPartition(_partition, _tokenHolder, _value, _data);
    }

    /// @notice Decreases totalSupply and the corresponding amount of the specified partition of msg.sender
    /// @param _partition The partition to allocate the decrease in balance
    /// @param _value The amount by which to decrease the balance
    /// @param _data Additional data attached to the burning of tokens
    function redeemByPartition(bytes32 _partition, uint256 _value, bytes _data) external {
        // Add the function to validate the `_data` parameter
        //_redeemByPartition(_partition, msg.sender, address(0), _value, _data, "");
    }

    /// @notice Decreases totalSupply and the corresponding amount of the specified partition of tokenHolder
    /// @dev This function can only be called by the authorised operator.
    /// @param _partition The partition to allocate the decrease in balance.
    /// @param _tokenHolder The token holder whose balance should be decreased
    /// @param _value The amount by which to decrease the balance
    /// @param _data Additional data attached to the burning of tokens
    /// @param _operatorData Additional data attached to the transfer of tokens by the operator
    function operatorRedeemByPartition(bytes32 _partition, address _tokenHolder, uint256 _value, bytes _data, bytes _operatorData) external {
        // Add the function to validate the `_data` parameter
        // TODO: Add a functionality of verifying the `_operatorData`
        require(_tokenHolder != address(0), "Invalid from address");
        require(
            isOperator(msg.sender, _tokenHolder) || isOperatorForPartition(_partition, msg.sender, _tokenHolder),
            "Not authorised"
        );
        _redeemByPartition(_partition, _tokenHolder, msg.sender, _value, _data, _operatorData);
    }

    function _redeemByPartition(bytes32 _partition, address _from, address _operator, uint256 _value, bytes _data, bytes _operatorData) internal {
        // Add the function to validate the `_data` parameter
        _validateParams(_partition, _value);
        require(_validPartition(_partition, _from), "Invalid partition");
        uint256 index = partitionToIndex[_from][_partition] - 1;
        require(partitions[_from][index].amount >= _value, "Insufficient value");
        if (partitions[_from][index].amount == _value) {
            _deletePartitionForHolder(_from, _partition, index);
        } else {
            partitions[_from][index].amount = partitions[_from][index].amount.sub(_value);
        }
        balances[_from] = balances[_from].sub(_value);
        _totalSupply = _totalSupply.sub(_value);
        emit RedeemedByPartition(_partition, _operator, _from, _value, _data, _operatorData);
    }

    function _deletePartitionForHolder(address _holder, bytes32 _partition, uint256 index) internal {
        if (index != partitions[_holder].length -1) {
            partitions[_holder][index] = partitions[_holder][partitions[_holder].length -1];
            partitionToIndex[_holder][partitions[_holder][index].partition] = index + 1;
        }
        delete partitionToIndex[_holder][_partition];
        partitions[_holder].length--;
    }

    function _validateParams(bytes32 _partition, uint256 _value) internal pure {
        require(_value != uint256(0), "Zero value not allowed");
        require(_partition != bytes32(0), "Invalid partition");
    }

}

// File: /Users/sherazarshad/Documents/iFunded/new security token/security-token/contracts/ERC1644/IERC1644.sol

interface IERC1644 {

    // Controller Operation
    function isControllable() external view returns (bool);
    function controllerTransfer(address _from, address _to, uint256 _value, bytes _data, bytes _operatorData) external;
    function controllerRedeem(address _tokenHolder, uint256 _value, bytes _data, bytes _operatorData) external;

    // Controller Events
    event ControllerTransfer(
        address _controller,
        address indexed _from,
        address indexed _to,
        uint256 _value,
        bytes _data,
        bytes _operatorData
    );

    event ControllerRedemption(
        address _controller,
        address indexed _tokenHolder,
        uint256 _value,
        bytes _data,
        bytes _operatorData
    );

}

// File: /Users/sherazarshad/Documents/iFunded/new security token/security-token/contracts/ERC1644/ERC1644Controllable.sol

/**
 * @title ERC1644Controllable contract which contains the authorization functions
 * functions related to the controller.
 */
contract ERC1644Controllable is Ownable {

    // Address of the controller which is a delegated entity
    // set by the issuer/owner of the token
    address public controller;

    // Event emitted when controller features will no longer in use
    event FinalizedControllerFeature();

    // Modifier to check whether the msg.sender is authorised or not 
    modifier onlyController() {
        require(msg.sender == controller, "Not Authorised");
        _;
    }

    /**
     * @notice constructor 
     * @dev Used to intialize the controller variable. 
     * `_controller` it can be zero address as well it means
     * controller functions will revert
     * @param _controller Address of the controller delegated by the issuer
     */
    constructor(address _controller) public {
        // Below condition is to restrict the owner/issuer to become the controller as well in ideal world.
        // But for non ideal case issuer could set another address which is not the owner of the token
        // but issuer holds its private key.
        require(_controller != msg.sender);
        controller = _controller;
    }

    /**
     * @notice It is used to end the controller feature from the token
     * @dev It only be called by the `owner/issuer` of the token
     */
    function finalizeControllable() external onlyOwner {
        require(controller != address(0), "Already finalized");
        controller = address(0);
        emit FinalizedControllerFeature();
    }

    /**
     * @notice Internal function to know whether the controller functionality
     * allowed or not.
     * @return bool `true` when controller address is non-zero otherwise return `false`.
     */
    function _isControllable() internal view returns (bool) {
        if (controller == address(0))
            return false;
        else
            return true;
    }

}

// File: /Users/sherazarshad/Documents/iFunded/new security token/security-token/contracts/ERC1644/ERC1644.sol

/**
 * @title Standard ERC1644 token
 */
contract ERC1644 is ERC1644Controllable, IERC1644 {

    
    /**
     * @notice constructor 
     * @dev Used to intialize the controller variable. 
     * `_controller` it can be zero address as well it means
     * controller functions will revert
     * @param _controller Address of the controller delegated by the issuer
     */
    constructor(address _controller)
    public 
    ERC1644Controllable(_controller)
    {

    }

    /**
     * @notice In order to provide transparency over whether `controllerTransfer` / `controllerRedeem` are useable
     * or not `isControllable` function will be used.
     * @dev If `isControllable` returns `false` then it always return `false` and
     * `controllerTransfer` / `controllerRedeem` will always revert.
     * @return bool `true` when controller address is non-zero otherwise return `false`.
     */
    function isControllable() external view returns (bool) {
        return _isControllable();
    }

    // /**
    //  * @notice This function allows an authorised address to transfer tokens between any two token holders.
    //  * The transfer must still respect the balances of the token holders (so the transfer must be for at most
    //  * `balanceOf(_from)` tokens) and potentially also need to respect other transfer restrictions.
    //  * @dev This function can only be executed by the `controller` address.
    //  * @param _from Address The address which you want to send tokens from
    //  * @param _to Address The address which you want to transfer to
    //  * @param _value uint256 the amount of tokens to be transferred
    //  * @param _data data to validate the transfer. (It is not used in this reference implementation
    //  * because use of `_data` parameter is implementation specific).
    //  * @param _operatorData data attached to the transfer by controller to emit in event. (It is more like a reason string 
    //  * for calling this function (aka force transfer) which provides the transparency on-chain). 
    //  */
    // function controllerTransfer(address _from, address _to, uint256 _value, bytes _data, bytes _operatorData) external onlyController {
    //     _transfer(_from, _to, _value);
    //     emit ControllerTransfer(msg.sender, _from, _to, _value, _data, _operatorData);
    // }

    // /**
    //  * @notice This function allows an authorised address to redeem tokens for any token holder.
    //  * The redemption must still respect the balances of the token holder (so the redemption must be for at most
    //  * `balanceOf(_tokenHolder)` tokens) and potentially also need to respect other transfer restrictions.
    //  * @dev This function can only be executed by the `controller` address.
    //  * @param _tokenHolder The account whose tokens will be redeemed.
    //  * @param _value uint256 the amount of tokens need to be redeemed.
    //  * @param _data data to validate the transfer. (It is not used in this reference implementation
    //  * because use of `_data` parameter is implementation specific).
    //  * @param _operatorData data attached to the transfer by controller to emit in event. (It is more like a reason string 
    //  * for calling this function (aka force transfer) which provides the transparency on-chain). 
    //  */
    // function controllerRedeem(address _tokenHolder, uint256 _value, bytes _data, bytes _operatorData) external onlyController {
    //     _burn(_tokenHolder, _value);
    //     emit ControllerRedemption(msg.sender, _tokenHolder, _value, _data, _operatorData);
    // }

}

// File: /Users/sherazarshad/Documents/iFunded/new security token/security-token/contracts/ERC1643/IERC1643.sol

// @title IERC1643 Document Management (part of the ERC1400 Security Token Standards)
/// @dev See https://github.com/SecurityTokenStandard/EIP-Spec

interface IERC1643 {

    // Document Management
    function getDocument(bytes32 _name) external view returns (string, bytes32, uint256);
    function setDocument(bytes32 _name, string _uri, bytes32 _documentHash) external;
    function removeDocument(bytes32 _name) external;
    function getAllDocuments() external view returns (bytes32[]);

    // Document Events
    event DocumentRemoved(bytes32 indexed _name, string _uri, bytes32 _documentHash);
    event DocumentUpdated(bytes32 indexed _name, string _uri, bytes32 _documentHash);

}

// File: /Users/sherazarshad/Documents/iFunded/new security token/security-token/contracts/ERC1643/ERC1643.sol

/**
 * @title Standard implementation of ERC1643 Document management
 */
contract ERC1643 is IERC1643, Ownable {

    struct Document {
        bytes32 docHash; // Hash of the document
        uint256 lastModified; // Timestamp at which document details was last modified
        string uri; // URI of the document that exist off-chain
    }

    // mapping to store the documents details in the document
    mapping(bytes32 => Document) internal _documents;
    // mapping to store the document name indexes
    mapping(bytes32 => uint256) internal _docIndexes;
    // Array use to store all the document name present in the contracts
    bytes32[] _docNames;
    
    /// Constructor
    constructor() public {

    }
    
    /**
     * @notice Used to attach a new document to the contract, or update the URI or hash of an existing attached document
     * @dev Can only be executed by the owner of the contract.
     * @param _name Name of the document. It should be unique always
     * @param _uri Off-chain uri of the document from where it is accessible to investors/advisors to read.
     * @param _documentHash hash (of the contents) of the document.
     */
    function setDocument(bytes32 _name, string _uri, bytes32 _documentHash) external onlyOwner {
        require(_name != bytes32(0), "Zero value is not allowed");
        require(bytes(_uri).length > 0, "Should not be a empty uri");
        if (_documents[_name].lastModified == uint256(0)) {
            _docNames.push(_name);
            _docIndexes[_name] = _docNames.length;
        }
        _documents[_name] = Document(_documentHash, now, _uri);
        emit DocumentUpdated(_name, _uri, _documentHash);
    }

    /**
     * @notice Used to remove an existing document from the contract by giving the name of the document.
     * @dev Can only be executed by the owner of the contract.
     * @param _name Name of the document. It should be unique always
     */
    function removeDocument(bytes32 _name) external onlyOwner {
        require(_documents[_name].lastModified != uint256(0), "Document should be existed");
        uint256 index = _docIndexes[_name] - 1;
        if (index != _docNames.length - 1) {
            _docNames[index] = _docNames[_docNames.length - 1];
            _docIndexes[_docNames[index]] = index + 1; 
        }
        _docNames.length--;
        emit DocumentRemoved(_name, _documents[_name].uri, _documents[_name].docHash);
        delete _documents[_name];
    }

    /**
     * @notice Used to return the details of a document with a known name (`bytes32`).
     * @param _name Name of the document
     * @return string The URI associated with the document.
     * @return bytes32 The hash (of the contents) of the document.
     * @return uint256 the timestamp at which the document was last modified.
     */
    function getDocument(bytes32 _name) external view returns (string, bytes32, uint256) {
        return (
            _documents[_name].uri,
            _documents[_name].docHash,
            _documents[_name].lastModified
        );
    }

    /**
     * @notice Used to retrieve a full list of documents attached to the smart contract.
     * @return bytes32 List of all documents names present in the contract.
     */
    function getAllDocuments() external view returns (bytes32[]) {
        return _docNames;
    }

}

// File: /Users/sherazarshad/Documents/iFunded/new security token/security-token/contracts/Pausable/IPausable.sol

interface IPausable {
    function pause() external returns (bool);
    function unpause() external returns (bool);

    event Paused(address account);
    event Unpaused(address account);
}

// File: /Users/sherazarshad/Documents/iFunded/new security token/security-token/contracts/Pausable/Pausable.sol

contract Pausable is IPausable, Ownable {
    bool public paused;

    function pause() external onlyOwner returns (bool) {
        require(!paused, "Token is already paused");
        paused = true;
    }

    function unpause() external onlyOwner returns (bool) {
        require(paused, "Token is already unpaused");
        paused = false;
    }

    function isPaused() internal view returns (bool) {
        return paused;
    }

}

// File: /Users/sherazarshad/Documents/iFunded/new security token/security-token/contracts/Whitelist/IWhitelist.sol

interface IWhitelist {

      /**
     *  This event is emitted when a verified address and associated identity hash are
     *  added to the contract.
     *  @param addr The address that was added.
     *  @param hash The identity hash associated with the address.
     *  @param sender The address that caused the address to be added.
     */
    event VerifiedAddressAdded(
        address indexed addr,
        bytes32 hash,
        address indexed sender
    );

    /**
     *  This event is emitted when a verified address its associated identity hash are
     *  removed from the contract.
     *  @param addr The address that was removed.
     *  @param sender The address that caused the address to be removed.
     */
    event VerifiedAddressRemoved(address indexed addr, address indexed sender);

    /**
     *  This event is emitted when the identity hash associated with a verified address is updated.
     *  @param addr The address whose hash was updated.
     *  @param oldHash The identity hash that was associated with the address.
     *  @param hash The hash now associated with the address.
     *  @param sender The address that caused the hash to be updated.
     */
    event VerifiedAddressUpdated(
        address indexed addr,
        bytes32 oldHash,
        bytes32 hash,
        address indexed sender
    );

        /**
     *  Add a verified address, along with an associated verification hash to the contract.
     *  Upon successful addition of a verified address, the contract must emit
     *  `VerifiedAddressAdded(addr, hash, msg.sender)`.
     *  It MUST throw if the supplied address or hash are zero, or if the address has already been supplied.
     *  @param addr The address of the person represented by the supplied hash.
     *  @param hash A cryptographic hash of the address holder's verified information.
     */
    function addVerified(address addr, bytes32 hash) external;
    


    /**
     *  Remove a verified address, and the associated verification hash. If the address is
     *  unknown to the contract then this does nothing. If the address is successfully removed, this
     *  function must emit `VerifiedAddressRemoved(addr, msg.sender)`.
     *  It MUST throw if an attempt is made to remove a verifiedAddress that owns Tokens.
     *  @param addr The verified address to be removed.
     */
    function removeVerified(address addr) external;
    

     /**
     *  Update the hash for a verified address known to the contract.
     *  Upon successful update of a verified address the contract must emit
     *  `VerifiedAddressUpdated(addr, oldHash, hash, msg.sender)`.
     *  If the hash is the same as the value already stored then
     *  no `VerifiedAddressUpdated` event is to be emitted.
     *  It MUST throw if the hash is zero, or if the address is unverified.
     *  @param addr The verified address of the person represented by the supplied hash.
     *  @param hash A new cryptographic hash of the address holder's updated verified information.
     */
    function updateVerified(address addr, bytes32 hash) external;

    function hasHash(address addr, bytes32 hash) external;

    function isVerifiedReceiver(address addr) external returns(byte);
    function isVerifiedSender(address addr) external returns(byte);
}

// File: contracts/SecurityToken.sol

contract SecurityToken is IERC20, ERC1410Standard, ERC1644, ERC1643, Pausable {
    
    IWhitelist public whitelist;
    mapping (address => mapping (address => uint256)) internal _allowed;

    bytes32 public defaultPartition = "Default";

    constructor(address _owner, address _controller, address _whitelist_address) public ERC1644(_controller) {
        whitelist = IWhitelist(_whitelist_address);
        transferOwnership(_owner);
    }

    function controllerTransfer(address _from, address _to, uint256 _value, bytes _data, bytes _operatorData) external onlyController {
        _transferByPartition(_from, _to, _value, defaultPartition, _data, msg.sender, _operatorData);
    }

    function controllerRedeem(address _tokenHolder, uint256 _value, bytes _data, bytes _operatorData) external onlyController {
        _redeemByPartition(defaultPartition, _tokenHolder, msg.sender, _value, _data, _operatorData);
    }


    function transfer(address _to, uint256 _value) external returns (bool success) {
        transferByPartition(defaultPartition, _to, _value, "");
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) {  
        require( isOperator(msg.sender, _from) || (_value <= _allowed[_from][msg.sender]), "Not enough allowance");

        if(_allowed[_from][msg.sender] >= _value) {
            _allowed[_from][msg.sender] = _allowed[_from][msg.sender].sub(_value);
        } else {
            _allowed[_from][msg.sender] = 0;
        }

        operatorTransferByPartition(defaultPartition, _from, _to, _value, "", "");
    }

    function approve(address spender, uint256 value) external returns (bool) {
        require(spender != address(0), "spender address is invalid");
        _allowed[msg.sender][spender] = value;
        approvals[msg.sender][spender] = true;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowed[owner][spender];
    }



    function issueByPartition(bytes32 _partition, address _tokenHolder, uint256 _value, bytes _data) external onlyOwner {
        byte status = whitelist.isVerifiedReceiver(_tokenHolder);
        require(status == hex"01", "Invalid Receiver.");

        super.issueByPartition(_partition, _tokenHolder, _value, _data);
    }

    function transferByPartition(bytes32 _partition, address _to, uint256 _value, bytes _data) external returns (bytes32) {
        require(!isPaused(), "Token is paused.");
        
        byte status;
        status = whitelist.isVerifiedReceiver(_to);
        require(status == hex"01", "Invalid receiver.");

        status = whitelist.isVerifiedSender(msg.sender);
        require(status == hex"01", "Invalid sender.");

        super.transferByPartition(_partition, _to, _value, _data);

    }

    function canTransferByPartition(address _from, address _to, bytes32 _partition, uint256 _value, bytes _data) external view returns (byte, bytes32, bytes32) {
        require(!isPaused(), "Token is paused.");
        
        byte status;
        status = whitelist.isVerifiedReceiver(_to);
        require(status == hex"01", "Invalid receiver.");

        status = whitelist.isVerifiedSender(_from);
        require(status == hex"01", "Invalid sender.");
        return super.canTransferByPartition(_from, _to, _partition, _value, _data);
    }

    function operatorTransferByPartition(bytes32 _partition, address _from, address _to, uint256 _value, bytes _data, bytes _operatorData) external returns (bytes32) {
        require(!isPaused(), "Token is paused.");
        
        byte status;
        status = whitelist.isVerifiedReceiver(_to);
        require(status == hex"01", "Invalid receiver.");

        status = whitelist.isVerifiedSender(_from);
        require(status == hex"01", "Invalid sender.");

        return super.operatorTransferByPartition(_partition, _from, _to, _value, _data, _operatorData);
    }

}
