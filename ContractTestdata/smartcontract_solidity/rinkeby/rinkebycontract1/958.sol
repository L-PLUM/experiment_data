/**
 *Submitted for verification at Etherscan.io on 2019-02-01
*/

pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: /home/igor/Development/kyodo/packages/kyodo-contracts/lib/BokkyPooBahsDateTimeLibrary/contracts/BokkyPooBahsDateTimeLibrary.sol

// ----------------------------------------------------------------------------
// BokkyPooBah's DateTime Library v1.00
//
// A gas-efficient Solidity date and time library
//
// https://github.com/bokkypoobah/BokkyPooBahsDateTimeLibrary
//
// Tested date range 1970/01/01 to 2345/12/31
//
// Conventions:
// Unit      | Range         | Notes
// :-------- |:-------------:|:-----
// timestamp | >= 0          | Unix timestamp, number of seconds since 1970/01/01 00:00:00 UTC
// year      | 1970 ... 2345 |
// month     | 1 ... 12      |
// day       | 1 ... 31      |
// hour      | 0 ... 23      |
// minute    | 0 ... 59      |
// second    | 0 ... 59      |
// dayOfWeek | 1 ... 7       | 1 = Monday, ..., 7 = Sunday
//
//
// Enjoy. (c) BokkyPooBah / Bok Consulting Pty Ltd 2018.
//
// GNU Lesser General Public License 3.0
// https://www.gnu.org/licenses/lgpl-3.0.en.html
// ----------------------------------------------------------------------------

library BokkyPooBahsDateTimeLibrary {

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;

    uint constant DOW_MON = 1;
    uint constant DOW_TUE = 2;
    uint constant DOW_WED = 3;
    uint constant DOW_THU = 4;
    uint constant DOW_FRI = 5;
    uint constant DOW_SAT = 6;
    uint constant DOW_SUN = 7;

    // ------------------------------------------------------------------------
    // Calculate the number of days from 1970/01/01 to year/month/day using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and subtracting the offset 2440588 so that 1970/01/01 is day 0
    //
    // days = day
    //      - 32075
    //      + 1461 * (year + 4800 + (month - 14) / 12) / 4
    //      + 367 * (month - 2 - (month - 14) / 12 * 12) / 12
    //      - 3 * ((year + 4900 + (month - 14) / 12) / 100) / 4
    //      - offset
    // ------------------------------------------------------------------------
    function _daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {
        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint(__days);
    }

    // ------------------------------------------------------------------------
    // Calculate year/month/day from the number of days since 1970/01/01 using
    // the date conversion algorithm from
    //   http://aa.usno.navy.mil/faq/docs/JD_Formula.php
    // and adding the offset 2440588 so that 1970/01/01 is day 0
    //
    // int L = days + 68569 + offset
    // int N = 4 * L / 146097
    // L = L - (146097 * N + 3) / 4
    // year = 4000 * (L + 1) / 1461001
    // L = L - 1461 * year / 4 + 31
    // month = 80 * L / 2447
    // dd = L - 2447 * month / 80
    // L = month / 11
    // month = month + 2 - 12 * L
    // year = 100 * (N - 49) + year + L
    // ------------------------------------------------------------------------
    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {
        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampFromDate(uint year, uint month, uint day) internal pure returns (uint timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }
    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (uint timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second;
    }
    function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function timestampToDateTime(uint timestamp) internal pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(uint year, uint month, uint day) internal pure returns (bool valid) {
        if (year >= 1970 && month > 0 && month <= 12) {
            uint daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }
    function isValidDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (bool valid) {
        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }
    function isLeapYear(uint timestamp) internal pure returns (bool leapYear) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }
    function _isLeapYear(uint year) internal pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }
    function isWeekDay(uint timestamp) internal pure returns (bool weekDay) {
        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }
    function isWeekEnd(uint timestamp) internal pure returns (bool weekEnd) {
        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }
    function getDaysInMonth(uint timestamp) internal pure returns (uint daysInMonth) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }
    function _getDaysInMonth(uint year, uint month) internal pure returns (uint daysInMonth) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }
    // 1 = Monday, 7 = Sunday
    function getDayOfWeek(uint timestamp) internal pure returns (uint dayOfWeek) {
        uint _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = (_days + 3) % 7 + 1;
    }

    function getYear(uint timestamp) internal pure returns (uint year) {
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getMonth(uint timestamp) internal pure returns (uint month) {
        uint year;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getDay(uint timestamp) internal pure returns (uint day) {
        uint year;
        uint month;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getHour(uint timestamp) internal pure returns (uint hour) {
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }
    function getMinute(uint timestamp) internal pure returns (uint minute) {
        uint secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }
    function getSecond(uint timestamp) internal pure returns (uint second) {
        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = (month - 1) % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }
    function addMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }
    function addSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {
        uint year;
        uint month;
        uint day;
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = yearMonth % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }
    function subMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }
    function subSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _years) {
        require(fromTimestamp <= toTimestamp);
        uint fromYear;
        uint fromMonth;
        uint fromDay;
        uint toYear;
        uint toMonth;
        uint toDay;
        (fromYear, fromMonth, fromDay) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (toYear, toMonth, toDay) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }
    function diffMonths(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _months) {
        require(fromTimestamp <= toTimestamp);
        uint fromYear;
        uint fromMonth;
        uint fromDay;
        uint toYear;
        uint toMonth;
        uint toDay;
        (fromYear, fromMonth, fromDay) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (toYear, toMonth, toDay) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }
    function diffDays(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _days) {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }
    function diffHours(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _hours) {
        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }
    function diffMinutes(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _minutes) {
        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }
    function diffSeconds(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _seconds) {
        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}

// File: /home/igor/Development/kyodo/packages/kyodo-contracts/lib/colonyNetwork/contracts/IRecovery.sol

/*
  This file is part of The Colony Network.

  The Colony Network is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  The Colony Network is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with The Colony Network. If not, see <http://www.gnu.org/licenses/>.
*/

pragma solidity ^0.4.23;
pragma experimental "v0.5.0";


/// @title Recovery interface
/// @notice All publicly available functions are available here and registered to work with EtherRouter Network contract
contract IRecovery {
/// @notice Put colony network mining into recovery mode.
  /// Can only be called by user with recovery role.
  function enterRecoveryMode() public;

  /// @notice Exit recovery mode, can be called by anyone if enough whitelist approvals are given.
  function exitRecoveryMode() public;

  /// @notice Indicate approval to exit recovery mode.
  /// Can only be called by user with recovery role.
  function approveExitRecovery() public;

  /// @notice Is colony network in recovery mode
  /// @return inRecoveryMode Return true if recovery mode is active, false otherwise
  function isInRecoveryMode() public view returns (bool inRecoveryMode);

  /// @notice Set new colony recovery role.
  /// Can be called by founder.
  /// @param _user User we want to give a recovery role to
  function setRecoveryRole(address _user) public;

  /// @notice Remove colony recovery role.
  /// Can only be called by founder role.
  /// @param _user User we want to remove recovery role from
  function removeRecoveryRole(address _user) public;

  /// @notice Return number of recovery roles.
  /// @return numRoles Number of users with the recovery role (excluding founder)
  function numRecoveryRoles() public view returns(uint64 numRoles);

  /// @notice Update value of arbitrary storage variable.
  /// Can only be called by user with recovery role.
  /// @param _slot Uint address of storage slot to be updated
  /// @param _value Bytes32 word of data to be set
  /// @dev certain critical variables are protected from editing in this function
  function setStorageSlotRecovery(uint256 _slot, bytes32 _value) public;

  /// @notice Check whether the supplied slot is a protected variable specific to this contract
  /// @param _slot The storage slot number to check.
  /// @dev No return value, but should throw if protected.
  /// @dev This is public, but is only expected to be called from ContractRecovery; no need to
  /// @dev expose this to any users.
  function checkNotAdditionalProtectedVariable(uint256 _slot) public view;
}

// File: /home/igor/Development/kyodo/packages/kyodo-contracts/lib/colonyNetwork/contracts/ColonyDataTypes.sol

/*
  This file is part of The Colony Network.

  The Colony Network is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  The Colony Network is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with The Colony Network. If not, see <http://www.gnu.org/licenses/>.
*/

pragma solidity ^0.4.23;


contract ColonyDataTypes {
  // Events
  /// @notice Event logged when the Colony token is set
  /// @param token The newly set token address
  event ColonyTokenSet(address token);

  /// @notice Event logged when Colony is initialised
  /// @param colonyNetwork The Colony Network address
  event ColonyInitialised(address colonyNetwork);

  /// @notice Event logged when Colony is initially bootstrapped
  /// @param users Array of address bootstraped with reputation
  /// @param amounts Amounts of reputation/tokens for every address
  event ColonyBootstrapped(address[] users, int[] amounts);

  /// @notice Event logged when colony is upgraded
  /// @param oldVersion The previous colony version
  /// @param newVersion The new colony version upgraded to
  event ColonyUpgraded(uint256 oldVersion, uint256 newVersion);

  /// @notice Event logged when the colony founder role is changed
  /// @param oldFounder The current founder delegating the role away
  /// @param newFounder User who is new new colony founder
  event ColonyFounderRoleSet(address oldFounder, address newFounder);

  /// @notice Event logged when a new user is assigned the colony admin role
  /// @param user The newly added colony admin user address
  event ColonyAdminRoleSet(address user);

  /// @notice Event logged when an existing colony admin is removed the colony admin role
  /// @param user The removed colony admin user address
  event ColonyAdminRoleRemoved(address user);

  /// @notice Event logged when colony funds, either tokens or ether, has been moved between funding pots
  /// @param fromPot The source funding pot
  /// @param toPot The targer funding pot
  /// @param amount The amount that was transferred
  /// @param token The token address being transferred
  event ColonyFundsMovedBetweenFundingPots(uint256 fromPot, uint256 toPot, uint256 amount, address token);

  /// @notice Event logged when colony funds are moved to the top-level domain pot
  /// @param token The token address
  /// @param fee The fee deducted for rewards
  /// @param payoutRemainder The remaining funds moved to the top-level domain pot
  event ColonyFundsClaimed(address token, uint256 fee, uint256 payoutRemainder);

  /// @notice Event logged when a new reward payout cycle has started
  /// @param rewardPayoutId The reward payout cycle id
  event RewardPayoutCycleStarted(uint256 rewardPayoutId);

  /// @notice Event logged when the reward payout cycle has ended
  /// @param rewardPayoutId The reward payout cycle id
  event RewardPayoutCycleEnded(uint256 rewardPayoutId);

  /// @notice Event logged when reward payout is claimed
  /// @param rewardPayoutId The reward payout cycle id
  /// @param user The user address who received the reward payout
  /// @param fee The fee deducted from payout
  /// @param rewardRemainder The remaining reward amount paid out to user
  event RewardPayoutClaimed(uint256 rewardPayoutId, address user, uint256 fee, uint256 rewardRemainder);

  /// @notice Event logged when the colony reward inverse is set
  /// @param rewardInverse The reward inverse value
  event ColonyRewardInverseSet(uint256 rewardInverse);

  /// @notice Event logged when a new task is added
  /// @param taskId The newly added task id
  event TaskAdded(uint256 taskId);

  /// @notice Event logged when a task's specification hash changes
  /// @param taskId Id of the task
  /// @param specificationHash New specification hash of the task
  event TaskBriefSet(uint256 taskId, bytes32 specificationHash);

  /// @notice Event logged when a task's due date changes
  /// @param taskId Id of the task
  /// @param dueDate New due date of the task
  event TaskDueDateSet(uint256 taskId, uint256 dueDate);

  /// @notice Event logged when a task's domain changes
  /// @param taskId Id of the task
  /// @param domainId New domain id of the task
  event TaskDomainSet(uint256 taskId, uint256 domainId);

  /// @notice Event logged when a task's skill changes
  /// @param taskId Id of the task
  /// @param skillId New skill id of the task
  event TaskSkillSet(uint256 taskId, uint256 skillId);

  /// @notice Event logged when a task's role user changes
  /// @param taskId Id of the task
  /// @param role Role of the user
  /// @param user User that fulfills the designated role
  event TaskRoleUserSet(uint256 taskId, uint8 role, address user);

  /// @notice Event logged when a task payout changes
  /// @param taskId Id of the task
  /// @param role Task role whose payout is being changed
  /// @param token Token of the payout funding
  /// @param amount Amount of the payout funding
  event TaskPayoutSet(uint256 taskId, uint8 role, address token, uint256 amount);

  /// @notice Event logged when a deliverable has been submitted for a task
  /// @param taskId Id of the task
  /// @param deliverableHash Hash of the work performed
  event TaskDeliverableSubmitted(uint256 taskId, bytes32 deliverableHash);

  /// @notice Event logged when a task has been completed. This is either because the dueDate has passed
  /// and the manager closed the task, or the worker has submitted the deliverable. In the
  /// latter case, TaskDeliverableSubmitted will also be emitted.
  event TaskCompleted(uint256 taskId);

  /// @notice Event logged when the rating of a role was revealed
  /// @param taskId Id of the task
  /// @param role Role that got rated
  /// @param rating Rating the role received
  event TaskWorkRatingRevealed(uint256 taskId, uint8 role, uint8 rating);

  /// @notice Event logged when a task has been finalized
  /// @param taskId Id of the finalized task
  event TaskFinalized(uint256 taskId);

  /// @notice Event logged when a task payout is claimed
  /// @param taskId Id of the task
  /// @param role Task role for which the payout is being claimed
  /// @param token Token of the payout claim
  /// @param amount Amount of the payout claim
  event TaskPayoutClaimed(uint256 taskId, uint256 role, address token, uint256 amount);

  /// @notice Event logged when a task has been canceled
  /// @param taskId Id of the canceled task
  event TaskCanceled(uint256 taskId);

  /// @notice Event logged when a new Domain is added
  /// @param domainId Id of the newly-created Domain
  event DomainAdded(uint256 domainId);

  /// @notice Event logged when a new Pot is added
  /// @param potId Id of the newly-created Pot
  event PotAdded(uint256 potId);

  struct RewardPayoutCycle {
    // Reputation root hash at the time of reward payout creation
    bytes32 reputationState;
    // Colony wide reputation
    uint256 colonyWideReputation;
    // Total tokens at the time of reward payout creation
    uint256 totalTokens;
    // Amount alocated for reward payout
    uint256 amount;
    // Token in which a reward is paid out with
    address tokenAddress;
    // Time of creation (in seconds)
    uint256 blockTimestamp;
  }

  struct Task {
    bytes32 specificationHash;
    bytes32 deliverableHash;
    uint8 status;
    uint256 dueDate;
    uint256 payoutsWeCannotMake;
    uint256 potId;
    uint256 completionTimestamp;
    uint256 domainId;
    uint256[] skills;

    mapping (uint8 => Role) roles;
    // Maps task role ids (0,1,2..) to a token amount to be paid on task completion
    mapping (uint8 => mapping (address => uint256)) payouts;
  }

  enum TaskRatings { None, Unsatisfactory, Satisfactory, Excellent }

  struct Role {
    // Address of the user for the given role
    address user;
    // Whether the user failed to submit their rating
    bool rateFail;
    // Rating the user received
    TaskRatings rating;
  }

  struct RatingSecrets {
    uint256 count;
    uint256 timestamp;
    mapping (uint8 => bytes32) secret;
  }

  struct Pot {
    mapping (address => uint256) balance;
    uint256 taskId;
  }

  struct Domain {
    uint256 skillId;
    uint256 potId;
  }
}

// File: /home/igor/Development/kyodo/packages/kyodo-contracts/lib/colonyNetwork/contracts/IColony.sol

/*
  This file is part of The Colony Network.

  The Colony Network is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  The Colony Network is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with The Colony Network. If not, see <http://www.gnu.org/licenses/>.
*/

pragma solidity ^0.4.23;




/// @title Colony interface
/// @notice All publicly available functions are available here and registered to work with EtherRouter Network contract
contract IColony is ColonyDataTypes, IRecovery {
  // Implemented in DSAuth.sol
  /// @notice Get the `ColonyAuthority` for the colony
  /// @return colonyAuthority The `ColonyAuthority` contract address
  function authority() public view returns (address colonyAuthority);

  /// @notice Get the colony `owner` address. This should be 0x0 at all times
  /// @dev Used for testing.
  /// @return colonyOwner Address of the colony owner
  function owner() public view returns (address colonyOwner);

  // Implemented in Colony.sol
  /// @notice Get the Colony contract version
  /// Starts from 1 and is incremented with every deployed contract change
  /// @return colonyVersion Version number
  function version() public pure returns (uint256 colonyVersion);

  /// @notice Upgrades a colony to a new Colony contract version `_newVersion`
  /// @dev Downgrades are not allowed, i.e. `_newVersion` should be higher than the currect colony version
  /// @param _newVersion The target version for the upgrade
  function upgrade(uint _newVersion) public;

  /// @notice Returns the colony network address set on the Colony
  /// @dev The colonyNetworkAddress we read here is set once, during `initialiseColony`
  /// @return colonyNetworkAddress The address of Colony Network instance
  function getColonyNetworkAddress() public view returns (address);

  /// @notice Set the colony token. Secured function to authorised members
  /// @param _token Address of the token contract to use.
  /// Note that if the `mint` functionality is to be controlled through the colony,
  /// that control has to be transferred to the colony after this call
  function setToken(address _token) public;

  /// @notice Set new colony founder role.
  /// @dev There can only be one address assigned to founder role at a time.
  /// Whoever calls this function will lose their founder role
  /// Can be called by founder role.
  /// @param _user User we want to give an founder role to
  function setFounderRole(address _user) public;

  /// @notice Set new colony admin role.
  /// Can be called by founder role or admin role.
  /// @param _user User we want to give an admin role to
  function setAdminRole(address _user) public;

  /// @notice Remove colony admin.
  /// Can only be called by founder role.
  /// @param _user User we want to remove admin role from
  function removeAdminRole(address _user) public;

  /// @notice Check whether a given user has a given role for the colony.
  /// Calls the function of the same name on the colony's authority contract.
  /// @param _user The user whose role we want to check
  /// @param _role The role we want to check for
  function hasUserRole(address _user, uint8 _role) public view returns (bool hasRole);

  /// @notice Get the colony token
  /// @return tokenAddress Address of the token contract
  function getToken() public view returns (address tokenAddress);

  /// @notice Called once when the colony is created to initialise certain storage slot values
  /// @dev Sets the reward inverse to the uint max 2**256 - 1
  /// @param _address Address of the colony network
  function initialiseColony(address _address) public;

  /// @notice Allows the colony to bootstrap itself by having initial reputation and token `_amount` assigned to users `_users`
  /// This reputation is assigned in the colony-wide domain. Secured function to authorised members
  /// @dev Only allowed to be called when `taskCount` is 0 by authorized addresses
  /// @param _users Array of address to bootstrap with reputation
  /// @param _amount Amount of reputation/tokens for every address
  function bootstrapColony(address[] _users, int[] _amount) public;

  /// @notice Mint `_wad` amount of colony tokens. Secured function to authorised members
  /// @param _wad Amount to mint
  function mintTokens(uint256 _wad) public;

  /// @notice Register colony's ENS label
  /// @param colonyName The label to register.
  /// @param orbitdb The path of the orbitDB database associated with the colony name
  function registerColonyLabel(string colonyName, string orbitdb) public;

  /// @notice Add a colony domain, and its respective local skill under skill with id `_parentSkillId`
  /// New funding pot is created and associated with the domain here
  /// @param _parentDomainId Id of the domain under which the new one will be added
  /// @dev Adding new domains is currently retricted to one level only, i.e. `_parentDomainId` has to be the root domain id: 1
  function addDomain(uint256 _parentDomainId) public;

  /// @notice Get the domain's local skill and funding pot id
  /// @param _id Id of the domain which details to get
  /// @return skillId The domain "local" skill id
  /// @return potId The domain's funding pot id
  function getDomain(uint256 _id) public view returns (uint256 skillId, uint256 potId);

  /// @notice Get the number of domains in the colony
  /// @return count The domain count. Min 1 as the root domain is created at the same time as the colony
  function getDomainCount() public view returns (uint256 count);

  /// @notice Helper function that can be used by a client to verify the correctness of a patricia proof they have been supplied with.
  /// @param key The key of the element the proof is for.
  /// @param value The value of the element that the proof is for.
  /// @param branchMask The branchmask of the proof
  /// @param siblings The siblings of the proof
  /// @return isValid True if the proof is valid, false otherwise.
  /// @dev For more detail about branchMask and siblings, examine the PatriciaTree implementation
  /// While public, likely only to be used by the Colony contracts, as it checks that the user is proving their own
  /// reputation in the current colony. The `verifyProof` function can be used to verify any proof, though this function
  /// is not currently exposed on the Colony's EtherRouter.
  function verifyReputationProof(bytes key, bytes value, uint256 branchMask, bytes32[] siblings) public view returns (bool isValid);

  // Implemented in ColonyTask.sol
  /// @notice Make a new task in the colony. Secured function to authorised members
  /// @param _specificationHash Database identifier where the task specification is stored
  /// @param _domainId The domain where the task belongs
  /// @param _skillId The skill associated with the task, can set to 0 for no-op
  /// @param _dueDate The due date of the task, can set to 0 for no-op
  function makeTask(bytes32 _specificationHash, uint256 _domainId, uint256 _skillId, uint256 _dueDate) public;

  /// @notice Get the number of tasks in the colony
  /// @return count The task count
  function getTaskCount() public view returns (uint256 count);

  /// @notice Starts from 0 and is incremented on every co-reviewed task change via `executeTaskChange` call
  /// @param _id Id of the task
  /// @return nonce The current task change nonce value
  function getTaskChangeNonce(uint256 _id) public view returns (uint256 nonce);

  /// @notice Executes a task update transaction `_data` which is approved and signed by two of its roles (e.g. manager and worker)
  /// using the detached signatures for these users.
  /// @dev The Colony functions which require approval and the task roles to review these are set in `IColony.initialiseColony` at colony creation
  /// Upon successful execution the `taskChangeNonces` entry for the task is incremented
  /// @param _sigV recovery id
  /// @param _sigR r output of the ECDSA signature of the transaction
  /// @param _sigS s output of the ECDSA signature of the transaction
  /// @param _mode How the signature was generated - 0 for Geth-style (usual), 1 for Trezor-style (only Trezor does this)
  /// @param _value The transaction value, i.e. number of wei to be sent when the transaction is executed
  /// Currently we only accept 0 value transactions but this is kept as a future option
  /// @param _data The transaction data
  function executeTaskChange(
    uint8[] _sigV,
    bytes32[] _sigR,
    bytes32[] _sigS,
    uint8[] _mode,
    uint256 _value,
    bytes _data
    ) public;

  /// @notice Executes a task role update transaction `_data` which is approved and signed by two of addresses
  /// depending of which function we are calling. Allowed functions are `setTaskManagerRole`, `setTaskEvaluatorRole` and `setTaskWorkerRole`.
  /// Upon successful execution the `taskChangeNonces` entry for the task is incremented
  /// @param _sigV recovery id
  /// @param _sigR r output of the ECDSA signature of the transaction
  /// @param _sigS s output of the ECDSA signature of the transaction
  /// @param _mode How the signature was generated - 0 for Geth-style (usual), 1 for Trezor-style (only Trezor does this)
  /// @param _value The transaction value, i.e. number of wei to be sent when the transaction is executed
  /// Currently we only accept 0 value transactions but this is kept as a future option
  /// @param _data The transaction data
  function executeTaskRoleAssignment(
    uint8[] _sigV,
    bytes32[] _sigR,
    bytes32[] _sigS,
    uint8[] _mode,
    uint256 _value,
    bytes _data
    ) public;

  /// @notice Submit a hashed secret of the rating for work in task `_id` which was performed by user with task role id `_role`
  /// Allowed within 5 days period starting which whichever is first from either the deliverable being submitted or the dueDate been reached
  /// Allowed only for evaluator to rate worker and for worker to rate manager performance
  /// Once submitted ratings can not be changed or overwritten
  /// @param _id Id of the task
  /// @param _role Id of the role, as defined in `ColonyStorage` `MANAGER`, `EVALUATOR` and `WORKER` constants
  /// @param _ratingSecret `keccak256` hash of a salt and 0-50 rating score (in increments of 10, .e.g 0, 10, 20, 30, 40 or 50)
  /// Can be generated via `IColony.generateSecret` helper function
  function submitTaskWorkRating(uint256 _id, uint8 _role, bytes32 _ratingSecret) public;

  /// @notice Reveal the secret rating submitted in `IColony.submitTaskWorkRating` for task `_id` and task role with id `_role`
  /// Allowed within 5 days period starting which whichever is first from either both rating secrets being submitted
  /// (via `IColony.submitTaskWorkRating`) or the 5 day rating period expiring
  /// @dev Compares the `keccak256(_salt, _rating)` output with the previously submitted rating secret and if they match,
  /// sets the task role properties `rated` to `true` and `rating` to `_rating`
  /// @param _id Id of the task
  /// @param _role Id of the role, as defined in `ColonyStorage` `MANAGER`, `EVALUATOR` and `WORKER` constants
  /// @param _rating 0-50 rating score (in increments of 10, .e.g 0, 10, 20, 30, 40 or 50)
  /// @param _salt Salt value used to generate the rating secret
  function revealTaskWorkRating(uint256 _id, uint8 _role, uint8 _rating, bytes32 _salt) public;

  /// @notice Helper function used to generage consistently the rating secret using salt value `_salt` and value to hide `_value`
  /// @param _salt Salt value
  /// @param _value Value to hide
  /// @return secret `keccak256` hash of joint _salt and _value
  function generateSecret(bytes32 _salt, uint256 _value) public pure returns (bytes32 secret);

  /// @notice Get the `ColonyStorage.RatingSecrets` for task `_id`
  /// @param _id Id of the task
  /// @return nSecrets Number of secrets
  /// @return lastSubmittedAt Timestamp of the last submitted rating secret
  function getTaskWorkRatings(uint256 _id) public view returns (uint256 nSecrets, uint256 lastSubmittedAt);

  /// @notice Get the rating secret submitted for role `_role` in task `_id`
  /// @param _id Id of the task
  /// @param _role Id of the role, as defined in `ColonyStorage` `MANAGER`, `EVALUATOR` and `WORKER` constants
  /// @return secret Rating secret `bytes32` value
  function getTaskWorkRatingSecret(uint256 _id, uint8 _role) public view returns (bytes32 secret);

  /// @notice Assigning manager role
  /// Current manager and user we want to assign role to both need to agree
  /// User we want to set here also needs to be an admin
  /// @dev This function can only be called through `executeTaskRoleAssignment`
  /// @param _id Id of the task
  /// @param _user Address of the user we want to give a manager role to
  function setTaskManagerRole(uint256 _id, address _user) public;

  /// @notice Assigning evaluator role
  /// Can only be set if there is no one currently assigned to be an evaluator
  /// Manager of the task and user we want to assign role to both need to agree
  /// Managers can assign themselves to this role, if there is no one currently assigned to it
  /// @dev This function can only be called through `executeTaskRoleAssignment`
  /// @param _id Id of the task
  /// @param _user Address of the user we want to give a evaluator role to
  function setTaskEvaluatorRole(uint256 _id, address _user) public;

  /// @notice Assigning worker role
  /// Can only be set if there is no one currently assigned to be a worker
  /// Manager of the task and user we want to assign role to both need to agree
  /// @dev This function can only be called through `executeTaskRoleAssignment`
  /// @param _id Id of the task
  /// @param _user Address of the user we want to give a worker role to
  function setTaskWorkerRole(uint256 _id, address _user) public;

  /// @notice Removing evaluator role
  /// Agreed between manager and currently assigned evaluator
  /// @param _id Id of the task
  function removeTaskEvaluatorRole(uint256 _id) public;

  /// @notice Removing worker role
  /// Agreed between manager and currently assigned worker
  /// @param _id Id of the task
  function removeTaskWorkerRole(uint256 _id) public;

  /// @notice Set the skill for task `_id`
  /// @dev Currently we only allow one skill per task although we have provisioned for an array of skills in `Task` struct
  /// Allowed before a task is finalized
  /// @param _id Id of the task
  /// @param _skillId Id of the skill which has to be a global skill
  function setTaskSkill(uint256 _id, uint256 _skillId) public;

  /// @notice Set the domain for task `_id`
  /// @param _id Id of the task
  /// @param _domainId Id of the domain
  function setTaskDomain(uint256 _id, uint256 _domainId) public;

  /// @notice Set the hash for the task brief, aka task work specification, which identifies the task brief content in ddb
  /// Allowed before a task is finalized
  /// @param _id Id of the task
  /// @param _specificationHash Unique hash of the task brief in ddb
  function setTaskBrief(uint256 _id, bytes32 _specificationHash) public;

  /// @notice Set the due date on task `_id`. Allowed before a task is finalized
  /// @param _id Id of the task
  /// @param _dueDate Due date as seconds since unix epoch
  function setTaskDueDate(uint256 _id, uint256 _dueDate) public;

  /// @notice Submit the task deliverable, i.e. the output of the work performed for task `_id`
  /// Submission is allowed only to the assigned worker before the task due date. Submissions cannot be overwritten
  /// @dev Set the `task.deliverableHash` and `task.completionTimestamp` properties
  /// @param _id Id of the task
  /// @param _deliverableHash Unique hash of the task deliverable content in ddb
  function submitTaskDeliverable(uint256 _id, bytes32 _deliverableHash) public;

  /// @notice Submit the task deliverable for Worker and rating for Manager
  /// @dev Internally call `submitTaskDeliverable` and `submitTaskWorkRating` in sequence
  /// @param _id Id of the task
  /// @param _deliverableHash Unique hash of the task deliverable content in ddb
  /// @param _ratingSecret Rating secret for manager
  function submitTaskDeliverableAndRating(uint256 _id, bytes32 _deliverableHash, bytes32 _ratingSecret) public;

  /// @notice Called after task work rating is complete which closes the task and logs the respective reputation log updates
  /// Allowed to be called once per task. Secured function to authorised members
  /// @dev Set the `task.finalized` property to true
  /// @param _id Id of the task
  function finalizeTask(uint256 _id) public;

  /// @notice Cancel a task at any point before it is finalized. Secured function to authorised members
  /// Any funds assigned to its funding pot can be moved back to the domain via `IColony.moveFundsBetweenPots`
  /// @dev Set the `task.status` property to 1
  /// @param _id Id of the task
  function cancelTask(uint256 _id) public;

  /// @notice Mark a task as complete after the due date has passed.
  /// This allows the task to be rated and finalized (and funds recovered) even in the presence of a worker who has disappeared.
  /// Note that if the due date was not set, then this function will throw.
  /// @param _id Id of the task
  function completeTask(uint256 _id) public;

  /// @notice Get a task with id `_id`
  /// @param _id Id of the task
  /// @return specificationHash Task brief hash
  /// @return deliverableHash Task deliverable hash
  /// @return status Status property. 0 - Active. 1 - Cancelled. 2 - Finalized
  /// @return dueDate Due date
  /// @return payoutsWeCannotMake Number of payouts that cannot be completed with the current task funding
  /// @return potId Id of funding pot for task
  /// @return completionTimestamp Task completion timestamp
  /// @return domainId Task domain id, default is root colony domain with id 1
  /// @return skillIds Array of global skill ids assigned to task
  function getTask(uint256 _id) public view returns (
    bytes32 specificationHash,
    bytes32 deliverableHash,
    uint8 status,
    uint256 dueDate,
    uint256 payoutsWeCannotMake,
    uint256 potId,
    uint256 completionTimestamp,
    uint256 domainId,
    uint256[] skillIds
    );

  /// @notice Get the `Role` properties back for role `_role` in task `_id`
  /// @param _id Id of the task
  /// @param _role Id of the role, as defined in `ColonyStorage` `MANAGER`, `EVALUATOR` and `WORKER` constants
  /// @return user Address of the user for the given role
  /// @return rateFail Whether the user failed to rate their counterpart
  /// @return rating Rating the user received
  function getTaskRole(uint256 _id, uint8 _role) public view returns (address user, bool rateFail, uint8 rating);

  /// @notice Set the reward inverse to pay out from revenue. e.g. if the fee is 1% (or 0.01), set 100
  /// @param _rewardInverse The inverse of the reward
  function setRewardInverse(uint256 _rewardInverse) public;

  /// @notice Return 1 / the reward to pay out from revenue. e.g. if the fee is 1% (or 0.01), return 100
  /// @return rewardInverse The inverse of the reward
  function getRewardInverse() public view returns (uint256 rewardInverse);

  /// @notice Get payout amount in `_token` denomination for role `_role` in task `_id`
  /// @param _id Id of the task
  /// @param _role Id of the role, as defined in `ColonyStorage` `MANAGER`, `EVALUATOR` and `WORKER` constants
  /// @param _token Address of the token, `0x0` value indicates Ether
  /// @return amount Payout amount
  function getTaskPayout(uint256 _id, uint8 _role, address _token) public view returns (uint256 amount);

  /// @notice Get total payout amount in `_token` denomination for task `_id`
  /// @param _id Id of the task
  /// @param _token Address of the token, `0x0` value indicates Ether
  /// @return amount Payout amount
  function getTotalTaskPayout(uint256 _id, address _token) public view returns (uint256 amount);

  /// @notice Set `_token` payout for manager in task `_id` to `_amount`
  /// @param _id Id of the task
  /// @param _token Address of the token, `0x0` value indicates Ether
  /// @param _amount Payout amount
  function setTaskManagerPayout(uint256 _id, address _token, uint256 _amount) public;

  /// @notice Set `_token` payout for evaluator in task `_id` to `_amount`
  /// @param _id Id of the task
  /// @param _token Address of the token, `0x0` value indicates Ether
  /// @param _amount Payout amount
  function setTaskEvaluatorPayout(uint256 _id, address _token, uint256 _amount) public;

  /// @notice Set `_token` payout for worker in task `_id` to `_amount`
  /// @param _id Id of the task
  /// @param _token Address of the token, `0x0` value indicates Ether
  /// @param _amount Payout amount
  function setTaskWorkerPayout(uint256 _id, address _token, uint256 _amount) public;

  /// @notice Set `_token` payout for all roles in task `_id` to the respective amounts
  /// @dev Can only call if evaluator and worker are unassigned or manager, otherwise need signature
  /// @param _id Id of the task
  /// @param _token Address of the token, `0x0` value indicates Ether
  /// @param _managerAmount Payout amount for manager
  /// @param _evaluatorAmount Payout amount for evaluator
  /// @param _workerAmount Payout amount for worker
  function setAllTaskPayouts(uint256 _id, address _token, uint256 _managerAmount, uint256 _evaluatorAmount, uint256 _workerAmount) public;

  /// @notice Claim the payout in `_token` denomination for work completed in task `_id` by contributor with role `_role`
  /// Allowed only by the contributors themselves after task is finalized. Here the network receives its fee from each payout.
  /// Ether fees go straight to the Meta Colony whereas Token fees go to the Network to be auctioned off.
  /// @param _id Id of the task
  /// @param _role Id of the role, as defined in `ColonyStorage` `MANAGER`, `EVALUATOR` and `WORKER` constants
  /// @param _token Address of the token, `0x0` value indicates Ether
  function claimPayout(uint256 _id, uint8 _role, address _token) public;

  /// @notice Start next reward payout for `_token`. All funds in the reward pot for `_token` will become unavailable.
  /// All tokens will be locked, and can be unlocked by calling `waiveRewardPayout` or `claimRewardPayout`.
  /// @param _token Address of the token used for reward payout
  /// @param key Some Reputation hash tree key
  /// @param value Reputation value
  /// @param branchMask The branchmask of the proof
  /// @param siblings The siblings of the proof
  function startNextRewardPayout(address _token, bytes key, bytes value, uint256 branchMask, bytes32[] siblings) public;

  /// @notice Claim the reward payout at `_payoutId`. User needs to provide their reputation and colony-wide reputation
  /// which will be proven via Merkle proof inside this function.
  /// Can only be called if payout is active, i.e if 60 days have not passed from its creation.
  /// Can only be called if next in queue
  /// @param _payoutId Id of the reward payout
  /// @param _squareRoots Square roots of values used in equation
  /// _squareRoots[0] - square root of user reputation
  /// _squareRoots[1] - square root of user tokens
  /// _squareRoots[2] - square root of total reputation
  /// _squareRoots[3] - square root of total tokens
  /// _squareRoots[4] - square root of numerator (user reputation * user tokens)
  /// _squareRoots[5] - square root of denominator (total reputation * total tokens)
  /// _squareRoots[6] - square root of payout amount
  /// @param key Some Reputation hash tree key
  /// @param value Reputation value
  /// @param branchMask The branchmask of the proof
  /// @param siblings The siblings of the proof
  function claimRewardPayout(
    uint256 _payoutId,
    uint256[7] _squareRoots,
    bytes key,
    bytes value,
    uint256 branchMask,
    bytes32[] siblings
    ) public;

  /// @notice Get useful information about specific reward payout
  /// @param _payoutId Id of the reward payout
  /// @return reputationState Reputation root hash at the time of creation
  /// @return colonyWideReputation Colony wide reputation in `reputationState`
  /// @return totalTokens Total colony tokens at the time of creation
  /// @return amount Total amount of tokens taken aside for reward payout
  /// @return tokenAddress Token address
  /// @return blockTimestamp Block number at the time of creation
  function getRewardPayoutInfo(uint256 _payoutId) public view returns (
    bytes32 reputationState,
    uint256 colonyWideReputation,
    uint256 totalTokens,
    uint256 amount,
    address tokenAddress,
    uint256 blockTimestamp
    );

  /// @notice Finalises the reward payout. Allows creation of next reward payouts for token that has been used in `_payoutId`
  /// Can only be called when reward payout cycle is finished i.e when 60 days have passed from its creation
  /// @param _payoutId Id of the reward payout
  function finalizeRewardPayout(uint256 _payoutId) public;

  /// @notice Get the `_token` balance of pot with id `_potId`
  /// @param _potId Id of the funding pot
  /// @param _token Address of the token, `0x0` value indicates Ether
  /// @return balance Funding pot balance
  function getPotBalance(uint256 _potId, address _token) public view returns (uint256 balance);

  /// @notice Move a given amount: `_amount` of `_token` funds from funding pot with id `_fromPot` to one with id `_toPot`.
  /// Secured function to authorised members
  /// @param _fromPot Funding pot id providing the funds
  /// @param _toPot Funding pot id receiving the funds
  /// @param _amount Amount of funds
  /// @param _token Address of the token, `0x0` value indicates Ether
  function moveFundsBetweenPots(uint256 _fromPot, uint256 _toPot, uint256 _amount, address _token) public;

  /// @notice Move any funds received by the colony in `_token` denomination to the top-level domain pot,
  /// siphoning off a small amount to the reward pot. If called against a colony's own token, no fee is taken
  /// @param _token Address of the token, `0x0` value indicates Ether
  function claimColonyFunds(address _token) public;

  /// @notice Get the total amount of tokens `_token` minus amount reserved to be paid to the reputation and token holders as rewards
  /// @param _token Address of the token, `0x0` value indicates Ether
  /// @return amount Total amount of tokens in pots other than the rewards pot (id 0)
  function getNonRewardPotsTotal(address _token) public view returns (uint256 amount);
}

// File: /home/igor/Development/kyodo/packages/kyodo-contracts/lib/colonyNetwork/lib/dappsys/auth.sol

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.4.23;

contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        emit LogSetAuthority(authority);
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "ds-auth-unauthorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, this, sig);
        }
    }
}

// File: /home/igor/Development/kyodo/packages/kyodo-contracts/lib/colonyNetwork/lib/dappsys/erc20.sol

/// erc20.sol -- API for the ERC20 token standard

// See <https://github.com/ethereum/EIPs/issues/20>.

// This file likely does not meet the threshold of originality
// required for copyright to apply.  As a result, this is free and
// unencumbered software belonging to the public domain.

pragma solidity ^0.4.8;

contract ERC20Events {
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
}

contract ERC20 is ERC20Events {
    function totalSupply() public view returns (uint);
    function balanceOf(address guy) public view returns (uint);
    function allowance(address src, address guy) public view returns (uint);

    function approve(address guy, uint wad) public returns (bool);
    function transfer(address dst, uint wad) public returns (bool);
    function transferFrom(
        address src, address dst, uint wad
    ) public returns (bool);
}

// File: /home/igor/Development/kyodo/packages/kyodo-contracts/lib/colonyNetwork/lib/dappsys/math.sol

/// math.sol -- mixin for inline numerical wizardry

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.4.13;

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
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

// File: /home/igor/Development/kyodo/packages/kyodo-contracts/lib/colonyNetwork/lib/dappsys/base.sol

/// base.sol -- basic ERC20 implementation

// Copyright (C) 2015, 2016, 2017  DappHub, LLC

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.4.23;



contract DSTokenBase is ERC20, DSMath {
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

    constructor(uint supply) public {
        _balances[msg.sender] = supply;
        _supply = supply;
    }

    function totalSupply() public view returns (uint) {
        return _supply;
    }
    function balanceOf(address src) public view returns (uint) {
        return _balances[src];
    }
    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        if (src != msg.sender) {
            require(_approvals[src][msg.sender] >= wad, "ds-token-insufficient-approval");
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        require(_balances[src] >= wad, "ds-token-insufficient-balance");
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

        return true;
    }
}

// File: /home/igor/Development/kyodo/packages/kyodo-contracts/lib/colonyNetwork/contracts/ERC20Extended.sol

/*
  This file is part of The Colony Network.

  The Colony Network is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  The Colony Network is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with The Colony Network. If not, see <http://www.gnu.org/licenses/>.
*/

pragma solidity ^0.4.23;



contract ERC20Extended is ERC20 {
  event Mint(address indexed guy, uint wad);
  event Burn(address indexed guy, uint wad);

  function mint(uint wad) public;
  
  function burn(uint wad) public;
}

// File: /home/igor/Development/kyodo/packages/kyodo-contracts/lib/colonyNetwork/contracts/Token.sol

/*
  This file is part of The Colony Network.

  The Colony Network is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  The Colony Network is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with The Colony Network. If not, see <http://www.gnu.org/licenses/>.
*/

pragma solidity ^0.4.23;





contract Token is DSTokenBase(0), DSAuth, ERC20Extended {
  uint8 public decimals;
  string public symbol;
  string public name;

  bool public locked;

  modifier unlocked {
    if (locked) {
      require(isAuthorized(msg.sender, msg.sig));
    }
    _;
  }

  constructor(string _name, string _symbol, uint8 _decimals) public {
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    locked = true;
  }

  function transferFrom(address src, address dst, uint wad) public 
  unlocked
  returns (bool)
  {
    return super.transferFrom(src, dst, wad);
  }

  function mint(uint wad) public
  auth
  {
    _balances[msg.sender] = add(_balances[msg.sender], wad);
    _supply = add(_supply, wad);

    emit Mint(msg.sender, wad);
  }

  function burn(uint wad) public {
    _balances[msg.sender] = sub(_balances[msg.sender], wad);
    _supply = sub(_supply, wad);

    emit Burn(msg.sender, wad);
  }

  function unlock() public
  auth
  {
    locked = false;
  }
}

// File: /home/igor/Development/kyodo/packages/kyodo-contracts/contracts/strings.sol

/*
 * @title String & slice utility library for Solidity contracts.
 * @author Nick Johnson <[email protected]>
 *
 * @dev Functionality in this library is largely implemented using an
 *      abstraction called a 'slice'. A slice represents a part of a string -
 *      anything from the entire string to a single character, or even no
 *      characters at all (a 0-length slice). Since a slice only has to specify
 *      an offset and a length, copying and manipulating slices is a lot less
 *      expensive than copying and manipulating the strings they reference.
 *
 *      To further reduce gas costs, most functions on slice that need to return
 *      a slice modify the original one instead of allocating a new one; for
 *      instance, `s.split(".")` will return the text up to the first '.',
 *      modifying s to only contain the remainder of the string after the '.'.
 *      In situations where you do not want to modify the original slice, you
 *      can make a copy first with `.copy()`, for example:
 *      `s.copy().split(".")`. Try and avoid using this idiom in loops; since
 *      Solidity has no memory management, it will result in allocating many
 *      short-lived slices that are later discarded.
 *
 *      Functions that return two slices come in two versions: a non-allocating
 *      version that takes the second slice as an argument, modifying it in
 *      place, and an allocating version that allocates and returns the second
 *      slice; see `nextRune` for example.
 *
 *      Functions that have to copy string data will return strings rather than
 *      slices; these can be cast back to slices for further processing if
 *      required.
 *
 *      For convenience, some functions are provided with non-modifying
 *      variants that create a new slice and return both; for instance,
 *      `s.splitNew('.')` leaves s unmodified, and returns two values
 *      corresponding to the left and right parts of the string.
 */

pragma solidity ^0.4.14;

library strings {
    struct slice {
        uint _len;
        uint _ptr;
    }

    function memcpy(uint dest, uint src, uint len) private pure {
        // Copy word-length chunks while possible
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }

        // Copy remaining bytes
        uint mask = 256 ** (32 - len) - 1;
        assembly {
            let srcpart := and(mload(src), not(mask))
            let destpart := and(mload(dest), mask)
            mstore(dest, or(destpart, srcpart))
        }
    }

    /*
     * @dev Returns a slice containing the entire string.
     * @param self The string to make a slice from.
     * @return A newly allocated slice containing the entire string.
     */
    function toSlice(string self) internal pure returns (slice) {
        uint ptr;
        assembly {
            ptr := add(self, 0x20)
        }
        return slice(bytes(self).length, ptr);
    }

    /*
     * @dev Returns the length of a null-terminated bytes32 string.
     * @param self The value to find the length of.
     * @return The length of the string, from 0 to 32.
     */
    function len(bytes32 self) internal pure returns (uint) {
        uint ret;
        if (self == 0)
            return 0;
        if (self & 0xffffffffffffffffffffffffffffffff == 0) {
            ret += 16;
            self = bytes32(uint(self) / 0x100000000000000000000000000000000);
        }
        if (self & 0xffffffffffffffff == 0) {
            ret += 8;
            self = bytes32(uint(self) / 0x10000000000000000);
        }
        if (self & 0xffffffff == 0) {
            ret += 4;
            self = bytes32(uint(self) / 0x100000000);
        }
        if (self & 0xffff == 0) {
            ret += 2;
            self = bytes32(uint(self) / 0x10000);
        }
        if (self & 0xff == 0) {
            ret += 1;
        }
        return 32 - ret;
    }

    /*
     * @dev Returns a slice containing the entire bytes32, interpreted as a
     *      null-terminated utf-8 string.
     * @param self The bytes32 value to convert to a slice.
     * @return A new slice containing the value of the input argument up to the
     *         first null.
     */
    function toSliceB32(bytes32 self) internal pure returns (slice ret) {
        // Allocate space for `self` in memory, copy it there, and point ret at it
        assembly {
            let ptr := mload(0x40)
            mstore(0x40, add(ptr, 0x20))
            mstore(ptr, self)
            mstore(add(ret, 0x20), ptr)
        }
        ret._len = len(self);
    }

    /*
     * @dev Returns a new slice containing the same data as the current slice.
     * @param self The slice to copy.
     * @return A new slice containing the same data as `self`.
     */
    function copy(slice self) internal pure returns (slice) {
        return slice(self._len, self._ptr);
    }

    /*
     * @dev Copies a slice to a new string.
     * @param self The slice to copy.
     * @return A newly allocated string containing the slice's text.
     */
    function toString(slice self) internal pure returns (string) {
        string memory ret = new string(self._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        memcpy(retptr, self._ptr, self._len);
        return ret;
    }

    /*
     * @dev Returns the length in runes of the slice. Note that this operation
     *      takes time proportional to the length of the slice; avoid using it
     *      in loops, and call `slice.empty()` if you only need to know whether
     *      the slice is empty or not.
     * @param self The slice to operate on.
     * @return The length of the slice in runes.
     */
    function len(slice self) internal pure returns (uint l) {
        // Starting at ptr-31 means the LSB will be the byte we care about
        uint ptr = self._ptr - 31;
        uint end = ptr + self._len;
        for (l = 0; ptr < end; l++) {
            uint8 b;
            assembly { b := and(mload(ptr), 0xFF) }
            if (b < 0x80) {
                ptr += 1;
            } else if(b < 0xE0) {
                ptr += 2;
            } else if(b < 0xF0) {
                ptr += 3;
            } else if(b < 0xF8) {
                ptr += 4;
            } else if(b < 0xFC) {
                ptr += 5;
            } else {
                ptr += 6;
            }
        }
    }

    /*
     * @dev Returns true if the slice is empty (has a length of 0).
     * @param self The slice to operate on.
     * @return True if the slice is empty, False otherwise.
     */
    function empty(slice self) internal pure returns (bool) {
        return self._len == 0;
    }

    /*
     * @dev Returns a positive number if `other` comes lexicographically after
     *      `self`, a negative number if it comes before, or zero if the
     *      contents of the two slices are equal. Comparison is done per-rune,
     *      on unicode codepoints.
     * @param self The first slice to compare.
     * @param other The second slice to compare.
     * @return The result of the comparison.
     */
    function compare(slice self, slice other) internal pure returns (int) {
        uint shortest = self._len;
        if (other._len < self._len)
            shortest = other._len;

        uint selfptr = self._ptr;
        uint otherptr = other._ptr;
        for (uint idx = 0; idx < shortest; idx += 32) {
            uint a;
            uint b;
            assembly {
                a := mload(selfptr)
                b := mload(otherptr)
            }
            if (a != b) {
                // Mask out irrelevant bytes and check again
                uint256 mask = uint256(-1); // 0xffff...
                if(shortest < 32) {
                  mask = ~(2 ** (8 * (32 - shortest + idx)) - 1);
                }
                uint256 diff = (a & mask) - (b & mask);
                if (diff != 0)
                    return int(diff);
            }
            selfptr += 32;
            otherptr += 32;
        }
        return int(self._len) - int(other._len);
    }

    /*
     * @dev Returns true if the two slices contain the same text.
     * @param self The first slice to compare.
     * @param self The second slice to compare.
     * @return True if the slices are equal, false otherwise.
     */
    function equals(slice self, slice other) internal pure returns (bool) {
        return compare(self, other) == 0;
    }

    /*
     * @dev Extracts the first rune in the slice into `rune`, advancing the
     *      slice to point to the next rune and returning `self`.
     * @param self The slice to operate on.
     * @param rune The slice that will contain the first rune.
     * @return `rune`.
     */
    function nextRune(slice self, slice rune) internal pure returns (slice) {
        rune._ptr = self._ptr;

        if (self._len == 0) {
            rune._len = 0;
            return rune;
        }

        uint l;
        uint b;
        // Load the first byte of the rune into the LSBs of b
        assembly { b := and(mload(sub(mload(add(self, 32)), 31)), 0xFF) }
        if (b < 0x80) {
            l = 1;
        } else if(b < 0xE0) {
            l = 2;
        } else if(b < 0xF0) {
            l = 3;
        } else {
            l = 4;
        }

        // Check for truncated codepoints
        if (l > self._len) {
            rune._len = self._len;
            self._ptr += self._len;
            self._len = 0;
            return rune;
        }

        self._ptr += l;
        self._len -= l;
        rune._len = l;
        return rune;
    }

    /*
     * @dev Returns the first rune in the slice, advancing the slice to point
     *      to the next rune.
     * @param self The slice to operate on.
     * @return A slice containing only the first rune from `self`.
     */
    function nextRune(slice self) internal pure returns (slice ret) {
        nextRune(self, ret);
    }

    /*
     * @dev Returns the number of the first codepoint in the slice.
     * @param self The slice to operate on.
     * @return The number of the first codepoint in the slice.
     */
    function ord(slice self) internal pure returns (uint ret) {
        if (self._len == 0) {
            return 0;
        }

        uint word;
        uint length;
        uint divisor = 2 ** 248;

        // Load the rune into the MSBs of b
        assembly { word:= mload(mload(add(self, 32))) }
        uint b = word / divisor;
        if (b < 0x80) {
            ret = b;
            length = 1;
        } else if(b < 0xE0) {
            ret = b & 0x1F;
            length = 2;
        } else if(b < 0xF0) {
            ret = b & 0x0F;
            length = 3;
        } else {
            ret = b & 0x07;
            length = 4;
        }

        // Check for truncated codepoints
        if (length > self._len) {
            return 0;
        }

        for (uint i = 1; i < length; i++) {
            divisor = divisor / 256;
            b = (word / divisor) & 0xFF;
            if (b & 0xC0 != 0x80) {
                // Invalid UTF-8 sequence
                return 0;
            }
            ret = (ret * 64) | (b & 0x3F);
        }

        return ret;
    }

    /*
     * @dev Returns the keccak-256 hash of the slice.
     * @param self The slice to hash.
     * @return The hash of the slice.
     */
    function keccak(slice self) internal pure returns (bytes32 ret) {
        assembly {
            ret := keccak256(mload(add(self, 32)), mload(self))
        }
    }

    /*
     * @dev Returns true if `self` starts with `needle`.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return True if the slice starts with the provided text, false otherwise.
     */
    function startsWith(slice self, slice needle) internal pure returns (bool) {
        if (self._len < needle._len) {
            return false;
        }

        if (self._ptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let length := mload(needle)
            let selfptr := mload(add(self, 0x20))
            let needleptr := mload(add(needle, 0x20))
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }
        return equal;
    }

    /*
     * @dev If `self` starts with `needle`, `needle` is removed from the
     *      beginning of `self`. Otherwise, `self` is unmodified.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return `self`
     */
    function beyond(slice self, slice needle) internal pure returns (slice) {
        if (self._len < needle._len) {
            return self;
        }

        bool equal = true;
        if (self._ptr != needle._ptr) {
            assembly {
                let length := mload(needle)
                let selfptr := mload(add(self, 0x20))
                let needleptr := mload(add(needle, 0x20))
                equal := eq(sha3(selfptr, length), sha3(needleptr, length))
            }
        }

        if (equal) {
            self._len -= needle._len;
            self._ptr += needle._len;
        }

        return self;
    }

    /*
     * @dev Returns true if the slice ends with `needle`.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return True if the slice starts with the provided text, false otherwise.
     */
    function endsWith(slice self, slice needle) internal pure returns (bool) {
        if (self._len < needle._len) {
            return false;
        }

        uint selfptr = self._ptr + self._len - needle._len;

        if (selfptr == needle._ptr) {
            return true;
        }

        bool equal;
        assembly {
            let length := mload(needle)
            let needleptr := mload(add(needle, 0x20))
            equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
        }

        return equal;
    }

    /*
     * @dev If `self` ends with `needle`, `needle` is removed from the
     *      end of `self`. Otherwise, `self` is unmodified.
     * @param self The slice to operate on.
     * @param needle The slice to search for.
     * @return `self`
     */
    function until(slice self, slice needle) internal pure returns (slice) {
        if (self._len < needle._len) {
            return self;
        }

        uint selfptr = self._ptr + self._len - needle._len;
        bool equal = true;
        if (selfptr != needle._ptr) {
            assembly {
                let length := mload(needle)
                let needleptr := mload(add(needle, 0x20))
                equal := eq(keccak256(selfptr, length), keccak256(needleptr, length))
            }
        }

        if (equal) {
            self._len -= needle._len;
        }

        return self;
    }

    event log_bytemask(bytes32 mask);

    // Returns the memory address of the first byte of the first occurrence of
    // `needle` in `self`, or the first byte after `self` if not found.
    function findPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {
        uint ptr = selfptr;
        uint idx;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));

                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }

                uint end = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }

                while (ptrdata != needledata) {
                    if (ptr >= end)
                        return selfptr + selflen;
                    ptr++;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr;
            } else {
                // For long needles, use hashing
                bytes32 hash;
                assembly { hash := sha3(needleptr, needlelen) }

                for (idx = 0; idx <= selflen - needlelen; idx++) {
                    bytes32 testHash;
                    assembly { testHash := sha3(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr;
                    ptr += 1;
                }
            }
        }
        return selfptr + selflen;
    }

    // Returns the memory address of the first byte after the last occurrence of
    // `needle` in `self`, or the address of `self` if not found.
    function rfindPtr(uint selflen, uint selfptr, uint needlelen, uint needleptr) private pure returns (uint) {
        uint ptr;

        if (needlelen <= selflen) {
            if (needlelen <= 32) {
                bytes32 mask = bytes32(~(2 ** (8 * (32 - needlelen)) - 1));

                bytes32 needledata;
                assembly { needledata := and(mload(needleptr), mask) }

                ptr = selfptr + selflen - needlelen;
                bytes32 ptrdata;
                assembly { ptrdata := and(mload(ptr), mask) }

                while (ptrdata != needledata) {
                    if (ptr <= selfptr)
                        return selfptr;
                    ptr--;
                    assembly { ptrdata := and(mload(ptr), mask) }
                }
                return ptr + needlelen;
            } else {
                // For long needles, use hashing
                bytes32 hash;
                assembly { hash := sha3(needleptr, needlelen) }
                ptr = selfptr + (selflen - needlelen);
                while (ptr >= selfptr) {
                    bytes32 testHash;
                    assembly { testHash := sha3(ptr, needlelen) }
                    if (hash == testHash)
                        return ptr + needlelen;
                    ptr -= 1;
                }
            }
        }
        return selfptr;
    }

    /*
     * @dev Modifies `self` to contain everything from the first occurrence of
     *      `needle` to the end of the slice. `self` is set to the empty slice
     *      if `needle` is not found.
     * @param self The slice to search and modify.
     * @param needle The text to search for.
     * @return `self`.
     */
    function find(slice self, slice needle) internal pure returns (slice) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len -= ptr - self._ptr;
        self._ptr = ptr;
        return self;
    }

    /*
     * @dev Modifies `self` to contain the part of the string from the start of
     *      `self` to the end of the first occurrence of `needle`. If `needle`
     *      is not found, `self` is set to the empty slice.
     * @param self The slice to search and modify.
     * @param needle The text to search for.
     * @return `self`.
     */
    function rfind(slice self, slice needle) internal pure returns (slice) {
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        self._len = ptr - self._ptr;
        return self;
    }

    /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and `token` to everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and `token` is set to the entirety of `self`.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @param token An output parameter to which the first token is written.
     * @return `token`.
     */
    function split(slice self, slice needle, slice token) internal pure returns (slice) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = self._ptr;
        token._len = ptr - self._ptr;
        if (ptr == self._ptr + self._len) {
            // Not found
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
            self._ptr = ptr + needle._len;
        }
        return token;
    }

    /*
     * @dev Splits the slice, setting `self` to everything after the first
     *      occurrence of `needle`, and returning everything before it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and the entirety of `self` is returned.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @return The part of `self` up to the first occurrence of `delim`.
     */
    function split(slice self, slice needle) internal pure returns (slice token) {
        split(self, needle, token);
    }

    /*
     * @dev Splits the slice, setting `self` to everything before the last
     *      occurrence of `needle`, and `token` to everything after it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and `token` is set to the entirety of `self`.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @param token An output parameter to which the first token is written.
     * @return `token`.
     */
    function rsplit(slice self, slice needle, slice token) internal pure returns (slice) {
        uint ptr = rfindPtr(self._len, self._ptr, needle._len, needle._ptr);
        token._ptr = ptr;
        token._len = self._len - (ptr - self._ptr);
        if (ptr == self._ptr) {
            // Not found
            self._len = 0;
        } else {
            self._len -= token._len + needle._len;
        }
        return token;
    }

    /*
     * @dev Splits the slice, setting `self` to everything before the last
     *      occurrence of `needle`, and returning everything after it. If
     *      `needle` does not occur in `self`, `self` is set to the empty slice,
     *      and the entirety of `self` is returned.
     * @param self The slice to split.
     * @param needle The text to search for in `self`.
     * @return The part of `self` after the last occurrence of `delim`.
     */
    function rsplit(slice self, slice needle) internal pure returns (slice token) {
        rsplit(self, needle, token);
    }

    /*
     * @dev Counts the number of nonoverlapping occurrences of `needle` in `self`.
     * @param self The slice to search.
     * @param needle The text to search for in `self`.
     * @return The number of occurrences of `needle` found in `self`.
     */
    function count(slice self, slice needle) internal pure returns (uint cnt) {
        uint ptr = findPtr(self._len, self._ptr, needle._len, needle._ptr) + needle._len;
        while (ptr <= self._ptr + self._len) {
            cnt++;
            ptr = findPtr(self._len - (ptr - self._ptr), ptr, needle._len, needle._ptr) + needle._len;
        }
    }

    /*
     * @dev Returns True if `self` contains `needle`.
     * @param self The slice to search.
     * @param needle The text to search for in `self`.
     * @return True if `needle` is found in `self`, false otherwise.
     */
    function contains(slice self, slice needle) internal pure returns (bool) {
        return rfindPtr(self._len, self._ptr, needle._len, needle._ptr) != self._ptr;
    }

    /*
     * @dev Returns a newly allocated string containing the concatenation of
     *      `self` and `other`.
     * @param self The first slice to concatenate.
     * @param other The second slice to concatenate.
     * @return The concatenation of the two strings.
     */
    function concat(slice self, slice other) internal pure returns (string) {
        string memory ret = new string(self._len + other._len);
        uint retptr;
        assembly { retptr := add(ret, 32) }
        memcpy(retptr, self._ptr, self._len);
        memcpy(retptr + self._len, other._ptr, other._len);
        return ret;
    }

    /*
     * @dev Joins an array of slices, using `self` as a delimiter, returning a
     *      newly allocated string.
     * @param self The delimiter to use.
     * @param parts A list of slices to join.
     * @return A newly allocated string containing all the slices in `parts`,
     *         joined with `self`.
     */
    function join(slice self, slice[] parts) internal pure returns (string) {
        if (parts.length == 0)
            return "";

        uint length = self._len * (parts.length - 1);
        for(uint i = 0; i < parts.length; i++)
            length += parts[i]._len;

        string memory ret = new string(length);
        uint retptr;
        assembly { retptr := add(ret, 32) }

        for(uint i = 0; i < parts.length; i++) {
            memcpy(retptr, parts[i]._ptr, parts[i]._len);
            retptr += parts[i]._len;
            if (i < parts.length - 1) {
                memcpy(retptr, self._ptr, self._len);
                retptr += self._len;
            }
        }

        return ret;
    }
}

// File: /home/igor/Development/kyodo/packages/kyodo-contracts/contracts/Ownable.sol

/**
 * @title Ownable
 * @dev This contract has the owner address providing basic authorization control
 */
contract Ownable {
  /**
   * @dev Event to show ownership has been transferred
   * @param previousOwner representing the address of the previous owner
   * @param newOwner representing the address of the new owner
   */
  event OwnershipTransferred(address previousOwner, address newOwner);

  // Owner of the contract
  address private _owner;

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner());
    _;
  }

  /**
   * @dev The constructor sets the original owner of the contract to the sender account.
   */
  constructor() public {
    setOwner(msg.sender);
  }

  /**
   * @dev Tells the address of the owner
   * @return the address of the owner
   */
  function owner() public view returns (address) {
    return _owner;
  }

  /**
   * @dev Sets a new owner address
   */
  function setOwner(address newOwner) internal {
    _owner = newOwner;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner(), newOwner);
    setOwner(newOwner);
  }
}

// File: /home/igor/Development/kyodo/packages/kyodo-contracts/contracts/DomainsV1.sol

contract DomainsV1 is Ownable {
  using SafeMath for uint256;

  struct Domain {
    string code;
    uint id;
  }

  Domain[] public domains;
  uint[] public distribution;
  bool internal _initialized;

  event NewDomainAdded(string _code, uint _id);

  /**
   * @dev Add domain to colony and store in kyodo contract.
   * @param _code Domain code to store
   */
  function addDomain(string _code) external onlyOwner {
    uint domainId = domains.length.add(1);
    Domain memory domain = Domain(_code, domainId);
    domains.push(domain);

    emit NewDomainAdded(_code, domainId);
  }

  function initialize(address owner) public {
    require(!_initialized);
    setOwner(owner);
    distribution = [1, 1, 1, 1];
    _initialized = true;
  }

  /**
   * @dev Get added domains length.
   */
  function getDomainsLength() public view returns (uint) {
    return domains.length;
  }

  /**
   * @dev Get domain details by its index.
   * @param _index Domain index to retrieve
   */
  function getDomain(uint _index) public view returns (string, uint) {
    return (domains[_index].code, domains[_index].id);
  }

  // function getDomains()
    // public
    // returns (string[], uint[])
  // {
    // string[] memory codes = new string[](domains.length);
    // uint[] memory ids = new uint[](domains.length);
    
    // for (uint i = 0; i < domains.length; i++) {
      // Domain storage domain = domains[i];
      // codes[i] = domain.code;
      // ids[i] = domain.id;
    // }
    
    // return (codes, ids);
  // }

  function distributeTokens(address _colony, address _token, uint _amount) public onlyOwner {
    uint totalPower = 0;
    for (uint i=0; i < distribution.length; i++) {
      totalPower = totalPower.add(distribution[i]);
    }
    // IColony(_colony).moveFundsBetweenPots(1, 2, 1, _token);
    for (uint i = 0; i < distribution.length; i++) {
      IColony(_colony).moveFundsBetweenPots(1, i+2, distribution[i].mul(_amount).div(totalPower), _token);
    }
  }
}

// File: /home/igor/Development/kyodo/packages/kyodo-contracts/contracts/MembersV1.sol

contract MembersV1 is Ownable {
  using strings for *;

  // Defines Member type
  struct Member {
    string alias;
    bool whitelisted;
  }

  string[] public usedAliases;
  bool internal _initialized;
  mapping(address => Member) public whitelist;
  address[] public whitelistedAddresses;

  event NewAliasSet(address _address, string _alias);

  function setAlias(
    string _value
  )
    external
    isWhitelisted(msg.sender)
  {
    require(nickNameNotExist(_value));
    string storage prevValue = whitelist[msg.sender].alias;
    int prevIndex = getNickNameIndex(prevValue);
    whitelist[msg.sender].alias = _value;

    // update used aliases
    usedAliases.push(_value);

    // delete previous nickname
    if (prevIndex >= 0) {
      usedAliases[uint(prevIndex)] = usedAliases[usedAliases.length - 1];
      delete usedAliases[usedAliases.length - 1];
      usedAliases.length--;
    }

    // TODO:  Check if should mint
    // MintableToken(Token).mint(msg.sender, 100000);

    emit NewAliasSet(msg.sender, _value);
  }

  /**
   * @dev Adds list of addresses to whitelist. Not overloaded due to limitations with truffle testing.
   * @param _beneficiaries Addresses to be added to the whitelist
   */
  function addManyToWhitelist(address[] _beneficiaries) external onlyOwner {
    for (uint256 i = 0; i < _beneficiaries.length; i++) {
      whitelist[_beneficiaries[i]].whitelisted = true;
      whitelistedAddresses.push(_beneficiaries[i]);
    }
  }

  /**
   * @dev Removes single address from whitelist.
   * @param _beneficiary Address to be removed to the whitelist
   */
  function removeFromWhitelist(address _beneficiary) external onlyOwner {
    whitelist[_beneficiary].whitelisted = false;
  }

  function getMembersCount() public view returns (uint)
  {
    return whitelistedAddresses.length;
  }

  modifier notNull(address _address) {
    require(_address != 0);
    _;
  }

  function initialize(address owner) public {
    require(!_initialized);
    setOwner(owner);
    _initialized = true;
  }

  /**
   * @dev Adds single address to whitelist.
   * @param _beneficiary Address to be added to the whitelist
   */
  function addToWhitelist(
    address _beneficiary
  )
    public
    isNotWhitelisted(_beneficiary)
    notNull(_beneficiary)
    onlyOwner
  {
    whitelist[_beneficiary].whitelisted = true;
    whitelistedAddresses.push(_beneficiary);
  }

  // @dev Returns list of whitelistedAddresses.
  // @return List of whitelisted addresses.
  function getWhitelistedAddresses() public view returns (address[]) {
    return whitelistedAddresses;
  }

  // @dev Returns list of whitelistedAddresses.
  // @return List of whitelisted addresses.
  function getUsedAliasesLength() public view returns (uint) {
    return usedAliases.length;
  }

  function nickNameNotExist(string _value)
    public
    returns (bool)
  {
    for (uint i=0; i < usedAliases.length; i++) {
      if (usedAliases[i].toSlice().equals(_value.toSlice())) return false;
    }
    return true;
  }

  function getNickNameIndex(string _value)
    public
    view
    returns (int)
  {
    for (uint i=0; i < usedAliases.length; i++) {
      if (usedAliases[i].toSlice().contains(_value.toSlice())) return int(i);
    }
    return -1;
  }

  function getAlias(address _addr) public view returns (string)
  {
    return whitelist[_addr].alias;
  }

    /**
   * @dev Reverts if beneficiary is not whitelisted. Can be used when extending this contract.
   */
  modifier isWhitelisted(address _beneficiary) {
    require(whitelist[_beneficiary].whitelisted);
    _;
  }

    /**
   * @dev Reverts if beneficiary is not whitelisted. Can be used when extending this contract.
   */
  modifier isNotWhitelisted(address _beneficiary) {
    require(!whitelist[_beneficiary].whitelisted);
    _;
  }

}

// File: /home/igor/Development/kyodo/packages/kyodo-contracts/contracts/PeriodsV1.sol

contract PeriodsV1 is Ownable {
  using SafeMath for uint256;

  uint256 public currentPeriodStartTime;
  uint public currentPeriodStartBlock;
  uint public periodDaysLength;
  uint[] public periods;

  bool internal _initialized;

  event NewPeriodStart(uint _periodId);

  function initialize(address owner) public {
    require(!_initialized);
    setOwner(owner);
    periodDaysLength = 30;
    currentPeriodStartTime = 0;
    _initialized = true;
  }

  function startNewPeriod(address _token, address _colony) public returns (uint256) {
    require(now > BokkyPooBahsDateTimeLibrary.addDays(currentPeriodStartTime, periodDaysLength));
    
    currentPeriodStartTime = now;
    currentPeriodStartBlock = block.number;
    emit NewPeriodStart(periods.length);
    periods.push(currentPeriodStartBlock);

    return currentPeriodStartTime;
  }

  // TODO: multisig function
  function setPeriodDaysLength(uint8 daysLength) public onlyOwner returns (uint) {
    periodDaysLength = daysLength;
    return periodDaysLength;
  }
}

// File: contracts/KyodoDAO.sol

contract KyodoDAO is Ownable {
  using strings for *;
  using SafeMath for uint256;

  address public colony;
  address public domains;
  address public members;
  address public periods;
  address public token;
  uint public inflationRate;
  bool internal _initialized;

  event ColonyAddressChanged(address _address);
  event DomainsAddressChanged(address _address);
  event PeriodsAddressChanged(address _address);
  event MembersAddressChanged(address _address);
  event TokenAddressChanged(address _address);
  event NewDomainAdded(string _code, uint _id);

  function addDomain(string _code) external onlyOwner {
    IColony(colony).addDomain(1);

    DomainsV1(domains).addDomain(_code);
    // emit NewDomainAdded(_code, 1);
  }

  /**
   * @dev Adds list of addresses to whitelist. Not overloaded due to limitations with truffle testing.
   * @param _beneficiaries Addresses to be added to the whitelist
   */
  function addManyToWhitelist(address[] _beneficiaries) external onlyOwner {
    MembersV1(members).addManyToWhitelist(_beneficiaries);
  }

  function initialize(address owner) public {
    require(!_initialized);
    setOwner(owner);
    // TODO: Find a proper place to define inflation rate
    inflationRate = 5;
    _initialized = true;
  }

  function setColonyAddress(address _address) public onlyOwner {
    colony = _address;
    emit ColonyAddressChanged(_address);
  }

  function setDomainsAddress(address _address) public onlyOwner {
    domains = _address;
    emit DomainsAddressChanged(_address);
  }

  function setPeriodsAddress(address _address) public onlyOwner {
    periods = _address;
    emit PeriodsAddressChanged(_address);
  }

  function setMembersAddress(address _address) public onlyOwner {
    members = _address;
    emit MembersAddressChanged(_address);
  }

  function setTokenAddress(address _address) public onlyOwner {
    token = _address;
    emit TokenAddressChanged(_address);
  }

  function startNewPeriod() public {
    PeriodsV1(periods).startNewPeriod(token, colony);

    // Mint tokens
    uint _totalSupply = ERC20Extended(token).totalSupply();
    uint _toMint = _totalSupply.mul(inflationRate).div(100);
    IColony(colony).mintTokens(_toMint);

    // Claim tokens
    IColony(colony).claimColonyFunds(token);

    DomainsV1(domains).distributeTokens(colony, token, _toMint);
  }

  function setPeriodDaysLength(uint8 _days) public onlyOwner {
    PeriodsV1(periods).setPeriodDaysLength(_days);
  }
}
