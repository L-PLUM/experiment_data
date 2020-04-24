/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity ^0.4.24;

contract Token {
    function delegateTransfer(address _from, address _to, uint256 _value) external returns (bool);
    function delegateApprove(address _from, address _to, uint256 _value) external returns (bool);
}

contract Delegator {
    event Execution(bytes32 hash);
    event ExecutionFailure(bytes32 hash);


    mapping (bytes32 => bool) executed;

    function execute(
        address _sender,
        address _destination,
        bytes _data,
        uint256 _nonce,
        bytes _signature ) external returns (bool)
        {
        require (verifyAddr(_sender, _data));
        bytes32 hash = keccak256(abi.encodePacked(this, _destination, _nonce, _data));
        require (!executed[hash]);
        require (_sender == ecverify(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), _signature));
        executed[hash] = true;
        if (_destination.call.value(0)(_data)) {
            emit Execution(hash);
            return true;
        } else {
            emit ExecutionFailure(hash);
            return false;
        }
    }

    function verifyAddr(address _signer, bytes _data) internal pure returns (bool) {
        address addr;
        assembly {
            addr := mload(add(_data,36))
        }
        return _signer==addr;
    }

    function ecverify(bytes32 hash, bytes signature) internal pure returns (address signature_address) {
        require(signature.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        // The signature format is a compact form of:
        //   {bytes32 r}{bytes32 s}{uint8 v}
        // Compact means, uint8 is not padded to 32 bytes.
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))

            // Here we are loading the last 32 bytes, including 31 bytes of 's'.
            v := byte(0, mload(add(signature, 96)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible
        if (v < 27) {
            v += 27;
        }

        require(v == 27 || v == 28);

        signature_address = ecrecover(hash, v, r, s);

        // ecrecover returns zero on error
        require(signature_address != 0x0);

        return signature_address;
    }
}
