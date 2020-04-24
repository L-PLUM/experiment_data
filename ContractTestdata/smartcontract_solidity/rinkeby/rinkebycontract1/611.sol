/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

pragma solidity ^0.5.2;

contract WishToken {
    string public name = 'WishListCoin';
    string public symbol = 'WLC';
    uint8 public decimals = 0;
    
    uint256 public totalSupply;
    
    //this address is the owner
    address payable public owner;
    
    //service admins here
    address[] public serviceAdmins;
    
    //price admin here (can only change price)
    address priceAdmin;
    
    //the next wish id to be sent when buying wishes
    uint256 public nextWishId = 1;
    
    //this is the price in WEI
    uint256 public wishPrice;
    
    //a list of all ballances by address
    mapping (address => uint256)   public balanceOf;
    
    //a list of all wishes onwned by address
    mapping (address => uint256[]) public wishesOwnedBy;
    
    //a list of all wishes exchanged by address
    mapping (address => uint256[]) public wishesExchangedBy;
    mapping (address => uint256)   public wishesExchangedByCount;
    
    event Exchange(address indexed from, uint256 wishId);
    event TransferSpecificWish(address indexed from, address indexed to, uint256 wishId);
    event Buy(address indexed from, uint256 amount, uint256 fromWishId, uint256 toWishId);
    
    //ensures that the caller of the function is an owner
    modifier onlyOwner {
        require(msg.sender == owner, 'You need to be the owner to do that!');
        _;
    }
    
    constructor (uint256 _initialSupply, address payable _owner, uint256 _initialPrice) public {
        owner = _owner;
        
        totalSupply = _initialSupply;
        balanceOf[owner] = totalSupply;
        
        wishPrice = _initialPrice;
        //0x80Ef7935cfB9D13b1FD0D0edEAcd9229E4D2Ebe7 - my wallet
        //1000000000000000000 - wish price (1 ETH)
        //100000000000000000  - wish price (0.1 ETH)
        //10000000000000000   - wish price (0.01 ETH)
        
        //166666666666666667  - wish if ETH = 120USD
        
        //1000000 - _initialSupply
    }
    
    //the price is in WEI
    function setWishPriceInWEI(uint256 _newPrice) public {
        require((msg.sender == owner || msg.sender == priceAdmin), 'You cannot do that!');
        wishPrice = _newPrice;
    }
    
    //change the price aadmin address
    function changePriceAdmin(address _newPriceAdmin) onlyOwner public {
        priceAdmin = _newPriceAdmin;
    }
    
    //add a service admin address
    function addServiceAdmin(address _address) onlyOwner public {
        serviceAdmins.push(_address);
    }
    
    //mint more wishes
    function mint(uint256 _amount) onlyOwner public {
        require (_amount > 0, 'Amount must be bigger than 0!');
        totalSupply += _amount;
        balanceOf[owner] += _amount;
    }
    
    //exchange ETH for wishes; calculates the nubmer of wishes for the given value
    //returns the excessive ETH (if any)
    function buy() payable public  {
        require(msg.value >= wishPrice, "You did't send enough ETH");
        
        uint256 amount = msg.value / wishPrice;
        
        _transfer(owner, msg.sender, amount);
        
        _addWishesToAddress(msg.sender, amount);
        
        emit Buy(msg.sender, amount, nextWishId - amount, nextWishId - 1);
        
        //transfer ETH to owner
        owner.transfer((amount * wishPrice));
        
        //returns excessive ETH
        msg.sender.transfer(msg.value - (amount * wishPrice));
    }

    //change the ballances of the addresses when transfering a number of wishes
    function _transfer(address _from, address _to, uint256 _amount) internal {
        require(balanceOf[_from] >= _amount);                // Check if the sender has enough
        require(balanceOf[_to] + _amount >= balanceOf[_to]); // Check for overflows
        
        balanceOf[_from] -= _amount;                         // Subtract from the sender
        balanceOf[_to] += _amount;                           // Add the same to the recipient
    }
    
    //adds the specified number of wishes to the specified address
    function _addWishesToAddress(address _to, uint256 _amount) internal {
        for (uint i = 0; i < _amount; i++) {
            wishesOwnedBy[_to].push(nextWishId + i);
        }
        
        nextWishId += _amount;
    }

    //allows an owner to transfer a number of wishes to a specified address
    function ownerTransfer(address _to, uint256 _amount) onlyOwner public returns (bool success) {
        _transfer(owner, msg.sender, _amount);
        
        _addWishesToAddress(_to, _amount);
        
        return true;
    }
    
    //allows users to transfer wishes to another address
    //can only trasnfer one wish at a time
    //user must have the wish in order to transfer it
    function transferSpecificWish(address _to, uint _wishId) public returns (bool success) {
        bool valueExists = false;
        uint valueKey = 0;
        for (uint i = 0; i < wishesOwnedBy[msg.sender].length; i++) {
            if (wishesOwnedBy[msg.sender][i] == _wishId) {
                valueExists = true;
                valueKey = i;
                break;
            }
        }
        
        require(valueExists == true, 'You do not own this token!');
        
        _transfer(msg.sender, _to, 1);
        
        delete wishesOwnedBy[msg.sender][valueKey];
        wishesOwnedBy[_to].push(_wishId);
        
        emit TransferSpecificWish(msg.sender, _to, _wishId);
        
        return true;   
    }
    
    //allows user to destroy a specified wish, sending it to the wishesExchangeBy register
    //this would allow a user to claim his prize for the destroyed wish
    function exchange(uint _wishId) public returns (bool success) {
        require(balanceOf[msg.sender] >= 1);
        
        bool valueExists = false;
        uint valueKey = 0;
        for (uint i = 0; i < wishesOwnedBy[msg.sender].length; i++) {
            if (wishesOwnedBy[msg.sender][i] == _wishId) {
                valueExists = true;
                valueKey = i;
                break;
            }
        }
        
        require(valueExists == true, 'You do not own this token!');
        
        balanceOf[msg.sender] -= 1;
        
        delete wishesOwnedBy[msg.sender][valueKey];
        
        wishesExchangedByCount[msg.sender] += 1;
        
        wishesExchangedBy[msg.sender].push(_wishId);
        
        emit Exchange(msg.sender, _wishId);
        
        return true; 
    }
}
