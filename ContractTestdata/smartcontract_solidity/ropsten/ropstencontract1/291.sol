/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

pragma solidity >=0.4.21 <0.6.0;

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



contract SessionRecord is Ownable {

  struct Attendance {
    string firstName;
    string lastName;
    string phone;
    uint256 timestamp;
    uint256 minutesSpoke;
    uint256 minutesAttended;
  }

  mapping (string => mapping (string => Attendance)) internal sessions;
  mapping (string => string[]) internal attendees;

  function addAttendee(string memory _session, string memory _email) public {
    attendees[_session].push(_email);
    emit InviteIssued(msg.sender, _session, _email);
  }

  function getAttendeeNumber(string memory _session) public view
    returns (uint256) {
    return attendees[_session].length;
  }

  function getAttendee(string memory _session, uint256 _n) public view
    returns (string memory) {
    return attendees[_session][_n];
  }

  function setFirstName(string memory _session, string memory _email, string memory _first) public {
    Attendance storage a = sessions[_session][_email];
    a.firstName = _first;
    emit FirstNameSet(msg.sender, _session, _email, _first);
  }
  
  function setLastName(string memory _session, string memory _email, string memory _last) public {
    Attendance storage a = sessions[_session][_email];
    a.lastName = _last;
    emit LastNameSet(msg.sender, _session, _email, _last);
  }

  
  function setPhone(string memory _session, string memory _email, string memory _phone) public {
    Attendance storage a = sessions[_session][_email];
    a.phone = _phone;
  }

  function setMinutesSpoke(string memory _session, string memory _email, uint256 _spoke) public {
    Attendance storage a = sessions[_session][_email];
    a.minutesSpoke = _spoke;
  }  
  
  function setMinutesAttended(string memory _session, string memory _email, uint256 _attended) public {
    Attendance storage a = sessions[_session][_email];
    a.minutesAttended = _attended;
  }

  function setTimestamp(string memory _session, string memory _email, uint256 _timestamp) public {
    Attendance storage a = sessions[_session][_email];
    a.timestamp = _timestamp;
    emit Timestamped(msg.sender, _session, _email, _timestamp);
  }

  event InviteIssued(address indexed by, string indexed session, string indexed email);
  event FirstNameSet(address indexed by, string indexed session, string indexed email, string firstName);
  event LastNameSet(address indexed by, string indexed session, string indexed email, string lastName);
  event PhoneSet(address indexed by, string indexed session, string indexed email, string PhoneNumber);
  event Timestamped(address indexed by, string indexed session, string indexed email, uint256 timestamp);
}
