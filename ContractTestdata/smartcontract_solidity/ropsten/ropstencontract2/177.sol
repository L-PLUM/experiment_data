/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity >=0.4.25 <0.6.0;


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

library NahmiiTypesLib {
    
    
    
    enum ChallengePhase {Dispute, Closed}

    
    
    
    struct OriginFigure {
        uint256 originId;
        MonetaryTypesLib.Figure figure;
    }

    struct IntendedConjugateCurrency {
        MonetaryTypesLib.Currency intended;
        MonetaryTypesLib.Currency conjugate;
    }

    struct SingleFigureTotalOriginFigures {
        MonetaryTypesLib.Figure single;
        OriginFigure[] total;
    }

    struct TotalOriginFigures {
        OriginFigure[] total;
    }

    struct CurrentPreviousInt256 {
        int256 current;
        int256 previous;
    }

    struct SingleTotalInt256 {
        int256 single;
        int256 total;
    }

    struct IntendedConjugateCurrentPreviousInt256 {
        CurrentPreviousInt256 intended;
        CurrentPreviousInt256 conjugate;
    }

    struct IntendedConjugateSingleTotalInt256 {
        SingleTotalInt256 intended;
        SingleTotalInt256 conjugate;
    }

    struct WalletOperatorHashes {
        bytes32 wallet;
        bytes32 operator;
    }

    struct Signature {
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    struct Seal {
        bytes32 hash;
        Signature signature;
    }

    struct WalletOperatorSeal {
        Seal wallet;
        Seal operator;
    }
}

library PaymentTypesLib {
    
    
    
    enum PaymentPartyRole {Sender, Recipient}

    
    
    
    struct PaymentSenderParty {
        uint256 nonce;
        address wallet;

        NahmiiTypesLib.CurrentPreviousInt256 balances;

        NahmiiTypesLib.SingleFigureTotalOriginFigures fees;

        string data;
    }

    struct PaymentRecipientParty {
        uint256 nonce;
        address wallet;

        NahmiiTypesLib.CurrentPreviousInt256 balances;

        NahmiiTypesLib.TotalOriginFigures fees;
    }

    struct Operator {
        uint256 id;
        string data;
    }

    struct Payment {
        int256 amount;
        MonetaryTypesLib.Currency currency;

        PaymentSenderParty sender;
        PaymentRecipientParty recipient;

        
        NahmiiTypesLib.SingleTotalInt256 transfers;

        NahmiiTypesLib.WalletOperatorSeal seals;
        uint256 blockNumber;

        Operator operator;
    }

    
    
    
    function PAYMENT_KIND()
    public
    pure
    returns (string memory)
    {
        return "payment";
    }
}
