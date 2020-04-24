/**
 *Submitted for verification at Etherscan.io on 2019-01-24
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




//import "./Ownable.sol";




/**
 * @title Proxyable Contract sits behind a Proxy
 * @notice A proxyable contract that works hand in hand with the Proxy contract
 * to allow for anyone to interact with the underlying contract both 
 * directly and through the proxy.
 * This contract should be treated like an abstract contract. Simply inherit 
 * Proxyable on the target contract.
 */
contract Proxyable is Ownable {
    /* The proxy this contract exists behind. */
    Proxy public proxy;

    /* The caller of the proxy, passed through to this contract.
     * Note that every function using this member must apply the onlyProxy or
     * optionalProxy modifiers, otherwise their invocations can use stale values. */ 
    address payable messageSender; 

    /**
     * @dev Constructor
     * @param _proxy The proxy this contract exists behind
     */
    constructor(address payable _proxy)
        Ownable()
        public
    {
        proxy = Proxy(_proxy);
        emit ProxyUpdated(_proxy);
    }

    /**
     * @param _proxy The proxy this contract exists behind
     */
    function setProxy(address payable _proxy)
        external
        onlyOwner
    {
        proxy = Proxy(_proxy);
        emit ProxyUpdated(_proxy);
    }

    /**
    * @dev We must get the msg.sender from the proxy otherwise the sender will be the Proxy
    * @param sender The msg.sender or the caller of the function
    */
    function setMessageSender(address payable sender)
        external
        onlyProxy
    {
        messageSender = sender;
    }

    //-----------------------------------------------------------------
    // Modifiers
    //-----------------------------------------------------------------

    /**
    * @dev Only the proxy can call this function
    */
    modifier onlyProxy {
        require(Proxy(msg.sender) == proxy, "Only the proxy can call this function");
        _;
    }

    /**
    * @dev This call could be called directly and not via the proxy
    */
    modifier optionalProxy
    {
        if (Proxy(msg.sender) != proxy) {
            messageSender = msg.sender;
        }
        _;
    }

    /**
    * @dev This call could be called directly and not via the proxy but must be the owner
    */
    modifier optionalProxy_onlyOwner
    {
        if (Proxy(msg.sender) != proxy) {
            messageSender = msg.sender;
        }
        require(messageSender == owner(), "This action can only be performed by the owner");
        _;
    }

    //-----------------------------------------------------------------
    // Events
    //-----------------------------------------------------------------

    event ProxyUpdated(address proxyAddress);
}


/**
 * @title Proxy contract for upgradable contracts
 * @notice 
 *
 * A proxy contract that, if it does not recognise the function
 * being called on it, passes all value and call data to an
 * underlying target contract.
 *
 * Usein CALL rather than DELEGATECALL puts the context into the target 
 * contract allowing it to store its data how it wants rather than in the proxy
 *
 * Therefore, any contract the proxy wraps must
 * implement the Proxyable interface, in order that it can pass msg.sender
 * into the underlying contract as the state parameter, messageSender.
 *
 * This proxy is meant to be generic and have zero knowledge of its 
 * underlying target contract ABI and the data it stores. 
 *
 * Select events from the target contracts are emited from this proxy
 * to allow DApp compatability with events being emited from this publicy 
 * accessible address.
 */
contract Proxy is Ownable {

    Proxyable public target;

    /**
     * @dev Constructor
     */
    constructor()
        Ownable()
        public
    {}

    /**
     * @dev Set the target contract address
     * @param _target The target contract address that sits behind this proxy
     */
    function setTarget(Proxyable _target)
        external
        onlyOwner
    {
        target = _target;
        emit TargetUpdated(_target);
    }

    /**
    * @dev Only the proxyable target contract may call this function to emit an event
    * @param callData the function hash and the arguments 
    * @param numTopics the number of topics to log
    */
    function _emit(bytes calldata callData, uint numTopics, bytes32 topic1, bytes32 topic2, bytes32 topic3, bytes32 topic4)
        external
        onlyTarget
    {
        uint size = callData.length;
        bytes memory _callData = callData;

        assembly {
            /* The first 32 bytes of callData contain its length (as specified by the abi). 
             * Length is assumed to be a uint256 and therefore maximum of 32 bytes
             * in length. It is also leftpadded to be a multiple of 32 bytes.
             * This means moving call_data across 32 bytes guarantees we correctly access
             * the data itself. */
            switch numTopics
            case 0 {
                log0(add(_callData, 32), size)
            } 
            case 1 {
                log1(add(_callData, 32), size, topic1)
            }
            case 2 {
                log2(add(_callData, 32), size, topic1, topic2)
            }
            case 3 {
                log3(add(_callData, 32), size, topic1, topic2, topic3)
            }
            case 4 {
                log4(add(_callData, 32), size, topic1, topic2, topic3, topic4)
            }
        }
    }

    /**
    * @dev Fallback function using assembly to forward the call and call data to the 
    * proxyable target contract 
    */
    function()
        external
        payable
    {
        // Must send the messageSender explicitly since we are using CALL rather than DELEGATECALL.
        target.setMessageSender(msg.sender);

        //Forward all call data to the target
        assembly {
            let free_ptr := mload(0x40)
            calldatacopy(free_ptr, 0, calldatasize)

            /* We must explicitly forward ether to the underlying contract as well. */
            let result := call(gas, sload(target_slot), callvalue, free_ptr, calldatasize, 0, 0)
            returndatacopy(free_ptr, 0, returndatasize)

            if iszero(result) { revert(free_ptr, returndatasize) }
            return(free_ptr, returndatasize)
        }
    }

    //-----------------------------------------------------------------
    // Modifiers
    //-----------------------------------------------------------------

    /**
    * @dev Only the proxyable target contract may call this function
    * @notice The msg.sender or the caller of the function
    */
    modifier onlyTarget {
        require(Proxyable(msg.sender) == target, "Must be proxy target");
        _;
    }

    //-----------------------------------------------------------------
    // Events
    //-----------------------------------------------------------------

    event TargetUpdated(Proxyable newTarget);
}
