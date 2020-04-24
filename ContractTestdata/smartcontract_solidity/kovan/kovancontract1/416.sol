/**
 *Submitted for verification at Etherscan.io on 2019-01-30
*/

pragma solidity 0.5.0;

// File: node_modules/openzeppelin-solidity/contracts/access/Roles.sol

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

// File: node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: contracts/ListUtils.sol

/**
 * @title ListUtils - a library to help manage lists
 * @author Mark D. Thompson <[email protected]>
 */
library ListUtils {
    /**
     * @notice Reorders an array after deleting an item by swapping with the last item in the list
     * @dev This method disregards order in the list
     * @param _arr - an address storage array to rearrange after deleting an item
     * @param _index - the index of the item to delete
     * @return returns the modified array
     */
    function AddressSwapSort(address[] storage _arr, uint _index) internal returns(address[] memory){
        _arr[_index] = _arr[_arr.length - 1];
        delete _arr[_arr.length - 1];
        _arr.length--;

        return _arr;
    }

    /**
     * @notice Reorders an array after deleting an item by sliding values down the list from the end to the _index
     * @dev Preserves order, but is expensive on gas with bigger lists
     * @param _arr - an address storage array to rearrange after deleting an item
     * @param _index - the index of the item to delete
     * @return returns the modified array
     */
    function AddressReorderSort(address[] storage _arr, uint _index) internal returns(address[] memory){
        for(uint i = _index; i < _arr.length - 1; i++) {
            _arr[_index] = _arr[_index + 1];
        }
        delete _arr[_arr.length - 1];
        _arr.length--;

        return _arr;
    }

    /**
     * @notice Reorders an array after deleting an item by swapping with the last item in the list
     * @dev Preserves order, but is expensive on gas with bigger lists
     * @param _arr - a uint storage array to rearrange after deleting an item
     * @param _index - the index of the item to delete
     * @return returns the modified array
     */
    function UintSwapSort(address[] storage _arr, uint _index) internal returns(address[] memory){
        _arr[_index] = _arr[_arr.length - 1];
        delete _arr[_arr.length - 1];
        _arr.length--;

        return _arr;
    }

    /**
     * @notice Reorders an array after deleting an item by sliding values down the list from the end to the _index
     * @dev Preserves order, but is expensive on gas with bigger lists
     * @param _arr - a uint storage array to rearrange after deleting an item
     * @param _index - the index of the item to delete
     * @return returns the modified array
     */

    function UintReorderSort(uint[] storage _arr, uint _index) internal returns(uint[] memory){
        for(uint i = _index; i < _arr.length - 1; i++) {
            _arr[_index] = _arr[_index + 1];
        }
        delete _arr[_arr.length - 1];
        _arr.length--;

        return _arr;
    }
}

// File: contracts/Marketplace.sol

/// @notice used for access control on functions

/// @notice used for buyItem & withdraw functions

/// @notice used for array/list reordering following item deletion


/**
@title Marketplace - A Marketplace demonstration project for the 2018-19 ConsenSys Developer Bootcamp
@author Mark D. Thompson <[email protected]>
@notice This contract is intended as the bootcamp final project demonstration
@dev This contract uses OpenZeppelin's Roles.sol library for ACL
@dev It also uses my custom library ListUtils.sol for account list management functions
*/
contract Marketplace{
    using Roles for Roles.Role;
    using SafeMath for uint;
    /**
     * storage variables
     */
    /// marketplace owner
    address payable private owner;

    /// circuit breaker
    bool private stopped = false;

    /// acl roles
    Roles.Role private admins;
    Roles.Role private shopOwners;

    /// account lists
    address[] private adminAccts;
    uint private maxAdmins = 10;
    address[] private shopOwnerAccts;
    uint private maxShopOwners = 10;

    /// shop data structures
    struct Shop {
        uint shopID;
        address shopOwner;
        string name;
        string category;
        uint balance;
    }
    Shop[] public shops;
    uint private shopCount = 0;
    uint private maxShops = 30;
    mapping(address => uint) private ownerShopCount;

    /// item data structures
    /// item states
    enum State {
      ForSale,
      Sold,
      Shipped,
      Received,
      Archived
    }

    /// Item object structure
    struct Item {
        uint shopID;
        uint sku;
        string name;
        string description;
        string ipfsImageHash;
        uint price;
        State state;
        address payable seller;
        address payable buyer;
    }
    /// master item list
    Item[] public items;
    /// count of all items
    uint private itemCount = 0;
    uint private maxItems = 360;
    /// shop item list mapping
    mapping(uint => uint) private shopItemCount;
    /// seller item list mapping
    mapping(address => uint) private sellerItemCount;
    /// customer item list mapping
    mapping(address => uint) private customerItemCount;

    /**
     * events
     */
    /// ciruit breaker
    event ToggledCircuit(bool _stopped);

    /// access
    event AddedAdmin(address _newAdmin);
    event RemovedAdminAccess(address addr);
    event AddedShopOwner(address _shopOwner);
    event RemovedShopOwnerAccess(address addr);

    /// shop CRUD
    event CreatedShop(uint _shopID);
    event EditedShop(uint _shopID);
    event WithdrewFunds(uint _shipID, uint _amount);

    /// inventory mgmt
    event AddedItemToShop(uint _sku);
    event EditedItem(uint _sku);
    event SoldItem(uint _sku);
    event ShippedItem(uint _sku);
    event ReceivedItem(uint _sku);
    event ArchivedItem(uint _sku);

    /**
     * modifiers
     */
    /// circuit breaker pattern run-only-when-not-stopped modifier
    modifier stopInEmergency {
        if (!stopped) {
            _;
        } else {
            revert("Operation failed. Circuit is stopped.");
        }
    }

    /// circuit breaker pattern run-only-when-stopped modifier
    modifier runInEmergency {
        if (stopped) {
            _;
        } else {
            revert("Operation failed. Circuit must be stopped before running.");
        }
    }

    /// ownable pattern run only if caller is owner
    modifier isOwner(){
        require(msg.sender == owner, "Operation failed. Caller must be owner.");
        _;
    }

    /// acl pattern run only if caller is admin
    modifier isAdmin() {
        require(Roles.has(admins, msg.sender),"Operation failed. Caller must be admin.");
        _;
    }

    /// acl pattern run only if caller is shopowner
    modifier isShopOwner() {
        require(Roles.has(shopOwners, msg.sender),"Operation failed. Caller must be shop owner.");
        _;
    }

    /// acl pattern run only if caller is admin-or-shopowner
    modifier isAdminOrOwner(address _owner) {
        require(Roles.has(admins, msg.sender) || (_owner == msg.sender), "caller must be admin or owner.");
        _;
    }

    /// authorization pattern run only if address belongs to sender
    modifier verifyCaller(address _address) {
        require (msg.sender == _address, "address must belong to sender.");
        _;
    }

    /// ensures payment covers price
    modifier paidEnough(uint _price) {
        require(msg.value >= _price, "value must be greater than or equal to price.");
        _;
    }

    /// make change if overpaid
    modifier checkValue(uint _sku) {
        //refund change
        _;
        uint _price = items[_sku].price;
        uint amountToRefund = msg.value - _price;
        items[_sku].buyer.transfer(amountToRefund);
    }

    /// state machine pattern run only if state is ForSale
    modifier forSale(uint _sku) {
        require(items[_sku].state == State.ForSale, "item must be for sale.");
        _;
    }

    /// state machine pattern run only if state is Sold
    modifier sold(uint _sku) {
        require(items[_sku].state == State.Sold, "item must be already sold.");
        _;
    }

    /// state machine pattern run only if state is Shipped
    modifier shipped(uint _sku) {
        require(items[_sku].state == State.Shipped,"item must have been shipped.");
        _;
    }

    /// state machine pattern run only if state is Received
    modifier received(uint _sku) {
        require(items[_sku].state == State.Received,"item must have been received.");
        _;
    }

    /**
    @notice Contract constructor
    @dev Assign owner, create & initialize acl admin role
    */
    constructor() public {
        owner = msg.sender;
        Roles.add(admins, msg.sender);
        adminAccts.push(owner);
    }

    /**
     * functions
    */
    /**

    @notice BIG RED BUTTON! Mortal lifecycle pattern
    @dev Clears all storage data on evm & pay out to owner
    @dev Only owner can run it when circuit breaker is engaged
    */
    function destroy() public isOwner runInEmergency {
        selfdestruct(owner);
    }

    /**
    @notice BIG Red BUTTON! Mortal lifecycle pattern
    @param _recipient address for payout recipient
    @dev Clears all storage data on evm and pay out to _recipient
    @dev Only owner can run it when circuit breaker is engaged
    */
    function destroyAndSend(address payable _recipient) public isOwner runInEmergency {
        selfdestruct(_recipient);
    }

    /// Setters

    /**
    @notice Toggles circuit breaker security pattern on & off
    @dev set to true in emergency, false for normal operation
    */
    function toggleCircuitBreaker() public isAdmin {
        stopped = !stopped;

        emit ToggledCircuit(stopped);
    }

    /**
    @notice Add a new admin acct
    @param _newAdmin address for the new admin
    @dev Only admins should be able to add more admins
    */
    function addAdmin(address _newAdmin) public isAdmin stopInEmergency {
        require(adminAccts.length < maxAdmins, 'Maximum number of admin accounts reached.');
        Roles.add(admins, _newAdmin);
        adminAccts.push(_newAdmin);

        emit AddedAdmin(_newAdmin);
    }

    /**
    @notice Remove an admin's permissions and account from admin list
    @dev Only admins can remove an admin's permissions
    */
    function removeAdmin(uint _index) public isAdmin {
        require(adminAccts[_index] != owner, "Can't remove admin perms from owner.");
        Roles.remove(admins, adminAccts[_index]);

        delete adminAccts[_index];
        adminAccts = ListUtils.AddressReorderSort(adminAccts, _index);
        emit RemovedAdminAccess(adminAccts[_index]);
    }

    /**
    @notice Add a new shopowner account
    @dev Only admins can add a new shopowner account
    @dev This function shoulb be restricted in an emergency
    */
    function addShopOwner(address _shopOwner) public isAdmin stopInEmergency {
        require(shopOwnerAccts.length < maxShopOwners, 'Maximum number of shop owners reached.');
        Roles.add(shopOwners, _shopOwner);
        shopOwnerAccts.push(_shopOwner);

        emit AddedShopOwner(_shopOwner);
    }

    /**
    @notice Remove a shopowner's permissions and account
    @dev Only admins can remove shopowner account
    @param _index a uint index to the shopowners account list
    */
    function removeShopOwner(uint _index) public isAdmin{
        Roles.remove(shopOwners, shopOwnerAccts[_index]);

        delete shopOwnerAccts[_index];
        shopOwnerAccts = ListUtils.AddressReorderSort(shopOwnerAccts, _index);
        emit RemovedShopOwnerAccess(shopOwnerAccts[_index]);
    }

    /**
    @notice Create a new shop
    @dev Only shopowners can create a shop
    @param _name a required string name for the shop
    @param _category an optional string name to categorize the shop
    */
    function createShop(string memory _name, string memory _category) public isShopOwner stopInEmergency{
        require(shopCount < maxShops, 'Maximum number of shops reached.');
        require(bytes(_name).length > 0, "Operation failed. Name cannot be empty.");

        shops.push(Shop({shopID:shopCount, shopOwner:msg.sender, name:_name, category:_category, balance:0}));
        ownerShopCount[msg.sender]++;
        shopCount++;

        emit CreatedShop(shops.length-1);
    }

    /**
    @notice Edit a shop's details
    @dev Only the shop's shopowner can edit a shop
    @param _shopID a uint index to look up the shop in the shop list
    @param _name a required string name for the shop
    @param _category an optional string name to categorize the shop
    */
    function editShop(uint _shopID, string memory _name, string memory _category) public stopInEmergency{
        require(shops[_shopID].shopOwner == msg.sender, "Operation failed. Must be shopowner to edit shop.");
        require(bytes(_name).length > 0, "name cannot be empty.");

        shops[_shopID].name = _name;
        shops[_shopID].category = _category;

        emit EditedShop(_shopID);
    }

    /**
    @notice Withdraw a shop's balance
    @dev Only the shop's shopowner can withdraw funds
    @param _shopID a uint index to look up the shop in the shop list
    */
    function withdrawFunds(uint _shopID) public stopInEmergency{
        require(shops[_shopID].shopOwner == msg.sender, "Operation failed. Must be shopowner to edit shop.");
        require(shops[_shopID].balance > 0, "balance must be greater than 0");

        uint amount = shops[_shopID].balance;
        shops[_shopID].balance = 0;
        msg.sender.transfer(amount);

        emit WithdrewFunds(_shopID, amount);
    }

    /**
    @notice Add an item to a shop
    @dev Only the shop's shopowner can add an item to a shop
    @param _shopID a uint index to look up the shop in the shop list
    @param _name a required string name for the item
    @param _desc a description
    @param _hash an ipfs file hash for image lookup
    @param _price a required price for the item
    */
    function addItemToShop(uint _shopID, string memory _name, string memory _desc, string memory _hash, uint _price) public stopInEmergency{
        require(itemCount < maxItems, 'Maximum number of items reached');
        require(shops[_shopID].shopOwner == msg.sender, "Operation failed. Must be shop owner to post item to store.");
        require(_shopID >= 0 && bytes(_name).length > 0 && _price > 0, "shopID, name and price cannot be empty.");

        address payable _buyer;
        items.push(Item({shopID:_shopID, sku: itemCount, name:_name, description:_desc, ipfsImageHash:_hash, price:_price, state:State.ForSale, seller:msg.sender, buyer:_buyer}));
        shopItemCount[_shopID]++;
        sellerItemCount[msg.sender]++;

        uint theItem = itemCount;

        itemCount++;

        emit AddedItemToShop(theItem);
    }

    /**
    @notice edit an item's details
    @dev Only the shop's shopowner can edit an item's details
    @param _sku a uint index to look up the item in the item list
    @param _shopID a uint index to look up the shop in the shop list
    @param _name a required string name for the item
    @param _price a required price for the item
    */
    function editItem(uint _sku, uint _shopID, string memory _name, string memory _desc, string memory _hash, uint _price) public forSale(_sku) stopInEmergency{
        require(shops[_shopID].shopOwner == msg.sender, "must be shop owner to edit an item's details.");
        require(_shopID >= 0 && bytes(_name).length > 0 && _price > 0, "shopID, name and price cannot be empty.");

        items[_sku].shopID = _shopID;
        items[_sku].name = _name;
        items[_sku].description = _desc;
        items[_sku].ipfsImageHash = _hash;
        items[_sku].price = _price;

        emit EditedItem(_sku);
    }

    /**
    @notice Buy an item
    @dev Anyone can buy an item, but the item must be ForSale
    @param _sku a uint index to look up the item to buy
    */
    function buyItem(uint _sku) public payable forSale(_sku) checkValue(_sku){

        items[_sku].buyer = msg.sender;
        items[_sku].state = State.Sold;
        customerItemCount[msg.sender]++;

        shops[items[_sku].shopID].balance = shops[items[_sku].shopID].balance.add(msg.value);
        emit SoldItem(_sku);
    }

    /**
    @notice Ship an item
    @dev Only the shop's owner can ship an item, and the item must have been Sold
    @param _sku a uint index to look up the item to ship
    */
    function shipItem(uint _sku) public isShopOwner sold(_sku){
        items[_sku].state = State.Shipped;
        emit ShippedItem(_sku);
    }

    /**
    @notice Receive an item
    @dev Only the item's buyer can receive an item, and the item must have been Shipped
    @param _sku a uint index to look up the item to mark received
    */
    function receiveItem(uint _sku) public shipped(_sku){
        require(items[_sku].buyer == msg.sender, "Only the customer can mark an item as received.");
        items[_sku].state = State.Received;

        emit ReceivedItem(_sku);
    }

    /**
    @notice Archive an item
    @dev Only the item's seller can archive an item, and the item must have been Shipped
    @param _sku a uint index to look up the item to mark received
    */
    function archiveItem(uint _sku) public received(_sku){
        require(items[_sku].seller == msg.sender, "Only the seller can mark an item archived.");
        items[_sku].state = State.Archived;

        emit ArchivedItem(_sku);
    }

    /// Getters
       /**
    * @notice Is the caller the contractowner
    * @return a boolean - true or false
    */
    
    function isTheOwner() public view returns(bool){
        return (msg.sender == owner);
    }
    

    /**
    @notice Check the state of the Circuit Breaker security pattern
    @dev Only admins can check the state of the Circuit Breaker
    @return bool value of the current state of the Circuit Breaker; false =n ormal operation, true = emergency
    */
    function getCircuitState() public view isAdmin returns(bool){
        return stopped;
    }

    /**
    * @notice Is the caller an admin
    * @return a boolean - true or false
    */
    function isAnAdmin() public view returns(bool){
        return Roles.has(admins, msg.sender);
    }

    /**
    @notice List all admins
    @dev Only admins can access the admin list
    @return array of addresses for admin  accounts
    */
    function listAdmins() public view isAdmin returns(address[] memory){
        return adminAccts;
    }

    /**
    * @notice Is the caller a shopOwner
    * @return a boolean - true or false
    */
    function isAShopOwner() public view returns(bool){
        return Roles.has(shopOwners, msg.sender);
    }

    /**
    @notice List all shop owners
    @dev Only admins can access the shopowners list
    @return array of addresses for shopowner accounts
    */
    function listShopOwners() public view isAdmin returns(address[] memory){
        return shopOwnerAccts;
    }

    /**
    @notice get the total number of shops
    @dev used to present the main marketplace listing
    @return uint count of shops
    */
    function getShopCount() public view returns(uint){
        return shopCount;
    }

    /**
    @notice List shop id's by shopowner
    @dev Only admins or the shopowner can access the list of shops owned by specific shopowners
    @param _owner - the address of a shop owner
    @return array of uints for shops owned by _owner
    */
    function getShopIDsByOwner(address _owner) public view isAdminOrOwner(_owner) returns (uint[] memory) {
        uint[] memory result = new uint[](ownerShopCount[_owner]);
        uint counter = 0;

        for (uint i = 0; i < shops.length; i++) {
            if (shops[i].shopOwner == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

   /**
    @notice get the total number of items
    @dev used to present the main marketplace listing
    @return uint count of items
    */
    function getItemCount() public view returns(uint){
        return itemCount;
    }

    /**
    @notice List item id's by shop
    @dev Only admins and the shop owner can access the full list of items (in all states) in a specific shop
    @return array of uint indexes to item list
    */
    function getItemsByShopID(uint _shopID) public view returns (uint[] memory) {
        require(Roles.has(admins, msg.sender) || (shops[_shopID].shopOwner == msg.sender), "caller must be admin or the shop owner.");
        uint[] memory result = new uint[](shopItemCount[_shopID]);
        uint counter = 0;

        for (uint i = 0; i < items.length; i++) {
            if (items[i].shopID == _shopID) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    /**
    @notice List item id's by seller
    @dev Only the buyer can access their purchase history
    @return array of uint indexes to items list
    */
    function getItemsBySeller(address _seller) public view verifyCaller(_seller) returns (uint[] memory) {
        uint[] memory result = new uint[](sellerItemCount[msg.sender]);
        uint counter = 0;

        for (uint i = 0; i < items.length; i++) {
            if (items[i].seller == msg.sender) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }

    /**
    @notice List item id's by buyer
    @dev Only the buyer can access their purchase history
    @return array of uint indexes to items list
    */
    function getCustomerOrders(address _customer) public view verifyCaller(_customer) returns (uint[] memory) {
        uint[] memory result = new uint[](customerItemCount[msg.sender]);
        uint counter = 0;

        for (uint i = 0; i < items.length; i++) {
            if (items[i].buyer == msg.sender) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    }
}
