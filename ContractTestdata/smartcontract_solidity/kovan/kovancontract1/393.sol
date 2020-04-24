/**
 *Submitted for verification at Etherscan.io on 2019-01-31
*/

pragma solidity 0.5.0;

// File: contracts/HeaderParser.sol

contract HeaderParser {

    uint constant TIMESTAMP_BYTES               = 4;
    uint constant PRODUCER_BYTES                = 8;
    uint constant CONFIRMED_BYTES               = 2;
    uint constant PREVIOUS_BYTES                = 32;
    uint constant TX_MROOT_BYTES                = 32;
    uint constant ACTION_MROOT_BYTES            = 32;
    uint constant SCHEDULE_BYTES                = 4;
    uint constant HAVE_NEW_PRODUCERS_BYTES      = 1;
    uint constant PRODUCERS_VERSION_BYTES       = 4;
    uint constant PRODUCERS_NAME_BYTES          = 8;
    uint constant PRODUCERS_AMOUNT_BYTES        = 1;
    uint constant PRODUCERS_KEY_HIGH_BYTES      = 32;

    function sliceBytes(bytes memory bs, uint start, uint size) internal pure returns (uint)
    {
        require(bs.length >= start + size, "slicing out of range");
        uint x;
        assembly {
            x := mload(add(bs, add(size, start)))
        }
        return x;
    }

    function reverseBytes(uint32 input) internal pure returns (uint32 output)
    {
        output = input >> 24 & 0xff | input >> 8 & 0xff00 | input << 8 & 0xff0000 |  input << 24 & 0xff000000;
    }

    function parseFixedFields0(bytes memory blockHeader)
        internal
        pure
        returns (uint32 ts, uint64 producer, uint16 confirmed, uint previous, uint tx_mroot)
    {
        uint offset = 0;

        ts = reverseBytes((uint32)(sliceBytes(blockHeader, offset, TIMESTAMP_BYTES)));
        offset = offset + TIMESTAMP_BYTES;

        producer = (uint64)(sliceBytes(blockHeader, offset, PRODUCER_BYTES));
        offset = offset + PRODUCER_BYTES;

        confirmed = (uint16)(sliceBytes(blockHeader, offset, CONFIRMED_BYTES));
        offset = offset + CONFIRMED_BYTES;

        previous = (uint256)(sliceBytes(blockHeader, offset, PREVIOUS_BYTES));
        offset = offset + PREVIOUS_BYTES;

        tx_mroot = (uint256)(sliceBytes(blockHeader, offset, TX_MROOT_BYTES));
        offset = offset + TX_MROOT_BYTES;
    }

    function parseFixedFields1(bytes memory blockHeader)
        internal
        pure
        returns (uint32 schedule, uint action_mroot, uint8 have_new_producers)
    {
        uint offset = 78;

        action_mroot = (uint256)(sliceBytes(blockHeader, offset, ACTION_MROOT_BYTES));
        offset = offset + ACTION_MROOT_BYTES;

        schedule = reverseBytes((uint32)(sliceBytes(blockHeader, offset, SCHEDULE_BYTES)));
        offset = offset + SCHEDULE_BYTES;

        have_new_producers = (uint8)(sliceBytes(blockHeader, offset, HAVE_NEW_PRODUCERS_BYTES));
        offset = offset + HAVE_NEW_PRODUCERS_BYTES;
    }

    function parseNonFixedFields(bytes memory blockHeader)
        internal
        pure
        returns (uint32 version, uint8 amount, uint64[21] memory producerNames, bytes32[21] memory producerKeyHighChunk)
    {
        uint offset = 115;

        version = reverseBytes((uint32)(sliceBytes(blockHeader, offset, PRODUCERS_VERSION_BYTES)));
        offset = offset + PRODUCERS_VERSION_BYTES;

        amount = (uint8)(sliceBytes(blockHeader, offset, PRODUCERS_AMOUNT_BYTES));
        offset = offset + PRODUCERS_AMOUNT_BYTES;

        for (uint i = 0; i < amount; i++) {
            producerNames[i] = (uint64)(sliceBytes(blockHeader, offset, PRODUCERS_NAME_BYTES));
            offset = offset + PRODUCERS_NAME_BYTES;

            offset = offset + 1; // skip 1 zeroed bytes
            offset = offset + 1; // skip first byte of the key

            producerKeyHighChunk[i] = (bytes32)(sliceBytes(blockHeader, offset, PRODUCERS_KEY_HIGH_BYTES));
            offset = offset + PRODUCERS_KEY_HIGH_BYTES;
        }
    } 

    function parseHeader(bytes memory blockHeader)
        public
        pure
        returns (
            uint32 timestamp,
            uint64 producer,
            uint16 confirmed,
            uint previous,
            uint tx_mroot,
            uint32 schedule,
            uint action_mroot,
            uint32 version,
            uint8 amount,
            uint64[21] memory producerNames,
            bytes32[21] memory producerKeyHighChunk // TODO: this should be 33 bytes!!!
        )
    {
        (timestamp, producer, confirmed, previous, tx_mroot) = parseFixedFields0(blockHeader);
        uint8 have_new_producers;
        (schedule, action_mroot, have_new_producers) = parseFixedFields1(blockHeader);

        if(have_new_producers != 0 ) {
            (version, amount, producerNames, producerKeyHighChunk) = parseNonFixedFields(blockHeader);
        }
    }

    function getBlockNumFromHeader(bytes memory header) internal pure returns (uint) {
        uint offset = TIMESTAMP_BYTES + PRODUCER_BYTES + CONFIRMED_BYTES;
        bytes32 previous = (bytes32)(sliceBytes(header, offset, PREVIOUS_BYTES));
        return getBlockNumFromId((bytes32)(previous)) + 1;
    }

    function getIdFromHeader(bytes memory header) internal pure returns (bytes32) {
        uint blockNum =getBlockNumFromHeader(header);
        return headerToId(header, blockNum);
    }

    function getScheduleVersionFromHeader(bytes memory header) internal pure returns (uint32) {
        uint offset = 78 + ACTION_MROOT_BYTES;
        uint32 schedule = reverseBytes((uint32)(sliceBytes(header, offset, SCHEDULE_BYTES)));
        return schedule;
    }

    function getActionMrootFromHeader(bytes memory header) internal pure returns (bytes32) {
        uint offset = 78;
        bytes32 actionMroot = (bytes32)(sliceBytes(header, offset, ACTION_MROOT_BYTES));
        return actionMroot;
    }

        function headerToId(bytes memory header, uint blockNum) internal pure returns (bytes32) {
        bytes32 headerHash = sha256(header);
        uint blockNumShifted = blockNum << (256 - 32);
        uint mask = ((2**(256 - 32))-1);
        uint result = ((uint)(headerHash) & mask) | blockNumShifted;
        return (bytes32)(result);
    }

    function getBlockNumFromId(bytes32 id) internal pure returns (uint) {
        return ((uint)(id) >> (256 - 32));
    }

}

// File: contracts/MerkleProof.sol

contract MerkleProof {

    uint constant OR_MASK =   0x8000000000000000000000000000000000000000000000000000000000000000;
    uint constant AND_MASK =  0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function makeCanonicalLeft(bytes32 self) internal pure returns (bytes32) {
        return (bytes32)((uint)(self) & AND_MASK);
    }

    function makeCanonicalRight(bytes32 self) internal pure returns (bytes32) {
        return (bytes32)((uint)(self) | OR_MASK);
    }

    function isCanonicalRight(bytes32 self) internal pure returns (bool) {
        return (((uint)(self) >> 255) == 1);
    }

    function proofIsValid(bytes32 leaf, bytes32[] memory path, bytes32 expectedRoot) internal pure returns (bool) {
        bytes32 current = leaf;
        bytes32 left;
        bytes32 right;
        
        for (uint i = 0; i < path.length; i++) {
            if(isCanonicalRight(path[i])) {
                left = current;
                right = path[i];
            } else {
                left = path[i];
                right = current;
            }
            left = makeCanonicalLeft(left);
            right = makeCanonicalRight(right);

            current = sha256(abi.encodePacked(left, right));
        }

        return (current == expectedRoot);
    }
}

// File: contracts/Relay.sol

contract Relay is HeaderParser, MerkleProof {

    struct HeadersData {
        bytes blockHeaders;
        uint[] blockHeaderSizes;
        bytes32[] blockMerkleHashs;
        bytes32[] blockMerklePaths;
        uint[] blockMerklePathSizes;
        bytes32[] pendingScheduleHashs;
        uint8[] sigVs;
        bytes32[] sigRs;
        bytes32[] sigSs;
        uint[] claimedKeyIndices;
    }

    struct verifyActionData {
        uint irreversibleBlockToReference;
        bytes blockHeader;
        bytes32 blockMerkleHash;
        bytes32[] blockMerklePath;
        bytes32 pendingScheduleHash;
        uint8 sigV;
        bytes32 sigR;
        bytes32 sigS;
        uint claimedKeyIndex;
        bytes32[] actionPath;
        bytes32 actionRecieptDigest;
    }

    /* globals */ 
    uint public numProducers;
    uint public scheduleVersion;
    uint public lastIrreversibleBlock;

    /* per Schedule */
    mapping(uint=>bytes32[21]) public pubKeysFirstPartsPerSchedule;
    mapping(uint=>bytes32[21]) public pubKeysSecondPartsPerSchedule;

    /* per relayed block */
    mapping(uint=>bool) public isBlockIrreversible;
    mapping(uint=>bytes) public irreversibleBlockHeaders;
    mapping(uint=>bytes32) public blockMroot;

    function storeInitialSchedule(
        uint inputScheduleVersion,
        bytes32[] memory inputPubKeysFirstParts,
        bytes32[] memory inputPubKeysSecondParts,
        uint numKeys
    ) public {
        scheduleVersion = inputScheduleVersion;
        numProducers = numKeys;
        for( uint idx = 0; idx < numKeys; idx++) {
            pubKeysFirstPartsPerSchedule[inputScheduleVersion][idx] = inputPubKeysFirstParts[idx];
            pubKeysSecondPartsPerSchedule[inputScheduleVersion][idx] = inputPubKeysSecondParts[idx]; 
        }
    }

    /* verify blocks have been built on the new producers block and store new schedule */
    function changeSchedule(
        bytes memory blockHeaders,
        uint[] memory blockHeaderSizes,
        bytes32[] memory blockMerkleHashs,
        bytes32[] memory blockMerklePaths,
        uint[] memory blockMerklePathSizes,
        bytes32[] memory pendingScheduleHashs,
        uint8[] memory sigVs,
        bytes32[] memory sigRs,
        bytes32[] memory sigSs,
        uint[] memory claimedKeyIndices,
        bytes32[] memory completingKeyParts
        
    ) public {
       HeadersData memory headersData = HeadersData({
            blockHeaders:blockHeaders,
            blockHeaderSizes:blockHeaderSizes,
            blockMerkleHashs:blockMerkleHashs,
            blockMerklePaths:blockMerklePaths,
            blockMerklePathSizes:blockMerklePathSizes,
            pendingScheduleHashs:pendingScheduleHashs,
            sigVs:sigVs,
            sigRs:sigRs,
            sigSs:sigSs,
            claimedKeyIndices:claimedKeyIndices
        });

        require(verifyBlockIrreversible(headersData));
        require(storeNewSchedule(blockHeaders, completingKeyParts));
    }

    function relayBlock(
        bytes memory blockHeaders,
        uint[] memory blockHeaderSizes,
        bytes32[] memory blockMerkleHashs,
        bytes32[] memory blockMerklePaths,
        uint[] memory blockMerklePathSizes,
        bytes32[] memory pendingScheduleHashs,
        uint8[] memory sigVs,
        bytes32[] memory sigRs,
        bytes32[] memory sigSs,
        uint[] memory claimedKeyIndices
    )
        public
        returns (bool)
    {
        HeadersData memory headersData = HeadersData({
            blockHeaders:blockHeaders,
            blockHeaderSizes:blockHeaderSizes,
            blockMerkleHashs:blockMerkleHashs,
            blockMerklePaths:blockMerklePaths,
            blockMerklePathSizes:blockMerklePathSizes,
            pendingScheduleHashs:pendingScheduleHashs,
            sigVs:sigVs,
            sigRs:sigRs,
            sigSs:sigSs,
            claimedKeyIndices:claimedKeyIndices
        });

        require(verifyBlockIrreversible(headersData));
        require(storeHeader(headersData));
    }

    function verifyAction(
        uint irreversibleBlockToReference,
        bytes memory blockHeader,
        bytes32 blockMerkleHash,
        bytes32[] memory blockMerklePath,
        bytes32 pendingScheduleHash,
        uint8 sigV,
        bytes32 sigR,
        bytes32 sigS,
        uint claimedKeyIndex,
        bytes32[] memory actionPath,
        bytes32 actionRecieptDigest // calculated offchain from action parameters
    )
        public
        view
        returns (bool)
    {
        verifyActionData memory actionData = verifyActionData({
            irreversibleBlockToReference:irreversibleBlockToReference,
            blockHeader:blockHeader,
            blockMerkleHash:blockMerkleHash,
            blockMerklePath:blockMerklePath,
            pendingScheduleHash:pendingScheduleHash,
            sigV:sigV,
            sigR:sigR,
            sigS:sigS,
            claimedKeyIndex:claimedKeyIndex,
            actionPath:actionPath,
            actionRecieptDigest:actionRecieptDigest
        });

        return doVerifyAction(actionData);
    }

    function storeNewSchedule(
        bytes memory blockHeaders,
        bytes32[] memory completingKeyParts
    )
        internal
        returns (bool)
    {
        uint32 version;
        uint8 amount;
        uint64[21] memory producerNames;
        bytes32[21] memory producerCompressedKeys;

        /* TODO: must get v part as well? */
        /* assuming first block is the new producers block, so no need to separate it */
        (version, amount, producerNames, producerCompressedKeys) = parseNonFixedFields(blockHeaders);

        require(amount == producerCompressedKeys.length);

        /* write new schedule to storage */
        numProducers = amount;
        scheduleVersion = version;
        for (uint idx = 0; idx < amount; idx++) {
            pubKeysFirstPartsPerSchedule[version][idx] = producerCompressedKeys[idx];
            pubKeysSecondPartsPerSchedule[version][idx] = completingKeyParts[idx];
        }

        return true;
    }

    function doVerifyAction(verifyActionData memory actionData) internal view returns (bool) {

        /* verify block sig */
        uint blockScheduleVersion = getScheduleVersionFromHeader(actionData.blockHeader);
        bool valid = doVerifyOneSig(
            actionData.blockHeader,
            actionData.blockMerkleHash,
            actionData.pendingScheduleHash,
            actionData.sigV,
            actionData.sigR,
            actionData.sigS,
            pubKeysFirstPartsPerSchedule[blockScheduleVersion][actionData.claimedKeyIndex],
            pubKeysSecondPartsPerSchedule[blockScheduleVersion][actionData.claimedKeyIndex]
        );
        if (!valid) return false;

        /* make sure the block is linked to an irreversible block */
        if (!isBlockIrreversible[actionData.irreversibleBlockToReference]) return false;
        valid = proofIsValid(
            getIdFromHeader(actionData.blockHeader),
            actionData.blockMerklePath,
            blockMroot[actionData.irreversibleBlockToReference]
        );
        if (!valid) return false;

        /* verify action path */
        valid = proofIsValid(
            actionData.actionRecieptDigest,
            actionData.actionPath,
            getActionMrootFromHeader(actionData.blockHeader)
        );
        if (!valid) return false;

        return true;
    }

    function verifyBlockIrreversible(HeadersData memory headersData) internal view returns (bool) {
        uint offset_in_headers = 0;
        uint pathOffset = 0;
        bytes32 currentId;
        bytes32 previousId = "";

        // TODO: make sure enough unique blocks were given.
        for (uint idx = 0; idx < headersData.blockHeaderSizes.length; idx++) {
            bytes memory header = getOneHeader(
                headersData.blockHeaders,
                offset_in_headers,
                headersData.blockHeaderSizes[idx]
            );
            offset_in_headers = offset_in_headers + headersData.blockHeaderSizes[idx];

            /* current we only allow to relay blocks from latest schedule */
            uint blockScheduleVersion = (uint)(getScheduleVersionFromHeader(header));
            if (scheduleVersion != blockScheduleVersion) return false;

            bool valid = verifyOneSig(
                header,
                headersData,
                idx,
                pubKeysFirstPartsPerSchedule[blockScheduleVersion][headersData.claimedKeyIndices[idx]],
                pubKeysSecondPartsPerSchedule[blockScheduleVersion][headersData.claimedKeyIndices[idx]]
            );
            if (!valid) return false;

            currentId = getIdFromHeader(header);
            uint pathSize = headersData.blockMerklePathSizes[idx];
            if (previousId != "") {
                bytes32[] memory path = getOnePath(headersData.blockMerklePaths, pathOffset, pathSize);

                valid = proofIsValid(previousId, path, headersData.blockMerkleHashs[idx]);
                if (!valid) return false;
            }
            pathOffset = pathOffset + pathSize;
            previousId = currentId;
        }

        return true;
    }

    function storeHeader(HeadersData memory headersData) internal returns (bool) {
        /* TODO: avoid current duplication as first header + id are already read when verifying */
        bytes memory header = getOneHeader(headersData.blockHeaders, 0, headersData.blockHeaderSizes[0]);
        uint blockNum = getBlockNumFromHeader(header);

        isBlockIrreversible[blockNum] = true;
        irreversibleBlockHeaders[blockNum] = header;
        blockMroot[blockNum] = headersData.blockMerkleHashs[0];
        if (blockNum > lastIrreversibleBlock) lastIrreversibleBlock = blockNum;

        return true;
    }

    function verifyOneSig(
        bytes memory blockHeader,
        HeadersData memory headersData,
        uint idx,
        bytes32 claimedSignerPubKeyFirst,
        bytes32 claimedSignerPubKeySecond
    )
        internal
        pure
        returns (bool) 
    {
        return doVerifyOneSig(
            blockHeader,
            headersData.blockMerkleHashs[idx],
            headersData.pendingScheduleHashs[idx],
            headersData.sigVs[idx],
            headersData.sigRs[idx],
            headersData.sigSs[idx],
            claimedSignerPubKeyFirst,
            claimedSignerPubKeySecond);
    }

    function doVerifyOneSig(
        bytes memory blockHeader,
        bytes32 blockMerkleHash,
        bytes32 pendingScheduleHash,
        uint8 sigV,
        bytes32 sigR,
        bytes32 sigS,
        bytes32 claimedSignerPubKeyFirst,
        bytes32 claimedSignerPubKeySecond
    )
        internal
        pure
        returns (bool) 
    {
        bytes32 pairHash = sha256(abi.encodePacked(sha256(blockHeader), blockMerkleHash));
        bytes32 finalHash = sha256(abi.encodePacked(pairHash, pendingScheduleHash));
        address calcAddress = ecrecover(finalHash, sigV, sigR, sigS);
        address claimedSignerAddress = address(
            (uint)(keccak256(abi.encodePacked(claimedSignerPubKeyFirst, claimedSignerPubKeySecond))) & (2**(8*21)-1)
        );

        return (calcAddress == claimedSignerAddress);
    }

    function getOneHeader(
        bytes memory blockHeaders,
        uint offset_in_headers,
        uint headerSize
    )
        internal
        pure
        returns (bytes memory)
    {
        bytes memory header = new bytes(headerSize);
        uint size = headerSize;
        uint offset_in_header = 0;
        uint current_size;
        uint x;

        while(size > 0) {
            if (size >= 32) {
                current_size = 32;
                assembly { x := mload(add(blockHeaders,
                                      add(current_size, add(offset_in_headers, offset_in_header)))) }
                assembly { mstore(add(header, add(32,offset_in_header)), x) }
            } else {
                current_size = size;
                for (uint i = 0; i < current_size; i++) {
                    header[offset_in_header + i] = blockHeaders[offset_in_headers + offset_in_header + i];
                }
           }
           offset_in_header = offset_in_header + current_size;
           size = size - current_size;
        }
        return header;
    }

    function getOnePath(
        bytes32[] memory blockMerklePaths,
        uint pathOffset,
        uint pathSize
    )
        internal
        pure
        returns (bytes32[] memory)
    {
        bytes32[] memory path = new bytes32[](pathSize);
        for( uint i = 0; i < pathSize; i++) {
            path[i] = blockMerklePaths[pathOffset + i];
        }
        return path;
    }
}
