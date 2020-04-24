/**
 *Submitted for verification at Etherscan.io on 2018-12-11
*/

pragma solidity 0.5.0; 

//
// base contract for all our horizon contracts and tokens
//
contract HorizonContractBase {
    // The owner of the contract, set at contract creation to the creator.
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    // Contract authorization - only allow the owner to perform certain actions.
    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }
}

/**
 * KYCAML Contract
 * Author: Horizon Globex GmbH Development Team
 *
 */
contract KYCAML is HorizonContractBase {

    // Contract authorization - only allow the official KYC provider to perform certain actions.
    modifier onlyKycProvider {
        require(msg.sender == regulatorApprovedKycProvider, "Only the KYC Provider can call this function.");
        _;
    }

    // The approved KYC provider that verifies all ICO/TGE Contributors.
    address public regulatorApprovedKycProvider;

    // KYC submission hashes accepted by KYC service provider for AML/KYC review.
    bytes32[] public kycHashes;

    // All submission hashes that have passed the external KYC verification checks.
    bytes32[] public kycValidated;

    constructor() public {
    }

    /**
     * The hash for all Know Your Customer information is calculated outside but stored here.
     * @param sha   The hash of the customer data.
    */
    function setKycHash(bytes32 sha) public onlyOwner {
        kycHashes.push(sha);
    }

    /**
     * A user has passed KYC verification, store their document hash on the blockchain in the order it happened.
     * @param sha   The user's hash of their submitted document
     */
    function kycApproved(bytes32 sha) public onlyKycProvider {
        kycValidated.push(sha);
    }

    /**
     * Set the address that has the authority to approve users' submissions by KYC.
     * @param who   The address of the KYC provider.
     */
    function setKycProvider(address who) public onlyOwner {
        regulatorApprovedKycProvider = who;
    }

    /**
     * Retrieve the KYC hash from the specified index.
     * @param   index   The index into the array.
     */
    function getKycHash(uint256 index) public view returns (bytes32) {
        return kycHashes[index];
    }

    /**
     * Retrieve the validated KYC hash from the specified index.
     * @param   index   The index into the array.
     */
    function getKycApproved(uint256 index) public view returns (bytes32) {
        return kycValidated[index];
    }
}
