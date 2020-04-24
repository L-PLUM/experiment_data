/**
 *Submitted for verification at Etherscan.io on 2018-12-13
*/

pragma solidity ^0.4.23;

pragma solidity ^0.4.23;


/// @title defined the interface that will be referenced in main Cutie contract
contract GeneMixerInterface {
    /// @dev simply a boolean to indicate this is the contract we expect to be
    function isGeneMixer() external pure returns (bool);

    /// @dev given genes of cutie 1 & 2, return a genetic combination - may have a random factor
    /// @param genes1 genes of mom
    /// @param genes2 genes of dad
    /// @return the genes that are supposed to be passed down the child
    function mixGenes(uint256 genes1, uint256 genes2) public view returns (uint256);

    function canBreed(uint40 momId, uint256 genes1, uint40 dadId, uint256 genes2) public view returns (bool);
}


contract GeneMixer is GeneMixerInterface {
   
    function isGeneMixer() external pure returns (bool)
    {
        return true;
    }

    function shift8(uint256 source1, uint256 source2) internal pure returns (uint256 shifted1, uint256 shifted2, uint8 element1, uint8 element2) {
        element1 = uint8(source1 % 0x100);
        element2 = uint8(source2 % 0x100);
        shifted1 = source1 / 0x100;
        shifted2 = source2 / 0x100;
    }

    function push8(uint256 result, uint256 mask, uint8 value) internal pure returns (uint256 result2, uint256 mask2) 
    {
        result2 = result | (value * mask);
        mask2 = mask * 0x100;
    }

    function shift4(uint256 source1, uint256 source2) internal pure returns (uint256 shifted1, uint256 shifted2, uint8 element1, uint8 element2) {
        element1 = uint8(source1 % 0x10);
        element2 = uint8(source2 % 0x10);
        shifted1 = source1 / 0x10;
        shifted2 = source2 / 0x10;
    }

    function push4(uint256 result, uint256 mask, uint8 value) internal pure returns (uint256 result2, uint256 mask2) 
    {
        result2 = result | (value * mask);
        mask2 = mask * 0x10;
    }

    function mixRecessive(uint256 genes, uint256 random) internal pure returns (uint256 result) 
    {
        // input genes sets - split
        uint80 a1 = uint80(genes % 0x10000000000000000000);
        genes /= 0x10000000000000000000;
        uint80 a2 = uint80(genes % 0x10000000000000000000);
        genes /= 0x10000000000000000000;
        uint80 a3 = uint80(genes % 0x10000000000000000000);

        // output genes sets
        uint80 r1 = 0;
        uint80 r2 = 0;
        uint80 r3 = 0;

        uint80 mask = 1;
        uint8 temp;

        for (uint8 i = 0; i < 19; i++)
        {
            // each gene in sets
            uint8 e1 = uint8(a1 % 0x10);
            uint8 e2 = uint8(a2 % 0x10);
            uint8 e3 = uint8(a3 % 0x10);
            a1 /= 0x10;
            a2 /= 0x10;
            a3 /= 0x10;

            if (random % 5 == 0)
            {
                temp = e3;
                e3 = e2;
                e2 = temp;
            }
            random /= 5;
            if (random % 5 == 0)
            {
                temp = e1;
                e1 = e2;
                e2 = temp;
            }
            random /= 5;

            // fill resulting sets
            r1 |= mask*e1;
            r2 |= mask*e2;
            r3 |= mask*e3;
            mask *= 0x10;
        }

        // combining result sets
        result = uint256(r1) | (uint256(r2) * 0x10000000000000000000) | (uint256(r3) * 0x10000000000000000000 * 0x10000000000000000000);

//        random2 = random;
    }

    function mixGenes(uint256 genes1, uint256 genes2) public view returns (uint256) {

        uint256 random = uint256(blockhash(block.number-1));
        uint256 result = 0;
        uint256 mask = 1;

        uint8 a;
        uint8 b;
        uint8 c;

        // update number - max
        (genes1, genes2, a, b) = shift8(genes1, genes2);
        c = a > b ? a : b; // max
        (result, mask) = push8(result, mask, c);

        // animal type - random
        (genes1, genes2, a, b) = shift8(genes1, genes2);

        if (a == 0x90 || b == 0x90) // Mutant + Any
        {
            c = 0x90; // Mutant
        }
        else if (a == 0x80 && b == 0x80) // Mythic + Mythic
        {
            c = 0x90; // Mutant
        }
        else if (a == 0x80) // Mythic + Other
        {
            c = b; // Other
        }
        else if (b == 0x80) // Mythic + Other
        {
            c = a; // Other
        }
        else
        {
            c = random % 2 == 0 ? a : b;
            random /= 2;
        }
        (result, mask) = push8(result, mask, c);

        // Aristocracy - binary and
        (genes1, genes2, a, b) = shift4(genes1, genes2);
        if (random % 20 == 0) // 5% chance
        {
            c = a & b;
        }
        else
        {
            c = 0;
        }
        random /= 20;
        (result, mask) = push4(result, mask, c);

        // skip 8
        (genes1, genes2, a, b) = shift8(genes1, genes2);
        c = 0;
        random /= 2;
        (result, mask) = push8(result, mask, c);

        (genes1) = mixRecessive(genes1, random);
        random /= 0x100000000;
        (genes2) = mixRecessive(genes2, random);
        random /= 0x100000000;

        for (uint8 i = 0; i < 19*3; i++)
        {
            // genes - random
            (genes1, genes2, a, b) = shift4(genes1, genes2);
            c = random % 2 == 0 ? a : b;
            random /= 2;
            (result, mask) = push4(result, mask, c);
        }

        return result;
    }

    function canBreed(uint40 /*momId*/, uint256 /*genes1*/, uint40 /*dadId*/, uint256 /*genes2*/) 
        public
        view
        returns (bool)
    {
        return true;
    }
}
