/**
 *Submitted for verification at Etherscan.io on 2019-07-25
*/

pragma solidity ^0.5.3;
pragma experimental ABIEncoderV2;

contract Bytes32Array
{
    function getStringy() public pure returns (bytes32[] memory listOfValues)
    {
        bytes32[] memory array = new bytes32[](3);
        array[0] = stringToBytes32("string line one");
        array[1] = stringToBytes32("string line two");
        array[2] = stringToBytes32("string line three");
        return array;
    }
    
    /// @dev Pads shorter strings with 0, truncates longer strings to length 32
    function stringToBytes32(string memory source) private pure returns (bytes32 result) 
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) 
        {
            return 0x0;
        }

        assembly
        {
            result := mload(add(source, 32))
        }
    }
}
