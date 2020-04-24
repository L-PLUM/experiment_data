/**
 *Submitted for verification at Etherscan.io on 2019-02-16
*/

pragma solidity ^0.5.4;

contract ClaimHolder {
    function getClaim(bytes32 _claimId)
        public
        view
        returns(
            uint256 claimType,
            uint256 scheme,
            address issuer,
            bytes memory signature,
            bytes memory data,
            string memory uri
        )
    {

    }
}

contract Identity {
    function getData(bytes32 _key) external view returns (bytes32 _value) {
    }
}

contract ClaimVerifier {

    //For this hackathon, verifier address and issuer address is constant for the demo
    address verifier = 0x61a12c10676E7Ef993D21e3B1DA9A137406b9689;
    address issuer = 0x72439bbA904bf5d4CE83e90a7e7466A74c3cEdab;

    function verify(Identity _identity, bytes memory hash, uint256 claimType)
        public
        view
        returns (bool)
    {
        bytes memory data;
        bytes memory sig;
        bytes32 claimId = keccak256(abi.encodePacked(issuer, claimType));
        bytes32 val =  _identity.getData(0xb0f23aea7d77ce19f9393243a7b50a3bcaac893c7d68a5a309dea7cacf035fd0);
        address _claimholder = toAddress(val);
        (, , , sig, data, ) = ClaimHolder(_claimholder).getClaim(claimId);

        bytes32 dataHash = keccak256(abi.encodePacked(_identity, claimType, data));
        bytes32 prefixedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", dataHash));

        address recovered = getRecoveredAddress(sig, prefixedHash);
        if (keccak256(abi.encodePacked(hash)) == keccak256(abi.encodePacked(data)) && recovered == verifier){
            return true;
        } else {
            return false;
        }
    }

    function toAddress(bytes32 a) internal pure returns (address b){
       assembly {
            mstore(0, a)
            b := mload(0)
        }
       return b;
    }


    function getRecoveredAddress(bytes memory sig, bytes32 dataHash)
        public
        pure
        returns (address addr)
    {
        bytes32 ra;
        bytes32 sa;
        uint8 va;

        // Check the signature length
        if (sig.length != 65) {
            return (address(0x0));
        }

        // Divide the signature in r, s and v variables
        assembly {
            ra := mload(add(sig, 32))
            sa := mload(add(sig, 64))
            va := byte(0, mload(add(sig, 96)))
        }

        if (va < 27) {
            va += 27;
        }

        address recoveredAddress = ecrecover(dataHash, va, ra, sa);

        return (recoveredAddress);
    }

}
