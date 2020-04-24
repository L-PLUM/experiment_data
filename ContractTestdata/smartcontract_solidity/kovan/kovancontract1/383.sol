/**
 *Submitted for verification at Etherscan.io on 2019-02-01
*/

pragma solidity 0.4.24;

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

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

// File: contracts/MTPromoPack.sol

contract TVCrowdsale {
    uint256 public currentRate;
    function buyTokens(address _beneficiary) public payable;
}

contract TVToken {
    function transfer(address _to, uint256 _value) public returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool);
    function safeTransfer(address _to, uint256 _value, bytes _data) public;
}

contract IMTArtefact {
    function packs(uint id) public view returns (uint, string, uint, uint, bool, bool);
    function changeAndBuyPack(uint packId) public payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function tokenOfOwnerByIndex(address _owner, uint256 _index) public returns (uint) ;
}

contract MTPromoPack is Ownable {
    address public manager;
    address public tvHolder;
    address public MTArtefactAddress;
    address public TVTokenAddress;
    address public TVCrowdsaleAddress;
    bool public active;
    uint public discountPercentage;
    uint public packsLeft;


    modifier onlyOwnerOrManager() {
        require(msg.sender == owner || manager == msg.sender);
        _;
    }

    event TokenReceived(address from, uint value, bytes data, uint packId);
    event ChangeAndBuyPack(address buyer, uint rate, uint price, uint packId);

    constructor(
        address _MTArtefactAddress,
        address _TVTokenAddress,
        address _TVCrowdsaleAddress,
        address _tvHolder,
        address _manager
    ) public {
        MTArtefactAddress = _MTArtefactAddress;
        TVTokenAddress = _TVTokenAddress;
        TVCrowdsaleAddress = _TVCrowdsaleAddress;
        tvHolder = _tvHolder;
        manager = _manager;
    }

    function changeAndBuyPack(uint packId) public payable {
        require(msg.sender == TVTokenAddress);
        require(active);
        require(packsLeft > 0);

        packsLeft--;

        (, , uint count, uint packPrice, ,) = IMTArtefact(MTArtefactAddress).packs(packId);

        uint rate = TVCrowdsale(TVCrowdsaleAddress).currentRate();
        uint discountPrice = (packPrice / 100) * discountPercentage;
        uint priceWei =  discountPrice / rate;
        require(priceWei == msg.value);

        TVCrowdsale(TVCrowdsaleAddress).buyTokens.value(msg.value)(this);
        bytes memory data = toBytes(packId);

        TVToken(TVTokenAddress).transferFrom(tvHolder, this, packPrice - discountPrice);
        TVToken(TVTokenAddress).safeTransfer(MTArtefactAddress, packPrice, data);

        for (uint i = 0; i < count; i++) {
            uint id = IMTArtefact(MTArtefactAddress).tokenOfOwnerByIndex(this, i);
            IMTArtefact(MTArtefactAddress).transferFrom(this, msg.sender, id);
        }

        emit ChangeAndBuyPack(msg.sender, rate, priceWei, packId);
    }

    function changeTVTokenAddress(address newAddress) public onlyOwnerOrManager {
        TVTokenAddress = newAddress;
    }

    function getPromoPrice(uint packId) public view returns(uint) {
        (, , , uint packPrice, ,) = IMTArtefact(MTArtefactAddress).packs(packId);
        return (packPrice / 100) * discountPercentage;
    }

    function changeTVCrowdsaleAddress(address newAddress) public onlyOwnerOrManager {
        TVCrowdsaleAddress = newAddress;
    }

    function changeHolderAddress(address newAddress) public onlyOwnerOrManager {
        tvHolder = newAddress;
    }

    function setManager(address _manager) public onlyOwner {
        manager = _manager;
    }

    function setActive(bool _active) public onlyOwnerOrManager {
        active = _active;
    }

    function setPack(uint count, uint discount) public onlyOwnerOrManager {
        discountPercentage = discount;
        packsLeft = count;
    }

    function toBytes(uint256 x) internal pure returns (bytes b) {
        b = new bytes(32);
        assembly {mstore(add(b, 32), x)}
    }
}
