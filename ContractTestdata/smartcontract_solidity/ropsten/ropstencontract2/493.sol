/**
 *Submitted for verification at Etherscan.io on 2019-08-06
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

// File: contracts/generators/ILogicGenerator.sol

pragma solidity ^0.5.0;

interface ILogicGenerator {
    function generate(address _sender)
    external
    returns (uint256 city, uint256 building, uint256 base, uint256 body, uint256 roof, uint256 special);
}

// File: contracts/generators/LogicGeneratorV2.sol

pragma solidity ^0.5.0;



contract LogicGeneratorV2 is Ownable, ILogicGenerator {
    uint256 internal randNonce = 0;

    event Generated(
        uint256 city,
        uint256 building,
        uint256 base,
        uint256 body,
        uint256 roof,
        uint256 special
    );

    uint256[] public cityPercentages;

    mapping(uint256 => uint256[]) public cityMappings;

    mapping(uint256 => uint256[]) public buildingBaseMappings;
    mapping(uint256 => uint256[]) public buildingBodyMappings;
    mapping(uint256 => uint256[]) public buildingRoofMappings;

    uint256[] public specialMappings;

    uint256 public specialModulo = 13; // give one every x blocks on average

    function generate(address _sender)
    external
    returns (uint256 city, uint256 building, uint256 base, uint256 body, uint256 roof, uint256 special) {
        bytes32 hash = blockhash(block.number);

        uint256 aCity = cityPercentages[_generate(hash, _sender, cityPercentages.length)];

        uint256 aBuilding = cityMappings[aCity][_generate(hash, _sender, cityMappings[aCity].length)];

        uint256 aBase = buildingBaseMappings[aBuilding][_generate(hash, _sender, buildingBaseMappings[aBuilding].length)];
        uint256 aBody = buildingBodyMappings[aBuilding][_generate(hash, _sender, buildingBodyMappings[aBuilding].length)];
        uint256 aRoof = buildingRoofMappings[aBuilding][_generate(hash, _sender, buildingRoofMappings[aBuilding].length)];
        uint256 aSpecial = _getSpecial(hash, _sender);

        emit Generated(aCity, aBuilding, aBase, aBody, aRoof, aSpecial);

        return (aCity, aBuilding, aBase, aBody, aRoof, aSpecial);
    }

    function _getSpecial(bytes32 hash, address _sender) internal returns (uint256) {
        // 1 in X roughly
        if (isSpecial(block.number)) {
            return specialMappings[_generate(hash, _sender, specialMappings.length)];
        }
        return 0;
    }

    function _generate(bytes32 _hash, address _sender, uint256 _max) internal returns (uint256) {
        randNonce++;
        bytes memory packed = abi.encodePacked(_hash, _sender, randNonce);
        return uint256(keccak256(packed)) % _max;
    }

    function isSpecial(uint256 _blocknumber) public view returns (bool) {
        return (_blocknumber % specialModulo) == 0;
    }

    function updateBuildingBaseMappings(uint256 _building, uint256[] memory _params) public onlyOwner {
        buildingBaseMappings[_building] = _params;
    }

    function updateBuildingBodyMappings(uint256 _building, uint256[] memory _params) public onlyOwner {
        buildingBodyMappings[_building] = _params;
    }

    function updateBuildingRoofMappings(uint256 _building, uint256[] memory _params) public onlyOwner {
        buildingRoofMappings[_building] = _params;
    }

    function updateCityPercentages(uint256[] memory _params) public onlyOwner {
        cityPercentages = _params;
    }

    function updateCityMappings(uint256 _cityIndex, uint256[] memory _params) public onlyOwner {
        cityMappings[_cityIndex] = _params;
    }

    function updateSpecialModulo(uint256 _specialModulo) public onlyOwner {
        specialModulo = _specialModulo;
    }

    function updateSpecialMappings(uint256[] memory _params) public onlyOwner {
        specialMappings = _params;
    }
}
