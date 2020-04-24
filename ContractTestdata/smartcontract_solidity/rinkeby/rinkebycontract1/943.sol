/**
 *Submitted for verification at Etherscan.io on 2019-02-02
*/

pragma solidity 0.5.0;


/** @title String utility to expand strings' functionality. 
  * @author Juho Lehtonen
*/
library StringUtil2 {

    uint constant private ALLOCATION_FOR_STRING = 32;

    /** @dev Append string (in bytes) to byte buffer.
      * @param offset Tracks overall progress of buffer allocation.
      * @param input String in bytes that is appended to buffer.
      * @param buffer Byte buffer that contains strings.
      */
    function stringToBytes(uint offset, bytes memory input, bytes memory buffer)
    public
    pure
    {
        uint256 stackSize = input.length / ALLOCATION_FOR_STRING;
        if (input.length % ALLOCATION_FOR_STRING > 0) {
            stackSize++;
        }
        
        assembly
        {
            stackSize := add(stackSize, 1)
            for 
            {
                let index := 0
            } 
            lt(index, stackSize) {}
            {
                mstore(add(buffer, offset), mload(add(input, mul(index, 32))))
                offset := sub(offset, 32)
                index := add(index, 1)
            }
        }
    }
}
