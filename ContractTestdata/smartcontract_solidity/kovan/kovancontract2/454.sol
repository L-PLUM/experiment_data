/**
 *Submitted for verification at Etherscan.io on 2019-07-06
*/

/**
 * This smart contract code is Copyright 2019 TokenMarket Ltd. For more information see https://tokenmarket.net
 * Licensed under the Apache License, version 2.0: https://github.com/TokenMarketNet/ico/blob/master/LICENSE.txt
 * NatSpec is used intentionally to cover also other than public functions
 * Solidity 0.4.18 is intentionally used: it's stable, and our framework is
 * based on that.
 */



interface KYCInterface {
    event Whitelisted(address who, uint128 nonce);

    function isWhitelisted(address who) external view returns(bool);
}



/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


/**
 * @author TokenMarket /  Ville Sundell <ville at tokenmarket.net>
 */
contract BasicKYC is Ownable, KYCInterface {
    /** @dev This mapping contains address which have completed the KYC: */
    mapping (address => bool) public whitelist;
    /** @dev This mapping contains signature hashes which have been already used: */
    mapping (bytes32 => bool) public hashes;

    /** @dev this event is emitted when address is whitelisted, including the nonce:*/
    event Whitelisted(address who, bool status);

    /** @dev Simple contructor, mainly because of a Populus bug. */
    function BasicKYC() Ownable() {
      // This is here for our verification code only
    }

    /**
     * @dev Whitelist an address.
     * @param who Address being whitelisted
     * @param status True for whitelisting, False for de-whitelisting
     */
    function setWhitelisting(address who, bool status) internal {
        whitelist[who] = status;

        Whitelisted(who, status);
    }

    /**
     * @dev Whitelist an address.
     * @param who Address being whitelisted
     * @param status True for whitelisting, False for de-whitelisting
     */
    function whitelistUser(address who, bool status) external onlyOwner {
        setWhitelisting(who, status);
    }

    /**
     * @dev Whitelist an address. User can whitelist themselves by using a
     *      signed message from server side.
     * @param nonce Value to prevent re-use of the server side signed data
     * @param v V of the server's key which was used to sign this transfer
     * @param r R of the server's key which was used to sign this transfer
     * @param s S of the server's key which was used to sign this transfer
     */
    function whitelistMe(uint128 nonce, uint8 v, bytes32 r, bytes32 s) external {
        bytes32 hash = keccak256(msg.sender, nonce);
        require(hashes[hash] == false);
        require(ecrecover(hash, v, r, s) == owner);

        hashes[hash] = true;
        setWhitelisting(msg.sender, true);
    }

    /**
     * @dev Check the whitelisting status of an address.
     *      Although "whitelist" is a public mapping, we provide this "external"
     *      function to optimize gas usage.
     * @param who Address of the user whose whitelist status we want to check
     */
    function isWhitelisted(address who) external view returns(bool) {
        return whitelist[who];
    }
}
