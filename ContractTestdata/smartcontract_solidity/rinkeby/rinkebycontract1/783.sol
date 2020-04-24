/**
 *Submitted for verification at Etherscan.io on 2019-02-07
*/

pragma solidity 0.5.0;

// File: flattened.sol

// @title DutchX Token Interface - Represents the allowed methods of ERC20 token contracts to be executed from the safe module DutchXModule
/// @author Denis Granha - <[email protected]>
interface DutchXTokenInterface {
	function transfer(address to, uint value) external;
    function approve(address spender, uint amount) external;
    function deposit() external payable;
    function withdraw() external;
}

// @title DutchX Interface - Represents the allowed methods to be executed from the safe module DutchXModule
/// @author Denis Granha - <[email protected]>
interface DutchXInterface {
	function deposit(address token, uint256 amount) external;
    function postSellOrder(address sellToken, address buyToken, uint256 auctionIndex, uint256 amount) external;
    function postBuyOrder(address sellToken, address buyToken, uint256 auctionIndex, uint256 amount) external;

    function claimTokensFromSeveralAuctionsAsBuyer(
        address[] calldata auctionSellTokens,
        address[] calldata auctionBuyTokens,
        uint[] calldata auctionIndices,
        address user
    ) external;

    function claimTokensFromSeveralAuctionsAsSeller(
        address[] calldata auctionSellTokens,
        address[] calldata auctionBuyTokens,
        uint[] calldata auctionIndices,
        address user
    ) external;

    function withdraw() external;
}

/// @title Enum - Collection of enums
/// @author Richard Meissner - <[email protected]>
contract Enum {
    enum Operation {
        Call,
        DelegateCall,
        Create
    }
}


/// @title SelfAuthorized - authorizes current contract to perform actions
/// @author Richard Meissner - <[email protected]>
contract SelfAuthorized {
    modifier authorized() {
        require(msg.sender == address(this), "Method can only be called from this contract");
        _;
    }
}


/// @title EtherPaymentFallback - A contract that has a fallback to accept ether payments
/// @author Richard Meissner - <[email protected]>
contract EtherPaymentFallback {

    /// @dev Fallback function accepts Ether transactions.
    function ()
        external
        payable
    {

    }
}



/// @title Executor - A contract that can execute transactions
/// @author Richard Meissner - <[email protected]>
contract Executor is EtherPaymentFallback {

    event ContractCreation(address newContract);

    function execute(address to, uint256 value, bytes memory data, Enum.Operation operation, uint256 txGas)
        internal
        returns (bool success)
    {
        if (operation == Enum.Operation.Call)
            success = executeCall(to, value, data, txGas);
        else if (operation == Enum.Operation.DelegateCall)
            success = executeDelegateCall(to, data, txGas);
        else {
            address newContract = executeCreate(data);
            success = newContract != address(0);
            emit ContractCreation(newContract);
        }
    }

    function executeCall(address to, uint256 value, bytes memory data, uint256 txGas)
        internal
        returns (bool success)
    {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := call(txGas, to, value, add(data, 0x20), mload(data), 0, 0)
        }
    }

    function executeDelegateCall(address to, bytes memory data, uint256 txGas)
        internal
        returns (bool success)
    {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            success := delegatecall(txGas, to, add(data, 0x20), mload(data), 0, 0)
        }
    }

    function executeCreate(bytes memory data)
        internal
        returns (address newContract)
    {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            newContract := create(0, add(data, 0x20), mload(data))
        }
    }
}



/// @title Module Manager - A contract that manages modules that can execute transactions via this contract
/// @author Stefan George - <[email protected]>
/// @author Richard Meissner - <[email protected]>
contract ModuleManager is SelfAuthorized, Executor {

    event EnabledModule(Module module);
    event DisabledModule(Module module);

    address public constant SENTINEL_MODULES = address(0x1);

    mapping (address => address) internal modules;

    function setupModules(address to, bytes memory data)
        internal
    {
        require(modules[SENTINEL_MODULES] == address(0), "Modules have already been initialized");
        modules[SENTINEL_MODULES] = SENTINEL_MODULES;
        if (to != address(0))
            // Setup has to complete successfully or transaction fails.
            require(executeDelegateCall(to, data, gasleft()), "Could not finish initialization");
    }

    /// @dev Allows to add a module to the whitelist.
    ///      This can only be done via a Safe transaction.
    /// @param module Module to be whitelisted.
    function enableModule(Module module)
        public
        authorized
    {
        // Module address cannot be null or sentinel.
        require(address(module) != address(0) && address(module) != SENTINEL_MODULES, "Invalid module address provided");
        // Module cannot be added twice.
        require(modules[address(module)] == address(0), "Module has already been added");
        modules[address(module)] = modules[SENTINEL_MODULES];
        modules[SENTINEL_MODULES] = address(module);
        emit EnabledModule(module);
    }

    /// @dev Allows to remove a module from the whitelist.
    ///      This can only be done via a Safe transaction.
    /// @param prevModule Module that pointed to the module to be removed in the linked list
    /// @param module Module to be removed.
    function disableModule(Module prevModule, Module module)
        public
        authorized
    {
        // Validate module address and check that it corresponds to module index.
        require(address(module) != address(0) && address(module) != SENTINEL_MODULES, "Invalid module address provided");
        require(modules[address(prevModule)] == address(module), "Invalid prevModule, module pair provided");
        modules[address(prevModule)] = modules[address(module)];
        modules[address(module)] = address(0);
        emit DisabledModule(module);
    }

    /// @dev Allows a Module to execute a Safe transaction without any further confirmations.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction.
    function execTransactionFromModule(address to, uint256 value, bytes memory data, Enum.Operation operation)
        public
        returns (bool success)
    {
        // Only whitelisted modules are allowed.
        require(msg.sender != SENTINEL_MODULES && modules[msg.sender] != address(0), "Method can only be called from an enabled module");
        // Execute transaction without further confirmations.
        success = execute(to, value, data, operation, gasleft());
    }

    /// @dev Returns array of modules.
    /// @return Array of modules.
    function getModules()
        public
        view
        returns (address[] memory)
    {
        // Calculate module count
        uint256 moduleCount = 0;
        address currentModule = modules[SENTINEL_MODULES];
        while(currentModule != SENTINEL_MODULES) {
            currentModule = modules[currentModule];
            moduleCount ++;
        }
        address[] memory array = new address[](moduleCount);

        // populate return array
        moduleCount = 0;
        currentModule = modules[SENTINEL_MODULES];
        while(currentModule != SENTINEL_MODULES) {
            array[moduleCount] = currentModule;
            currentModule = modules[currentModule];
            moduleCount ++;
        }
        return array;
    }
}



/// @title MasterCopy - Base for master copy contracts (should always be first super contract)
/// @author Richard Meissner - <[email protected]>
contract MasterCopy is SelfAuthorized {
  // masterCopy always needs to be first declared variable, to ensure that it is at the same location as in the Proxy contract.
  // It should also always be ensured that the address is stored alone (uses a full word)
    address masterCopy;

  /// @dev Allows to upgrade the contract. This can only be done via a Safe transaction.
  /// @param _masterCopy New contract address.
    function changeMasterCopy(address _masterCopy)
        public
        authorized
    {
        // Master copy address cannot be null.
        require(_masterCopy != address(0), "Invalid master copy address provided");
        masterCopy = _masterCopy;
    }
}


/// @title Module - Base class for modules.
/// @author Stefan George - <[email protected]>
/// @author Richard Meissner - <[email protected]>
contract Module is MasterCopy {

    ModuleManager public manager;

    modifier authorized() {
        require(msg.sender == address(manager), "Method can only be called from manager");
        _;
    }

    function setManager()
        internal
    {
        // manager can only be 0 at initalization of contract.
        // Check ensures that setup function can only be called once.
        require(address(manager) == address(0), "Manager has already been set");
        manager = ModuleManager(msg.sender);
    }
}



/// @title DutchX Base Module - Expose a set of methods to enable a Safe to interact with a DX
/// @author Denis Granha - <[email protected]>
contract DutchXBaseModule is Module {

  address public dutchXAddress;
  // isWhitelistedToken mapping maps destination address to boolean.
  mapping (address => bool) public isWhitelistedToken;
  mapping (address => bool) public isOperator;

  /// @dev Setup function sets initial storage of contract.
  /// @param dx DutchX Proxy Address.
  /// @param tokens List of whitelisted tokens.
  function setup(address dx, address[] memory tokens, address[] memory operators)
      public
  {
      setManager();
      dutchXAddress = dx;

      for (uint256 i = 0; i < tokens.length; i++) {
          address token = tokens[i];
          require(token != address(0), "Invalid token provided");
          isWhitelistedToken[token] = true;
      }
      for (uint256 i = 0; i < operators.length; i++) {
          address operator = operators[i];
          require(operator != address(0), "Invalid operator address provided");
          isOperator[operator] = true;
      }
  }

  /// @dev Allows to add token to whitelist. This can only be done via a Safe transaction.
  /// @param token ERC20 token address.
  function addToWhitelist(address token)
      public
      authorized
  {
      require(token != address(0), "Invalid token provided");
      require(!isWhitelistedToken[token], "Token is already whitelisted");
      isWhitelistedToken[token] = true;
  }

  /// @dev Allows to remove token from whitelist. This can only be done via a Safe transaction.
  /// @param token ERC20 token address.
  function removeFromWhitelist(address token)
      public
      authorized
  {
      require(isWhitelistedToken[token], "Token is not whitelisted");
      isWhitelistedToken[token] = false;
  }

  /// @dev Allows to add operator to whitelist. This can only be done via a Safe transaction.
  /// @param operator ethereum address.
  function addOperator(address operator)
      public
      authorized
  {
      require(operator != address(0), "Invalid address provided");
      require(!isOperator[operator], "Operator is already whitelisted");
      isOperator[operator] = true;
  }

  /// @dev Allows to remove operator from whitelist. This can only be done via a Safe transaction.
  /// @param operator ethereum address.
  function removeOperator(address operator)
      public
      authorized
  {
      require(isOperator[operator], "Operator is not whitelisted");
      isOperator[operator] = false;
  }

  /// @dev Allows to change DutchX Proxy contract address. This can only be done via a Safe transaction.
  /// @param dx New proxy contract address for DutchX.
  function changeDXProxy(address dx)
      public
      authorized
  {
      require(dx != address(0), "Invalid address provided");
      dutchXAddress = dx;
  }

  /// @dev Abstract method. Returns if Safe transaction is to DutchX contract and with whitelisted tokens.
  /// @param to Dutch X address or Whitelisted token (only for approve operations for DX).
  /// @param value Not checked.
  /// @param data Allowed operations
  /// @return Returns if transaction can be executed.
  function executeWhitelisted(address to, uint256 value, bytes memory data)
      public
      returns (bool);

}

/// @title DutchX Module - Allows to execute transactions to DutchX contract for whitelisted token pairs without confirmations and deposit tokens in the DutchX.
/// @author Denis Granha - <[email protected]>
contract DutchXCompleteModule is DutchXBaseModule {

    string public constant NAME = "DutchX Complete Module";
    string public constant VERSION = "0.0.2";

    /// @dev Returns if Safe transaction is to DutchX contract and with whitelisted tokens.
    /// @param to Dutch X address or Whitelisted token (only for approve operations for DX).
    /// @param value Not checked.
    /// @param data Allowed operations (postSellOrder, postBuyOrder, claimTokensFromSeveralAuctionsAsBuyer, claimTokensFromSeveralAuctionsAsSeller, deposit).
    /// @return Returns if transaction can be executed.
    function executeWhitelisted(address to, uint256 value, bytes memory data)
        public
        returns (bool)
    {

        // Load allowed method interfaces
        DutchXTokenInterface tokenInterface;
        DutchXInterface dxInterface;

        // Only Safe owners are allowed to execute transactions to whitelisted accounts.
        require(isOperator[msg.sender], "Method can only be called by an operator");

        // Only DutchX Proxy and Whitelisted tokens are allowed as destination
        require(to == dutchXAddress || isWhitelistedToken[to], "Destination address is not allowed");

        // Decode data
        bytes4 functionIdentifier;
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            functionIdentifier := mload(add(data, 0x20))
        }

        // Only approve tokens function and deposit (in the case of WETH) is allowed against token contracts, and DutchX proxy must be the spender (for approve)
        if (functionIdentifier != tokenInterface.deposit.selector){
            require(value == 0, "Eth transactions only allowed for wrapping ETH");
        }

        // Only these functions:
        // PostSellOrder, postBuyOrder, claimTokensFromSeveralAuctionsAsBuyer, claimTokensFromSeveralAuctionsAsSeller, deposit
        // Are allowed for the Dutch X contract
        if (functionIdentifier == tokenInterface.approve.selector) {
            uint spender;
            // solium-disable-next-line security/no-inline-assembly
            assembly {
                spender := mload(add(data, 0x24))
            }

            // TODO we need abi.decodeWithSelector
            // approve(address spender, uint256 amount) we skip the amount
            // (address spender) = abi.decode(dataParams, (address));

            require(address(spender) == dutchXAddress, "Spender must be the DutchX Contract");
        } else if (functionIdentifier == dxInterface.deposit.selector) {
            // TODO we need abi.decodeWithSelector
            // deposit(address token, uint256 amount) we skip the amount
            // (address token) = abi.decode(data, (address));

            uint depositToken;
            // solium-disable-next-line security/no-inline-assembly
            assembly {
                depositToken := mload(add(data, 0x24))
            }
            require (isWhitelistedToken[address(depositToken)], "Only whitelisted tokens can be deposit on the DutchX");
        } else if (functionIdentifier == dxInterface.postSellOrder.selector) {
            // TODO we need abi.decodeWithSelector
            // postSellOrder(address sellToken, address buyToken, uint256 auctionIndex, uint256 amount) we skip auctionIndex and amount
            // (address sellToken, address buyToken) = abi.decode(data, (address, address));

            uint sellToken;
            uint buyToken;
            // solium-disable-next-line security/no-inline-assembly
            assembly {
                sellToken := mload(add(data, 0x24))
                buyToken := mload(add(data, 0x44))
            }
            require (isWhitelistedToken[address(sellToken)] && isWhitelistedToken[address(buyToken)], "Only whitelisted tokens can be sold");
        } else if (functionIdentifier == dxInterface.postBuyOrder.selector) {
            // TODO we need abi.decodeWithSelector
            // postBuyOrder(address sellToken, address buyToken, uint256 auctionIndex, uint256 amount) we skip auctionIndex and amount
            // (address sellToken, address buyToken) = abi.decode(data, (address, address));

            uint sellToken;
            uint buyToken;
            // solium-disable-next-line security/no-inline-assembly
            assembly {
                sellToken := mload(add(data, 0x24))
                buyToken := mload(add(data, 0x44))
            }
            require (isWhitelistedToken[address(sellToken)] && isWhitelistedToken[address(buyToken)], "Only whitelisted tokens can be bought");
        } else {
            // Other functions different than claim and deposit are not allowed
            require(functionIdentifier == dxInterface.claimTokensFromSeveralAuctionsAsSeller.selector || functionIdentifier == dxInterface.claimTokensFromSeveralAuctionsAsBuyer.selector || functionIdentifier == tokenInterface.deposit.selector, "Function not allowed");
        }

        require(manager.execTransactionFromModule(to, value, data, Enum.Operation.Call), "Could not execute transaction");
    }
}
