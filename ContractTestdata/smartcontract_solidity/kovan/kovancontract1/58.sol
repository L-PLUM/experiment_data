/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^0.5.4;
contract ERC20 {
    function transfer(address to, uint256 value) public returns(bool);
}
contract ERC721 {
    function transferFrom(address from, address to, uint256 tokenId) public returns(bool);
}
contract ERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);
}
contract Vault is ERC721Receiver {
    mapping(address => bool) _granted;
    constructor() public {
        _granted[msg.sender] = true;
    }
    modifier onlyAdmin() {
        require(_granted[msg.sender]);
        _;
    }
    modifier payLoad(address account) {
        require(account != address(0) && address(this) != account);
        _;
    }
    function () external payable {}
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data) public returns(bytes4) {
        operator;
        from;
        tokenId;
        data;
        return this.onERC721Received.selector;
    }
    function receive() public payable returns(bool) {
        require(msg.value > 0);
        return true;
    }
    function send(address payable to, uint256 value) public onlyAdmin payLoad(to) returns(bool) {
        require(value > 0 && value <= address(this).balance);
        to.transfer(value);
        return true;
    }
    function transfer(ERC20 token, address to, uint256 value) public onlyAdmin payLoad(to) returns(bool) {
        if (value > 0) token.transfer(to, value);
        return true;
    }
    function transferFrom(ERC721 token, address to, uint256 tokenId) public onlyAdmin payLoad(to) returns(bool) {
        token.transferFrom(address(this), to, tokenId);
        return true;
    }
    function grantAdmin(address account) public onlyAdmin payLoad(account) returns(bool) {
        if (!_granted[account]) _granted[account] = true;
        return true;
    }
    function renounce() public onlyAdmin returns(bool) {
        _granted[msg.sender] = false;
        return true;
    }
}
