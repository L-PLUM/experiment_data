/**
 *Submitted for verification at Etherscan.io on 2019-02-17
*/

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.0;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: openzeppelin-solidity/contracts/cryptography/ECDSA.sol

pragma solidity ^0.5.0;

/**
 * @title Elliptic curve signature operations
 * @dev Based on https://gist.github.com/axic/5b33912c6f61ae6fd96d6c4a47afde6d
 * TODO Remove this library once solidity supports passing a signature to ecrecover.
 * See https://github.com/ethereum/solidity/issues/864
 */

library ECDSA {
    /**
     * @dev Recover signer address from a message by using their signature
     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param signature bytes signature, the signature is generated using web3.eth.sign()
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solhint-disable-next-line no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            return ecrecover(hash, v, r, s);
        }
    }

    /**
     * toEthSignedMessageHash
     * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
     * and hash the result
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/IndexedMerkleProof.sol

pragma solidity ^0.5.2;


library IndexedMerkleProof {
    function verify(bytes memory proof, uint160 root, uint160 leaf, uint index) internal pure returns (bool) {
        // Check if the computed hash (root) is equal to the provided root
        return root == compute(proof, leaf, index);
    }

    function compute(bytes memory proof, uint160 leaf, uint index) internal pure returns (uint160) {
        uint160 computedHash = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            uint160 proofElement;
            assembly {
                proofElement := div(mload(add(proof, 32)), 0x1000000000000000000000000)
            }

            if (index & (1 << i) == 0) {
                // Hash(current computed hash + current element of the proof)
                computedHash = uint160(uint256(keccak256(abi.encodePacked(computedHash, proofElement))));
            } else {
                // Hash(current element of the proof + current computed hash)
                computedHash = uint160(uint256(keccak256(abi.encodePacked(proofElement, computedHash))));
            }
        }

        // Check if the computed hash (root) is equal to the provided root
        return computedHash;
    }
}

// File: contracts/CertCenter.sol

pragma solidity ^0.5.2;



contract CertCenter is Ownable {
    mapping(address => bool) public renters;

    event RenterAdded(address indexed renter);
    event RenterRemoved(address indexed renter);

    function updateRenters(
        address[] calldata rentersToRemove,
        address[] calldata rentersToAdd
    )
        external
        onlyOwner
    {
        for (uint i = 0; i < rentersToRemove.length; i++) {
            if (renters[rentersToRemove[i]]) {
                delete renters[rentersToRemove[i]];
                emit RenterRemoved(rentersToRemove[i]);
            }
        }

        for (uint i = 0; i < rentersToAdd.length; i++) {
            if (!renters[rentersToAdd[i]]) {
                renters[rentersToAdd[i]] = true;
                emit RenterAdded(rentersToAdd[i]);
            }
        }
    }
}

// File: contracts/Vehicle.sol

pragma solidity ^0.5.2;


contract Vehicle {
    address public vehicle;

    modifier onlyVehicle {
        require(msg.sender == vehicle);
        _;
    }

    constructor(address vehicleAddress) public {
        require(vehicleAddress != address(0));
        vehicle = vehicleAddress;
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: contracts/IKyberNetwork.sol

pragma solidity ^0.5.2;


contract IKyberNetwork {
    function trade(
        address src,
        uint256 srcAmount,
        address dest,
        address destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address walletId
    )
        public
        payable
        returns(uint);

    function getExpectedRate(
        address source,
        address dest,
        uint srcQty
    )
        public
        view
        returns (
            uint expectedPrice,
            uint slippagePrice
        );
}

// File: contracts/AnyPaymentReceiver.sol

pragma solidity ^0.5.2;






contract AnyPaymentReceiver is Ownable {
    using SafeMath for uint256;

    address constant public ETHER_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    function _processPayment(
        IKyberNetwork kyber,
        address desiredToken,
        address paymentToken,
        uint256 paymentAmount
    )
        internal
        returns(uint256)
    {
        uint256 previousBalance = _balanceOf(desiredToken);

        // Receive payment
        if (paymentToken != address(0)) {
            require(IERC20(paymentToken).transferFrom(msg.sender, address(this), paymentAmount));
        } else {
            require(msg.value >= paymentAmount);
        }

        // Convert payment if needed
        if (paymentToken != desiredToken) {
            if (paymentToken != address(0)) {
                IERC20(paymentToken).approve(address(kyber), paymentAmount);
            }

            kyber.trade.value(msg.value)(
                (paymentToken == address(0)) ? ETHER_ADDRESS : paymentToken,
                (paymentToken == address(0)) ? msg.value : paymentAmount,
                (desiredToken == address(0)) ? ETHER_ADDRESS : desiredToken,
                address(this),
                1 << 255,
                0,
                address(0)
            );
        }

        uint256 currentBalance = _balanceOf(desiredToken);
        return currentBalance.sub(previousBalance);
    }

    function _balanceOf(address token) internal view returns(uint256) {
        if (token == address(0)) {
            return address(this).balance;
        }
        return IERC20(token).balanceOf(address(this));
    }

    function _returnRemainder(address payable renter, IERC20 token, uint256 remainder) internal {
        if (token == IERC20(0)) {
            renter.transfer(remainder);
        } else {
            token.transfer(renter, remainder);
        }
    }
}

// File: contracts/Car.sol

pragma solidity ^0.5.2;










contract Car is Ownable, Vehicle, AnyPaymentReceiver {
    using ECDSA for bytes;
    using IndexedMerkleProof for bytes;

    enum State {
        NotAvailable,
        AlreadyBooked,
        AlreadyRented,
        AvailableForRent,
        ReturningToHome
    }

    struct Tariff {
        IERC20 desiredToken;
        uint256 pricePerMinute;
        uint256 minimumCost;
        uint256 bookingCost;
        uint256 maxTime;
    }

    State public state;
    Tariff public tariff;
    mapping(address => uint256) public renterDeposits;
    mapping(uint160 => uint) public expiringCodesMerkleRoots;
    mapping(address => bool) public trustedCertCenters;

    event StateUpdated(State indexed newState, State indexed oldState);
    event TariffUpdated();
    event ExpiringCodeAdded(uint160 indexed expiringCode);
    event ExpiringCodeRemoved(uint160 indexed expiringCode);
    event CertCenterAdded(address indexed certCenter);
    event CertCenterRemoved(address indexed certCenter);
    event LocationUpdated(uint256 latitude, uint256 longitude);
    event EncryptedLocationUpdated(bytes32 encKey, uint256 encLatitude, uint256 encLongitude);
    event DepositAdded(address indexed renter, uint256 amount);

    constructor(address vehicle)
        public
        Vehicle(vehicle)
    {
    }

    // Owner methods

    function updateState(State newState) external onlyOwner {
        require(state != newState);
        emit StateUpdated(newState, state);
        state = newState;
    }

    function updateTariff(
        IERC20 desiredToken,
        uint256 pricePerMinute,
        uint256 minimumCost,
        uint256 bookingCost,
        uint256 maxTime
    )
        external
        onlyOwner
    {
        require(state == State.NotAvailable);
        emit TariffUpdated();
        tariff = Tariff({
            desiredToken: desiredToken,
            pricePerMinute: pricePerMinute,
            minimumCost: minimumCost,
            bookingCost: bookingCost,
            maxTime: maxTime
        });
    }

    function updateCertCenters(
        address[] calldata notYetTrustedCertCenters,
        address[] calldata alreadyTrustedCertCenters
    )
        external
        onlyOwner
    {
        for (uint i = 0; i < alreadyTrustedCertCenters.length; i++) {
            if (trustedCertCenters[alreadyTrustedCertCenters[i]]) {
                delete trustedCertCenters[alreadyTrustedCertCenters[i]];
                emit CertCenterRemoved(alreadyTrustedCertCenters[i]);
            }
        }

        for (uint i = 0; i < notYetTrustedCertCenters.length; i++) {
            if (!trustedCertCenters[notYetTrustedCertCenters[i]]) {
                trustedCertCenters[notYetTrustedCertCenters[i]] = true;
                emit CertCenterAdded(notYetTrustedCertCenters[i]);
            }
        }
    }

    // Vehicle methods

    function addExpiringCode(
        uint160 notYetExpiredCode,
        uint160[] calldata alreadyExpiredCodes
    )
        external
        onlyVehicle
    {
        require(state == State.AvailableForRent);

        for (uint i = 0; i < alreadyExpiredCodes.length; i++) {
            if (expiringCodesMerkleRoots[alreadyExpiredCodes[i]] != 0) {
                delete expiringCodesMerkleRoots[alreadyExpiredCodes[i]];
                emit ExpiringCodeRemoved(alreadyExpiredCodes[i]);
            }
        }

        if (expiringCodesMerkleRoots[notYetExpiredCode] == 0) {
            expiringCodesMerkleRoots[notYetExpiredCode] = now;
            emit ExpiringCodeAdded(notYetExpiredCode);
        }
    }

    function postLocation(uint256 latitude, uint256 longitude) public onlyVehicle {
        require(state != State.AlreadyRented);
        emit LocationUpdated(latitude, longitude);
    }

    function postEncryptedLocation(bytes32 encKey, uint256 encLatitude, uint256 encLongitude) public onlyVehicle {
        require(state != State.AlreadyRented);
        emit EncryptedLocationUpdated(encKey, encLatitude, encLongitude);
    }

    // Renter methods

    function book(
        IKyberNetwork kyber, // 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;
        CertCenter certCenter,
        address paymentToken,
        uint256 paymentAmount
    )
        external
        payable
    {
        require(state == State.AvailableForRent || state == State.ReturningToHome);
        require(trustedCertCenters[address(certCenter)], "Not trusted cert center");
        require(certCenter.renters(msg.sender), "Renter check fails");

        uint256 deposit = _processPayment(kyber, address(tariff.desiredToken), paymentToken, paymentAmount);
        renterDeposits[msg.sender] = renterDeposits[msg.sender].add(deposit);
        require(renterDeposits[msg.sender] >= tariff.bookingCost);
        emit DepositAdded(msg.sender, deposit);

        emit StateUpdated(State.AlreadyBooked, state);
        state = State.AlreadyBooked;
    }

    function cancelBooking() external {
        require(state == State.AlreadyBooked && renterDeposits[msg.sender] != 0);
        _returnRemainder(msg.sender, tariff.desiredToken, renterDeposits[msg.sender]);
        renterDeposits[msg.sender] = 0;

        emit StateUpdated(State.AvailableForRent, state);
        state = State.AvailableForRent;
    }

    function rent(
        IKyberNetwork kyber, // 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;
        CertCenter certCenter,
        address paymentToken,
        uint256 paymentAmount,
        bytes calldata signature,
        uint256 merkleIndex,
        bytes calldata merkleProof
    )
        external
    {
        require(state == State.AvailableForRent ||
                state == State.ReturningToHome);
        require(state == State.AlreadyBooked && renterDeposits[msg.sender] != 0);
        require(trustedCertCenters[address(certCenter)], "Not trusted cert center");
        require(certCenter.renters(msg.sender), "Renter check fails");

        bytes32 messageHash = ECDSA.toEthSignedMessageHash(keccak256(abi.encodePacked(msg.sender)));
        address signer = ECDSA.recover(messageHash, signature);
        uint160 merkleRoot = merkleProof.compute(uint160(signer), merkleIndex);
        require(expiringCodesMerkleRoots[merkleRoot] != 0);

        uint256 time = expiringCodesMerkleRoots[merkleRoot] + merkleIndex * 60 * 5;
        require(time < now + 60 * 5);

        uint256 deposit = _processPayment(kyber, address(tariff.desiredToken), paymentToken, paymentAmount);
        renterDeposits[msg.sender] = renterDeposits[msg.sender].add(deposit);
        require(renterDeposits[msg.sender] >= tariff.minimumCost);
        emit DepositAdded(msg.sender, deposit);

        emit StateUpdated(State.AlreadyRented, state);
        state = State.AlreadyRented;
    }
}
