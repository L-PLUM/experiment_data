/**
 *Submitted for verification at Etherscan.io on 2019-02-22
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

// File: /home/akru/devel/cdex/contracts/misc/Set.sol

/**
 * @title Library for single value data collection. 
 */

pragma solidity >= 0.5.0;

library Set {
    struct Address {
        mapping(address => bool) flags;
        address[] data;
    }

    function at(
        Address storage self,
        uint256 _ix
    ) internal view returns (address) {
        require(_ix < self.data.length);
        return self.data[_ix];
    }

    function size(
        Address storage self
    ) internal view returns (uint256) {
        return self.data.length;
    }

    function contains(
        Address storage self,
        address _value
    ) internal view returns (bool) {
        return self.flags[_value];
    }

    function insert(
        Address storage self,
        address _value
    ) internal returns (bool) {
        if (!self.flags[_value]) {
            self.flags[_value] = true;
            self.data.push(_value);
            return true;
        } 
        return false;
    }

}

// File: /home/akru/devel/cdex/contracts/interface/IExchange.sol

/**
 * @title Interface of exchange smart contract.
 */

pragma solidity >= 0.5.0;


interface IExchange {
    /**
     * @dev New market params added to registry.
     */
    event NewMarket(bytes32 indexed id);

    /**
     * @dev Trade open state notification. 
     */
    event TradeStart(uint256 indexed id);

    /**
     * @dev Trade partial state notification. 
     */
    event TradePartial(uint256 indexed id);

    /**
     * @dev Trade finish state notification. 
     */
    event TradeFinish(uint256 indexed id);

    /**
     * @dev Notify for every transfer taker confirmation from oracle. 
     */
    event TakerTransferConfirmation(
        uint256 indexed id,
        address indexed oracle
    );

    /**
     * @dev Notify for every confirmed taker transfers. 
     */
    event TakerTransferConfirmed(uint256 indexed id);

    /**
     * @dev Notify for every maker transfer confirmation from oracle. 
     */
    event MakerTransferConfirmation(
        uint256 indexed id,
        address indexed oracle
    );

    /**
     * @dev Notify for every confirmed maker transfers. 
     */
    event MakerTransferConfirmed(uint256 indexed id);

    enum TradeState {
        Start,
        Partial,
        Release,
        Penalty,
        Finish
    }

    struct Trade {
        // Market id: sha3(timeouts, oracles, min confirmations) 
        bytes32 market;

        // Deal id: sha3(makret id, sell value, buy value)
        bytes32 deal;

        // Collateral params
        address maker;
        address taker;
        uint256 collateral;

        // Trade oracles
        Set.Address makerTransferConfirmations;
        Set.Address takerTransferConfirmations;

        // Trade state
        TradeState state;
        uint256 startBlock;
        uint256 partialBlock;
        uint256 finishBlock;

        // Trade extra params (used by oracle to check trade off-chain)
        bytes makerExtra;
        bytes takerExtra;
    }

    struct Market {
        // Timeout params
        uint256 makerTimeout;
        uint256 takerTimeout;

        // Trade oracles
        Set.Address oracles;
        uint256 minimalConfirmations;
    }

    /**
     * @dev Get trade summary.
     * @param _id Trade identifier.
     * @return Trade params.
     */
    function getTrade(
        uint256 _id
    ) external view returns (
        bytes32 market,
        bytes32 deal,
        address maker,
        address taker,
        uint256 collateral,
        uint256 makerTransferConfirmations,
        uint256 takerTransferConfirmations,
        uint256 startBlock,
        uint256 partialBlock,
        uint256 finishBlock,
        bytes memory makerExtra,
        bytes memory takerExtra
    );

    /**
     * @dev Get market summary.
     * @param _id Market identifier.
     * @return Market params.
     */
    function getMarket(
        bytes32 _id
    ) external view returns (
        uint256 makerTimeout,
        uint256 takerTimeout,
        address[] memory oracles,
        uint256 minimalConfirmations
    );

    /**
     * @dev Add new market descriptor.
     * @param _makerTimeout Maker timeout in blocks.
     * @param _takerTimeout Taker timeout in blocks.
     * @param _oracles Trade oracle list.
     * @param _minimalConfirmations Minimal confirmation for trade.
     * @return Market id.
     */
    function addMarket(
        uint256 _makerTimeout,
        uint256 _takerTimeout,
        address[] calldata _oracles,
        uint256 _minimalConfirmations
    ) external returns (
        bytes32 id
    );

    /**
     * @dev Start trade by matching two orders.
     * @param makerOrder ABI-encoded maker order
     * @param makerSignature Ethereum signature of maker order
     * @param takerOrder ABI-encoded taker order
     * @param takerSignature Ethereum signature of taker order
     * @return started trade identifier
     * @notice orders should not be used befor
     */
    function startTrade(
        bytes calldata makerOrder,
        bytes calldata makerSignature,
        bytes calldata takerOrder,
        bytes calldata takerSignature
    ) external returns (
        uint256 id
    );

    /**
     * @dev Confirm taker transfer for trade.
     * @param _id trade identifier 
     * @notice for trade oracles call only
     */
    function confirmTakerTransfer(
        uint256 _id
    ) external returns (
        bool success
    );

    /**
     * @dev Confirm maker transfer for trade.
     * @param _id trade identifier 
     * @notice for trade oracles call only
     */
    function confirmMakerTransfer(
        uint256 _id
    ) external returns (
        bool success
    );

    /**
     * @dev Finish trade and pay refund when transfer isn't confirmed.
     * @param _id trade identifier
     * @return true when success closed
     */
    function finishTrade(
        uint256 _id
    ) external returns (
        bool success
    );
}

// File: /home/akru/devel/cdex/contracts/interface/IOracle.sol

/**
 * @title Interface of oracle contract.
 */

pragma solidity >= 0.5.0;

interface IOracle {
    /**
     * @dev Check trade transfers and make decision.
     * @param _dex Exchange address
     * @param _id Trade identifier
     */
    function checkTrade(
        address _dex,
        uint256 _id
    ) external returns(
        bool success
    );
}

// File: /home/akru/devel/cdex/contracts/misc/SingletonHash.sol

/**
 * @title Hash consumtion accounting.
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

// File: contracts/Exchange.sol

/**
 * @title Exchange smart contract.
 */

pragma solidity >= 0.5.0;








contract Exchange is IExchange, SingletonHash {
    constructor(ERC20 _collateral) public {
        token = _collateral;
    }

    string constant private ERROR_TRADE_DOESNT_EXIT = "Trade doesn't exist";
    string constant private ERROR_TRADE_ALREADY_FINISH = "Trade already finish";
    string constant private ERROR_ORACLE_ONLY = "This method is for trade oracle only";
    string constant private ERROR_INVALID_STATE = "Call method in invalid trade state";
    string constant private ERROR_DOUBLE_VOTE = "Oracle can vote for trade only once"; 
    string constant private ERROR_DEADLINE_REACHED = "Order message deadline was reached";
    string constant private ERROR_ORDER_MISMATCHED = "Order messages mismatched by params";

    using SafeERC20 for ERC20;
    using ECDSA for bytes32;
    using Set for Set.Address;

    ERC20 public token;
    Trade[] private trades;
    mapping(bytes32 => Market) private markets;

    modifier oracleOnly(uint256 _id) {
        require(markets[trades[_id].market].oracles.contains(msg.sender), ERROR_ORACLE_ONLY);
        _;
    }

    modifier stateOnly(uint256 _id, TradeState _state) {
        require(trades[_id].state == _state, ERROR_INVALID_STATE);
        _;
    }

    modifier timedTransaction(uint256 _id) {
        Trade storage trade = trades[_id];

        // Start/finish checks
        require(trade.startBlock != 0, ERROR_TRADE_DOESNT_EXIT);
        require(trade.finishBlock == 0, ERROR_TRADE_ALREADY_FINISH);

        // Check for taker timeout
        if (trade.state == TradeState.Start
            && trade.startBlock + markets[trade.market].takerTimeout < block.number)
            _release(_id);

        // Check for maker timeout
        if (trade.state == TradeState.Partial
            && trade.partialBlock + markets[trade.market].makerTimeout < block.number)
                _penalty(_id);

        _;

        // Make release when needed
        if (trade.state == TradeState.Release)
            _release(_id);
    }

    function getTrade(
        uint256 _id
    ) external view returns (
        bytes32 market,
        bytes32 deal,
        address maker,
        address taker,
        uint256 collateral,
        uint256 makerTransferConfirmations,
        uint256 takerTransferConfirmations,
        uint256 startBlock,
        uint256 partialBlock,
        uint256 finishBlock,
        bytes memory makerExtra,
        bytes memory takerExtra
    ) {
        Trade storage trade = trades[_id];
        market = trade.market;
        deal = trade.deal;
        maker = trade.maker;
        taker = trade.taker;
        collateral = trade.collateral;
        makerTransferConfirmations = trade.makerTransferConfirmations.size();
        takerTransferConfirmations = trade.takerTransferConfirmations.size();
        startBlock = trade.startBlock;
        partialBlock = trade.partialBlock;
        finishBlock = trade.finishBlock;
        makerExtra = trade.makerExtra;
        takerExtra = trade.takerExtra;
    }

    function getMarket(
        bytes32 _id
    ) external view returns (
        uint256 makerTimeout,
        uint256 takerTimeout,
        address[] memory oracles,
        uint256 minimalConfirmations
    ) {
        Market storage market = markets[_id];

        makerTimeout = market.makerTimeout;
        takerTimeout = market.takerTimeout;
        minimalConfirmations = market.minimalConfirmations;

        oracles = new address[](market.oracles.size());
        for (uint256 i = 0; i < market.oracles.size(); ++i)
            oracles[i] = market.oracles.at(i);
    }

    function addMarket(
        uint256 _makerTimeout,
        uint256 _takerTimeout,
        address[] calldata _oracles,
        uint256 _minimalConfirmations
    ) external returns (
        bytes32 id 
    ) {
        id = keccak256(abi.encodePacked(
            _makerTimeout,
            _takerTimeout,
            _oracles,
            _minimalConfirmations
        ));

        Market storage market = markets[id];
        market.makerTimeout = _makerTimeout;
        market.takerTimeout = _takerTimeout;
        market.minimalConfirmations = _minimalConfirmations;

        for (uint256 i = 0; i < _oracles.length; ++i)
            market.oracles.insert(_oracles[i]);

        emit NewMarket(id);
    }

    function startTrade(
        bytes calldata makerOrder,
        bytes calldata makerSignature,
        bytes calldata takerOrder,
        bytes calldata takerSignature
    ) external returns (
        uint256 id
    ) {
        // Start new trade
        id = trades.length++;
        Trade storage trade = trades[id];

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
        trade.startBlock = block.number;
        trade.state = TradeState.Start;

        // Process orders
        require(processMakerOrder(id, makerOrder));
        require(processTakerOrder(id, takerOrder));

        // Notify oracles to start transfer checking
        Set.Address storage oracles = markets[trade.market].oracles;
        require(oracles.size() > 0);
        for (uint256 i = 0; i < oracles.size(); ++i)
            require(IOracle(oracles.at(i)).checkTrade(address(this), id));

        emit TradeStart(id);
    }

    function confirmTakerTransfer(
        uint256 _id
    ) external
      oracleOnly(_id)
      timedTransaction(_id)
      stateOnly(_id, TradeState.Start)
      returns (
        bool success
    ) {
        Trade storage trade = trades[_id];
        require(trade.takerTransferConfirmations.insert(msg.sender), ERROR_DOUBLE_VOTE);
        emit TakerTransferConfirmation(_id, msg.sender);

        if (trade.takerTransferConfirmations.size() >= markets[trade.market].minimalConfirmations) {
            trade.partialBlock = block.number;
            trade.state = TradeState.Partial;
            emit TakerTransferConfirmed(_id);
        }

        success = true;
    }

    function confirmMakerTransfer(
        uint256 _id
    ) external
      oracleOnly(_id)
      timedTransaction(_id)
      stateOnly(_id, TradeState.Partial)
      returns (
        bool success
    ) {
        Trade storage trade = trades[_id];
        require(trade.makerTransferConfirmations.insert(msg.sender), ERROR_DOUBLE_VOTE);
        emit MakerTransferConfirmation(_id, msg.sender);

        if (trade.makerTransferConfirmations.size() >= markets[trade.market].minimalConfirmations) {
            trade.partialBlock = block.number;
            trade.state = TradeState.Release;
            emit MakerTransferConfirmed(_id);
        }

        success = true;
    }

    function finishTrade(
        uint256 _id
    ) external
      timedTransaction(_id)
      stateOnly(_id, TradeState.Finish)
      returns (
        bool success
    ) {
        success = true;
    }

    function _penalty(
        uint256 _id
    ) internal {
        token.safeTransfer(trades[_id].taker, trades[_id].collateral);
        _finish(_id);
    }

    function _release(
        uint256 _id
    ) internal {
        token.safeTransfer(trades[_id].maker, trades[_id].collateral);
        _finish(_id);
    }

    function _finish(
        uint256 _id
    ) internal {
        trades[_id].finishBlock = block.number;
        trades[_id].state = TradeState.Finish;
        emit TradeFinish(_id);
    }

    function processMakerOrder(
        uint256 _id,
        bytes memory _order
    ) internal returns (
        bool success
    ) {
        uint256 deadline;
        Trade storage trade = trades[_id];

        (trade.market,
         trade.deal,
         trade.collateral,
         deadline,
         trade.makerExtra)
            = abi.decode(_order, (bytes32, bytes32, uint256, uint256, bytes));

        // Order deadline check
        require(deadline > block.number, ERROR_DEADLINE_REACHED);

        // Collateral transfer
        token.safeTransferFrom(trade.maker, address(this), trade.collateral);

        success = true;
    }

    function processTakerOrder(
        uint256 _id,
        bytes memory _order
    ) internal returns (
        bool success
    ) {
        uint256 deadline;
        bytes32 market;
        bytes32 deal;

        (market,
         deal,
         deadline,
         trades[_id].takerExtra)
            = abi.decode(_order, (bytes32, bytes32, uint256, bytes));

        // Order deadline check
        require(deadline > block.number, ERROR_DEADLINE_REACHED);

        // Check for market & deal
        require(trades[_id].market == market && trades[_id].deal == deal, ERROR_ORDER_MISMATCHED);

        success = true;
    }
}
