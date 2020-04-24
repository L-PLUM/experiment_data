/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

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

// File: contracts/interfaces/Cosigner.sol

pragma solidity 0.5.10;


interface Cosigner {

    function cost(
        address engine,
        uint256 index,
        bytes calldata data,
        bytes calldata oracleData
    ) external view returns (uint256);

}

// File: contracts/interfaces/diaspore/DebtEngine.sol

pragma solidity 0.5.10;


interface DebtEngine {

    function pay(
        bytes32 _id,
        uint256 _amount,
        address _origin,
        bytes calldata _oracleData
    ) external returns (uint256 paid, uint256 paidToken);

    function transferFrom(address _from, address _to, uint256 _assetId) external;
}

// File: contracts/interfaces/diaspore/LoanManager.sol

pragma solidity 0.5.10;



contract LoanManager {
    IERC20 public token;

    function getCurrency(uint256 _id) external view returns (bytes32);
    function getAmount(uint256 _id) external view returns (uint256);
    function getAmount(bytes32 _id) external view returns (uint256);
    function getOracle(uint256 _id) external view returns (address);

    function settleLend(
        bytes memory _requestData,
        bytes memory _loanData,
        address _cosigner,
        uint256 _maxCosignerCost,
        bytes memory _cosignerData,
        bytes memory _oracleData,
        bytes memory _creatorSig,
        bytes memory _borrowerSig
    ) public returns (bytes32 id);

    function lend(
        bytes32 _id,
        bytes memory _oracleData,
        address _cosigner,
        uint256 _cosignerLimit,
        bytes memory _cosignerData,
        bytes memory _callbackData
    ) public returns (bool);

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

// File: contracts/interfaces/RateOracle.sol

pragma solidity 0.5.10;



/// @dev Defines the interface of a standard Diaspore RCN Oracle,
/// The contract should also implement it is ERC165 interface: 0xa265d8e0
/// @notice Each oracle can only support one currency
/// @author Agustin Aguilar
interface RateOracle {
    function readSample(bytes calldata _data) external returns (uint256 _tokens, uint256 _equivalent);
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

// File: contracts/ConverterRamp.sol

pragma solidity 0.5.10;


/// @title  Converter Ramp
/// @notice for conversion between different assets, use TokenConverter 
///         contract as abstract layer for convert different assets.
/// @dev All function calls are currently implemented without side effects
contract ConverterRamp is Ownable {
    
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    /// @notice address to identify operations with ETH 
    address public constant ETH_ADDRESS = address(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    event Return(address _token, address _to, uint256 _amount);
    event ReadedOracle(address _oracle, uint256 _tokens, uint256 _equivalent);

    
    /// @notice pays a loan using _fromTokens
    /// @param _converter converter to use for swapping (uniswap, kyber, bancor, etc)
    /// @param _fromToken token address to convert
    /// @param _loanManagerAddress address of diaspore LoanManagaer
    /// @param _debtEngineAddress address of diaspore LoanManagaer 
    /// @param _payFrom registering pay address 
    /// @param _requestId loan id to pay
    /// @param _oracleData data signed by ripio oracle
    function pay(
        address _converter,
        address _fromToken,
        address _loanManagerAddress,
        address _debtEngineAddress,
        address _payFrom,
        bytes32 _requestId,
        bytes calldata _oracleData
    ) external payable {
        
        /// load RCN IERC20, we need it to pay
        IERC20 token = LoanManager(_loanManagerAddress).token();

        /// get amount required, in RCN, for payment
        uint256 amount = getRequiredRcnPay(
            _loanManagerAddress,
            _requestId, 
            _oracleData
        );
        
        /// converter using token converter
        convertSafe(_converter, _loanManagerAddress, _fromToken, address(token), amount);

        /// pay loan
        DebtEngine debtEngine = DebtEngine(_debtEngineAddress);
        require(token.safeApprove(_debtEngineAddress, amount), "error on payment approve");
        
        uint256 prevTokenBalance = token.balanceOf(address(this));
        debtEngine.pay(_requestId, amount, _payFrom, _oracleData);

        require(token.approve(_debtEngineAddress, 0), "error removing the payment approve");
        require(token.balanceOf(address(this)) == prevTokenBalance.sub(amount), "the contract balance should be the previous");
    }

    /// @notice Lends a loan using fromTokens, transfer loan ownership to msg.sender
    /// @param _converter converter to use for swapping (uniswap, kyber, bancor, etc)
    /// @param _fromToken token address to convert
    /// @param _loanManagerAddress address of diaspore LoanManagaer
    /// @param _lenderCosignerAddress address of diaspore Cosigner 
    /// @param _debtEngineAddress address of diaspore LoanManagaer 
    /// @param _requestId loan id to pay
    /// @param _oracleData data signed by ripio oracle
    /// @param _cosignerData cosigner data
    /// @param _callbackData callback data 
    function lend(
        address _converter,
        address _fromToken,
        address _loanManagerAddress,
        address _lenderCosignerAddress,
        address _debtEngineAddress,
        bytes32 _requestId,
        bytes memory _oracleData,
        bytes memory _cosignerData,
        bytes memory _callbackData
    ) public payable {
        
        /// load RCN IERC20
        IERC20 token = LoanManager(_loanManagerAddress).token();

        /// get required RCN for lending the loan
        uint256 amount = getRequiredRcnLend(
            _loanManagerAddress, 
            _lenderCosignerAddress, 
            _requestId,  
            _oracleData, 
            _cosignerData
        );

        /// convert using token converter
        convertSafe(_converter, _loanManagerAddress, _fromToken, address(token), amount);

        uint256 prevTokenBalance = token.balanceOf(address(this));

        LoanManager(_loanManagerAddress).lend(
            _requestId, 
            _oracleData, 
            _lenderCosignerAddress, 
            0, 
            _cosignerData, 
            _callbackData
        );
        
        require(token.safeApprove(_loanManagerAddress, 0), "error removing approve");
        require(token.balanceOf(address(this)) == prevTokenBalance.sub(amount), "the contract balance should be the previous");

        /// transfer loan to msg.sender
        DebtEngine(_debtEngineAddress).transferFrom(address(this), msg.sender, uint256(_requestId));

    }

    /// @notice get the cost, in wei, of making a convertion using the value specified.
    /// @param _amount amount to calculate cost
    /// @param _converter converter to use for swap
    /// @param _fromToken token to convert
    /// @param _token RCN token address
    /// @return _tokenCost and _etherCost
    function getCost(uint _amount, address _converter, address _fromToken, address _token) public view returns (uint256, uint256)  {
    
        TokenConverter tokenConverter = TokenConverter(_converter);
        if (_fromToken == ETH_ADDRESS) {
            return tokenConverter.getPrice(_token, _amount);
        } else {
            return tokenConverter.getPrice(_fromToken, _token, _amount);
        }
       
    }

    /// @notice Converts an amount using a converter
    /// @dev orchestrator between token->token, eth->token
    function convertSafe(
        address _converter,
        address _loanManagerAddress,
        address _fromToken,
        address _token,
        uint256 _amount
    ) internal {
        
        (uint256 tokenCost, uint256 etherCost) = getCost(_amount, _converter, _fromToken, address(_token));
        if (_fromToken == ETH_ADDRESS) {
            ethConvertSafe(_converter, _fromToken, address(_token), _amount, tokenCost, etherCost);
        } else {
            tokenConvertSafe(_converter, _loanManagerAddress, _fromToken, address(_token), _amount, tokenCost, etherCost);
        }
    }

    /// @dev not trusting the converter, validates all convertions using the token contract.
    ///      Token convertions
    function tokenConvertSafe(
        address _converter,
        address _loanManagerAddress,
        address _fromTokenAddress,
        address _toTokenAddress,
        uint256 _amount,
        uint256 _tokenCost,
        uint256 _etherCost
    ) internal {
        
        IERC20 fromToken = IERC20(_fromTokenAddress);
        IERC20 toToken = IERC20(_toTokenAddress);
        TokenConverter tokenConverter = TokenConverter(_converter);
        
        /// pull tokens to convert
        require(fromToken.safeTransferFrom(msg.sender, address(this), _tokenCost), "Error pulling token amount");

        /// safe approve tokens to tokenConverter
        require(fromToken.safeApprove(address(tokenConverter), _tokenCost), "Error approving token transfer");

        /// store the previus balance after conversion to validate
        uint256 prevBalance = toToken.balanceOf(address(this));

        /// call convert in token converter
        tokenConverter.convert(fromToken, toToken, _amount, _tokenCost, _etherCost);

        /// token balance should have increased by amount
        require(_amount == toToken.balanceOf(address(this)).sub(prevBalance), "Bought amound does does not match");

        /// if we are converting from a token, remove the approve
        require(fromToken.safeApprove(address(tokenConverter), 0), "Error removing token approve");

        /// approve token to loan manager
        require(toToken.safeApprove(_loanManagerAddress, _tokenCost), "Error approving lend token transfer");

    }

    /// @dev not trusting the converter, validates all convertions using the token contract.
    ///      ETH convertions
    function ethConvertSafe(
        address _converter,
        address _fromTokenAddress,
        address _toTokenAddress,
        uint256 _amount,
        uint256 _tokenCost,
        uint256 _etherCost
    ) internal {

        IERC20 fromToken = IERC20(_fromTokenAddress);
        IERC20 toToken = IERC20(_toTokenAddress);
        TokenConverter tokenConverter = TokenConverter(_converter);

        /// store the previus balance after conversion to validate
        uint256 prevEthBalance = (address(this).balance).sub(msg.value);

        /// call convert in token converter
        tokenConverter.convert.value(_amount)(fromToken, toToken, _amount, _tokenCost, _etherCost);

        /// Return leftover eth
        uint256 surplus = (address(this).balance).sub(prevEthBalance);
        if (surplus > 0) {
            msg.sender.transfer(surplus);
        }

    }

    /// @notice returns how much RCN is required for a given lend
    function getRequiredRcnLend(
        address _loanManagerAddress,
        address _lenderCosignerAddress,
        bytes32 _requestId,
        bytes memory _oracleData,
        bytes memory _cosignerData
    ) internal returns (uint256) {
        
        /// load loan manager and id
        LoanManager loanManager = LoanManager(_loanManagerAddress);
        uint256 amount = loanManager.getAmount(_requestId);

        /// load cosigner of loan
        Cosigner cosigner = Cosigner(_lenderCosignerAddress);

        /// if loan has a cosigner, sum the cost
        if (_lenderCosignerAddress != address(0)) {
            amount = amount.add(cosigner.cost(_loanManagerAddress, uint256(_requestId), _cosignerData, _oracleData));
        }

        /// load the  Oracle rate and convert required   
        address oracle = loanManager.getOracle(uint256(_requestId))     ;
        return getCurrencyToToken(oracle, amount, _oracleData);
    }

    /// @notice returns how much RCN is required for a given pay
    function getRequiredRcnPay(
        address _loanManagerAddress,
        bytes32 _requestId,
        bytes memory _oracleData
    ) internal returns (uint256 _result) {
        
        /// Load LoanManager and ID
        LoanManager loanManager = LoanManager(_loanManagerAddress);
        uint256 amount = loanManager.getAmount(_requestId);
        /// Read loan oracle
        address oracle = loanManager.getOracle(uint256(_requestId));
        return getCurrencyToToken(oracle, amount, _oracleData);

    }

    /// @notice returns how much tokens for _amount currency
    /// @dev tokens and equivalents get oracle data
    function getCurrencyToToken(
        address _oracle,
        uint256 _amount,
        bytes memory _oracleData
    ) internal returns (uint256) {
        if (_oracle == address(0)) {
            return _amount;
        }
        (uint256 tokens, uint256 equivalent) = RateOracle(_oracle).readSample(_oracleData);

        emit ReadedOracle(_oracle, tokens, equivalent);
        return tokens.mul(_amount) / equivalent;
    }
}
