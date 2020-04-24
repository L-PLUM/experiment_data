/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

// File: contracts/IUniswapExchange.sol

pragma solidity ^0.5.0;

// Solidity Interface

contract IUniswapExchange {
    // Address of ERC20 token sold on this exchange
    function tokenAddress() external view returns (address token);
    // Address of Uniswap Factory
    function factoryAddress() external view returns (address factory);
    // Provide Liquidity
    function addLiquidity(uint256 min_liquidity, uint256 max_tokens, uint256 deadline) external payable returns (uint256);
    function removeLiquidity(uint256 amount, uint256 min_eth, uint256 min_tokens, uint256 deadline) external returns (uint256, uint256);
    // Get Prices
    function getEthToTokenInputPrice(uint256 eth_sold) external view returns (uint256 tokens_bought);
    function getEthToTokenOutputPrice(uint256 tokens_bought) external view returns (uint256 eth_sold);
    function getTokenToEthInputPrice(uint256 tokens_sold) external view returns (uint256 eth_bought);
    function getTokenToEthOutputPrice(uint256 eth_bought) external view returns (uint256 tokens_sold);
    // Trade ETH to ERC20
    function ethToTokenSwapInput(uint256 min_tokens, uint256 deadline) external payable returns (uint256  tokens_bought);
    function ethToTokenTransferInput(uint256 min_tokens, uint256 deadline, address recipient) external payable returns (uint256  tokens_bought);
    function ethToTokenSwapOutput(uint256 tokens_bought, uint256 deadline) external payable returns (uint256  eth_sold);
    function ethToTokenTransferOutput(uint256 tokens_bought, uint256 deadline, address recipient) external payable returns (uint256  eth_sold);
    // Trade ERC20 to ETH
    function tokenToEthSwapInput(uint256 tokens_sold, uint256 min_eth, uint256 deadline) external returns (uint256  eth_bought);
    function tokenToEthTransferInput(uint256 tokens_sold, uint256 min_tokens, uint256 deadline, address recipient) external returns (uint256  eth_bought);
    function tokenToEthSwapOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline) external returns (uint256  tokens_sold);
    function tokenToEthTransferOutput(uint256 eth_bought, uint256 max_tokens, uint256 deadline, address recipient) external returns (uint256  tokens_sold);
    // Trade ERC20 to ERC20
    function tokenToTokenSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_bought);
    function tokenToTokenSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address token_addr) external returns (uint256  tokens_sold);
    function tokenToTokenTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address token_addr) external returns (uint256  tokens_sold);
    // Trade ERC20 to Custom Pool
    function tokenToExchangeSwapInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeTransferInput(uint256 tokens_sold, uint256 min_tokens_bought, uint256 min_eth_bought, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_bought);
    function tokenToExchangeSwapOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address exchange_addr) external returns (uint256  tokens_sold);
    function tokenToExchangeTransferOutput(uint256 tokens_bought, uint256 max_tokens_sold, uint256 max_eth_sold, uint256 deadline, address recipient, address exchange_addr) external returns (uint256  tokens_sold);
    // ERC20 comaptibility for liquidity tokens
    bytes32 public name;
    bytes32 public symbol;
    uint256 public decimals;
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 value) external returns (bool);
    function approve(address _spender, uint256 _value) external returns (bool);
    function allowance(address _owner, address _spender) external view returns (uint256);
    function balanceOf(address _owner) external view returns (uint256);
    // Never use
    function setup(address token_addr) external;
}

// File: contracts/IUniswapFactory.sol

pragma solidity ^0.5.0;

// Solidity Interface

contract IUniswapFactory {
    // Public Variables
    address public exchangeTemplate;
    uint256 public tokenCount;
    // Create Exchange
    function createExchange(address token) external returns (address exchange);
    // Get Exchange and Token Info
    function getExchange(address token) external view returns (address exchange);
    function getToken(address exchange) external view returns (address token);
    function getTokenWithId(uint256 tokenId) external view returns (address token);
    // Never use
    function initializeFactory(address template) external;
}

// File: contracts/IDutchExchange.sol

pragma solidity ^0.5.0;

contract IDutchExchange {


    mapping(address => mapping(address => uint)) public balances;

    // Token => Token => auctionIndex => amount
    mapping(address => mapping(address => mapping(uint => uint))) public extraTokens;

    // Token => Token =>  auctionIndex => user => amount
    mapping(address => mapping(address => mapping(uint => mapping(address => uint)))) public sellerBalances;
    mapping(address => mapping(address => mapping(uint => mapping(address => uint)))) public buyerBalances;
    mapping(address => mapping(address => mapping(uint => mapping(address => uint)))) public claimedAmounts;

    
    function ethToken() public returns(address);
    function claimBuyerFunds(address, address, address, uint) public returns(uint, uint);
    function deposit(address tokenAddress, uint amount) public returns (uint);
    function withdraw(address tokenAddress, uint amount) public returns (uint);
    function getAuctionIndex(address token1, address token2) public returns(uint256);
    function postBuyOrder(address token1, address token2, uint256 auctionIndex, uint256 amount) public returns(uint256);
    function postSellOrder(address token1, address token2, uint256 auctionIndex, uint256 tokensBought) public returns(uint256, uint256);
    function getCurrentAuctionPrice(address token1, address token2, uint256 auctionIndex) public view returns(uint256, uint256);
    function claimAndWithdrawTokensFromSeveralAuctionsAsBuyer(address[] calldata, address[] calldata, uint[] calldata) external view returns(uint[] memory, uint);
}

// File: contracts/ITokenMinimal.sol

pragma solidity ^0.5.0;

contract ITokenMinimal {
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function balanceOf(address tokenOwner) public view returns (uint balance);
}

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

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

// File: @gnosis.pm/mock-contract/contracts/MockContract.sol

pragma solidity ^0.5.0;

interface MockInterface {
	/**
	 * @dev After calling this method, the mock will return `response` when it is called
	 * with any calldata that is not mocked more specifically below
	 * (e.g. using givenMethodReturn).
	 * @param response ABI encoded response that will be returned if method is invoked
	 */
	function givenAnyReturn(bytes calldata response) external;
	function givenAnyReturnBool(bool response) external;
	function givenAnyReturnUint(uint response) external;
	function givenAnyReturnAddress(address response) external;

	function givenAnyRevert() external;
	function givenAnyRevertWithMessage(string calldata message) external;
	function givenAnyRunOutOfGas() external;

	/**
	 * @dev After calling this method, the mock will return `response` when the given
	 * methodId is called regardless of arguments. If the methodId and arguments
	 * are mocked more specifically (using `givenMethodAndArguments`) the latter
	 * will take precedence.
	 * @param method ABI encoded methodId. It is valid to pass full calldata (including arguments). The mock will extract the methodId from it
	 * @param response ABI encoded response that will be returned if method is invoked
	 */
	function givenMethodReturn(bytes calldata method, bytes calldata response) external;
	function givenMethodReturnBool(bytes calldata method, bool response) external;
	function givenMethodReturnUint(bytes calldata method, uint response) external;
	function givenMethodReturnAddress(bytes calldata method, address response) external;

	function givenMethodRevert(bytes calldata method) external;
	function givenMethodRevertWithMessage(bytes calldata method, string calldata message) external;
	function givenMethodRunOutOfGas(bytes calldata method) external;

	/**
	 * @dev After calling this method, the mock will return `response` when the given
	 * methodId is called with matching arguments. These exact calldataMocks will take
	 * precedence over all other calldataMocks.
	 * @param call ABI encoded calldata (methodId and arguments)
	 * @param response ABI encoded response that will be returned if contract is invoked with calldata
	 */
	function givenCalldataReturn(bytes calldata call, bytes calldata response) external;
	function givenCalldataReturnBool(bytes calldata call, bool response) external;
	function givenCalldataReturnUint(bytes calldata call, uint response) external;
	function givenCalldataReturnAddress(bytes calldata call, address response) external;

	function givenCalldataRevert(bytes calldata call) external;
	function givenCalldataRevertWithMessage(bytes calldata call, string calldata message) external;
	function givenCalldataRunOutOfGas(bytes calldata call) external;

	/**
	 * @dev Returns the number of times anything has been called on this mock since last reset
	 */
	function invocationCount() external returns (uint);

	/**
	 * @dev Returns the number of times the given method has been called on this mock since last reset
	 * @param method ABI encoded methodId. It is valid to pass full calldata (including arguments). The mock will extract the methodId from it
	 */
	function invocationCountForMethod(bytes calldata method) external returns (uint);

	/**
	 * @dev Returns the number of times this mock has been called with the exact calldata since last reset.
	 * @param call ABI encoded calldata (methodId and arguments)
	 */
	function invocationCountForCalldata(bytes calldata call) external returns (uint);

	/**
	 * @dev Resets all mocked methods and invocation counts.
	 */
	 function reset() external;
}

/**
 * Implementation of the MockInterface.
 */
contract MockContract is MockInterface {
	enum MockType { Return, Revert, OutOfGas }
	
	bytes32 public constant MOCKS_LIST_START = hex"01";
	bytes public constant MOCKS_LIST_END = "0xff";
	bytes32 public constant MOCKS_LIST_END_HASH = keccak256(MOCKS_LIST_END);
	bytes4 public constant SENTINEL_ANY_MOCKS = hex"01";

	// A linked list allows easy iteration and inclusion checks
	mapping(bytes32 => bytes) calldataMocks;
	mapping(bytes => MockType) calldataMockTypes;
	mapping(bytes => bytes) calldataExpectations;
	mapping(bytes => string) calldataRevertMessage;
	mapping(bytes32 => uint) calldataInvocations;

	mapping(bytes4 => bytes4) methodIdMocks;
	mapping(bytes4 => MockType) methodIdMockTypes;
	mapping(bytes4 => bytes) methodIdExpectations;
	mapping(bytes4 => string) methodIdRevertMessages;
	mapping(bytes32 => uint) methodIdInvocations;

	MockType fallbackMockType;
	bytes fallbackExpectation;
	string fallbackRevertMessage;
	uint invocations;
	uint resetCount;

	constructor() public {
		calldataMocks[MOCKS_LIST_START] = MOCKS_LIST_END;
		methodIdMocks[SENTINEL_ANY_MOCKS] = SENTINEL_ANY_MOCKS;
	}

	function trackCalldataMock(bytes memory call) private {
		bytes32 callHash = keccak256(call);
		if (calldataMocks[callHash].length == 0) {
			calldataMocks[callHash] = calldataMocks[MOCKS_LIST_START];
			calldataMocks[MOCKS_LIST_START] = call;
		}
	}

	function trackMethodIdMock(bytes4 methodId) private {
		if (methodIdMocks[methodId] == 0x0) {
			methodIdMocks[methodId] = methodIdMocks[SENTINEL_ANY_MOCKS];
			methodIdMocks[SENTINEL_ANY_MOCKS] = methodId;
		}
	}

	function _givenAnyReturn(bytes memory response) internal {
		fallbackMockType = MockType.Return;
		fallbackExpectation = response;
	}

	function givenAnyReturn(bytes calldata response) external {
		_givenAnyReturn(response);
	}

	function givenAnyReturnBool(bool response) external {
		uint flag = response ? 1 : 0;
		_givenAnyReturn(uintToBytes(flag));
	}

	function givenAnyReturnUint(uint response) external {
		_givenAnyReturn(uintToBytes(response));	
	}

	function givenAnyReturnAddress(address response) external {
		_givenAnyReturn(uintToBytes(uint(response)));
	}

	function givenAnyRevert() external {
		fallbackMockType = MockType.Revert;
		fallbackRevertMessage = "";
	}

	function givenAnyRevertWithMessage(string calldata message) external {
		fallbackMockType = MockType.Revert;
		fallbackRevertMessage = message;
	}

	function givenAnyRunOutOfGas() external {
		fallbackMockType = MockType.OutOfGas;
	}

	function _givenCalldataReturn(bytes memory call, bytes memory response) private  {
		calldataMockTypes[call] = MockType.Return;
		calldataExpectations[call] = response;
		trackCalldataMock(call);
	}

	function givenCalldataReturn(bytes calldata call, bytes calldata response) external  {
		_givenCalldataReturn(call, response);
	}

	function givenCalldataReturnBool(bytes calldata call, bool response) external {
		uint flag = response ? 1 : 0;
		_givenCalldataReturn(call, uintToBytes(flag));
	}

	function givenCalldataReturnUint(bytes calldata call, uint response) external {
		_givenCalldataReturn(call, uintToBytes(response));
	}

	function givenCalldataReturnAddress(bytes calldata call, address response) external {
		_givenCalldataReturn(call, uintToBytes(uint(response)));
	}

	function _givenMethodReturn(bytes memory call, bytes memory response) private {
		bytes4 method = bytesToBytes4(call);
		methodIdMockTypes[method] = MockType.Return;
		methodIdExpectations[method] = response;
		trackMethodIdMock(method);		
	}

	function givenMethodReturn(bytes calldata call, bytes calldata response) external {
		_givenMethodReturn(call, response);
	}

	function givenMethodReturnBool(bytes calldata call, bool response) external {
		uint flag = response ? 1 : 0;
		_givenMethodReturn(call, uintToBytes(flag));
	}

	function givenMethodReturnUint(bytes calldata call, uint response) external {
		_givenMethodReturn(call, uintToBytes(response));
	}

	function givenMethodReturnAddress(bytes calldata call, address response) external {
		_givenMethodReturn(call, uintToBytes(uint(response)));
	}

	function givenCalldataRevert(bytes calldata call) external {
		calldataMockTypes[call] = MockType.Revert;
		calldataRevertMessage[call] = "";
		trackCalldataMock(call);
	}

	function givenMethodRevert(bytes calldata call) external {
		bytes4 method = bytesToBytes4(call);
		methodIdMockTypes[method] = MockType.Revert;
		trackMethodIdMock(method);		
	}

	function givenCalldataRevertWithMessage(bytes calldata call, string calldata message) external {
		calldataMockTypes[call] = MockType.Revert;
		calldataRevertMessage[call] = message;
		trackCalldataMock(call);
	}

	function givenMethodRevertWithMessage(bytes calldata call, string calldata message) external {
		bytes4 method = bytesToBytes4(call);
		methodIdMockTypes[method] = MockType.Revert;
		methodIdRevertMessages[method] = message;
		trackMethodIdMock(method);		
	}

	function givenCalldataRunOutOfGas(bytes calldata call) external {
		calldataMockTypes[call] = MockType.OutOfGas;
		trackCalldataMock(call);
	}

	function givenMethodRunOutOfGas(bytes calldata call) external {
		bytes4 method = bytesToBytes4(call);
		methodIdMockTypes[method] = MockType.OutOfGas;
		trackMethodIdMock(method);	
	}

	function invocationCount() external returns (uint) {
		return invocations;
	}

	function invocationCountForMethod(bytes calldata call) external returns (uint) {
		bytes4 method = bytesToBytes4(call);
		return methodIdInvocations[keccak256(abi.encodePacked(resetCount, method))];
	}

	function invocationCountForCalldata(bytes calldata call) external returns (uint) {
		return calldataInvocations[keccak256(abi.encodePacked(resetCount, call))];
	}

	function reset() external {
		// Reset all exact calldataMocks
		bytes memory nextMock = calldataMocks[MOCKS_LIST_START];
		bytes32 mockHash = keccak256(nextMock);
		// We cannot compary bytes
		while(mockHash != MOCKS_LIST_END_HASH) {
			// Reset all mock maps
			calldataMockTypes[nextMock] = MockType.Return;
			calldataExpectations[nextMock] = hex"";
			calldataRevertMessage[nextMock] = "";
			// Set next mock to remove
			nextMock = calldataMocks[mockHash];
			// Remove from linked list
			calldataMocks[mockHash] = "";
			// Update mock hash
			mockHash = keccak256(nextMock);
		}
		// Clear list
		calldataMocks[MOCKS_LIST_START] = MOCKS_LIST_END;

		// Reset all any calldataMocks
		bytes4 nextAnyMock = methodIdMocks[SENTINEL_ANY_MOCKS];
		while(nextAnyMock != SENTINEL_ANY_MOCKS) {
			bytes4 currentAnyMock = nextAnyMock;
			methodIdMockTypes[currentAnyMock] = MockType.Return;
			methodIdExpectations[currentAnyMock] = hex"";
			methodIdRevertMessages[currentAnyMock] = "";
			nextAnyMock = methodIdMocks[currentAnyMock];
			// Remove from linked list
			methodIdMocks[currentAnyMock] = 0x0;
		}
		// Clear list
		methodIdMocks[SENTINEL_ANY_MOCKS] = SENTINEL_ANY_MOCKS;

		fallbackExpectation = "";
		fallbackMockType = MockType.Return;
		invocations = 0;
		resetCount += 1;
	}

	function useAllGas() private {
		while(true) {
			bool s;
			assembly {
				//expensive call to EC multiply contract
				s := call(sub(gas, 2000), 6, 0, 0x0, 0xc0, 0x0, 0x60)
			}
		}
	}

	function bytesToBytes4(bytes memory b) private pure returns (bytes4) {
		bytes4 out;
		for (uint i = 0; i < 4; i++) {
			out |= bytes4(b[i] & 0xFF) >> (i * 8);
		}
		return out;
	}

	function uintToBytes(uint256 x) private pure returns (bytes memory b) {
		b = new bytes(32);
		assembly { mstore(add(b, 32), x) }
	}

	function updateInvocationCount(bytes4 methodId, bytes memory originalMsgData) public {
		require(msg.sender == address(this), "Can only be called from the contract itself");
		invocations += 1;
		methodIdInvocations[keccak256(abi.encodePacked(resetCount, methodId))] += 1;
		calldataInvocations[keccak256(abi.encodePacked(resetCount, originalMsgData))] += 1;
	}

	function() payable external {
		bytes4 methodId;
		assembly {
			methodId := calldataload(0)
		}

		// First, check exact matching overrides
		if (calldataMockTypes[msg.data] == MockType.Revert) {
			revert(calldataRevertMessage[msg.data]);
		}
		if (calldataMockTypes[msg.data] == MockType.OutOfGas) {
			useAllGas();
		}
		bytes memory result = calldataExpectations[msg.data];

		// Then check method Id overrides
		if (result.length == 0) {
			if (methodIdMockTypes[methodId] == MockType.Revert) {
				revert(methodIdRevertMessages[methodId]);
			}
			if (methodIdMockTypes[methodId] == MockType.OutOfGas) {
				useAllGas();
			}
			result = methodIdExpectations[methodId];
		}

		// Last, use the fallback override
		if (result.length == 0) {
			if (fallbackMockType == MockType.Revert) {
				revert(fallbackRevertMessage);
			}
			if (fallbackMockType == MockType.OutOfGas) {
				useAllGas();
			}
			result = fallbackExpectation;
		}

		// Record invocation as separate call so we don't rollback in case we are called with STATICCALL
		(, bytes memory r) = address(this).call.gas(100000)(abi.encodeWithSignature("updateInvocationCount(bytes4,bytes)", methodId, msg.data));
		assert(r.length == 0);
		
		assembly {
			return(add(0x20, result), mload(result))
		}
	}
}

// File: contracts/Arbitrage.sol

pragma solidity ^0.5.0;







/// @title Uniswap Arbitrage Module - Executes arbitrage transactions between Uniswap and DutchX.
/// @author Billy Rennekamp - <[email protected]>
contract Arbitrage is Ownable {
    
    uint constant max = uint(-1);

    IUniswapFactory uniFactory; 
    IDutchExchange dutchXProxy;

    event Profit(uint profit, bool wasDutchOpportunity);

    /// @dev Payable fallback function has nothing inside so it won't run out of gas with gas limited transfers
    function() external payable {}

    /// @dev Only owner can deposit contract Ether into the DutchX as WETH
    function depositEther() public payable onlyOwner {

        require(address(this).balance > 0, "Balance must be greater than 0 to deposit");
        uint balance = address(this).balance;

        // Deposit balance to WETH
        address weth = dutchXProxy.ethToken();
        bytes memory payload = abi.encodeWithSignature("deposit()");
        // solium-disable-next-line security/no-call-value
        (bool success, ) = weth.call.value(balance).gas(200000)(payload);
        require(success, "Converting Ether to WETH didn't work.");

        uint wethBalance = ITokenMinimal(weth).balanceOf(address(this));
        uint allowance = ITokenMinimal(weth).allowance(address(this), address(dutchXProxy));
        if (wethBalance < allowance) {
            // Approve max amount of WETH to be transferred by dutchX
            // Keeping it max will have same or similar costs to making it exact over and over again
            // 200000 was common gas amount added to similar transactions although typically used only ~30k—50k
            // success is not guaranteed by success boolean, returnData deemed unnecessary to decode
            payload = abi.encodeWithSignature("approve(address,uint256)", address(dutchXProxy), max);
            // solium-disable-next-line security/no-call-value
            (bool secondSuccess, bytes memory returnData) = weth.call.value(0).gas(200000)(payload);
            require(secondSuccess, "Approve WETH to be transferred by DutchX didn't work.");
            require(returnData.length == 0 || (returnData.length == 32 && (returnData[31] != 0)), "Approve WETH to be transferred by DutchX didn't return true.");
        }

        // Deposit new amount on dutchX, confirm there's at least the amount we just deposited
        uint newBalance = dutchXProxy.deposit(weth, balance);
        require(newBalance >= balance, "Deposit WETH to DutchX didn't work.");
    }

    /// @dev Only owner can withdraw WETH from DutchX, convert to Ether and transfer to owner
    /// @param amount The amount of Ether to withdraw
    function withdrawEtherThenTransfer(uint amount) external onlyOwner {
        _withdrawEther(amount);
        address(uint160(owner())).transfer(amount);
    }

    /// @dev Only owner can transfer any Ether currently in the contract to the owner address.
    /// @param amount The amount of Ether to withdraw
    function transferEther(uint amount) external onlyOwner {
        // If amount is zero, deposit the entire contract balance.
        address(uint160(owner())).transfer(amount == 0 ? address(this).balance : amount);
    }

    
    /// @dev Only owner function to withdraw WETH from the DutchX, convert it to Ether and keep it in contract
    /// @param amount The amount of WETH to withdraw and convert.
    function withdrawEther(uint amount) external onlyOwner {
        _withdrawEther(amount);
    }

    /// @dev Internal function to withdraw WETH from the DutchX, convert it to Ether and keep it in contract
    /// @param amount The amount of WETH to withdraw and convert.
    function _withdrawEther(uint amount) internal {

        address weth = dutchXProxy.ethToken();
        dutchXProxy.withdraw(weth, amount);

        // 200000 was common gas amount added to similar transactions although typically used only ~30k—50k
        // success is not guaranteed by success boolean, returnData deemed unnecessary to decode
        bytes memory payload = abi.encodeWithSignature("withdraw(uint256)", amount);
        // solium-disable-next-line security/no-call-value
        (bool success, ) = weth.call.value(0).gas(200000)(payload);
        require(success, "Withdraw of Ether from WETH didn't work.");
    }

    /// @dev Only owner can withdraw a token from the DutchX
    /// @param token The token address that is being withdrawn.
    /// @param amount The amount of token to withdraw. Can be larger than available balance and maximum will be withdrawn.
    /// @return Returns the amount actually withdrawn from the DutchX
    function withdrawToken(address token, uint amount) external onlyOwner returns (uint) {
        return dutchXProxy.withdraw(token, amount);
    }

    /// @dev Only owner can transfer tokens to the owner that belong to this contract
    /// @param token The token address that is being transferred.
    /// @param amount The amount of token to transfer.
    function transferToken(address token, uint amount) external onlyOwner {

        // 200000 was common gas amount added to similar transactions although typically used only ~30k—50k
        // success is not guaranteed by success boolean, returnData deemed unnecessary to decode
        bytes memory payload = abi.encodeWithSignature("transfer(address,uint256)", owner(), amount);
        // solium-disable-next-line security/no-call-value
        (bool success, bytes memory returnData) = token.call.value(0).gas(200000)(payload);
        require(success, "Transfer token didn't work.");
        require(returnData.length == 0 || (returnData.length == 32 && (returnData[31] != 0)), "Transfer token return true.");
    }

    /// @dev Only owner can deposit token to the DutchX
    /// @param token The token address that is being deposited.
    /// @param amount The amount of token to deposit.
    function depositToken(address token, uint amount) external onlyOwner {
        _depositToken(token, amount);
    }

    /// @dev Internal function to deposit token to the DutchX
    /// @param token The token address that is being deposited.
    /// @param amount The amount of token to deposit.
    function _depositToken(address token, uint amount) internal {

        uint allowance = ITokenMinimal(token).allowance(address(this), address(dutchXProxy));
        if (allowance < amount) {
            // 200000 was common gas amount added to similar transactions although typically used only ~30k—50k
            // success is not guaranteed by success boolean, returnData deemed unnecessary to decode
            bytes memory payload = abi.encodeWithSignature("approve(address,uint256)", address(dutchXProxy), max);
            // solium-disable-next-line security/no-call-value
            (bool success, bytes memory returnData) = token.call.value(0).gas(200000)(payload);
            require(success, "Approve token to be transferred by DutchX didn't work.");
            require(returnData.length == 0 || (returnData.length == 32 && (returnData[31] != 0)), "Approve token to be transferred by DutchX didn't return true.");
        }

        // Confirm that the balance of the token on the DutchX is at least how much was deposited
        uint newBalance = dutchXProxy.deposit(token, amount);
        require(newBalance >= amount, "deposit didn't work");
    }

    event Debug(uint);
    event DebugAdd(address);

    /// @dev Executes a trade opportunity on dutchX. Assumes that there is a balance of WETH already on the dutchX 
    /// @param arbToken Address of the token that should be arbitraged.
    /// @param amount Amount of Ether to use in arbitrage.
    /// @return Returns if transaction can be executed.
    function dutchOpportunity(address arbToken, uint256 amount) external {

        address etherToken = dutchXProxy.ethToken();

        // The order of parameters for getAuctionIndex don't matter
        uint256 dutchAuctionIndex = dutchXProxy.getAuctionIndex(arbToken, etherToken);

        // postBuyOrder(sellToken, buyToken, amount)
        // results in a decrease of the amount the user owns of the second token
        // which means the buyToken is what the buyer wants to get rid of.
        // "The buy token is what the buyer provides, the seller token is what the seller provides."
        dutchXProxy.postBuyOrder(arbToken, etherToken, dutchAuctionIndex, amount);

        (uint tokensBought, ) = dutchXProxy.claimBuyerFunds(arbToken, etherToken, address(this), dutchAuctionIndex);
        dutchXProxy.withdraw(arbToken, tokensBought);

        address uniswapExchange = uniFactory.getExchange(arbToken);

        uint allowance = ITokenMinimal(arbToken).allowance(address(this), address(uniswapExchange));
        if (allowance < tokensBought) {
            // Approve Uniswap to transfer arbToken on contract's behalf
            // Keeping it max will have same or similar costs to making it exact over and over again
            // 200000 was common gas amount added to similar transactions although typically used only ~30k—50k
            // success is not guaranteed by success boolean, returnData deemed unnecessary to decode
            bytes memory payload = abi.encodeWithSignature("approve(address,uint256)", address(uniswapExchange), max);
            // solium-disable-next-line security/no-call-value
            (bool success, bytes memory returnData) = arbToken.call.value(0).gas(200000)(payload);
            require(success, "Approve arbToken to be transferred by Uniswap didn't work");
            require(returnData.length == 0 || (returnData.length == 32 && (returnData[31] != 0)), "Approve arbToken to be transferred by Uniswap didn't return true");
        }

        // tokenToEthSwapInput(inputToken, minimumReturn, timeToLive)
        // minimumReturn is enough to make a profit (excluding gas)
        // timeToLive is now because transaction is atomic
        uint256 etherReturned = IUniswapExchange(uniswapExchange).tokenToEthSwapInput(tokensBought, 1, block.timestamp);

        // gas costs were excluded because worse case scenario the tx fails and gas costs were spent up to here anyway
        // best worst case scenario the profit from the trade alleviates part of the gas costs even if still no total profit
        require(etherReturned >= amount, "no profit");
        emit Profit(etherReturned, true);

        // Ether is deposited as WETH
        depositEther();
    }

    /// @dev Executes a trade opportunity on uniswap.
    /// @param arbToken Address of the token that should be arbitraged.
    /// @param amount Amount of Ether to use in arbitrage.
    /// @return Returns if transaction can be executed.
    function uniswapOpportunity(address arbToken, uint256 amount) external {

        // WETH must be converted to Eth for Uniswap trade
        // (Uniswap allows ERC20:ERC20 but most liquidity is on ETH:ERC20 markets)
        _withdrawEther(amount);
        require(address(this).balance >= amount, "buying from uniswap takes real Ether");

        // ethToTokenSwapInput(minTokens, deadline)
        // minTokens is 1 because it will revert without a profit regardless
        // deadline is now since trade is atomic
        // solium-disable-next-line security/no-block-members
        uint256 tokensBought = IUniswapExchange(uniFactory.getExchange(arbToken)).ethToTokenSwapInput.value(amount)(1, block.timestamp);
        
        // tokens need to be approved for the dutchX before they are deposited
        _depositToken(arbToken, tokensBought);

        address etherToken = dutchXProxy.ethToken();
        
        // The order of parameters for getAuctionIndex don't matter
        uint256 dutchAuctionIndex = dutchXProxy.getAuctionIndex(arbToken, etherToken);

        // spend max amount of tokens currently on the dutch x (might be combined from previous remainders)
        // max is automatically reduced to maximum available tokens because there may be
        // token remainders from previous auctions which closed after previous arbitrage opportunities
        dutchXProxy.postBuyOrder(etherToken, arbToken, dutchAuctionIndex, max);
        // solium-disable-next-line no-unused-vars
        (uint etherReturned, ) = dutchXProxy.claimBuyerFunds(etherToken, arbToken, address(this), dutchAuctionIndex);
        
        // gas costs were excluded because worse case scenario the tx fails and gas costs were spent up to here anyway
        // best worst case scenario the profit from the trade alleviates part of the gas costs even if still no total profit
        require(etherReturned >= amount, "no profit");
        emit Profit(etherReturned, false);

        // Ether returned is already in dutchX balance where Ether is assumed to be stored when not being used.
    }
    
}

// File: contracts/ArbitrageRinkeby.sol

pragma solidity ^0.5.0;

/// @title Uniswap Arbitrage Module - Executes arbitrage transactions between Uniswap and DutchX.
/// @author Billy Rennekamp - <[email protected]>
contract ArbitrageRinkeby is Arbitrage {
    IUniswapFactory uniFactory = IUniswapFactory(0xf5D915570BC477f9B8D6C0E980aA81757A3AaC36); 
    IDutchExchange dutchXProxy = IDutchExchange(0x4e69969D9270fF55fc7c5043B074d4e45F795587);
}
