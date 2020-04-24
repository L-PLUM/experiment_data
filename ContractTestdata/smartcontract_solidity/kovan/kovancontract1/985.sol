/**
 *Submitted for verification at Etherscan.io on 2018-12-12
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


contract GroupReader {
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-group-config-store-slots"));
    bytes32 internal constant GROUP_CONFIG_STORE_SLOT = 0x8ad7eb591937695082ebce99794911fcb3aa811ac112bbc562fd368751bb9ae2;
    
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-master-method-group"));
    bytes32 internal constant MASTER_METHOD_GROUP = 0x59d3a36e9cdc22e8a3f7f0c855d500876dbd0c457339ce4f7850a44a514faf63;
    
    bytes32 internal constant INVALID_GROUP = bytes32(0);
    
    function _group(bytes4 methodID) internal view returns (bytes32 group) {
        bytes32 position = keccak256(abi.encodePacked(GROUP_CONFIG_STORE_SLOT, methodID));
        
        assembly {
            group := sload(position)
        }
        
        if (group == INVALID_GROUP) {
            group = MASTER_METHOD_GROUP;
        }
    }        
}

contract GroupConfig is GroupReader {
    
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-pause-group"));
    bytes32 internal constant PAUSE_GROUP = 0xbf9069d5250bc460e31e67b842b496ff588511187f2303da8d795fce61be0257;
    
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-blacklist-group"));
    bytes32 internal constant BLACKLIST_GROUP = 0x5e443130463cdec2b1d29c271eb5f2c9b1e4545da29f0d23b4949a1c11c4c1c4;
    
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-issuer-group"));
    bytes32 internal constant ISSUER_GROUP = 0x2cd4bade3e2e369d05e9094faca5d280061bc9f7051b9915ac537ef3b1923e73;
    
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-lawEnforcement-group"));
    bytes32 internal constant LAWENFORCEMENT_GROUP = 0x22e8201cc892adc396a511a2e8ba95bfd6306fd8ba3576310d56cba2d3512a33;
    
    function _setGroup(bytes4 methodID, bytes32 group) internal {
        bytes32 position = keccak256(abi.encodePacked(GROUP_CONFIG_STORE_SLOT, methodID));
        
        assembly {
            sstore(position, group)
        }
    }
}

contract OperationStatus {
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-opt-signed-store-slot"));
    bytes32 internal constant OPT_SIGNED_STORE_SLOT = 0xcd83bacdf6208f6e511a9d677ab21b0d39544f1f1653f9ada000921e6fde20ea;
    
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-opt-done-store-slot"));
    bytes32 internal constant OPT_DONE_STORE_SLOT = 0x77b9a1d70f5b2c0de6929fc339e5bd0c4c369c39cd7a2c1bf9b34b9976bfe5dc;
    
    
    function _optStatusPosition(bytes32 slotType, bytes32 group, bytes32 optHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(slotType, group, optHash));
    }
    
    function _storeStatus(bytes32 position, bool status) public {
        assembly {
            sstore(position, status)
        }
    }

    function _optSigned(bytes32 group, bytes32 optHash) public {
        bytes32 position = keccak256(abi.encodePacked(OPT_SIGNED_STORE_SLOT, group, optHash));
        bool status = true;
        assembly {
            sstore(position, status)
        }
    }
    
    function _optDone(bytes32 group, bytes32 optHash) public {
        bytes32 position = keccak256(abi.encodePacked(OPT_DONE_STORE_SLOT, group, optHash));
        bool status = true;
        assembly {
            sstore(position, status)
        }
    }
   
    function _loadOptStatus(bytes32 position) public view returns (bool status) {
        assembly {
            status := sload(position)
        }
    }
    
    function _isSigned( bytes32 group, bytes32 optHash) public view returns (bool status) {
        bytes32 position = keccak256(abi.encodePacked(OPT_SIGNED_STORE_SLOT, group, optHash)); 
        assembly {
            status := sload(position)
        }
    }
    
    function _isDone(bytes32 group, bytes32 optHash) public view returns (bool status) {
        bytes32 position = keccak256(abi.encodePacked(OPT_DONE_STORE_SLOT, group, optHash)); 
        assembly {
            status := sload(position)
        }
    }
}

contract ShouldMultiSign is GroupConfig, OperationStatus {
    
    modifier shouldMultiSign(){
        bytes32 optHash = keccak256(msg.data);
        bytes32 group = _group(msg.sig);
    
        bytes32 doneStatusPosition = _optStatusPosition(OPT_DONE_STORE_SLOT, group, optHash);
        require(_isSigned(group, optHash) && !_loadOptStatus(doneStatusPosition), "require invalid");
        _storeStatus(doneStatusPosition, true);
        
        _;
    }
}


contract VoterAddress {
    
    //keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-voter-address-store-slot"));
    bytes32 private constant VOTER_STORE_SLOT = 0x791c1d1569a8fb58edafdf50e2fea738894b2bf76a8fa10a3a22b0b11e90a6cf;
    
    
    function _voterAddressPosition(bytes32 group, uint8 index) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(VOTER_STORE_SLOT, group, index));
    }
    
    function _loadVoterAddress(bytes32 position) internal view returns (address addr) {
        assembly {
            addr := sload(position)
        }
    }
    
    function _storeVoterAddress(bytes32 position, address addr) internal {
        assembly {
            sstore(position, addr)
        }
    }
    
    function _setVoterAddress(bytes32 group, uint8 index, address addr) internal {
        bytes32 position = keccak256(abi.encodePacked(VOTER_STORE_SLOT, group, index));
        
        assembly {
            sstore(position, addr)
        }
    }
    
    function _voterAddress(bytes32 group, uint8 index) internal view returns (address addr) {
        bytes32 position = keccak256(abi.encodePacked(VOTER_STORE_SLOT, group, index));
        
        assembly {
            addr := sload(position)
        }
    }
}

contract VoterCount {
    
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-voter-count-store-slot"));
    bytes32 private constant VTNUM_STORE_SLOT = 0x90b8f6c326ac31b778dedbd1da59465a714856a0afacc83e481941056f04cfdf;
    
    
    function _voterCountPosition(bytes32 group) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(VTNUM_STORE_SLOT, group));
    }
    
    function _loadVoterCount(bytes32 position) internal view returns (uint8 num) {
        assembly {
            num := sload(position)
        }
    }
    
    function _storeVoterCount(bytes32 position, uint8 count) internal {
        assembly {
            sstore(position, count)
        }
    }
    
    function _setVoterCount(bytes32 group, uint8 count) internal {
        bytes32 position = keccak256(abi.encodePacked(VTNUM_STORE_SLOT, group));
        
        assembly {
            sstore(position, count)
        }
    }
    
    function _voterCount(bytes32 group) internal view returns (uint8 num) {
        bytes32 position = keccak256(abi.encodePacked(VTNUM_STORE_SLOT, group));
        
        assembly {
            num := sload(position)
        }
    }
}

contract VoterIndex {
    
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-voter-index-store-slot"));
    bytes32 private constant INDEX_STORE_SLOT = 0xc8bbafb6f38f642a59ff64e56fad5debbd01830be06c08db69d8cc2d6483b5db;
    
        
    function _voterIndexPosition(bytes32 group, address addr) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(INDEX_STORE_SLOT, group, addr));
    }
    
    function _loadVoterIndex(bytes32 position) internal view returns (uint8 index) {
        assembly {
            index := sload(position)
        }
    }
    
    function _storeVoterIndex(bytes32 position, uint8 index) internal {
        assembly {
            sstore(position, index)
        }
    }
    
    function _setVoterIndex(bytes32 group, address addr, uint8 index) internal {
        bytes32 position = keccak256(abi.encodePacked(INDEX_STORE_SLOT, group, addr));
        
        assembly {
            sstore(position, index)
        }
    }
    
    function _voterIndex(bytes32 group, address addr) internal view returns (uint8 index) {
        bytes32 position = keccak256(abi.encodePacked(INDEX_STORE_SLOT, group, addr));
        
        assembly {
            index := sload(position)
        }
    }
}

contract VoterManager is VoterAddress, VoterIndex, VoterCount {}

contract MultiSign is VoterManager {
    
    event OperationSigned(address caller, bytes32 group, bytes32 optHash);
    
    function quorum(uint8 total) internal pure returns (uint8) 
    {
        uint16 tmp = total * 2 + 1;
        return uint8(tmp%3==0 ? tmp/3 : tmp/3+1);
    }
        
    function verifySigns(bytes32 group, bytes32 optHash, bytes32[] manyR, bytes32[] manyS, uint8[] manyV) internal view returns (bool) {
        require(manyR.length == manyS.length && manyS.length == manyV.length, "invalid sign length.");
        
        uint8 i; uint8 count; uint8 ix;
        
        uint8 quorumN = quorum(_voterCount(group));
        
        require(quorumN>0, "quorum is zero.");
        
        uint256 poll = 0;
        
        for (i=0; i < manyR.length; i++) {
            
            ix =  _voterIndex(group, ecrecover(optHash, manyV[i], manyR[i], manyS[i]));
            
            if (ix > 0 && poll & 1<<ix == 0) {
                poll |= 1 << ix;
                count++;
            }
            
            if (count >= quorumN) {
                return true;
            }
        }
    }
}

contract GroupedManager is MultiSign, SignerSetter, Erc20Setter, ShouldMultiSign, ImplementationSlector {
    
    event VoterAdded(address caller, bytes32 group, address newVoter, string proposal);
    event VoterRemoved(address caller, bytes32 group, address oldVoter, string proposal);
    
    // keccak256(abi.encodePacked("ibitcome-ecrecover-multi-sign-signer-initialized-slot"));
    bytes32 private constant SIGNER_INITIALIZED_STORE_SLOT = 0xf1a0b9add6bccf3bf319c81d2ed0b9eca12ee4eded9836d671971e1f6837fad4;
    
    function _addVoter(bytes32 group, address addr) internal {
        if (_voterIndex(group, addr) > 0) return;
        
        bytes32 _countPosition = _voterCountPosition(group);
        uint8 _count = _loadVoterCount(_countPosition) + 1;
        require(_count <= 250, "voter count exceeded");
        
        for (uint8 i=1; i <=250; i++) {
            if (_voterAddress(group, i) != address(0)) continue;
            
            _setVoterAddress(group, i, addr);
            _setVoterIndex(group, addr, i);
            _storeVoterCount(_countPosition, _count);
            
            break;
        }
    }
    
    function _removeVoter(bytes32 group, address addr) internal {
        bytes32 _indexPosition = _voterIndexPosition(group, addr);
        uint8 _index = _loadVoterIndex(_indexPosition);
        if (_index == 0) return;
        
        bytes32 _countPosition = _voterCountPosition(group);
        uint8 _count = _loadVoterCount(_countPosition);
        require(_count >= 1, "error count littler than 1");
        
        _setVoterAddress(group, _index, address(0));
        _storeVoterIndex(_indexPosition, 0);
        _storeVoterCount(_countPosition, _count - 1);
    }
    
    function _setImplementationSelector() internal {
        
        // "managedBaseOnMethod(bytes4,bytes32,bytes32[],bytes32[],uint8[])"
        _setImplSlot(0xf2bc0ec2, SIGNER_STORE_SLOT);
        
        // "managedBaseOnGroup(bytes32,bytes32,bytes32[],bytes32[],uint8[])"
        _setImplSlot(0xe34e9852, SIGNER_STORE_SLOT);
        
        // "addVoter(bytes32,address[],string)"
        _setImplSlot(0x5d019927, SIGNER_STORE_SLOT);
        
        // "removeVoter(bytes32,address,string)"
        _setImplSlot(0x5d1cf81e, SIGNER_STORE_SLOT);
        
        // "changeSigner(address,string)"
        _setImplSlot(0xb09b82f3, SIGNER_STORE_SLOT);
        
        // "changeErc20(address,string)"
        _setImplSlot(0xcef5c9bd, SIGNER_STORE_SLOT);
    }
    
    function _setMethodGroup(bytes32 group) internal {
        if (group == PAUSE_GROUP) {
            // "pause(string)"
            _setGroup(0x6da66355, group);
            
            // "unpause(string)"
            _setGroup(0xe79faa58, group);
            
        } else if (group == BLACKLIST_GROUP) {
            // "blacklist(address,string)"
            _setGroup(0xddf579ff, group);
            
            // "unBlacklist(address,string)"
            _setGroup(0xf1c5faae, group);
            
        } else if (group == ISSUER_GROUP) {
            // "mint(address,address,uint256,string)"
            _setGroup(0xb85cbc79, group);
            
            // "issuerTransfer(address,address,uint256,string)"
            _setGroup(0x84edc87d, group);
            
        } else if (group == LAWENFORCEMENT_GROUP) {
            // "wipeBlacklistedAddress(address,address,string)"
            _setGroup(0xb51c8303, group);
            
            // "wipeBlacklistedIssuer(address,address,string)"
            _setGroup(0x24ec8b45, group);
        }
    }
    
    function _removeMethodGroup(bytes32 group) internal {
        if (group == PAUSE_GROUP) {
            // "pause(string)"
            _setGroup(0x6da66355, INVALID_GROUP);
            
            // "unpause(string)"
            _setGroup(0xe79faa58, INVALID_GROUP);
            
        } else if (group == BLACKLIST_GROUP) {
            // "blacklist(address,string)"
            _setGroup(0xddf579ff, INVALID_GROUP);
            
            // "unBlacklist(address,string)"
            _setGroup(0xf1c5faae, INVALID_GROUP);
            
        } else if (group == ISSUER_GROUP) {
            // "mint(address,address,uint256,string)"
            _setGroup(0xb85cbc79, INVALID_GROUP);
            
            // "issuerTransfer(address,address,uint256,string)"
            _setGroup(0x84edc87d, INVALID_GROUP);

        } else if (group == LAWENFORCEMENT_GROUP) {
            // "wipeBlacklistedAddress(address,address,string)"
            _setGroup(0xb51c8303, INVALID_GROUP);
            
            // "wipeBlacklistedIssuer(address,address,string)"
            _setGroup(0x24ec8b45, INVALID_GROUP);
            
        }
    }
    
    function managedBaseOnMethod(bytes4 methodID, bytes32 optHash, bytes32[] manyR, bytes32[] manyS, uint8[] manyV) external returns (bool) {
        bytes32 group = _group(methodID);
        if (_voterCount(group) == 0) {
            group = MASTER_METHOD_GROUP;
        }
        
        require(verifySigns(group, optHash, manyR, manyS, manyV), "verifySigns failed");
        
        _optSigned(group, optHash);
        emit OperationSigned(msg.sender, group, optHash);
        
        return true;
    }
    
    function managedBaseOnGroup(bytes32 argGroup, bytes32 optHash, bytes32[] manyR, bytes32[] manyS, uint8[] manyV) external returns (bool) {
        bytes32 group = argGroup;
        if (_voterCount(group) == 0) {
            group = MASTER_METHOD_GROUP;
        }
        
        require(verifySigns(group, optHash, manyR, manyS, manyV), "verifySigns failed");
        
        _optSigned(group, optHash);
        emit OperationSigned(msg.sender, group, optHash);
        
        return true;
    }
    
    function initMasterGroup(address[] addrs) external {
        require(addrs.length <= 250);
        
        bytes32 position = SIGNER_INITIALIZED_STORE_SLOT;
        bool initialized;
        assembly{
            initialized := sload(position)
        }
        require(!initialized, "initialized");
        
        for (uint8 i = 0; i < addrs.length; i++) {
            _addVoter(MASTER_METHOD_GROUP, addrs[i]);
            emit VoterAdded(msg.sender, MASTER_METHOD_GROUP, addrs[i], "init");
        }
        
        _setImplementationSelector();
        
        initialized = true;
        assembly {
            sstore(position, initialized)
        }
    }
    
    function addVoter(bytes32 group, address[] addrs, string proposal) external {
        require( addrs.length <= 250, "voters should be less than 250.");
        
        bytes32 optHash = keccak256(msg.data);
        
        bytes32 realGroup = group;
        if (_voterCount(realGroup) == 0) {
            realGroup = MASTER_METHOD_GROUP;
            _setMethodGroup(group);
        }
        
        bytes32 doneStatusPosition = _optStatusPosition(OPT_DONE_STORE_SLOT, realGroup, optHash);
        require(_isSigned(realGroup, optHash) && !_loadOptStatus(doneStatusPosition), "require invalid");
        _storeStatus(doneStatusPosition, true);
        
        for (uint8 i = 0; i < addrs.length; i++) {
            _addVoter(group, addrs[i]);
            emit VoterAdded(msg.sender, group, addrs[i], proposal);
        }
    }
    
    function removeVoter(bytes32 group, address addr, string proposal) external {
        bytes32 optHash = keccak256(msg.data);
        
        bytes32 doneStatusPosition = _optStatusPosition(OPT_DONE_STORE_SLOT, group, optHash);
        require(_isSigned(group, optHash) && !_loadOptStatus(doneStatusPosition), "require invalid");
        _storeStatus(doneStatusPosition, true);
        
        _removeVoter(group, addr);
        if (_voterCount(group) == 0) {
            _removeMethodGroup(group);
        }
        
        emit VoterRemoved(msg.sender, group, addr, proposal);
    }
    
    function changeSigner(address newSigner, string proposal) shouldMultiSign external {
        
        _setSigner(newSigner);
        
        emit SignerUpgraded(msg.sender, newSigner, proposal);
    }
    
    function changeErc20(address newErc20, string proposal) shouldMultiSign external {
        
        _setErc20(newErc20);
        
        emit Erc20Upgraded(msg.sender, newErc20, proposal);
    }
}
