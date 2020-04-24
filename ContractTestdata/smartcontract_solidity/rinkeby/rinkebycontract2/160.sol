/**
 *Submitted for verification at Etherscan.io on 2019-08-06
*/

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP. Does not include
 * the optional functions; to access them see `ERC20Detailed`.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

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

// File: openzeppelin-solidity/contracts/introspection/IERC165.sol

pragma solidity ^0.5.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * [EIP](https://eips.ethereum.org/EIPS/eip-165).
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others (`ERC165Checker`).
 *
 * For an implementation, see `ERC165`.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * [EIP section](https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified)
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: openzeppelin-solidity/contracts/token/ERC721/IERC721.sol

pragma solidity ^0.5.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
contract IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of NFTs in `owner`'s account.
     */
    function balanceOf(address owner) public view returns (uint256 balance);

    /**
     * @dev Returns the owner of the NFT specified by `tokenId`.
     */
    function ownerOf(uint256 tokenId) public view returns (address owner);

    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * 
     *
     * Requirements:
     * - `from`, `to` cannot be zero.
     * - `tokenId` must be owned by `from`.
     * - If the caller is not `from`, it must be have been allowed to move this
     * NFT by either `approve` or `setApproveForAll`.
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public;
    /**
     * @dev Transfers a specific NFT (`tokenId`) from one account (`from`) to
     * another (`to`).
     *
     * Requirements:
     * - If the caller is not `from`, it must be approved to move this NFT by
     * either `approve` or `setApproveForAll`.
     */
    function transferFrom(address from, address to, uint256 tokenId) public;
    function approve(address to, uint256 tokenId) public;
    function getApproved(uint256 tokenId) public view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) public;
    function isApprovedForAll(address owner, address operator) public view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

// File: contracts/exchange/TokenExchange.sol

pragma solidity 0.5.7;





contract TokenExchange {
    using SafeMath for uint;

    enum Type { ERC20, ERC721 }
    enum Status { _, ACTIVE, CLOSED, CANCELLED }

    struct Listing {
        address token;
        uint256 price;
        uint256 amount;
        uint256 tokenId;
        address payable seller;
        address buyer;
        Type tokenType;
        Status status;
    }

    Listing[] private _listings;

    mapping(address => uint256[] ) private _userVsListings;

    mapping(uint256 => uint256) private idVersusIndex;

    event Added(uint256 indexed id);

    event Closed(uint256 indexed id, address indexed buyer);

    event Cancelled(uint256 indexed id);

    modifier onlySeller(uint256 id) {
        uint256 index = idVersusIndex[id].sub(1);
        require(
            _listings[index].seller == msg.sender,
            "Only sender can call this method!!"
        );
        _;
    }

    function getListing(
        uint256 id
    )
        external
        view
        returns(
            address,
            uint256,
            uint256,
            uint256,
            address,
            address,
            Type,
            Status
        )
    {
        if (_listings.length > 0 && _listings.length >= idVersusIndex[id]) {
            uint256 index = idVersusIndex[id].sub(1);

            Listing memory listing = _listings[index];

            return(
                listing.token,
                listing.price,
                listing.amount,
                listing.tokenId,
                listing.seller,
                listing.buyer,
                listing.tokenType,
                listing.status
            );
        }

    }

    function totalListings() external view returns(uint256) {
        return _listings.length;
    }

    function getUserListings(
        address user
    )
        external
        view
        returns(uint256[] memory)
    {
        return _userVsListings[user];
    }

    function getListingForUser(
        address user,
        uint256 index
    )
        external
        view
        returns(
            address,
            uint256,
            uint256,
            uint256,
            address,
            address,
            Type,
            Status
        )
    {
        require(
            _userVsListings[user].length > index,
            "Listing does not exist!!"
        );
        Listing memory listing = _listings[_userVsListings[user][index]];
        return(
                listing.token,
                listing.price,
                listing.amount,
                listing.tokenId,
                listing.seller,
                listing.buyer,
                listing.tokenType,
                listing.status
        );
    }

    function addListing(
        uint256 listingId,
        address token,
        uint256 price,
        uint256 amount,
        uint256 tokenId,
        Type tokenType
    )
        external
    {
        require(token != address(0), "Invalid token address!!");
        require(
            amount > 0 || tokenType == Type.ERC721,
            "Inavlid amount!!"
        );

        require(
            idVersusIndex[listingId] > 0,
            "Listing already exist!!"
        );

        Listing memory listing = Listing({
            token: token,
            price: price,
            amount: amount,
            tokenId: tokenId,
            seller: msg.sender,
            buyer: address(0),
            tokenType: tokenType,
            status: Status.ACTIVE
        });

        _listings.push(listing);
        uint256 index = _listings.length;
        _userVsListings[msg.sender].push(index.sub(1));
        idVersusIndex[listingId] = index;

        receiveTokens(
            token,
            amount,
            tokenId,
            tokenType
        );
        emit Added(listingId);
    }

    function buyListing(uint256 id) external payable {
        uint256 index = idVersusIndex[id].sub(1);

        Listing storage listing = _listings[index];

        require(listing.status == Status.ACTIVE, "Listing not active!!");
        require(msg.value == listing.price, "Invalid amount!!");
        require(
            listing.seller != msg.sender,
            "Can not purchase your own listing!!"
        );

        listing.status = Status.CLOSED;
        listing.buyer = msg.sender;

        listing.seller.transfer(listing.price);

        sendTokens(
            listing.token,
            listing.amount,
            listing.tokenId,
            listing.tokenType,
            listing.buyer
        );

        emit Closed(id, msg.sender);
    }

    function cancelListing(uint256 id) external onlySeller(id) {
        uint256 index = idVersusIndex[id].sub(1);

        Listing storage listing = _listings[index];

        require(listing.status == Status.ACTIVE, "Listing not active!!");

        listing.status = Status.CANCELLED;

        sendTokens(
            listing.token,
            listing.amount,
            listing.tokenId,
            listing.tokenType,
            listing.seller
        );

        emit Cancelled(id);

    }

    function receiveTokens(
        address token,
        uint256 amount,
        uint256 tokenId,
        Type tokenType
    )
        private
    {
        if (tokenType == Type.ERC20) {
            IERC20(token).transferFrom(msg.sender, address(this), amount);
        }
        else{
            IERC721(token).transferFrom(msg.sender, address(this), tokenId);
        }
    }

    function sendTokens(
        address token,
        uint256 amount,
        uint256 tokenId,
        Type tokenType,
        address receiver
    )
        private
    {
        if (tokenType == Type.ERC20) {
            IERC20(token).transfer(receiver, amount);
        }
        else{
            IERC721(token).transferFrom(address(this), receiver, tokenId);
        }
    }
}
