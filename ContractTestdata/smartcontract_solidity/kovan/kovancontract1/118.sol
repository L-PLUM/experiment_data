/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity ^0.5.2;

// File: contracts/Common.sol

contract Common {
    struct Order {
        // 0: maker
        // 1: taker
        // 2: makerToken
        // 3: takerToken
        // 4: reseller
        // 5: [placeholder]
        // 6: verifier
        // 7: makerTokenBank
        // 8: takerTokenBank
        address[9] orderAddresses;
        // 0: makerAmount
        // 1: takerAmount
        // 2: expires
        // 3: nonce
        // 4: minimumTakerAmount
        uint256[5] orderValues;
        bytes makerData;
        bytes takerData;
    }

    struct OrderInfo {
        uint8 orderStatus;
        bytes32 orderHash;
        uint256 filledTakerAmount;
    }

    struct FillResults {
        uint256 makerFilledAmount;
        uint256 makerFeeExchange;
        uint256 makerFeeReseller;
        uint256 takerFilledAmount;
        uint256 takerFeeExchange;
        uint256 takerFeeReseller;
    }

    struct MatchedFillResults {
        FillResults left;
        FillResults right;
        uint256 spreadAmount;
    }
}

// File: contracts/Verifier.sol

pragma experimental ABIEncoderV2;


/// An abstract Contract of Verifier.
contract Verifier is Common {

    /// Verifies trade for KYC purposes.
    /// @param order Order object.
    /// @param takerAmountToFill Desired amount of takerToken to sell.
    /// @param taker Taker address.
    /// @return Whether the trade is valid.
    function verify(
        Order memory order,
        uint256 takerAmountToFill,
        address taker
    )
    public
    view
    returns (bool);

    /// Verifies user address for KYC purposes.
    /// @param user User address.
    /// @return Whether the user address is valid.
    function verifyUser(address user)
    external
    view
    returns (bool);
}

// File: contracts/WyreVerifier.sol


/// Interface of YES token issued by Wyre.
interface IYes {

    /// If user has a YES token, it means the user has been KYCed by Wyre.
    /// @param _owner User address.
    /// @return Number of YES token the user has.
    function balanceOf(address _owner)
    external
    view
    returns (uint256);
}

/// Uses Wyre as service provider for KYC verification.
contract WyreVerifier is Verifier {

    IYes public yes;

    constructor(address addr) public {
        yes = IYes(addr);
    }

    /// Verifies both order maker and order taker.
    /// @param order Order object.
    /// @param taker Taker address.
    /// @return Whether the trade is valid.
    function verify(
        Order memory order,
        uint256,
        address taker
    )
    public
    view
    returns (bool) {
        return yes.balanceOf(order.orderAddresses[0]) == 1 && yes.balanceOf(taker) == 1;
    }

    /// Verifies user address.
    /// @param user User address.
    /// @return Whether the user address is valid.
    function verifyUser(address user)
    external
    view
    returns (bool) {
        return yes.balanceOf(user) == 1;
    }
}
