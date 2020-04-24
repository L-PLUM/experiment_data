/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

/**
 *Submitted for verification at Etherscan.io on 2019-08-06
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

// File: contracts/IKyber.sol

pragma solidity 0.5.10;



interface IKyber {
    function maxGasPrice() external view returns(uint);

    function getUserCapInWei(address user) external view returns(uint);

    function getUserCapInTokenWei(
        address user,
        IERC20 token
    )
        external
        view
        returns(uint);

    function enabled() external view returns(bool);

    function info(bytes32 id) external view returns(uint);

    function getExpectedRate(
        IERC20 src,
        IERC20 dest,
        uint srcQty
    )
        external
        view
        returns (uint expectedRate, uint slippageRate);

    function tradeWithHint(
        IERC20 src,
        uint srcAmount,
        IERC20 dest,
        address destAddress,
        uint maxDestAmount,
        uint minConversionRate,
        address walletId,
        bytes calldata hint
    )
        external
        payable
        returns(uint);
}

// File: contracts/KyberExchange.sol

pragma solidity 0.5.10;




contract KyberExchange {
    // Variables
    IKyber private kyberNetworkProxyContract;
    
    address constant private ETH_ADDRESS = address(
        0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE
    );
    
    // Events
    event Swap(address indexed sender, IERC20 srcToken, IERC20 destToken);

    // Functions
    /**
     * @dev Contract constructor
     * @param _kyberNetworkProxyContract KyberNetworkProxy contract address
     */
    constructor (
        IKyber _kyberNetworkProxyContract
    )
        public
    {
        kyberNetworkProxyContract = _kyberNetworkProxyContract;
    }

    /**
     * @dev Swap the user's ERC20 token to another ERC20 token/ETH
     * @param srcToken source token contract address
     * @param srcQty amount of source tokens
     * @param destToken destination token contract address
     * @param destAddress address to send swapped tokens to
     * @param maxDestAmount address to send swapped tokens to
     */
    function executeSwap(
        IERC20 srcToken,
        uint srcQty,
        IERC20 destToken,
        address destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate
    )
        external
        payable
    {
    
        if (address(srcToken) != ETH_ADDRESS){
            // Check that the token transferFrom has succeeded
            require(srcToken.transferFrom(msg.sender, address(this), srcQty));

            // Set the spender's token allowance to tokenQty
            require(srcToken.approve(address(kyberNetworkProxyContract), srcQty));
        }
        
        bytes memory b;
        // Swap the ERC20 token and send to destAddress
        kyberNetworkProxyContract.tradeWithHint.value(msg.value)(
            srcToken,
            srcQty,
            destToken,
            destAddress,
            maxDestAmount,
            minConversionRate,
            address(0), //walletId for fee sharing program
            b
        );

        // Log the event
        emit Swap(msg.sender, srcToken, destToken);
    }
}
