/**
 *Submitted for verification at Etherscan.io on 2019-07-24
*/

/**
 *  @authors: [@mtsalenc]
 *  @reviewers: []
 *  @auditors: []
 *  @bounties: []
 *  @deployments: []
 */

pragma solidity 0.5.1;
pragma experimental ABIEncoderV2;


interface ArbitrableTokenList {
    function getTokenInfo(bytes32) external view returns (string memory, address, string memory, uint, uint);
}


contract TokensView {
    struct Token {
        string name;
        address addr;
        string symbolMultihash;
        uint status;
        uint numberOfRequest;
    }
    
    function getTokens(address t2crAddress, bytes32[] calldata tokenIDs) 
        external 
        view 
        returns (Token[] memory tokens)
    {
        ArbitrableTokenList t2cr = ArbitrableTokenList(t2crAddress);
        for (uint i = 0; i < tokenIDs.length; i++) {
            (string memory tokenName, address tokenAddress, string memory symbolMultihash, uint tokenStatus, uint numberOfRequests) = t2cr.getTokenInfo(tokenIDs[i]);
            tokens[i] = Token(
                tokenName,
                tokenAddress,
                symbolMultihash,
                tokenStatus,
                numberOfRequests
            );
        }
    }
}
