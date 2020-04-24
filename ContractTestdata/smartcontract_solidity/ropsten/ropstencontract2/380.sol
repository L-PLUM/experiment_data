/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

// 0x9c83dce8ca20e9aaf9d3efc003b2ea62abc08351



// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/interfaces/token/TokenConverter.sol

pragma solidity 0.5.10;



interface TokenConverter {

    /// @notice Converts an amount 
    ///         a. swap the user`s ETH to IERC20 token or 
    ///         b. swap the user`s IERC20 token to another IERC20 token
    /// @param _inToken source token contract address
    /// @param _outToken destination token contract address
    /// @param _amount amount of source tokens
    /// @param _tokenCost amount of source _tokenCost
    /// @param _etherCost amount of source _etherCost
    function convert(
        IERC20 _inToken,
        IERC20 _outToken,
        uint256 _amount,
        uint256 _tokenCost,
        uint256 _etherCost
    ) external payable;

    /// @notice get the cost, in wei, of making a convertion using the value specified.
    /// @dev ETH -> Token
    function getPrice(
        address _outToken,
        uint256 _amount
    ) external view returns (uint256, uint256);

    /// @notice get the cost, in wei, of making a convertion using the value specified.
    /// @dev Token -> Token
    function getPrice(
        address _token,
        address _outToken,
        uint256 _amount
    ) external view returns (uint256, uint256);

}

// File: contracts/interfaces/uniswap/UniswapFactoryInterface.sol

pragma solidity 0.5.10;

/// https://docs.uniswap.io/smart-contract-integration/interface
contract UniswapFactoryInterface {
    /// Public Variables
    address public exchangeTemplate;
    uint256 public tokenCount;
    /// Create Exchange
    function createExchange(address token) external returns (address exchange);
    /// Get Exchange and Token Info
    function getExchange(address token) external view returns (address exchange);
    function getToken(address exchange) external view returns (address token);
    function getTokenWithId(uint256 tokenId) external view returns (address token);
    /// Never use
    function initializeFactory(address template) external;
}

// File: contracts/interfaces/uniswap/UniswapExchangeInterface.sol

pragma solidity 0.5.10;

/// https:///docs.uniswap.io/smart-contract-integration/interface
contract UniswapExchangeInterface {
    /// Address of ERC20 token sold on this exchange
    function tokenAddress() external view returns (address token);
    /// Address of Uniswap Factory
    function factoryAddress() external view returns (address factory);
    /// Provide Liquidity
    function addLiquidity(uint256 minLiquidity, uint256 maxTokens, uint256 deadline) external payable returns (uint256);
    function removeLiquidity(uint256 amount, uint256 minEth, uint256 minTokens, uint256 deadline) external returns (uint256, uint256);
    /// Get Prices
    function getEthToTokenInputPrice(uint256 ethSold) external view returns (uint256 tokensBought);
    function getEthToTokenOutputPrice(uint256 tokensBought) external view returns (uint256 ethSold);
    function getTokenToEthInputPrice(uint256 tokensSold) external view returns (uint256 ethBought);
    function getTokenToEthOutputPrice(uint256 ethBought) external view returns (uint256 tokensSold);
    /// Trade ETH to ERC20
    function ethToTokenSwapInput(uint256 minTokens, uint256 deadline) external payable returns (uint256  tokensBought);
    function ethToTokenTransferInput(uint256 minTokens, uint256 deadline, address recipient) external payable returns (uint256  tokensBought);
    function ethToTokenSwapOutput(uint256 tokensBought, uint256 deadline) external payable returns (uint256  ethSold);
    function ethToTokenTransferOutput(uint256 tokensBought, uint256 deadline, address recipient) external payable returns (uint256  ethSold);
    /// Trade ERC20 to ETH
    function tokenToEthSwapInput(uint256 tokensSold, uint256 minEth, uint256 deadline) external returns (uint256  ethBought);
    function tokenToEthTransferInput(uint256 tokensSold, uint256 minTokens, uint256 deadline, address recipient) external returns (uint256  ethBought);
    function tokenToEthSwapOutput(uint256 ethBought, uint256 maxTokens, uint256 deadline) external returns (uint256  tokensSold);
    function tokenToEthTransferOutput(uint256 ethBought, uint256 maxTokens, uint256 deadline, address recipient) external returns (uint256  tokensSold);
    /// Trade ERC20 to ERC20
    function tokenToTokenSwapInput(uint256 tokensSold, uint256 minTokensBought, uint256 minEthBought, uint256 deadline, address tokenAddr) external returns (uint256  tokensBought);
    function tokenToTokenTransferInput(uint256 tokensSold, uint256 minTokensBought, uint256 minEthBought, uint256 deadline, address recipient, address tokenAddr) external returns (uint256  tokensBought);
    function tokenToTokenSwapOutput(uint256 tokensBought, uint256 maxTokensSold, uint256 maxEthSold, uint256 deadline, address tokenAddr) external returns (uint256  tokensSold);
    function tokenToTokenTransferOutput(uint256 tokensBought, uint256 maxTokensSold, uint256 maxEthSold, uint256 deadline, address recipient, address tokenAddr) external returns (uint256  tokensSold);
    /// Trade ERC20 to Custom Pool
    function tokenToExchangeSwapInput(uint256 tokensSold, uint256 minTokensBought, uint256 minEthBought, uint256 deadline, address exchangeAddr) external returns (uint256  tokensBought);
    function tokenToExchangeTransferInput(uint256 tokensSold, uint256 minTokensBought, uint256 minEthBought, uint256 deadline, address recipient, address exchangeAddr) external returns (uint256  tokensBought);
    function tokenToExchangeSwapOutput(uint256 tokensBought, uint256 maxTokensSold, uint256 maxEthSold, uint256 deadline, address exchangeAddr) external returns (uint256  tokensSold);
    function tokenToExchangeTransferOutput(uint256 tokensBought, uint256 maxTokensSold, uint256 maxEthSold, uint256 deadline, address recipient, address exchangeAddr) external returns (uint256  tokensSold);
    /// ERC20 comaptibility for liquidity tokens
    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    /// Never use
    function setup(address tokenAddr) external;
}

// File: contracts/safe/SafeERC20.sol

pragma solidity ^0.5.10;



/**
* @dev Library to perform safe calls to standard method for ERC20 tokens.
*
* Why Transfers: transfer methods could have a return value (bool), throw or revert for insufficient funds or
* unathorized value.
*
* Why Approve: approve method could has a return value (bool) or does not accept 0 as a valid value (BNB token).
* The common strategy used to clean approvals.
*
* We use the Solidity call instead of interface methods because in the case of transfer, it will fail
* for tokens with an implementation without returning a value.
* Since versions of Solidity 0.4.22 the EVM has a new opcode, called RETURNDATASIZE.
* This opcode stores the size of the returned data of an external call. The code checks the size of the return value
* after an external call and reverts the transaction in case the return data is shorter than expected
* https://github.com/nachomazzara/SafeERC20/blob/master/contracts/libs/SafeERC20.sol
*/
library SafeERC20 {
    /**
    * @dev Transfer token for a specified address
    * @param _token erc20 The address of the ERC20 contract
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the _value of tokens to be transferred
    * @return bool whether the transfer was successful or not
    */
    function safeTransfer(IERC20 _token, address _to, uint256 _value) internal returns (bool) {
        uint256 prevBalance = _token.balanceOf(address(this));

        if (prevBalance < _value) {
            // Insufficient funds
            return false;
        }

        (bool success,) = address(_token).call(
            abi.encodeWithSignature("transfer(address,uint256)", _to, _value)
        );

        if (!success || prevBalance - _value != _token.balanceOf(address(this))) {
            // Transfer failed
            return false;
        }

        return true;
    }

    /**
    * @dev Transfer tokens from one address to another
    * @param _token erc20 The address of the ERC20 contract
    * @param _from address The address which you want to send tokens from
    * @param _to address The address which you want to transfer to
    * @param _value uint256 the _value of tokens to be transferred
    * @return bool whether the transfer was successful or not
    */
    function safeTransferFrom(
        IERC20 _token,
        address _from,
        address _to,
        uint256 _value
    ) internal returns (bool)
    {
        uint256 prevBalance = _token.balanceOf(_from);

        if (prevBalance < _value) {
            // Insufficient funds
            return false;
        }

        if (_token.allowance(_from, address(this)) < _value) {
            // Insufficient allowance
            return false;
        }

        (bool success,) = address(_token).call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", _from, _to, _value)
        );

        if (!success || prevBalance - _value != _token.balanceOf(_from)) {
            // Transfer failed
            return false;
        }

        return true;
    }

   /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender"s allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   *
   * @param _token erc20 The address of the ERC20 contract
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   * @return bool whether the approve was successful or not
   */
    function safeApprove(IERC20 _token, address _spender, uint256 _value) internal returns (bool) {
        (bool success,) = address(_token).call(
            abi.encodeWithSignature("approve(address,uint256)",_spender, _value)
        );

        if (!success && _token.allowance(address(this), _spender) != _value) {
            // Approve failed
            return false;
        }

        return true;
    }

   /**
   * @dev Clear approval
   * Note that if 0 is not a valid value it will be set to 1.
   * @param _token erc20 The address of the ERC20 contract
   * @param _spender The address which will spend the funds.
   */
    function clearApprove(IERC20 _token, address _spender) internal returns (bool) {
        bool success = safeApprove(_token, _spender, 0);

        if (!success) {
            success = safeApprove(_token, _spender, 1);
        }

        return success;
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: contracts/safe/SafeExchange.sol

pragma solidity ^0.5.10;





library SafeExchange {
    using SafeMath for uint256;

    modifier swaps(uint256 _value, IERC20 _token) {
        uint256 nextBalance = _token.balanceOf(address(this)).add(_value);
        _;
        require(
            _token.balanceOf(address(this)) >= nextBalance,
            "Balance validation failed after swap."
        );
    }

    function swapTokens(
        UniswapExchangeInterface _exchange,
        uint256 _outValue,
        uint256 _inValue,
        uint256 _ethValue,
        uint256 _deadline,
        IERC20 _outToken
    ) internal swaps(_outValue, _outToken) {
        _exchange.tokenToTokenSwapOutput(
            _outValue,
            _inValue,
            _ethValue,
            _deadline,
            address(_outToken)
        );
    }

    function swapEther(
        UniswapExchangeInterface _exchange,
        uint256 _outValue,
        uint256 _ethValue,
        uint256 _deadline,
        IERC20 _outToken
    ) internal swaps(_outValue, _outToken) {
        _exchange.ethToTokenSwapOutput.value(_ethValue)(_outValue, _deadline);
    }
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
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

// File: contracts/proxy/UniswapProxy.sol

pragma solidity 0.5.10;

/// @notice proxy between ConverterRamp and Uniswap
///         accepts tokens and ether, converts these to the desired token, 
///         and makes approve calls to allow the recipient to transfer those 
///         tokens from the contract.
/// @author Joaquin Pablo Gonzalez ([email protected])
contract UniswapProxy is TokenConverter, Ownable {
    
    using SafeMath for uint256;
    using SafeExchange for UniswapExchangeInterface;
    using SafeERC20 for IERC20;

    event Swap(address indexed _sender, IERC20 _token, IERC20 _outToken, uint _amount);
    event WithdrawTokens(address _token, address _to, uint256 _amount);
    event WithdrawEth(address _to, uint256 _amount);
    event SetUniswap(address _uniswapFactory);

    /// @notice address to identify operations with ETH 
    IERC20 constant internal ETH_TOKEN_ADDRESS = IERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    /// @notice registry of ERC20 tokens that have been added to the system 
    ///         and the exchange to which they are associated.
    UniswapFactoryInterface factory;

    constructor (address _uniswapFactory) public {
        factory = UniswapFactoryInterface(_uniswapFactory);
        emit SetUniswap(_uniswapFactory);
    }
    
    /// @notice get price to swap token to another token
    /// @return _tokenCost, _etherCost, _inExchange
    /// @dev  internal method.
    function price(
        address _token,
        address _outToken,
        uint256 _amount
    ) internal view returns (uint256, uint256, UniswapExchangeInterface) {
        UniswapExchangeInterface inExchange =
            UniswapExchangeInterface(factory.getExchange(_token));
        UniswapExchangeInterface outExchange =
            UniswapExchangeInterface(factory.getExchange(_outToken));

        uint256 etherCost = outExchange.getEthToTokenOutputPrice(_amount);
        uint256 tokenCost = inExchange.getTokenToEthOutputPrice(etherCost);

        return (tokenCost, etherCost, inExchange);
    }

    /// @notice get price to swap eth to token
    /// @return _etherCost, _exchange
    /// @dev  internal method.
    function price(
        address _outToken,
        uint256 _amount
    ) internal view returns (uint256, UniswapExchangeInterface) {
        UniswapExchangeInterface exchange =
            UniswapExchangeInterface(factory.getExchange(_outToken));

        return (exchange.getEthToTokenOutputPrice(_amount), exchange);
    }

    /// @notice change uniswap factory address
    /// @param _uniswapFactory address
    /// @return returns true if everything was correct
    function setUniswapFactory(address _uniswapFactory) external onlyOwner returns (bool) {
        factory = UniswapFactoryInterface(_uniswapFactory);
        emit SetUniswap(_uniswapFactory);
        return true;
    }

    /// @notice get price for swap token to token
    /// @return _tokenCost, _etherCost, _inExchange
    function getPrice(
        address _token,
        address _outToken,
        uint256 _amount
    ) public view returns (uint256, uint256) {
        
        (
            uint256 tokenCost, 
            uint256 etherCost,
        ) = price(address(_token), address(_outToken), _amount);

        return (tokenCost, etherCost);
    }

    /// @notice get price for swap eth to token
    /// @return _tokenCost, _etherCost, _inExchange
    function getPrice(
        address _outToken,
        uint256 _amount
    ) public view returns (uint256, uint256) {
        
        (
            uint256 etherCost,
        ) = price(address(_outToken), _amount);
        
        return (0, etherCost);

    }

    /// @notice Converts an amount 
    ///         a. swap the user`s ETH to IERC20 token or 
    ///         b. swap the user`s IERC20 token to another IERC20 token
    /// @param _inToken source token contract address
    /// @param _outToken destination token contract address
    /// @param _amount amount of source tokens
    /// @param _tokenCost amount of source _tokenCost
    /// @param _etherCost amount of source _etherCost
    function convert(
        IERC20 _inToken,
        IERC20 _outToken, 
        uint256 _amount,
        uint256 _tokenCost,
        uint256 _etherCost
    ) external payable {   

        address sender = msg.sender;
        if (_inToken == ETH_TOKEN_ADDRESS && _outToken != ETH_TOKEN_ADDRESS) {
            execSwapEtherToToken(_outToken, _amount, _etherCost, sender);
        } else {
            require(msg.value == 0, "eth not required");    
            execSwapTokenToToken(_inToken, _amount, _tokenCost, _etherCost, _outToken, sender);
        }

        emit Swap(msg.sender, _inToken, _outToken, _amount);
        
    }

    /// @notice Swap the user`s ETH to IERC20 token
    /// @param _outToken source token contract address
    /// @param _amount amount of source tokens
    /// @param _etherCost amount of source _etherCost
    /// @param _recipient address to send swapped tokens to
    function execSwapEtherToToken(
        IERC20 _outToken, 
        uint _amount,
        uint _etherCost, 
        address _recipient
    ) public payable {
        
        UniswapExchangeInterface exchange = UniswapExchangeInterface(factory.getExchange(address(_outToken)));
        
        require(msg.value >= _etherCost, "insufficient ether sent.");
        exchange.swapEther(_amount, _etherCost, block.timestamp + 1, _outToken);

        require(_outToken.safeTransfer(_recipient, _amount), "error transfer tokens"); 
        uint256 toReturn = msg.value.sub(_etherCost);
        if (toReturn > 0) {
            msg.sender.transfer(toReturn);
        }
    }

    /// @notice swap the user`s IERC20 token to another IERC20 token
    /// @param _token source token contract address
    /// @param _amount amount of source tokens
    /// @param _tokenCost amount of source _tokenCost
    /// @param _etherCost amount of source _etherCost
    /// @param _outToken destination token contract address
    /// @param _recipient address to send swapped tokens to
    function execSwapTokenToToken(
        IERC20 _token, 
        uint256 _amount,
        uint256 _tokenCost,
        uint256 _etherCost, 
        IERC20 _outToken, 
        address _recipient
    ) internal {

        UniswapExchangeInterface exchange = UniswapExchangeInterface(factory.getExchange(address(_token)));
        /// Check that the player has transferred the token to this contract
        require(_token.safeTransferFrom(msg.sender, address(this), _tokenCost), "error pulling tokens");

        /// Set the spender`s token allowance to tokenCost
        _token.safeApprove(address(exchange), _tokenCost);

        /// safe swap tokens
        exchange.swapTokens(_amount, _tokenCost, _etherCost, block.timestamp + 1, _outToken);
        require(_outToken.safeTransfer(_recipient, _amount), "error transfer tokens");        
    }

}
