/**
 *Submitted for verification at Etherscan.io on 2019-01-09
*/

pragma solidity ^0.4.24;
// produced by the Solididy File Flattener (c) David Appleton 2018
// contact : [email protected]
// released under Apache 2.0 licence
// input  D:\Topicus\ICO\[email protected]\Code\contracts\Leasje.sol
// flattened :  Wednesday, 09-Jan-19 12:53:50 UTC
contract ERC223 {
    uint public totalSupply;
    function balanceOf(address who) public view returns (uint);

    function name() public view returns (string _name);
    function symbol() public view returns (string _symbol);
    function decimals() public view returns (uint8 _decimals);
    function totalSupply() public view returns (uint256 _supply);

    function transfer(address to, uint value) public returns (bool ok);
    function transfer(address to, uint value, bytes data) public returns (bool ok);
    function transfer(address to, uint value, bytes data, string customFallback) public returns (bool ok);

    event Transfer(address indexed from, address indexed to, uint value);
}

contract SafeMath {
    uint256 constant public MAX_UINT256 =
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function safeAdd(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (x > MAX_UINT256 - y) revert();
        return x + y;
    }

    function safeSub(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (x < y) revert();
        return x - y;
    }

    function safeMul(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (y == 0) return 0;
        if (x > MAX_UINT256 / y) revert();
        return x * y;
    }
}
contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}
contract ERC223Token is ERC223, SafeMath {

    mapping(address => uint) balances;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    // Function to access name of token.
    function name() public view returns (string _name) {
        return name;
    }
    // Function to access symbol of token.
    function symbol() public view returns (string _symbol) {
        return symbol;
    }
    // Function to access decimals of token.
    function decimals() public view returns (uint8 _decimals) {
        return decimals;
    }
    // Function to access total supply of tokens.
    function totalSupply() public view returns (uint256 _totalSupply) {
        return totalSupply;
    }


    // Function that is called when a user or another contract wants to transfer funds.
    function transfer(address _to, uint _value, bytes _data, string _customFallback) public returns (bool success) {

        if(isContract(_to)) {
            if (balanceOf(msg.sender) < _value) revert();
            balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
            balances[_to] = safeAdd(balanceOf(_to), _value);
            assert(_to.call.value(0)(abi.encodePacked(_customFallback), msg.sender, _value, _data));
            emit Transfer(msg.sender, _to, _value);
            return true;
        }
        else {
            return transferToAddress(_to, _value, _data);
        }
    }


    // Function that is called when a user or another contract wants to transfer funds.
    function transfer(address _to, uint _value, bytes _data) public returns (bool success) {

        if(isContract(_to)) {
            return transferToContract(_to, _value, _data);
        }
        else {
            return transferToAddress(_to, _value, _data);
        }
    }



    // Assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) public view returns (bool is_contract) {
        uint length;
        assembly {
                //retrieve the size of the code on target address, this needs assembly
                length := extcodesize(_addr)
        }
        return (length>0);
    }

    // Function that is called when transaction target is an address.
    function transferToAddress(address _to, uint _value, bytes _data) private returns (bool success) {
        if (balanceOf(msg.sender) < _value) revert();
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Function that is called when transaction target is a contract.
    function transferToContract(address _to, uint _value, bytes _data) private returns (bool success) {
        if (balanceOf(msg.sender) < _value) revert();
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        ContractReceiver receiver = ContractReceiver(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Function that gets the balance of a user.
    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }
}

contract ContractReceiver {

    struct TKN {
        address sender;
        uint value;
        bytes data;
        bytes4 sig;
    }


    function tokenFallback(address _from, uint _value, bytes _data) public pure {
      TKN memory tkn;
      tkn.sender = _from;
      tkn.value = _value;
      tkn.data = _data;
      uint32 u = uint32(_data[3]) + (uint32(_data[2]) << 8) + (uint32(_data[1]) << 16) + (uint32(_data[0]) << 24);
      tkn.sig = bytes4(u);

      /* tkn variable is analogue of msg variable of Ether transaction
      *  tkn.sender is person who initiated this token transaction   (analogue of msg.sender)
      *  tkn.value the number of tokens that were sent   (analogue of msg.value)
      *  tkn.data is data of token transaction   (analogue of msg.data)
      *  tkn.sig is 4 bytes signature of function
      *  if data of token transaction is a function execution
      */
    }
}

contract Annuity is DSMath {

    uint256 public numberOfPeriods;         // The total number of payout periods the Lease contracts have.
    uint256 public payoutPeriod;            // The current payoutPeriod.
    uint256 public decimals;                // The number of decimals the Ray consists of.

    uint256 public RayInterestMonthly;      // The monthly interest in Ray format
    uint256 public RayInterestReservation;  // The interest reservation percentage in Ray format
    uint256 public RayInitialSupply;        // The starting amount of euro the contracts start with in Ray format

    /**
    * @dev Struct to store the details of the annuity.
    */
    struct AnnuityDetails {
        uint256 total;
        uint256 redemption;
        uint256 interest;
    }

    /**
    * @dev function to convert numbers to Rays.
    * This asserts that numbers are currently not in ray format.
    * @param _amount Amount to be converted.
    * @return amountRay_ Amount in Ray.
    */
    function convertToRay(uint256 _amount) internal view returns(uint256 amountRay_) {
        amountRay_ = (_amount * (10 ** uint256(decimals)));
    }

    /**
    * @dev Get the current payoutperiod.
    * @return payoutPeriod_ Current payoutperiod.
    */
    function getPayoutPeriod() public view returns(uint256 payoutPeriod_) {
        payoutPeriod_ = payoutPeriod;
    }

    /**
    * @dev Function to receive the price and redemption for a certain period.
    * The function uses the actual paid amount as input.
    * @param _payoutPeriod The payoutPeriod the price is calculated for
    * @return redemption The redemption in euro's for the current period, in Ray format.
    * @return price The price of a Leasje in euro's for the current period, in Ray format.
    */
    function getPriceForPeriod(uint256 _payoutPeriod) internal view returns(uint256, uint256) {

        uint256 ReversedPayoutPeriod = numberOfPeriods + 1 - _payoutPeriod;

        AnnuityDetails memory expectedAnnuitiyDetails = calculateAnnuityNumbers(_payoutPeriod);
        AnnuityDetails memory reversedAnnuitiyDetails = calculateAnnuityNumbers(ReversedPayoutPeriod);

        uint256 RayInterestForPayout = rmul(reversedAnnuitiyDetails.interest, sub(convertToRay(1), RayInterestReservation));

        uint256 RayLeasePrice = convertToRay(1) + rdiv(RayInterestForPayout, expectedAnnuitiyDetails.redemption);

        return (expectedAnnuitiyDetails.redemption, RayLeasePrice);

    }

    /**
    * @dev Function that calculates the total amount, the redemption, and interest for a given payoutperiod.
    * @param _payoutPeriod The given payoutperiod.
    * @return calculatedAnnuityDetails An AnnuityDetails object that contains the details of the annuity in euro's, converted to Ray.
    */
    function calculateAnnuityNumbers(uint256 _payoutPeriod) private view returns(AnnuityDetails memory) {

        AnnuityDetails memory calculatedAnnuityDetails;

        uint256 RayInterestMonthlyPlusOne = convertToRay(1) + RayInterestMonthly;

        calculatedAnnuityDetails.total = rmul(rdiv(RayInterestMonthly, (convertToRay(1) - rdiv(convertToRay(1), rpow(RayInterestMonthlyPlusOne, numberOfPeriods)))),RayInitialSupply);

        calculatedAnnuityDetails.interest = rdiv(
            (rmul(rmul(RayInitialSupply, RayInterestMonthly), (rpow(RayInterestMonthlyPlusOne, (numberOfPeriods + 1))) - rpow(RayInterestMonthlyPlusOne, _payoutPeriod))),
            (rmul(RayInterestMonthlyPlusOne, (rpow(RayInterestMonthlyPlusOne, numberOfPeriods) - convertToRay(1))))
        );

        calculatedAnnuityDetails.redemption = calculatedAnnuityDetails.total - calculatedAnnuityDetails.interest;

        return calculatedAnnuityDetails;

    }

}
contract Leasje is ERC223Token, Ownable, Annuity {

    // Keeps a list of addresses with balances that can be transfered to the front-end.
    mapping(address => uint) participantIndices;
    address[] participantList;

    // Keeps a whitelist of users that can have Leasjes.
    mapping(address => bool) public whitelist;

    bool public contractIsFrozen;
    uint256 public burnPercentage;

    uint256 public minimumMonthlyPayout;
    uint256 public maximumMonthlyPayout;

    // Payout price per period, multiplied with priceDecimals.
    mapping(uint256 => uint256) public price;

    // Initial payout for the current payoutPeriod minus the amount already paid.
    uint256 public payoutRemaining;

    // List of payouts per payoutperiod per address. Structure: address => (payoutperiod => payout).
    mapping(address => mapping(uint256 => uint256)) public payouts;

    // This generates a public event on the blockchain that will notify clients of the transfer.
    event Transfer(address indexed from, address indexed to, uint value);

    // This event is emitted when a user offers tokens for buyback to the contract. This may differ from the payout event depending on the burn percentage.
    event Burn(address indexed burner, uint256 value);

    // This event is emitted when a user requests the payout of Leasjes for tokens to the contract.
    event Payout(address addr, uint256 value);

    /**
    * @dev Constructor function.
    * Initializes the contract with initial supply tokens to the creator of the contract.
    */
    constructor(uint256 _totalSupply, string _name, string _symbol, uint8 _decimals, uint256 _backupSupply, uint256 _burnPercentage, uint256 _minimumMonthlyPayout,
                uint256 _maximumMonthlyPayout, uint256 _interestReservation, uint256 _numberOfPeriods) public {
        decimals = _decimals;
        name = _name;
        symbol = _symbol;
        burnPercentage = _burnPercentage;
        totalSupply = convertToRay(_totalSupply);
        minimumMonthlyPayout = convertToRay(_minimumMonthlyPayout);
        maximumMonthlyPayout = convertToRay(_maximumMonthlyPayout);
        numberOfPeriods = _numberOfPeriods;
        RayInterestReservation = rdiv(convertToRay(_interestReservation),convertToRay(100));
        RayInitialSupply = convertToRay(_totalSupply);
        uint256 RayBackupSupply = convertToRay(_backupSupply);

        payoutPeriod = 0;
        contractIsFrozen = false;
        payoutRemaining = 0;

        balances[msg.sender] = add(totalSupply, RayBackupSupply);
        addParticipantIfNotExists(msg.sender);
        addToWhitelist(msg.sender);
        addToWhitelist(address(0));
    }

    /**
    * @dev Modifier that validates if the contract is not frozen.
    * Reverts if the contract is frozen.
    */
    modifier isNotFrozen() {
        require(contractIsFrozen == false, "Contract is frozen");
        _;
    }

    /**
    * @dev Modifier that validates if an address is whitelisted.
    * Reverts if address is not whitelisted.
    * @param _addr Address to be checked.
    */
    modifier isWhitelisted(address _addr) {
        require(whitelist[_addr], "Address is not whitelisted");
        _;
    }

    /**
    * @dev Modifier that validates an incoming transfer.
    * Reverts if one of the validations below is not met.
    * Checks if the address to which the Leasjes are sent is not undefind.
    * Checks if the value to be sent is not 0.
    * @param _to Address to which the transfer is made.
    * @param _value Value in Leasje involved in the transfer, in Ray format.
    */
    modifier isValidTransfer(address _to, uint256 _value) {
        require(_to != address(0), "Transfer can not be done to address 0");
        require(_value > 0, "Transer value should be larger than 0");
        _;
    }

    /**
    * @dev Modifier that validates a payout.
    * Reverts if one of the validations below is not met.
    * Checks if the number of Leasjes to be sold is smaller or equal than the payout remaining.
    * Checks if the number of Leasjes to be sold is smaller or equal than the balance of the address.
    * Checks if the number of Leasjes to be sold is larger or equal than the minimum monthly payout.
    * Checks if the number of Leasjes plus the payout for that address is smaller or equal than the maximum monthly payout.
    * Checks if the payout is done by an account that's not the owner of the contract.
    * @param _addr Address of which the payout is made.
    * @param _numberOfLeasjes Number of Leasjes to be paid out, in Ray format.
    */
    modifier isValidPayout(address _addr, uint256 _numberOfLeasjes) {
        require(_numberOfLeasjes <= payoutRemaining, "Number of Leasjes to be sold should be smaller or equal than the payout remaining");
        require(_numberOfLeasjes <= balanceOf(_addr), "Number of Leasjes to be sold should be smaller or equal than the balance of the address");
        require(_numberOfLeasjes >= minimumMonthlyPayout, "Number of Leasjes to be sold should at least equal the minimum monthly payout");
        require(safeAdd(getPayout(_addr, payoutPeriod), _numberOfLeasjes) <= maximumMonthlyPayout, "Transaction exceeds the max payout");
        require(_addr != Ownable.owner, "Buyback form can not be filled in by the owner of the smart contract");
        _;
    }

    /**
    * @dev Function that adds an address to the participants list.
    * @param _addr Address to be added to the list.
    */
    function addParticipantIfNotExists(address _addr) private isNotFrozen() {
        if (participantIndices[_addr] <= 0) {
            participantIndices[_addr] = (participantList.length+1);
            participantList.push(_addr);
        }
    }

    /**
    * @dev Function that returns the participants list.
    * @return participantList List of participants that have Leasjes.
    */
    function getParticipants() public view returns(address[] addresses) {
        return participantList;
    }

    /**
    * @dev Function that returns the amount of participants in the participants list.
    * @return count Number of participants with Leasjes.
    */
    function getParticipantCount() public view returns(uint count) {
        return participantList.length;
    }

    /**
    * @dev Function that returns the index of an address in the participants list.
    * @param _addr Address of a participant.
    * @return index Position of participant in the participant list.
    */
    function getParticipantIndex(address _addr) public view returns(uint index) {
        require(participantIndices[_addr] > 0, "Participant not found in the participants list");
        return participantIndices[_addr];
    }

    /**
    * @dev Function that is called when a user or another contract wants to transfer funds.
    * Overrides transfer function in ERC223_Token.
    * @param _to Address to which the transfer is made.
    * @param _value Value in Leasje involved in the transfer, in Ray format.
    * @return success True if transfer succeeded. If there is any error, the function will be reverted.
    */
    function transfer(address _to, uint _value) public isNotFrozen() returns (bool success) {
        return transfer(_to, _value, "", "");
    }

    /**
    * @dev Function that is called when a user or another contract wants to transfer funds.
    * Overrides transfer function in ERC223_Token.
    * @param _to Address to which the transfer is made.
    * @param _value Value in Leasje involved in the transfer, in Ray format.
    * @param _data Optional data that can be transfered with the transaction.
    * @return success True if transfer succeeded. If there is any error, the function will be reverted.
    */
    function transfer(address _to, uint _value, bytes _data) public isNotFrozen() returns (bool success) {
        return transfer(_to, _value, "", "");
    }

    /**
    * @dev Function that is called when a user or another contract wants to transfer funds.
    * Overrides transfer function in ERC223_Token, adds the addAddress(_to) function.
    * @param _to Address to which the transfer is made.
    * @param _value Value in Leasje involved in the transfer, in Ray format.
    * @param _data Optional data that can be transfered with the transaction.
    * @param _customFallback Optional callback message that can be transfered with the transaction.
    * @return success True if transfer succeeded. If there is any error, the function will be reverted.
    */
    function transfer(
        address _to,
        uint _value,
        bytes _data,
        string _customFallback) public isNotFrozen() isWhitelisted(_to) isValidTransfer(_to, _value) returns (bool success) {

        _data = "";
        _customFallback = "";

        if (isContract(_to)) {
            if (balanceOf(msg.sender) < _value) revert();
            balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
            balances[_to] = safeAdd(balanceOf(_to), _value);
            assert(_to.call.value(0)(abi.encodePacked(_customFallback), msg.sender, _value, _data));
            emit Transfer(msg.sender, _to, _value);
            addParticipantIfNotExists(_to);
            return true;
        }
        else {
            return transferToAddress(_to, _value, _data);
        }
    }

    /**
    * @dev Function that is called when transaction target is an address.
    * Overrides transferToAddress function in ERC223_Token, adds the addAddress(_to) function.
    * @param _to Address to which the transfer is made.
    * @param _value Value in Leasje involved in the transfer, in Ray format.
    * @param _data Optional data that can be transfered with the transaction.
    * @return success True if transfer succeeded. If there is any error, the function will be reverted.
    */
    function transferToAddress(address _to, uint _value, bytes _data) private isNotFrozen() returns (bool success) {
        if (balanceOf(msg.sender) < _value) revert();
        balances[msg.sender] = safeSub(balanceOf(msg.sender), _value);
        balances[_to] = safeAdd(balanceOf(_to), _value);
        emit Transfer(msg.sender, _to, _value);
        addParticipantIfNotExists(_to);
        return true;
    }

    /**
    * @dev Adds single address to whitelist.
    * @param _addr Address to be added to the whitelist.
    */
    function addToWhitelist(address _addr) public onlyOwner isNotFrozen() {
        whitelist[_addr] = true;
    }

    /**
    * @dev Removes single address from whitelist.
    * @param _addr Address to be removed to the whitelist.
    */
    function removeFromWhitelist(address _addr) public onlyOwner isNotFrozen() {
        whitelist[_addr] = false;
    }

    /**
    * @dev Checks if a user is whitelisted.
    * @param _addr Address to be checked.
    * @return whitelisted_ True if the address is whitelisted, false if the address is not whitelisted.
    */
    function whitelisted(address _addr) public view returns(bool whitelisted_) {
        whitelisted_ = whitelist[_addr];
    }

    /**
    * @dev Get the price of the token for a period.
    * @param _payoutPeriod Period to be checked.
    * @return price_ Price of the token for the given payoutperiod, in Ray format.
    */
    function getPrice(uint256 _payoutPeriod) public view returns(uint256 price_) {
        require(price[_payoutPeriod] > 0, "There is no price determined for the given payout period (yet)");
        price_ = price[_payoutPeriod];
    }

    /**
    * @dev Get the total payout in Leasje for an address and period.
    * @param _addr Address of which the payout is checked.
    * @param _payoutPeriod Period to be checked.
    * @return payout_ Total payout in Leasje for the given payoutperiod and address, in Ray format.
    */
    function getPayout(address _addr, uint256 _payoutPeriod) public view returns(uint256 payout_) {
        payout_ = payouts[_addr][_payoutPeriod];
    }

    /**
    * @dev Set the interest rate of the assets that are leased.
    * Divides the input by 120000 (100*100*12), to calculate the monthly interest rate in percentage.
    * @param _interestRate The interest rate in cents per year. E.g. if the interest rate is 6,52%, the param _interestRate should be 652.
    */
    function setInterestRate(uint256 _interestRate) public onlyOwner isNotFrozen() {
        RayInterestMonthly = rdiv(convertToRay(_interestRate), convertToRay(120000));
    }

    /**
    * @dev Set the price per Leasje for a given payoutperiod.
    * @param _payoutPeriod The payoutperiod of which the price is set.
    */
    function setPrice(uint256 _payoutPeriod) private onlyOwner isNotFrozen() {
        uint256 _redemption;
        uint256 _price;

        // Get price
        (_redemption, _price) = getPriceForPeriod(_payoutPeriod);

        // Set the remaining payout for this payout period
        setPayoutRemaining(_redemption);

        // Set price
        price[_payoutPeriod] = _price;
    }

    /**
    * @dev Set the payout remaining for the current payoutperiod.
    * The payout remaining is defined as the initial redemption that was paid for that payout period,
    * minus the number of Leasjes that is already sold during the payout period.
    * @param _payoutRemaining The payout remaining that is set, in Ray format.
    */
    function setPayoutRemaining(uint256 _payoutRemaining) private onlyOwner isNotFrozen() {
        payoutRemaining = _payoutRemaining;
    }

    /**
    * @dev Function that is called at the end of the payout period, to start a new payout period.
    * Reverts if the payoutperiod has reached the total number of periods.
    * @param _payoutPeriod the payoutperiod to be set, 999 if you just want to increase the payoutPeriod by 1.
    */
    function newPayoutPeriod(uint256 _payoutPeriod) public onlyOwner isNotFrozen() {

        // Check if RayInterestMonthly is set
        require(RayInterestMonthly > 0, "Monthly interest rate is not set");

        // Check if payoutPeriod is smaller than the maximum payoutPeriod
        require(((_payoutPeriod < numberOfPeriods) || _payoutPeriod == 999 ), "Payout period should be smaller than the maximum payout period");

        // Set payout period number
        if(_payoutPeriod == 999){
            payoutPeriod = add(payoutPeriod, 1);
        } else {
            payoutPeriod = _payoutPeriod;
        }

        // Set the new price for next payoutPeriod
        setPrice(payoutPeriod);
    }

    /**
    * @dev Function is called when a user fills in the buyback form.
    * @param _numberOfLeasjes Number of Leasjes that is paid by the address, in Ray format.
    */
    function offerToBuyback(uint256 _numberOfLeasjes) public isNotFrozen() isWhitelisted(msg.sender) isValidPayout(msg.sender, _numberOfLeasjes) {

        // Burn Leasjes
        if(burnPercentage == 100){
            burn(msg.sender, _numberOfLeasjes);
        } else {
            burn(msg.sender, rmul(rdiv(convertToRay(burnPercentage), convertToRay(100)), _numberOfLeasjes));
            transfer(Ownable.owner, rmul(rdiv(safeSub(convertToRay(100), convertToRay(burnPercentage)), convertToRay(100)), _numberOfLeasjes));
        }

        // Decrease payoutRemaining with _value
        payoutRemaining = safeSub(payoutRemaining, _numberOfLeasjes);

        // Add to payouts
        payouts[msg.sender][payoutPeriod] = safeAdd(getPayout(msg.sender, payoutPeriod), _numberOfLeasjes);

        // Emit Payout event
        emit Payout(msg.sender, _numberOfLeasjes);
    }

    /**
    * @dev Function that freezes the contract.
    */
    function freezeContract(bool _frozen) public onlyOwner {
        contractIsFrozen = _frozen;
    }

    /**
    * @dev Burns a specific amount of tokens.
    * @param _addr The address from which the tokens are burned.
    * @param _value The amount of token to be burned, in Ray format.
    */
    function burn(address _addr, uint256 _value) private {
        require(_value <= balanceOf(_addr), "Value exceed the balance of the address");
        balances[_addr] = safeSub(balanceOf(_addr),_value);
        totalSupply = safeSub(totalSupply, _value);
        emit Burn(_addr, _value);
        emit Transfer(_addr, address(0), _value);
    }
}
