/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity >=0.4.25 <0.6.0;
pragma experimental ABIEncoderV2;


library MonetaryTypesLib {
    
    
    
    struct Currency {
        address ct;
        uint256 id;
    }

    struct Figure {
        int256 amount;
        Currency currency;
    }

    struct NoncedAmount {
        uint256 nonce;
        int256 amount;
    }
}

library SettlementChallengeTypesLib {
    
    
    
    enum Status {Qualified, Disqualified}

    struct Proposal {
        address wallet;
        uint256 nonce;
        uint256 referenceBlockNumber;
        uint256 definitionBlockNumber;

        uint256 expirationTime;

        
        Status status;

        
        Amounts amounts;

        
        MonetaryTypesLib.Currency currency;

        
        Driip challenged;

        
        bool walletInitiated;

        
        bool terminated;

        
        Disqualification disqualification;
    }

    struct Amounts {
        
        int256 cumulativeTransfer;

        
        int256 stage;

        
        int256 targetBalance;
    }

    struct Driip {
        
        string kind;

        
        bytes32 hash;
    }

    struct Disqualification {
        
        address challenger;
        uint256 nonce;
        uint256 blockNumber;

        
        Driip candidate;
    }
}
