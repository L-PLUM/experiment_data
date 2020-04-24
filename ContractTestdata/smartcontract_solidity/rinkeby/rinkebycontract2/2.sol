/**
 *Submitted for verification at Etherscan.io on 2019-08-13
*/

pragma solidity ^0.5.0;

/**
 * @title - Special Flag
 * ███████╗██╗      █████╗  ██████╗  ██████╗ ██╗███╗   ██╗ ██████╗
 * ██╔════╝██║     ██╔══██╗██╔════╝ ██╔════╝ ██║████╗  ██║██╔════╝
 * █████╗  ██║     ███████║██║  ███╗██║  ███╗██║██╔██╗ ██║██║  ███╗
 * ██╔══╝  ██║     ██╔══██║██║   ██║██║   ██║██║██║╚██╗██║██║   ██║
 * ██║     ███████╗██║  ██║╚██████╔╝╚██████╔╝██║██║ ╚████║╚██████╔╝
 * ╚═╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝╚═╝  ╚═══╝ ╚═════╝
 * ---
 *
 * POWERED BY
 *  __    ___   _     ___  _____  ___     _     ___
 * / /`  | |_) \ \_/ | |_)  | |  / / \   | |\ |  ) )
 * \_\_, |_| \  |_|  |_|    |_|  \_\_/   |_| \| _)_)
 *
 * Game at https://skullys.co/
 **/

interface IERC165 {
    /**
     * @notice Query if a contract implements an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @dev Interface identification is specified in ERC-165. This function
     * uses less than 30,000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

contract ERC721 is IERC165 {

    // IERC721
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) public view returns (uint256 balance);
    function ownerOf(uint256 tokenId) public view returns (address owner);

    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);

    function transferFrom(address from, address to, uint256 tokenId) public;
    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

    // IERC721Metadata
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) public view returns (string memory);

    // IERC721Enumerable
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);

    function tokenByIndex(uint256 index) public view returns (uint256);
    
    function getSkully(uint256 _skullyId)
    external
    view
    returns (
        uint256 attack,
        uint256 defend,
        uint256 birthTime,
        string memory category,
        string memory URI,
        uint256 totalTradingTime
    );
}

contract SkullyItems {
    
    function getSkullyItems(uint256 skullyId) public view
    returns (uint256 PO8,
        uint256 totalAccessoriesAP,
        uint256 totalAccessoriesDP,
        uint256 totalAccessoriesPO8,
        uint256 totalAccessoriesPO8DailyMultiplier,
        uint8 rank,
        uint256 flags,
        uint256[] memory badges);
     
    function getTotalAccessoriesAP(uint256 skullyId) public view returns (uint256);

    function getTotalAccessoriesDP(uint256 skullyId) public view returns (uint256);
    
    function getSkullyFlagRank(uint256 skullyId) public view returns (uint256, uint8);
}

contract ERC20 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public;
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract GameRole {
    using Roles for Roles.Role;

    event GameControllerAdded(address indexed account);
    event GameControllerRemoved(address indexed account);

    Roles.Role private _games;

    constructor () internal {
        _addGameController(msg.sender); // the controller of Game Contract address
    }

    modifier onlyGameController() {
        require(isGameController(msg.sender), "GameRole: caller does not have the Game role");
        _;
    }

    function isGameController(address account) public view returns (bool) {
        return _games.has(account);
    }

    function addGameController(address account) public onlyGameController {
        _addGameController(account);
    }

    function renounceGameController(address account) public onlyGameController {
        _removeGameController(account);
    }

    function _addGameController(address account) internal {
        _games.add(account);
        emit GameControllerAdded(account);
    }

    function _removeGameController(address account) internal {
        _games.remove(account);
        emit GameControllerRemoved(account);
    }
}

contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {
        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {
        _addPauser(account);
    }

    function renouncePauser() public {
        _removePauser(msg.sender);
    }

    function _addPauser(address account) internal {
        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {
        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}

/**
 * @dev Contract module which allows children to implement an emergency stop
 * mechanism that can be triggered by an authorized account.
 *
 * This module is used through inheritance. It will make available the
 * modifiers `whenNotPaused` and `whenPaused`, which can be applied to
 * the functions of your contract. Note that they will not be pausable by
 * simply including this module, only once the modifiers are put in place.
 */
contract Pausable is PauserRole {
    /**
     * @dev Emitted when the pause is triggered by a pauser (`account`).
     */
    event Paused(address account);

    /**
     * @dev Emitted when the pause is lifted by a pauser (`account`).
     */
    event Unpaused(address account);

    bool private _paused;

    /**
     * @dev Initializes the contract in unpaused state. Assigns the Pauser role
     * to the deployer.
     */
    constructor () internal {
        _paused = false;
    }

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused, "Pausable: not paused");
        _;
    }

    /**
     * @dev Called by a pauser to pause, triggers stopped state.
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev Called by a pauser to unpause, returns to normal state.
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

contract SpecialFlaggingAccessControl is Pausable {
     /// @dev The ERC-165 interface signature for ERC-721.
    ///  Ref: https://github.com/ethereum/EIPs/issues/165
    ///  Ref: https://github.com/ethereum/EIPs/issues/721
    bytes4 constant InterfaceSignature_ERC721 = bytes4(0x80ac58cd);
    ERC721 public nonFungibleContract;
    
    ERC20 po8Token;
    
    SkullyItems public skItem;
    
    constructor(address _nftAddress, address skItemAddress, address po8Address) public {
        ERC721 candidateContract = ERC721(_nftAddress);
        require(candidateContract.supportsInterface(InterfaceSignature_ERC721), "The candidate contract must supports ERC721");
        nonFungibleContract = candidateContract;
        
        ERC20 po8 = ERC20(po8Address);
        po8Token = po8;
        
        skItem = SkullyItems(skItemAddress);
    }
}

contract SpecialFlagging is SpecialFlaggingAccessControl, GameRole {
    /// Nearest day the skull have geo flagging action
    /// mapping (uint256 => uint256) public nearestDateFlagging;
    
    uint256 public exchangeRate;
    
    uint256 public rate; // 86400s = 8.64 po8 - 1s = 0.00001 po8
    
    mapping(uint256 => uint256) public allSpecialLocationIndexs;
    
    /// Special Location structure
    struct SpecialLocation {
        uint256 locationId;
        uint256 lat;
        uint256 long;
        uint256 creater;
        uint256 createdTime;
        uint256 owner;
        uint256 takenTime;
        uint256 price; // wei ETH
    }
    
    SpecialLocation[] allSpecialLocations;
    
    mapping(uint256 => uint256) public totalSpLsOfSkully;
    
    event SpecialLocationCreated(uint256 locationId, uint256 latitude, uint256 longitude, uint256 creater, uint256 timeCreated, uint256 price);
    
    event PO8ClaimedByLocation(uint256 locationId, uint256 skullyId, address indexed whoClaimed, uint256 totalClaimed, address indexed caller);
    event AllPO8ClaimedBySkully(uint256 skullyId, address indexed whoClaimed, uint256[] locationsId, uint256 totalClaimed);
    event PO8ClaimedBySkullyWithSomeLocations(uint256 skullyId, address indexed whoClaimed, uint256[] locationsId, uint256 totalClaimed);
    event AllPO8Claimed(address indexed caller, address indexed whoClaimed, uint256[] skullysId, uint256 totalClaimed);
    
    event NewPriceUpdated(uint256 locationId, uint256 newPrice);
    
    event ExchangeRateUpdated(uint256 _newExchangeRate);
    
    /* @notice The constructor of main contract
     * @dev create default special location, rate, exchangeRate
     * specify skully core and po8 token address
     * @param _nftAddress skully core address
     * @param po8Address po8 token address
     */
    constructor(address _nftAddress, address skItemAddress, address po8Address) public SpecialFlaggingAccessControl(_nftAddress, skItemAddress, po8Address) {
        allSpecialLocations.push(
            SpecialLocation({
                locationId: 0,
                lat: 0,
                long: 0,
                creater: 0,
                createdTime: now,
                owner: 0,
                takenTime: 0,
                price: 0
                }));
        rate = 1e13;
        exchangeRate = 23000; // base-on ETH price
        allSpecialLocationIndexs[0] = 0 ;
        attackFee = 375;
    }
    
    /* @notice the function is used to set Po8 address if changed
     * @dev 
     * @param po8Address the new po8 token address
     * @return true if successfully changed
     */
    function setPO8TokenContractAdress(address po8Address) external onlyGameController returns (bool) {
        ERC20 po8 = ERC20(po8Address);
        po8Token = po8;
        return true;
    }
    
    /* @notice The Owner can set the new exchange rate between ETH and PO8 token.
     * @dev watch the ETH price before update.
     * @param _newExchangeRate the new exchange rate
     * @return _newExchangeRate
     */
    function setExchangeRate(uint256 _newExchangeRate) external onlyGameController returns (uint256) {
        exchangeRate = _newExchangeRate;

        emit ExchangeRateUpdated(_newExchangeRate);

        return _newExchangeRate;
    }

    /* @notice only game controller can create a new special location
     * @dev use this function 
     * @param locationId the id from back-end
     * @param skullyId the id of skully AKA owner
     * @param lat latitude of location
     * @param long longitude of location
     * @param price the location's price
     */
    function createSpecialLocation(uint256 locationId, uint256 skullyId, uint256 lat, uint256 long, uint256 price) public onlyGameController {
        uint256 loIndex = allSpecialLocations.length;
        allSpecialLocations.push(
            SpecialLocation({
                locationId: locationId,
                lat: lat,
                long: long,
                creater: skullyId,
                createdTime: now,
                owner: skullyId,
                takenTime: now,
                price: price
                }));
        
        assert(allSpecialLocationIndexs[locationId] == 0); // locationId must not be duplicate
        allSpecialLocationIndexs[locationId] = loIndex; 
        emit SpecialLocationCreated(locationId, lat, long, skullyId, now, price);
    }
    
    /* @notice user can get all location's information
     * @param locationId the id of location you want to get information
     * @return latitude, longitude, creater, createdTime, owner, takenTime, price
     */
    function getSpecialLocationInformation(uint256 locationId) public view returns (
        uint256 latitude, 
        uint256 longitude, 
        uint256 creater, 
        uint256 createdTime, 
        uint256 owner, 
        uint256 takenTime,
        uint256 price) {
        SpecialLocation storage sl = allSpecialLocations[allSpecialLocationIndexs[locationId]];
        return (
            sl.lat,
            sl.long,
            sl.creater,
            sl.createdTime,
            sl.owner,
            sl.takenTime,
            sl.price);
    }
    
    /* @notice user (skully's owner) can use PO8 to pin a location with price which determined by game controller,
     * plus totalSpLsOfSkully by 1 when successful pining.
     * @dev user must approve PO8 to this contract so contract can use user's po8 to pay, it's called fee
     * @param locationId the id from back-end
     * @param skullyId the id of skully AKA owner of location
     * @param lat latitude of location
     * @param long longitude of location
     * @param price the location's price 
     */
    function pinNewSpecialLocationByPO8(uint256 locationId, uint256 skullyId, uint256 lat, uint256 long, uint256 price) external whenNotPaused {
        //require(now - nearestDateFlagging[skullyId] >= 86400);
        uint256 fee = price * exchangeRate; // price in wei ETH
        require(po8Token.balanceOf(msg.sender) >= fee); // must approved before do this action
        
        po8Token.transferFrom(msg.sender, address(this), fee);
        
        uint256 loIndex = allSpecialLocations.length;
        
        allSpecialLocations.push(SpecialLocation({
            locationId: locationId,
            lat: lat, 
            long: long,
            creater: skullyId,
            createdTime: now,
            owner: skullyId,
            takenTime: now,
            price: price
            }));
        
        totalSpLsOfSkully[skullyId]++;
        
        assert(allSpecialLocationIndexs[locationId] == 0); // locationId must not be duplicate
        allSpecialLocationIndexs[locationId] = loIndex;
        
        emit SpecialLocationCreated(locationId, lat, long, skullyId, now, price);
    }
    
    /* @notice user (skully's owner) can use PO8 to pin a location with price which determined by game controller,
     * plus totalSpLsOfSkully by 1 when successful pining,
     * the price of this location is msg.value which specified in fallback payable
     * @dev user must approve PO8 to this contract so contract can use user's po8 to pay, it's called fee 
     * @param locationId the id from back-end
     * @param skullyId the id of skully
     * @param lat latitude of location
     * @param long longitude of location
     */
    function pinNewSpecialLocationByETH(uint256 locationId, uint256 skullyId, uint256 lat, uint256 long) external payable whenNotPaused {
        uint256 loIndex = allSpecialLocations.length;
        
        allSpecialLocations.push(SpecialLocation({
            locationId: locationId,
            lat: lat,
            long: long,
            creater: skullyId,
            createdTime: now,
            owner: skullyId,
            takenTime: now,
            price: msg.value
            }));
        
        totalSpLsOfSkully[skullyId]++;
        
        assert(allSpecialLocationIndexs[locationId] == 0); // locationId must not be duplicate
        allSpecialLocationIndexs[locationId] = loIndex;
        
        emit SpecialLocationCreated(locationId, lat, long, skullyId, now, msg.value);
    }
    
    /* @notice controller can set any location's price when needed
     * @dev bcz user may hack this price, therefore this function is appeared
     * @param locationId the id of location you want to set new price
     * @return new price
     */
    function setLocationPrice(uint256 locationId, uint256 newPrice) public onlyGameController returns (uint256) {
        allSpecialLocations[allSpecialLocationIndexs[locationId]].price = newPrice;
        
        return newPrice;
    }
    
    /* @notice controller can set any location's lat, long when needed
     * @dev bcz user may hack this lat, long, therefore this function is appeared
     * @param lat new latitude of location
     * @param long new longitude of location
     * @return new latitude and longitude
     */
    function setLocationLatLong(uint256 locationId, uint256 newLat, uint256 newLong) public onlyGameController returns (uint256, uint256) {
        allSpecialLocations[allSpecialLocationIndexs[locationId]].lat = newLat;
        allSpecialLocations[allSpecialLocationIndexs[locationId]].long = newLong;
        
        return (newLat, newLong);
    }
    
    /* @notice this function is used by controller to set new owner of location
     * @dev
     * @param locationId the id of location you want to set new owner
     * @param attacker new owner
     */
    function _successAttack(uint256 locationId, uint256 attacker) internal {
        allSpecialLocations[allSpecialLocationIndexs[locationId]].owner = attacker;
        allSpecialLocations[allSpecialLocationIndexs[locationId]].takenTime = now;
    }
    
    /* @notice user can claim PO8 in the location skully owned
     * @dev if location does not belong to skully, then PO8 will transfer to real master of location owner
     * @param locationId the id of location you want to claim PO8
     */
    function claimPO8ByLocationId(uint256 locationId) public whenNotPaused {
        uint256 locationOwner = allSpecialLocations[allSpecialLocationIndexs[locationId]].owner; //skullyId
        
        po8Token.transfer(nonFungibleContract.ownerOf(locationOwner), (now - allSpecialLocations[allSpecialLocationIndexs[locationId]].takenTime) * rate);
        
        allSpecialLocations[allSpecialLocationIndexs[locationId]].takenTime = now;
        
        emit PO8ClaimedByLocation(
            locationId, 
            locationOwner, 
            nonFungibleContract.ownerOf(locationOwner), 
            (now - allSpecialLocations[allSpecialLocationIndexs[locationId]].takenTime) * rate, 
            msg.sender);
    }
    
    /* @notice user can claim PO8 in the location skully owned
     * @dev if location does not belong to skully, then PO8 will transfer to real master of location owner
     * @param skullyId the id of skully
     * @param locationIds the array id of locations you want to claim PO8
     */
    function claimPO8BySkullyWithLocations(uint256 skullyId, uint256[] memory locationIds) public whenNotPaused {
        uint256 locationOwner = allSpecialLocations[allSpecialLocationIndexs[locationIds[0]]].owner;
        uint256 totalPO8;
        for(uint256 i = 0; i < locationIds.length; i++) {
            assert(locationOwner == allSpecialLocations[allSpecialLocationIndexs[locationIds[i]]].owner); //skullyId
        
            totalPO8 += (now - allSpecialLocations[allSpecialLocationIndexs[locationIds[i]]].takenTime) * rate;
        
            allSpecialLocations[allSpecialLocationIndexs[locationIds[i]]].takenTime = now;
        }
        po8Token.transfer(nonFungibleContract.ownerOf(locationOwner), totalPO8);
        emit PO8ClaimedBySkullyWithSomeLocations(skullyId, msg.sender, locationIds, totalPO8);
    }
    
    /* @notice user can claim PO8 in all locations skully owned
     * @dev if location does not belong to skully, then PO8 will transfer to real master of location owner
     * @param locationIds the array id of locations you want to claim PO8
     */
    function claimAllPO8BySkully(uint256 skullyId) public whenNotPaused {
        uint256[] memory allLocationIds = getAllLocationsIdOfSkully(skullyId);
        uint256 locationOwner = allSpecialLocations[allSpecialLocationIndexs[allLocationIds[0]]].owner;
        uint256 totalPO8;
        
        for(uint256 i = 0; i < allLocationIds.length; i++) {
            assert(locationOwner == allSpecialLocations[allSpecialLocationIndexs[allLocationIds[i]]].owner); //skullyId
        
            totalPO8 += (now - allSpecialLocations[allSpecialLocationIndexs[allLocationIds[i]]].takenTime) * rate;
            
            allSpecialLocations[allSpecialLocationIndexs[allLocationIds[i]]].takenTime = now;
        }
        po8Token.transfer(nonFungibleContract.ownerOf(locationOwner), totalPO8);
        emit AllPO8ClaimedBySkully(skullyId, msg.sender, allLocationIds, totalPO8);
    }
    
    /* @notice User can claim all PO8 belong to Special Flags of all skullys they own,
     * by put the skully into array and make a transaction
     * @param skullyIds Array skullys, which was chosen to claim PO8 with their Special Flags
     */
    function claimAllPO8(uint256[] memory skullyIds) public whenNotPaused {
        address caller = nonFungibleContract.ownerOf(skullyIds[0]);
        uint256 totalPO8;
        uint256[] memory allLocationIds;
        uint256 locationOwner;
        
        for(uint256 i = 0; i < skullyIds.length; i++) {
            assert(caller == nonFungibleContract.ownerOf(skullyIds[i]));
            
            allLocationIds = getAllLocationsIdOfSkully(skullyIds[i]);
            locationOwner = allSpecialLocations[allSpecialLocationIndexs[allLocationIds[0]]].owner;
            for(uint256 j = 0; j < allLocationIds.length; j++) {
                assert(locationOwner == allSpecialLocations[allSpecialLocationIndexs[allLocationIds[j]]].owner); //skullyId
            
                totalPO8 += (now - allSpecialLocations[allSpecialLocationIndexs[allLocationIds[j]]].takenTime) * rate;
                
                allSpecialLocations[allSpecialLocationIndexs[allLocationIds[j]]].takenTime = now;
            }
        }
        po8Token.transfer(caller, totalPO8);
        emit AllPO8Claimed(caller, msg.sender, skullyIds, totalPO8);
    }
    
    /* @notice User can see all locations which belong to skully
     * @param skullyId the id of skully
     * @return an array is containing all locationId which skully own
     */
    function getAllLocationsIdOfSkully(uint256 skullyId) public view returns (uint256[] memory) {
        uint256[] memory allLocationIds = new uint256[](totalSpLsOfSkully[skullyId]);
        uint256 count;
        for(uint256 i = 1; i < allSpecialLocations.length; i++) {
            if(allSpecialLocations[i].owner == skullyId) {
                allLocationIds[count] = allSpecialLocations[i].locationId;
                count++;
            }
        }
        return allLocationIds;
    }
    
    /* @notice users can see total current PO8 in the location made.
     * @param locationId the id of location
     * @return PO8 amount
     */
    function getCurrentPO8CanClaimInLocation(uint256 locationId) public view returns (uint256) {
        return (now - allSpecialLocations[allSpecialLocationIndexs[locationId]].takenTime) * rate;
    }
    
    /* @notice Controller can get PO8 from contract anytime
     */
    function getBackERC20Token(address tokenAddress) external onlyGameController {
        ERC20 token = ERC20(tokenAddress);
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
    
    /* @notice Controller can get ether from contract anytime
     */
    function withdrawBalance(uint256 amount) external onlyGameController {
        msg.sender.transfer(amount);
    }
    
    /// -----------------------------------------------------
    uint256 public attackFee; // in percentage
    
    mapping(uint256 => bool) public isAttackedState;
    
    struct Battle {
        uint256 battleId;
        uint256 locationId;
        uint256 attacker;
        uint256 defender;
        uint256 timeAttack;
        uint256 fee;
        uint8 state; // 0 : pending, 1 : win, 2 : lose
        bool attackByETH;
        bool attackByPO8;
    }
    
    Battle[] public allBattles;
    
    event BattleCreated(
        uint256 id, 
        uint256 locationId, 
        uint256 attacker, 
        uint256 defender, 
        uint256 timeAttack, 
        uint256 fee, 
        uint8 state,
        bool attackByETH,
        bool attackByPO8);
    
    event SpecialLocationAttackSussess(uint256 battleId, uint256 locationId, uint256 newOwner);
    event SpecialLocationAttackFail(uint256 battleId, uint256 locationId, uint256 attacker);
    
    /* @notice 
     * @dev 
     * @param 
     * @param 
     * @return 
     */
    function createBattleByETH(uint256 locationId, uint256 attacker) public whenNotPaused payable {
        require(isAttackedState[locationId] == false);
        require(msg.value == allSpecialLocations[allSpecialLocationIndexs[locationId]].price);
        
        uint256 locationOwner = allSpecialLocations[locationId].owner;
        
        require(canAttack(attacker, locationOwner));
        
        uint256 fee = allSpecialLocations[allSpecialLocationIndexs[locationId]].price; // price in wei ETH
        
        //po8Token.transferFrom(msg.sender, address(this), fee);
        
        uint256 id = allBattles.length;
        
        allBattles.push(Battle({
           battleId: id,
           locationId: locationId,
           attacker: attacker,
           defender: locationOwner,
           timeAttack: now,
           fee: fee,
           state: 0,
           attackByETH: true,
           attackByPO8: false
        }));
        isAttackedState[locationId] = true;
        
        emit BattleCreated(id, locationId, attacker, locationOwner, now, fee, 0, true, false);
    }
    
    /* @notice 
     * @dev 
     * @param 
     * @param 
     * @return 
     */
    function giveUpByETH(uint256 battleId) public whenNotPaused {
        require(isAttackedState[allBattles[battleId].locationId] == true);
        require(allBattles[battleId].state == 0);
        require(allBattles[battleId].attackByETH == true);
        
        address payable defenderOwner = address(uint160(address(nonFungibleContract.ownerOf(allBattles[battleId].defender))));
        
        if(now - allBattles[battleId].timeAttack < 2 days)
            require (msg.sender == defenderOwner);
        
        isAttackedState[allBattles[battleId].locationId] = false; // set state of location
        
        allBattles[battleId].state = 1; // set state win of Battle
        
        claimPO8ByLocationId(allBattles[battleId].locationId); // transfer PO8 to owner of skully
        
        defenderOwner.transfer(allBattles[battleId].fee * 9625 * 10000); // transfer price of location
        
        _successAttack(allBattles[battleId].locationId, allBattles[battleId].attacker); // transfer location to attacker
        
        emit SpecialLocationAttackSussess(battleId, allBattles[battleId].locationId, allBattles[battleId].attacker);
    }
    
    /* @notice 
     * @dev 
     * @param
     * @return 
     */
    function defendByETH(uint256 battleId) public whenNotPaused {
        address payable defenderOwner = address(uint160(address(nonFungibleContract.ownerOf(allBattles[battleId].defender))));
        require(msg.sender == defenderOwner);
        require(allBattles[battleId].attackByETH == true);
        require(isAttackedState[allBattles[battleId].locationId] == true);
        require(allBattles[battleId].state == 0);
        require(now - allBattles[battleId].timeAttack < 2 days); // require defend before 2 days
        require(canDefend(allBattles[battleId].defender, allBattles[battleId].attacker));
        
        isAttackedState[allBattles[battleId].locationId] = false; // set state of location
        
        allBattles[battleId].state = 2; // set the state to lose of Battle
        
        address payable attackerOwner = address(uint160(address(nonFungibleContract.ownerOf(allBattles[battleId].attacker))));
        
        attackerOwner.transfer(allBattles[battleId].fee * 9625 * 10000); // transfer price of location
        
        emit SpecialLocationAttackFail(battleId, allBattles[battleId].locationId, allBattles[battleId].attacker);
    }
    
    /// -------------------------PO8----------------------------///
    
    /* @notice 
     * @dev 
     * @param 
     * @param 
     * @return 
     */
    /*function createBattleByPO8(uint256 locationId, uint256 attacker) public whenNotPaused {
        require(isAttackedState[locationId] == false);
        //require(msg.value == allSpecialLocations[allSpecialLocationIndexs[locationId]].price);
        
        uint256 locationOwner = allSpecialLocations[locationId].owner;
        
        require(canAttack(attacker, locationOwner));
        
        uint256 fee = allSpecialLocations[allSpecialLocationIndexs[locationId]].price * exchangeRate; // price in wei ETH
        
        po8Token.transferFrom(msg.sender, address(this), fee);
        
        uint256 id = allBattles.length;
        
        allBattles.push(Battle({
           battleId: id,
           locationId: locationId,
           attacker: attacker,
           defender: locationOwner,
           timeAttack: now,
           fee: fee,
           state: 0,
           attackByETH: false,
           attackByPO8: true
        }));
        isAttackedState[locationId] = true;
        
        emit BattleCreated(id, locationId, attacker, locationOwner, now, fee, 0, false, true);
    }*/
    
    /* @notice 
     * @dev 
     * @param 
     * @param 
     * @return 
     */
    /*function giveUpByPO8(uint256 battleId) public whenNotPaused {
        require(isAttackedState[allBattles[battleId].locationId] == true);
        require(allBattles[battleId].state == 0);
        require(allBattles[battleId].attackByPO8 == true);
        
        address payable defenderOwner = address(uint160(address(nonFungibleContract.ownerOf(allBattles[battleId].defender))));
        
        if(now - allBattles[battleId].timeAttack < 2 days)
            require (msg.sender == defenderOwner);
        
        isAttackedState[allBattles[battleId].locationId] = false; // set state of location
        
        allBattles[battleId].state = 1; // set state win of Battle
        
        claimPO8ByLocationId(allBattles[battleId].locationId); // transfer PO8 to owner of skully
        
        po8Token.transfer(defenderOwner, allBattles[battleId].fee * 9625 * 10000); // transfer price of location
        
        _successAttack(allBattles[battleId].locationId, allBattles[battleId].attacker); // transfer location to attacker
        
        emit SpecialLocationAttackSussess(battleId, allBattles[battleId].locationId, allBattles[battleId].attacker);
    }*/
    
    /* @notice 
     * @dev 
     * @param
     * @return 
     */
    /*function defendByPO8(uint256 battleId) public whenNotPaused {
        address payable defenderOwner = address(uint160(address(nonFungibleContract.ownerOf(allBattles[battleId].defender))));
        require(msg.sender == defenderOwner);
        require(allBattles[battleId].attackByPO8 == true);
        require(isAttackedState[allBattles[battleId].locationId] == true);
        require(allBattles[battleId].state == 0);
        require(now - allBattles[battleId].timeAttack < 2 days); // require defend before 2 days
        require(canDefend(allBattles[battleId].defender, allBattles[battleId].attacker));
        
        isAttackedState[allBattles[battleId].locationId] = false; // set state of location
        
        allBattles[battleId].state = 2; // set state lose of Battle
        
        address payable attackerOwner = address(uint160(address(nonFungibleContract.ownerOf(allBattles[battleId].attacker))));
        
        po8Token.transfer(attackerOwner, allBattles[battleId].fee * 9625 * 10000); // transfer price of location
        
        emit SpecialLocationAttackFail(battleId, allBattles[battleId].locationId, allBattles[battleId].attacker);
    }*/
    
    /* @notice 
     * @dev 
     * @param
     * @return 
     */
    function canAttack(uint256 attacker, uint256 defender) public view returns (bool) {
        uint8 attackerRank;
        (, attackerRank) = skItem.getSkullyFlagRank(attacker);
        uint8 defenderRank;
        (, defenderRank) = skItem.getSkullyFlagRank(defender);
        require(attackerRank > 0 && defenderRank > 0);
        if(attackerRank > defenderRank) // because rank 1 > rank 2
            return false;
        
        uint256 attackerAccessoriesAP;
        attackerAccessoriesAP = skItem.getTotalAccessoriesAP(attacker);
        uint256 defenderAccessoriesDP;
        defenderAccessoriesDP = skItem.getTotalAccessoriesDP(defender);
        
        // calculate attackerPower
        uint256 attackerAP;
        (attackerAP,,,,,) = nonFungibleContract.getSkully(attacker);
        
        uint256 totalAttackerAP = attackerAccessoriesAP + attackerAP;
        
        // calculate defenderPower
        uint256 defenderDP;
        (,defenderDP,,,,) = nonFungibleContract.getSkully(defender);
        
        uint256 totalDefenderDP = defenderAccessoriesDP + defenderDP;
        
        if(totalAttackerAP < totalDefenderDP)
            return false;
        
        return true;
    }
    
    /* @notice 
     * @dev 
     * @param
     * @return 
     */
    function canDefend(uint256 defender, uint256 attacker) public view returns (bool) {
        uint8 defenderRank;
        (, defenderRank) = skItem.getSkullyFlagRank(defender);
        uint8 attackerRank;
        (, attackerRank) = skItem.getSkullyFlagRank(attacker);
        require(defenderRank > 0 && attackerRank > 0);
        if(defenderRank > attackerRank) // because rank 1 > rank 2
            return false;
        
        uint256 defenderAccessoriesDP;
        defenderAccessoriesDP = skItem.getTotalAccessoriesDP(defender);
        uint256 attackerAccessoriesAP;
        attackerAccessoriesAP = skItem.getTotalAccessoriesAP(attacker);
        
        // calculate defenderPower
        uint256 defenderDP;
        (,defenderDP,,,,) = nonFungibleContract.getSkully(defender);
        
        uint256 totalDefenderDP = defenderAccessoriesDP + defenderDP;
        
        // calculate attackerPower
        uint256 attackerAP;
        (attackerAP,,,,,) = nonFungibleContract.getSkully(attacker);
        
        uint256 totalAttackerAP = attackerAccessoriesAP + attackerAP;
        
        if(totalDefenderDP < totalAttackerAP)
            return false;
        
        return true;
    }
}
