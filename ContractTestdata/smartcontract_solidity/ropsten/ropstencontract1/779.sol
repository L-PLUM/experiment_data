/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity >=0.5.0 <0.6.0;

interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

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

contract PauserRole {
    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(msg.sender);
    }

    modifier onlyPauser() {
        require(isPauser(msg.sender));
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

contract Pausable is PauserRole {
    event Paused(address account);
    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    /**
     * @return true if the contract is paused, false otherwise.
     */
    function paused() public view returns (bool) {
        return _paused;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenNotPaused() {
        require(!_paused);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenPaused() {
        require(_paused);
        _;
    }

    /**
     * @dev called by the owner to pause, triggers stopped state
     */
    function pause() public onlyPauser whenNotPaused {
        _paused = true;
        emit Paused(msg.sender);
    }

    /**
     * @dev called by the owner to unpause, returns to normal state
     */
    function unpause() public onlyPauser whenPaused {
        _paused = false;
        emit Unpaused(msg.sender);
    }
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

library BytesUtils {
  function isZero(bytes memory b) internal pure returns (bool) {
    if (b.length == 0) {
      return true;
    }
    bytes memory zero = new bytes(b.length);
    return keccak256(b) == keccak256(zero);
  }
}

library DnsUtils {
  function isDomainName(bytes memory s) internal pure returns (bool) {
    byte last = '.';
    bool ok = false;
    uint partlen = 0;

    for (uint i = 0; i < s.length; i++) {
      byte c = s[i];
      if (c >= 'a' && c <= 'z' || c == '_') {
        ok = true;
        partlen++;
      } else if (c >= '0' && c <= '9') {
        partlen++;
      } else if (c == '-') {
        // byte before dash cannot be dot.
        if (last == '.') {
          return false;
        }
        partlen++;
      } else if (c == '.') {
        // byte before dot cannot be dot, dash.
        if (last == '.' || last == '-') {
          return false;
        }
        if (partlen > 63 || partlen == 0) {
          return false;
        }
        partlen = 0;
      }
      last = c;
    }
    if (last == '-' || partlen > 63) {
      return false;
    }
    return ok;
  }
}

contract Marketplace is Ownable, Pausable {
  using BytesUtils for bytes;
  using DnsUtils for bytes;

  /**
    Structures
   */

  struct Service {
    address owner;
    bytes sid;

    mapping(bytes32 => Version) versions; // version's hash => Version
    bytes32[] versionsList;

    Offer[] offers;

    mapping(address => Purchase) purchases; // purchaser's address => Purchase
    address[] purchasesList;
  }

  struct Purchase {
    uint expire;
  }

  struct Version {
    bytes manifest;
    bytes manifestProtocol;
  }

  struct Offer {
    uint price;
    uint duration;
    bool active;
  }

  /**
    Constant
   */

  uint constant INFINITY = ~uint256(0);
  uint constant MAX_SID_LENGTH = 63;


  /**
    State variables
   */

  IERC20 public token;

  mapping(bytes32 => Service) public services; // service's hashed sid => Service
  bytes32[] public servicesList;

  mapping(bytes32 => bytes32) public hashToService; // version's hash => service's hashed sid

  /**
    Constructor
   */

  constructor(IERC20 _token) public {
    token = _token;
  }

  /**
    Events
   */

  event ServiceCreated(
    bytes sid,
    bytes32 indexed sidHash,
    address indexed owner
  );

  event ServiceOwnershipTransferred(
    bytes32 indexed sidHash,
    address indexed previousOwner,
    address indexed newOwner
  );

  event ServiceVersionCreated(
    bytes32 indexed sidHash,
    bytes32 indexed hash,
    bytes manifest,
    bytes manifestProtocol
  );

  event ServiceOfferCreated(
    bytes32 indexed sidHash,
    uint indexed offerIndex,
    uint price,
    uint duration
  );

  event ServiceOfferDisabled(
    bytes32 indexed sidHash,
    uint indexed offerIndex
  );

  event ServicePurchased(
    bytes32 indexed sidHash,
    uint indexed offerIndex,
    address indexed purchaser,
    uint price,
    uint duration,
    uint expire
  );

  /**
    Modifiers
   */

  modifier whenAddressNotZero(address a) {
    require(a != address(0), "Address cannot be set to zero");
    _;
  }

  modifier whenManifestNotEmpty(bytes memory manifest) {
    require(!manifest.isZero(), "Manifest cannot be empty");
    _;
  }

  modifier whenManifestProtocolNotEmpty(bytes memory manifestProtocol) {
    require(!manifestProtocol.isZero(), "Manifest protocol cannot be empty");
    _;
  }

  modifier whenDurationNotZero(uint duration) {
    require(duration > 0, "Duration cannot be zero");
    _;
  }

  modifier whenServiceExist(bytes32 sidHash) {
    require(services[sidHash].owner != address(0), "Service with this sid does not exist");
    _;
  }

  modifier onlyServiceOwner(bytes32 sidHash) {
    require(services[sidHash].owner == msg.sender, "Service owner is not the sender");
    _;
  }

  modifier notServiceOwner(bytes32 sidHash) {
    require(services[sidHash].owner != msg.sender, "Service owner cannot be the sender");
    _;
  }

  modifier whenServiceHashNotExist(bytes32 hash) {
    require(services[hashToService[hash]].owner == address(0), "Hash already exists");
    _;
  }

  modifier whenServiceVersionNotEmpty(bytes32 sidHash) {
    require(services[sidHash].versionsList.length > 0, "Cannot create an offer on a service without version");
    _;
  }

  modifier whenServiceOfferExist(bytes32 sidHash, uint offerIndex) {
    require(offerIndex < services[sidHash].offers.length, "Service offer does not exist");
    _;
  }

  modifier whenServiceOfferActive(bytes32 sidHash, uint offerIndex) {
    require(services[sidHash].offers[offerIndex].active, "Service offer is not active");
    _;
  }

  /**
    Externals
   */

  function createService(bytes calldata sid)
    external
    whenNotPaused
  {
    require(sid.length > 0, "Sid cannot be empty");
    require(sid.length <= MAX_SID_LENGTH, "Sid cannot exceed 63 chars");
    require(sid.isDomainName(), "Sid format invalid");
    bytes32 sidHash = keccak256(sid);
    require(services[sidHash].owner == address(0), "Service with same sid already exists");
    services[sidHash].owner = msg.sender;
    services[sidHash].sid = sid;
    servicesList.push(sidHash);
    emit ServiceCreated(sid, sidHash, msg.sender);
  }

  function transferServiceOwnership(bytes32 sidHash, address newOwner)
    external
    whenNotPaused
    onlyServiceOwner(sidHash)
    whenAddressNotZero(newOwner)
  {
    emit ServiceOwnershipTransferred(sidHash, services[sidHash].owner, newOwner);
    services[sidHash].owner = newOwner;
  }

  function createServiceVersion(
    bytes32 sidHash,
    bytes32 hash,
    bytes calldata manifest,
    bytes calldata manifestProtocol
  )
    external
    whenNotPaused
    onlyServiceOwner(sidHash)
    whenServiceHashNotExist(hash)
    whenManifestNotEmpty(manifest)
    whenManifestProtocolNotEmpty(manifestProtocol)
  {
    services[sidHash].versions[hash].manifest = manifest;
    services[sidHash].versions[hash].manifestProtocol = manifestProtocol;
    services[sidHash].versionsList.push(hash);
    hashToService[hash] = sidHash;
    emit ServiceVersionCreated(sidHash, hash, manifest, manifestProtocol);
  }

  function createServiceOffer(bytes32 sidHash, uint price, uint duration)
    external
    whenNotPaused
    onlyServiceOwner(sidHash)
    whenServiceVersionNotEmpty(sidHash)
    whenDurationNotZero(duration)
    returns (uint offerIndex)
  {
    Offer[] storage offers = services[sidHash].offers;
    offers.push(Offer({
      price: price,
      duration: duration,
      active: true
    }));
    emit ServiceOfferCreated(sidHash, offers.length - 1, price, duration);
    return offers.length - 1;
  }

  function disableServiceOffer(bytes32 sidHash, uint offerIndex)
    external
    whenNotPaused
    onlyServiceOwner(sidHash)
    whenServiceOfferExist(sidHash, offerIndex)
  {
    services[sidHash].offers[offerIndex].active = false;
    emit ServiceOfferDisabled(sidHash, offerIndex);
  }

  function purchase(bytes32 sidHash, uint offerIndex)
    external
    whenNotPaused
    whenServiceExist(sidHash)
    notServiceOwner(sidHash)
    whenServiceOfferExist(sidHash, offerIndex)
    whenServiceOfferActive(sidHash, offerIndex)
  {
    Service storage service = services[sidHash];
    Offer storage offer = service.offers[offerIndex];

    // if offer has been purchased for infinity then return
    require(service.purchases[msg.sender].expire != INFINITY, "Service has been already purchased");

    // Check if offer is active, sender has enough balance and approved the transform
    require(token.balanceOf(msg.sender) >= offer.price, "Sender does not have enough balance to pay this service");
    require(token.allowance(msg.sender, address(this)) >= offer.price, "Sender did not approve this contract to spend on his behalf. Execute approve function on the token contract");

    // Transfer the token from sender to service owner
    token.transferFrom(msg.sender, service.owner, offer.price);

    // max(service.purchases[msg.sender].expire,  now)
    uint expire = service.purchases[msg.sender].expire <= now ?
                    now : service.purchases[msg.sender].expire;

    // set expire + duration or INFINITY on overflow
    expire = expire + offer.duration < expire ?
               INFINITY : expire + offer.duration;

    // if given address purchase service
    // 1st time add it to purchases list
    if (service.purchases[msg.sender].expire == 0) {
      service.purchasesList.push(msg.sender);
    }

    // set new expire time
    service.purchases[msg.sender].expire = expire;
    emit ServicePurchased(sidHash, offerIndex, msg.sender, offer.price, offer.duration, expire);
  }

  /**
    External views
   */

  function servicesListLength()
    external view
    returns (uint length)
  {
    return servicesList.length;
  }

  function servicesVersionsListLength(bytes32 sidHash)
    external view
    whenServiceExist(sidHash)
    returns (uint length)
  {
    return services[sidHash].versionsList.length;
  }

  function servicesVersionsList(bytes32 sidHash, uint versionIndex)
    external view
    whenServiceExist(sidHash)
    returns (bytes32 hash)
  {
    return services[sidHash].versionsList[versionIndex];
  }

  function servicesVersion(bytes32 sidHash, bytes32 hash)
    external view
    whenServiceExist(sidHash)
    returns (bytes memory manifest, bytes memory manifestProtocol)
  {
    Version storage version = services[sidHash].versions[hash];
    return (version.manifest, version.manifestProtocol);
  }

  function servicesOffersLength(bytes32 sidHash)
    external view
    whenServiceExist(sidHash)
    returns (uint length)
  {
    return services[sidHash].offers.length;
  }

  function servicesOffer(bytes32 sidHash, uint offerIndex)
    external view
    whenServiceExist(sidHash)
    returns (uint price, uint duration, bool active)
  {
    Offer storage offer = services[sidHash].offers[offerIndex];
    return (offer.price, offer.duration, offer.active);
  }

  function servicesPurchasesListLength(bytes32 sidHash)
    external view
    whenServiceExist(sidHash)
    returns (uint length)
  {
    return services[sidHash].purchasesList.length;
  }

  function servicesPurchasesList(bytes32 sidHash, uint purchaseIndex)
    external view
    whenServiceExist(sidHash)
    returns (address purchaser)
  {
    return services[sidHash].purchasesList[purchaseIndex];
  }

  function servicesPurchase(bytes32 sidHash, address purchaser)
    external view
    whenServiceExist(sidHash)
    returns (uint expire)
  {
    return services[sidHash].purchases[purchaser].expire;
  }

  function isAuthorized(bytes32 sidHash, address purchaser)
    external view
    returns (bool authorized)
  {
    return services[sidHash].owner == purchaser ||
      services[sidHash].purchases[purchaser].expire >= now;
  }
}
