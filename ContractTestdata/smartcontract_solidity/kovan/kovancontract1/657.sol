/**
 *Submitted for verification at Etherscan.io on 2019-01-16
*/

pragma solidity ^0.4.24;

// File: contracts/CDLotteryConverter.sol

contract ICDClue {
    function clues(uint id) public returns (uint, uint);
    function ownerOf(uint256 _tokenId) public view returns (address);
}

contract CDLotteryConverter {
    address CDClueAddress;

    constructor(address _CDClueAddress) public {
        CDClueAddress = _CDClueAddress;
    }

    function artefacts(uint id) public returns (uint, uint) {
        return ICDClue(CDClueAddress).clues(id);
    }

    function ownerOf(uint _tokenId) public returns (address) {
        return ICDClue(CDClueAddress).ownerOf(_tokenId);
    }
}
