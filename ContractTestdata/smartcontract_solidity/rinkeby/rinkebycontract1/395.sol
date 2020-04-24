/**
 *Submitted for verification at Etherscan.io on 2019-02-16
*/

pragma solidity ^0.5.4;

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Keybook is Ownable {

    mapping(address => bool) public addressIsAVerifier;

    struct User {
        string email;
        string name;
        string phoneNumber;
        string pgpKey;
        string twitter;
        string website;
        
        address[] emailVerifiedByAddresses;
    }

    event NewUnverifiedEmail(
        address userAddress,
        string email
    );

    mapping(address => User) public addressToUser;
    
    
    function getUserByAddress(address userAddress) private view returns (User memory) {
        return addressToUser[userAddress];
    }
    
    function getEmailForUser(address userAddress) public view returns (string memory){
        return getUserByAddress(userAddress).email;
    }
    function getNameForUser(address userAddress) public view returns (string memory){
        return getUserByAddress(userAddress).name;
    }
    function getPhoneForUser(address userAddress) public view returns (string memory){
        return getUserByAddress(userAddress).phoneNumber;
    }
    function getPgpKeyForUser(address userAddress) public view returns (string memory){
        return getUserByAddress(userAddress).pgpKey;
    }
    function getTwitterForUser(address userAddress) public view returns (string memory){
        return getUserByAddress(userAddress).twitter;
    }
    function getWebsiteForUser(address userAddress) public view returns (string memory){
        return getUserByAddress(userAddress).website;
    }
    

    function makeUser(  string memory email,
                        string memory name,
                        string memory phoneNumber,
                        string memory pgpKey,
                        string memory twitter,
                        string memory website) public{
        address[] memory dumArray;
        User memory newUser = User(email, name, phoneNumber, pgpKey, twitter, website, dumArray);
        addressToUser[msg.sender] = newUser;
        
        emit NewUnverifiedEmail(msg.sender, email);
    }
    
    function verifyEmail(address userAddress, uint8 v, bytes32 r, bytes32 s) public {
        User storage verifyingUser = addressToUser[userAddress];

        bytes32 dataToSign = keccak256(abi.encodePacked(userAddress, verifyingUser.email));
        
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked( prefix, dataToSign));
        address verifier = ecrecover(prefixedHash, v, r, s);
        
        require(addressIsAVerifier[verifier]);
        verifyingUser.emailVerifiedByAddresses.push(verifier);
    }
    
    function addVerifier(address newVerifier) public onlyOwner {
        addressIsAVerifier[newVerifier] = true;
    }
        
    function removeVerifier(address verifierToRemove) public onlyOwner {
        addressIsAVerifier[verifierToRemove] = false;
    }
    
}
