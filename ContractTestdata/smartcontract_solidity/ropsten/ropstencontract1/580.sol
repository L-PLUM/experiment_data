/**
 *Submitted for verification at Etherscan.io on 2019-02-17
*/

pragma solidity ^0.5.0;

contract CollectionRegistry {

    address public manufacturer;
    string public name;
    uint public maxItems;
    address[] public maintainers;

    item[] public items;

    event itemAdded(address publicKey, string identifier, string metaData);

    struct item {
        address publicKey;
        string identifier;
        string metaData;
    }

    modifier deployConditions(string memory _name, address[] memory _maintainers) {
        require(_maintainers.length > 0, "maintainers list mustn't be empty");
        require(bytes(_name).length > 0, "name may not be empty");
        _;
    }

    modifier maintainer() {
        bool isMaintainer = false;
        for (uint i = 0; i < maintainers.length; i++) {
            if (maintainers[i] == msg.sender) {
                isMaintainer = true;
            }
        }
        require(isMaintainer, "not a maintainer");
        _;
    }

    modifier itemConditions(address _publicKey, string memory _identifier) {
        if (maxItems != 0) {
            require(items.length < maxItems, "collection reached max amount of items");
        }
        require(bytes(_identifier).length > 0, "identifier mustn't be empty");
        for (uint i = 0; i < items.length; i++) {
            if (items[i].publicKey == _publicKey) {
                revert("item already exists in collection");
            }
            if (keccak256(abi.encodePacked(items[i].identifier)) == keccak256(abi.encodePacked(_identifier))) {
                revert("item already exists in collection");
            }
        }
        _;
    }

    constructor(string memory _name, uint _maxItems, address[] memory _maintainers) public deployConditions(_name, _maintainers) {
        manufacturer = msg.sender;
        name = _name;
        maxItems = _maxItems;
        maintainers = _maintainers;
    }

    function addItem(address _publicKey, string memory _identifier, string memory _metaData)
            public maintainer itemConditions(_publicKey, _identifier) {
        item memory newItem;
        newItem.publicKey = _publicKey;
        newItem.identifier = _identifier;
        newItem.metaData = _metaData;
        items.push(newItem);
        emit itemAdded(_publicKey, _identifier, _metaData);
    }

    function checkItem(address _publicKey) public view returns (bool) {
        for (uint i = 0; i < items.length; i++) {
            if (items[i].publicKey == _publicKey) {
                return true;
            }
        }
        return false;
    }
}
