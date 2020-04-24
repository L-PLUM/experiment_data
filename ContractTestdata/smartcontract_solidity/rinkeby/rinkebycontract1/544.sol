/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity ^0.4.24;

contract EIPv1 {

    bytes32 public domainHash;

    constructor(uint _chainId) public {
        assembly {
            let m := mload(0x40)
            // "EIP712Domain(string name, string version, uint256 chainId, address verifyingContract)"
            mstore(m, 0x8b73c3c69bb8fe3d512ecc4cf759cc79239f7b179b0ffacaa9a75d522b39400f)
            // name = "AZTEC_CRYPTOGRAPHY_ENGINE"
            mstore(add(m, 0x20), 0xc8066e2c715ce196630b273cd256d8959d5b9fefc55e9e6d999fb0f08bb7f75f)
            // version = "0.1.0"
            mstore(add(m, 0x40), 0xaa7cdbe2cce2ec7b606b0e199ddd9b264a6e645e767fb8479a7917dcd1b8693f)
            mstore(add(m, 0x60), _chainId) // chain id
            mstore(add(m, 0x80), address) // verifying contract
            sstore(domainHash_slot, keccak256(m, 0xa0)) // domain hash
        }
    }
}
