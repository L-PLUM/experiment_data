/**
 *Submitted for verification at Etherscan.io on 2019-01-23
*/

pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

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
}

// File: contracts/DefaultVerifier.sol


contract DefaultVerifier is Ownable, Verifier {

    address[] trustedVerifiers;

    event AddVerifier(address verifier, address[] trustedVerifiers);
    event RemoveVerifier(address verifier, address[] trustedVerifiers);

    function addVerifier(address verifier) public onlyOwner {
        trustedVerifiers.push(verifier);
        emit AddVerifier(verifier, trustedVerifiers);
    }

    function removeVerifier(address verifier) public onlyOwner {
        for (uint256 i = 0; i < trustedVerifiers.length; i++) {
            if (trustedVerifiers[i] == verifier) {
                for (uint256 j = i; j < trustedVerifiers.length - 1; j++) {
                    trustedVerifiers[j] = trustedVerifiers[j + 1];
                }
                delete trustedVerifiers[trustedVerifiers.length - 1];
                trustedVerifiers.length--;
                emit RemoveVerifier(verifier, trustedVerifiers);
                return;
            }
        }
    }

    function verify(
        Order memory order,
        uint256 takerAmountToFill,
        address taker
    )
    public
    nonReentrant
    returns (bool) {
        for (uint256 i = 0; i < trustedVerifiers.length; i++) {
            if (Verifier(trustedVerifiers[i]).verify(order, takerAmountToFill, taker)) {
                return true;
            }
        }
        return false;
    }
}
