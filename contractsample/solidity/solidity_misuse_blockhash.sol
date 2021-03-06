pragma solidity 0.4.24;

contract BlockHash{

    function getBlockHash(uint64 blockNumber) constant returns (bytes32 blockHash){
        // <yes> <report> solidity_misuse_blockhash blo101
        block.blockhash(100);
        // <yes> <report> solidity_misuse_blockhash blo101
        block.blockhash(block.number);
        // <yes> <report> solidity_misuse_blockhash blo101
        block.blockhash(block.number-257);
        block.blockhash(block.number-256);
    }
}