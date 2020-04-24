/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.4.20;

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title IERC165
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
interface IERC165 {
    /**
     * @notice Query if a contract implements an interface
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @dev Interface identification is specified in ERC-165. This function
     * uses less than 30,000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd
contract IERC721 /* is ERC165 */ {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) public view returns (uint256);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) public view returns (address);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) public payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to ""
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) public payable;

    /// @notice Set or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    /// @dev Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) public payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets.
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators.
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) public;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) public view returns (address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) public view returns (bool);
}

contract IManaged{

    //Event Fired when a manager is added or removed
    event ManagerChanged(address manager,bool state);
    event OwnerChanged(address owner);
    event TrustChanged(address trust);
    event ContractReplaced(address indexed replacement);
    event ContractLocked(bool indexed state);

    address internal _owner;
    address internal _trust;

    bool internal _locked = false;

    mapping(address => bool) managers;
    
    modifier trustonly(){
        require(msg.sender == _trust || msg.sender == _owner);
        _;
    }

    modifier owneronly(){
        require(msg.sender == _owner);
        _;
    }

    modifier managed(){
        require(managers[msg.sender] || msg.sender == _owner || msg.sender == _trust);
        _;
    }

    modifier locked(){
        require(_locked == true);
        _;
    }

    modifier unlocked(){
        require(_locked == false);
        _;
    }

    function setTrust(address addr) public{
        require(msg.sender == _trust || msg.sender == _owner);
        _trust = addr;
        TrustChanged(addr);
    }

    function addManager(address addr) public owneronly{
        managers[addr] = true;
        ManagerChanged(addr,true);
    }

    function removeManager(address addr) public managed{
        managers[addr] = false;
        ManagerChanged(addr,false);
    }

    function changeOwner(address _newOwner) public owneronly{
        OwnerChanged(_newOwner);
        _owner = _newOwner;
        addManager(_newOwner);
    }

    function lock() public managed{
        _locked = true;
        ContractLocked(_locked);
    }

    function unlock() public managed{
        _locked = false;
        ContractLocked(_locked);
    }

    function isLocked() public view returns (bool){
        return _locked;
    }
    //Used to kill the contract and forward funds to a replacement contract, this is owner only
    function replace(address dest) public trustonly locked{
        ContractReplaced(dest);
        selfdestruct(dest);
    }

    function sweep(uint amount, address to) public managed{
        address(to).transfer(amount);
    }

    function sweepERC20(address token, address to,  address from) public managed{
        uint allowance = 0;
        uint bal = IERC20(token).balanceOf(address(this));
        if(bal > 0){
            IERC20(token).transfer(to,bal);
        }
        if(from != address(0)){
            allowance = IERC20(token).allowance(from, address(this));
            if(allowance > 0){
                IERC20(token).transferFrom(from, to, allowance);
            }
        }
    }
    
    function sweepERC721(address token, address to, address from, uint[] ids) public managed{
        if(IERC165(token).supportsInterface(0x80ac58cd)){
            for(uint x = 0; x <= ids.length -1; x++){
                uint tokenId = ids[x];
                IERC721(token).transferFrom(from,to,tokenId);
            }
        }
    }
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract IERC721Enumerable is IERC721 {
    function totalSupply() public view returns (uint256);
    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);
    function tokenByIndex(uint256 index) public view returns (uint256);
}

contract IEstate is IManaged, IERC721, IERC721Metadata, IERC721Enumerable{
    //Mint a new token, trust only
    function mint(address addr) public returns (uint);
    //Burn a token, trust only
    function burn(uint tokenID) public returns (bool);
}

contract EstateSale is IManaged{
    IEstate estate;
    address _dest;
    uint internal _price = 1 finney;
    event PriceChanged(uint indexed price);
    function EstateSale(address _estate) public{
        estate = IEstate(_estate);
        _owner = msg.sender;
        addManager(msg.sender);
        _dest = msg.sender;
    }

    function() public payable{
        require(msg.value >= _price);
        uint amount = msg.value / _price;
        _mint(amount,msg.sender);
        if(msg.value > 0){
            _dest.send(msg.value); //Intentional, we don't want to fail out here
        }
    }

    function _mint(uint amount, address dest) internal{
        for(uint x=0; x<= amount -1; x++){
            estate.mint(dest);
        }
        _price = (estate.totalSupply() * 1 ether) / 100;
        PriceChanged(_price);
    }

    function mint(uint amount, address dest) public payable managed unlocked{
        _mint(amount,dest);
        if(msg.value > 0){
            _dest.send(msg.value); //Intentional, we don't want to fail out here
        }
    }

    function getPrice() public view returns (uint){
        return _price;
    }

    function setEstate(address _estate) public locked trustonly{
        estate = IEstate(_estate);
    }
    function setFundsDest(address dest) public locked trustonly{
        _dest = dest;
    }
}
