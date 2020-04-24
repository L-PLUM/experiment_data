/**
 *Submitted for verification at Etherscan.io on 2019-08-06
*/

pragma solidity 0.5.10; /*


___________________________________________________________________
  _      _                                        ______           
  |  |  /          /                                /              
--|-/|-/-----__---/----__----__---_--_----__-------/-------__------
  |/ |/    /___) /   /   ' /   ) / /  ) /___)     /      /   )     
__/__|____(___ _/___(___ _(___/_/_/__/_(___ _____/______(___/__o_o_



██████╗ ██╗      ██████╗  ██████╗██╗  ██╗    ██╗  ██╗   ██╗███╗   ██╗ ██████╗███████╗
██╔══██╗██║     ██╔═══██╗██╔════╝██║ ██╔╝    ██║  ╚██╗ ██╔╝████╗  ██║██╔════╝██╔════╝
██████╔╝██║     ██║   ██║██║     █████╔╝     ██║   ╚████╔╝ ██╔██╗ ██║██║     ███████╗
██╔══██╗██║     ██║   ██║██║     ██╔═██╗     ██║    ╚██╔╝  ██║╚██╗██║██║     ╚════██║
██████╔╝███████╗╚██████╔╝╚██████╗██║  ██╗    ███████╗██║   ██║ ╚████║╚██████╗███████║
╚═════╝ ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝    ╚══════╝╚═╝   ╚═╝  ╚═══╝ ╚═════╝╚══════╝
                                                                                     
                                                                                     

=== 'BlockLyncs' NFT Management contract with following features ===
    => ERC721 Compliance
    => ERC165 Compliance
    => SafeMath implementation 
    => Generation of new digital assets
    => Destroyal of digital assets
    => Buying/selling of digital assets


============= Independant Audit of the code ============
    => Multiple Freelancers Auditors
    => Community Audit by Bug Bounty program


-------------------------------------------------------------------
 Copyright (c) 2019 onwards  BlockLyncs Inc. ( http://blocklyncs.com )
 Contract designed with ❤ by EtherAuthority ( https://EtherAuthority.io )
-------------------------------------------------------------------
*/ 

/* Safemath library */
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

/* Token Counters Library */
library Counters {
    using SafeMath for uint256;

    struct Counter {
        // This variable should never be directly accessed by users of the library: interactions must be restricted to
        // the library's function. As of Solidity v0.5.2, this cannot be enforced, though there is a proposal to add
        // this feature: see https://github.com/ethereum/solidity/issues/4637
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter) internal {
        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {
        counter._value = counter._value.sub(1);
    }
}

/* Address library */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * This test is non-exhaustive, and there may be false-negatives: during the
     * execution of a contract's constructor, its address will be reported as
     * not containing a contract.
     *
     * > It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

// Owner Handler
contract owned    // Contract Owner and OwherShip change
{
    address payable public owner;
    address payable internal newOwner;

    address public subAdmin;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
        subAdmin = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner, 'caller must be owner');
        _;
    }

    modifier onlySubAdmin {
        require(msg.sender == subAdmin, 'caller must be subAdmin');
        _;
    }

    function changeSubAdmin(address newSubAdminAddress) public onlyOwner returns(string memory) {
        subAdmin = newSubAdminAddress;
        return "Sub admin changed successfully";
    }

    function transferOwnership(address payable _newOwner) public onlyOwner returns(string memory) {
        newOwner = _newOwner;
        return "ownership transferred successfully";
    }

    //this flow is to prevent transferring ownership to wrong wallet by mistake
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}

interface IERC721Receiver {
    /**
     * @notice Handle the receipt of an NFT
     * @dev The ERC721 smart contract calls this function on the recipient
     * after a `safeTransfer`. This function MUST return the function selector,
     * otherwise the caller will revert the transaction. The selector to be
     * returned can be obtained as `this.onERC721Received.selector`. This
     * function MAY throw to revert and reject the transfer.
     * Note: the ERC721 contract address is always the message sender.
     * @param operator The address which called `safeTransferFrom` function
     * @param from The address which previously owned the token
     * @param tokenId The NFT identifier which is being transferred
     * @param data Additional data with no specified format
     * @return bytes4 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
     */
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
    external returns (bytes4);
}




/**
 * @dev Implementation of the `IERC165` interface.
 *
 * Contracts may inherit from this and call `_registerInterface` to declare
 * their support of an interface.
 */
contract ERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) public supportsInterface;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }


    /**
     * @dev Registers the contract as an implementer of the interface defined by
     * `interfaceId`. Support of the actual ERC165 interface is automatic and
     * registering its interface id is not required.
     *
     * See `IERC165.supportsInterface`.
     *
     * Requirements:
     *
     * - `interfaceId` cannot be the ERC165 invalid interface (`0xffffffff`).
     */
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        supportsInterface[interfaceId] = true;
    }
}




contract BlockLyncs is owned,  ERC165 
{
    
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;
    bool safeGuard;
    
    // Token name
    string public _name = "BlockLyncs";
    // Token symbol
    string public _symbol = "BKL";
    // Token totalSupply
    uint256 public totalSupply;

    
    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
    
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    
    // Mapping from token ID to owner
    mapping (uint256 => address) internal _tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => address) internal _tokenApprovals;

    // Mapping from owner to number of owned token
     mapping (address => Counters.Counter) internal _ownedTokensCount;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) internal _operatorApprovals;

    // Optional mapping for token URIs
    mapping(uint256 => string) private _tokenURIs;

    /*
     *     bytes4(keccak256('name()')) == 0x06fdde03
     *     bytes4(keccak256('symbol()')) == 0x95d89b41
     *     bytes4(keccak256('tokenURI(uint256)')) == 0xc87b56dd
     *
     *     => 0x06fdde03 ^ 0x95d89b41 ^ 0xc87b56dd == 0x5b5e139f
     */
    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;
    
    
    // Events
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    
    //============================================================//
    //                STANDARD ERC721 FUNCTIONS                   //
    //============================================================//

    /**
     * @dev Constructor function
     */
    constructor () public {
        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    /**
     * @dev Gets the token name.
     * @return string representing the token name
     */
    function name() external view returns (string memory) {
        return _name;
    }

    /**
     * @dev Gets the token symbol.
     * @return string representing the token symbol
     */
    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns an URI for a given token ID.
     * Throws if the token ID does not exist. May return an empty string.
     * @param tokenId uint256 ID of the token to query
     */
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        require(exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    /**
     * @dev Internal function to set the token URI for a given token.
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to set its URI
     * @param uri string URI to assign
     */
    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        require(exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = uri;
    }
    
    
    function createDigitalAsset(address receipient, uint256 tokenID, string memory URI) public returns(bool){
        _mint(receipient, tokenID);
        _setTokenURI(tokenID, URI);
        return true;
    }

    
     /**
     * @dev Gets the balance of the specified address.
     * @param owner address to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(address owner) public view returns (uint256) {
        return _ownedTokensCount[owner].current();
    }
    
     /**
     * @dev Gets the owner of the specified token ID.
     * @param tokenId uint256 ID of the token to query the owner of
     * @return address currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        return _tokenOwner[tokenId];
    }
    
    
    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to transferFrom, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _transfer(address from, address to, uint256 tokenId) internal {
        
        require(!safeGuard);
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();
        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }
    
    
    function transfer(address to, uint256 tokenId) public returns (bool){
        
        //nothing to check here as all will be done in _transfer function.
        _transfer(msg.sender, to, tokenId);
        
    }
    
    
    /**
     * @dev Transfers the ownership of a given token ID to another address.
     * Usage of this method is discouraged, use `safeTransferFrom` whenever possible.
     * Requires the msg.sender to be the owner, approved, or operator.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function transferFrom(address from, address to, uint256 tokenId) public returns(bool) {

        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
        
        return true;
    }
    
    
    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }
    
    
    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement {IERC721Receiver-onERC721Received},
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransferFrom(from, to, tokenId, _data);
    }

    
    /**
     * @dev Safely transfers the ownership of a given token ID to another address
     * If the target address is a contract, it must implement `onERC721Received`,
     * which is called upon a safe transfer, and return the magic value
     * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
     * the transfer is reverted.
     * Requires the msg.sender to be the owner, approved, or operator
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes data to send along with a safe transfer check
     */
    function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) internal {
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
        _transfer(from, to, tokenId);
    }
    
       /**
     * @dev Approves another address to transfer the given token ID
     * The zero address indicates there is no approved address.
     * There can only be one approved address per token at a given time.
     * Can only be called by the token owner or an approved operator.
     * @param to address to be approved for the given token ID
     * @param tokenId uint256 ID of the token to be approved
     */
    function Approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(msg.sender == owner || IsApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }
    
     /**
     * @dev Gets the approved address for a token ID, or zero if no address set
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to query the approval of
     * @return address currently approved for the given token ID
     */
    function GetApproved(uint256 tokenId) public view returns (address) {
        return _tokenApprovals[tokenId];
    }
     
     /**
     * @dev Returns whether the specified token exists.
     * @param tokenId uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function exists(uint256 tokenId) public view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }
    
    /**
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf.
     * @param to operator address to set the approval
     * @param approved representing the status of the approval to be set
     */
    function SetApprovalForAll(address to, bool approved) public {
        require(to != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }
    
     /**
     * @dev Tells whether an operator is approved by a given owner.
     * @param owner owner address which you want to query the approval of
     * @param operator operator address which you want to query the approval of
     * @return bool whether the given operator is approved by the given owner
     */
    function IsApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    
    
    /**
     * @dev Returns whether the given spender can transfer a given token ID.
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     * is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || GetApproved(tokenId) == spender || IsApprovedForAll(owner, spender));
    }


     /**
     * @dev Internal function to invoke `onERC721Received` on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool) {
        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }
    
    
    function onERC721Received(address, address, uint256, bytes memory) public pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
    
     
    
     /**
     * @dev Internal function to mint a new token.
     * Reverts if the given token ID already exists.
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!exists(tokenId), "ERC721: token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();
        totalSupply++;

        emit Transfer(address(0), to, tokenId);
    }

      /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * Deprecated, use _burn(uint256) instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned
     */
     function _burn(address owner, uint256 tokenId) internal {
        require(ownerOf(tokenId) == owner, "ERC721: burn of token that is not own");

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);
        totalSupply = totalSupply.sub(1);
        
        // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        emit Transfer(owner, address(0), tokenId);
    }
    
    
     /**
     * @dev Private function to clear current approval of a given token ID.
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _clearApproval(uint256 tokenId) internal {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }


    //============================================================//
    //                BLOCKLYNCS CORE FUNCTIONS                   //
    //============================================================//
    
    struct ListingDetail 
    {
        address seller;
        address buyer;
        uint256 tokenId;
        uint256 price;
        uint8 listingType;      // 1 = Fixed price, 2 = Auction
        uint256 listingExpire;  // timestamp
        uint8 listingStatus;    // 1 = Active, 2 = Inactive
    }
    
    struct BiddingDetail
    {
        address payable bidder;
        uint256 lastAskingPrice;
        uint8 bidStatus;    // 1 = Active, 2 = Rejected, 3 = Accepted
    }
    uint256 public listingFeeFixedPrice;    // by default zero
    uint256 public listingFeeAuction;       // by default zero
    uint256 public saleFeeAuction;          // by default zero
    
    
    
    mapping(uint256 => ListingDetail) public sellerListItems;   // listing ID => ListingDetail
    mapping(uint256 => BiddingDetail) public BidsMapping;       // listing ID => BiddingDetail
    
    
    event ListItem(uint256 indexed listUniqueID, uint256 listingType, address indexed seller, uint256 indexed tokenId, uint256 price, uint256 listingFee);
    event SoldItemFixedPrice(uint256 indexed listingID, address indexed seller, address buyer, uint256 indexed tokenId, uint256 price);
    event Bids (uint256 indexed listingID, address indexed bidder, uint256 biddingPrice);
    event SoldItemAuction(uint256 indexed listID, address indexed seller, address buyer, uint256 indexed tokenId, uint256 price, uint256 tradingFee);    
    
    
    /**
     * ListType: 0 = Fixed price, 1 = Auction
     */
    function listAnItem(uint256 listID, uint8 listingType,  uint256 tokenId, uint256 priceWEI, uint256 expires) public payable returns (bool){
        
        //checking conditions
        require(tokenId != sellerListItems[listID].tokenId, 'This token ID is already listed');
        uint256 listingFee = calculatePercentage(priceWEI,listingFeeFixedPrice);
        require(msg.value >= listingFee, 'Need to pay the listing fee');
        
        
        //transfer token from token owner to contract
        transfer(address(this), tokenId);
        
        ListingDetail memory temp;
        
        temp.seller = msg.sender;
        temp.tokenId = tokenId;
        temp.price = priceWEI;
        temp.listingType = listingType;     // 1 = Fixed price, 2 = Auction
        temp.listingExpire = expires;
        temp.listingStatus = 1;
        
        //Put auction data to listing mapped array
        sellerListItems[listID] = temp;
        
        //emit Event
        emit ListItem(listID, listingType, msg.sender, tokenId, priceWEI, listingFee);
        
        return true;
    }
    
    
    function availableToList(uint256 tokenID, uint256 listID) public view returns(bool){
        
        if(msg.sender == ownerOf(tokenID) && tokenID != sellerListItems[listID].tokenId ){
            return true;
        }
        
    }
    
    
    function tokenPurchase(uint256 listID, address buyer) public onlySubAdmin returns (bool){
        ListingDetail memory listingData = sellerListItems[listID];
        require(listingData.listingType == 1, 'This listing is not Fixed Priced');
        require(listingData.listingStatus == 1, 'This listing is not active');
        require(listingData.listingExpire > now, 'Listing is expired');
        
        //transfer token from  contract to buyer
        _transfer(address(this), buyer, listingData.tokenId);
        
        //update sellerListItems[listID] mapping
        sellerListItems[listID].buyer = buyer;
        sellerListItems[listID].listingStatus = 2;
        
        emit SoldItemFixedPrice(listID, listingData.seller, buyer, listingData.tokenId, listingData.price);
        
    }
    
    
    function placeBid(uint256 listID) public payable returns (bool){
        ListingDetail memory listingData = sellerListItems[listID];
        BiddingDetail memory bidsData = BidsMapping[listID];
        uint256 etherAmount = msg.value;
        
        require(listingData.listingType == 2, 'This listing is not Auction');
        require(listingData.listingStatus == 1, 'This listing is not active');
        require((etherAmount > listingData.price && etherAmount > bidsData.lastAskingPrice), 'bidding price should be higher than previous price');
        require(listingData.listingExpire > now, 'Listing is expired');
        
        //refund bid if previous bids exists
        if(bidsData.bidStatus > 0){
            refundPreviousBid(bidsData.bidder, bidsData.lastAskingPrice);
        }
        
        //adding data in bid mapping
        BiddingDetail memory temp;
        
        temp.bidder = msg.sender;
        temp.lastAskingPrice = etherAmount;
        temp.bidStatus = 1;      // 1 = Active, 2 = Rejected, 3 = Accepted

        
        //Put auction data to listing mapped array
        BidsMapping[listID] = temp;
        
        //emit Event
        emit Bids (listID, msg.sender, etherAmount);
        
    }
    
    
    function refundPreviousBid(address payable bidder, uint256 amount) internal{
        bidder.transfer(amount);
    }
    
    
    function confirmBid(uint256 listID) public returns(bool){
        
        ListingDetail memory listingData = sellerListItems[listID];
        BiddingDetail memory bidsData = BidsMapping[listID];
        
        require(listingData.seller == msg.sender, 'caller must be item seller');
        require(listingData.listingStatus == 1, 'Listing is not active');
        require(listingData.listingType == 2, 'This listing is not Auction');
        require(bidsData.bidStatus == 1, 'No active bidding');
        
        //transfer token from  contract to buyer
        _transfer(address(this), bidsData.bidder, listingData.tokenId);
        
        //update sellerListItems[listID] mapping
        sellerListItems[listID].buyer = bidsData.bidder;
        sellerListItems[listID].listingStatus = 2;
        BidsMapping[listID].bidStatus = 3;
        
        uint256 tradingFee = calculatePercentage(bidsData.lastAskingPrice,saleFeeAuction);
        msg.sender.transfer(bidsData.lastAskingPrice - tradingFee);
        
        emit SoldItemAuction(listID, msg.sender, bidsData.bidder, listingData.tokenId, bidsData.lastAskingPrice, tradingFee);
        
    }
    
    
    function updateFees(uint256 _listingFreeFixedPriceWEI, uint256 _listingFeeAuctionWEI) public onlyOwner returns (string memory){
        
        listingFeeFixedPrice = _listingFreeFixedPriceWEI;
        listingFeeAuction = _listingFeeAuctionWEI;
        
        return "Listing fees updated successfully";
    }

    function manualWithdrawEther() public onlyOwner returns(string memory){
        owner.transfer(address(this).balance);
        return "Ether withdrawn successfully";
    }
    
    //Calculate percent and return result
    function calculatePercentage(uint256 PercentOf, uint256 percentTo ) internal pure returns (uint256) 
    {
        uint256 factor = 10000;
        require(percentTo <= factor);
        uint256 c = PercentOf.mul(percentTo).div(factor);
        return c;
    } 
    
    function changeSafeguardStatus() onlyOwner public returns (string memory)
    {
        if (safeGuard == false)
        {
            safeGuard = true;
        }
        else
        {
            safeGuard = false;    
        }
        return "success";
    }





}
