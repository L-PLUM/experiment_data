/**
 *Submitted for verification at Etherscan.io on 2019-07-25
*/

pragma solidity ^0.5.10;


interface SyscoinSuperblocksI {

    
    enum Status { Unitialized, New, InBattle, SemiApproved, Approved, Invalid }

    function propose(
        bytes32 _blocksMerkleRoot,
        uint _accumulatedWork,
        uint _timestamp,
        bytes32 _lastHash,
        uint32 _lastBits,
        bytes32 _parentId,
        address submitter
    ) external returns (uint, bytes32);

    function getSuperblock(bytes32 superblockHash) external view returns (
        bytes32 _blocksMerkleRoot,
        uint _accumulatedWork,
        uint _timestamp,
        bytes32 _lastHash,
        uint32 _lastBits,
        bytes32 _parentId,
        address _submitter,
        Status _status,
        uint32 _height
    );

    function confirm(bytes32 _superblockHash, address _validator) external returns (uint);
    function challenge(bytes32 _superblockHash, address _challenger) external returns (uint);
    function semiApprove(bytes32 _superblockHash, address _validator) external returns (uint, bytes32);
    function invalidate(bytes32 _superblockHash, address _validator) external returns (uint, bytes32);
    function getBestSuperblock() external view returns (bytes32);
    function getSuperblockHeight(bytes32 superblockHash) external view returns (uint32);
    function getSuperblockParentId(bytes32 _superblockHash) external view returns (bytes32);
    function getSuperblockStatus(bytes32 _superblockHash) external view returns (Status);
    function getSuperblockAt(uint _height) external view returns (bytes32);
}

interface SyscoinClaimManagerI {
    function bondDeposit(bytes32 superblockHash, address account, uint amount) external returns (uint);

    function getDeposit(address account) external view returns (uint);

    function getSuperblockInfo(bytes32 superblockHash) external view returns (
        bytes32 _blocksMerkleRoot,
        uint _accumulatedWork,
        uint _timestamp,
        bytes32 _lastHash,
        uint32 _lastBits,
        bytes32 _parentId,
        address _submitter,
        SyscoinSuperblocksI.Status _status,
        uint32 _height
    );

    function sessionDecided(bytes32 sessionId, bytes32 superblockHash, address winner, address loser, bool timedOut) external;
}

contract SyscoinErrorCodes {
    
    uint constant ERR_SUPERBLOCK_OK = 0;
    uint constant ERR_SUPERBLOCK_MISSING_SIBLINGS = 1;
    uint constant ERR_SUPERBLOCK_BAD_STATUS = 50020;
    uint constant ERR_SUPERBLOCK_BAD_SYSCOIN_STATUS = 50025;
    uint constant ERR_SUPERBLOCK_NO_TIMEOUT = 50030;
    uint constant ERR_SUPERBLOCK_BAD_TIMESTAMP = 50035;
    uint constant ERR_SUPERBLOCK_INVALID_MERKLE = 50040;
    uint constant ERR_SUPERBLOCK_BAD_PARENT = 50050;
    uint constant ERR_SUPERBLOCK_OWN_CHALLENGE = 50055;

    uint constant ERR_SUPERBLOCK_MIN_DEPOSIT = 50060;

    uint constant ERR_SUPERBLOCK_NOT_CLAIMMANAGER = 50070;

    uint constant ERR_SUPERBLOCK_BAD_CLAIM = 50080;
    uint constant ERR_SUPERBLOCK_VERIFICATION_PENDING = 50090;
    uint constant ERR_SUPERBLOCK_CLAIM_DECIDED = 50100;
    uint constant ERR_SUPERBLOCK_BAD_CHALLENGER = 50110;

    uint constant ERR_SUPERBLOCK_BAD_ACCUMULATED_WORK = 50120;
    uint constant ERR_SUPERBLOCK_BAD_BITS = 50130;
    uint constant ERR_SUPERBLOCK_MISSING_CONFIRMATIONS = 50140;
    uint constant ERR_SUPERBLOCK_BAD_LASTBLOCK = 50150;
    uint constant ERR_SUPERBLOCK_BAD_LASTBLOCK_STATUS = 50160;
    uint constant ERR_SUPERBLOCK_BAD_BLOCKHEIGHT = 50170;
    uint constant ERR_SUPERBLOCK_INVALID_ACCUMULATED_WORK = 50180;
    uint constant ERR_SUPERBLOCK_BAD_PREVBLOCK = 50190;
    uint constant ERR_SUPERBLOCK_BAD_RETARGET = 50200;
    uint constant ERR_SUPERBLOCK_INVALID_DIFFICULTY_ADJUSTMENT = 50210;
    uint constant ERR_SUPERBLOCK_BAD_MISMATCH = 50220;

    
    uint constant ERR_BAD_FEE = 20010;
    uint constant ERR_CONFIRMATIONS = 20020;
    uint constant ERR_CHAIN = 20030;
    uint constant ERR_SUPERBLOCK = 20040;
    uint constant ERR_MERKLE_ROOT = 20050;
    uint constant ERR_TX_64BYTE = 20060;
    
    uint constant ERR_RELAY_VERIFY = 30010;
    uint constant public minProposalDeposit = 3000000000000000000;
}

interface SyscoinTransactionProcessor {
    function processTransaction(uint txHash, uint value, address destinationAddress, uint32 _assetGUID, address superblockSubmitterAddress) external returns (uint);
    function burn(uint _value, uint32 _assetGUID, bytes calldata syscoinWitnessProgram) payable external returns (bool success);
}

library SyscoinMessageLibrary {

    
    uint constant ERR_INVALID_HEADER = 10050;
    uint constant ERR_COINBASE_INDEX = 10060; 
    uint constant ERR_NOT_MERGE_MINED = 10070; 
    uint constant ERR_FOUND_TWICE = 10080; 
    uint constant ERR_NO_MERGE_HEADER = 10090; 
    uint constant ERR_NOT_IN_FIRST_20 = 10100; 
    uint constant ERR_CHAIN_MERKLE = 10110;
    uint constant ERR_PARENT_MERKLE = 10120;
    uint constant ERR_PROOF_OF_WORK = 10130;
    uint constant ERR_INVALID_HEADER_HASH = 10140;
    uint constant ERR_PROOF_OF_WORK_AUXPOW = 10150;
    uint constant ERR_PARSE_TX_OUTPUT_LENGTH = 10160;
    uint constant ERR_PARSE_TX_SYS = 10170;
    enum Network { MAINNET, TESTNET, REGTEST }
    uint32 constant SYSCOIN_TX_VERSION_ASSET_ALLOCATION_BURN = 0x7407;
    
    struct AuxPoW {
        uint blockHash;

        uint txHash;

        uint coinbaseMerkleRoot; 
        uint[] chainMerkleProof; 
        uint syscoinHashIndex; 
        uint coinbaseMerkleRootCode; 

        uint parentMerkleRoot; 
        uint[] parentMerkleProof; 
        uint coinbaseTxIndex; 

        uint parentNonce;
    }

    
    
    
    struct BlockHeader {
        uint32 bits;
        uint blockHash;
    }
    
    
    function parseVarInt(bytes memory txBytes, uint pos) private pure returns (uint, uint) {
        
        uint8 ibit = uint8(txBytes[pos]);
        pos += 1;  

        if (ibit < 0xfd) {
            return (ibit, pos);
        } else if (ibit == 0xfd) {
            return (getBytesLE(txBytes, pos, 16), pos + 2);
        } else if (ibit == 0xfe) {
            return (getBytesLE(txBytes, pos, 32), pos + 4);
        } else if (ibit == 0xff) {
            return (getBytesLE(txBytes, pos, 64), pos + 8);
        }
    }
    
    function getBytesLE(bytes memory data, uint pos, uint bits) internal pure returns (uint256 result) {
        for (uint256 i = 0; i < bits / 8; i++) {
            result += uint256(uint8(data[pos + i])) * 2 ** (i * 8);
        }
    }
    

    
    
    
    
    
    


    function parseTransaction(bytes memory txBytes) internal pure
             returns (uint, uint, address, uint32)
    {
        
        uint output_value;
        uint32 assetGUID;
        address destinationAddress;
        uint32 version;
        uint pos = 0;
        version = bytesToUint32Flipped(txBytes, pos);
        if(version != SYSCOIN_TX_VERSION_ASSET_ALLOCATION_BURN){
            return (ERR_PARSE_TX_SYS, output_value, destinationAddress, assetGUID);
        }
        pos = skipInputs(txBytes, 4);
            
        (output_value, destinationAddress, assetGUID) = scanBurns(txBytes, pos);
        return (0, output_value, destinationAddress, assetGUID);
    }


  
    
    function skipWitnesses(bytes memory txBytes, uint pos, uint n_inputs) private pure
             returns (uint)
    {
        uint n_stack;
        (n_stack, pos) = parseVarInt(txBytes, pos);
        
        uint script_len;
        for (uint i = 0; i < n_inputs; i++) {
            for (uint j = 0; j < n_stack; j++) {
                (script_len, pos) = parseVarInt(txBytes, pos);
                pos += script_len;
            }
        }

        return n_stack;
    }    

    function skipInputs(bytes memory txBytes, uint pos) private pure
             returns (uint)
    {
        uint n_inputs;
        uint script_len;
        (n_inputs, pos) = parseVarInt(txBytes, pos);
        
        if(n_inputs == 0x00){
            (n_inputs, pos) = parseVarInt(txBytes, pos); 
            assert(n_inputs != 0x00);
            
            (n_inputs, pos) = parseVarInt(txBytes, pos);
        }
        require(n_inputs < 100);

        for (uint i = 0; i < n_inputs; i++) {
            pos += 36;  
            (script_len, pos) = parseVarInt(txBytes, pos);
            pos += script_len + 4;  
        }

        return pos;
    }
             
    
    function scanBurns(bytes memory txBytes, uint pos) private pure
             returns (uint, address, uint32)
    {
        uint script_len;
        uint output_value;
        uint32 assetGUID = 0;
        address destinationAddress;
        uint n_outputs;
        (n_outputs, pos) = parseVarInt(txBytes, pos);
        require(n_outputs < 10);
        for (uint i = 0; i < n_outputs; i++) {
            pos += 8;
            
            (script_len, pos) = parseVarInt(txBytes, pos);
            if(!isOpReturn(txBytes, pos)){
                
                pos += script_len;
                output_value = 0;
                continue;
            }
            
            pos += 1;
            (output_value, destinationAddress, assetGUID) = scanAssetDetails(txBytes, pos);  
            
            break;
        }

        return (output_value, destinationAddress, assetGUID);
    }

    function skipOutputs(bytes memory txBytes, uint pos) private pure
             returns (uint)
    {
        uint n_outputs;
        uint script_len;

        (n_outputs, pos) = parseVarInt(txBytes, pos);

        require(n_outputs < 10);

        for (uint i = 0; i < n_outputs; i++) {
            pos += 8;
            (script_len, pos) = parseVarInt(txBytes, pos);
            pos += script_len;
        }

        return pos;
    }
    
    
    function getSlicePos(bytes memory txBytes, uint pos) private pure
             returns (uint slicePos)
    {
        slicePos = skipInputs(txBytes, pos + 4);
        slicePos = skipOutputs(txBytes, slicePos);
        slicePos += 4; 
    }
    
    
    
    
    function scanMerkleBranch(bytes memory txBytes, uint pos, uint stop) private pure
             returns (uint[] memory, uint)
    {
        uint n_siblings;
        uint halt;

        (n_siblings, pos) = parseVarInt(txBytes, pos);

        if (stop == 0 || stop > n_siblings) {
            halt = n_siblings;
        } else {
            halt = stop;
        }

        uint[] memory sibling_values = new uint[](halt);

        for (uint i = 0; i < halt; i++) {
            sibling_values[i] = flip32Bytes(sliceBytes32Int(txBytes, pos));
            pos += 32;
        }

        return (sibling_values, pos);
    }   
    
    function sliceBytes20(bytes memory data, uint start) private pure returns (bytes20) {
        uint160 slice = 0;
        
        
        
        for (uint8 i = 0; i < 20; i++) {
            slice += uint160(uint8(data[i + start])) << (8 * (19 - i));
        }
        return bytes20(slice);
    }
    
    function sliceBytes32Int(bytes memory data, uint start) private pure returns (uint slice) {
        for (uint8 i = 0; i < 32; i++) {
            if (i + start < data.length) {
                slice += uint256(uint8(data[i + start])) << (8 * (31 - i));
            }
        }
    }

    
    
    
    
    
    
    
    
    function sliceArray(bytes memory _rawBytes, uint offset, uint _endIndex) internal view returns (bytes memory) {
        uint len = _endIndex - offset;
        bytes memory result = new bytes(len);
        assembly {
            
            if iszero(staticcall(gas, 0x04, add(add(_rawBytes, 0x20), offset), len, add(result, 0x20), len)) {
                revert(0, 0)
            }
        }
        return result;
    }
    
    
    
    function isOpReturn(bytes memory txBytes, uint pos) private pure
             returns (bool) {
        
        
        return 
            txBytes[pos] == byte(0x6a);
    }  
    
    function scanAssetDetails(bytes memory txBytes, uint pos) private pure
             returns (uint, address, uint32) {
                 
        uint32 assetGUID;
        address destinationAddress;
        uint output_value;
        uint8 op;
        
        (op, pos) = getOpcode(txBytes, pos);
        
        require(op == 0x04);
        assetGUID = bytesToUint32(txBytes, pos);
        pos += op;
        
        (op, pos) = getOpcode(txBytes, pos);
        require(op == 0x08);
        output_value = bytesToUint64(txBytes, pos);
        pos += op;
         
        (op, pos) = getOpcode(txBytes, pos);
        
        require(op == 0x14);
        destinationAddress = readEthereumAddress(txBytes, pos);       
        return (output_value, destinationAddress, assetGUID);
    }         
    
    function readEthereumAddress(bytes memory txBytes, uint pos) private pure
             returns (address) {
        uint256 data;
        assembly {
            data := mload(add(add(txBytes, 20), pos))
        }
        return address(uint160(data));
    }

    
    function getOpcode(bytes memory txBytes, uint pos) private pure
             returns (uint8, uint)
    {
        require(pos < txBytes.length);
        return (uint8(txBytes[pos]), pos + 1);
    }

    
    
    
    
    function flip32Bytes(uint _input) internal pure returns (uint result) {
        assembly {
            let pos := mload(0x40)
            for { let i := 0 } lt(i, 32) { i := add(i, 1) } {
                mstore8(add(pos, i), byte(sub(31, i), _input))
            }
            result := mload(pos)
        }
    }

    function parseAuxPoW(bytes memory rawBytes, uint pos) internal view
             returns (AuxPoW memory auxpow)
    {
        
        pos += 80; 
        uint slicePos;
        (slicePos) = getSlicePos(rawBytes, pos);
        auxpow.txHash = dblShaFlipMem(rawBytes, pos, slicePos - pos);
        pos = slicePos;
        
        pos += 32;
        (auxpow.parentMerkleProof, pos) = scanMerkleBranch(rawBytes, pos, 0);
        auxpow.coinbaseTxIndex = getBytesLE(rawBytes, pos, 32);
        pos += 4;
        (auxpow.chainMerkleProof, pos) = scanMerkleBranch(rawBytes, pos, 0);
        auxpow.syscoinHashIndex = getBytesLE(rawBytes, pos, 32);
        pos += 4;
        
        auxpow.blockHash = dblShaFlipMem(rawBytes, pos, 80);
        pos += 36; 
        auxpow.parentMerkleRoot = sliceBytes32Int(rawBytes, pos);
        pos += 40; 
        auxpow.parentNonce = getBytesLE(rawBytes, pos, 32);
        uint coinbaseMerkleRootPosition;
        (auxpow.coinbaseMerkleRoot, coinbaseMerkleRootPosition, auxpow.coinbaseMerkleRootCode) = findCoinbaseMerkleRoot(rawBytes);
    }

    
    
    
    
    function findCoinbaseMerkleRoot(bytes memory rawBytes) private pure
             returns (uint, uint, uint)
    {
        uint position;
        bool found = false;

        for (uint i = 0; i < rawBytes.length; ++i) {
            if (rawBytes[i] == 0xfa && rawBytes[i+1] == 0xbe && rawBytes[i+2] == 0x6d && rawBytes[i+3] == 0x6d) {
                if (found) { 
                    return (0, position - 4, ERR_FOUND_TWICE);
                } else {
                    found = true;
                    position = i + 4;
                }
            }
        }

        if (!found) { 
            return (0, position - 4, ERR_NO_MERGE_HEADER);
        } else {
            return (sliceBytes32Int(rawBytes, position), position - 4, 1);
        }
    }

    
    
    
    
    
    
    function makeMerkle(bytes32[] calldata hashes2) external pure returns (bytes32) {
        bytes32[] memory hashes = hashes2;
        uint length = hashes.length;
        if (length == 1) return hashes[0];
        require(length > 0);
        uint i;
        uint j;
        uint k;
        k = 0;
        while (length > 1) {
            k = 0;
            for (i = 0; i < length; i += 2) {
                j = i+1<length ? i+1 : length-1;
                hashes[k] = bytes32(concatHash(uint(hashes[i]), uint(hashes[j])));
                k += 1;
            }
            length = k;
        }
        return hashes[0];
    }

    
    
    
    
    
    
    
    function computeMerkle(uint _txHash, uint _txIndex, uint[] memory _siblings) internal pure returns (uint) {
        uint resultHash = _txHash;
        uint i = 0;
        while (i < _siblings.length) {
            uint proofHex = _siblings[i];

            uint sideOfSiblings = _txIndex % 2;  

            uint left;
            uint right;
            if (sideOfSiblings == 1) {
                left = proofHex;
                right = resultHash;
            } else if (sideOfSiblings == 0) {
                left = resultHash;
                right = proofHex;
            }

            resultHash = concatHash(left, right);

            _txIndex /= 2;
            i += 1;
        }

        return resultHash;
    }

    
    
    
    
    
    
    
    function computeParentMerkle(AuxPoW memory _ap) internal pure returns (uint) {
        return flip32Bytes(computeMerkle(_ap.txHash,
                                         _ap.coinbaseTxIndex,
                                         _ap.parentMerkleProof));
    }

    
    
    
    
    
    
    
    
    function computeChainMerkle(uint _blockHash, AuxPoW memory _ap) internal pure returns (uint) {
        return computeMerkle(_blockHash,
                             _ap.syscoinHashIndex,
                             _ap.chainMerkleProof);
    }

    
    
    
    
    
    
    
    
    function concatHash(uint _tx1, uint _tx2) internal pure returns (uint) {
        return flip32Bytes(uint(sha256(abi.encodePacked(sha256(abi.encodePacked(flip32Bytes(_tx1), flip32Bytes(_tx2)))))));
    }

    
    
    
    
    
    
    
    
    function checkAuxPoW(uint _blockHash, AuxPoW memory _ap) internal pure returns (uint) {
        if (_ap.coinbaseTxIndex != 0) {
            return ERR_COINBASE_INDEX;
        }

        if (_ap.coinbaseMerkleRootCode != 1) {
            return _ap.coinbaseMerkleRootCode;
        }

        if (computeChainMerkle(_blockHash, _ap) != _ap.coinbaseMerkleRoot) {
            return ERR_CHAIN_MERKLE;
        }

        if (computeParentMerkle(_ap) != _ap.parentMerkleRoot) {
            return ERR_PARENT_MERKLE;
        }

        return 1;
    }

    function sha256mem(bytes memory _rawBytes, uint offset, uint len) internal view returns (bytes32 result) {
        assembly {
            
            
            let ptr := mload(0x40)
            if iszero(staticcall(gas, 0x02, add(add(_rawBytes, 0x20), offset), len, ptr, 0x20)) {
                revert(0, 0)
            }
            result := mload(ptr)
        }
    }

    
    
    
    function dblShaFlip(bytes memory _dataBytes) internal pure returns (uint) {
        return flip32Bytes(uint(sha256(abi.encodePacked(sha256(abi.encodePacked(_dataBytes))))));
    }

    
    
    
    function dblShaFlipMem(bytes memory _rawBytes, uint offset, uint len) internal view returns (uint) {
        return flip32Bytes(uint(sha256(abi.encodePacked(sha256mem(_rawBytes, offset, len)))));
    }

    
    
    
    
    
    function targetFromBits(uint32 _bits) internal pure returns (uint) {
        uint exp = _bits / 0x1000000;  
        uint mant = _bits & 0xffffff;
        return mant * 256**(exp - 3);
    }

    

    
    
    
    
    
    

    
    
    
    
    
    function getHashPrevBlock(bytes memory _blockHeader) internal pure returns (uint) {
        uint hashPrevBlock;
        assembly {
            hashPrevBlock := mload(add(add(_blockHeader, 32), 0x04))
        }
        return flip32Bytes(hashPrevBlock);
    }

    
    
    
    
    
    function getHeaderMerkleRoot(bytes memory _blockHeader) public pure returns (uint) {
        uint merkle;
        assembly {
            merkle := mload(add(add(_blockHeader, 32), 0x24))
        }
        return flip32Bytes(merkle);
    }

    
    
    
    
    
    function getTimestamp(bytes memory _blockHeader) internal pure returns (uint32 time) {
        return bytesToUint32Flipped(_blockHeader, 0x44);
    }

    
    
    
    
    
    function getBits(bytes memory _blockHeader) internal pure returns (uint32 bits) {
        return bytesToUint32Flipped(_blockHeader, 0x48);
    }


    
    
    
    
    function parseHeaderBytes(bytes memory _rawBytes, uint pos) internal view returns (BlockHeader memory bh) {
        bh.bits = getBits(_rawBytes);
        bh.blockHash = dblShaFlipMem(_rawBytes, pos, 80);
    }

    uint32 constant VERSION_AUXPOW = (1 << 8);

    
    
    function bytesToUint32Flipped(bytes memory input, uint pos) internal pure returns (uint32 result) {
        result = uint32(uint8(input[pos])) + uint32(uint8(input[pos + 1]))*(2**8) + uint32(uint8(input[pos + 2]))*(2**16) + uint32(uint8(input[pos + 3]))*(2**24);
    }
    function bytesToUint64(bytes memory input, uint pos) internal pure returns (uint64 result) {
        result = uint64(uint8(input[pos+7])) + uint64(uint8(input[pos + 6]))*(2**8) + uint64(uint8(input[pos + 5]))*(2**16) + uint64(uint8(input[pos + 4]))*(2**24) + uint64(uint8(input[pos + 3]))*(2**32) + uint64(uint8(input[pos + 2]))*(2**40) + uint64(uint8(input[pos + 1]))*(2**48) + uint64(uint8(input[pos]))*(2**56);
    }
     function bytesToUint32(bytes memory input, uint pos) internal pure returns (uint32 result) {
        result = uint32(uint8(input[pos+3])) + uint32(uint8(input[pos + 2]))*(2**8) + uint32(uint8(input[pos + 1]))*(2**16) + uint32(uint8(input[pos]))*(2**24);
    }  
    
    function isMergeMined(bytes memory _rawBytes, uint pos) internal pure returns (bool) {
        return bytesToUint32Flipped(_rawBytes, pos) & VERSION_AUXPOW != 0;
    }

    
    
    
	
    
    function verifyBlockHeader(bytes calldata _blockHeaderBytes, uint _pos, uint _proposedBlockHash) external view returns (uint) {
        BlockHeader memory blockHeader = parseHeaderBytes(_blockHeaderBytes, _pos);
        uint blockSha256Hash = blockHeader.blockHash;
		
		if(blockSha256Hash != _proposedBlockHash){
			return (ERR_INVALID_HEADER_HASH);
		}
        uint target = targetFromBits(blockHeader.bits);
        if (_blockHeaderBytes.length > 80 && isMergeMined(_blockHeaderBytes, 0)) {
            AuxPoW memory ap = parseAuxPoW(_blockHeaderBytes, _pos);
            if (ap.blockHash > target) {

                return (ERR_PROOF_OF_WORK_AUXPOW);
            }
            uint auxPoWCode = checkAuxPoW(blockSha256Hash, ap);
            if (auxPoWCode != 1) {
                return (auxPoWCode);
            }
            return (0);
        } else {
            if (_proposedBlockHash > target) {
                return (ERR_PROOF_OF_WORK);
            }
            return (0);
        }
    }

    
    int64 constant TARGET_TIMESPAN =  int64(21600); 
    int64 constant TARGET_TIMESPAN_DIV_4 = TARGET_TIMESPAN / int64(4);
    int64 constant TARGET_TIMESPAN_MUL_4 = TARGET_TIMESPAN * int64(4);
    int64 constant TARGET_TIMESPAN_ADJUSTMENT =  int64(360);  
    uint constant POW_LIMIT =    0x00000fffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    function getWorkFromBits(uint32 bits) external pure returns(uint) {
        uint target = targetFromBits(bits);
        return (~target / (target + 1)) + 1;
    }
    function getLowerBoundDifficultyTarget() external pure returns (int64) {
        return TARGET_TIMESPAN_DIV_4;
    }
     function getUpperBoundDifficultyTarget() external pure returns (int64) {
        return TARGET_TIMESPAN_MUL_4;
    }   
    
    
    
    
    function calculateDifficulty(int64 _actualTimespan, uint32 _bits) external pure returns (uint32 result) {
       int64 actualTimespan = _actualTimespan;
        
        if (_actualTimespan < TARGET_TIMESPAN_DIV_4) {
            actualTimespan = TARGET_TIMESPAN_DIV_4;
        } else if (_actualTimespan > TARGET_TIMESPAN_MUL_4) {
            actualTimespan = TARGET_TIMESPAN_MUL_4;
        }

        
        uint bnNew = targetFromBits(_bits);
        bnNew = bnNew * uint(actualTimespan);
        bnNew = uint(bnNew) / uint(TARGET_TIMESPAN);

        if (bnNew > POW_LIMIT) {
            bnNew = POW_LIMIT;
        }

        return toCompactBits(bnNew);
    }

    
    
    
    
    
    function shiftRight(uint _val, uint _shift) private pure returns (uint) {
        return _val / uint(2)**_shift;
    }

    
    
    
    
    
    function shiftLeft(uint _val, uint _shift) private pure returns (uint) {
        return _val * uint(2)**_shift;
    }

    
    
    
    
    function bitLen(uint _val) private pure returns (uint length) {
        uint int_type = _val;
        while (int_type > 0) {
            int_type = shiftRight(int_type, 1);
            length += 1;
        }
    }

    
    
    
    
    
    
    function toCompactBits(uint _val) private pure returns (uint32) {
        uint nbytes = uint (shiftRight((bitLen(_val) + 7), 3));
        uint32 compact = 0;
        if (nbytes <= 3) {
            compact = uint32 (shiftLeft((_val & 0xFFFFFF), 8 * (3 - nbytes)));
        } else {
            compact = uint32 (shiftRight(_val, 8 * (nbytes - 3)));
            compact = uint32 (compact & 0xFFFFFF);
        }

        
        
        if ((compact & 0x00800000) > 0) {
            compact = uint32(shiftRight(compact, 8));
            nbytes += 1;
        }

        return compact | uint32(shiftLeft(nbytes, 24));
    }
}

contract SyscoinBattleManager is SyscoinErrorCodes {

    enum ChallengeState {
        Unchallenged,             
        Challenged,               
        QueryMerkleRootHashes,    
        RespondMerkleRootHashes,  
        QueryLastBlockHeader,     
        PendingVerification,      
        SuperblockVerified,       
        SuperblockFailed          
    }

    enum BlockInfoStatus {
        Uninitialized,
        Requested,
		Verified
    }

    struct BlockInfo {
        bytes32 prevBlock;
        uint64 timestamp;
        uint32 bits;
        BlockInfoStatus status;
        bytes32 blockHash;
    }

    struct BattleSession {
        bytes32 id;
        bytes32 superblockHash;
        address submitter;
        address challenger;
        uint lastActionTimestamp;         
        uint lastActionClaimant;          
        uint lastActionChallenger;        
        uint actionsCounter;              
        bytes32[] blockHashes;            

        BlockInfo blocksInfo;

        ChallengeState challengeState;    
    }


    mapping (bytes32 => BattleSession) sessions;



    uint public superblockDuration;         
    uint public superblockTimeout;          


    
    SyscoinMessageLibrary.Network private net;


    
    SyscoinClaimManagerI trustedSyscoinClaimManager;

    
    SyscoinSuperblocksI trustedSuperblocks;

    event NewBattle(bytes32 superblockHash, bytes32 sessionId, address submitter, address challenger);
    event ChallengerConvicted(bytes32 superblockHash, bytes32 sessionId, address challenger);
    event SubmitterConvicted(bytes32 superblockHash, bytes32 sessionId, address submitter);

    event QueryMerkleRootHashes(bytes32 superblockHash, bytes32 sessionId, address submitter);
    event RespondMerkleRootHashes(bytes32 superblockHash, bytes32 sessionId, address challenger);
    event QueryLastBlockHeader(bytes32 sessionId, address submitter);
    event RespondLastBlockHeader(bytes32 sessionId, address challenger);
    event ErrorBattle(bytes32 sessionId, uint err);
    modifier onlyFrom(address sender) {
        require(msg.sender == sender);
        _;
    }

    modifier onlyClaimant(bytes32 sessionId) {
        require(msg.sender == sessions[sessionId].submitter);
        _;
    }

    modifier onlyChallenger(bytes32 sessionId) {
        require(msg.sender == sessions[sessionId].challenger);
        _;
    }

    
    
    
    
    
    constructor(
        SyscoinMessageLibrary.Network _network,
        SyscoinSuperblocksI _superblocks,
        uint _superblockDuration,
        uint _superblockTimeout
    ) public {
        net = _network;
        trustedSuperblocks = _superblocks;
        superblockDuration = _superblockDuration;
        superblockTimeout = _superblockTimeout;
    }

    function setSyscoinClaimManager(SyscoinClaimManagerI _syscoinClaimManager) public {
        require(address(trustedSyscoinClaimManager) == address(0) && address(_syscoinClaimManager) != address(0));
        trustedSyscoinClaimManager = _syscoinClaimManager;
    }

    
    function beginBattleSession(bytes32 superblockHash, address submitter, address challenger)
        onlyFrom(address(trustedSyscoinClaimManager)) public returns (bytes32) {
        bytes32 sessionId = keccak256(abi.encode(superblockHash, msg.sender, challenger));
        BattleSession storage session = sessions[sessionId];
        if(session.id != 0x0){
            revert();
        }
        session.id = sessionId;
        session.superblockHash = superblockHash;
        session.submitter = submitter;
        session.challenger = challenger;
        session.lastActionTimestamp = block.timestamp;
        session.lastActionChallenger = 0;
        session.lastActionClaimant = 1;     
        session.actionsCounter = 1;
        session.challengeState = ChallengeState.Challenged;


        emit NewBattle(superblockHash, sessionId, submitter, challenger);
        return sessionId;
    }

    
    function doQueryMerkleRootHashes(BattleSession storage session) internal returns (uint) {
        if (session.challengeState == ChallengeState.Challenged) {
            session.challengeState = ChallengeState.QueryMerkleRootHashes;
            assert(msg.sender == session.challenger);
            return ERR_SUPERBLOCK_OK;
        }
        return ERR_SUPERBLOCK_BAD_STATUS;
    }

    
    function queryMerkleRootHashes(bytes32 superblockHash, bytes32 sessionId) onlyChallenger(sessionId) public {
        BattleSession storage session = sessions[sessionId];
        uint err = doQueryMerkleRootHashes(session);
        if (err != ERR_SUPERBLOCK_OK) {
            emit ErrorBattle(sessionId, err);
        } else {
            session.actionsCounter += 1;
            session.lastActionTimestamp = block.timestamp;
            session.lastActionChallenger = session.actionsCounter;
            emit QueryMerkleRootHashes(superblockHash, sessionId, session.submitter);
        }
    }

    
    function doVerifyMerkleRootHashes(BattleSession storage session, bytes32[] memory blockHashes) internal returns (uint) {
        require(session.blockHashes.length == 0);
        if (session.challengeState == ChallengeState.QueryMerkleRootHashes) {
            (bytes32 merkleRoot, , ,bytes32 lastHash,, , ,,) = getSuperblockInfo(session.superblockHash);
            if (lastHash != blockHashes[blockHashes.length - 1]){
                return ERR_SUPERBLOCK_BAD_LASTBLOCK;
            }
            if(net != SyscoinMessageLibrary.Network.REGTEST && blockHashes.length != superblockDuration){
                return ERR_SUPERBLOCK_BAD_BLOCKHEIGHT;
            }
            if (merkleRoot != SyscoinMessageLibrary.makeMerkle(blockHashes)) {
                return ERR_SUPERBLOCK_INVALID_MERKLE;
            }
            session.blockHashes = blockHashes;
            session.challengeState = ChallengeState.RespondMerkleRootHashes;
            return ERR_SUPERBLOCK_OK;
        }
        return ERR_SUPERBLOCK_BAD_STATUS;
    }

    
    function respondMerkleRootHashes(bytes32 superblockHash, bytes32 sessionId, bytes32[] memory blockHashes) onlyClaimant(sessionId) public {
        BattleSession storage session = sessions[sessionId];
        uint err = doVerifyMerkleRootHashes(session, blockHashes);
        if (err != 0) {
            emit ErrorBattle(sessionId, err);
        } else {
            session.actionsCounter += 1;
            session.lastActionTimestamp = block.timestamp;
            session.lastActionClaimant = session.actionsCounter;
            emit RespondMerkleRootHashes(superblockHash, sessionId, session.challenger);
        }
    }
       
    
    function doQueryLastBlockHeader(BattleSession storage session) internal returns (uint) {
        if (session.challengeState == ChallengeState.RespondMerkleRootHashes) {
            require(session.blocksInfo.status == BlockInfoStatus.Uninitialized);
            session.challengeState = ChallengeState.QueryLastBlockHeader;
            session.blocksInfo.status = BlockInfoStatus.Requested;
            return ERR_SUPERBLOCK_OK;
        }
        return ERR_SUPERBLOCK_BAD_STATUS;
    }

    
    function queryLastBlockHeader(bytes32 sessionId) onlyChallenger(sessionId) public {
        BattleSession storage session = sessions[sessionId];
        uint err = doQueryLastBlockHeader(session);
        if (err != ERR_SUPERBLOCK_OK) {
            emit ErrorBattle(sessionId, err);
        } else {
            session.actionsCounter += 1;
            session.lastActionTimestamp = block.timestamp;
            session.lastActionChallenger = session.actionsCounter;
            emit QueryLastBlockHeader(sessionId, session.submitter);
        }
    }

    
    function verifyBlockAuxPoW(
        BlockInfo storage blockInfo,
        bytes32 blockHash,
        bytes memory blockHeader
    ) internal returns (uint) {
        uint err = SyscoinMessageLibrary.verifyBlockHeader(blockHeader, 0, uint(blockHash));
        if (err != 0) {
            return err;
        }
        blockInfo.timestamp = SyscoinMessageLibrary.getTimestamp(blockHeader);
        blockInfo.bits = SyscoinMessageLibrary.getBits(blockHeader);
        blockInfo.prevBlock = bytes32(SyscoinMessageLibrary.getHashPrevBlock(blockHeader));
        blockInfo.blockHash = blockHash;
        return ERR_SUPERBLOCK_OK;
    }

    
    function doRespondLastBlockHeader(
        BattleSession storage session,
        bytes memory blockHeader
    ) internal returns (uint) {
        if (session.challengeState == ChallengeState.QueryLastBlockHeader) {
            bytes32 blockSha256Hash = bytes32(SyscoinMessageLibrary.dblShaFlipMem(blockHeader, 0, 80));
            if(session.blockHashes[session.blockHashes.length-1] != blockSha256Hash){
                return (ERR_SUPERBLOCK_BAD_LASTBLOCK);
            }
            BlockInfo storage blockInfo = session.blocksInfo;
            if (blockInfo.status != BlockInfoStatus.Requested) {
                return (ERR_SUPERBLOCK_BAD_SYSCOIN_STATUS);
            }

			
            
            
            uint err = verifyBlockAuxPoW(blockInfo, blockSha256Hash, blockHeader);
            if (err != ERR_SUPERBLOCK_OK) {
                return (err);
            }

            session.challengeState = ChallengeState.PendingVerification;
            blockInfo.status = BlockInfoStatus.Verified;
            return (ERR_SUPERBLOCK_OK);
        }
        return (ERR_SUPERBLOCK_BAD_STATUS);
    }
    function respondLastBlockHeader(
        bytes32 sessionId,
        bytes memory blockHeader
        ) onlyClaimant(sessionId) public {
        BattleSession storage session = sessions[sessionId];
        (uint err) = doRespondLastBlockHeader(session, blockHeader);
        if (err != 0) {
            emit ErrorBattle(sessionId, err);
        }else{
            session.actionsCounter += 1;
            session.lastActionTimestamp = block.timestamp;
            session.lastActionClaimant = session.actionsCounter;
            emit RespondLastBlockHeader(sessionId, session.challenger);
        }
    }     

    
    function validateLastBlocks(BattleSession storage session) internal view returns (uint) {
        if (session.blockHashes.length <= 0) {
            return ERR_SUPERBLOCK_BAD_LASTBLOCK;
        }
        uint lastTimestamp;
        uint prevTimestamp;
        bytes32 parentId;
        bytes32 lastBlockHash;
        (, , lastTimestamp, lastBlockHash, ,parentId,,,) = getSuperblockInfo(session.superblockHash);
        bytes32 blockSha256Hash = session.blockHashes[session.blockHashes.length - 1];
        BlockInfo storage blockInfo = session.blocksInfo;
        if(session.blockHashes.length > 2){
            bytes32 prevBlockSha256Hash = session.blockHashes[session.blockHashes.length - 2];
            if(blockInfo.prevBlock != prevBlockSha256Hash){
                return ERR_SUPERBLOCK_BAD_PREVBLOCK;
            }

        }
        if(blockSha256Hash != lastBlockHash){
            return ERR_SUPERBLOCK_BAD_LASTBLOCK;
        }
        if (blockInfo.timestamp != lastTimestamp) {
            return ERR_SUPERBLOCK_BAD_TIMESTAMP;
        }
        if (blockInfo.status != BlockInfoStatus.Verified) {
            return ERR_SUPERBLOCK_BAD_LASTBLOCK_STATUS;
        }
        (, ,prevTimestamp , ,,,, , ) = getSuperblockInfo(parentId);
        
        if (prevTimestamp > lastTimestamp) {
            return ERR_SUPERBLOCK_BAD_TIMESTAMP;
        }
        return ERR_SUPERBLOCK_OK;
    }

    
    function validateProofOfWork(BattleSession storage session) internal view returns (uint) {
        uint accWork;
        bytes32 prevBlock;
        uint heightDiff = superblockDuration; 
        uint prevWork;
        uint32 prevBits;
        uint superblockHeight;
        bytes32 superblockHash = session.superblockHash;
        (, accWork, ,,prevBits,prevBlock,,,superblockHeight) = getSuperblockInfo(superblockHash);
        BlockInfo storage blockInfo = session.blocksInfo;
        if(accWork <= 0){
            return ERR_SUPERBLOCK_BAD_ACCUMULATED_WORK;
        }    
        if(prevBits != blockInfo.bits){
            return ERR_SUPERBLOCK_BAD_MISMATCH;
        }
        (, prevWork, ,, prevBits,, ,,) = getSuperblockInfo(prevBlock);
        if(net == SyscoinMessageLibrary.Network.REGTEST)
            heightDiff = session.blockHashes.length;
         
        if(accWork <= prevWork){
            return ERR_SUPERBLOCK_INVALID_ACCUMULATED_WORK;
        }
        
        if(net == SyscoinMessageLibrary.Network.MAINNET){
            if(((superblockHeight-2) % 6) == 0){
                if(prevBits == blockInfo.bits){
                    return ERR_SUPERBLOCK_INVALID_DIFFICULTY_ADJUSTMENT;
                }
                
                uint32 lowerBoundDiff = SyscoinMessageLibrary.calculateDifficulty(SyscoinMessageLibrary.getLowerBoundDifficultyTarget()-1, prevBits);
                uint32 upperBoundDiff = SyscoinMessageLibrary.calculateDifficulty(SyscoinMessageLibrary.getUpperBoundDifficultyTarget()+1, prevBits);
                if(blockInfo.bits < lowerBoundDiff || blockInfo.bits > upperBoundDiff){
                    return ERR_SUPERBLOCK_BAD_RETARGET;
                }          
            }
            
            else if(prevBits != blockInfo.bits){
                return ERR_SUPERBLOCK_BAD_BITS;
            }

            uint newWork = prevWork + (SyscoinMessageLibrary.getWorkFromBits(blockInfo.bits)*heightDiff);

            if (newWork != accWork) {
                return ERR_SUPERBLOCK_BAD_ACCUMULATED_WORK;
            }
        }   
        return ERR_SUPERBLOCK_OK;
    }
    
    
    function doVerifySuperblock(BattleSession storage session, bytes32 sessionId) internal returns (uint) {
        if (session.challengeState == ChallengeState.PendingVerification) {
            uint err;
            err = validateLastBlocks(session);
            if (err != 0) {
                emit ErrorBattle(sessionId, err);
                return 2;
            }
            err = validateProofOfWork(session);
            if (err != 0) {
                emit ErrorBattle(sessionId, err);
                return 2;
            }
            return 1;
        } else if (session.challengeState == ChallengeState.SuperblockFailed) {
            return 2;
        }
        return 0;
    }

    
    function verifySuperblock(bytes32 sessionId) public {
        BattleSession storage session = sessions[sessionId];
        uint status = doVerifySuperblock(session, sessionId);
        if (status == 1) {
            convictChallenger(sessionId, session.challenger, session.superblockHash, false);
        } else if (status == 2) {
            convictSubmitter(sessionId, session.submitter, session.superblockHash);
        }
    }

    
    function timeout(bytes32 sessionId) public returns (uint) {
        BattleSession storage session = sessions[sessionId];
        if (session.challengeState == ChallengeState.SuperblockFailed ||
            (session.lastActionChallenger > session.lastActionClaimant &&
            block.timestamp > session.lastActionTimestamp + superblockTimeout)) {
            convictSubmitter(sessionId, session.submitter, session.superblockHash);
            return ERR_SUPERBLOCK_OK;
        } else if (session.lastActionClaimant > session.lastActionChallenger &&
            block.timestamp > session.lastActionTimestamp + superblockTimeout) {
            convictChallenger(sessionId, session.challenger, session.superblockHash, true);
            return ERR_SUPERBLOCK_OK;
        }
        emit ErrorBattle(sessionId, ERR_SUPERBLOCK_NO_TIMEOUT);
        return ERR_SUPERBLOCK_NO_TIMEOUT;
    }

    
    function convictChallenger(bytes32 sessionId, address challenger, bytes32 superblockHash, bool timedOut) internal {
        BattleSession storage session = sessions[sessionId];
        sessionDecided(sessionId, superblockHash, session.submitter, session.challenger, timedOut);
        disable(sessionId);
        emit ChallengerConvicted(superblockHash, sessionId, challenger);
    }

    
    function convictSubmitter(bytes32 sessionId, address submitter, bytes32 superblockHash) internal {
        BattleSession storage session = sessions[sessionId];
        sessionDecided(sessionId, superblockHash, session.challenger, session.submitter, false);
        disable(sessionId);
        emit SubmitterConvicted(superblockHash, sessionId, submitter);
    }

    
    
    function disable(bytes32 sessionId) internal {
        delete sessions[sessionId];
    }

    
    function getChallengerHitTimeout(bytes32 sessionId) public view returns (bool) {
        BattleSession storage session = sessions[sessionId];
        return (session.lastActionClaimant > session.lastActionChallenger &&
            block.timestamp > session.lastActionTimestamp + superblockTimeout);
    }

    
    function getSubmitterHitTimeout(bytes32 sessionId) public view returns (bool) {
        BattleSession storage session = sessions[sessionId];
        return (session.lastActionChallenger > session.lastActionClaimant &&
            block.timestamp > session.lastActionTimestamp + superblockTimeout);
    }

    
    function getSyscoinBlockHashes(bytes32 sessionId) public view returns (bytes32[] memory) {
        return sessions[sessionId].blockHashes;
    }

    function getSuperblockBySession(bytes32 sessionId) public view returns (bytes32) {
        return sessions[sessionId].superblockHash;
    }

    function getSessionStatus(bytes32 sessionId) public view returns (BlockInfoStatus) {
        BattleSession storage session = sessions[sessionId];
        return session.blocksInfo.status;
    }
    function getSessionChallengeState(bytes32 sessionId) public view returns (ChallengeState) {
        return sessions[sessionId].challengeState;
    }
    
    function sessionDecided(bytes32 sessionId, bytes32 superblockHash, address winner, address loser, bool timedOut) internal {
        trustedSyscoinClaimManager.sessionDecided(sessionId, superblockHash, winner, loser, timedOut);
    }

    
    function getSuperblockInfo(bytes32 superblockHash) internal view returns (
        bytes32 _blocksMerkleRoot,
        uint _accumulatedWork,
        uint _timestamp,
        bytes32 _lastHash,
        uint32 _lastBits,
        bytes32 _parentId,
        address _submitter,
        SyscoinSuperblocksI.Status _status,
        uint32 _height
    ) {
        return trustedSuperblocks.getSuperblock(superblockHash);
    }
    
    
    function hasDeposit(address who, uint amount) internal view returns (bool) {
        return trustedSyscoinClaimManager.getDeposit(who) >= amount;
    }

    
    function bondDeposit(bytes32 superblockHash, address account, uint amount) internal returns (uint) {
        return trustedSyscoinClaimManager.bondDeposit(superblockHash, account, amount);
    }
}
