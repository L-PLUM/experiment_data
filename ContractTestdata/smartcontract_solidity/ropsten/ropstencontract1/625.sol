/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity >=0.5.0;

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

contract Fizzy is Ownable {

    uint128 constant CANCELLED  = 2**0;
    uint128 constant DIVERTED   = 2**1;
    uint128 constant REDIRECTED = 2**2;
    uint128 constant DELAY      = 2**3;

    enum InsuranceStatus {
        Open, ClosedCompensated, ClosedNotCompensated
    }

    struct Insurance {
        uint256         productId;
        uint256         premium;
        uint256         indemnity;
        uint64          limitArrivalTime; // timestamp in sec
        uint128         conditions;
        InsuranceStatus status;
        address payable compensationAddress;
    }

    // key: flightId
    mapping(bytes32 => Insurance[]) private insuranceList;

    event InsuranceCreation(
        bytes32         flightId,            // <carrier_code><flight_number>.<timestamp_in_sec_of_departure_date>
        uint256         productId,
        uint256         premium,
        uint256         indemnity,
        uint64          limitArrivalTime,
        uint128         conditions,
        address payable compensationAddress  // The indemnity will be send to this address in case of crypto payment.
    );

    event InsuranceUpdate(
        bytes32         flightId,            // <carrier_code><flight_number>.<timestamp_in_sec_of_departure_date>
        uint256         productId,
        uint256         premium,
        uint256         indemnity,
        InsuranceStatus status
    );

    /**
    * @dev Allow the owner to add a new insurance for the given flight
    * @param flightId <carrier_code><flight_number>.<timestamp_in_sec_of_departure_date>
    * @param productId ID string of product linked to the insurance
    * @param premium Amount of premium paid by the client
    * @param indemnity Amount (potentialy) perceived by the client
    * @param limitArrivalTime Maximum time after which we trigger the compensation (timestamp in sec)
    * @param conditions flight statuses triggering compensation
    */
    function addNewInsurance(
        bytes32 flightId,
        uint256 productId,
        uint256 premium,
        uint256 indemnity,
        uint64  limitArrivalTime,
        uint128 conditions
        ) external onlyOwner {

        _addNewInsurance(flightId, productId, premium, indemnity, limitArrivalTime, conditions, address(0));
    }

    /**
    * @dev Set the actual arrival time of a flight
    * @param flightId <carrier_code><flight_number>.<timestamp_in_sec_of_departure_date>
    * @param actualArrivalTime The actual arrival time of the flight (timestamp in sec)
    */
    function setFlightLandedAndArrivalTime(
        bytes32 flightId,
        uint64 actualArrivalTime)
        external
        onlyOwner {

        for (uint i = 0; i < insuranceList[flightId].length; i++) {
            Insurance memory insurance = insuranceList[flightId][i];
            if (insurance.status == InsuranceStatus.Open) {
                InsuranceStatus newStatus;

                if (_containsCondition(insurance.conditions, DELAY)) {
                    if (actualArrivalTime > insurance.limitArrivalTime) {
                        newStatus = InsuranceStatus.ClosedCompensated;
                        compensateIfEtherPayment(insurance);
                    } else {
                        newStatus = InsuranceStatus.ClosedNotCompensated;
                        noCompensateIfEtherPayment(insurance);
                    }
                } else {
                    newStatus = InsuranceStatus.ClosedNotCompensated;
                    noCompensateIfEtherPayment(insurance);
                }

                insuranceList[flightId][i].status = newStatus;

                emit InsuranceUpdate(
                    flightId,
                    insurance.productId,
                    insurance.premium,
                    insurance.indemnity,
                    newStatus
                    );
            }
        }
    }

    /**
    * @dev Set the status of the flighjt
    * @param flightId <carrier_code><flight_number>.<timestamp_in_sec_of_departure_date>
    * @param flightStatus status of the flight
    */
    function setFlightStatus(
        bytes32 flightId,
        uint128 flightStatus)
        external
        onlyOwner {

        for (uint i = 0; i < insuranceList[flightId].length; i++) {
            Insurance memory insurance = insuranceList[flightId][i];

            if (insurance.status == InsuranceStatus.Open) {
                InsuranceStatus newInsuranceStatus;

                if (_containsCondition(insurance.conditions, flightStatus)) {
                    newInsuranceStatus = InsuranceStatus.ClosedCompensated;
                    compensateIfEtherPayment(insurance);
                } else {
                    newInsuranceStatus = InsuranceStatus.ClosedNotCompensated;
                    noCompensateIfEtherPayment(insurance);
                }

                insuranceList[flightId][i].status = newInsuranceStatus;

                emit InsuranceUpdate(
                    flightId,
                    insurance.productId,
                    insurance.premium,
                    insurance.indemnity,
                    newInsuranceStatus
                    );
            }
        }
    }

    /**
    * @dev Manually resolve an insurance contract
    * @param flightId <carrier_code><flight_number>.<timestamp_in_sec_of_departure_date>
    * @param productId ID string of the product linked to the insurance
    * @param newStatus ID of the resolution status for this insurance contract
    */
    function manualInsuranceResolution(
        bytes32 flightId,
        uint256 productId,
        InsuranceStatus newStatus
    )
        external
        onlyOwner {
        require(newStatus == InsuranceStatus.ClosedCompensated || newStatus == InsuranceStatus.ClosedNotCompensated);

        for (uint i = 0; i < insuranceList[flightId].length; i++) {
            Insurance memory insurance = insuranceList[flightId][i];
            if (insurance.status == InsuranceStatus.Open && insurance.productId == productId) {
                if (newStatus == InsuranceStatus.ClosedCompensated) {
                    compensateIfEtherPayment(insurance);
                } else if (newStatus == InsuranceStatus.ClosedNotCompensated) {
                    noCompensateIfEtherPayment(insurance);
                }

                insuranceList[flightId][i].status = newStatus;

                emit InsuranceUpdate(
                    flightId,
                    insurance.productId,
                    insurance.premium,
                    insurance.indemnity,
                    newStatus
                    );
            }
        }
    }

    function _addNewInsurance (
        bytes32 flightId,
        uint256 productId,
        uint256 premium,
        uint256 indemnity,
        uint64  limitArrivalTime,
        uint128 conditions,
        address payable compensationAddress
    ) internal {

        Insurance memory newInsurance;
        newInsurance.productId = productId;
        newInsurance.premium = premium;
        newInsurance.indemnity = indemnity;
        newInsurance.limitArrivalTime = limitArrivalTime;
        newInsurance.conditions = conditions;
        newInsurance.status = InsuranceStatus.Open;
        newInsurance.compensationAddress = compensationAddress;

        insuranceList[flightId].push(newInsurance);

        emit InsuranceCreation(flightId, productId, premium, indemnity, limitArrivalTime, conditions, compensationAddress);
    }

    function _compensate(address payable to, uint256 amount, uint256 productId) internal returns (bool success);
    function _noCompensate(uint256 amount) internal returns (bool success);

    function compensateIfEtherPayment(Insurance memory insurance) private {
        if (insurance.compensationAddress != address(0)) {
            _compensate(insurance.compensationAddress, insurance.indemnity, insurance.productId);
        }
    }

    function noCompensateIfEtherPayment(Insurance memory insurance) private {
        if (insurance.compensationAddress != address(0)) {
            _noCompensate(insurance.indemnity);
        }
    }

    function _containsCondition(uint128 a, uint128 b) private pure returns (bool) {
        return (a & b) != 0;
    }
}

contract FizzyCrypto is Fizzy {

    uint256 private _availableExposure;
    uint256 private _collectedTaxes;
    address private _signer;

    event EtherCompensation(uint256 amount, address to, uint256 productId);
    event EtherCompensationError(uint256 amount, address to, uint256 productId);
    event SignershipTransferred(address previousSigner, address newSigner);

    modifier beforeTimestampLimit(uint256 timestampLimit) {
        require(timestampLimit >= now, "The transaction is invalid: the timestamp limit has been reached.");
        _;
    }

    modifier enoughExposure(uint256 amount) {
        require(_availableExposure >= amount, "Available exposure can not be reached");
        _;
    }

    modifier enoughTaxes(uint256 amount) {
        require(_collectedTaxes >= amount, "Cannot withdraw more taxes than all collected taxes");
        _;
    }

    constructor () public {
        _signer = msg.sender;
        emit SignershipTransferred(address(0), _signer);
    }

    function deposit() external payable onlyOwner {
        _availableExposure = _availableExposure + msg.value;
    }

    function withdraw(uint256 amount) external onlyOwner enoughExposure(amount) {
        _availableExposure = _availableExposure - amount;
        msg.sender.transfer(amount);
    }

    function withdrawTaxes(uint256 amount) external onlyOwner enoughTaxes(amount) {
        _collectedTaxes = _collectedTaxes - amount;
        msg.sender.transfer(amount);
    }

    function buyInsurance(
        bytes32        flightId,
        uint256        productId,
        uint256        premium,
        uint256        indemnity,
        uint256        taxes,
        uint64         limitArrivalTime,
        uint128        conditions,
        uint256        timestampLimit,
        bytes calldata signature
    )
        external
        payable
        beforeTimestampLimit(timestampLimit)
        enoughExposure(indemnity)
    {
        _checkSignature(flightId, productId, premium, indemnity, taxes, limitArrivalTime, conditions, timestampLimit, signature);

        require(premium >= taxes, "The taxes must be included in the premium.");
        require(premium == msg.value, "The amount sent does not match the price of the order.");

        _addNewInsurance(flightId, productId, premium, indemnity, limitArrivalTime, conditions, msg.sender);

        _availableExposure = _availableExposure + premium - taxes - indemnity;
        _collectedTaxes = _collectedTaxes + taxes;
    }

    function availableExposure() external view returns(uint256) {
        return _availableExposure;
    }

    function collectedTaxes() external view returns(uint256) {
        return _collectedTaxes;
    }

    function _compensate(address payable to, uint256 amount, uint256 productId) internal returns (bool success) {
        if(to.send(amount)) {
            emit EtherCompensation(amount, to, productId);
            return true;
        } else {
            emit EtherCompensationError(amount, to, productId);
            return false;
        }
    }

    function _noCompensate(uint256 amount) internal returns (bool success) {
        _availableExposure = _availableExposure + amount;
        return true;
    }

    function transferSignership(address newSigner) onlyOwner external {
        require(newSigner != address(0));
        emit SignershipTransferred(_signer, newSigner);
        _signer = newSigner;
    }

    function _checkSignature(
        bytes32 flightId,
        uint256 productId,
        uint256 premium,
        uint256 indemnity,
        uint256 taxes,
        uint64  limitArrivalTime,
        uint128 conditions,
        uint256 timestampLimit,
        bytes memory signature
    ) private view  returns (bool) {

        bytes32 messageHash = keccak256(abi.encodePacked(
            flightId,
            productId,
            premium,
            indemnity,
            taxes,
            limitArrivalTime,
            conditions,
            timestampLimit
        ));

        address decypheredAddress = ECDSA.recover(ECDSA.toEthSignedMessageHash(messageHash), signature);
        require(decypheredAddress == _signer, "The signature is invalid if it does not match the _signer address.");
    }
}
