/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

// File: contracts/ZyneraStorage.sol

pragma solidity ^0.4.25;

contract ZyneraStorage {
    uint public count;
    address internal owner;
    bytes32 internal name;
    uint internal pt;
    uint internal mp;
    uint internal coef;
    bytes32 internal domain;
    uint internal frequency;
    uint internal customer_id;

    constructor(bytes32 _name, uint _pt, uint _mp, uint _coef, bytes32 _domain, uint _frequency, uint _customer_id) public {
        owner = msg.sender;
        name = _name;
        pt = _pt;
        mp = _mp;
        coef = _coef;
        domain = _domain;
        frequency = _frequency;
        customer_id = _customer_id;
    }

    event DataSourceEvent(
        uint indexed index,
        address indexed sender,
        uint indexed timestamp,
        bytes32 name,
        uint pt,
        uint mp,
        uint coef,
        bytes32 domain,
        uint frequency,
        uint customer_id,
        uint256 score,
        uint256 c_v,
        uint256 claim_v
    );

    function getCustomerValue(uint _pt, uint _score) public view returns (uint256)  {
        if (_pt == 1) {
            return _score * 100;
        }
        else if (_pt == 2) {
            return _score * 150;
        }
        else if (_pt == 3) {
            return _score * 200;
        }
    }

    function getClaimValue(uint _pt, uint256 _c_v, uint _mp, uint _coef) public view returns (uint256) {
        if (_pt == 1) {
            return _c_v * uint256(_mp);
        }
        else if (_pt == 2) {
            return _c_v * uint256(_mp);
        }
        else if (_pt == 3) {
            return (_c_v * uint256(_mp)) / uint256(_coef);
        }
    }

    function saveResult(uint _timestamp, uint _score) external {
        uint256 c_v = getCustomerValue(pt, _score);
        uint256 claim_v = getClaimValue(pt, c_v, mp, coef);

        emit DataSourceEvent(count, msg.sender, _timestamp, name, pt, mp, coef, domain, frequency, customer_id, _score, c_v, claim_v);
        count++;
    }

    function updateParameters(bytes32 _name, uint _pt, uint _mp, uint _coef, bytes32 _domain, uint _frequency) external {
        name = _name;
        pt = _pt;
        mp = _mp;
        coef = _coef;
        domain = _domain;
        frequency = _frequency;
    }
}

// File: contracts/ZyneraStorageFactory.sol

pragma solidity ^0.4.25;


contract ZyneraStorageFactory {
    address[] public zyneraStorages;

    address public owner;

    function() public payable {revert();}

    constructor() public {
        owner = msg.sender;
    }

    event CreateStorageEvent(
        uint indexed customer_id,
        address indexed storage_address
    );

    function createZyneraStorage(bytes32 _name, uint _pt, uint _mp, uint _coef, bytes32 _domain, uint _frequency, uint _customer_id) public
    returns (address) {
        ZyneraStorage zyneraStorage = new ZyneraStorage(_name, _pt, _mp, _coef, _domain, _frequency, _customer_id);
        zyneraStorages.push(address(zyneraStorage));
        emit CreateStorageEvent(_customer_id, address(zyneraStorage));
        return address(zyneraStorage);
    }

    function getZyneraStorages() public view
    returns (address[]) {
        return zyneraStorages;
    }

    function destroy(address target) public {
        require(msg.sender == owner);
        selfdestruct(target);
    }
}
