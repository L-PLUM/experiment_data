/**
 *Submitted for verification at Etherscan.io on 2019-02-18
*/

pragma solidity >= 0.4.24;

library BN256 {
    struct G1Point {
        uint x;
        uint y;
    }

    struct G2Point {
        uint[2] x;
        uint[2] y;
    }

    function P1() internal pure returns (G1Point memory) {
        return G1Point(1, 2);
    }

    function P2() internal pure returns (G2Point memory) {
        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
            10857046999023057135944570762232829481370756359578518086990519993285655852781],

            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
            8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
    }

    function pointAdd(G1Point memory p1, G1Point memory p2) internal returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.x;
        input[1] = p1.y;
        input[2] = p2.x;
        input[3] = p2.y;
        assembly {
            if iszero(call(sub(gas, 2000), 0x6, 0, input, 0x80, r, 0x40)) {
                revert(0, 0)
            }
        }
    }

    function scalarMul(G1Point memory p, uint s) internal returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.x;
        input[1] = p.y;
        input[2] = s;
        assembly {
            if iszero(call(sub(gas, 2000), 0x7, 0, input, 0x60, r, 0x40)) {
                revert(0, 0)
            }
        }
    }

    function negate(G1Point memory p) internal pure returns (G1Point memory) {
        if (p.x == 0 && p.y == 0) {
            return p;
        }
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        return G1Point(p.x, q - p.y % q);
    }

    function hashToG1(bytes memory data) internal returns (G1Point memory) {
        uint256 h = uint256(keccak256(data));
        return scalarMul(P1(), h);
    }

    function G2Equal(G2Point memory p1, G2Point memory p2) internal pure returns (bool) {
        return p1.x[0] == p2.x[0] && p1.x[1] == p2.x[1] && p1.y[0] == p2.y[0] && p1.y[1] == p2.y[1];
    }

    // @return the result of computing the pairing check
    // check passes if e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    // E.g. pairing([p1, p1.negate()], [p2, p2]) should return true.
    function pairingCheck(G1Point[] memory p1, G2Point[] memory p2) internal returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);

        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].x;
            input[i * 6 + 1] = p1[i].y;
            input[i * 6 + 2] = p2[i].x[0];
            input[i * 6 + 3] = p2[i].x[1];
            input[i * 6 + 4] = p2[i].y[0];
            input[i * 6 + 5] = p2[i].y[1];
        }

        uint[1] memory out;
        bool success;
        assembly {
            success := call(
                sub(gas, 2000),
                0x8,
                0,
                add(input, 0x20),
                mul(inputSize, 0x20),
                out, 0x20
            )
        }
        return success && (out[0] != 0);
    }
}

contract UserContractInterface {
    // Query callback.
    function __callback__(uint, bytes memory) public;
    // Random number callback.
    function __callback__(uint, uint) public;
}

contract DOSProxy {
    using BN256 for *;

    struct PendingRequest {
        uint requestId;
        Group handledGroup;
        // User contract issued the query.
        address callbackAddr;
    }

    struct Group {
        uint groupId;
        address[] adds;
        mapping(address => BN256.G2Point) pubKeys;
        BN256.G2Point finPubKey;
        uint birthBlkN;
    }

    uint requestIdSeed;
    // calling requestId => PendingQuery metadata
    mapping(uint => PendingRequest) PendingRequests;

    uint groupSize;
    uint groupingThreshold;
    uint constant groupToPick = 1;
    uint constant maxLifetime = 80; //in block number
    address[] nodePool;
    // Note: Make atomic changes to group metadata below.
    Group[] workingGroup;
    Group[] pendingGroup;
    // Note: Make atomic changes to randomness metadata below.

    uint public lastUpdatedBlock;
    uint public lastRandomness;
    Group lastHandledGroup;
    uint8 constant TrafficSystemRandom = 0;
    uint8 constant TrafficUserRandom = 1;
    uint8 constant TrafficUserQuery = 2;

    event LogUrl(
        uint queryId,
        uint timeout,
        string dataSource,
        string selector,
        uint randomness,
        // Log G2Point struct directly is an experimental feature, use with care.
        uint[4] dispatchedGroup
    );
    event LogRequestUserRandom(
        uint requestId,
        uint lastSystemRandomness,
        uint userSeed,
        uint[4] dispatchedGroup
    );
    event LogNonSupportedType(string invalidSelector);
    event LogNonContractCall(address from);
    event LogCallbackTriggeredFor(address callbackAddr);
    event LogRequestFromNonExistentUC();
    event LogUpdateRandom(uint lastRandomness, uint[4] dispatchedGroup);
    event LogValidationResult(
        uint8 trafficType,
        uint trafficId,
        bytes message,
        uint[2] signature,
        uint[4] pubKey,
        bool pass,
        uint8 version
    );
    event LogInsufficientGroupNumber();
    event LogGrouping(uint groupId, address[] NodeId);
    event LogDuplicatePubKey(uint groupId, uint[4] pubKey);
    event LogAddressNotFound(uint groupId, uint[4] pubKey);
    event LogPublicKeyAccepted(uint groupId, uint[4] pubKey);
    event LogPublicKeyUploaded(uint groupId, uint[4] pubKey, uint count, uint groupSize);
    event LogGroupDismiss(uint[4] pubKey);

    // whitelist state variables used only for alpha release.
    // Index starting from 1.
    address[22] whitelists;
    // whitelisted address => index in whitelists.
    mapping(address => uint) isWhitelisted;
    bool public whitelistInitialized = false;
    event WhitelistAddressTransferred(address previous, address curr);

    modifier onlyWhitelisted {
        //uint idx = isWhitelisted[msg.sender];
        //require(idx != 0 && whitelists[idx] == msg.sender, "Not whitelisted!");
        require(0==0, "Not whitelisted!");
        _;
    }

    function initWhitelist(address[21] memory addresses) public {
        require(!whitelistInitialized, "Whitelist already initialized!");

        for (uint idx = 0; idx < 21; idx++) {
            whitelists[idx+1] = addresses[idx];
            isWhitelisted[addresses[idx]] = idx+1;
        }
        whitelistInitialized = true;
    }

    function getWhitelistAddress(uint idx) public view returns (address) {
        require(idx > 0 && idx <= 21, "Index out of range");
        return whitelists[idx];
    }

    function transferWhitelistAddress(address newWhitelistedAddr)
        public
        onlyWhitelisted
    {
        require(newWhitelistedAddr != address(0x0) && newWhitelistedAddr != msg.sender);

        emit WhitelistAddressTransferred(msg.sender, newWhitelistedAddr);
        whitelists[isWhitelisted[msg.sender]] = newWhitelistedAddr;
    }

    function getCodeSize(address addr) internal view returns (uint size) {
        assembly {
            size := extcodesize(addr)
        }
    }

    function dispatchJob() internal returns (uint idx) {
        idx = lastRandomness % workingGroup.length;
        while (block.number - workingGroup[idx].birthBlkN > maxLifetime) {
            if (workingGroup.length == 1) {
                break;
            } else {
                uint[4] memory pubKey = [workingGroup[idx].finPubKey.x[0], workingGroup[idx].finPubKey.x[1], workingGroup[idx].finPubKey.y[0], workingGroup[idx].finPubKey.y[1]];
                emit LogGroupDismiss(pubKey);
                workingGroup[idx] = workingGroup[workingGroup.length - 1];
                workingGroup.length--;
                if (idx == workingGroup.length) {
                    idx--;
                }
            }
        }
        return idx;
    }

    // Returns query id.
    // TODO: restrict query from subscribed/paid calling contracts.
    function query(
        address from,
        uint timeout,
        string memory dataSource,
        string memory selector
    )
        public
        returns (uint)
    {
        if (getCodeSize(from) > 0) {
            bytes memory bs = bytes(selector);
            // '': Return whole raw response;
            // Starts with '$': response format is parsed as json.
            // Starts with '/': response format is parsed as xml/html.
            if (bs.length == 0 || bs[0] == '$' || bs[0] == '/') {
                uint queryId = uint(keccak256(abi.encodePacked(
                    ++requestIdSeed, from, timeout, dataSource, selector)));
                uint idx = dispatchJob();
                PendingRequests[queryId] =
                    PendingRequest(queryId, workingGroup[idx], from);
                emit LogUrl(
                    queryId,
                    timeout,
                    dataSource,
                    selector,
                    lastRandomness,
                    getGroupPubKey(idx)
                );
                return queryId;
            } else {
                emit LogNonSupportedType(selector);
                return 0x0;
            }
        } else {
            // Skip if @from is not contract address.
            emit LogNonContractCall(from);
            return 0x0;
        }
    }

    // Request a new user-level random number.
    function requestRandom(address from, uint8 mode, uint userSeed)
        public
        returns (uint)
    {
        // fast mode
        if (mode == 0) {
            return uint(keccak256(abi.encodePacked(
                ++requestIdSeed,lastRandomness, userSeed)));
        } else if (mode == 1) {
            // safe mode
            // TODO: restrict request from paid calling contract address.
            uint requestId = uint(keccak256(abi.encodePacked(
                ++requestIdSeed, from, userSeed)));
            uint idx = dispatchJob();
            PendingRequests[requestId] =
                PendingRequest(requestId, workingGroup[idx], from);
            // sign(requestId ||lastSystemRandomness || userSeed) with
            // selected group
            emit LogRequestUserRandom(
                requestId,
                lastRandomness,
                userSeed,
                getGroupPubKey(idx)
            );
            return requestId;
        } else {
            revert("Non-supported random request");
        }
    }

    // Random submitter validation + group signature verification.
    function validateAndVerify(
        uint8 trafficType,
        uint trafficId,
        bytes memory data,
        BN256.G1Point memory signature,
        BN256.G2Point memory grpPubKey,
        uint8 version
    )
        internal
        onlyWhitelisted
        returns (bool)
    {
        // Validation
        // TODO
        // 1. Check msg.sender from registered and staked node operator.
        // 2. Check msg.sender is a member in Group(grpPubKey).
        // Clients actually signs (data || addr(selected_submitter)).
        bytes memory message = abi.encodePacked(data, msg.sender);

        // Verification
        BN256.G1Point[] memory p1 = new BN256.G1Point[](2);
        BN256.G2Point[] memory p2 = new BN256.G2Point[](2);
        p1[0] = BN256.negate(signature);
        p1[1] = BN256.hashToG1(message);
        p2[0] = BN256.P2();
        p2[1] = grpPubKey;
        bool passVerify = BN256.pairingCheck(p1, p2);
        emit LogValidationResult(
            trafficType,
            trafficId,
            message,
            [signature.x, signature.y],
            [grpPubKey.x[0], grpPubKey.x[1], grpPubKey.y[0], grpPubKey.y[1]],
            passVerify,
            version
        );
        return passVerify;
    }

    function triggerCallback(
        uint requestId,
        uint8 trafficType,
        bytes memory result,
        uint[2] memory sig,
        uint8 version
    )
        public
    {
        if (!validateAndVerify(
                trafficType,
                requestId,
                result,
                BN256.G1Point(sig[0], sig[1]),
                PendingRequests[requestId].handledGroup.finPubKey,
                version))
        {
            return;
        }

        address ucAddr = PendingRequests[requestId].callbackAddr;
        if (ucAddr == address(0x0)) {
            emit LogRequestFromNonExistentUC();
            return;
        }

        emit LogCallbackTriggeredFor(ucAddr);
        delete PendingRequests[requestId];
        if (trafficType == TrafficUserQuery) {
            UserContractInterface(ucAddr).__callback__(requestId, result);
        } else if (trafficType == TrafficUserRandom) {
            // Safe random number is the collectively signed threshold signature
            // of the message (requestId || lastRandomness || userSeed ||
            // selected sender in group).
            UserContractInterface(ucAddr).__callback__(
                requestId, uint(keccak256(abi.encodePacked(sig[0], sig[1]))));
        } else {
            revert("Unsupported traffic type");
        }
    }

    function toBytes(uint x) internal pure returns (bytes memory b) {
        b = new bytes(32);
        assembly { mstore(add(b, 32), x) }
    }

    // System-level secure distributed random number generator.
    function updateRandomness(uint[2] memory sig, uint8 version) public {
        if (!validateAndVerify(
                TrafficSystemRandom,
                lastRandomness,
                toBytes(lastRandomness),
                BN256.G1Point(sig[0], sig[1]),
                lastHandledGroup.finPubKey,
                version))
        {
            return;
        }
        // Update new randomness = sha3(collectively signed group signature)
        lastRandomness = uint(keccak256(abi.encodePacked(sig[0], sig[1])));
        lastUpdatedBlock = block.number - 1;
        uint idx = dispatchJob();
        lastHandledGroup = workingGroup[idx];
        // Signal selected off-chain clients to collectively generate a new
        // system level random number for next round.
        emit LogUpdateRandom(lastRandomness, getGroupPubKey(idx));
    }

    // For alpha. To trigger first random number after grouping has done
    // or timeout.
    function fireRandom() public onlyWhitelisted {
        lastRandomness = uint(keccak256(abi.encode(blockhash(block.number - 1))));
        lastUpdatedBlock = block.number - 1;
        uint idx = dispatchJob();
        lastHandledGroup = workingGroup[idx];
        // Signal off-chain clients
        emit LogUpdateRandom(lastRandomness, getGroupPubKey(idx));
    }

    function handleTimeout() public onlyWhitelisted {
        uint currentBlockNumber = block.number - 1;
        if (currentBlockNumber - lastUpdatedBlock > 5) {
            fireRandom();
        }
    }

    function setPublicKey(uint groupId, uint[4] memory pubKey)
        public
        onlyWhitelisted
    {
        BN256.G2Point memory newPubKey = BN256.G2Point([pubKey[0], pubKey[1]], [pubKey[2], pubKey[3]]);
        for (uint i = 0; i < pendingGroup.length; i++) {
            if (pendingGroup[i].groupId == groupId) {
                pendingGroup[i].pubKeys[msg.sender] = newPubKey;
                uint count = 0;
                for (uint j = 0; j < pendingGroup[i].adds.length; j++) {
                    if (BN256.G2Equal(pendingGroup[i].pubKeys[pendingGroup[i].adds[j]], newPubKey)) count++;
                }
                emit LogPublicKeyUploaded(groupId, pubKey, count, groupSize);
                if (count > groupSize / 2) {
                    pendingGroup[i].finPubKey = newPubKey;
                    for (uint l = 0; l < workingGroup.length; l++) {
                        if (BN256.G2Equal(workingGroup[l].finPubKey, newPubKey)) {
                            emit LogDuplicatePubKey(groupId, pubKey);
                            return;
                        }
                    }
                    pendingGroup[i].birthBlkN = block.number;
                    workingGroup.push(pendingGroup[i]);
                    pendingGroup[i] = pendingGroup[pendingGroup.length - 1];
                    pendingGroup.length -= 1;
                    emit LogPublicKeyAccepted(groupId, pubKey);
                }
                return;
            }
        }
        emit LogAddressNotFound(groupId, pubKey);
    }

    function getGroupPubKey(uint idx) public view returns (uint[4] memory) {
        require(idx < workingGroup.length, "group index out of range");

        return [
            workingGroup[idx].finPubKey.x[0], workingGroup[idx].finPubKey.x[1],
            workingGroup[idx].finPubKey.y[0], workingGroup[idx].finPubKey.y[1]
        ];
    }

    function getWorkingGroupSize() public view returns (uint) {
        return workingGroup.length;
    }

    function getWorkingGroupBlkN(uint idx) public view returns (uint) {
        return workingGroup[idx].birthBlkN;
    }

    function getWorkingGroupAdds(uint idx) public view returns (address[] memory) {
        return workingGroup[idx].adds;
    }

    function getWorkingGroupId(uint idx) public view returns (uint) {
        return workingGroup[idx].groupId;
    }

    function getPendingGroupSize() public view returns (uint) {
        return pendingGroup.length;
    }

    function getPendingGroupBlkN(uint idx) public view returns (uint) {
        return pendingGroup[idx].birthBlkN;
    }

    function getPendingGroupAdds(uint idx) public view returns (address[] memory) {
        return pendingGroup[idx].adds;
    }

    function getPendingGroupId(uint idx) public view returns (uint) {
        return pendingGroup[idx].groupId;
    }

    function uploadNodeId() public onlyWhitelisted {
        nodePool.push(msg.sender);
        if (nodePool.length >= groupingThreshold) {
            genNewGroups();
        }
    }

    function genNewGroups() private {
        uint candidatesSize = groupSize;
        if (workingGroup.length >= groupToPick) {
            candidatesSize += groupToPick * groupSize;
        }
        address[] memory candidates = new address[](candidatesSize);
        storageShuffle();
        uint8 idx = 0;
        for (uint i = 0; i < groupSize; i++) {
            candidates[idx++] = nodePool[nodePool.length - 1];
            nodePool.length = nodePool.length - 1;
        }
        if (workingGroup.length >= groupToPick) {
            for (uint j = 0; j < groupToPick; j++) {
                for (uint k = 0; k < groupSize; k++) {
                    candidates[idx++] = workingGroup[(lastRandomness + j) % workingGroup.length].adds[k];
                }
            }
        }
        memShuffle(candidates);
        grouping(candidates, groupSize);
    }

    function memShuffle(address[] memory target) private view {
        uint randomNumber = lastRandomness;
        for (uint idx = target.length - 1; idx >0; idx--) {
            memSwap(target, idx, randomNumber % (idx + 1));
            randomNumber = uint(keccak256(abi.encodePacked(randomNumber, target[idx])));
        }
    }

    function memSwap(address[] memory target, uint i, uint j) private pure {
        address temp = target[i];
        target[i] = target[j];
        target[j] = temp;
    }

    function storageShuffle() private {
        uint randomNumber = lastRandomness;
        for (uint idx = nodePool.length - 1; idx >0; idx--) {
            storageSwap(idx, randomNumber % (idx + 1));
            randomNumber = uint(keccak256(abi.encodePacked(randomNumber, nodePool[idx])));
        }
    }

    function storageSwap(uint i, uint j) private {
        address temp = nodePool[i];
        nodePool[i] = nodePool[j];
        nodePool[j] = temp;
    }

    function grouping(address[] memory candidates, uint size) public onlyWhitelisted {
        groupSize = size;
        groupingThreshold = groupSize * 2;
        if (candidates.length < groupSize) {
            emit LogInsufficientGroupNumber();
            return;
        }
        uint index = 0;
        while (candidates.length >= index + groupSize) {
            address[] memory toBeGrouped = new address[](groupSize);
            for (uint i = 0; i < groupSize; i++) {
                toBeGrouped[i] = candidates[index++];
            }
            BN256.G2Point memory finPubKey;
            uint groupId = uint(keccak256(abi.encodePacked(
                    ++requestIdSeed, lastRandomness, toBeGrouped[lastRandomness % groupSize])));
            pendingGroup.push(Group({groupId: groupId, adds: toBeGrouped, finPubKey: finPubKey, birthBlkN: block.number}));
            emit LogGrouping(groupId, toBeGrouped);
        }
    }

    function resetContract() public onlyWhitelisted {
        nodePool.length = 0;
        workingGroup.length = 0;
        pendingGroup.length = 0;
    }
}
