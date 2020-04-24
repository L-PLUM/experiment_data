/**
 *Submitted for verification at Etherscan.io on 2019-02-04
*/

pragma solidity ^0.4.24;

// File: node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address private _owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() internal {
    _owner = msg.sender;
    emit OwnershipTransferred(address(0), _owner);
  }

  /**
   * @return the address of the owner.
   */
  function owner() public view returns(address) {
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
  function isOwner() public view returns(bool) {
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

// File: contracts/DevicesList.sol

contract DevicesList is Ownable {

    // Struct data
    struct Device {
        bytes32 id;     // device identifier
        address dso;    // DSO address
    }

    // Variables declaration

    /// Mapping containing the devices data
    mapping (address => Device) private devicesData;

    /// Mapping containing the flags related to the devices addresses
    mapping (address => bool) private devicesFlags;

    /// Mapping containing the flags related to the devices identifiers
    mapping (bytes32 => bool) private devicesIdsFlags;

    /// Mapping containing the DSOs allowance (True: address allowed to update the device list | False: address not allowed)
    mapping (address => bool) private dsosEnabled;

    // Events

    /// DSO enabled
    /// @param dso address of the enabled DSO
    event EnabledDSO(address dso);

    /// DSO disabled
    /// @param dso address of the disabled DSO
    event DisabledDSO(address dso);

    /// Device added
    /// @param device address of the added device
    event AddedDevice(address device);

    /// Device removed
    /// @param device address of the removed device
    event RemovedDevice(address device);

    /// Constructor
    constructor() public { }

    /// Enable a DSO to update the devices list
    /// @param _dso the DSO address to enable
    function enableDSO(address _dso) onlyOwner public {
        dsosEnabled[_dso] = true;
        emit EnabledDSO(_dso);
    }

    /// Disable a DSO to update the devices list
    /// @param _dso the DSO address to disable
    function disableDSO(address _dso) onlyOwner public {
        dsosEnabled[_dso] = false;
        emit DisabledDSO(_dso);
    }

    /// Add a device to the list
    /// @param _device the device address
    /// @param _deviceId the device identifier (e.g. a serial number, a tag related to the plant)
    /// @param _dso the DSO address
    function add(address _device, bytes32 _deviceId, address _dso) public {

        // Check if msg.sender is allowed to add a device
        // Only enabled DSOs and contract owner are allowed to update the list
        require((isOwner() == true) || (dsosEnabled[msg.sender] == true && msg.sender == _dso));

        // Check if the data to insert are meaningful
        require(_device != address(0));
        require(_dso != address(0));
        require(_dso != _device);
        require(_deviceId != 0);

        // Check if the device to add already exists
        require(devicesFlags[_device] == false);
        require(devicesIdsFlags[_deviceId] == false);

        // Add the device
        devicesData[_device].id = _deviceId;
        devicesData[_device].dso = _dso;
        devicesFlags[_device] = true;
        devicesIdsFlags[_deviceId] = true;

        emit AddedDevice(_device);
    }

    /// Remove a device from the list
    /// @param _device the device address
    function remove(address _device) public {

        // Get the device identifier
        bytes32 deviceId = getId(_device);

        // Check if msg.sender is allowed to add a device
        // Only enabled DSOs and contract owner are allowed to update the list
        require((isOwner() == true) || (dsosEnabled[msg.sender] == true && msg.sender == devicesData[_device].dso));

        // Check if the data to insert are meaningful
        require(_device != address(0));
        require(_device != msg.sender);

        // Check if the device to remove already exists
        require(devicesFlags[_device] == true);
        require(devicesIdsFlags[deviceId] == true);

        // Remove the device
        devicesData[_device].id = '';
        devicesData[_device].dso = address(0);
        devicesFlags[_device] = false;
        devicesIdsFlags[deviceId] = false;

        emit RemovedDevice(_device);
    }

    /// @param _device the device address
    /// @return device identifier
    function getId(address _device) view public returns(bytes32) {
        // Check if the device to remove already exists
        if (devicesFlags[_device] == true) {
            return devicesData[_device].id;
        }
        else {
            return '';
        }
    }

    /// @param _device the device address
    /// @return address of the DSO related to the device
    function getDSO(address _device) view public returns(address) {
        // Check if the device to remove already exists
        if (devicesFlags[_device] == true) {
            return devicesData[_device].dso;
        }
        else {
            return address(0);
        }
    }

    /// @param _device the device address
    /// @return TRUE if device in list, otherwise FALSE
    function getDeviceFlag(address _device) view public returns(bool) {
        return devicesFlags[_device];
    }

    /// @param _dso the DSO address
    /// @return TRUE if DSO is enabled, otherwise FALSE
    function getDSOEnabling(address _dso) view public returns(bool) {
        return dsosEnabled[_dso];
    }
}
