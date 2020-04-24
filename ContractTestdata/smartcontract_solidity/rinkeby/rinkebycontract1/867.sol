/**
 *Submitted for verification at Etherscan.io on 2019-02-05
*/

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

interface HydroInterface {
    function balances(address) external view returns (uint);
    function allowed(address, address) external view returns (uint);
    function transfer(address _to, uint256 _amount) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);
    function approve(address _spender, uint256 _amount) external returns (bool success);
    function approveAndCall(address _spender, uint256 _value, bytes calldata _extraData)
        external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint256 remaining);
    function totalSupply() external view returns (uint);

    function authenticate(uint _value, uint _challenge, uint _partnerId) external;
}

interface SnowflakeInterface {
    function deposits(uint) external view returns (uint);
    function resolverAllowances(uint, address) external view returns (uint);

    function identityRegistryAddress() external returns (address);
    function hydroTokenAddress() external returns (address);
    function clientRaindropAddress() external returns (address);

    function setAddresses(address _identityRegistryAddress, address _hydroTokenAddress) external;
    function setClientRaindropAddress(address _clientRaindropAddress) external;

    function createIdentityDelegated(
        address recoveryAddress, address associatedAddress, address[] calldata providers, string calldata casedHydroId,
        uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external returns (uint ein);
    function addProvidersFor(
        address approvingAddress, address[] calldata providers, uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;
    function removeProvidersFor(
        address approvingAddress, address[] calldata providers, uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;
    function upgradeProvidersFor(
        address approvingAddress, address[] calldata newProviders, address[] calldata oldProviders,
        uint8[2] calldata v, bytes32[2] calldata r, bytes32[2] calldata s, uint[2] calldata timestamp
    ) external;
    function addResolver(address resolver, bool isSnowflake, uint withdrawAllowance, bytes calldata extraData) external;
    function addResolverAsProvider(
        uint ein, address resolver, bool isSnowflake, uint withdrawAllowance, bytes calldata extraData
    ) external;
    function addResolverFor(
        address approvingAddress, address resolver, bool isSnowflake, uint withdrawAllowance, bytes calldata extraData,
        uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;
    function changeResolverAllowances(address[] calldata resolvers, uint[] calldata withdrawAllowances) external;
    function changeResolverAllowancesDelegated(
        address approvingAddress, address[] calldata resolvers, uint[] calldata withdrawAllowances,
        uint8 v, bytes32 r, bytes32 s
    ) external;
    function removeResolver(address resolver, bool isSnowflake, bytes calldata extraData) external;
    function removeResolverFor(
        address approvingAddress, address resolver, bool isSnowflake, bytes calldata extraData,
        uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;

    function triggerRecoveryAddressChangeFor(
        address approvingAddress, address newRecoveryAddress, uint8 v, bytes32 r, bytes32 s
    ) external;

    function transferSnowflakeBalance(uint einTo, uint amount) external;
    function withdrawSnowflakeBalance(address to, uint amount) external;
    function transferSnowflakeBalanceFrom(uint einFrom, uint einTo, uint amount) external;
    function withdrawSnowflakeBalanceFrom(uint einFrom, address to, uint amount) external;
    function transferSnowflakeBalanceFromVia(uint einFrom, address via, uint einTo, uint amount, bytes calldata _bytes)
        external;
    function withdrawSnowflakeBalanceFromVia(uint einFrom, address via, address to, uint amount, bytes calldata _bytes)
        external;
}

interface SnowflakeResolverInterface {
    function callOnAddition() external view returns (bool);
    function callOnRemoval() external view returns (bool);
    function onAddition(uint ein, uint allowance, bytes calldata extraData) external returns (bool);
    function onRemoval(uint ein, bytes calldata extraData) external returns (bool);
}

contract SnowflakeResolver is Ownable {
    string public snowflakeName;
    string public snowflakeDescription;

    address public snowflakeAddress;

    bool public callOnAddition;
    bool public callOnRemoval;

    constructor(
        string memory _snowflakeName, string memory _snowflakeDescription,
        address _snowflakeAddress,
        bool _callOnAddition, bool _callOnRemoval
    )
        public
    {
        snowflakeName = _snowflakeName;
        snowflakeDescription = _snowflakeDescription;

        setSnowflakeAddress(_snowflakeAddress);

        callOnAddition = _callOnAddition;
        callOnRemoval = _callOnRemoval;
    }

    modifier senderIsSnowflake() {
        require(msg.sender == snowflakeAddress, "Did not originate from Snowflake.");
        _;
    }

    // this can be overriden to initialize other variables, such as e.g. an ERC20 object to wrap the HYDRO token
    function setSnowflakeAddress(address _snowflakeAddress) public onlyOwner {
        snowflakeAddress = _snowflakeAddress;
    }

    // if callOnAddition is true, onAddition is called every time a user adds the contract as a resolver
    // this implementation **must** use the senderIsSnowflake modifier
    // returning false will disallow users from adding the contract as a resolver
    function onAddition(uint ein, uint allowance, bytes memory extraData) public returns (bool);

    // if callOnRemoval is true, onRemoval is called every time a user removes the contract as a resolver
    // this function **must** use the senderIsSnowflake modifier
    // returning false soft prevents users from removing the contract as a resolver
    // however, note that they can force remove the resolver, bypassing onRemoval
    function onRemoval(uint ein, bytes memory extraData) public returns (bool);

    function transferHydroBalanceTo(uint einTo, uint amount) internal {
        HydroInterface hydro = HydroInterface(SnowflakeInterface(snowflakeAddress).hydroTokenAddress());
        require(hydro.approveAndCall(snowflakeAddress, amount, abi.encode(einTo)), "Unsuccessful approveAndCall.");
    }

    function withdrawHydroBalanceTo(address to, uint amount) internal {
        HydroInterface hydro = HydroInterface(SnowflakeInterface(snowflakeAddress).hydroTokenAddress());
        require(hydro.transfer(to, amount), "Unsuccessful transfer.");
    }

    function transferHydroBalanceToVia(address via, uint einTo, uint amount, bytes memory snowflakeCallBytes) internal {
        HydroInterface hydro = HydroInterface(SnowflakeInterface(snowflakeAddress).hydroTokenAddress());
        require(
            hydro.approveAndCall(
                snowflakeAddress, amount, abi.encode(true, address(this), via, einTo, snowflakeCallBytes)
            ),
            "Unsuccessful approveAndCall."
        );
    }

    function withdrawHydroBalanceToVia(address via, address to, uint amount, bytes memory snowflakeCallBytes) internal {
        HydroInterface hydro = HydroInterface(SnowflakeInterface(snowflakeAddress).hydroTokenAddress());
        require(
            hydro.approveAndCall(
                snowflakeAddress, amount, abi.encode(false, address(this), via, to, snowflakeCallBytes)
            ),
            "Unsuccessful approveAndCall."
        );
    }
}

interface IdentityRegistryInterface {
    function isSigned(address _address, bytes32 messageHash, uint8 v, bytes32 r, bytes32 s)
        external pure returns (bool);

    // Identity View Functions /////////////////////////////////////////////////////////////////////////////////////////
    function identityExists(uint ein) external view returns (bool);
    function hasIdentity(address _address) external view returns (bool);
    function getEIN(address _address) external view returns (uint ein);
    function isAssociatedAddressFor(uint ein, address _address) external view returns (bool);
    function isProviderFor(uint ein, address provider) external view returns (bool);
    function isResolverFor(uint ein, address resolver) external view returns (bool);
    function getIdentity(uint ein) external view returns (
        address recoveryAddress,
        address[] memory associatedAddresses, address[] memory providers, address[] memory resolvers
    );

    // Identity Management Functions ///////////////////////////////////////////////////////////////////////////////////
    function createIdentity(address recoveryAddress, address[] calldata providers, address[] calldata resolvers)
        external returns (uint ein);
    function createIdentityDelegated(
        address recoveryAddress, address associatedAddress, address[] calldata providers, address[] calldata resolvers,
        uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external returns (uint ein);
    function addAssociatedAddress(
        address approvingAddress, address addressToAdd, uint8 v, bytes32 r, bytes32 s, uint timestamp
    ) external;
    function addAssociatedAddressDelegated(
        address approvingAddress, address addressToAdd,
        uint8[2] calldata v, bytes32[2] calldata r, bytes32[2] calldata s, uint[2] calldata timestamp
    ) external;
    function removeAssociatedAddress() external;
    function removeAssociatedAddressDelegated(address addressToRemove, uint8 v, bytes32 r, bytes32 s, uint timestamp)
        external;
    function addProviders(address[] calldata providers) external;
    function addProvidersFor(uint ein, address[] calldata providers) external;
    function removeProviders(address[] calldata providers) external;
    function removeProvidersFor(uint ein, address[] calldata providers) external;
    function addResolvers(address[] calldata resolvers) external;
    function addResolversFor(uint ein, address[] calldata resolvers) external;
    function removeResolvers(address[] calldata resolvers) external;
    function removeResolversFor(uint ein, address[] calldata resolvers) external;

    // Recovery Management Functions ///////////////////////////////////////////////////////////////////////////////////
    function triggerRecoveryAddressChange(address newRecoveryAddress) external;
    function triggerRecoveryAddressChangeFor(uint ein, address newRecoveryAddress) external;
    function triggerRecovery(uint ein, address newAssociatedAddress, uint8 v, bytes32 r, bytes32 s, uint timestamp)
        external;
    function triggerDestruction(
        uint ein, address[] calldata firstChunk, address[] calldata lastChunk, bool resetResolvers
    ) external;
}

contract SnowMoResolver is SnowflakeResolver {
    address public uniswapViaAddress;
    SnowflakeInterface private snowflake;
    IdentityRegistryInterface private identityRegistry;

    mapping (uint => address) public tokenReceiptAddresses;
    mapping (uint => address) public tokenPreferences;

    constructor (address snowflakeAddress, address _uniswapViaAddress)
        SnowflakeResolver(
            "SnowMo", "Decentralized meta-transaction payment protocol fueled by HYDRO.", snowflakeAddress, true, false
        )
        public
    {
        setSnowflakeAddress(snowflakeAddress);
        uniswapViaAddress = _uniswapViaAddress;
    
    }

    function setSnowflakeAddress(address snowflakeAddress) public onlyOwner() {
        super.setSnowflakeAddress(snowflakeAddress);

        snowflake = SnowflakeInterface(snowflakeAddress);
        identityRegistry = IdentityRegistryInterface(snowflake.identityRegistryAddress());
    }

    // preference-based send
    function sendTo(uint einFrom, uint einTo, uint amount) public {
        require(identityRegistry.isProviderFor(einFrom, msg.sender), "");
        address tokenPreference = tokenPreferences[einTo];
        if (tokenPreference == address(0)) {
            transferSnowflakeBalanceFrom(einFrom, einTo, amount);
        } else {
            require(tokenReceiptAddresses[einTo] != address(0), "");
            withdrawSnowflakeBalanceFromVia(einFrom, tokenReceiptAddresses[einTo], amount, tokenPreferences[einTo]);
        }
    }

    // force transfer
    function forceTransferTo(uint einFrom, uint einTo, uint amount) public {
        require(identityRegistry.isProviderFor(einFrom, msg.sender), "");
        transferSnowflakeBalanceFrom(einFrom, einTo, amount);
    }

    // force withdraw
    function forceWithdrawTo(uint einFrom, uint einTo, uint amount) public {
        require(identityRegistry.isProviderFor(einFrom, msg.sender), "");
        require(tokenReceiptAddresses[einTo] != address(0), "");
        withdrawSnowflakeBalanceFrom(einFrom, tokenReceiptAddresses[einTo], amount);
    }

    // force withdraw
    function forceWithdrawTo(uint einFrom, address to, uint amount) public {
        require(identityRegistry.isProviderFor(einFrom, msg.sender), "");
        withdrawSnowflakeBalanceFrom(einFrom, to, amount);
    }

    // force withdraw via
    function forceWithdrawToVia(uint einFrom, uint einTo, uint amount) public {
        require(identityRegistry.isProviderFor(einFrom, msg.sender), "");
        require(tokenReceiptAddresses[einTo] != address(0), "");
        require(tokenPreferences[einTo] != address(0), "");
        withdrawSnowflakeBalanceFromVia(einFrom, tokenReceiptAddresses[einTo], amount, tokenPreferences[einTo]);
    }

    // force withdraw via
    function forceWithdrawToVia(uint einFrom, uint einTo, uint amount, address tokenPreference) public {
        require(identityRegistry.isProviderFor(einFrom, msg.sender), "");
        require(tokenReceiptAddresses[einTo] != address(0), "");

        withdrawSnowflakeBalanceFromVia(einFrom, tokenReceiptAddresses[einTo], amount, tokenPreference);
    }

    // force withdraw via
    function forceWithdrawToVia(uint einFrom, address to, uint amount, address tokenPreference) public {
        require(identityRegistry.isProviderFor(einFrom, msg.sender), "");
        withdrawSnowflakeBalanceFromVia(einFrom, to, amount, tokenPreference);
    }

    // wrapper to emit events
    function transferSnowflakeBalanceFrom(uint einFrom, uint einTo, uint amount) private {
        snowflake.transferSnowflakeBalanceFrom(einFrom, einTo, amount);
        emit TransferFrom(einFrom, einTo, amount);
    }

    // wrapper to emit events
    function withdrawSnowflakeBalanceFrom(uint einFrom, address to, uint amount) private {
        snowflake.withdrawSnowflakeBalanceFrom(einFrom, to, amount);
        emit WithdrawFrom(einFrom, to, amount);
    }

    // wrapper to emit events
    function withdrawSnowflakeBalanceFromVia(
        uint einFrom, address to, uint amount, address tokenAddress
    ) private {
        withdrawSnowflakeBalanceFromVia(
            einFrom, to, amount, tokenAddress, 1, 1, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        );
    }

    function withdrawSnowflakeBalanceFromVia(
        uint einFrom, address to, uint amount,
        address tokenAddress, uint minTokensBought, uint minEthBought, uint deadline
    ) private {
        bytes memory snowflakeCallBytes = abi.encode(tokenAddress, minTokensBought, minEthBought, deadline);
        snowflake.withdrawSnowflakeBalanceFromVia(einFrom, uniswapViaAddress, to, amount, snowflakeCallBytes);
        emit WithdrawFromVia(einFrom, uniswapViaAddress, to, amount, snowflakeCallBytes);
    }

    function onAddition(uint ein, uint /* allowance */, bytes memory extraData)
        public senderIsSnowflake() returns (bool)
    {
        (address tokenReceiptAddress, address tokenPreferenceAddress) = abi.decode(extraData, (address, address));
        tokenReceiptAddresses[ein] = tokenReceiptAddress;
        if (tokenPreferenceAddress != address(0)) {
            tokenPreferences[ein] = tokenPreferenceAddress;
        }

        emit SnowMoSignup(ein);

        return true;
    }

    function onRemoval(uint /* ein */, bytes memory /* extraData */) public senderIsSnowflake() returns (bool) {
        return true;
    }

    event SnowMoSignup(uint indexed ein);
    event TransferFrom(uint indexed einFrom, uint indexed einTo, uint amount);
    event WithdrawFrom(uint indexed einFrom, address indexed to, uint amount);
    event WithdrawFromVia(uint indexed einFrom, address indexed to, address via, uint amount, bytes snowflakeCallBytes);
}
