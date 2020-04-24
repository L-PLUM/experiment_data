/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity ^0.5.0;

// File: /mnt/dev/capacity/kompany-timestamp/truffle/contracts/MerkleProofSha256.sol

/**
 * @title MerkleProofSha256
 * @dev Merkle proof verification using SHA256 hash function, adapted from
 * openzeppelin/cryptography/MerkleProof.sol based on
 * https://github.com/ameensol/merkle-tree-solidity/blob/master/src/MerkleProof.sol
 */
library MerkleProofSha256 {
    /**
     * @dev Verifies a Merkle proof proving the existence of a leaf in a Merkle tree. Assumes that each pair of leaves
     * and each pair of pre-images are sorted.
     * @param proof Merkle proof containing sibling hashes on the branch from the leaf to the root of the Merkle tree
     * @param root Merkle root
     * @param leaf Leaf of Merkle tree
     */
    function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {
        bytes32 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];

            if (computedHash < proofElement) {
                // Hash(current computed hash + current element of the proof)
                computedHash = sha256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = sha256(abi.encodePacked(proofElement, computedHash));
            }
        }

        // Check if the computed hash (root) is equal to the provided root
        return computedHash == root;
    }
}

// File: contracts/Timestamp.sol

contract Timestamp {

    mapping(bytes32 => uint) public hashTimestamps;

    event HashRecorded(bytes32 rootHash, uint timestamp);


    function submitRootHash(bytes32 rootHash) public {
        require(hashTimestamps[rootHash] == 0, "Hash has been submitted before.");
        hashTimestamps[rootHash] = now;
        emit HashRecorded(rootHash, hashTimestamps[rootHash]);
    }


    function verifyHistory(bytes32 rootHash, bytes32[] memory merkleProof, bytes32 leafHash)
    view public returns (uint timestamp) {

        require(hashTimestamps[rootHash] > 0, "Hash was not submitted yet.");

        require(MerkleProofSha256.verify(merkleProof, rootHash, leafHash), "Verification failed.");
        return hashTimestamps[rootHash];
    }

}
