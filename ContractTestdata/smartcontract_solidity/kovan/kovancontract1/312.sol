/**
 *Submitted for verification at Etherscan.io on 2019-02-07
*/

pragma solidity ^0.5.0;

// File: openzeppelin-solidity/contracts/cryptography/ECDSA.sol

/**
 * @title Elliptic curve signature operations
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 * TODO Remove this library once solidity supports passing a signature to ecrecover.
 * See https://github.com/ethereum/solidity/issues/864
 */

library ECDSA {
    /**
     * @dev Recover signer address from a message by using their signature
     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param signature bytes signature, the signature is generated using web3.eth.sign()
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    /**
     * toEthSignedMessageHash
     * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
     * and hash the result
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

// File: /home/akru/devel/cdex/node_modules/openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: /home/akru/devel/cdex/node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure.
 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        require(token.transfer(to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        require(token.transferFrom(from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require((value == 0) || (token.allowance(msg.sender, spender) == 0));
        require(token.approve(spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        require(token.approve(spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value);
        require(token.approve(spender, newAllowance));
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood:
 * https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 *
 * This implementation emits additional Approval events, allowing applications to reconstruct the allowance status for
 * all accounts just by listening to said events. Note that this isn't required by the specification, and other
 * compliant implementations may not do it.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowed;

    uint256 private _totalSupply;

    /**
    * @dev Total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param owner The address to query the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev Function to check the amount of tokens that an owner allowed to a spender.
     * @param owner address The address which owns the funds.
     * @param spender address The address which will spend the funds.
     * @return A uint256 specifying the amount of tokens still available for the spender.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowed[owner][spender];
    }

    /**
    * @dev Transfer token for a specified address
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * Beware that changing an allowance with this method brings the risk that someone may use both the old
     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
     * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     * @param spender The address which will spend the funds.
     * @param value The amount of tokens to be spent.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Transfer tokens from one address to another.
     * Note that while this function emits an Approval event, this is not required as per the specification,
     * and other compliant implementations may not emit the event.
     * @param from address The address which you want to send tokens from
     * @param to address The address which you want to transfer to
     * @param value uint256 the amount of tokens to be transferred
     */
    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    /**
     * @dev Increase the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To increment
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param addedValue The amount of tokens to increase the allowance by.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].add(addedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
     * @dev Decrease the amount of tokens that an owner allowed to a spender.
     * approve should be called when allowed_[_spender] == 0. To decrement
     * allowed value is better to use this function to avoid 2 calls (and wait until
     * the first transaction is mined)
     * From MonolithDAO Token.sol
     * Emits an Approval event.
     * @param spender The address which will spend the funds.
     * @param subtractedValue The amount of tokens to decrease the allowance by.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        require(spender != address(0));

        _allowed[msg.sender][spender] = _allowed[msg.sender][spender].sub(subtractedValue);
        emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
        return true;
    }

    /**
    * @dev Transfer token for a specified addresses
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0));

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);
        emit Transfer(from, to, value);
    }

    /**
     * @dev Internal function that mints an amount of the token and assigns it to
     * an account. This encapsulates the modification of balances such that the
     * proper events are emitted.
     * @param account The account that will receive the created tokens.
     * @param value The amount that will be created.
     */
    function _mint(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.add(value);
        _balances[account] = _balances[account].add(value);
        emit Transfer(address(0), account, value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account, deducting from the sender's allowance for said account. Uses the
     * internal burn function.
     * Emits an Approval event (reflecting the reduced allowance).
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burnFrom(address account, uint256 value) internal {
        _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(value);
        _burn(account, value);
        emit Approval(account, msg.sender, _allowed[account][msg.sender]);
    }
}

// File: /home/akru/devel/cdex/contracts/AbstractDEX.sol

/*
    Interface of DEX contract.
*/

pragma solidity >= 0.5.0;


contract AbstractDEX {
    /**
     * @dev Notification for opened trades. 
     */
    event TradeOpened(uint256 indexed id);

    /**
     * @dev Notification for finalized trades. 
     */
    event TradeClosed(uint256 indexed id);

    /**
     * @dev Notify for every confirmed transfers. 
     */
    event TransferConfirmed(
        uint256 indexed id,
        address indexed trader,
        address indexed oracle
    );

    struct Trade {
        // Trade params
        address maker;
        address taker;
        uint256 collateralValue;
        // Trade state
        uint256 openBlock;
        uint256 closeBlock;
    }

    // Trade list 
    Trade[] public trades;

    // Value of transfer for trader
    mapping(uint256 => mapping(address => uint256)) public valueToSell;
    mapping(uint256 => mapping(address => uint256)) public valueToBuy;
    // Transfer extra params for trader
    mapping(uint256 => mapping(address => bytes)) public extraData;
    
    /**
     * @dev Collateral token address.
     */
    ERC20 public collateral;

    uint256 public tradingBlocks;

    /**
     * @dev Open trade by matching two orders.
     * @param makerOrder ABI-encoded maker order
     * @param takerOrder ABI-encoded taker order
     * @return unique trade identifier
     * @notice orders should not be used befor
     */
    function openTrade(
        bytes calldata makerOrder,
        bytes calldata makerSignature,
        bytes calldata takerOrder,
        bytes calldata takerSignature
    ) external returns (
        uint256 tradeId
    );

    /**
     * @dev Close trade and pay refund when transfer isn't confirmed.
     * @param _tradeId trade identifier
     * @return true when success closed
     */
    function closeTrade(
        uint256 _tradeId
    ) external returns (
        bool success
    );

    /**
     * @dev Confirm transfer for trade.
     * @param _tradeId trade identifier 
     * @param _trader trader address
     * @notice oracles call only
     */
    function confirmTransfer(
        uint256 _tradeId,
        address _trader
    ) external returns (
        bool success
    );
}

// File: /home/akru/devel/cdex/contracts/SingletonHash.sol

/*
    Hash consumtion accounting.
*/

pragma solidity >= 0.5.0;

contract SingletonHash {
    event HashConsumed(bytes32 indexed hash);

    /**
     * @dev Used hash accounting
     */
    mapping(bytes32 => bool) public isHashConsumed;

    /**
     * @dev Parameter can be used only once
     * @param _hash Single usage hash
     */
    function singleton(bytes32 _hash) internal returns (bytes32) {
        require(!isHashConsumed[_hash]);
        isHashConsumed[_hash] = true;
        emit HashConsumed(_hash);
        return _hash;
    }
}

// File: /home/akru/devel/cdex/contracts/AbstractOracle.sol

/*
    Interface of oracle contract.
*/

pragma solidity >= 0.5.0;


contract AbstractOracle {
    AbstractDEX public dex;

    function checkTrade(
        uint256 _tradeId
    ) external returns(
        bool success
    );
}

// File: contracts/DEX.sol

/*
    DEX core contract.
*/

pragma solidity >= 0.5.0;






contract DEX is AbstractDEX, SingletonHash {
    constructor(
        ERC20   _collateral,
        uint256 _tradingBlocks,
        uint256 _minConfirmations
    ) public {
        collateral = _collateral;
        tradingBlocks = _tradingBlocks;
        minTransferConfirmations = _minConfirmations;
    }

    using SafeERC20 for ERC20;
    using ECDSA for bytes32;

    // TODO: restrict visibility
    mapping(uint256 => mapping(address => address[])) public transferConfirmations;

    // TODO: keep in mind that it could be user params
    function setOracles(AbstractOracle[] calldata _oracles) external {
        require(oracles.length == 0);
        oracles = _oracles;
        for (uint256 i = 0; i < _oracles.length; ++i)
            isTradeOracle[address(_oracles[i])] = true;
    }
    AbstractOracle[] public oracles;
    mapping(address => bool) public isTradeOracle;
    uint256 public minTransferConfirmations;

    modifier oraclesOnly(uint256 _tradeId) {
        // Check that sender is trade oracle
        require(isTradeOracle[msg.sender]);
        _;
    }

    modifier openTradeOnly(uint256 _tradeId) {
        // Check that trade isn't closed before
        require(trades[_tradeId].closeBlock == 0);
        _;
    }

    function openTrade(
        bytes calldata makerOrder,
        bytes calldata makerSignature,
        bytes calldata takerOrder,
        bytes calldata takerSignature
    ) external returns (
        uint256 tradeId
    ) {
        // Instantiate new trade
        tradeId = trades.length++;
        Trade storage trade = trades[tradeId];

        // Recover trader addresses
        singleton(keccak256(makerOrder));
        trade.maker = keccak256(makerOrder)
            .toEthSignedMessageHash()
            .recover(makerSignature);

        singleton(keccak256(takerOrder));
        trade.taker = keccak256(takerOrder)
            .toEthSignedMessageHash()
            .recover(takerSignature);

        // Open order at current block
        trade.openBlock = block.number;

        // Process orders
        trade.collateralValue = processOrder(tradeId, trade.maker, makerOrder);
        require(trade.collateralValue > 0);
        require(trade.collateralValue == processOrder(tradeId, trade.taker, takerOrder));

        // Order matching validation
        require(valueToSell[tradeId][trade.maker] == valueToBuy[tradeId][trade.taker]);
        require(valueToBuy[tradeId][trade.maker] == valueToSell[tradeId][trade.taker]);

        // Notify oracles to start transfer checking
        for (uint256 i = 0; i < oracles.length; ++i)
            oracles[i].checkTrade(tradeId);

        emit TradeOpened(tradeId);
    }

    function closeTrade(
        uint256 _tradeId
    ) external
      returns (
        bool success
    ) {
        Trade storage trade = trades[_tradeId];
        // Checko that trade isn't closed
        require(trade.openBlock > 0
            && trade.closeBlock == 0
            && trades[_tradeId].openBlock + tradingBlocks < block.number);

        uint256 takerConfirmations = transferConfirmations[_tradeId][trade.taker].length;
        address takerRefund = takerConfirmations >= minTransferConfirmations ? trade.taker : trade.maker;
        collateral.safeTransfer(takerRefund, trade.collateralValue);

        uint256 makerConfirmations = transferConfirmations[_tradeId][trade.maker].length;
        address makerRefund = makerConfirmations >= minTransferConfirmations ? trade.maker : trade.taker;
        collateral.safeTransfer(makerRefund, trade.collateralValue);

        trade.closeBlock = block.number;
        emit TradeClosed(_tradeId);
        success = true;
    }

    function confirmTransfer(
        uint256 _tradeId,
        address _trader
    ) external 
      oraclesOnly(_tradeId)
      openTradeOnly(_tradeId)
      returns (
        bool success
    ) {
        address[] storage transfer_confirmations
            = transferConfirmations[_tradeId][_trader];
        for (uint256 i = 0; i < transfer_confirmations.length; ++i)
            require(transfer_confirmations[i] != msg.sender);
        transfer_confirmations.push(msg.sender);

        if (transfer_confirmations.length >= minTransferConfirmations)
            emit TransferConfirmed(_tradeId, _trader, msg.sender);

        return true;
    }

    function processOrder(
        uint256 _tradeId,
        address _trader,
        bytes memory _order
    ) internal returns (
        uint256 collateralValue
    ) {
        bytes memory extra;
        uint256 deadline;

        (extra,
         valueToBuy[_tradeId][_trader],
         valueToSell[_tradeId][_trader],
         collateralValue,
         deadline)
            = abi.decode(_order, (bytes, uint256, uint256, uint256, uint256));

        // Order deadline check
        require(deadline > block.number);

        // Collateral transfer
        collateral.safeTransferFrom(_trader, address(this), collateralValue);

        // Store trader extra data
        extraData[_tradeId][_trader] = extra;
    }
}
