/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity ^0.5.4;

contract Test 
{
	
	function test4(uint var1, uint var2) public pure returns( bytes memory strabi, bytes32 hash)
	{
		strabi = abi.encodePacked( var1, var2 );
		hash = keccak256( strabi );
	}

	function test5(uint var1, uint var2) public pure returns(bytes memory strabi, bytes32 hash, bytes32 hash2)
	{
		strabi = abi.encodePacked( var1, var2 );
		hash = keccak256( strabi );
		
		bytes memory prefix = "\x19Ethereum Signed Message:\n32";
		hash2 = keccak256( abi.encodePacked(prefix,hash) );
	}
	
	function test6(address sender, uint256 tokenId, uint64 nonce, uint64 userId, bytes32 r, bytes32 s, uint8 v) public view returns(address signer)
	{
		bytes memory prefix = "\x19Ethereum Signed Message:\n32";
		
		bytes32 hash = keccak256( abi.encodePacked(address(this), sender, nonce, userId, tokenId) );
        signer = ecrecover(keccak256( abi.encodePacked(prefix,hash)), v, r, s);
	}

	
}
