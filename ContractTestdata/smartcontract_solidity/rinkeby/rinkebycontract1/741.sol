/**
 *Submitted for verification at Etherscan.io on 2019-02-08
*/

pragma solidity 0.5.2;

// File: /Users/ka/Projects/Altoros/Etherisc/dip-platform/core/gif-contracts/contracts/modules/Registry/IRegistry.sol

interface IRegistry {
    event LogContractRegistered(
        uint256 release,
        bytes32 contractName,
        address contractAddress
    );

    event LogContractDeregistered(uint256 release, bytes32 contractName);

    event LogInterfaceIdRegistered(bytes4 interfaceId, bytes32 contractName);

    event LogReleasePrepared(uint256 release);
}

// File: /Users/ka/Projects/Altoros/Etherisc/dip-platform/core/gif-contracts/contracts/modules/Registry/RegistryStorageModel.sol

contract RegistryStorageModel is IRegistry {
    /**
     * @dev Current release
     */
    uint256 public release;

    /**
     * @dev  Save number of items to iterate through
     */
    uint256 public maxContracts = 100;

    // release => contract name => contract address
    mapping(uint256 => mapping(bytes32 => address)) public contracts;
    // release => contract name []
    mapping(uint256 => bytes32[]) public contractNames;
    // controller name => address
    mapping(bytes32 => address) public controllers;
}

// File: /Users/ka/Projects/Altoros/Etherisc/dip-platform/core/gif-contracts/contracts/shared/Delegator.sol

contract Delegator {
    function _delegate(address _implementation) internal {
        require(_implementation != address(0), "ERROR::UNKNOWN_IMPLEMENTATION");

        bytes memory data = msg.data;

        /* solhint-disable no-inline-assembly */
        assembly {
            let result := delegatecall(
                gas,
                _implementation,
                add(data, 0x20),
                mload(data),
                0,
                0
            )
            let size := returndatasize
            let ptr := mload(0x40)
            returndatacopy(ptr, 0, size)
            switch result
                case 0 {
                    revert(ptr, size)
                }
                default {
                    return(ptr, size)
                }
        }
        /* solhint-enable no-inline-assembly */
    }
}

// File: /Users/ka/Projects/Altoros/Etherisc/dip-platform/core/gif-contracts/contracts/shared/BaseModuleStorage.sol

contract BaseModuleStorage is Delegator {
    address public controller;

    /* solhint-disable payable-fallback */
    function() external {
        _delegate(controller);
    }
    /* solhint-enable payable-fallback */

    function _assignController(address _controller) internal {
        controller = _controller;
    }
}

// File: contracts/modules/Registry/Registry.sol

contract Registry is RegistryStorageModel, BaseModuleStorage {
    constructor(address _controller) public {
        // Init
        controllers["DAO"] = msg.sender;
        _assignController(_controller);
    }

    function assignController(address _controller) external {
        // todo: use onlyDAO modifier
        require(msg.sender == controllers["DAO"], "ERROR::NOT_AUTHORIZED");
        _assignController(_controller);
    }
}
