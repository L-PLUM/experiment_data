/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

pragma solidity ^0.4.24;


contract Ownable {
    address public owner;
    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    /**
        * @dev The Ownable constructor sets the original `owner` of the contract to the sender
        * account.
    */
    constructor() internal {
        owner = msg.sender;
    }
    /**
        * @dev Throws if called by any account other than the owner.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    /**
        * @dev Allows the current owner to relinquish control of the contract.
        * @notice Renouncing to ownership will leave the contract without an owner.
        * It will not be possible to call the functions with the `onlyOwner`
        * modifier anymore.
    */

    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }
    /**
        * @dev Allows the current owner to transfer control of the contract to a newOwner.
        * @param _newOwner The address to transfer ownership to.
    */
    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }
    /**
        * @dev Transfers control of the contract to a newOwner.
        * @param _newOwner The address to transfer ownership to.
    */

    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
    * @dev modifier to allow actions only when the contract IS paused
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @dev modifier to allow actions only when the contract IS NOT paused
    */
    modifier whenPaused {
        require(paused);
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() public onlyOwner whenNotPaused returns (bool) {
        paused = true;
        emit Pause();
        return true;
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() public onlyOwner whenPaused returns (bool) {
        paused = false;
        emit Unpause();
        return true;
    }
}

contract SmartContractStore is Pausable{
    event broughtItem(address _buyer, uint256 _id);
    event listItem(address _seller, uint256 _id, uint256 _newPrice);
    struct Item{
        uint256 totalOwners;
        uint256 price;
        address currentOwner;
        bool isSale;
    }

    Item[] public items;

    address public loyaltyAddress;

    constructor() public{
        // Initialize loyaltyAddress and items here

        // New item template
        // totalOwners = 0
        // price = 0.001 eth
        // currentOwner = 0x0
        // isSale = true
        Item memory item = Item(0, 1000000000000000, address(this), true);

        // Create 100 instance of the item template
        for (uint x = 0 ; x < 10 ; x++){
            items.push(item);
        }

        // Start contract paused
        pause();
    }

    function buyItem(uint256 _id) public whenNotPaused payable{
        // Item must be on sale
        require(items[_id].isSale);
        // Bid price must be greater than or equal to the item price
        require(msg.value >= items[_id].price);
        // Send back any excess bid
        msg.sender.transfer(msg.value-items[_id].price);
        // Variable for loyalty percentage
        uint256 loyaltyPercentage;
        // Calculate loyalty percentage with the total number of owners
        // If first buyer send 50 percent to loyalty address
        if(items[_id].totalOwners == 0) loyaltyPercentage = 50;
        // If not first buyer percentage would be 5 and decreasing by 1 per purchase
        else if(6 - items[_id].totalOwners >= 1) loyaltyPercentage = 10 - items[_id].totalOwners;
        // Until loyalty percentage is 1 percent
        else loyaltyPercentage = 1;
        // Send the percentage of the item price to the loyalty address
        loyaltyAddress.transfer(items[_id].price * ( loyaltyPercentage / 100 ));
        // Send the remaining percentage to the seller
        if(items[_id].currentOwner != address(this)) items[_id].currentOwner.transfer(items[_id].price * ( (100-loyaltyPercentage) / 100 ));
        // Increment item total owners
        items[_id].totalOwners = items[_id].totalOwners + 1;
        // Set msg.sender as current item owner
        items[_id].currentOwner = msg.sender;
        // Set item not for sale
        items[_id].isSale = false;
        emit broughtItem(msg.sender,_id);
    }

    function sellItem(uint256 _id, uint256 _price) public whenNotPaused{
        // Check if msg.sender is the item owner
        require(items[_id].currentOwner == msg.sender);
        // Check if item is currently for sale
        require(items[_id].isSale == false);
        // New item price must be greater than the previous price
        require(items[_id].price < _price);
        // Set item new price
        items[_id].price = _price;
        // Set item for sale
        items[_id].isSale = true;
        emit listItem(msg.sender,_id,_price);
    }

    function forSaleItems() external view returns(uint256[]){
        // Variable to save the forSaleItemIndex array size
        uint forSaleItemCount;
        // For loop to get the number of for sale items
        for (uint256 x = 0 ; x < items.length ; x++ ){
            if(items[x].isSale == true) forSaleItemCount = forSaleItemCount + 1;
        }
        // Variable to save the index counter for forSaleItemIndex array
        uint256 forSaleItemArrayIndex;
        // Array to save the id of all for sale items
        uint256[] memory forSaleItemIndex = new uint256[](forSaleItemCount);
        // For loop for save the index of all for sale items in forSaleItemIndex array
        for (uint256 y = 0 ; y < items.length ; y++ ){
            // If item is for sale true
            if(items[y].isSale == true){
                // Save the for sale item index to forSaleItemIndex array
                forSaleItemIndex[forSaleItemArrayIndex] = y;
                // Increment the forSaleItemArrayIndex;
                forSaleItemArrayIndex = forSaleItemArrayIndex + 1;
            }
        }
        // Return forSaleItemIndex array
        return forSaleItemIndex;
    }

    function notForSaleItems() external view returns(uint256[]){
        // Variable to save the forSaleItemIndex array size
        uint forSaleItemCount;
        // For loop to get the number of for sale items
        for (uint256 x = 0 ; x < items.length ; x++ ){
            if(items[x].isSale == false) forSaleItemCount = forSaleItemCount + 1;
        }
        // Variable to save the index counter for forSaleItemIndex array
        uint256 forSaleItemArrayIndex;
        // Array to save the id of all for sale items
        uint256[] memory forSaleItemIndex = new uint256[](forSaleItemCount);
        // For loop for save the index of all for sale items in forSaleItemIndex array
        for (uint256 y = 0 ; y < items.length ; y++ ){
            // If item is for sale true
            if(items[y].isSale == false){
                // Save the for sale item index to forSaleItemIndex array
                forSaleItemIndex[forSaleItemArrayIndex] = y;
                // Increment the forSaleItemArrayIndex;
                forSaleItemArrayIndex = forSaleItemArrayIndex + 1;
            }
        }
        // Return forSaleItemIndex array
        return forSaleItemIndex;
    }

    function myItems() external view returns(uint256[]){
        // Variable to save the forSaleItemIndex array size
        uint forSaleItemCount;
        // For loop to get the number of for sale items
        for (uint256 x = 0 ; x < items.length ; x++ ){
            if(items[x].currentOwner == msg.sender) forSaleItemCount = forSaleItemCount + 1;
        }
        // Variable to save the index counter for forSaleItemIndex array
        uint256 forSaleItemArrayIndex;
        // Array to save the id of all for sale items
        uint256[] memory forSaleItemIndex = new uint256[](forSaleItemCount);
        // For loop for save the index of all for sale items in forSaleItemIndex array
        for (uint256 y = 0 ; y < items.length ; y++ ){
            // If item is for sale true
            if(items[y].currentOwner == msg.sender){
                // Save the for sale item index to forSaleItemIndex array
                forSaleItemIndex[forSaleItemArrayIndex] = y;
                // Increment the forSaleItemArrayIndex;
                forSaleItemArrayIndex = forSaleItemArrayIndex + 1;
            }
        }
        // Return forSaleItemIndex array
        return forSaleItemIndex;
    }

    function setLoyaltyAddress(address _address) external onlyOwner{
        loyaltyAddress = _address;
    }

    function unpause() public onlyOwner whenPaused returns (bool) {
        require(loyaltyAddress != address(0));
        return super.unpause();
    }

    function withdraw() public onlyOwner{
        owner.transfer(address(this).balance);
    }
}
