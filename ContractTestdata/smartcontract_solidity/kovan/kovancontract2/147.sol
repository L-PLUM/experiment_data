/**
 *Submitted for verification at Etherscan.io on 2019-07-30
*/

pragma solidity >=0.4.21 <0.6.0;

library ECVerify {
  function ecrecovery(bytes32 hash, bytes memory sig) public pure returns (address) {
    bytes32 r;
    bytes32 s;
    uint8 v;

    if (sig.length != 65) {
      return address(0x0);
    }

    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := and(mload(add(sig, 65)), 255)
    }

    // https://github.com/ethereum/go-ethereum/issues/2053
    if (v < 27) {
      v += 27;
    }

    if (v != 27 && v != 28) {
      return address(0x0);
    }

    /* prefix might be needed for geth only
     * https://github.com/ethereum/go-ethereum/issues/3731
     */
    bytes memory prefix = "\x19Ethereum Signed Message:\n32";
    hash = keccak256(abi.encodePacked(prefix, hash));

    return ecrecover(hash, v, r, s);
  }

  function ecverify(bytes32 hash, bytes memory sig, address signer) public pure returns (bool) {
    return signer == ecrecovery(hash, sig);
  }
}
