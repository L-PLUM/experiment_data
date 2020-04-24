/**
 *Submitted for verification at Etherscan.io on 2019-01-24
*/

pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/ReentrancyGuard.sol

/**
 * @title Helps contracts guard against reentrancy attacks.
 * @author Remco Bloemen <[email protected]π.com>, Eenae <[email protected]>
 * @dev If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

  /// @dev Constant for unlocked guard state - non-zero to prevent extra gas costs.
  /// See: https://github.com/OpenZeppelin/openzeppelin-solidity/issues/1056
  uint private constant REENTRANCY_GUARD_FREE = 1;

  /// @dev Constant for locked guard state
  uint private constant REENTRANCY_GUARD_LOCKED = 2;

  /**
   * @dev We use a single lock for the whole contract.
   */
  uint private reentrancyLock = REENTRANCY_GUARD_FREE;

  /**
   * @dev Prevents a contract from calling itself, directly or indirectly.
   * If you mark a function `nonReentrant`, you should also
   * mark it `external`. Calling one `nonReentrant` function from
   * another is not supported. Instead, you can implement a
   * `private` function doing the actual work, and an `external`
   * wrapper marked as `nonReentrant`.
   */
  modifier nonReentrant() {
    require(reentrancyLock == REENTRANCY_GUARD_FREE);
    reentrancyLock = REENTRANCY_GUARD_LOCKED;
    _;
    reentrancyLock = REENTRANCY_GUARD_FREE;
  }

}

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



contract Verifier is ReentrancyGuard, Common {
    function verify(
        Order memory order,
        uint256 takerAmountToFill,
        address taker
    )
    public
    returns (bool);

    function verifyUser(address user)
    external
    returns (bool);
}

// File: contracts/WyreVerifier.sol

contract YesToken {
    function balanceOf(address _owner)
    external
    view
    returns (uint256);
}

contract WyreVerifier is Verifier {

    YesToken public cert;

    constructor(address _cert) public {
        cert = YesToken(_cert);
    }

    function verify(
        Order memory order,
        uint256 takerAmountToFill,
        address taker
    )
    public
    nonReentrant
    returns (bool) {
        return cert.balanceOf(order.orderAddresses[0]) == 1 && cert.balanceOf(taker) == 1;
    }

    function verifyUser(address user)
    external
    nonReentrant
    returns (bool) {
        return cert.balanceOf(user) == 1;
    }
}
