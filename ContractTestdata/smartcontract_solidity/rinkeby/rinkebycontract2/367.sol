/// @title Marketplace: A marketplace for listing and buying products
/// @author John McCrae
/// @notice This contract inherits EmergencyStop, a contract that implements the circuit breaker design pattern

/// @dev This contract requires solidity compiler version 0.5 or higher.
pragma solidity ^0.5.0;

/// @dev This contract imports EmergencyStop.sol
import "./EmergencyStop.sol";

/// @dev Marketplace: A contract for listing and buying products
contract Marketplace is EmergencyStop {

    /// @param ownerMarketplace A public payable address data type
    address payable public ownerMarketplace;
    
    /// @param productIDGen A public uint data type to keep track of product ID numbers.
    uint public productIDGen;
    
    /// @param managerIDGen A public uint data type to keep track of manager ID numbers
    uint public managerIDGen;

    /// @param productName A string data type to keep track of store product names
    /// @param totalUnits A uint data type to keep track of total store product units
    /// @param unitPrice A uint data type to keep track of store product unit prices
    /// @param forSale A uint data type to keep track of whether store product is for sale
    /// @param buyersAcc A uint data type to keep track of total product units held within the buyers account
    struct Products {
        string productName;
        uint totalUnits;
        uint unitPrice;
        bool forSale;
        mapping (address => uint) buyersAcc;
    }
    
    /// @param managerID A uint data type to keep track of store manager ID numbers
    /// @param managerName A string data type to keep track of store manager names
    /// @param managerAuth A boolean data type to keep track of store manager authorisation
    struct Managers {
        uint managerID;
        string managerName;
        bool managerAuth;
    }
    
    /// @param storeProd A mapping data type with key as uint (store product ID) and value as struct Products (store product data)
    mapping (uint => Products) public storeProd;

    /// @param storeMan A mapping data type with key as address (store manager address) and value as struct Managers (store manager data)
    mapping (address => Managers) public storeMan;

    /// @dev _xxxProductID A uint data type to keep track of store product ID numbers
    /// @dev _xxxProductName A string data type to keep track of store product names
    /// @dev _xxxTotalUnits A uint data type to keep track of total store product units
    /// @dev _xxxUnitPrice A uint data type to keep track of store product unit prices
    /// @dev _xxxforSale A uint data type to keep track of whether store product is for sale
    /// @dev _xxxbuyersAcc A uint data type to keep track of total product units held within the buyers account
    /// @dev _readStoreFunds A uint data type to output value of store funds
    /// @dev _contractBalance A uint data type to output value of store funds withdrawl
    event LogStoreProductsRead(uint _readProductID, string _readProductName, uint _readTotalUnits, uint _readUnitPrice, bool _forSale, uint _buyersAcc);
    event LogStoreProductBuy(uint _buyProductID, string _buyProductName, uint _buyTotalUnits, uint _buyUnitPrice);
    event LogStoreProductAdded(uint _newProductID, string _newProductName, uint _newTotalUnits, uint _newUnitPrice, bool _forSale, uint _buyersAcc);
    event LogStoreProductRemoved(uint _oldProductID, string _oldProductName, uint _oldTotalUnits, uint _oldUnitPrice, bool _forSale, uint _buyersAcc);
    event LogStoreProductPriceChanged(uint _changeProductID, string _changeProductName, uint _changeTotalUnits, uint _changeUnitPrice, bool _forSale);
    event LogStoreManAdded(uint _newManagerID, string _newManagerName, bool _newManagerAuth, address _newManagerAddress);
    event LogStoreManRemoved(uint _oldManagerID, string _oldManagerName, bool _oldManagerAuth, address _oldManagerAddress);
    event LogReadStoreFunds(uint _readStoreFunds);
    event LogStoreFundsWithdrawn(uint _amountWithdrawn);


    /// @dev verifyOwnerMarketplace A modifier requiring the message sender address is equal to the ownerMarketplace address
    modifier verifyOwnerMarketplace () {
        require (msg.sender == ownerMarketplace, "Access denied. Access restricted to contract owner.");
        _;
    }

    /// @dev verifyManagerMarketplace A modifier requiring the message sender has been authorised as a store manager
    modifier verifyManagerMarketplace () {
        require (storeMan[msg.sender].managerAuth == true, "Access denied. Access restricted to store managers.");
        _;
    }

    /// @dev verifyProductForSale A modifier requiring the requested store product to be currently registered as for sale.
    modifier verifyProductForSale (uint _productID) {
        require (storeProd[_productID].forSale == true, "Request declined. Store product is not for sale.");
        _;
    }
    
    /// @dev verifyManagerAuth A modifier requiring the requested store manager to be currently registered as authorised.
    modifier verifyManagerAuth (address _manAddress) {
        require (storeMan[_manAddress].managerAuth == true, "Request declined. Store manager is not authorised.");
        _;
    }

    /// @dev verifyWithinPriceCap A modifier requiring product prices to be below a cap of 1,000 Wei. This mitigates risk of money loss
    modifier verifyWithinPriceCap (uint _newUnitPrice) {
        require (_newUnitPrice <= 1000, "Request declined. Price cap of 1,000 Wei enforced.");
        _;
    }
    
    /// @dev verifyWithinUnitsCap A modifier requiring total units to be below a cap of 1,000,000. This mitigates risk of integer overflow
    modifier verifyWithinUnitsCap (uint _newTotalUnits) {
        require (_newTotalUnits <= 1000000, "Request declined. Total units cap of 1,000,000 enforced.");
        _;
    }

    /// @dev verifyUnitsEnough A modifier requiring product units to be in stock prior to purchase
    modifier verifyUnitsEnough (uint _productID) {
        require (storeProd[_productID].totalUnits >= 1, "Payment declined. Unit out of stock.");
        _;
    }

    /// @dev verifyPaidEnough A modifier requiring buyer payment value to be no less than unit price
    modifier verifyPaidEnough (uint _orderPrice) {
        require (msg.value >= _orderPrice, "Payment declined. Insufficient funds received.");
        _;
    }
    
    /// @dev sendPaymentChange A modifier that refunds buyers in the event they send too much ether
    modifier sendPaymentChange (uint _orderPrice) {
        _;
        uint paymentChange = msg.value - _orderPrice;
        msg.sender.transfer(paymentChange);
    }
    
    /// @dev Declare constructor. Set ownerMarketplace to be the contract creator
    constructor () public {
        ownerMarketplace = msg.sender;
    }
    
    /// @dev readStoreProducts() A function to read store product data
    /// @param readProductID A uint data type to read data associated with store product ID
    /// @return _xxxProductID, _xxxProductName, _xxxTotalUnits, _xxxUnitPrice, _xxxforSale, _xxxbuyersAcc
    function readStoreProducts(uint readProductID)
        public
        verifyEmergencyStopValue
        returns(uint _readProductID, string memory _readProductName, uint _readTotalUnits, uint _readUnitPrice, bool _forSale, uint _buyersAcc)
    {
        emit LogStoreProductsRead(readProductID, storeProd[readProductID].productName, storeProd[readProductID].totalUnits, storeProd[readProductID].unitPrice, storeProd[readProductID].forSale, storeProd[readProductID].buyersAcc[msg.sender]);
        return(readProductID, storeProd[readProductID].productName, storeProd[readProductID].totalUnits, storeProd[readProductID].unitPrice, storeProd[readProductID].forSale, storeProd[readProductID].buyersAcc[msg.sender]);
    }
    
    /// @dev buyStoreProduct() A function to buy a store product
    /// @param buyProductID A uint data type to buy store product associated with store product ID
    /// @return _xxxProductID, _xxxProductName, _xxxTotalUnits, _xxxUnitPrice
    function buyStoreProduct(uint buyProductID)
        public
        payable
        verifyEmergencyStopValue
        verifyProductForSale (buyProductID)
        verifyUnitsEnough (buyProductID)
        verifyPaidEnough (storeProd[buyProductID].unitPrice)
        sendPaymentChange (storeProd[buyProductID].unitPrice)
        returns(uint _buyProductID, string memory _buyProductName, uint _buyTotalUnits, uint _buyUnitPrice)
    {
        storeProd[buyProductID].totalUnits -= 1;
        storeProd[buyProductID].buyersAcc[msg.sender] += 1;
        emit LogStoreProductBuy(buyProductID, storeProd[buyProductID].productName, storeProd[buyProductID].totalUnits, storeProd[buyProductID].unitPrice);
        return(buyProductID, storeProd[buyProductID].productName, storeProd[buyProductID].totalUnits, storeProd[buyProductID].unitPrice);
    }

    /// @dev addStoreProduct() A function to add a new store product ***Restricted to store manager (authorised by store owner)***
    /// @param newProductName A string data type to add new store product name
    /// @param newTotalUnits A uint data type to add new total store product units
    /// @param newUnitPrice A uint data type to add new store product unit price
    /// @return _xxxProductID, _xxxProductName, _xxxTotalUnits, _xxxUnitPrice, _xxxforSale, _xxxbuyersAcc
    function addStoreProduct(string memory newProductName, uint newTotalUnits, uint newUnitPrice)
        public
        verifyEmergencyStopValue
        verifyManagerMarketplace
        verifyWithinPriceCap (newUnitPrice)
        verifyWithinUnitsCap (newTotalUnits)
        returns(uint _productIDGen, string memory _newProductName, uint _newTotalUnits, uint _newUnitPrice, bool _forSale, uint _buyersAcc)
    {
        storeProd[productIDGen].productName = newProductName;
        storeProd[productIDGen].totalUnits = newTotalUnits;
        storeProd[productIDGen].unitPrice = newUnitPrice;
        storeProd[productIDGen].forSale = true;
        productIDGen += 1;
        emit LogStoreProductAdded(productIDGen - 1, storeProd[productIDGen - 1].productName, storeProd[productIDGen - 1].totalUnits, storeProd[productIDGen - 1].unitPrice, storeProd[productIDGen - 1].forSale, storeProd[productIDGen - 1].buyersAcc[msg.sender]);
        return (productIDGen - 1, storeProd[productIDGen - 1].productName, storeProd[productIDGen - 1].totalUnits, storeProd[productIDGen - 1].unitPrice, storeProd[productIDGen - 1].forSale, storeProd[productIDGen - 1].buyersAcc[msg.sender]);
    }

    /// @dev removeStoreProduct() A function to remove an old store product ***Restricted to store manager (authorised by store owner)***
    /// @param oldProductID A uint data type to remove store product associated with store product ID
    /// @return _xxxProductID, _xxxProductName, _xxxTotalUnits, _xxxUnitPrice, _xxxforSale, _xxxbuyersAcc
    function removeStoreProduct(uint oldProductID)
        public
        verifyEmergencyStopValue
        verifyManagerMarketplace
        verifyProductForSale (oldProductID)
        returns(uint _oldProductID, string memory _oldProductName, uint _oldTotalUnits, uint _oldUnitPrice, bool _forSale, uint _buyersAcc)
    {
        storeProd[oldProductID].forSale = false;        
        emit LogStoreProductRemoved(oldProductID, storeProd[oldProductID].productName, storeProd[oldProductID].totalUnits, storeProd[oldProductID].unitPrice, storeProd[oldProductID].forSale, storeProd[oldProductID].buyersAcc[msg.sender]);
        return (oldProductID, storeProd[oldProductID].productName, storeProd[oldProductID].totalUnits, storeProd[oldProductID].unitPrice, storeProd[oldProductID].forSale, storeProd[oldProductID].buyersAcc[msg.sender]);
    }

    /// @dev changeStoreProductPrice() A function to change the price of a store product ***Restricted to store manager (authorised by store owner)***
    /// @param changeProductID A uint data type to identify the store product to change
    /// @param changeUnitPrice A uint data type to state the new price of the store product
    /// @return _xxxProductID, _xxxProductName, _xxxTotalUnits, _xxxUnitPrice, _xxxforSale
    function changeStoreProductPrice(uint changeProductID, uint changeUnitPrice)
        public
        verifyEmergencyStopValue
        verifyManagerMarketplace
        verifyProductForSale (changeProductID)
        verifyWithinPriceCap (changeUnitPrice)
        returns(uint _changeProductID, string memory _changeProductName, uint _changeTotalUnits, uint _changeUnitPrice, bool _forSale)
    {
        emit LogStoreProductPriceChanged(changeProductID, storeProd[changeProductID].productName, storeProd[changeProductID].totalUnits, changeUnitPrice, storeProd[changeProductID].forSale);
        storeProd[changeProductID].unitPrice = changeUnitPrice;
        return (changeProductID, storeProd[changeProductID].productName, storeProd[changeProductID].totalUnits, storeProd[changeProductID].unitPrice, storeProd[changeProductID].forSale);
    }

    /// @dev addStoreManager() A function to add a new store manager ***Restricted to store owner (contract owner)***
    /// @param newManagerName A string data type to add a new store manager name
    /// @param newManagerAddress An address data type to add new store manager address
    /// @return _xxxManagerID, _xxxManagerName, _xxxManagerAuth, _xxxManagerAddress
    function addStoreManager(string memory newManagerName, address newManagerAddress)
        public
        verifyEmergencyStopValue
        verifyOwnerMarketplace
        returns(uint _manIDGen, string memory _manName, bool _manAuth, address _manAddress)
    {
        storeMan[newManagerAddress].managerID = managerIDGen;
        storeMan[newManagerAddress].managerName = newManagerName;
        storeMan[newManagerAddress].managerAuth = true;
        managerIDGen += 1;
        emit LogStoreManAdded(storeMan[newManagerAddress].managerID, storeMan[newManagerAddress].managerName, storeMan[newManagerAddress].managerAuth, newManagerAddress);
        return (storeMan[newManagerAddress].managerID, storeMan[newManagerAddress].managerName, storeMan[newManagerAddress].managerAuth, newManagerAddress);
    }

    /// @dev removeStoreManager() A function to remove an old store manager ***Restricted to store owner (contract owner)***
    /// @param oldManagerAddress An address data type to identify the store manager to remove
    /// @return _xxxManagerID, _xxxManagerName, _xxxManagerAuth, _xxxManagerAddress
    function removeStoreManager(address oldManagerAddress)
        public
        verifyEmergencyStopValue
        verifyOwnerMarketplace
        verifyManagerAuth (oldManagerAddress)
        returns(uint _manIDGen, string memory _manName, bool _manAuth, address _manAddress)
    {
        storeMan[oldManagerAddress].managerAuth = false;
        emit LogStoreManRemoved(storeMan[oldManagerAddress].managerID, storeMan[oldManagerAddress].managerName, storeMan[oldManagerAddress].managerAuth, oldManagerAddress);
        return (storeMan[oldManagerAddress].managerID, storeMan[oldManagerAddress].managerName, storeMan[oldManagerAddress].managerAuth, oldManagerAddress);
    }

    /// @dev readStoreFunds() A function to read store funds. ***Restricted to store owner (contract owner)***
    /// @return _storeFunds
    function readStoreFunds()
        public
        verifyOwnerMarketplace
        returns(uint _readStoreFunds)
    {
        uint storeFundsAmount = address(this).balance;
        emit LogReadStoreFunds(storeFundsAmount);
        return (storeFundsAmount);
    }

    /// @dev withdrawStoreFunds() A function to withdraw store funds. ***Restricted to store owner (contract owner)***
    /// @return _amountWithdrawn
    function withdrawStoreFunds()
        public
        verifyOwnerMarketplace
        returns(uint _amountWithdrawn)
    {
        uint amountWithdrawn = address(this).balance;
        emit LogStoreFundsWithdrawn(amountWithdrawn);
        ownerMarketplace.transfer(amountWithdrawn);
        return (amountWithdrawn);
    }

}
