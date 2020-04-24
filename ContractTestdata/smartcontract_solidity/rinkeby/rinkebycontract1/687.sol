/**
 *Submitted for verification at Etherscan.io on 2019-02-09
*/

pragma solidity ^0.4.11;

contract AbstractENS {
    function owner(bytes32 node) constant returns(address);
    function resolver(bytes32 node) constant returns(address);
    function ttl(bytes32 node) constant returns(uint64);
    function setOwner(bytes32 node, address owner);
    function setSubnodeOwner(bytes32 node, bytes32 label, address owner);
    function setResolver(bytes32 node, address resolver);
    function setTTL(bytes32 node, uint64 ttl);
   }
   
/**
 * A registrar that allocates subdomains to the first person to claim them.
 */
contract FIFSRegistrar {
    AbstractENS public ens;
    bytes32 public rootNode;
    uint64 public onlyOwner;
    address public theCurrentOwner;

    modifier only_owner(bytes32 subnode) {
        var node = sha3(rootNode, subnode);
        var currentOwner = ens.owner(node);
        theCurrentOwner = currentOwner;
        onlyOwner = 2;
        if(currentOwner != 0 && currentOwner != msg.sender)
            throw;
        _;
        onlyOwner = 1;
    }

    /**
     * Constructor.
     * @param ensAddr The address of the ENS registry.
     * @param node The node that this registrar administers.
     */
    function FIFSRegistrar(AbstractENS ensAddr, bytes32 node) {
        ens = ensAddr;
        rootNode = node;
        onlyOwner = 0;
    }

    /**
     * Register a name, or change the owner of an existing registration.
     * @param subnode The hash of the label to register.
     * @param owner The address of the new owner.
     */
    function register(bytes32 subnode, address owner) only_owner(subnode) {
        ens.setSubnodeOwner(rootNode, subnode, owner);
    }
}
