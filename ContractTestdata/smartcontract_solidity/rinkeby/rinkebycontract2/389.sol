pragma solidity ^0.5.0;
import "./SafeMath.sol";

/** @title Vintage Explorer
    @author Keita Fukue
    @notice Vintage Explorer contract keeps track of wine producers and wines on the blockchain. Buyers can manage their inventory and buy/refund wines.
    @dev Using simple math to perform arthimetic operation.
*/

contract VintageExplorer{
    using SafeMath for uint256;
    address payable public owner;
    bool public stopped = false;
    address backendContract;
    address[] previousBackends;

    uint ONE_WEI = 1 wei;

    uint public numWineProducers;

    struct WineProducer {
        string name;
        string website;
        address wineProducer;
        uint numWines;
        mapping (uint => Wine) wines;
        uint balance;
        bool exists;
    }

    struct Wine {
        string name;
        string description;
        string sku;
        uint vintage;
        uint totalSupply;
        mapping (address => uint) owners;
        uint priceWei;
        uint totalSales;
        bool exists;
    }

    mapping (address => bool) admins;
    mapping (uint => WineProducer) wineProducers;
    mapping (address => bool) wineProducersExists;
    mapping (address => uint) wineProducerIdLookup;

    event LogWineProducerAdded(string name, address wineProducer, uint wineProducerId);
    event LogWineAdded(string name, address wineProducer, string sku, uint wineId);
    event LogWineReOpened(string name, address wineProducer, uint wineId);
    event LogWineClosed(string name, address wineProducer, uint wineId);
    event LogBuyWine(address buyer,uint wineProducerId, uint wineId, uint numWInes);
    event LogGetRefund(address buyer,uint wineProducerId, uint wineId, uint amountToRefund);

    modifier onlyOwner { require(msg.sender == owner, 'msg.sender is not owner'); _; }
    modifier onlyAdmin { require(admins[msg.sender] == true, 'msg.sender is not admin'); _; }
    modifier stopInEmergency { require(!stopped); _;}
    modifier onlyInEmergency { require(stopped); _;}
    modifier onlyWineProducer () {
        require (wineProducersExists[msg.sender] == true, 'wine producer does not exist');
        uint wineProducerId = wineProducerIdLookup[msg.sender];
        require (wineProducers[wineProducerId].exists, 'wine producer does not exist');
        require (wineProducers[wineProducerId].wineProducer == msg.sender, 'wine producer address does not match');
        _;
    }
    modifier checkIfWineProducerAndWineExists(uint _wineProducerId, uint _wineId) {
        require(wineProducers[_wineProducerId].exists == true, 'wine producer does not exist');
        require(wineProducers[_wineProducerId].wines[_wineId].exists == true, 'wine does not exist');
        _;
    }
    modifier checkIfWineProducerIsNew(address wineProducer) {
        require(wineProducersExists[wineProducer] == false, 'wine producer already exists');
        _;
    }
    /**
        @author Keita Fukue
        @notice Called when the contract is created. Sets the contract creator address to owner and admin.
        @dev This is the only way to set the owner.
    */
    constructor() public {
        owner = msg.sender;
        admins[msg.sender] = true;
    }

    /**
        @author Keita Fukue
        @notice Adds address to the list of admins where admins can add wine producers.
        @dev This can only be called by Admins and when circuit breaker is not turned on.
        @param _a - address that will be added as the list of admins
    */
    function addAdmin(address _a)
        public
        onlyAdmin()
        stopInEmergency()
        returns(bool)
    {
        admins[_a] = true;
        return true;
    }


    /**
        @author Keita Fukue
        @notice Circuit breaker where only specific functions are allowed to be called when turned on.
        @dev This can only be called by the owner of the contract.
        @return bool - status of stopped
    */
    function stopForEmergency()
        public
        onlyOwner()
        returns(bool)
    {
        stopped = true;
        return stopped;
    }

    /**
        @author Keita Fukue
        @notice Turns off circuit breaker.
        @dev This can only be called by the owner of the contract.
        @return bool - status of stopped
    */
    function turnOffEmergency()
        public
        onlyOwner()
        returns(bool)
    {
        stopped = false;
        return stopped;
    }

    /**
        @author Keita Fukue
        @notice Self destructs the contract to remove the contract from blockchain.
        @dev This can only be called by the owner and the circuit breaker needs to be on.
    */
    function kill()
        public
        onlyOwner()
        onlyInEmergency()
    {
        selfdestruct(owner);
    }

    /**
        @author Keita Fukue
        @notice Change the address contract to another address for upgrades.
        @dev This will keep track of all the previous address contracts as well
        @param _newBackend - new contract address
        @return bool - returns true if succeeded false else wise.
    */
    function changeBackend(address _newBackend) public
        onlyOwner()
        onlyInEmergency()
        returns (bool)
    {
        if(_newBackend != backendContract) {
            previousBackends.push(backendContract);
            backendContract = _newBackend;
            return true;
        }
        return false;
    }

    /**
        @author Keita Fukue
        @notice Checks if the caller is part of the admin list.
        @return boolean true if admin
    */
    function checkIfAdmin()
        public
        view
        returns(bool)
    {
        return admins[msg.sender];
    }

    /**
        @author Keita Fukue
        @notice Checks if the caller is part of the wine producers list.
        @return boolean true if wine producer
    */
    function checkIfWineProducer()
        public
        view
        returns(bool)
    {
        return wineProducersExists[msg.sender];
    }

    /**
        @author Keita Fukue
        @notice Add a new wine producer to this contract
        @dev You can not add more than one wine producer from the same address.
        @param _name - name of the wine producer
        @param _website - website of the wine producer
        @param _wineProducer - address of the wine producer
        @return returns the newly generated wine producer Id
    */
    function addWineProducer(string memory _name, string memory _website, address _wineProducer)
        public
        stopInEmergency()
        onlyAdmin()
        checkIfWineProducerIsNew(_wineProducer)
        returns(uint newWineProducerId)
    {
        uint newId = numWineProducers;
        wineProducers[newId] = WineProducer({
            name : _name,
            website : _website,
            wineProducer : _wineProducer,
            numWines : 0,
            balance : 0,
            exists : true
        });
        wineProducersExists[_wineProducer] = true;
        wineProducerIdLookup[_wineProducer] = newId;
        emit LogWineProducerAdded(_name, _wineProducer, newId);
        numWineProducers = newId.add(1);
        return newId;
    }

     /**
        @author Keita Fukue
        @notice Add a new wine to a specific winer producer
        @dev Only wine producers can add wines
        @param _wineProducerId - wine producer id
        @param _name - name of the wine
        @param _description - description of the win
        @param _sku - stock keeping unit
        @param _vintage - vintage year of the wine
        @param _totalSupply - total number of wines available
        @param _priceWei - price of each wine in wei
        @return returns the newly generated wine
    */

    function addWine(uint _wineProducerId, string memory _name,
        string memory _description, string memory _sku, uint _vintage,
        uint _totalSupply, uint _priceWei)
        public
        stopInEmergency()
        onlyWineProducer()
        returns(uint newWineId)
    {
        uint newId = wineProducers[_wineProducerId].numWines;
        require(newId >= 0, "newId is not greater than or equal to 0");
        wineProducers[_wineProducerId].wines[newId] = Wine({
            name : _name,
            description : _description,
            sku : _sku,
            vintage : _vintage,
            totalSupply : _totalSupply,
            priceWei : _priceWei,
            totalSales : 0,
            exists : true
        });
        emit LogWineAdded(_name, msg.sender, _sku, newId);
        newId = newId.add(1);
        wineProducers[_wineProducerId].numWines = newId;
        return newId;
    }

    /**
        @author Keita Fukue
        @notice Get wine producer information by wine producer id
        @param _wineProducerId - wine producer id
        @return wine producer's name, website, number of unique wines.
    */
    function readWineProducerById(uint _wineProducerId)
        public
        view
        returns(string memory name, string memory website,
        uint numWines, uint balance)
    {
        return (
            wineProducers[_wineProducerId].name,
            wineProducers[_wineProducerId].website,
            wineProducers[_wineProducerId].numWines,
            wineProducers[_wineProducerId].balance
        );
    }

    /**
        @author Keita Fukue
        @notice Get wine producer information by wine producer's address
        @param _wineProducer - wine producer's address
        @return wine producer's name, website, number of unique wines.
    */
    function readWineProducerByAccount(address _wineProducer)
        public
        view
        returns(uint wineProducerId, string memory name, string memory website,
        uint numWines, uint balance)
    {
        return (
            wineProducerIdLookup[_wineProducer],
            wineProducers[wineProducerIdLookup[_wineProducer]].name,
            wineProducers[wineProducerIdLookup[_wineProducer]].website,
            wineProducers[wineProducerIdLookup[_wineProducer]].numWines,
            wineProducers[wineProducerIdLookup[_wineProducer]].balance
        );
    }

    /**
        @author Keita Fukue
        @notice Get wine information by wine producer's id and wine id
        @param _wineProducerId - wine producer id
        @param _wineId - wine id
        @return wine name, wine description, wine sku, wine vintage
    */
    function readWineDescription(uint _wineProducerId, uint _wineId)
        public
        view
        checkIfWineProducerAndWineExists(_wineProducerId, _wineId)
        returns(string memory name, string memory description,
        string memory sku, uint vintage
        )
    {
        return (
            wineProducers[_wineProducerId].wines[_wineId].name,
            wineProducers[_wineProducerId].wines[_wineId].description,
            wineProducers[_wineProducerId].wines[_wineId].sku,
            wineProducers[_wineProducerId].wines[_wineId].vintage
        );
    }

    /**
        @author Keita Fukue
        @notice Get wine's sales related information by wine producer's id and wine id
        @param _wineProducerId - wine producer id
        @param _wineId - wine id
        @return wine name, wine's total supply, individual wine's price in wei, wine's total sales
    */
    function readWineSalesRelated(uint _wineProducerId, uint _wineId)
        public
        view
        checkIfWineProducerAndWineExists(_wineProducerId, _wineId)
        returns(string memory name, uint totalSupply,
        uint price, uint totalSales)
    {
        return (
            wineProducers[_wineProducerId].wines[_wineId].name,
            wineProducers[_wineProducerId].wines[_wineId].totalSupply,
            wineProducers[_wineProducerId].wines[_wineId].priceWei,
            wineProducers[_wineProducerId].wines[_wineId].totalSales
        );
    }

    /**
        @author Keita Fukue
        @notice Buy a certain number of wines from the wine producer.
        @dev Adds balance to the wine producer's address
        @param _wineProducerId - wine producer id
        @param _wineId - wine id
        @return wine name, wine's total supply, individual wine's price in wei, wine's total sales
    */
    function buyWine(uint _wineProducerId, uint _wineId, uint numberOfPurchasingWines)
        public
        payable
        stopInEmergency()
        checkIfWineProducerAndWineExists(_wineProducerId, _wineId)
    {
        uint winePrice = (wineProducers[_wineProducerId].wines[_wineId].priceWei) * ONE_WEI;
        uint purchaseAmount = winePrice.mul(numberOfPurchasingWines);
        require(msg.value >= purchaseAmount,
            'not enough value sent to buy wines');
        require(wineProducers[_wineProducerId].wines[_wineId].totalSupply
            >= numberOfPurchasingWines, 'Not enough wines left');
        uint ownersWineAmount = wineProducers[_wineProducerId].wines[_wineId].owners[msg.sender];
        wineProducers[_wineProducerId].wines[_wineId].owners[msg.sender] = ownersWineAmount.add(numberOfPurchasingWines);
        uint totalSales = wineProducers[_wineProducerId].wines[_wineId].totalSales;
        wineProducers[_wineProducerId].wines[_wineId].totalSales = totalSales.add(numberOfPurchasingWines);
        uint totalSupply = wineProducers[_wineProducerId].wines[_wineId].totalSupply;
        wineProducers[_wineProducerId].wines[_wineId].totalSupply = totalSupply.sub(numberOfPurchasingWines);
        uint balance = wineProducers[_wineProducerId].balance;
        wineProducers[_wineProducerId].balance = balance.add(purchaseAmount);
        emit LogBuyWine(msg.sender, _wineProducerId, _wineId, numberOfPurchasingWines);
        uint changeAmount = msg.value.sub(winePrice.mul(numberOfPurchasingWines));
        if(changeAmount > 0){
            emit LogGetRefund(msg.sender, _wineProducerId, _wineId, changeAmount);
            msg.sender.transfer(changeAmount);
        }
    }

    /**
        @author Keita Fukue
        @notice Get refund from specific wine.
        @dev Return the amount back to the user and subtract the amount from the wine producer's balance.
        @param _wineProducerId - wine producer id
        @param _wineId - wine id
        @return amount of refund
    */
    function getRefund(uint _wineProducerId, uint _wineId)
        public
        checkIfWineProducerAndWineExists(_wineProducerId, _wineId)
        returns(uint)
    {
        uint numberOfWines = wineProducers[_wineProducerId].wines[_wineId].owners[msg.sender];
        uint winePrice = wineProducers[_wineProducerId].wines[_wineId].priceWei.mul(ONE_WEI);
        require(numberOfWines > 0, 'not enough wines');
        uint amountToRefund = winePrice.mul(numberOfWines);
        uint balance = wineProducers[_wineProducerId].balance;
        require(amountToRefund <= balance, 'not enough balance');
        wineProducers[_wineProducerId].wines[_wineId].owners[msg.sender] = 0;
        uint totalSales = wineProducers[_wineProducerId].wines[_wineId].totalSales;
        wineProducers[_wineProducerId].wines[_wineId].totalSales = totalSales.sub(numberOfWines);
        uint totalSupply = wineProducers[_wineProducerId].wines[_wineId].totalSupply;
        wineProducers[_wineProducerId].wines[_wineId].totalSupply = totalSupply.add(numberOfWines);
        emit LogGetRefund(msg.sender, _wineProducerId, _wineId, amountToRefund);
        wineProducers[_wineProducerId].balance = balance.sub(amountToRefund);
        msg.sender.transfer(amountToRefund);
        return amountToRefund;
    }

    /**
        @author Keita Fukue
        @notice Get number of wines purchased by the caller's address
        @param _wineProducerId - wine producer id
        @param _wineId - wine id
        @return number of wines owned by the contract caller.
    */
    function getOwnersNumberOfWines(uint _wineProducerId, uint _wineId)
        public
        view
        checkIfWineProducerAndWineExists(_wineProducerId, _wineId)
        returns(uint purchasedWines)
    {
        return wineProducers[_wineProducerId].wines[_wineId].owners[msg.sender];
    }
}
