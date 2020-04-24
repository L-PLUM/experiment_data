/**
 *Submitted for verification at Etherscan.io on 2019-07-12
*/

pragma solidity ^0.5.0;

contract AdministratorInterface {
    event NewAdmin(address indexed _address);
    event NewOwner(address indexed _owner);
    
    mapping(address => bool) _admins;
    uint256 _fundToAdmin = 0.1 ether;
    address _owner;
    
    modifier onlyOwner {
        if (msg.sender != _owner){
            revert();
        }
        _;
    }
    
    modifier onlyAdmin {
        if (_admins[msg.sender] != true && msg.sender == _owner)
            revert();
        _;
    }
    
    /*
     * Deployment account will become the initial owner by default
    */
    constructor() public {
        _owner = msg.sender;
    }
    
    function setOwner(address newOwner) public onlyOwner returns(bool) {
        _owner = newOwner;
        emit NewOwner(_owner);
        return true;
    }
    
    /*
     * Set administrator permission. grants some ethers to user for operation cost
    */
    function setAdmin(address payable user) public onlyOwner returns(bool) {
        _admins[user] = true;
        
        if (_fundToAdmin > 0) {
            if (!user.send(_fundToAdmin)) {
                revert();
            }
        }
        
        emit NewAdmin(user);
        return true;
    }
    
    function revokeAdmin(address user) public onlyOwner {
        _admins[user] = false;
    }
    
    function isAdmin(address user) public view returns(bool) {
        return _admins[user];
    }
    
    function isOwner(address user) public view returns(bool) {
        return _owner == user;
    }
    
    function getOwner() public view returns(address) {
        return (_owner);
    }
}

contract Subscription is AdministratorInterface {
    event NewSubscriber(address indexed _address);
    event NewPendingSubscriber(address indexed _address, uint256 _expired);
    
    mapping(address => bool) _subscribers;
    mapping(address => uint256) _pendingSubcribers;
    
    bool _approvalPolicy;
    string _name;
    
    constructor(string memory name, bool approvalPolicy) public {
        _name = name;
        _approvalPolicy = approvalPolicy;
    }
    
    function getInfo() public view returns(string memory name, bool approvalPolicy) {
        return (_name, _approvalPolicy);
    } 
    
    function subcribe() public returns (bool) {
        address user = msg.sender;
        
        //if already subcribed, revert
        if (_subscribers[user]){
           revert(); 
        }
        
        if (_approvalPolicy){
            _pendingSubcribers[user] = now + 1 days;
            emit NewPendingSubscriber(user, _pendingSubcribers[user]);
        } else {
            _subscribers[user] = true;
            emit NewSubscriber(user);
        }
        
        return true;
    }
    
    function approveSubscription(address user) public returns(bool) {
        if (_pendingSubcribers[user] <= now) {
            revert();
        }
        
        _subscribers[user] = true;
        _pendingSubcribers[user] = 0;
        return true;
    }
    
    function rejectSubscription(address user) public returns(bool) {
        if (_pendingSubcribers[user] <= now) {
            revert();
        }
        
        _pendingSubcribers[user] = 0;
        return true;
    }
    
    function revokeSubscription(address user) public returns(bool) {
        if (!_subscribers[user]){
            revert();
        }
        
        _pendingSubcribers[user] = 0;
        _subscribers[user] = false;
        
        return true;
    }
    
    function hasSubscription(address user) public view returns(bool) {
        return _subscribers[user];
    }
    
    function() onlyOwner payable external {
        /*
        * Only owner payable
        */
    }
}
