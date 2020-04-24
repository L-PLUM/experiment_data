/**
 *Submitted for verification at Etherscan.io on 2019-07-30
*/

pragma solidity >=0.5.0;

contract ERC20Like {
    function transfer(address to, uint value) public returns (bool success);
    function transferFrom(address from, address to, uint value) public returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);
}

contract Bridge {
    address owner;
    
    address public manager;
    ERC20Like public token;
    
    mapping (address => address) mappedAddresses;
    
    //owner able.
    modifier ownable() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    //manager able.
    modifier manageable() {
        require(msg.sender == manager);
        _;
    }

    constructor(address _manager, address _token) public {
        owner = msg.sender;
        manager = _manager;
        token = ERC20Like(_token);
    }
    
    function setManager(address _manager) public ownable {
        require(_manager != address(0));

        if(_manager != manager) {
            manager = _manager;
        }
    }

    function unlock(address _receiver, uint256 _amount) public manageable returns(bool) {
        return token.transfer(_receiver, _amount);
    }
    
    //合成一个交易来做是为了防止在转账和设置映射地址两个交易之间被事件监听程序捕获到转账交易。
    function setMappedAddress(address _to, uint256 _amount) public {
        require(token.allowance(msg.sender, address(this)) >= _amount, "Not allowance");
        token.transferFrom(msg.sender, address(this), _amount);
        mappedAddresses[msg.sender] = _to;
    }
    
    function getMappedAddress(address _account) public view returns (address) {
        address mapped = mappedAddresses[_account];
        return mapped;  //may be address(0);
    }
}
