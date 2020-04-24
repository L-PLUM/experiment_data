/**
 *Submitted for verification at Etherscan.io on 2019-08-12
*/

pragma solidity >=0.4.0 <0.7.0;

/**
 * Saft maths
 */
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }

    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }

    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }

    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
 }

/**
 * Owned contract
 */
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }

    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

/**
 * ERC20 Token Standard Interface
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 */
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

/**
 * Linear Vesting Contract
 */
contract SOTokenVesting is Owned {
    using SafeMath for uint;

    struct VestingSchedule {
        uint startTimeInSec;
        uint cliffTimeInSec;
        uint endTimeInSec;
        uint totalAmount;
        uint totalAmountWithdrawn;
        address depositor;
        bool isConfirmed;
    }

    /// each address has its own vesting schedule.
    /// address can be changed
    mapping(address => VestingSchedule) public schedules;
    mapping(address => address) public addressChangeRequests;

    ERC20Interface public vestingToken;

    event VestingScheduleRegistered(
        address indexed registeredAddress,
        address depositor,
        uint startTimeInSec,
        uint cliffTimeInSec,
        uint endTimeInSec,
        uint totalAmount
    );
    event VestingScheduleConfirmed(
        address indexed registeredAddress,
        address depositor,
        uint startTimeInSec,
        uint cliffTimeInSec,
        uint endTimeInSec,
        uint totalAmount
    );
    event AddressChangeRequested(
        address indexed oldRegisteredAddress,
        address indexed newRegisteredAddress
    );
    event AddressChangeConfirmed(
        address indexed oldRegisteredAddress,
        address indexed newRegisteredAddress
    );
    event VestingEndedByOwner(
        address indexed registeredAddress,
        uint amountWithdrawn,
        uint amountRefunded
    );
    event Withdrawal(address indexed registeredAddress, uint amountWithdrawn);

    /// @param tokenContractAddress Token to be vested
    constructor(address tokenContractAddress) public {
        vestingToken = ERC20Interface(tokenContractAddress);
    }

    modifier addressRegistered(address target) {
        VestingSchedule storage vestingSchedule = schedules[target];
        require(vestingSchedule.depositor != address(0));
        _;
    }

    modifier addressNotRegistered(address target) {
        VestingSchedule storage vestingSchedule = schedules[target];
        require(vestingSchedule.depositor == address(0));
        _;
    }

    modifier vestingScheduleConfirmed(address target) {
        VestingSchedule storage vestingSchedule = schedules[target];
        require(vestingSchedule.isConfirmed);
        _;
    }

    modifier vestingScheduleNotConfirmed(address target) {
        VestingSchedule storage vestingSchedule = schedules[target];
        require(!vestingSchedule.isConfirmed);
        _;
    }

    modifier pendingAddressChangeRequest(address target) {
        require(addressChangeRequests[target] != address(0));
        _;
    }

    modifier pastCliffTime(address target) {
        VestingSchedule storage vestingSchedule = schedules[target];
        require(block.timestamp > vestingSchedule.cliffTimeInSec);
        _;
    }

    modifier validVestingScheduleTimes(
        uint startTimeInSec,
        uint cliffTimeInSec,
        uint endTimeInSec
    )
    {
        require(cliffTimeInSec >= startTimeInSec);
        require(endTimeInSec >= cliffTimeInSec);
        _;
    }

    modifier addressNotNull(address target) {
        require(target != address(0));
        _;
    }

    /// @dev Registers a vesting schedule to an address.
    /// @param _addressToRegister The address that is allowed to
    ///        withdraw vested tokens for this schedule.
    /// @param _depositor Address that will be depositing vesting token.
    /// @param _startTimeInSec The time in seconds that vesting began.
    /// @param _cliffTimeInSec The time in seconds that tokens become withdrawable.
    /// @param _endTimeInSec The time in seconds that vesting ends.
    /// @param _totalAmount The total amount of tokens that the registered
    ///        address can withdraw by the end of the vesting period.
    function registerVestingSchedule(
        address _addressToRegister,
        address _depositor,
        uint _startTimeInSec,
        uint _cliffTimeInSec,
        uint _endTimeInSec,
        uint _totalAmount
    )
        public
        onlyOwner
        addressNotNull(_depositor)
        vestingScheduleNotConfirmed(_addressToRegister)
        validVestingScheduleTimes(
            _startTimeInSec,
            _cliffTimeInSec,
            _endTimeInSec
        )
    {
        schedules[_addressToRegister] = VestingSchedule({
            startTimeInSec: _startTimeInSec,
            cliffTimeInSec: _cliffTimeInSec,
            endTimeInSec: _endTimeInSec,
            totalAmount: _totalAmount,
            totalAmountWithdrawn: 0,
            depositor: _depositor,
            isConfirmed: false
        });

        emit VestingScheduleRegistered(
            _addressToRegister,
            _depositor,
            _startTimeInSec,
            _cliffTimeInSec,
            _endTimeInSec,
            _totalAmount
        );
    }

    /// @dev Confirms a vesting schedule and deposits necessary tokens.
    ///      Throws if deposit fails or schedules do not match.
    /// @param _startTimeInSec The time in seconds that vesting began.
    /// @param _cliffTimeInSec The time in seconds that tokens become withdrawable.
    /// @param _endTimeInSec The time in seconds that vesting ends.
    /// @param _totalAmount The total amount of tokens that the registered
    ///        address can withdraw by the end of the vesting period.
    function confirmVestingSchedule(
        uint _startTimeInSec,
        uint _cliffTimeInSec,
        uint _endTimeInSec,
        uint _totalAmount
    )
        public
        addressRegistered(msg.sender)
        vestingScheduleNotConfirmed(msg.sender)
    {
        VestingSchedule storage vestingSchedule = schedules[msg.sender];

        require(vestingSchedule.startTimeInSec == _startTimeInSec);
        require(vestingSchedule.cliffTimeInSec == _cliffTimeInSec);
        require(vestingSchedule.endTimeInSec == _endTimeInSec);
        require(vestingSchedule.totalAmount == _totalAmount);

        vestingSchedule.isConfirmed = true;

        require(vestingToken.transferFrom(
            vestingSchedule.depositor,
            address(this),
            _totalAmount
        ));
        // depositor need to first "approve" this smart contract address
        // in ERC20 token contract so this contract can do "transferFrom"

        emit VestingScheduleConfirmed(
            msg.sender,
            vestingSchedule.depositor,
            _startTimeInSec,
            _cliffTimeInSec,
            _endTimeInSec,
            _totalAmount
        );
    }

    /// @dev Allows a registered address to request an address change.
    /// @param _newRegisteredAddress Desired address to update to.
    function requestAddressChange(address _newRegisteredAddress)
        public
        vestingScheduleConfirmed(msg.sender)
        addressNotRegistered(_newRegisteredAddress)
        addressNotNull(_newRegisteredAddress)
    {
        addressChangeRequests[msg.sender] = _newRegisteredAddress;
        emit AddressChangeRequested(msg.sender, _newRegisteredAddress);
    }

    /// @dev Confirm an address change and
    ///      migrate vesting schedule to new address.
    /// @param _oldRegisteredAddress Current registered address.
    /// @param _newRegisteredAddress Address to migrate vesting schedule to.
    function confirmAddressChange(
        address _oldRegisteredAddress,
        address _newRegisteredAddress
    )
        public
        onlyOwner
        pendingAddressChangeRequest(_oldRegisteredAddress)
        addressNotRegistered(_newRegisteredAddress)
    {
        address newRegisteredAddress =
            addressChangeRequests[_oldRegisteredAddress];
        require(newRegisteredAddress == _newRegisteredAddress);
        /// prevents race condition

        VestingSchedule memory vestingSchedule =
            schedules[_oldRegisteredAddress];
        schedules[newRegisteredAddress] = vestingSchedule;

        delete schedules[_oldRegisteredAddress];
        delete addressChangeRequests[_oldRegisteredAddress];

        emit AddressChangeConfirmed(
            _oldRegisteredAddress,
            _newRegisteredAddress
        );
    }

    /// @dev Allows contract owner to terminate a vesting schedule,
    ///      transfering remaining vested tokens to the registered address
    ///      and refunding owner with remaining tokens.
    /// @param _addressToEnd Address that is currently registered to
    ///        the vesting schedule that will be closed.
    /// @param _addressToRefund Address that will receive unvested tokens.
    function endVesting(address _addressToEnd, address _addressToRefund)
        public
        onlyOwner
        vestingScheduleConfirmed(_addressToEnd)
        addressNotNull(_addressToRefund)
    {
        VestingSchedule storage vestingSchedule = schedules[_addressToEnd];

        uint amountWithdrawable = 0;
        uint amountRefundable = 0;

        if (block.timestamp < vestingSchedule.cliffTimeInSec) {
            amountRefundable = vestingSchedule.totalAmount;
        } else {
            uint totalAmountVested = getTotalAmountVested(vestingSchedule);
            amountWithdrawable = totalAmountVested.sub(
                vestingSchedule.totalAmountWithdrawn
            );
            amountRefundable = vestingSchedule.totalAmount.sub(
                totalAmountVested
            );
        }

        delete schedules[_addressToEnd];
        require(amountWithdrawable == 0 || vestingToken.transfer(
            _addressToEnd,
            amountWithdrawable
        ));
        require(amountRefundable == 0 || vestingToken.transfer(
            _addressToRefund,
            amountRefundable
        ));

        emit VestingEndedByOwner(
            _addressToEnd,
            amountWithdrawable,
            amountRefundable
        );
    }

    /// @dev Allows a registered address to withdraw tokens
    ///      that have already been vested.
    function withdraw()
        public
        vestingScheduleConfirmed(msg.sender)
        pastCliffTime(msg.sender)
    {
        VestingSchedule storage vestingSchedule = schedules[msg.sender];

        uint totalAmountVested = getTotalAmountVested(vestingSchedule);
        uint amountWithdrawable = totalAmountVested.sub(
            vestingSchedule.totalAmountWithdrawn
        );
        vestingSchedule.totalAmountWithdrawn = totalAmountVested;

        if (amountWithdrawable > 0) {
            require(vestingToken.transfer(msg.sender, amountWithdrawable));
            emit Withdrawal(msg.sender, amountWithdrawable);
        }
    }

    /// @dev Calculates the total tokens that have been vested for a
    ///      vesting schedule, assuming the schedule is past the cliff.
    /// @param vestingSchedule Vesting schedule used to calculate vested tokens.
    /// @return Total tokens vested for a vesting schedule.
    function getTotalAmountVested(VestingSchedule memory vestingSchedule)
        internal
        view
        returns (uint)
    {
        if (block.timestamp >= vestingSchedule.endTimeInSec) {
            return vestingSchedule.totalAmount;
        }
        uint timeSinceStartInSec =
            block.timestamp.sub(vestingSchedule.startTimeInSec);
        uint totalVestingTimeInSec =
            vestingSchedule.endTimeInSec.sub(vestingSchedule.startTimeInSec);
        uint totalAmountVested =
            (vestingSchedule.totalAmount.mul(timeSinceStartInSec)).div(
                totalVestingTimeInSec
            );

        return totalAmountVested;
    }
}
