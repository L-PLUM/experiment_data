/**
 *Submitted for verification at Etherscan.io on 2019-02-05
*/

pragma solidity 0.4.24;

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/ERC165.sol

/**
 * @title ERC165
 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
interface ERC165 {

  /**
   * @notice Query if a contract implements an interface
   * @param _interfaceId The interface identifier, as specified in ERC-165
   * @dev Interface identification is specified in ERC-165. This function
   * uses less than 30,000 gas.
   */
  function supportsInterface(bytes4 _interfaceId) external view returns (bool);
}

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/ERC721Basic.sol

/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Basic is ERC165 {
    event Transfer(
      address indexed _from,
      address indexed _to,
      uint256 indexed _tokenId
    );
    event Approval(
      address indexed _owner,
      address indexed _approved,
      uint256 indexed _tokenId
    );
    event ApprovalForAll(
      address indexed _owner,
      address indexed _operator,
      bool _approved
    );

    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint256 _tokenId) public view returns (address _owner);
    function exists(uint256 _tokenId) public view returns (bool _exists);

    function approve(address _to, uint256 _tokenId) public;
    function getApproved(uint256 _tokenId) public view returns (address _operator);

    function setApprovalForAll(address _operator, bool _approved) public;
    function isApprovedForAll(address _owner, address _operator) public view returns (bool);

    function transferFrom(address _from, address _to, uint256 _tokenId) public;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;

    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public;
}

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/ERC721Enumerable.sol

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Enumerable is ERC721Basic {
    function totalSupply() public view returns (uint256);
    // function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId);
    function tokenByIndex(uint256 _index) public view returns (uint256);
}

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/ERC721Metadata.sol

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Metadata is ERC721Basic {
    function name() external view returns (string _name);
    function symbol() external view returns (string _symbol);
    function tokenURI(uint256 _tokenId) public view returns (string);
}

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/ERC721.sol

/**
 * @title ERC-721 Non-Fungible Token Standard, full implementation interface
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/ERC721Receiver.sol

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
contract ERC721Receiver {
  /**
   * @dev Magic value to be returned upon successful reception of an NFT
   *  Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`,
   *  which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
   */
    bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;

  /**
   * @notice Handle the receipt of an NFT
   * @dev The ERC721 smart contract calls this function on the recipient
   * after a `safetransfer`. This function MAY throw to revert and reject the
   * transfer. Return of other than the magic value MUST result in the 
   * transaction being reverted.
   * Note: the contract address is always the message sender.
   * @param _operator The address which called `safeTransferFrom` function
   * @param _from The address which previously owned the token
   * @param _tokenId The NFT identifier which is being transfered
   * @param _data Additional data with no specified format
   * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
   */
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) public returns(bytes4);
}

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/SafeMath.sol

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

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/AddressUtils.sol

/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * Returns whether the target address is a contract
   * @dev This function will return false if invoked during the constructor of a contract,
   * as the code is not actually created until after the constructor finishes.
   * @param addr address to check
   * @return whether the target address is a contract
   */
    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solium-disable-next-line security/no-inline-assembly
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

}

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/SupportsInterfaceWithLookup.sol

/**
 * @title SupportsInterfaceWithLookup
 * @author Matt Condon (@shrugs)
 * @dev Implements ERC165 using a lookup table.
 */
contract SupportsInterfaceWithLookup is ERC165 {
  bytes4 public constant InterfaceId_ERC165 = 0x01ffc9a7;
  /**
   * 0x01ffc9a7 ===
   *   bytes4(keccak256('supportsInterface(bytes4)'))
   */

  /**
   * @dev a mapping of interface id to whether or not it's supported
   */
  mapping(bytes4 => bool) internal supportedInterfaces;

  /**
   * @dev A contract implementing SupportsInterfaceWithLookup
   * implement ERC165 itself
   */
//   constructor()
//     public
//   {
//     _registerInterface(InterfaceId_ERC165);
//   }

  /**
   * @dev implement supportsInterface(bytes4) using a lookup table
   */
  function supportsInterface(bytes4 _interfaceId)
    external
    view
    returns (bool)
  {
    return supportedInterfaces[_interfaceId];
  }

  /**
   * @dev private method for registering an interface
   */
  function _registerInterface(bytes4 _interfaceId)
    internal
  {
    require(_interfaceId != 0xffffffff);
    supportedInterfaces[_interfaceId] = true;
  }
}

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/AccessControl.sol

contract AccessControl {

    event ContractUpgrade(address newContract);

    // The addresses of the accounts (or contracts) that can execute actions within each roles.
    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;
    address public ctoAddress;

    // @dev Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public paused = false;

    /// @dev Access modifier for CEO-only functionality
    modifier onlyCEO() {
        require(msg.sender == ceoAddress || 
                msg.sender == ctoAddress);
        _;
    }

    /// @dev Access modifier for CFO-only functionality
    modifier onlyCFO() {
        require(msg.sender == cfoAddress || 
                msg.sender == ctoAddress);
        _;
    }
    
    /// @dev Access modifier for CFO-only functionality
    modifier onlyCOO() {
        require(msg.sender == cfoAddress || 
                msg.sender == ctoAddress);
        _;
    }    

    /// @dev Access modifier for CTO-only functionality
    modifier onlyCTO() {
        require(msg.sender == ctoAddress);
        _;
    }

    modifier onlyCLevel() {
        require(
            msg.sender == cooAddress ||
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress ||
            msg.sender == ctoAddress
        );
        _;
    }

    /// @dev Assigns a new address to act as the CEO. Only available to the current CTO.
    /// @param _newCEO The address of the new CEO
    function setCEO(address _newCEO) external onlyCTO {
        require(_newCEO != address(0));
        ceoAddress = _newCEO;
    }

    /// @dev Assigns a new address to act as the CFO. Only available to the current CTO.
    /// @param _newCFO The address of the new CFO
    function setCFO(address _newCFO) external onlyCTO {
        require(_newCFO != address(0));
        cfoAddress = _newCFO;
    }

    /// @dev Assigns a new address to act as the COO. Only available to the current CTO.
    /// @param _newCOO The address of the new COO
    function setCOO(address _newCOO) external onlyCTO {
        require(_newCOO != address(0));
        cooAddress = _newCOO;
    }

    /*** Pausable functionality adapted from OpenZeppelin ***/

    /// @dev Modifier to allow actions only when the contract IS NOT paused
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /// @dev Modifier to allow actions only when the contract IS paused
    modifier whenPaused {
        require(paused);
        _;
    }

    /// @dev Called by any "C-level" role to pause the contract. Used only when
    ///  a bug or exploit is detected and we need to limit damage.
    function pause() external onlyCLevel whenNotPaused {
        paused = true;
    }

    /// @dev Unpauses the smart contract. Can only be called by the CEO, since
    ///  one reason we may pause the contract is when CFO or COO accounts are
    ///  compromised.
    /// @notice This is public rather than external so it can be called by
    ///  derived contracts.
    function unpause() public onlyCEO whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }
}

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/ClockAuctionBase.sol

/// @title Auction Core
/// @dev Contains models, variables, and internal methods for the auction.
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract ClockAuctionBase is ERC721Receiver {

    // Represents an auction on an NFT
    struct Auction {
        // Current owner of NFT
        address seller;
        // Price (in wei) at beginning of auction
        uint128 startingPrice;
        // Price (in wei) at end of auction
        uint128 endingPrice;
        // Duration (in seconds) of auction
        uint64 duration;
        // Time when auction started
        // NOTE: 0 if this auction has been concluded
        uint64 startedAt;
    }

    // Reference to contract tracking NFT ownership
    ERC721 public nonFungibleContract;

    // Cut owner takes on each auction, measured in basis points (1/100 of a percent).
    // Values 0-10,000 map to 0%-100%
    uint256 public ownerCut;

    // Map from token ID to their corresponding auction.
    mapping (uint256 => Auction) tokenIdToAuction;

    event AuctionCreated(uint256 tokenId, uint256 startingPrice, uint256 endingPrice, uint256 duration, uint256 timestamp);
    event AuctionSuccessful(uint256 tokenId, uint256 totalPrice, address winner);
    event AuctionCancelled(uint256 tokenId);

    /// @dev Returns true if the claimant owns the token.
    /// @param _claimant - Address claiming to own the token.
    /// @param _tokenId - ID of token whose ownership to verify.
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (nonFungibleContract.ownerOf(_tokenId) == _claimant);
    }

    /// @dev Escrows the NFT, assigning ownership to this contract.
    /// Throws if the escrow fails.
    /// @param _owner - Current owner address of token to escrow.
    /// @param _tokenId - ID of token whose approval to verify.
    function _escrow(address _owner, uint256 _tokenId) internal {
        // it will throw if transfer fails
        if(_owner != address(nonFungibleContract)){
            nonFungibleContract.safeTransferFrom(_owner, address(this), _tokenId); // SAFE TRANSFER
        }

    }

    function onERC721Received(address /* _operator */, address /* _from */, uint256 /* _tokenId*/, bytes /* _data */) public returns(bytes4) {
        // require(nonFungibleContract.isApprovedForAll(_from, _operator), "Operator lacks approval from token owner");
        // require(nonFungibleContract.ownerOf(_tokenId) == address(_operator), "Operator is not in possession of token");
        return ERC721_RECEIVED;
    }

    /// @dev Transfers an NFT owned by this contract to another address.
    /// Returns true if the transfer succeeds.
    /// @param _receiver - Address to transfer NFT to.
    /// @param _tokenId - ID of token to transfer.
    function _transfer(address _receiver, uint256 _tokenId, address _seller) internal {
        // it will throw if transfer fails
        // nonFungibleContract.transfer(_receiver, _tokenId);
        if(_seller != address(nonFungibleContract)) {
            nonFungibleContract.safeTransferFrom(address(this), _receiver, _tokenId); // SAFE TRANSFER
        } else {
            nonFungibleContract.safeTransferFrom(address(nonFungibleContract), _receiver, _tokenId);
        }
    }

    /// @dev Adds an auction to the list of open auctions. Also fires the
    ///  AuctionCreated event.
    /// @param _tokenId The ID of the token to be put on auction.
    /// @param _auction Auction to add.
    function _addAuction(uint256 _tokenId, Auction _auction) internal {
        // Require that all auctions have a duration of
        // at least one minute. (Keeps our math from getting hairy!)
        require(_auction.duration >= 1 minutes);

        tokenIdToAuction[_tokenId] = _auction;

        emit AuctionCreated(
            uint256(_tokenId),
            uint256(_auction.startingPrice),
            uint256(_auction.endingPrice),
            uint256(_auction.duration),
            block.timestamp
        );
    }

    /// @dev Cancels an auction unconditionally.
    function _cancelAuction(uint256 _tokenId, address _seller) internal {
        _removeAuction(_tokenId);
        _transfer(_seller, _tokenId, _seller);
        emit AuctionCancelled(_tokenId);
    }

    /// @dev Computes the price and transfers winnings.
    /// Does NOT transfer ownership of token.
    function _bid(uint256 _tokenId, uint256 _bidAmount)
        internal
        returns (uint256)
    {
        // Get a reference to the auction struct
        Auction storage auction = tokenIdToAuction[_tokenId];

        // Explicitly check that this auction is currently live.
        // (Because of how Ethereum mappings work, we can't just count
        // on the lookup above failing. An invalid _tokenId will just
        // return an auction object that is all zeros.)
        require(_isOnAuction(auction));

        // Check that the bid is greater than or equal to the current price
        uint256 price = _currentPrice(auction);
        require(_bidAmount >= price);

        // Grab a reference to the seller before the auction struct
        // gets deleted.
        address seller = auction.seller;

        // The bid is good! Remove the auction before sending the fees
        // to the sender so we can't have a reentrancy attack.
        _removeAuction(_tokenId);

        // Transfer proceeds to seller (if there are any!)
        if (price > 0) {
            // Calculate the auctioneer's cut.
            // (NOTE: _computeCut() is guaranteed to return a
            // value <= price, so this subtraction can't go negative.)
            uint256 auctioneerCut = _computeCut(price);
            uint256 sellerProceeds = price - auctioneerCut;

            // NOTE: Doing a transfer() in the middle of a complex
            // method like this is generally discouraged because of
            // reentrancy attacks and DoS attacks if the seller is
            // a contract with an invalid fallback function. We explicitly
            // guard against reentrancy attacks by removing the auction
            // before calling transfer(), and the only thing the seller
            // can DoS is the sale of their own asset! (And if it's an
            // accident, they can call cancelAuction(). )
            seller.transfer(sellerProceeds);
        }

        // Calculate any excess funds included with the bid. If the excess
        // is anything worth worrying about, transfer it back to bidder.
        // NOTE: We checked above that the bid amount is greater than or
        // equal to the price so this cannot underflow.
        uint256 bidExcess = _bidAmount - price;

        // Return the funds. Similar to the previous transfer, this is
        // not susceptible to a re-entry attack because the auction is
        // removed before any transfers occur.
        msg.sender.transfer(bidExcess);

        // Tell the world!
        emit AuctionSuccessful(_tokenId, price, msg.sender);

        return price;
    }

    /// @dev Removes an auction from the list of open auctions.
    /// @param _tokenId - ID of NFT on auction.
    function _removeAuction(uint256 _tokenId) internal {
        delete tokenIdToAuction[_tokenId];
    }

    /// @dev Returns true if the NFT is on auction.
    /// @param _auction - Auction to check.
    function _isOnAuction(Auction storage _auction) internal view returns (bool) {
        return (_auction.startedAt > 0);
    }

    /// @dev Returns current price of an NFT on auction. Broken into two
    ///  functions (this one, that computes the duration from the auction
    ///  structure, and the other that does the price computation) so we
    ///  can easily test that the price computation works correctly.
    function _currentPrice(Auction storage _auction)
        internal
        view
        returns (uint256)
    {
        uint256 secondsPassed = 0;

        // A bit of insurance against negative values (or wraparound).
        // Probably not necessary (since Ethereum guarnatees that the
        // now variable doesn't ever go backwards).
        if (now > _auction.startedAt) {
            secondsPassed = now - _auction.startedAt;
        }

        return _computeCurrentPrice(
            _auction.startingPrice,
            _auction.endingPrice,
            _auction.duration,
            secondsPassed
        );
    }

    /// @dev Computes the current price of an auction. Factored out
    ///  from _currentPrice so we can run extensive unit tests.
    ///  When testing, make this function public and turn on
    ///  `Current price computation` test suite.
    function _computeCurrentPrice(
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        uint256 _secondsPassed
    )
        internal
        pure
        returns (uint256)
    {
        // NOTE: We don't use SafeMath (or similar) in this function because
        //  all of our public functions carefully cap the maximum values for
        //  time (at 64-bits) and currency (at 128-bits). _duration is
        //  also known to be non-zero (see the require() statement in
        //  _addAuction())
        if (_secondsPassed >= _duration) {
            // We've reached the end of the dynamic pricing portion
            // of the auction, just return the end price.
            return _endingPrice;
        } else {
            // Starting price can be higher than ending price (and often is!), so
            // this delta can be negative.
            int256 totalPriceChange = int256(_endingPrice) - int256(_startingPrice);

            // This multiplication can't overflow, _secondsPassed will easily fit within
            // 64-bits, and totalPriceChange will easily fit within 128-bits, their product
            // will always fit within 256-bits.
            int256 currentPriceChange = totalPriceChange * int256(_secondsPassed) / int256(_duration);

            // currentPriceChange can be negative, but if so, will have a magnitude
            // less that _startingPrice. Thus, this result will always end up positive.
            int256 currentPrice = int256(_startingPrice) + currentPriceChange;

            return uint256(currentPrice);
        }
    }

    /// @dev Computes owner's cut of a sale.
    /// @param _price - Sale price of NFT.
    function _computeCut(uint256 _price) internal view returns (uint256) {
        // NOTE: We don't use SafeMath (or similar) in this function because
        //  all of our entry functions carefully cap the maximum values for
        //  currency (at 128-bits), and ownerCut <= 10000 (see the require()
        //  statement in the ClockAuction constructor). The result of this
        //  function is always guaranteed to be <= _price.
        return _price * ownerCut / 10000;
    }

}

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/Pausable.sol

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

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/ClockAuction.sol

/// @title Clock auction for non-fungible tokens.
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract ClockAuction is Pausable, ClockAuctionBase {

    /// @dev The ERC-165 interface signature for ERC-721.
    ///  Ref: https://github.com/ethereum/EIPs/issues/165
    ///  Ref: https://github.com/ethereum/EIPs/issues/721
    // bytes4 constant InterfaceSignature_ERC721 = bytes4(0x9a20483d);
    bytes4 private constant InterfaceId_ERC721 = 0x80ac58cd;

    /// @dev Constructor creates a reference to the NFT ownership contract
    ///  and verifies the owner cut is in the valid range.
    /// @param _nftAddress - address of a deployed contract implementing
    ///  the Nonfungible Interface.
    /// @param _cut - percent cut the owner takes on each auction, must be
    ///  between 0-500 i.e a maximum of 5% comission
    constructor(address _nftAddress, uint256 _cut) public {
        require(_cut <= 500);
        ownerCut = _cut;

        ERC721 candidateContract = ERC721(_nftAddress);
        require(candidateContract.supportsInterface(InterfaceId_ERC721));
        nonFungibleContract = candidateContract;
    }

    function setComission(uint256 _commission) external onlyOwner whenPaused {
        require(_commission <= 500, "Commission may not exceed 5%");
        ownerCut = _commission;
    }

    /// @dev Sets internal reference of NFT ownership to new contract address
    /// @param _nftAddress - address of the new NFT contract
    function setNFTAddress(address _nftAddress) whenPaused onlyOwner public {

        ERC721 candidateContract = ERC721(_nftAddress);
        require(candidateContract.supportsInterface(InterfaceId_ERC721));
        nonFungibleContract = candidateContract;
    }

    /// @dev Remove all Ether from the contract, which is the owner's cuts
    ///  as well as any Ether sent directly to the contract address.
    ///  Always transfers to the NFT contract, but can be called either by
    ///  the owner or the NFT contract.
    function withdrawBalance() external {
        address nftAddress = address(nonFungibleContract);

        require(
            msg.sender == owner ||
            msg.sender == nftAddress
        );
        nftAddress.transfer(address(this).balance);
    }

    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of time to move between starting
    ///  price and ending price (in seconds).
    /// @param _seller - Seller, if not the message sender
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
        external
        whenNotPaused
    {
        // Sanity check that no inputs overflow how many bits we've allocated
        // to store them in the auction struct.
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        require(_owns(msg.sender, _tokenId));
        _escrow(msg.sender, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }

    /// @dev Bids on an open auction, completing the auction and transferring
    ///  ownership of the NFT if enough Ether is supplied.
    /// @param _tokenId - ID of token to bid on.
    function bid(uint256 _tokenId)
        external
        payable
        whenNotPaused
    {
        address seller = tokenIdToAuction[_tokenId].seller;
        // _bid will throw if the bid or funds transfer fails
        _bid(_tokenId, msg.value);
        _transfer(msg.sender, _tokenId, seller);
    }

    /// @dev Cancels an auction that hasn't been won yet.
    ///  Returns the NFT to original owner.
    /// @notice This is a state-modifying function that can
    ///  be called while the contract is paused.
    /// @param _tokenId - ID of token on auction
    function cancelAuction(uint256 _tokenId)
        external
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        address seller = auction.seller;
        require(msg.sender == seller);
        _cancelAuction(_tokenId, seller);
    }

    /// @dev Cancels an auction when the contract is paused.
    ///  Only the owner may do this, and NFTs are returned to
    ///  the seller. This should only be used in emergencies.
    /// @param _tokenId - ID of the NFT on auction to cancel.
    function cancelAuctionWhenPaused(uint256 _tokenId)
        whenPaused
        onlyOwner
        external
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        _cancelAuction(_tokenId, auction.seller);
    }

    /// @dev Returns auction info for an NFT on auction.
    /// @param _tokenId - ID of NFT on auction.
    function getAuction(uint256 _tokenId)
        external
        view
        returns
    (
        address seller,
        uint256 startingPrice,
        uint256 endingPrice,
        uint256 duration,
        uint256 startedAt
    ) {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return (
            auction.seller,
            auction.startingPrice,
            auction.endingPrice,
            auction.duration,
            auction.startedAt
        );
    }

    /// @dev Returns the current price of an auction.
    /// @param _tokenId - ID of the token price we are checking.
    function getCurrentPrice(uint256 _tokenId)
        external
        view
        returns (uint256)
    {
        Auction storage auction = tokenIdToAuction[_tokenId];
        require(_isOnAuction(auction));
        return _currentPrice(auction);
    }

}

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/SiringClockAuction.sol

/// @title Reverse auction modified for siring
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SiringClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    // right auction in our setSiringAuctionAddress() call.
    bool public isSiringClockAuction = true;

    // 2% comission
    constructor(address _nftAddr) public
        ClockAuction(_nftAddr, 200) {}

    /// @dev Creates and begins a new auction. Since this function is wrapped,
    /// require sender to be Core contract.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
        external
    {
        // Sanity check that no inputs overflow how many bits we've allocated
        // to store them in the auction struct.
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungibleContract));
        _escrow(_seller, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }

    /// @dev Places a bid for siring. Requires the sender
    /// is the Core contract because all bid methods
    /// should be wrapped. Also returns the horsey to the
    /// seller rather than the winner.
    function bid(uint256 _tokenId)
        external
        payable
    {
        require(msg.sender == address(nonFungibleContract));
        address seller = tokenIdToAuction[_tokenId].seller;
        // _bid checks that token ID is valid and will throw if bid fails
        _bid(_tokenId, msg.value);
        // We transfer the horsey back to the seller, the winner will get
        // the offspring
        _transfer(seller, _tokenId, seller); /* INTERNAL TO CLOCKAUCTION */
    }
}

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/SaleClockAuction.sol

/// @title Clock auction modified for sale of horses
/// @notice We omit a fallback function to prevent accidental sends to this contract.
contract SaleClockAuction is ClockAuction {

    // @dev Sanity check that allows us to ensure that we are pointing to the
    //  right auction in our setSaleAuctionAddress() call.
    bool public isSaleClockAuction = true;

    // Tracks last 5 sale price of gen0 horse sales
    uint256 public gen0SaleCount;
    uint256[5] public lastGen0SalePrices;

    // 2% comission
    constructor(address _nftAddr) public
    ClockAuction(_nftAddr, 200) {}

    /// @dev Creates and begins a new auction.
    /// @param _tokenId - ID of token to auction, sender must be owner.
    /// @param _startingPrice - Price of item (in wei) at beginning of auction.
    /// @param _endingPrice - Price of item (in wei) at end of auction.
    /// @param _duration - Length of auction (in seconds).
    /// @param _seller - Seller, if not the message sender
    function createAuction(
        uint256 _tokenId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration,
        address _seller
    )
        external
    {
        // Sanity check that no inputs overflow how many bits we've allocated
        // to store them in the auction struct.
        require(_startingPrice == uint256(uint128(_startingPrice)));
        require(_endingPrice == uint256(uint128(_endingPrice)));
        require(_duration == uint256(uint64(_duration)));

        require(msg.sender == address(nonFungibleContract));
        _escrow(_seller, _tokenId);
        Auction memory auction = Auction(
            _seller,
            uint128(_startingPrice),
            uint128(_endingPrice),
            uint64(_duration),
            uint64(now)
        );
        _addAuction(_tokenId, auction);
    }

    /// @dev Updates lastSalePrice if seller is the nft contract
    /// Otherwise, works the same as default bid method.
    function bid(uint256 _tokenId)
        external
        payable
    {
        // _bid verifies token ID size
        address seller = tokenIdToAuction[_tokenId].seller;
        uint256 price = _bid(_tokenId, msg.value);
        _transfer(msg.sender, _tokenId, seller); /* INTERNAL TO CLOCKAUCTION */

        // If not a gen0 auction, exit
        if (seller == address(nonFungibleContract)) {
            // Track gen0 sale prices
            lastGen0SalePrices[gen0SaleCount % 5] = price;
            gen0SaleCount++;
        }
    }

    // TODO determine selling price strategy
    function averageGen0SalePrice() external view returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < 5; i++) {
            sum += lastGen0SalePrices[i];
        }
        return sum / 5;
    }

}

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/GeneScienceInterface.sol

contract GeneScienceInterface {
    /// @dev simply a boolean to indicate this is the contract we expect to be
    function isGeneScience() public pure returns (bool);

    /// @dev given genes of kitten 1 & 2, return a genetic combination - may have a random factor
    /// @param gene1 gene of mom
    /// @param gene2 gene of dad
    /// @return the genes that are supposed to be passed down the child
    function mixGenes(uint256 gene1, uint256 gene2, uint256 targetBlock) public view returns (uint256);
}

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/ReentrancyGuard.sol

/**
 * @title Helps contracts guard agains reentrancy attacks.
 * @author Remco Bloemen <[email protected]π.com>
 * @notice If you mark a function `nonReentrant`, you should also
 * mark it `external`.
 */
contract ReentrancyGuard {

    /**
    * @dev We use a single lock for the whole contract.
    */
    bool private reentrancyLock = false;

    /**
    * @dev Prevents a contract from calling itself, directly or indirectly.
    * @notice If you mark a function `nonReentrant`, you should also
    * mark it `external`. Calling one nonReentrant function from
    * another is not supported. Instead, you can implement a
    * `private` function doing the actual work, and a `external`
    * wrapper marked as `nonReentrant`.
    */
    modifier nonReentrant() {
        require(!reentrancyLock);
        reentrancyLock = true;
        _;
        reentrancyLock = false;
    }

}

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/Base.sol

/// @title Base contract. Holds all common structs, events and base variables.
contract Base is AccessControl, SupportsInterfaceWithLookup, ReentrancyGuard, ERC721 {
    using SafeMath for uint256;
    using AddressUtils for address;    
    /*** EVENTS ***/

    /// @dev The Birth event is fired whenever a new token comes into existence. This obviously
    ///  includes any time a token is created through the giveBirth method, but it is also called
    ///  when a new gen0 token is created.
    event Birth(address owner, uint256 tokenId, uint256 matronId, uint256 sireId, uint256 gene);

    /// @dev Transfer event as defined in current draft of ERC721. Emitted every time a token
    ///  ownership is assigned, including births.
    // event Transfer(address from, address to, uint256 tokenId);

    /*** DATA TYPES ***/

    /// @dev The NFT struct. Every token is represented by a copy.
    struct NFT {
        // The genetic code is packed into a 256-bit word
        uint256 gene;
        // The timestamp from the block when this token came into existence.
        uint64 birthTime; 

        // The minimum timestamp after which this token can engage in breeding
        // activities again. This same timestamp is used for the pregnancy
        // timer (for matrons) as well as the siring cooldown.
        uint64 cooldownEndBlock;

        // The ID of the parents of this token, set to 0 for gen0 tokens.
        uint32 matronId;
        uint32 sireId;

        // Set to the ID of the sire horse for matrons that are pregnant, zero otherwise. 
        uint32 siringWithId;

        // Set to the index in the cooldown array representing the current cooldown for this token
        uint16 cooldownIndex;      

        // The "generation number" of this token.
        // eneration number of all other token is the larger of the two generation
        // numbers of their parents, plus one.
        // (i.e. max(matron.generation, sire.generation) + 1)
        uint16 generation;
    }
    
    
    /*** TO BE MODIFIED***/

    /// @dev A lookup table indicating the cooldown duration after any successful breeding action
    uint32[14] public cooldowns = [
        uint32(1 minutes),
        uint32(2 minutes),
        uint32(5 minutes),
        uint32(10 minutes),
        uint32(30 minutes),
        uint32(1 hours),
        uint32(2 hours),
        uint32(4 hours),
        uint32(8 hours),
        uint32(16 hours),
        uint32(1 days),
        uint32(2 days),
        uint32(4 days),
        uint32(7 days)
    ];

    // An approximation of currently how many seconds are in between blocks.
    uint256 public secondsPerBlock = 15;

    /*** STORAGE ***/

    /// @dev An array containing the Horse struct for all horses in existence. The ID
    ///  of each horse is actually an index into this array. Note that ID 0 is 
    ///  Pegasus, the mythical beast that is the parent of all gen0 horse. A bizarre
    ///  creature that is both matron and sire... to itself! Has an invalid genetic code.
    ///  In other words, horse ID 0 is invalid... 
    NFT[] collection;

  // Array with all token ids, used for enumeration
    // uint256[] internal allTokens;
  // NFT[] internal allTokens

    /// @dev A mapping from horse IDs to the address that owns them. All tokens have
    ///  some valid owner address, even gen0 tokens are created with a non-zero owner.
    mapping (uint256 => address) internal tokenOwner;

    // @dev A mapping from owner address to count of tokens that address owns.
    //  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256) internal ownedTokensCount;

    /// @dev A mapping from TokenIDs to an address that has been approved to call
    ///  transferFrom(). Each Horse can only have one approved address for transfer
    ///  at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public tokenApprovals;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) internal operatorApprovals;    

    /// @dev A mapping from TokenIDs to an address that has been approved to use
    ///  this token for siring via breedWith(). Each Horse can only have one approved
    ///  address for siring at any time. A zero value means no approval is outstanding.
    mapping (uint256 => address) public sireApprovals;

  // Mapping from owner to list of owned token IDs
    // mapping(address => uint256[]) internal ownedTokens;

  // Mapping from token ID to index of the owner tokens list
    // mapping(uint256 => uint256) internal ownedTokensIndex;

  // Mapping from token id to position in the allTokens array
    // mapping(uint256 => uint256) internal allTokensIndex;

  // Optional mapping for token URIs
    mapping(uint256 => string) internal tokenURIs;

    /**
    * @dev Guarantees msg.sender is owner of the given token
    * @param _tokenId uint256 ID of the token to validate its ownership belongs to msg.sender
    */
    modifier onlyOwnerOf(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender);
        _;
    } 
    
    /**
    * @dev Checks msg.sender can transfer a token, by being owner, approved, or operator
    * @param _tokenId uint256 ID of the token to validate
    */
    modifier canTransfer(uint256 _tokenId) {
        require(isApprovedOrOwner(msg.sender, _tokenId),"msg.sender is not approved to transfer on behalf of owner");
        // require(_tokenId > 0);
        _;
    }       

    /// @dev The address of the ClockAuction contract that handles sales of tokens. This
    ///  same contract handles both peer-to-peer sales as well as the gen0 sales which are
    ///  initiated every 15 minutes.
    SaleClockAuction public saleAuction;

    /// @dev The address of a custom ClockAuction subclassed contract that handles siring
    ///  auctions. Needs to be separate from saleAuction because the actions taken on success
    ///  after a sales and siring auction are quite different.
    SiringClockAuction public siringAuction;

    // /// @dev Assigns ownership of a specific Token to an address.
    // function _transfer(address _from, address _to, uint256 _tokenId) internal {
    //     // Since the number of tokens is capped to 2^32 we can't overflow this
    //     ownedTokensCount[_to]++;
    //     // transfer ownership
    //     tokenOwner[_tokenId] = _to;
    //     // When creating new horses _from is 0x0, but we can't account that address.
    //     if (_from != address(0)) {
    //         ownedTokensCount[_from]--;
    //         // once the horse is transferred also clear sire allowances
    //         delete sireApprovals[_tokenId];
    //         // clear any previously approved ownership exchange
    //         delete tokenApprovals[_tokenId];
    //     }
    //     // Emit the transfer event.
    //     emit Transfer(_from, _to, _tokenId);
    // }

  /**
   * @dev Returns an URI for a given token ID
   * Throws if the token ID does not exist. May return an empty string.
   * @param _tokenId uint256 ID of the token to query
   */
    function tokenURI(uint256 _tokenId) public view returns (string) {
        require(exists(_tokenId));
        return tokenURIs[_tokenId];
    }

//   /**
//    * @dev Gets the token ID at a given index of the tokens list of the requested owner
//    * @param _owner address owning the tokens list to be accessed
//    * @param _index uint256 representing the index to be accessed of the requested tokens list
//    * @return uint256 token ID at the given index of the tokens list owned by the requested address
//    */
    // function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {
    //     require(_index < balanceOf(_owner));
    //     return ownedTokens[_owner][_index];
    // }

    /// @dev An internal method that creates a new horse and stores it. This
    ///  method doesn't do any checking and should only be called when the
    ///  input data is known to be valid. Will generate both a Birth event
    ///  and a Transfer event.
    /// @param _matronId The horsey ID of the matron of this horse (zero for gen0)
    /// @param _sireId The horsey ID of the sire of this horse (zero for gen0)
    /// @param _generation The generation number of this horse, must be computed by caller.
    /// @param _gene The horse's genetic code
    /// @param _owner The inital owner of this horse, must be non-zero (except for Pegasus, ID 0)
    function _createToken(
        uint256 _matronId,
        uint256 _sireId,
        uint256 _generation,
        uint256 _gene,
        address _owner
    )
        internal
        returns (uint)
    {
        // require(_to != address(0));       
        // These requires are not strictly necessary, our calling code should make
        // sure that these conditions are never broken. However! _createToken() is already
        // an expensive call (for storage), and it doesn't hurt to be especially careful
        // to ensure our data structures are always valid.
        require(_matronId == uint256(uint32(_matronId)));
        require(_sireId == uint256(uint32(_sireId)));
        require(_generation == uint256(uint16(_generation)));

        // New horse starts with the same cooldown as parent gen/2
        uint16 cooldownIndex = uint16(_generation / 2);
        if (cooldownIndex > 13) {
            cooldownIndex = 13;
        }

        NFT memory _new = NFT({
            gene: _gene,
            birthTime: uint64(now),
            cooldownEndBlock: 0,
            matronId: uint32(_matronId),
            sireId: uint32(_sireId),
            siringWithId: 0,
            cooldownIndex: cooldownIndex,
            generation: uint16(_generation)
        });
        uint256 newTokenId = collection.push(_new) - 1;

        // It's probably never going to happen, 4 billion horses is A LOT, but
        // let's just be 100% sure we never let this happen.
        require(newTokenId == uint256(uint32(newTokenId)));

        // emit the birth event
        emit Birth(_owner, newTokenId, uint256(_new.matronId), uint256(_new.sireId), _new.gene);

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        // _transfer(0, _owner, newTokenId);
        addTokenTo(_owner, newTokenId);
        emit Transfer(address(0), _owner, newTokenId);

        // allTokensIndex[newTokenId] = allTokens.length;
        // allTokens.push(newTokenId);

        return newTokenId;
    }

    // Any C-level can fix how many seconds per blocks are currently observed.
    function setSecondsPerBlock(uint256 secs) external onlyCLevel {
        require(secs < cooldowns[0]);
        secondsPerBlock = secs;
    }
//================================================//    
// }

// contract Ownership is Base /*, ERC721 */ {
//     using SafeMath for uint256;
//     using AddressUtils for address;

//================================================//
    /// @notice Name and symbol of the non fungible token, as defined in ERC721.

    // string public constant name = "ERC721";
    // string public constant symbol = "ERC721";

    // Token name
    string internal name_;

    // Token symbol
    string internal symbol_;    

    // bytes4 constant InterfaceSignature_ERC165 =
    //     bytes4(keccak256('supportsInterface(bytes4)')); ///////in SupportsInterfaceWithLookup.sol
    
    bytes4 private constant InterfaceId_ERC721Exists = 0x4f558e79;
    /*
    * 0x4f558e79 ===
    *   bytes4(keccak256('exists(uint256)'))
    */

    bytes4 private constant ERC721_RECEIVED = 0x150b7a02;    

    bytes4 private constant InterfaceId_ERC721Enumerable = 0x780e9d63;
    /**
    * 0x780e9d63 ===
    *   bytes4(keccak256('totalSupply()')) ^
    *   bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^
    *   bytes4(keccak256('tokenByIndex(uint256)'))
    */

    bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;
    /**
    * 0x5b5e139f ===
    *   bytes4(keccak256('name()')) ^
    *   bytes4(keccak256('symbol()')) ^
    *   bytes4(keccak256('tokenURI(uint256)'))
    */

    // bytes4 constant InterfaceSignature_ERC721 = ///////DEPRACATED SEE BELOW
    //     bytes4(keccak256('name()')) ^
    //     bytes4(keccak256('symbol()')) ^
    //     bytes4(keccak256('totalSupply()')) ^
    //     bytes4(keccak256('balanceOf(address)')) ^
    //     bytes4(keccak256('ownerOf(uint256)')) ^
    //     bytes4(keccak256('approve(address,uint256)')) ^
    //     bytes4(keccak256('transfer(address,uint256)')) ^
    //     bytes4(keccak256('transferFrom(address,address,uint256)')) ^
    //     bytes4(keccak256('tokensOfOwner(address)')) ^
    //     bytes4(keccak256('tokenMetadata(uint256,string)'));

    bytes4 private constant InterfaceId_ERC721 = 0x80ac58cd;
      /*
       * 0x80ac58cd ===
       *   bytes4(keccak256('balanceOf(address)')) ^
       *   bytes4(keccak256('ownerOf(uint256)')) ^
       *   bytes4(keccak256('approve(address,uint256)')) ^
       *   bytes4(keccak256('getApproved(uint256)')) ^
       *   bytes4(keccak256('setApprovalForAll(address,bool)')) ^
       *   bytes4(keccak256('isApprovedForAll(address,address)')) ^
       *   bytes4(keccak256('transferFrom(address,address,uint256)')) ^
       *   bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^
       *   bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))
       */
    /// @notice Introspection interface as per ERC-165 (https://github.com/ethereum/EIPs/issues/165).
    ///  Returns true for any standardized interfaces implemented by this contract. We implement
    ///  ERC-165 (obviously!) and ERC-721.
    // function supportsInterface(bytes4 _interfaceID) external view returns (bool) ///////in SupportsInterfaceWithLookup.sol
    // {
    //     // DEBUG ONLY
    //     //require((InterfaceSignature_ERC165 == 0x01ffc9a7) && (InterfaceSignature_ERC721 == 0x9a20483d));

    //     return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));
    // }

    constructor(string _name, string _symbol) public { 
        name_ = _name;
        symbol_ = _symbol;

        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(InterfaceId_ERC165);
        _registerInterface(InterfaceId_ERC721Enumerable);
        _registerInterface(InterfaceId_ERC721Metadata);
        _registerInterface(InterfaceId_ERC721);
        _registerInterface(InterfaceId_ERC721Exists);

    }
  /**
   * @dev Gets the token name
   * @return string representing the token name
   */
    function name() external view returns (string) { 
        return name_;
    }

  /**
   * @dev Gets the token symbol
   * @return string representing the token symbol
   */
    function symbol() external view returns (string) { 
        return symbol_;
    }
    // Internal utility functions: These functions all assume that their input arguments
    // are valid. We leave it to public methods to sanitize their inputs and follow
    // the required logic.

    /// @dev Checks if a given address is the current owner of a particular Horse.
    /// @param _claimant the address we are validating against.
    /// @param _tokenId horse id, only valid when > 0
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return tokenOwner[_tokenId] == _claimant;
    }

    /// @dev Checks if a given address currently has transferApproval for a particular Horse.
    /// @param _claimant the address we are confirming horse is approved for.
    /// @param _tokenId horse id, only valid when > 0
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return tokenApprovals[_tokenId] == _claimant;
    }

    // /// @dev Marks an address as being approved for transferFrom(), overwriting any previous
    // ///  approval. Setting _approved to address(0) clears all transfer approval.
    // ///  NOTE: _approve() does NOT send the Approval event. This is intentional because
    // ///  _approve() and transferFrom() are used together for putting Horses on auction, and
    // ///  there is no value in spamming the log with Approval events in that case.
    // function _approve(uint256 _tokenId, address _approved) internal {
    //     tokenApprovals[_tokenId] = _approved;
    // }

    // /// @notice Returns the number of Horses owned by a specific address.
    // /// @param _owner The owner address to check.
    // /// @dev Required for ERC-721 compliance
    // function balanceOf(address _owner) public view returns (uint256 count) {
    //     require(_owner != address(0));
    //     return ownedTokensCount[_owner];
    // }

    /**
    * @dev Gets the balance of the specified address
    * @param _owner address to query the balance of
    * @return uint256 representing the amount owned by the passed address
    */
    function balanceOf(address _owner) public view returns (uint256) {
        require(_owner != address(0));
        return ownedTokensCount[_owner];
    }

    ////// DEPRECATED
    // /// @notice Transfers a Horse to another address. If transferring to a smart
    // ///  contract be VERY CAREFUL to ensure that it is aware of ERC-721 or your Horse may be lost forever. Seriously.
    // /// @param _to The address of the recipient, can be a user or contract.
    // /// @param _tokenId The ID of the Horse to transfer.
    // /// @dev Required for ERC-721 compliance.
    // function transfer(
    //     address _to,
    //     uint256 _tokenId
    // )
    //     external
    //     whenNotPaused
    // {
    //     // Safety check to prevent against an unexpected 0x0 default.
    //     require(_to != address(0));
    //     // Disallow transfers to this contract to prevent accidental misuse.
    //     // The contract should never own any horsies (except very briefly
    //     // after a gen0 horse is created and before it goes on auction).
    //     require(_to != address(this));
    //     // Disallow transfers to the auction contracts to prevent accidental
    //     // misuse. Auction contracts should only take ownership of horses
    //     // through the allow + transferFrom flow.
    //     require(_to != address(saleAuction));
    //     require(_to != address(siringAuction));

    //     // You can only send your own horse.
    //     require(_owns(msg.sender, _tokenId));

    //     // Reassign ownership, clear pending approvals, emit Transfer event.
    //     _transfer(msg.sender, _to, _tokenId);
    // }

    // /// @notice Grant another address the right to transfer a specific Horse via
    // ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.
    // /// @param _to The address to be granted transfer approval. Pass address(0) to
    // ///  clear all approvals.
    // /// @param _tokenId The ID of the Horse that can be transferred if this call succeeds.
    // /// @dev Required for ERC-721 compliance.
    // function approve(
    //     address _to,
    //     uint256 _tokenId
    // )
    //     external
    //     whenNotPaused
    // {
    //     // Only an owner can grant transfer approval.
    //     require(_owns(msg.sender, _tokenId));

    //     // Register the approval (replacing any previous approval).
    //     // _approve(_tokenId, _to);
    //     tokenApprovals[_tokenId] = _to; //_approved;

    //     // Emit approval event.
    //     emit Approval(msg.sender, _to, _tokenId);
    // }

    /**
    * @dev Approves another address to transfer the given token ID
    * The zero address indicates there is no approved address.
    * There can only be one approved address per token at a given time.
    * Can only be called by the token owner or an approved operator.
    * @param _to address to be approved for the given token ID
    * @param _tokenId uint256 ID of the token to be approved
    */
    function approve(address _to, uint256 _tokenId) public whenNotPaused {
        address owner = ownerOf(_tokenId);
        require(_to != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        tokenApprovals[_tokenId] = _to;
        emit Approval(owner, _to, _tokenId);
    }    

    /**
    * @dev Gets the approved address for a token ID, or zero if no address set
    * @param _tokenId uint256 ID of the token to query the approval of
    * @return address currently approved for the given token ID
    */
    function getApproved(uint256 _tokenId) public view returns (address) {
        return tokenApprovals[_tokenId];
    }

    /**
    * @dev Sets or unsets the approval of a given operator
    * An operator is allowed to transfer all tokens of the sender on their behalf
    * @param _to operator address to set the approval
    * @param _approved representing the status of the approval to be set
    */
    function setApprovalForAll(address _to, bool _approved) public {
        require(_to != msg.sender);
        operatorApprovals[msg.sender][_to] = _approved;
        emit ApprovalForAll(msg.sender, _to, _approved);
    }    

    /**
    * @dev Tells whether an operator is approved by a given owner
    * @param _owner owner address which you want to query the approval of
    * @param _operator operator address which you want to query the approval of
    * @return bool whether the given operator is approved by the given owner
    */
    function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
        return operatorApprovals[_owner][_operator];
    }

    // /// @notice Transfer a Horse owned by another address, for which the calling address
    // ///  has previously been granted transfer approval by the owner.
    // /// @param _from The address that owns the Horse to be transfered.
    // /// @param _to The address that should take ownership of the Horse. Can be any address,
    // ///  including the caller.
    // /// @param _tokenId The ID of the Horse to be transferred.
    // /// @dev Required for ERC-721 compliance.
    // function transferFrom(
    //     address _from,
    //     address _to,
    //     uint256 _tokenId
    // )
    //     external
    //     whenNotPaused
    // {
    //     // Safety check to prevent against an unexpected 0x0 default.
    //     require(_to != address(0));
    //     // Disallow transfers to this contract to prevent accidental misuse.
    //     // The contract should never own any horses (except very briefly
    //     // after a gen0 horse is created and before it goes on auction).
    //     require(_to != address(this));
    //     // Check for approval and valid ownership
    //     require(_approvedFor(msg.sender, _tokenId));
    //     require(_owns(_from, _tokenId));

    //     // Reassign ownership (also clears pending approvals and emits Transfer event).
    //     _transfer(_from, _to, _tokenId);
    // }

    // /// @notice Returns the total number of Horses currently in existence.
    // /// @dev Required for ERC-721 compliance.
    // function totalSupply() public view returns (uint) {
    //     return collection.length - 1;
    // }

  /**
   * @dev Gets the total amount of tokens stored by the contract
   * @return uint256 representing the total amount of tokens
   */
    function totalSupply() public view returns (uint256) {
        // return allTokens.length;
        return collection.length;
    }

  /**
   * @dev Gets the token ID at a given index of all the tokens in this contract
   * Reverts if the index is greater or equal to the total number of tokens
   * @param _index uint256 representing the index to be accessed of the tokens list
   * @return uint256 token ID at the given index of the tokens list
   */
    function tokenByIndex(uint256 _index) public view returns (uint256) {
        require(_index < totalSupply());
        // return allTokens[_index];
        return _index;
    }

  /**
   * @dev Internal function to set the token URI for a given token
   * Reverts if the token ID does not exist
   * @param _tokenId uint256 ID of the token to set its URI
   * @param _uri string URI to assign
   */
    function _setTokenURI(uint256 _tokenId, string _uri) internal {
        require(exists(_tokenId));
        tokenURIs[_tokenId] = _uri;
    }

  /**
   * @dev Transfers the ownership of a given token ID to another address
   * Usage of this method is discouraged, use `safeTransferFrom` whenever possible
   * Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
  */
    function transferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) whenNotPaused {
        require(_from != address(0));
        require(_to != address(0));

        // require(_to != address(saleAuction));
        // require(_to != address(siringAuction));

        clearApproval(_from, _tokenId);
        removeTokenFrom(_from, _tokenId);
        addTokenTo(_to, _tokenId);

        emit Transfer(_from, _to, _tokenId);
    }

  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * If the target address is a contract, it must implement `onERC721Received`,
   * which is called upon a safe transfer, and return the magic value
   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
   * the transfer is reverted.
   *
   * Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
  */
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) whenNotPaused {
      // solium-disable-next-line arg-overflow
        safeTransferFrom(_from, _to, _tokenId, "");
    }

  /**
   * @dev Safely transfers the ownership of a given token ID to another address
   * If the target address is a contract, it must implement `onERC721Received`,
   * which is called upon a safe transfer, and return the magic value
   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,
   * the transfer is reverted.
   * Requires the msg sender to be the owner, approved, or operator
   * @param _from current owner of the token
   * @param _to address to receive the ownership of the given token ID
   * @param _tokenId uint256 ID of the token to be transferred
   * @param _data bytes data to send along with a safe transfer check
   */
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public canTransfer(_tokenId) whenNotPaused {
        transferFrom(_from, _to, _tokenId);
        // solium-disable-next-line arg-overflow
        require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data)); // FAILS BEFORE REACHING THIS
    }

  /**
   * @dev Internal function to invoke `onERC721Received` on a target address
   * The call is not executed if the target address is not a contract
   * @param _from address representing the previous owner of the given token ID
   * @param _to target address that will receive the tokens
   * @param _tokenId uint256 ID of the token to be transferred
   * @param _data bytes optional data to send along with the call
   * @return whether the call correctly returned the expected magic value
   */
    function checkAndCallSafeTransfer(address _from, address _to, uint256 _tokenId, bytes _data) internal returns (bool) {
        if (!_to.isContract()) {
            return true;
        }
        bytes4 retval = ERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
        return (retval == ERC721_RECEIVED);
    }

    // /// @notice Returns the address currently assigned ownership of a given Horse.
    // /// @dev Required for ERC-721 compliance.
    // function ownerOf(uint256 _tokenId)
    //     external
    //     view
    //     returns (address owner)
    // {
    //     owner = tokenOwner[_tokenId];

    //     require(owner != address(0));
    // }

    /**
    * @dev Gets the owner of the specified token ID
    * @param _tokenId uint256 ID of the token to query the owner of
    * @return owner address currently marked as the owner of the given token ID
    */
    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = tokenOwner[_tokenId];
        require(owner != address(0));
        return owner;
    }

    /**
    * @dev Returns whether the specified token exists
    * @param _tokenId uint256 ID of the token to query the existence of
    * @return whether the token exists
    */
    function exists(uint256 _tokenId) public view returns (bool) {
        address owner = tokenOwner[_tokenId];
        return owner != address(0);
    }

    /**
    * @dev Internal function to clear current approval of a given token ID
    * Reverts if the given address is not indeed the owner of the token
    * @param _owner owner of the token
    * @param _tokenId uint256 ID of the token to be transferred
    */
    function clearApproval(address _owner, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _owner);
        if (tokenApprovals[_tokenId] != address(0)) {
            tokenApprovals[_tokenId] = address(0);
        }
        if (sireApprovals[_tokenId] != address(0)) {
            sireApprovals[_tokenId] = address(0);
        }
    }

    function clearSiringApproval(address _owner, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _owner);
        if (sireApprovals[_tokenId] != address(0)) {
            sireApprovals[_tokenId] = address(0);
        }
    }

    /**
    * @dev Internal function to remove a token ID from the list of a given address
    * @param _from address representing the previous owner of the given token ID
    * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
    */
    function removeTokenFrom(address _from, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _from);
        ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
        tokenOwner[_tokenId] = address(0);

        // uint256 tokenIndex = ownedTokensIndex[_tokenId];
        // uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
        // uint256 lastToken = ownedTokens[_from][lastTokenIndex];

        // ownedTokens[_from][tokenIndex] = lastToken;
        // ownedTokens[_from][lastTokenIndex] = 0;
        // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
        // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
        // the lastToken to the first position, and then dropping the element placed in the last position of the list

        // ownedTokens[_from].length--;
        // ownedTokensIndex[_tokenId] = 0;
        // ownedTokensIndex[lastToken] = tokenIndex;

        // tokenOwner[_tokenId] = address(0);
    }

    /**
    * @dev Internal function to add a token ID to the list of a given address
    * @param _to address representing the new owner of the given token ID
    * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
    */
    function addTokenTo(address _to, uint256 _tokenId) internal {
        require(tokenOwner[_tokenId] == address(0));
        tokenOwner[_tokenId] = _to;
        ownedTokensCount[_to] = ownedTokensCount[_to].add(1);

        // uint256 length = ownedTokens[_to].length;
        // ownedTokens[_to].push(_tokenId);
        // ownedTokensIndex[_tokenId] = length;
    }

  /**
   * @dev Returns whether the given spender can transfer a given token ID
   * @param _spender address of the spender to query
   * @param _tokenId uint256 ID of the token to be transferred
   * @return bool whether the msg.sender is approved for the given token ID,
   *  is an operator of the owner, or is the owner of the token
   */
    function isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
        address owner = ownerOf(_tokenId);
        // Disable solium check because of
        // https://github.com/duaraghav8/Solium/issues/175
        // solium-disable-next-line operator-whitespace
        return (
        _spender == owner ||
        getApproved(_tokenId) == _spender ||
        isApprovedForAll(owner, _spender)
        );
    }

    /// @notice Returns a list of all Horse IDs assigned to an address.
    /// @param _owner The owner whose Horses we are interested in.
    /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly
    ///  expensive (it walks the entire Horse array looking for horses belonging to owner),
    ///  but it also returns a dynamic array, which is only supported for web3 calls, and
    ///  not contract-to-contract calls.
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalTokens = totalSupply();
            uint256 resultIndex = 0;

            // We count on the fact that all horses have IDs starting at 1 and increasing
            // sequentially up to the totalHorses count.
            uint256 tokenId;

            for (tokenId = 1; tokenId <= totalTokens; tokenId++) {
                if (tokenOwner[tokenId] == _owner) {
                    result[resultIndex] = tokenId;
                    resultIndex++;
                }
            }

            return result;
        }
    }
}

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/Breeding.sol

/// @title A facet of Core that manages NFT siring, gestation, and birth.
contract Breeding is Base {

    /// @dev The Pregnant event is fired when two horses successfully breed and the pregnancy
    ///  timer begins for the matron.
    event Pregnant(address owner, uint256 matronId, uint256 sireId, uint256 matronCooldownEndBlock, uint256 sireCooldownEndBlock);

    /// @notice The minimum payment required to use breedWithAuto(). This fee goes towards
    ///  the gas cost paid by whatever calls giveBirth(), and can be dynamically updated by
    ///  the COO role as the gas price changes.
    uint256 public autoBirthFee = 2 finney;         //0.002 ether

    // Keeps track of number of pregnant horsies.
    uint256 public pregnantTokens;

    uint256 public cooldownEtherRate = 1 finney;   // 0.001 ether

    /// @dev The address of the sibling contract that is used to implement the
    ///  truffle tic combination algorithm.
    GeneScienceInterface public geneScience;

    /// @dev Update the address of the genetic contract, can only be called by the CEO.
    /// @param _address An address of a GeneScience contract instance to be used from this point forward.
    function setGeneScienceAddress(address _address) external onlyCEO {
        GeneScienceInterface candidateContract = GeneScienceInterface(_address);

        // NOTE: verify that a contract is what we expect
        // https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isGeneScience());

        // Set the new contract address
        geneScience = candidateContract;
    }

    function setCooldownEtherRate(uint256 _rate) external onlyCTO {
        require(_rate > 0, "Rate may not be zero");
        cooldownEtherRate = _rate;
    }

    /// @dev Checks that a given horse is able to breed. Requires that the
    ///  current cooldown is finished (for sires) and also checks that there is
    ///  no pending pregnancy.
    function _isReadyToBreed(NFT _nft) internal view returns (bool) {
        // In addition to checking the cooldownEndBlock, we also need to check to see if
        // the horse has a pending birth; there can be some period of time between the end
        // of the pregnacy timer and the birth event.
        return (_nft.siringWithId == 0) && (_nft.cooldownEndBlock <= uint64(block.number));
    }

    /// @dev Check if a sire has authorized breeding with this matron. True if both sire
    ///  and matron have the same owner, or if the sire has given siring permission to
    ///  the matron's owner (via approveSiring()).
    function _isSiringPermitted(uint256 _sireId, uint256 _matronId) internal view returns (bool) {
        address matronOwner = tokenOwner[_matronId];
        address sireOwner = tokenOwner[_sireId];

        // Siring is okay if they have same owner, or if the matron's owner was given
        // permission to breed with this sire.
        return (matronOwner == sireOwner || sireApprovals[_sireId] == matronOwner);
    }

    /// @dev Set the cooldownEndTime for the given Horse, based on its current cooldownIndex.
    ///  Also increments the cooldownIndex (unless it has hit the cap).
    /// @param _nft A reference to the NFT in storage which needs its timer started.
    function _triggerCooldown(NFT storage _nft) internal {
        // Compute an estimation of the cooldown time in blocks (based on current cooldownIndex).
        _nft.cooldownEndBlock = uint64((cooldowns[_nft.cooldownIndex]/secondsPerBlock) + block.number);

        // Increment the breeding count, clamping it at 13, which is the length of the
        // cooldowns array. We could check the array size dynamically, but hard-coding
        // this as a constant saves gas. Yay, Solidity!
        if (_nft.cooldownIndex < 13) {
            _nft.cooldownIndex += 1;
        }
    }

    /// @dev Reduce the cooldownEndTime for the given NFT.
    /// @param _id A reference to the NFT in storage which needs its timer started.
    function reduceCooldown(uint256 _id) payable external onlyOwnerOf(_id) nonReentrant {
        NFT storage _nft = collection[_id];

        uint256 reductionCost = _computeCooldownCost(_nft);

        if(reductionCost == 0) {
            revert();
        }

        // uint256 cost = duration * cooldownEtherRate;
        require(msg.value >= reductionCost, "Insufficient payment to reduce current cooldown");

        _nft.cooldownEndBlock = uint64(block.number);
        (msg.sender).transfer(msg.value - reductionCost);
    }

    /// @dev Calculates the cost to reduce current cooldown
    /// @param _id The token ID whose cooldown cost is being queried
    function getCooldownCost(uint256 _id) external view returns(uint256 cost) {
        NFT storage _nft = collection[_id];
        cost = _computeCooldownCost(_nft);
    }

    /// @dev internal method handling cooldown cost computation
    /// @param _nft The token whose cooldown cost is being queried
    function _computeCooldownCost(NFT memory _nft) internal view returns(uint256) {
        // duration is zero for cooldowns less than an hour
        // uint256 duration = ((_nft.cooldownEndBlock - block.number) * secondsPerBlock) / (1 hours);
        // cost is correspondingly zero for cooldowns below an hour
        // cost = duration * cooldownEtherRate;
        // bypass unecessary intermediate variable
        return uint256((((_nft.cooldownEndBlock - block.number) * secondsPerBlock) / (1 hours)) * cooldownEtherRate);
    }

    /// @notice Grants approval to another user to sire with one of your Horses.
    /// @param _addr The address that will be able to sire with your Horse. Set to
    ///  address(0) to clear all siring approvals for this Horse.
    /// @param _sireId A Horse that you own that _addr will now be able to sire with.
    function approveSiring(address _addr, uint256 _sireId)
        external
        whenNotPaused
    {
        require(_owns(msg.sender, _sireId));
        sireApprovals[_sireId] = _addr;
    }

    /// @dev Updates the minimum payment required for calling giveBirthAuto(). Can only
    ///  be called by the COO address. (This fee is used to offset the gas cost incurred
    ///  by the autobirth daemon).
    function setAutoBirthFee(uint256 val) external onlyCOO {
        autoBirthFee = val;
    }

    /// @dev Checks to see if a given Horse is pregnant and (if so) if the gestation
    ///  period has passed.
    function _isReadyToGiveBirth(NFT _matron) private view returns (bool) {
        return (_matron.siringWithId != 0) && (_matron.cooldownEndBlock <= uint64(block.number));
    }

    /// @notice Checks that a given horse is able to breed (i.e. it is not pregnant or
    ///  in the middle of a siring cooldown).
    /// @param _nftId reference the id of the horse, any user can inquire about it
    function isReadyToBreed(uint256 _nftId)
        public
        view
        returns (bool)
    {
        require(_nftId > 0);
        NFT storage token = collection[_nftId];
        return _isReadyToBreed(token);
    }

    /// @dev Checks whether a horsey is currently pregnant.
    /// @param _nftId reference the id of the horse, any user can inquire about it
    function isPregnant(uint256 _nftId)
        public
        view
        returns (bool)
    {
        require(_nftId > 0);
        // A horse is pregnant if and only if this field is set
        return collection[_nftId].siringWithId != 0;
    }

    /// @dev Internal check to see if a given sire and matron are a valid mating pair. DOES NOT
    ///  check ownership permissions (that is up to the caller).
    /// @param _matron A reference to the Horse struct of the potential matron.
    /// @param _matronId The matron's ID.
    /// @param _sire A reference to the Horse struct of the potential sire.
    /// @param _sireId The sire's ID
    function _isValidMatingPair(
        NFT storage _matron,
        uint256 _matronId,
        NFT storage _sire,
        uint256 _sireId
    )
        private
        view
        returns(bool)
    {
        // A Horse can't breed with itself!
        if (_matronId == _sireId) {
            return false;
        }

        // Horses can't breed with their parents.
        if (_matron.matronId == _sireId || _matron.sireId == _sireId) {
            return false;
        }
        if (_sire.matronId == _matronId || _sire.sireId == _matronId) {
            return false;
        }

        // We can short circuit the sibling check (below) if either horse is
        // gen zero (has a matron ID of zero).
        if (_sire.matronId == 0 || _matron.matronId == 0) {
            return true;
        }

        // Horses can't breed with full or half siblings.
        if (_sire.matronId == _matron.matronId || _sire.matronId == _matron.sireId) {
            return false;
        }
        if (_sire.sireId == _matron.matronId || _sire.sireId == _matron.sireId) {
            return false;
        }

        // Everything seems cool! Let's get DTF.
        return true;
    }

    /// @dev Internal check to see if a given sire and matron are a valid mating pair for
    ///  breeding via auction (i.e. skips ownership and siring approval checks).
    function _canBreedWithViaAuction(uint256 _matronId, uint256 _sireId)
        internal
        view
        returns (bool)
    {
        NFT storage matron = collection[_matronId];
        NFT storage sire = collection[_sireId];
        return _isValidMatingPair(matron, _matronId, sire, _sireId);
    }

    /// @notice Checks to see if two horses can breed together, including checks for
    ///  ownership and siring approvals. Does NOT check that both horses are ready for
    ///  breeding (i.e. breedWith could still fail until the cooldowns are finished).
    /// @param _matronId The ID of the proposed matron.
    /// @param _sireId The ID of the proposed sire.
    function canBreedWith(uint256 _matronId, uint256 _sireId)
        external
        view
        returns(bool)
    {
        require(_matronId > 0);
        require(_sireId > 0);
        NFT storage matron = collection[_matronId];
        NFT storage sire = collection[_sireId];
        return _isValidMatingPair(matron, _matronId, sire, _sireId) &&
            _isSiringPermitted(_sireId, _matronId);
    }

    /// @dev Internal utility function to initiate breeding, assumes that all breeding
    ///  requirements have been checked.
    function _breedWith(uint256 _matronId, uint256 _sireId) internal {
        // Grab a reference to the Horses from storage.
        NFT storage sire = collection[_sireId];
        NFT storage matron = collection[_matronId];

        // Mark the matron as pregnant, keeping track of who the sire is.
        matron.siringWithId = uint32(_sireId);

        // Trigger the cooldown for both parents.
        _triggerCooldown(sire);
        _triggerCooldown(matron);

        // Clear siring permission for both parents. This may not be strictly necessary
        // but it's likely to avoid confusion!
        delete sireApprovals[_matronId];
        delete sireApprovals[_sireId];

        // Every time a horse gets pregnant, counter is incremented.
        pregnantTokens++;

        // Emit the pregnancy event.
        emit Pregnant(tokenOwner[_matronId], _matronId, _sireId, matron.cooldownEndBlock, sire.cooldownEndBlock);
    }

    /// @notice Breed a Horse you own (as matron) with a sire that you own, or for which you
    ///  have previously been given Siring approval. Will either make your horse pregnant, or will
    ///  fail entirely. Requires a pre-payment of the fee given out to the first caller of giveBirth()
    /// @param _matronId The ID of the Horse acting as matron (will end up pregnant if successful)
    /// @param _sireId The ID of the Horse acting as sire (will begin its siring cooldown if successful)
    function breedWithAuto(uint256 _matronId, uint256 _sireId)
        external
        payable
        whenNotPaused
    {
        // Checks for payment.
        require(msg.value >= autoBirthFee);

        // Caller must own the matron.
        require(_owns(msg.sender, _matronId));

        // Neither sire nor matron are allowed to be on auction during a normal
        // breeding operation, but we don't need to check that explicitly.
        // For matron: The caller of this function can't be the owner of the matron
        //   because the owner of a Horse on auction is the auction house, and the
        //   auction house will never call breedWith().
        // For sire: Similarly, a sire on auction will be owned by the auction house
        //   and the act of transferring ownership will have cleared any oustanding
        //   siring approval.
        // Thus we don't need to spend gas explicitly checking to see if either horse
        // is on auction.

        // Check that matron and sire are both owned by caller, or that the sire
        // has given siring permission to caller (i.e. matron's owner).
        // Will fail for _sireId = 0
        require(_isSiringPermitted(_sireId, _matronId));

        // Grab a reference to the potential matron
        NFT storage matron = collection[_matronId];

        // Make sure matron isn't pregnant, or in the middle of a siring cooldown
        require(_isReadyToBreed(matron));

        // Grab a reference to the potential sire
        NFT storage sire = collection[_sireId];

        // Make sure sire isn't pregnant, or in the middle of a siring cooldown
        require(_isReadyToBreed(sire));

        // Test that these horses are a valid mating pair.
        require(_isValidMatingPair(
            matron,
            _matronId,
            sire,
            _sireId
        ));

        // All checks passed, horse gets pregnant!
        _breedWith(_matronId, _sireId);
    }

    /// @notice Have a pregnant Horse give birth!
    /// @param _matronId A Horse ready to give birth.
    /// @return The Horse ID of the new horse.
    /// @dev Looks at a given Horse and, if pregnant and if the gestation period has passed,
    ///  combines the genes of the two parents to create a new horse. The new Horse is assigned
    ///  to the current owner of the matron. Upon successful completion, both the matron and the
    ///  new horse will be ready to breed again. Note that anyone can call this function (if they
    ///  are willing to pay the gas!), but the new horse always goes to the mother's owner.

	  /// Update this giveBirth to accept 2nd parameter - _cGene
    function giveBirth(uint256 _matronId, uint256 _cGene)
        external
        whenNotPaused
        returns(uint256)
    {
        // Grab a reference to the matron in storage.
        NFT storage matron = collection[_matronId];

        // Check that the matron is a valid horses.
        require(matron.birthTime != 0);

        // Check that the matron is pregnant, and that its time has come!
        require(_isReadyToGiveBirth(matron));

        // Grab a reference to the sire in storage.
        uint256 sireId = matron.siringWithId;
        NFT storage sire = collection[sireId];

        // Determine the higher generation number of the two parents
        uint16 parentGen = matron.generation;
        if (sire.generation > matron.generation) {
            parentGen = sire.generation;
        }

        // Call the gene mixing operation
        uint256 childGene;
        // (childGene) = geneScience.mixGenes(matron.gene, sire.gene, matron.cooldownEndBlock - 1);

              (childGene) = _cGene;

        // Make the new horse!
        address owner = tokenOwner[_matronId];
        uint256 newTokenId = _createToken(_matronId, matron.siringWithId, parentGen + 1, childGene, owner);

        // Clear the reference to sire from the matron (REQUIRED! Having siringWithId
        // set is what marks a matron as being pregnant.)
        delete matron.siringWithId;

        // Every time a horsey gives birth counter is decremented.
        pregnantTokens--;

        // Send the balance fee to the person who made birth happen.
        msg.sender.transfer(autoBirthFee);

        // return the new horse's ID
        return newTokenId;
    }
}

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/Auction.sol

/// @title Handles creating auctions for sale and siring of horses.
///  This wrapper of ReverseAuction exists only so that users can create
///  auctions with only one transaction.
contract Auction is Breeding {

    // @notice The auction contract variables are defined in Base to allow
    //  us to refer to them in Ownership to prevent accidental transfers.
    // `saleAuction` refers to the auction for gen0 and p2p sale of horsies.
    // `siringAuction` refers to the auction for siring rights of horsies.

    /// @dev Sets the reference to the sale auction.
    /// @param _address - Address of sale contract.
    function setSaleAuctionAddress(address _address) external onlyCEO {
        SaleClockAuction candidateContract = SaleClockAuction(_address);

        // NOTE: verify that a contract is what we expect 
        // https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isSaleClockAuction());

        // Set the new contract address
        saleAuction = candidateContract;
        
        operatorApprovals[address(this)][_address] = true; // approve sale auction
    }

    /// @dev Sets the reference to the siring auction.
    /// @param _address - Address of siring contract.
    function setSiringAuctionAddress(address _address) external onlyCEO {
        SiringClockAuction candidateContract = SiringClockAuction(_address);

        // NOTE: verify that a contract is what we expect 
        // https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isSiringClockAuction());

        // Set the new contract address
        siringAuction = candidateContract;
        
        // setApprovalForAll(siringAuction, true); Core will never sire place tokens for siring!
    }

    /// @dev Put an nft up for auction.
    ///  Does some ownership trickery to create auctions in one tx.
    function createSaleAuction(
        uint256 _nftId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
        external
        whenNotPaused
    {
        // Auction contract checks input sizes
        // If horse is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(msg.sender, _nftId));
        // Ensure the horsey is not pregnant to prevent the auction
        // contract accidentally receiving ownership of the child.
        // NOTE: the horse IS allowed to be in a cooldown.
        require(!isPregnant(_nftId));
        // _approve(_nftId, saleAuction);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the horsey.
        saleAuction.createAuction(
            _nftId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }

    /// @dev Put a horse up for auction to be sire.
    ///  Performs checks to ensure the horse can be sired, then
    ///  delegates to reverse auction.
    function createSiringAuction(
        uint256 _nftId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
        external
        whenNotPaused
    {
        // Auction contract checks input sizes
        // If horse is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(msg.sender, _nftId));
        require(isReadyToBreed(_nftId));
        // _approve(_nftId, siringAuction);
        // Siring auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the horsey.
        siringAuction.createAuction(
            _nftId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }

    /// @dev Completes a siring auction by bidding.
    ///  Immediately breeds the winning matron with the sire on auction.
    /// @param _sireId - ID of the sire on auction.
    /// @param _matronId - ID of the matron owned by the bidder.
    function bidOnSiringAuction(
        uint256 _sireId,
        uint256 _matronId
    )
        external
        payable
        whenNotPaused
    {
        // Auction contract checks input sizes
        require(_owns(msg.sender, _matronId));
        require(isReadyToBreed(_matronId));
        require(_canBreedWithViaAuction(_matronId, _sireId));

        // Define the current price of the auction.
        uint256 currentPrice = siringAuction.getCurrentPrice(_sireId);
        require(msg.value >= currentPrice + autoBirthFee);

        // Siring auction will throw if the bid fails.
        siringAuction.bid.value(msg.value - autoBirthFee)(_sireId);
        _breedWith(uint32(_matronId), uint32(_sireId));
    }

    /// @dev Transfers the balance of the sale auction contract
    /// to the Core contract. We use two-step withdrawal to
    /// prevent two transfer calls in the auction bid function.
    function withdrawAuctionBalances() external onlyCLevel {
        saleAuction.withdrawBalance();
        siringAuction.withdrawBalance();
    }
}

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/Minting.sol

/// @title all functions related to creating horses
contract Minting is Auction {

    // Limits the number of horses the contract owner can ever create.
    uint256 public constant PROMO_CREATION_LIMIT = 5000;
    uint256 public constant GEN0_CREATION_LIMIT = 45000;

    // Constants for gen0 auctions.
    uint256 public constant GEN0_STARTING_PRICE = 10 finney;    //0.01 ether
    uint256 public constant GEN0_AUCTION_DURATION = 1 days;

    // Counts the number of horses the contract owner has created.
    uint256 public promoCreatedCount;
    uint256 public gen0CreatedCount;

    /// @dev we can create promo nfts, up to a limit. Only callable by COO
    /// @param _gene the encoded genes of the nft to be created, any value is accepted
    function createPromoTokenDebugger(uint256 _gene) external onlyCTO returns(uint256 nftId) {
        require(promoCreatedCount < PROMO_CREATION_LIMIT);

        promoCreatedCount++;
        nftId = _createToken(0, 0, 0, _gene, ctoAddress);
    }

    /// @dev we can create promo nfts, up to a limit. Only callable by COO
    /// @param _gene the encoded genes of the nft to be created, any value is accepted
    /// @param _owner the future owner of the created nfts. Default to contract COO
    function createPromoToken(uint256 _gene, address _owner) external onlyCTO returns(uint256 nftId) {
        require(promoCreatedCount < PROMO_CREATION_LIMIT);

        promoCreatedCount++;
        nftId = _createToken(0, 0, 0, _gene, _owner);
    }

    /// @dev Creates a new gen0 horse with the given genes and
    ///  creates an auction for it.
    function createGen0Auction(uint256 _gene) external onlyCTO {
        require(gen0CreatedCount < GEN0_CREATION_LIMIT);
        // require(gasleft() >= 400000, "Insufficient gas");

        uint256 nftId = _createToken(0, 0, 0, _gene, address(this));
    
        saleAuction.createAuction(
            nftId,
            _computeNextGen0Price(),
            0,
            GEN0_AUCTION_DURATION,
            address(this)
        );

        gen0CreatedCount++;
    }

    /// @dev Computes the next gen0 auction starting price, given
    ///  the average of the past 5 prices + 50%.
    function _computeNextGen0Price() internal view returns (uint256) {
        uint256 avePrice = saleAuction.averageGen0SalePrice();

        // Sanity check to ensure we don't overflow arithmetic
        require(avePrice == uint256(uint128(avePrice)));

        uint256 nextPrice = avePrice + (avePrice / 2);

        // We never auction for less than starting price
        if (nextPrice < GEN0_STARTING_PRICE) {
            nextPrice = GEN0_STARTING_PRICE;
        }

        return nextPrice;
    }
}

// File: /home/moncy/projects/planetpegasus/planet-pegasus-smart-contracts/contracts/modules/Modules.sol

// import "./ClockAuction.sol";
// import "./GeneScienceInterface.sol";
// import "./AccessControl.sol"; in Ownership.sol
// import "./Base.sol";
// import "./MiddleWare.sol";
// import "./Ownership.sol";
// import "./ERC721.sol";


contract Modules {}

// File: contracts/Core.sol

contract Core is Minting {

    // This is the main contract. In order to keep our code seperated into logical sections,
    // we've broken it up in two ways. First, we have several seperately-instantiated sibling contracts
    // that handle auctions and our super-top-secret genetic combination algorithm. The auctions are
    // seperate since their logic is somewhat complex and there's always a risk of subtle bugs. By keeping
    // them in their own contracts, we can upgrade them without disrupting the main contract that tracks
    // horsey ownership. The genetic combination algorithm is kept seperate so we can open-source all of
    // the rest of our code without making it _too_ easy for folks to figure out how the genetics work.
    // Don't worry, I'm sure someone will reverse engineer it soon enough!
    //
    // Secondly, we break the core contract into multiple files using inheritence, one for each major
    // facet of functionality of DBC. This allows us to keep related code bundled together while still
    // avoiding a single giant file with everything in it. The breakdown is as follows:
    //
    //      - Base: This is where we define the most fundamental code shared throughout the core
    //             functionality. This includes our main data storage, constants and data types, plus
    //             internal functions for managing these items.
    //
    //      - AccessControl: This contract manages the various addresses and constraints for operations
    //             that can be executed only by specific roles. Namely CEO, CFO and COO.
    //
    //      - Ownership: This provides the methods required for basic non-fungible token
    //             transactions, following the draft ERC-721 spec (https://github.com/ethereum/EIPs/issues/721).
    //
    //      - Breeding: This file contains the methods necessary to breed horses together, including
    //             keeping track of siring offers, and relies on an external genetic combination contract.
    //
    //      - Auction: Here we have the public methods for auctioning or bidding on horses or siring
    //             services. The actual auction functionality is handled in two sibling contracts (one
    //             for sales and one for siring), while auction creation and bidding is mostly mediated
    //             through this facet of the core contract.
    //
    //      - Minting: This final facet contains the functionality we use for creating new gen0 horses.
    //             We can make up to 5000 "promo" horses that can be given away (especially important when
    //             the community is new), and all others can only be created and then immediately put up
    //             for auction via an algorithmically determined starting price. Regardless of how they
    //             are created, there is a hard limit of 50k gen0 horses. After that, it's all up to the
    //             community to breed, breed, breed!

    // Set in case the core contract is broken and an upgrade is required
    address public newContractAddress;

    /// @notice Creates the main smart contract instance.
    constructor() public
        Base("PlanetPegasus", "PEGASUS")
    {

        // Starts paused.
        paused = true;

        // the creator is also the CTO
        ctoAddress = msg.sender;

        // start with the zero nft (ID 0) - so we don't have generation-0 parent issues
        _createToken(0, 0, 0, uint256(-1), address(0));

        // saleAuction = new SaleClockAuction(address(this));
    }

    // function deploySaleAuction() external onlyCTO {
    //     saleAuction = new SaleClockAuction(address(this), ctoAddress);
    //     setApprovalForAll(saleAuction, true);
    // }

    // function deploySiringAuction() external onlyCTO {
    //     siringAuction = new SiringClockAuction(address(this), ctoAddress);
    // }

    /// @dev Used to mark the smart contract as upgraded, in case there is a serious
    ///  breaking bug. This method does nothing but keep track of the new contract and
    ///  emit a message indicating that the new address is set. It's up to clients of this
    ///  contract to update to the new contract address in that case. (This contract will
    ///  be paused indefinitely if such an upgrade takes place.)
    /// @param _v2Address new address
    function setNewAddress(address _v2Address) external onlyCEO whenPaused {
        // See README.md for updgrade plan
        newContractAddress = _v2Address;
        emit ContractUpgrade(_v2Address);
    }

    /// @notice No tipping!
    /// @dev Reject all Ether from being sent here, unless it's from one of the
    ///  two auction contracts. (Hopefully, we can prevent user accidents.)
    function() external payable {
        require(
            msg.sender == address(saleAuction) ||
            msg.sender == address(siringAuction)
        );
    }

    /// @notice Returns all the relevant information about a specific horse.
    /// @param _id The ID of the horse of interest.
    function getNFT(uint256 _id)
        external
        view
        returns (
        bool isGestating,
        bool isReady,
        uint256 cooldownIndex,
        uint256 nextActionAt,
        uint256 siringWithId,
        uint256 birthTime,
        uint256 matronId,
        uint256 sireId,
        uint256 generation,
        uint256 gene
    ) {

        NFT storage _nft = collection[_id];

        // if this variable is 0 then it's not gestating
        isGestating = (_nft.siringWithId != 0);
        isReady = (_nft.cooldownEndBlock <= block.number);
        cooldownIndex = uint256(_nft.cooldownIndex);
        nextActionAt = uint256(_nft.cooldownEndBlock);
        siringWithId = uint256(_nft.siringWithId);
        birthTime = uint256(_nft.birthTime);
        matronId = uint256(_nft.matronId);
        sireId = uint256(_nft.sireId);
        generation = uint256(_nft.generation);
        gene = _nft.gene;
    }

    /// @dev Override unpause so it requires all external contract addresses
    ///  to be set before contract can be unpaused. Also, we can't have
    ///  newContractAddress set either, because then the contract was upgraded.
    /// @notice This is public rather than external so we can call super.unpause
    ///  without using an expensive CALL.
    function unpause() public onlyCEO whenPaused {
        require(saleAuction != address(0));
        require(siringAuction != address(0));
        require(geneScience != address(0));
        require(newContractAddress == address(0));

        // Actually unpause the contract.
        super.unpause();
    }

    // @dev Allows the CFO to capture the balance available to the contract.
    function withdrawBalance() external onlyCFO {
        uint256 balance = address(this).balance;
        // Subtract all the currently pregnant horses we have, plus 1 of margin.
        uint256 subtractFees = (pregnantTokens + 1) * autoBirthFee;

        if (balance > subtractFees) {
            cfoAddress.transfer(balance - subtractFees);
        }
    }
}
