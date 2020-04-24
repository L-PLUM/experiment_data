/**
 *Submitted for verification at Etherscan.io on 2018-12-11
*/

pragma solidity ^0.4.24;

contract SignerSetter {
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-proxy-signer-store-slot"));
    bytes32 internal constant SIGNER_STORE_SLOT = 0x12c544e514c50de95c0cb63530112ad1aafb15a9b310ebba7865d7187f21aa51;

    event SignerUpgraded(address caller, address newSigner, string proposal);
    
    function _setSigner(address newSigner) internal {
        bytes32 position = SIGNER_STORE_SLOT;
        
        assembly {
            sstore(position, newSigner)
        }
    }
}

contract Erc20Setter {
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-proxy-erc20-store-slot"));
    bytes32 internal constant ERC20_STORE_SLOT = 0xb615bf7acb88878500ffdb85a52987718354f4e5599f28a240552c6c31526e78;
    
    event Erc20Upgraded(address caller, address newErc20, string proposal);
    
    function _setErc20(address newErc20) internal {
        bytes32 position = ERC20_STORE_SLOT;
        
        assembly {
            sstore(position, newErc20)
        }
    }
}

// ImplementaionSlector used to find a slot which store an implementation by methodID
// so from a methodID, we can find a slot, then read this slot, get an implementation

contract ImplementationSlector {
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-implementation-locator-store-slot"));
    bytes32 internal constant IMPL_STORE_LOCATION_SLOT = 0x7cc364d97eb004d5265607d2bd8c06d96b2d1f900cf41f190dfa665baf7d2ec6;
    
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-proxy-erc20-store-slot"));
    bytes32 internal constant ERC20_STORE_SLOT = 0xb615bf7acb88878500ffdb85a52987718354f4e5599f28a240552c6c31526e78;
    
    function _setImplSlot(bytes4 methodID, bytes32 implSlot) internal {
        bytes32 position = keccak256(abi.encodePacked(IMPL_STORE_LOCATION_SLOT, methodID));
        
        assembly {
            sstore(position, implSlot)
        }
    }

    function _implementation(bytes4 methodID) internal view returns(address _impl) {
        bytes32 position = keccak256(abi.encodePacked(IMPL_STORE_LOCATION_SLOT, methodID));
        bytes32 implSlot;
        
        assembly {
            implSlot := sload(position)
        }
        
        if (implSlot == bytes32(0)) {
            implSlot = ERC20_STORE_SLOT;
        }

        assembly {
            _impl := sload(implSlot)
        }    
    }
}

contract GroupedProxy is SignerSetter, Erc20Setter, ImplementationSlector {
    
    constructor(address signer, address erc20) public {
        _setSigner(signer);
        emit SignerUpgraded(msg.sender, signer, "init");
        
        _setErc20(erc20);
        emit Erc20Upgraded(msg.sender, erc20, "init");
        
        _setImplementationSelector();
    }
    
    function _setImplementationSelector() internal {
        // "initMasterGroup(address[])"
        _setImplSlot(0xd35c2517, SIGNER_STORE_SLOT);
        
        // 
        
    }
    
    function currentSigner() public view returns (address _signer) {
        bytes32 position = SIGNER_STORE_SLOT;
        
        assembly {
            _signer := sload(position)
        }
    }
    
    function currentErc20() public view returns (address _erc20) {
        bytes32 position = ERC20_STORE_SLOT;
        
        assembly {
            _erc20 := sload(position)
        }
    }
    
    function groupManagedCall(bytes, bytes) public {
        /*
        0xa1c7ffd3
        0000000000000000000000000000000000000000000000000000000000000040
        00000000000000000000000000000000000000000000000000000000000000a0
        0000000000000000000000000000000000000000000000000000000000000026
        1122334455667788990011223344556677889900000000000011223344556677
        8899001122330000000000000000000000000000000000000000000000000000
        0000000000000000000000000000000000000000000000000000000000000002
        1234000000000000000000000000000000000000000000000000000000000000
        */
        assembly {
            // call sign verification
            calldatacopy(0, 0x44, 0x20)        // copy signerData length 
            calldatacopy(0x20, 0x64, mload(0)) // copy signerData value

            let result := delegatecall(gas, address, 0x20, mload(0), 0, 0)

            returndatacopy(0, 0, returndatasize)

            switch result
            case 0  { revert(0, returndatasize) }
            
            // call the real method
            calldatacopy(0, 0x24, 0x20)                          // copy callData offset
            calldatacopy(0x20, add(mload(0), 4), 0x20)           // copy callData length
            calldatacopy(0x40, add(mload(0), 0x24), mload(0x20)) // copy callData

            result := delegatecall(gas, address, 0x40, mload(0x20), 0, 0)

            returndatacopy(0, 0, returndatasize)

            switch result
            case 0  { revert(0, returndatasize) }
            default { return(0, returndatasize) }
        }
    }
    
    function() payable public{
        bytes4 methodID;
        assembly {
            methodID := calldataload(0)
        }
        
        address _impl = _implementation(methodID);
        
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize)

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas, _impl, 0, calldatasize, 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize)

            switch result
            // delegatecall returns 0 on error.
            case 0  { revert(0, returndatasize) }
            default { return(0, returndatasize) }
        }
    }
}
