/**
 *Submitted for verification at Etherscan.io on 2019-07-26
*/

pragma solidity ^0.5.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
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
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    paused = true;
    emit Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    paused = false;
    emit Unpause();
  }
}

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract SalePlace is Pausable{

  using SafeMath for uint;

  struct Item {
    string name;
    string image;
    string description;
    uint price;
    uint numberOfItems;
    uint timestamp;
    address payable seller;
  }

  /* Staus Enum used by ItemInvoice ,with 4 states
    Processing
    Shipped
    Received
    Refunded
  */
  enum Status { Processing ,Shipped, Received, Refunded }

  struct ItemInvoice{
    string itemId;
    uint numberOfItemsSold;
    uint amountPaid;
    Status status;
    uint timestamp;
    address payable buyer;
  }

  mapping (string => Item) private items;
  mapping (string => ItemInvoice) private itemsSold;

  modifier isSeller(string memory _itemId){
    _;
    require(items[_itemId].seller != address(0) && items[_itemId].seller == msg.sender, "should be the seller to process forward");
  }

  modifier isBuyer(string memory _itemId){
    _;
    require(itemsSold[_itemId].buyer != address(0) && itemsSold[_itemId].buyer == msg.sender, "should be a buyer to process forward");
  }

  event LogAddItem(address seller, string itemId , uint numberOfItems, uint price);
  event LogUpdateItem(address seller, string itemId , uint numberOfItems, uint price);
  event LogBuyItem(address buyer, string invoiceId, uint numberOfItems);
  event LogShipped(address seller, string invoiceId, string itemId);
  event LogReceived(address buyer, string invoiceId, string itemId);
  event LogRefund(address seller, address buyer, string invoiceId, string itemId, uint amountRefunded);

  /// @notice Trade logic called when items are purchased by a user
  /// @param _itemId id of the item to fetch
  /// @param _numberOfItems number of the items purchased
  /// @dev the function will trade amount from buyer to seller , also any left over amount will be transfered to buyer itself
  modifier trade (string memory _itemId, uint _numberOfItems)  {
    _;
    uint totalAmount = _numberOfItems.mul(items[_itemId].price);
    require(msg.value >= totalAmount, 'Amount less than required');

    uint amountToRefund = msg.value.sub(items[_itemId].price);
    if(amountToRefund>0){
      msg.sender.transfer(amountToRefund); // transfer left over to buyer
    }
    items[_itemId].seller.transfer(items[_itemId].price); // send the money to seller
  }


  /// @notice Get am item based on item id
  /// @param _itemId id of the item to fetch
  /// @return id, name, image , description , price , number of Items left, timestamp and seller address of the item
  function getItem(string memory _itemId)
  public
  view
  returns (string memory id, string memory name, string memory image, string memory description, uint price, uint numberOfItems, address seller, uint timestamp) {
    id = _itemId;
    name = items[_itemId].name;
    image = items[_itemId].image;
    price = items[_itemId].price;
    description = items[_itemId].description;
    numberOfItems = items[_itemId].numberOfItems;
    seller = items[_itemId].seller;
    timestamp = items[_itemId].timestamp;
    return (id, name, image, description, price, numberOfItems, seller, timestamp);
  }

  /// @notice Get item purcahsed details of the request user mapping for given item
  /// @param _invoiceId  invoice id of the item sold to fetch 
  /// @return itemId, invoiceId, number of Items sold , status, timestamp, buyer address & amount paid
  function getItemSold(string memory _invoiceId)
  public 
  view 
  isBuyer(_invoiceId)
  returns (string memory itemId, string memory invoiceId, uint numberOfItemsSold, Status status, address buyer, uint timestamp, uint amountPaid) {
    itemId = itemsSold[_invoiceId].itemId;
    invoiceId = _invoiceId;
    numberOfItemsSold = itemsSold[_invoiceId].numberOfItemsSold;
    status = itemsSold[_invoiceId].status;
    buyer = itemsSold[_invoiceId].buyer;
    timestamp = itemsSold[_invoiceId].timestamp;
    amountPaid = itemsSold[_invoiceId].amountPaid;
    return (itemId, invoiceId, numberOfItemsSold, status, buyer, timestamp, amountPaid);
  }

  /// @notice Add item
  /// @dev Emits LogAddItem
  /// @param _itemId id of the item
  /// @param _name name of the item
  /// @param _image image url of the item
  /// @param _description description of the item
  /// @param _price price of the item
  /// @param _numberOfItems number of the item to sell
  /// @return true if item is created
  function addItem(string memory _itemId,string memory _name, string memory _image, string memory _description, uint _price, uint _numberOfItems)
  public
  whenNotPaused()
  returns(bool){
    require(_numberOfItems>0, 'Number of items should be atleast 1');
    require(_price>0, 'Price of items cannot be atleast 0');
    Item memory newItem;
    newItem.name = _name;
    newItem.image = _image;
    newItem.description = _description;
    newItem.price = _price;
    newItem.numberOfItems = _numberOfItems;
    newItem.seller = msg.sender;
    newItem.timestamp = now;
    items[_itemId] = newItem;
    emit LogAddItem(msg.sender, _itemId, _numberOfItems, _price);
    return true;
  }

  /// @notice Update item
  /// @dev Emits LogUpdateItem
  /// @dev Need to be seller of the item to update
  /// @param _itemId id of the item
  /// @param _name name of the item
  /// @param _image image url of the item
  /// @param _description description of the item
  /// @param _price price of the item
  /// @param _numberOfItems number of the item to sell
  /// @return true if item is udpated
  function updateItem(string memory _itemId, string memory _name, string memory _image, string memory _description, uint _price, uint _numberOfItems)
  public
  whenNotPaused()
  isSeller(_itemId)
  returns(bool){
    require(_numberOfItems>0, 'Number of items should be atleast 1');
    require(_price>0, 'Price of items cannot be atleast 0');
    items[_itemId].name = _name;
    items[_itemId].image = _image;
    items[_itemId].description = _description;
    items[_itemId].price = _price;
    items[_itemId].numberOfItems = _numberOfItems;
    emit LogUpdateItem(msg.sender, _itemId, _numberOfItems, _price);
    return true;
  }

  /// @notice Function to buy items
  /// @dev Emits LogBuyItem
  /// @dev Amount paid more than required will be refunded
  /// @param _itemId id of the item
  /// @param _invoiceId id of the invoice item sold
  /// @param _numberOfItems number of the item to buy
  /// @return true if items are bought
  function buyItem(string memory _itemId, string memory _invoiceId, uint _numberOfItems)
  public
  payable
  whenNotPaused()
  trade(_itemId,_numberOfItems)
  returns(bool){
    require(_numberOfItems>0, 'Number of items should be atleast 1');
    require(items[_itemId].numberOfItems - _numberOfItems >= 0, 'Out of stock');

    itemsSold[_invoiceId].status = Status.Processing;
    itemsSold[_invoiceId].numberOfItemsSold = _numberOfItems;
    itemsSold[_invoiceId].buyer = msg.sender;
    itemsSold[_invoiceId].timestamp = now;
    itemsSold[_invoiceId].itemId = _itemId;
    itemsSold[_invoiceId].amountPaid = _numberOfItems.mul(items[_itemId].price);

    items[_itemId].numberOfItems = items[_itemId].numberOfItems.sub(1);

    emit LogBuyItem(msg.sender, _itemId, _numberOfItems);

    return true;
  }

  /// @notice Function called by seller to set item status to shipped
  /// @dev Emits LogShipped
  /// @dev Needs to be seller of the itemto access the function
  /// @param _invoiceId id of the invoice id of item sold
  /// @return true if items is udpated to shipped status
  function shipItem(string memory _invoiceId)
  public
  returns(bool){
    require(itemsSold[_invoiceId].status == Status.Processing, 'Item already shipped');
    require(items[itemsSold[_invoiceId].itemId].seller == msg.sender, 'Action restricted to seller only');
    itemsSold[_invoiceId].status = Status.Shipped;
    emit LogShipped(msg.sender, _invoiceId, itemsSold[_invoiceId].itemId);
    return true;
  }

  /// @notice Function called by buyer to set item status to received
  /// @dev Emits LogReceived
  /// @dev Needs to be buyer of the item to access the function
  /// @param _invoiceId id of the invoice id of item sold
  /// @return true if items is udpated to received status
  function receiveItem(string memory _invoiceId)
  public
  isBuyer(_invoiceId)
  returns(bool){
    require(itemsSold[_invoiceId].status == Status.Shipped , 'Item not yet shipped');
    require(itemsSold[_invoiceId].buyer == msg.sender, 'Action restricted to buyer only');
    itemsSold[_invoiceId].status = Status.Received;
    emit LogReceived(msg.sender, _invoiceId, itemsSold[_invoiceId].itemId);
    return true;
  }

  /// @notice Function called by seller to refund for the item
  /// @dev Emits LogRefund
  /// @dev Needs to be seller of the item to access the function
  /// @dev Amount is transfered from seller account to buyer account , any left over paid will transfered to the seller itself
  /// @param _invoiceId id of the invoice id of item sold
  /// @return true if refund is successfull
  function refundItem(string memory _invoiceId)
  public
  payable
  returns(bool){
    string memory itemId = itemsSold[_invoiceId].itemId;
    require(items[itemId].seller == msg.sender, 'Action restricted to seller only');

    require(msg.value >= itemsSold[_invoiceId].amountPaid, 'Amount less than required');
    require(itemsSold[_invoiceId].amountPaid > 0, 'Total amount to refund should be greater than zero');

    itemsSold[_invoiceId].buyer.transfer(itemsSold[_invoiceId].amountPaid); // transfer to buyer

    uint amountLeftOver = msg.value.sub(itemsSold[_invoiceId].amountPaid);
    
    if(amountLeftOver>0){
      items[itemId].seller.transfer(amountLeftOver); // transfer any left over to seller
    }
    itemsSold[_invoiceId].status = Status.Refunded;
    
    emit LogRefund(msg.sender, itemsSold[_invoiceId].buyer, _invoiceId, itemId, itemsSold[_invoiceId].amountPaid);
    return true;
  }
}
