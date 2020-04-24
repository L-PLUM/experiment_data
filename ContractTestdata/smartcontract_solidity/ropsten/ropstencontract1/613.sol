/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.4.24;

contract Proxy {

    address public implementation;

    constructor(address _address) public payable {
        require(msg.value == 1 ether, "Must send 1 Ether");
        implementation = _address;
    }

    function() external payable {
        address _impl = implementation;
        require(_impl != address(0x0));

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0x0, calldatasize)
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
            returndatacopy(ptr, 0x0, returndatasize)
            switch result case 0 {revert(ptr, returndatasize)} default {return (ptr, returndatasize)}
        }
    }
}

contract Challenge {
    function isComplete() public view returns (bool);
}

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

contract Deployer is Ownable {

    event ChallengeDeployed(address player, address challenge);
    event ChallengeCompleted(address player, address challenge);

    mapping (address => Proxy[5]) playersToContracts;
    mapping (address => bool[5]) playersToCompletion;
    mapping (address => string) playersToNickname;

    address[5] challenges;

    constructor(address challenge1, address challenge2, address challenge3, address challenge4, address challenge5) public {
        challenges[0] = challenge1;
        challenges[1] = challenge2;
        challenges[2] = challenge3;
        challenges[3] = challenge4;
        challenges[4] = challenge5;
    }

    //------------------ STATE CHANGING FUNCTIONS ------------------------//

    function updateChallenge(address newAddress, uint256 index)
        public
        onlyOwner
    {
        challenges[index] = newAddress;
    }

    function deployChallenge(uint256 index)
        public
        payable
    {
        require(msg.value == 1 ether, "Must send 1 ether");

        require(isContract(address(challenges[index])), "Challenge has not been created yet");

        playersToContracts[msg.sender][index] = (new Proxy).value(msg.value)(challenges[index]);

        playersToCompletion[msg.sender][index] = false;

        emit ChallengeDeployed(msg.sender, playersToContracts[msg.sender][index]);
    }

    function setNickname(string memory name)
        public
    {
        playersToNickname[msg.sender] = name;
    }

    function completeChallenge(uint256 index)
        public
    {
        address _to = address(playersToContracts[msg.sender][index]);

        require(isContract(_to), "Contract has not been deployed");

        playersToCompletion[msg.sender][index] = Challenge(_to).isComplete();

        emit ChallengeCompleted(msg.sender, playersToContracts[msg.sender][index]);
    }

    //---------------------- VIEW FUNCTIONS -------------------------------//

    function isContract(address _addr)
        private
        view
        returns (bool)
    {
        uint32 size;
        assembly {
            size := extcodesize(_addr)
        }
        return (size > 0);
    }

    function getNicknameOf(address player)
        public
        view
        returns (string memory)
    {
        return playersToNickname[player];
    }

    function getAddressOf(address player, uint256 index)
        public
        view
        returns (address)
    {
        return address(playersToContracts[player][index]);
    }

    function checkCompletionOf(address player, uint256 index)
        public
        view
        returns (bool)
    {
        return playersToCompletion[player][index];
    }

}
