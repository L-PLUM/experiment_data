/**
 *Submitted for verification at Etherscan.io on 2019-01-30
*/

pragma solidity ^0.4.24;

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


contract ClaimTypesRegistry is Ownable{

    uint256[] claimTypes;

    event claimTypeAdded(uint256 indexed claimType);
    event claimTypeRemoved(uint256 indexed claimType);

    /**
    * @notice Add a trusted claim type (For example: KYC=1, AML=2).
    * Only owner can call.
    *
    * @param claimType The claim type index
    */
    function addClaimType(uint256 claimType) public onlyOwner{
        uint length = claimTypes.length;
        for(uint i = 0; i<length; i++){
            require(claimTypes[i]!=claimType, "claimType already exists");
        }
        claimTypes.push(claimType);
        emit claimTypeAdded(claimType);
    }
    /**
    * @notice Remove a trusted claim type (For example: KYC=1, AML=2).
    * Only owner can call.
    *
    * @param claimType The claim type index
    */

    function removeClaimType(uint256 claimType) public onlyOwner {
        uint length = claimTypes.length;
        for (uint i = 0; i<length; i++) {
            if(claimTypes[i] == claimType) {
                delete claimTypes[i];
                claimTypes[i] = claimTypes[length-1];
                delete claimTypes[length-1];
                claimTypes.length--;
                emit claimTypeRemoved(claimType);
                return;
            }
        }
    }
    /**
    * @notice Get the trusted claim types for the security token
    *
    * @return Array of trusted claim types
    */

    function getClaimTypes() public view returns (uint256[]) {
        return claimTypes;
    }
}
