/**
 *Submitted for verification at Etherscan.io on 2019-07-25
*/

pragma solidity ^0.5.3;
pragma experimental ABIEncoderV2;

contract StringArray
{
    function getStringy() public pure returns (string[] memory strings)
    {
        string[] memory stringArray = new string[](3);
        stringArray[0] = "string line one";
        stringArray[1] = "string line two";
        stringArray[2] = "string line three";
        return stringArray;
    }
}
