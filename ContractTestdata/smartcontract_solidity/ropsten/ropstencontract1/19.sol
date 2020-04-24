/**
 *Submitted for verification at Etherscan.io on 2019-02-23
*/

pragma solidity 0.5.4;


contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


contract SimpleBank is Ownable {
    mapping (address => uint256) private balance;
    bool private bankOpen = true;
    
    modifier bankOpened() {
        require(isOwner() || bankOpen);
        _;
    }
    
    function setBankState(bool _bankOpen) external onlyOwner {
        bankOpen = _bankOpen;
    }
    
    function deposit(uint256 _amount) external payable bankOpened {
        require(msg.value == _amount);
        require(balance[msg.sender] + _amount > balance[msg.sender]);
        
        balance[msg.sender] += _amount;
    }
    
    function withdraw(uint256 _amount) external bankOpened {
        require(balance[msg.sender] >= _amount);
        
        balance[msg.sender] -= _amount;
        msg.sender.transfer(_amount);
    }
    
    function transfer(address _to, uint256 _amount) external bankOpened {
        require(balance[msg.sender] >= _amount);
        require(balance[_to] + _amount > balance[_to]);
        
        balance[msg.sender] -= _amount;
        balance[_to] += _amount;
    }
    
    function getBalance(address _user) external view bankOpened returns (uint256) {
        return balance[_user];
    }
}
