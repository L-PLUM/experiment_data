/**
 *Submitted for verification at Etherscan.io on 2019-02-16
*/

pragma solidity ^0.5.0;

contract CollectionDomainRegistry {

    address owner;
    string public collectionDomains = "";

    event domainAdded(string domainName);

    modifier onlyOwner() {
        require(msg.sender == owner, "must be owner of contract");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function addDomain(string memory _domainName) public onlyOwner {
        if (bytes(collectionDomains).length > 0) {
            collectionDomains = strConcat(collectionDomains, ",", _domainName);
        } else {
            collectionDomains = _domainName;
        }
        emit domainAdded(_domainName);
    }

    // https://ethereum.stackexchange.com/questions/729/how-to-concatenate-strings-in-solidity
    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e)
            internal pure returns (string memory _concatenatedString) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        uint i = 0;
        for (i = 0; i < _ba.length; i++) {
            babcde[k++] = _ba[i];
        }
        for (i = 0; i < _bb.length; i++) {
            babcde[k++] = _bb[i];
        }
        for (i = 0; i < _bc.length; i++) {
            babcde[k++] = _bc[i];
        }
        for (i = 0; i < _bd.length; i++) {
            babcde[k++] = _bd[i];
        }
        for (i = 0; i < _be.length; i++) {
            babcde[k++] = _be[i];
        }
        return string(babcde);
    }

    function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory _concatenatedString) {
        return strConcat(_a, _b, _c, "", "");
    }
}
