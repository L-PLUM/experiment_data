/**
 *Submitted for verification at Etherscan.io on 2018-12-22
*/

pragma solidity >=0.4.22 <0.6.0;
contract ERC20Interface {
    function totalSupply() public view returns (uint);
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract SplitMeUp {
    struct PKHolder{
        string username;
        bool paid;
        uint reward;
        uint security;
    }
    // stores all those who are storing the keys and have paid or not
    mapping(address => PKHolder) privateKeyHolders;
    // stores the acount number of all those who are storing the keys
    mapping(bytes32 => address) keyStorageAccounts;
    address owner;
    address ERC20Address = 0xC4375B7De8af5a38a93548eb8453a498222C4fF2;
    uint numberOfKeyHolders;
    uint numberOfKeyStores;
    // constant variables
    uint INITIALPAY = 2 * 10 ** 18;
    uint REWARD = 0.5 * 10 ** 18;
    uint SECURITY = 1 * 10 ** 18;
    uint ALLOWANCE = 9 * 10 ** 25;
    
    // getter setter for these variables
    function getInitialPay() view public returns(uint){
        require(msg.sender == owner);
        return INITIALPAY;
    }
    
    function setInitialPay(uint _newPay) public{
        require(msg.sender == owner);
        INITIALPAY = _newPay;
    }
    
    function getReward() view public returns(uint){
        require(msg.sender == owner);
        return REWARD;
    }
    
    function setReward(uint _newReward) public{
        require(msg.sender == owner);
        REWARD = _newReward;
    }
    
    function getSecurity() view public returns(uint){
        require(msg.sender == owner);
        return SECURITY;
    }
    
    function setSecurity(uint _newSecurity) public{
        require(msg.sender == owner);
        SECURITY = _newSecurity;
    }
    
    function getAllowance() view public returns(uint){
        require(msg.sender == owner);
        return ALLOWANCE;
    }
    
    function setAllowance(uint _newAllowance) public{
        require(msg.sender == owner);
        ALLOWANCE = _newAllowance;
    }
    
    function getNumberOfKeyHolders() view public returns(uint){
        return numberOfKeyHolders;
    }
    
    function getNumberOfKeyStores() view public returns(uint){
        return numberOfKeyStores;
    }
    
    //utils
    function equal(string _a, string _b)  private pure returns (bool){
        return compare(_a, _b) == 0;
    }
    
    function compare(string _a, string _b) private pure returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        //@todo unroll the loop into increments of 32 and do full 32 byte comparisons
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }
    
    function convert(string key) private pure returns(bytes32 ret) {
        if (bytes(key).length > 32) {
            revert();
        }

        assembly {
            ret := mload(add(key, 32))
        }
    }
    
    ERC20Interface ERC20Contract = ERC20Interface(ERC20Address);
    
    constructor() public{
        owner = msg.sender;
        numberOfKeyStores = 0;
        numberOfKeyHolders = 0;
    }
    
    function addNewStorageAccount(string _username) public{
        address holder = msg.sender;
        keyStorageAccounts[convert(_username)] = holder;
        numberOfKeyStores++;
    }
    
    function addPrivateKeyHolder(string _username) public{
        address currAddress = msg.sender;
        require(ERC20Contract.balanceOf(currAddress) >= INITIALPAY);
        require(ERC20Contract.allowance(currAddress, this) >= ALLOWANCE);
        PKHolder memory current = PKHolder({username : _username, paid : true, reward : REWARD, security : SECURITY});
        ERC20Contract.transferFrom(currAddress, this, INITIALPAY);
        privateKeyHolders[currAddress] = current;
        numberOfKeyHolders++;
    }
    
    function privateKeyRetreived(string _holder, string _sender1, string _sender2) public{
        address currAddress = msg.sender;
        PKHolder memory currentUser = privateKeyHolders[currAddress];
        require(currentUser.paid);
        require(equal(currentUser.username, _holder));
        ERC20Contract.transfer(msg.sender, currentUser.security);
        ERC20Contract.transfer(keyStorageAccounts[convert(_sender1)], currentUser.reward);
        ERC20Contract.transfer(keyStorageAccounts[convert(_sender2)], currentUser.reward);
        currentUser.paid = false;
        numberOfKeyHolders--;
    }
    
    function withdraw(uint _amount) public{
        require(msg.sender == owner);
        ERC20Contract.transfer(msg.sender, _amount);
    }
}
