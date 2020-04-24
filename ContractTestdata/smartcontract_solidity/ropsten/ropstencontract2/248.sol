/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity ^0.5.7;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    /**
  * @dev Multiplies two numbers, throws on overflow.
  */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
  * @dev Adds two numbers, throws on overflow.
  */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

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

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


/**
@title IProperties
@dev This contract represents properties contract interface */
contract IProperties {
    /**
    @notice fired when owner is changed
     */
    event OwnerChanged(address newOwner);

    /**
    @notice fired when a manager's status is set
     */
    event ManagerSet(address manager, bool status);

    /**
    @notice fired when a new property is created
     */
    event PropertyCreated(
        uint256 propertyId,
        uint256 allocationCapacity,
        string title,
        string location,
        uint256 marketValue,
        uint256 maxInvestedATperInvestor,
        uint256 totalAllowedATinvestments,
        address AT,
        uint256 dateAdded
    );

    /**
    @notice fired when the status of a property is updated
     */
    event PropertyStatusUpdated(uint256 propertyId, uint256 status);

    /**
    @notice fired when a property is invested in
     */
    event PropertyInvested(uint256 propertyId, uint256 tokens);

    /**
    @dev fired when investment contract's status is set
    */
    event InvestmentContractStatusSet(address investmentContract, bool status);

    /**
    @dev function to change the owner
    @param newOwner the address of new owner
     */
    function changeOwner(address newOwner) external;

    /**
    @dev function to set the status of manager
    @param manager address of manager
    @param status the status to set
     */
    function setManager(address manager, bool status) external;

    /**
    @dev function to create a new property
    @param  allocationCapacity refers to the number of ATs allocated to a property
    @param title title of property
    @param location location of property
    @param marketValue market value of property in USD
    @param maxInvestedATperInvestor absolute amount of shares that could be allocated per person
    @param totalAllowedATinvestments absolute amount of shares to be issued
    @param AT address of AT contract
    */
   function createProperty(
        uint256 allocationCapacity,
        string memory title,
        string memory location,
        uint256 marketValue,
        uint256 maxInvestedATperInvestor,
        uint256 totalAllowedATinvestments,
        address AT
    ) public returns (bool);

    /**
    @notice function is called to update a property's status
    @param propertyId ID of the property
    @param status status of the property
     */
    function updatePropertyStatus(uint256 propertyId, uint256 status) external;

    /**
    @notice function is called to invest in the property
    @param investor the address of the investor
    @param propertyId the ID of the property to invest in
    @param shares the amount of shares being invested
     */
    function invest(address investor, uint256 propertyId, uint256 shares)
        public
        returns (bool);

    /**
    @dev this function is called to set the status of an investment contract
    @param investmentContract the address of investment contract
    @param status status of the investment smart contact
     */
    function setInvestmentContractStatus(
        address investmentContract,
        bool status
    ) external;

    /**
    @notice the function returns the paramters of a property
    @param propertyId the ID of the property to get
     */
    function getProperty(uint256 propertyId)
        public
        view
        returns (
            uint256,
            uint256,
            string memory,
            string memory,
            uint256,
            uint256,
            uint256,
            address,
            uint256,
            uint8
        );

    /**
    @notice function returns the list of property investors
    @param from the starting number . minimum = 0
    @param to the ending number
     */
    function getPropertyInvestors(uint256 propertyId, uint256 from, uint256 to)
        public
        view
        returns (address[] memory);

    /**
    @notice Called to get the total amount of investment and investment for a specific holder for a property
    @param propertyId The ID of the property
    @param holder The address of the holder
    @return The total amount of investment
    @return The amount of shares owned by the holder */
    function getTotalAndHolderShares(uint256 propertyId, address holder)
        public
        view
        returns (uint256 totalShares, uint256 holderShares);
}

/**
@title IInvestment
@dev This contract is an interface for Investment contract
 */
contract IDividendsWithETH {
    /**
    @dev fired on exchange state change
    */
    event StateChanged(uint256 state);

    /**
    @dev fired when property is set by owner
     */
    event PropertiesSet(address property);

    // Fired after the status for a manager is updated
    event ManagerStatusUpdated(address manager, bool managerStatus);

    /**
    @notice fired when dividend are created/paid by the manager
     */
    event DividendPaid(
        uint256 propertyId,
        uint256 dividendId,
        uint256 ethAmount
    );

     /**
    @notice fired when an investor withdraw his dividend
     */
    event DividendWithdrawn(
        uint256 propertyId,
        uint256 dividendId,
        address investor,
        uint256 amount
    );

    /**
    @notice fired when ETH is drawn from the contract by manager
     */
    event ETHWithdrawn(address withdrawer, uint256 amount);

    /// @notice Sets status for a manager
    /// @param manager The address of manager for which the status is to be updated
    /// @param managerStatus The status for the manager
    /// @return status of the transaction
    function setManagerStatus(address manager, bool managerStatus)
        external
        returns (bool);

    /**
    @notice is called by owner to set property address
    @param _properties it is the address of the property
     */
    function setProperty(IProperties _properties) external;

    /**
    @notice this function sets/changes state of this smart contract and only manager/owner can call it
    @param state it can be either 0 (ACTIVE) or 1 (INACTIVE)
     */
    function setState(uint256 state) external;

    /**
    @notice Used to pay/create dividend for a property
    @param  propertyId The ID of the property for which the dividend is being paid/created
    */
    function payDividend(uint256 propertyId)
        external
        payable;

    /**
    @notice Called to withdraw ETH dividend by investor
    @param dividendId The ID of the dividend from where the user wants to withdraw his dividend amount
     */
    function withdrawDividend(uint256 dividendId) public returns (bool);

    /**
    @notice Used to withdraw ETH from the contract by the manager
    @param amount The amount of ETH to withdraw | if amount is zero then all ETH balance is withdrawn from the contract
     */
    function withdrawETHByManager(uint256 amount) external;

    /**
    @notice Returns the complete list of all dividends
    @return The list of IDs of all dividends
    @return The list of totalDividendAmount of all dividends
    @return The list of totalInvestment of all dividends
    @return The list of dividendsAmountPaid of all dividends
     */
    function getAllDividendsList()
        public
        view
        returns (
            uint256[] memory propertyId,
            uint256[] memory totalDividendAmount,
            uint256[] memory totalInvestment,
            uint256[] memory dividendsAmountPaid
        );

    /**
    @notice Called to get the withdrawal status of an investor for a dividend
    @param  dividendId The ID of dividend
    @param investor The address of investor
    @return The status of withdrawal in true or false
     */
    function getInvestorStatusByDividendId(uint256 dividendId, address investor)
        public
        view
        returns (bool withdrawn);
}

contract DividendsWithETH is IDividendsWithETH, Ownable {
    using SafeMath for uint256;

    enum State {INACTIVE, ACTIVE} // enum value for the states of DividendsWithETH contract.

    struct Dividend {
        uint256 propertyId; // ID of the property for which the dividend is created.
        uint256 totalDividendAmount; // amount of dividend.
        uint256 totalInvestment; // total investment amount of the property.
        uint256 dividendsAmountPaid; // the amount of dividend that are withdrawn by the investors.
        mapping(address => bool) dividendWithdrawn; // mapping of investor address to its status(true or false) of payment.
    }

    mapping(uint256 => Dividend) public dividends; // mapping from dividendId to dividend

    mapping(address => bool) public managers; // mapping of manager address to its status(true or false) of eligibility.

    State stateOfDividendsWithETH; // current state( ACTIVE, INACTIVE ) of the contract
    uint256 dividendIdCount = 0; // total count of the dividens

    IProperties public properties; // properties interface to interact with the properties contract

    /**
    @dev constructor of the  DividendsWithETH contract
    */
    constructor() public {
        // set the current state of the contract as ACTIVE
        stateOfDividendsWithETH = State.ACTIVE;

        emit StateChanged(uint256(stateOfDividendsWithETH));
    }

    /**
     * @dev Throws if called by any account other than Managers.
     */
    modifier onlyManager() {
        require(managers[msg.sender], "Only manager can call this function.");
        _;
    }

    /// @notice Sets status for a manager
    /// @param manager The address of manager for which the status is to be updated
    /// @param managerStatus The status for the manager
    /// @return status of the transaction
    function setManagerStatus(address manager, bool managerStatus)
        external
        onlyOwner
        returns (bool)
    {
        require(
            manager != address(0),
            "Provided mannager address is not valid."
        );
        require(
            managers[manager] != managerStatus,
            "This status of manager is already set."
        );

        managers[manager] = managerStatus;

        emit ManagerStatusUpdated(manager, managerStatus);

        return true;
    }

    /**
    @notice is called by owner to set property address
    @param _properties it is the address of the property
     */
    function setProperty(IProperties _properties) external onlyOwner {
        require(
            address(_properties) != address(0),
            "properties address must be a valid address."
        );
        properties = _properties;

        emit PropertiesSet(address(properties));
    }

    /**
    @notice call is only allowed to pass when exchange is in ACTIVE state
     */
    modifier isStateActive() {
        require(
            stateOfDividendsWithETH == State.ACTIVE,
            "contract state is INACTIVE."
        );
        _;
    }

    /**
    @notice this function sets/changes state of this smart contract and only manager/owner can call it
    @param state it can be either 0 (ACTIVE) or 1 (INACTIVE)
     */
    function setState(uint256 state) external onlyOwner {
        require(state == 0 || state == 1, "Provided state is invalid.");
        require(
            state != uint256(stateOfDividendsWithETH),
            "Provided state is already set."
        );

        stateOfDividendsWithETH = State(state);

        emit StateChanged(uint256(stateOfDividendsWithETH));
    }

    /**
    @notice Used to pay/create dividend for a property
    @param  propertyId The ID of the property for which the dividend is being paid/created
    */
    function payDividend(uint256 propertyId)
        external
        payable
        onlyManager
        isStateActive
    {
        require(propertyId > 0, "propertyId should be greater than zero.");
        require(msg.value > 0, "msg.value should be greater than 0");

        // get total property investment from the properties contract
        uint256 dividendAmount = msg.value;
        (, , , , , , uint256 totalPropertyInvestment, , , ) = properties
            .getProperty(propertyId);

        Dividend memory newDividend = Dividend(
            propertyId,
            dividendAmount,
            totalPropertyInvestment,
            uint256(0)
        );

        dividendIdCount = dividendIdCount.add(1);

        dividends[dividendIdCount] = newDividend;

        emit DividendPaid(propertyId, dividendIdCount, dividendAmount);

    }

    /**
    @notice Called to withdraw ETH dividend by investor
    @param dividendId The ID of the dividend from where the user wants to withdraw his dividend amount
     */
    function withdrawDividend(uint256 dividendId)
        public
        isStateActive
        returns (bool)
    {
        require(dividendId > 0, "dividendId should be greater than zero");

        Dividend storage dividend = dividends[dividendId];

        require(
            dividend.propertyId != 0,
            "dividend with the given property ID does not exists"
        );
        require(
            !dividend.dividendWithdrawn[msg.sender],
            "dividend has already been withdrawn"
        );

        // Get amount of the shares of the investor in the given property
        (, uint256 investmentByUser) = properties.getTotalAndHolderShares(
            dividend.propertyId,
            msg.sender
        );

        // calculate dividend amount for the given investor
        uint256 userDividendAmount = calculateDividend(
            dividend.totalInvestment,
            dividend.totalDividendAmount,
            investmentByUser
        );

        require(
            userDividendAmount <= address(this).balance,
            "The dividendWithETH contract does not have enough ETH balance to pay dividend."
        );

        dividend.dividendWithdrawn[msg.sender] = true;
        dividend.dividendsAmountPaid = dividend.dividendsAmountPaid.add(
            userDividendAmount
        );

        // transfer dividend to investor
        msg.sender.transfer(userDividendAmount);

        emit DividendWithdrawn(
            dividend.propertyId,
            dividendId,
            msg.sender,
            userDividendAmount
        );

        return true;
    }

    /**
    @notice Used to withdraw ETH from the contract by the manager
    @param amount The amount of ETH to withdraw | if amount is zero then all ETH balance is withdrawn from the contract
     */
    function withdrawETHByManager(uint256 amount) external onlyManager {
        uint256 contractBalance = address(this).balance;

        require(contractBalance > 0, "Contract has no ETH in it.");

        if (amount == 0) {
            msg.sender.transfer(contractBalance);
            emit ETHWithdrawn(msg.sender, contractBalance);
        } else {
            require(
                amount <= contractBalance,
                "Contract has less balance than the amount specified."
            );
            msg.sender.transfer(amount);
            emit ETHWithdrawn(msg.sender, amount);
        }
    }

    /**
    @notice Returns the complete list of all dividends
    @return The list of IDs of all dividends
    @return The list of totalDividendAmount of all dividends
    @return The list of totalInvestment of all dividends
    @return The list of dividendsAmountPaid of all dividends
     */
    function getAllDividendsList()
        public
        view
        returns (
            uint256[] memory propertyId,
            uint256[] memory totalDividendAmount,
            uint256[] memory totalInvestment,
            uint256[] memory dividendsAmountPaid
        )
    {
        propertyId = new uint256[](dividendIdCount);
        totalDividendAmount = new uint256[](dividendIdCount);
        totalInvestment = new uint256[](dividendIdCount);
        dividendsAmountPaid = new uint256[](dividendIdCount);

        for (uint256 i = 1; i <= dividendIdCount; i++) {
            Dividend memory dividend = dividends[i];

            propertyId[i - 1] = dividend.propertyId;
            totalDividendAmount[i - 1] = dividend.totalDividendAmount;
            totalInvestment[i - 1] = dividend.totalInvestment;
            dividendsAmountPaid[i - 1] = dividend.dividendsAmountPaid;
        }

    }

    /**
    @notice Called to get the withdrawal status of an investor for a dividend
    @param  dividendId The ID of dividend
    @param investor The address of investor
    @return The status of withdrawal in true or false
     */
    function getInvestorStatusByDividendId(uint256 dividendId, address investor)
        public
        view
        returns (bool withdrawn)
    {
        require(dividendId > 0, "dividendId cannot be zero");

        Dividend storage dividend = dividends[dividendId];

        withdrawn = dividend.dividendWithdrawn[investor];
    }

    /**
    @dev Fallback function to accept ETH
     */
    function() external payable {
        require(msg.data.length == 0, "Error in calling the function");
    }

    /**
    @notice Function to calculated dividend amount
    @param  totalInvestments The total nvestments in a property
    @param totalDividend The amount of total dividends allocated to a dividend
    @param userInvestment The investment of a user in a property
    @return The amount of dividend withdrawable by user
     */
    function calculateDividend(
        uint256 totalInvestments,
        uint256 totalDividend,
        uint256 userInvestment
    ) private pure returns (uint256) {
        return
            userInvestment 
                .mul(1000)
                .div(totalInvestments)
                .mul(totalDividend)
                .div(1000);
    }

}
