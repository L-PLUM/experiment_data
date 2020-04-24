/**
 *Submitted for verification at Etherscan.io on 2018-12-20
*/

pragma solidity ^0.5.0;

contract BimchainCaen {
    struct Signature {
        address signatory;
        uint8 docId;
        uint8 workflowStep;
        uint8 score; 
        uint256 ethblockNumber;
        bytes32 mainPhysicalHash;
        bytes32 mainBusinessHash;
        bytes32 linkedPhysicalHash;
        bytes32 linkedBusinessHash;
        bool exists;
    }
    event SignatureError(uint8 code);
    event SignatureEvent(
        address signatory,
        uint8 docId,
        uint8 workflowStep,
        uint8 score,
        uint256 ethblockNumber,
        bytes32 mainPhysicalHash,
        bytes32 mainBusinessHash,
        bytes32 linkedPhysicalHash,
        bytes32 linkedBusinessHash
    );
    
    mapping(uint48 => Signature) private signatureIndex;
    mapping(bytes32 => uint48[]) private signaturesByHash;

    // Returns the details of a signature for a given hash, at a given index
    function getSignature(bytes32 docHash, uint index) public view returns (
        bytes32,bytes32,bytes32,bytes32,address, uint8, uint8, uint8, uint256){
        if ( index < 0 || countSignatures(docHash) <= index ){
            return (0, 0, 0, 0, 0x0000000000000000000000000000000000000000, 0, 0, 0, 0);
        }
        uint48 signatureId = signaturesByHash[docHash][index];
        Signature memory s = signatureIndex[signatureId];
        return (
            s.mainPhysicalHash,
            s.mainBusinessHash,
            s.linkedPhysicalHash,
            s.linkedBusinessHash,
            s.signatory,
            s.docId,
            s.workflowStep,
            s.score,
            s.ethblockNumber
        );
    }

    // Returns the number of signature for a given document Hash
    function countSignatures(bytes32 docHash) public view returns (uint){
        return signaturesByHash[docHash].length;
    }

    // True if at least one signature exists for a given hash
    function checkSignature(bytes32 docHash) public view returns (bool) {
        return countSignatures(docHash) > 0;
    }

    // Add a signature in the contract using the delegation Library
    function addSignature(
        bytes32 mainPhysicalHash, bytes32 mainBusinessHash, bytes32 linkedPhysicalHash, bytes32 linkedBusinessHash, 
        address signatory, uint8 docId, uint8 step, uint8 score, uint48 nonce,
        bytes32 r, bytes32 s, uint8 v) public {

        Signature memory sig = buildSignature(
            mainPhysicalHash, mainBusinessHash, linkedPhysicalHash, linkedBusinessHash,
            signatory, docId, step, score);

        // Check everything
        if ( !performChecks(sig, nonce, r, s, v)) return; 

        // Every check passed : register the signature
        indexSignature(sig, nonce);
    }

    function performChecks(Signature memory sig, uint48 nonce, bytes32 r, bytes32 s, uint8 v ) private returns ( bool ){
        return checkNonce(nonce) && checkDelegation(sig, nonce, r, s, v);
    }

    function checkNonce(uint48 nonce) private returns ( bool ) {
        if ( signatureIndex[nonce].exists ){
            emit SignatureError(0);
            return false;
        }
        return true;
    }

    function checkDelegation(Signature memory sig, uint48 nonce, bytes32 r, bytes32 s, uint8 v) private returns ( bool ) {
        bytes memory packed = abi.encodePacked(
            sig.mainPhysicalHash,sig.mainBusinessHash,
            sig.linkedPhysicalHash,sig.linkedBusinessHash, 
            sig.signatory, sig.docId, sig.workflowStep, sig.score, nonce);
        bytes32 message = prefixed(keccak256(packed));
        if ( ecrecover(message, v, r, s) != sig.signatory ) {
            emit SignatureError(1);
            return false;
        } 
        return true;
    }

    function buildSignature(
        bytes32 mainPhysicalHash, 
        bytes32 mainBusinessHash, 
        bytes32 linkedPhysicalHash, 
        bytes32 linkedBusinessHash, 
        address signatory,
        uint8 docId,  
        uint8 step,
        uint8 score
    ) private view returns ( Signature memory ) {
        return Signature(
            signatory,docId,step, score, block.number, mainPhysicalHash, 
            mainBusinessHash, linkedPhysicalHash, linkedBusinessHash, true);
    }

    function indexSignature(Signature memory signature, uint48 nonce) private {
        signatureIndex[nonce] = signature;
        if ( signature.mainPhysicalHash != "" && signature.mainPhysicalHash != 0x0){
            signaturesByHash[signature.mainPhysicalHash].push(nonce);
        }
        if ( signature.mainBusinessHash != "" && signature.mainBusinessHash != 0x0){
            signaturesByHash[signature.mainBusinessHash].push(nonce);
        }
        if ( signature.linkedPhysicalHash != "" && signature.linkedPhysicalHash != 0x0){
            signaturesByHash[signature.linkedPhysicalHash].push(nonce);
        }
        if ( signature.linkedBusinessHash != "" && signature.linkedBusinessHash != 0x0){
            signaturesByHash[signature.linkedBusinessHash].push(nonce);
        }
         // Emit signature event
        emit SignatureEvent(
            signature.signatory,signature.docId,signature.workflowStep, signature.score, signature.ethblockNumber, signature.mainPhysicalHash, 
            signature.mainBusinessHash, signature.linkedPhysicalHash, signature.linkedBusinessHash);
    }

    function prefixed(bytes32 hash) private pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",hash));
    }
}
