/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.5.4;
contract Mintable {
    function mint(address to, uint256 tokenId) public returns(bool);
    function burn(address owner, uint256 tokenId) public returns(bool);
}
contract Authority {
    mapping(uint256 => uint256) private _valueOf;
    address public author;
    Mintable public token;
    uint256 private nextId;
    uint256 private _nextPrice;
    uint256 private _capitalized;
    constructor(address authorAccount, address tokenAddress, uint256 genesisId, uint256 genesisPrice) public {
        author = authorAccount;
        token = Mintable(tokenAddress);
        nextId = genesisId;
        _nextPrice = genesisPrice;
        _valueOf[0] = 0;
    }
    function () external payable {
        if (msg.value >= price()) mint();
    }
    function changeAuthor(address newAuthor) public returns(bool) {
        require(msg.sender == author);
        require(newAuthor != address(0) && address(this) != newAuthor);
        author = newAuthor;
        return true;
    }
    function price() public view returns(uint256) {
        return _nextPrice + 4567890123456789;
    }
    function priceOf(uint256 tokenId) public view returns(uint256) {
        return _valueOf[tokenId];
    }
    function capitalized() public view returns(uint256) {
        return _capitalized;
    }
    function uncollected() public view returns(uint256) {
        return address(this).balance - _capitalized;
    }
    function mint() public payable returns(bool) {
        bytes32 _seed = keccak256(abi.encodeWithSignature("mintURI(uint256,address,uint256,uint256)", nextId, msg.sender, msg.value, _nextPrice));
        uint256 _addition;
        bytes memory _bytes = new bytes(32);
        require(msg.value >= price());
        token.mint(msg.sender, nextId);
        _valueOf[nextId] = _nextPrice;
        _capitalized += _nextPrice;
        for (uint i = 0; i < 32; i++) _bytes[i] = _seed[i];
        assembly { _addition := mload(add(_bytes,add(0x20, 0))) }
        _nextPrice += uint(uint48(_addition));
        nextId++;
        return true;
    }
    function burn(uint256 tokenId) public returns(bool) {
        require(_valueOf[tokenId] > 0);
        token.burn(msg.sender, tokenId);
        msg.sender.transfer(_valueOf[tokenId]);
        _capitalized -= _valueOf[tokenId];
        _valueOf[tokenId] = 0;
        return true;
    }
    function collect() public returns(bool) {
        require(msg.sender == author && uncollected() > 0);
        msg.sender.transfer(uncollected());
        return true;
    }
}
