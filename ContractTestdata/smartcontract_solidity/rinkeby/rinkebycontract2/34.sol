/**
 *Submitted for verification at Etherscan.io on 2019-08-12
*/

pragma solidity ^0.5.2;

library MerkleUtils {
    function containedInTree(bytes32 merkleRoot, bytes memory data, bytes32[] memory nodes, uint256 index) public pure returns(bool) {
        bytes32 hashData = keccak256(data);
        for(uint i = 0; i < nodes.length; i++) {
            if(index % 2 == 1) {
                hashData = keccak256(abi.encodePacked(nodes[i], hashData));
            } else {
                hashData = keccak256(abi.encodePacked(hashData, nodes[i]));
            }
            index /= 2;
        }

        return hashData == merkleRoot;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * > Note: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



contract RootValidator is Ownable {

	bytes32 public limeRoot;

	function setRoot(bytes32 merkleRoot) public onlyOwner {
		limeRoot = merkleRoot;
	}

	function verifyDataInState(bytes memory data, bytes32[] memory nodes, uint leafIndex) view public returns(bool) {
		return MerkleUtils.containedInTree(limeRoot, data, nodes, leafIndex);
	}

    
}

contract MerkleAirDrop is RootValidator {

	mapping(address => uint256) public balanceOf;
	mapping(address => bool) public hasClaimed;

	function claim(uint256 price, bytes32[] memory nodes, uint leafIndex) public {
		require(!hasClaimed[msg.sender]);
		bytes memory data = abi.encodePacked(msg.sender, price);
		require(verifyDataInState(data, nodes, leafIndex), "Data not contained");

		hasClaimed[msg.sender] = true;
		balanceOf[msg.sender] += price;
	}

	function encodePacked(address sender, uint256 price) public view returns(bytes memory) {
		return abi.encodePacked(sender, price);
	}

	function hash(address sender, uint256 price) public view returns(bytes32) {
		return keccak256(abi.encodePacked(sender, price));
	}

}
