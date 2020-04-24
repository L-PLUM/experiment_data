/**
 *Submitted for verification at Etherscan.io on 2019-07-25
*/

pragma solidity ^0.5.0;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be aplied to your functions to restrict their use to
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
     * > Note: Renouncing ownership will leave the contract without an owner,
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

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

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

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @dev Implementation of the `IERC20` interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using `_mint`.
 * For a generic mechanism see `ERC20Mintable`.
 *
 * *For a detailed writeup see our guide [How to implement supply
 * mechanisms](https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226).*
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an `Approval` event is emitted on calls to `transferFrom`.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard `decreaseAllowance` and `increaseAllowance`
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See `IERC20.approve`.
 */
contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    /**
     * @dev See `IERC20.totalSupply`.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IERC20.balanceOf`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See `IERC20.transfer`.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See `IERC20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `ERC20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     /**
     * @dev Destoys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See `_burn` and `_approve`.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}

// File: openzeppelin-solidity/contracts/introspection/IERC165.sol

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

// File: openzeppelin-solidity/contracts/token/ERC721/IERC721Receiver.sol

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
contract IERC721Receiver {
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
    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);
}

// File: openzeppelin-solidity/contracts/utils/Address.sol

/**
 * @dev Collection of functions related to the address type,
 */
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

// File: openzeppelin-solidity/contracts/drafts/Counters.sol

/**
 * @title Counters
 * @author Matt Condon (@shrugs)
 * @dev Provides counters that can only be incremented or decremented by one. This can be used e.g. to track the number
 * of elements in a mapping, issuing ERC721 ids, or counting request ids.
 *
 * Include with `using Counters for Counters.Counter;`
 * Since it is not possible to overflow a 256 bit integer with increments of one, `increment` can skip the SafeMath
 * overflow check, thereby saving gas. This does assume however correct usage, in that the underlying `_value` is never
 * directly accessed.
 */
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

// File: openzeppelin-solidity/contracts/introspection/ERC165.sol

/**
 * @dev Implementation of the `IERC165` interface.
 *
 * Contracts may inherit from this and call `_registerInterface` to declare
 * their support of an interface.
 */
contract ERC165 is IERC165 {
    /*
     * bytes4(keccak256('supportsInterface(bytes4)')) == 0x01ffc9a7
     */
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    /**
     * @dev Mapping of interface ids to whether or not it's supported.
     */
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        // Derived contracts need only register support for their own interfaces,
        // we register support for ERC165 itself here
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    /**
     * @dev See `IERC165.supportsInterface`.
     *
     * Time complexity O(1), guaranteed to always use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
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
        _supportedInterfaces[interfaceId] = true;
    }
}

// File: openzeppelin-solidity/contracts/token/ERC721/ERC721.sol

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract ERC721 is ERC165, IERC721 {
    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    // Mapping from token ID to owner
    mapping (uint256 => address) private _tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private _tokenApprovals;

    // Mapping from owner to number of owned token
    mapping (address => Counters.Counter) private _ownedTokensCount;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

    /*
     *     bytes4(keccak256('balanceOf(address)')) == 0x70a08231
     *     bytes4(keccak256('ownerOf(uint256)')) == 0x6352211e
     *     bytes4(keccak256('approve(address,uint256)')) == 0x095ea7b3
     *     bytes4(keccak256('getApproved(uint256)')) == 0x081812fc
     *     bytes4(keccak256('setApprovalForAll(address,bool)')) == 0xa22cb465
     *     bytes4(keccak256('isApprovedForAll(address,address)')) == 0xe985e9c
     *     bytes4(keccak256('transferFrom(address,address,uint256)')) == 0x23b872dd
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256)')) == 0x42842e0e
     *     bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)')) == 0xb88d4fde
     *
     *     => 0x70a08231 ^ 0x6352211e ^ 0x095ea7b3 ^ 0x081812fc ^
     *        0xa22cb465 ^ 0xe985e9c ^ 0x23b872dd ^ 0x42842e0e ^ 0xb88d4fde == 0x80ac58cd
     */
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor () public {
        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    /**
     * @dev Gets the balance of the specified address.
     * @param owner address to query the balance of
     * @return uint256 representing the amount owned by the passed address
     */
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");

        return _ownedTokensCount[owner].current();
    }

    /**
     * @dev Gets the owner of the specified token ID.
     * @param tokenId uint256 ID of the token to query the owner of
     * @return address currently marked as the owner of the given token ID
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _tokenOwner[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");

        return owner;
    }

    /**
     * @dev Approves another address to transfer the given token ID
     * The zero address indicates there is no approved address.
     * There can only be one approved address per token at a given time.
     * Can only be called by the token owner or an approved operator.
     * @param to address to be approved for the given token ID
     * @param tokenId uint256 ID of the token to be approved
     */
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
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
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    /**
     * @dev Sets or unsets the approval of a given operator
     * An operator is allowed to transfer all tokens of the sender on their behalf.
     * @param to operator address to set the approval
     * @param approved representing the status of the approval to be set
     */
    function setApprovalForAll(address to, bool approved) public {
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
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev Transfers the ownership of a given token ID to another address.
     * Usage of this method is discouraged, use `safeTransferFrom` whenever possible.
     * Requires the msg.sender to be the owner, approved, or operator.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function transferFrom(address from, address to, uint256 tokenId) public {
        //solhint-disable-next-line max-line-length
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transferFrom(from, to, tokenId);
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
     */
    function safeTransferFrom(address from, address to, uint256 tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
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
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {
        transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    /**
     * @dev Returns whether the specified token exists.
     * @param tokenId uint256 ID of the token to query the existence of
     * @return bool whether the token exists
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    /**
     * @dev Returns whether the given spender can transfer a given token ID.
     * @param spender address of the spender to query
     * @param tokenId uint256 ID of the token to be transferred
     * @return bool whether the msg.sender is approved for the given token ID,
     * is an operator of the owner, or is the owner of the token
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev Internal function to mint a new token.
     * Reverts if the given token ID already exists.
     * @param to The address that will own the minted token
     * @param tokenId uint256 ID of the token to be minted
     */
    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

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

        emit Transfer(owner, address(0), tokenId);
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * @param tokenId uint256 ID of the token being burned
     */
    function _burn(uint256 tokenId) internal {
        _burn(ownerOf(tokenId), tokenId);
    }

    /**
     * @dev Internal function to transfer ownership of a given token ID to another address.
     * As opposed to transferFrom, this imposes no restrictions on msg.sender.
     * @param from current owner of the token
     * @param to address to receive the ownership of the given token ID
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _transferFrom(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Internal function to invoke `onERC721Received` on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * This function is deprecated.
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
        internal returns (bool)
    {
        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    /**
     * @dev Private function to clear current approval of a given token ID.
     * @param tokenId uint256 ID of the token to be transferred
     */
    function _clearApproval(uint256 tokenId) private {
        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}

// File: openzeppelin-solidity/contracts/token/ERC721/IERC721Metadata.sol

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://eips.ethereum.org/EIPS/eip-721
 */
contract IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

// File: openzeppelin-solidity/contracts/token/ERC721/ERC721Metadata.sol

contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

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

    /**
     * @dev Constructor function
     */
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;

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
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    /**
     * @dev Internal function to set the token URI for a given token.
     * Reverts if the token ID does not exist.
     * @param tokenId uint256 ID of the token to set its URI
     * @param uri string URI to assign
     */
    function _setTokenURI(uint256 tokenId, string memory uri) internal {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = uri;
    }

    /**
     * @dev Internal function to burn a specific token.
     * Reverts if the token does not exist.
     * Deprecated, use _burn(uint256) instead.
     * @param owner owner of the token to burn
     * @param tokenId uint256 ID of the token being burned by the msg.sender
     */
    function _burn(address owner, uint256 tokenId) internal {
        super._burn(owner, tokenId);

        // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

// File: contracts/UnicoinRegistry.sol

pragma solidity^0.5.0;

/// @title UniCoin smart contract
/// @author Chris Maree, Helda Mandlate, Luke Meiklejohn 

/// @dev import contracts from openzeppelin related to ownable and ERC20, ERC721 tokens




/// @notice contract begins here
contract UnicoinRegistry is ERC721Metadata {
    /// @notice Creates a struct for users of the plaform, needs their Ethereum address and profile URL
    struct User {
        address owned_address;
        string profile_uri;
    }
    /// @notice Creates an array of users that a registered
    User[] public users;

    /// @notice The mapping below maps all users' addresses to their userID
    mapping (address => uint256) public userAddresses ;

    /// @notice Creates user defined type
    enum bidStatus {Pending, Accepted, Rejected, Sale, Cancelled}

    /// @notice Creates a struct for all bids, takes in the offer (amount of the bid), one of the enum parameters, publication Id and owner Id
    struct Bid {
        uint256 offer;
        bidStatus status;
        uint256 publication_Id;
        uint256 owner_Id; /// @dev owner of the bid
    }
    /// @notice Creates an array of bids that have been placed
    Bid[] public bids;

    /// @notice The mapping below maps all bidders' IDs to their userID
    mapping(uint256 => uint256[]) public bidOwners;

    /// @notice Creates a struct for all publications
    /// @param author_Id The array below will contain all bids received for that work
    /// @param publication_uri If the researcher has chosen the auction pricing structure, the below is TRUE.
    /// @param publication_bids If the auction is still running, the below is TRUE, because the researcher can choose to stop the auction at any point.
    /// @param isAuction If both of the booleans above are FALSE, the price below is the flat sale price of the work.
    /// @param isRunning The value of the publication
    /// @param sell_price The co-authors/ contributors of the publication
    /// @param contributors_weightings The contributor's respective weighting contributions
    struct Publication {
        uint256 author_Id;
        string publication_uri;
        uint256[] publication_bids;
        bool isAuction;
        bool isRunning;
        uint256 sell_price;
        uint256[] contributors;
        uint256[] contributors_weightings;
    }
    /// @notice Creates an array of publications for every published document
    Publication[] public publications;
    
    /// @notice The mapping below will map the addresses of all the successful bidders' addresses to the ID of their owned publications
    mapping(uint256 => uint256[]) public publicationOwners;
    
    /// @notice Creates a struct for licencing
    /// @param buyer_Id of each publication's buyer
    /// @param publication_Id of the publication being bought
    /// @param bid_Id The bid's Id for the publication    
    struct LicenceDesign {
        uint256 buyer_Id;
        uint256 publication_Id;
        uint256 bid_Id;
    }
    /// @notice Creates an array of purchased licences
    LicenceDesign[] public licences;
    /// @notice Mapping of licence Id to get the licence owners
    mapping(uint256 => uint256[]) public licenceOwners;
    /// @notice Mapping of licence Id to get the publication Id
    mapping(uint256 => uint256[]) public publicationLicences;

    event NewPublication(
        address indexed _from,
        string _publication_uri,
        bool _isAuction,
        uint256 _sell_price
    );

    event NewBid(
        address indexed _from,
        uint256 indexed _publication_Id,
        uint256 _offer
    );

    event AcceptedBid(
        address indexed _from,
        uint256 _id
    );

    event RejectedBid(
        address indexed _from,
        uint256 _id
    ); 

    event CancelledBid(
        address indexed _from,
        uint256 _id
    );

    event ChangeToSale(
        address indexed _from,
        uint256 indexed _publication_Id,
        uint256 _sell_price
    );   

    event ChangeToAuction(
        address indexed _from,
        uint256 indexed _publication_Id
    ); 

    event ChangeSellPrice(
        address indexed _from,
        uint256 indexed _publication_Id,
        uint256 _sell_price
    );

    event ChangeRunningStatus(
        address indexed _from,
        uint256 indexed _publication_Id,
        bool _isRunning
    );

    /// @dev ERC20 is now daiContract
    ERC20 daiContract;
    /// @dev The constructor below reserves user 0 for all unregistered users
    /// @param _daiContractAddress DAI contract address
    constructor(address _daiContractAddress) public ERC721Metadata("UniCoin Licence", "UNIC"){
        users.push(User(address(0), ""));
        licences.push(LicenceDesign(0, 0, 0));

        daiContract = ERC20(_daiContractAddress);
    }

    /// @notice This function registers a user on the platform by taking in their profile URL
    /// @param _profile_uri user profile url
    /// @dev If the user's address is in position 0 of the userAddresses array, they are unregistered
    /// @dev Create an instance of the user and add the Id to their address
    function registerUser(string memory _profile_uri) public {
        require(bytes(_profile_uri).length > 0, "Profile URI should not be empty.");
        require(userAddresses[msg.sender]==0,"User already registered.");
        uint256 id = users.push(User(msg.sender,_profile_uri));
        userAddresses[msg.sender] = id - 1;
    }

    /// @notice This function creates a publication on the system, with blank arrays for publication bids and owners,
    /// @notice since no one has bidded for or bought a licence yet
    /// @dev The researcher only specifies the flat rate if they have chosen not to auction the work
    /// @dev Add instance to the respective arrays

    function createPublication(
        string memory _publication_uri,
        bool _isAuction,
        bool _isRunning,
        uint256 _sell_price,
        uint256[] memory _contributors,
        uint256[] memory _contributors_weightings) public {
        require(bytes(_publication_uri).length > 0, "Publication URI should not be empty.");
        require(userAddresses[msg.sender] != 0, "User address is not registered.");
        if(_isAuction) {
            require(_sell_price == 0, "Should not specify sell price for auction.");
        }
        else {
            require(_sell_price > 0, "Sell price not specified.");
        }
        uint256 _author_Id = userAddresses[msg.sender];
        uint256[] memory _publication_bids;
        Publication memory _publication = Publication(
            _author_Id,
            _publication_uri,
            _publication_bids,
            _isAuction,
            _isRunning,
            _sell_price,
            _contributors,
            _contributors_weightings);
        uint256 _id = publications.push(_publication);
        publicationOwners[_author_Id].push(_id - 1);

        emit NewPublication(msg.sender,_publication_uri, _isAuction, _sell_price);
    }

    /// @notice This function creates a new bid for a particular publication
    /// @param _offer for the research
    /// @param _publication_Id is the index for the publication Id
    /// @dev The bidder should only be able to submit a bid if the publication's pricing structure is an auction and the auction is running
    /// @dev By default the bid will have a status of Pending until it is accepted or rejected by the author
    /// @dev If the author has specified a flat rate, the buyer doesn't submit a bid but just sends the funds.
    /// @dev The funds sent should match the sale price specified by the author.
    /// @dev This 'bid' has a status of sale because the author does not need to evaluate and accept/reject these bids.
    /// @dev Transfer Dai from buyer to seller
    /// @dev parameters of licence design: buyer_id, publication id, bid_id
    function makeBid(uint256 _offer, uint256 _publication_Id) public {
        require(publications[_publication_Id].author_Id != 0, "Publication not enlisted.");
        require(userAddresses[msg.sender] != 0, "Bidder address is not registered.");
        if(publications[_publication_Id].isAuction) {
            require(publications[_publication_Id].isRunning, "Auction is not running.");
            uint256 _id = bids.push(Bid(_offer, bidStatus.Pending, _publication_Id, userAddresses[msg.sender]));
            publications[_publication_Id].publication_bids.push(_id - 1);
            bidOwners[userAddresses[msg.sender]].push(_id - 1);
        }
        if(!publications[_publication_Id].isAuction) {
            require(_offer == publications[_publication_Id].sell_price, "Incorrect funds sent.");
            uint256 _id = bids.push(Bid(_offer, bidStatus.Sale, _publication_Id, userAddresses[msg.sender])) - 1;
            publications[_publication_Id].publication_bids.push(_id);
            bidOwners[userAddresses[msg.sender]].push(_id);

            require(daiContract.allowance(msg.sender, address(this)) >= _offer, "Insufficient fund allowance");
            address publisherAddress = users[publications[_publication_Id].author_Id].owned_address;
            require(daiContract.transferFrom(msg.sender, publisherAddress, _offer), "dai Transfer failed");

            uint256 _licence_Id = licences.push(LicenceDesign(bids[_id].owner_Id, _publication_Id, _id));
            licenceOwners[bids[_id].owner_Id].push(_licence_Id);
            publicationLicences[_publication_Id].push(_licence_Id);
            _mint(users[bids[_id].owner_Id].owned_address, _licence_Id);

            emit NewBid(msg.sender, _publication_Id, _offer);
        }
    }

    /// @notice This function allows the auctioneer to accept the bids
    /// @dev parameters of licence design: buyer_id, publication id, bid_id
    /// @notice This function allows the auctioneer to reject the bids
    /// @param _id is the bid Id
    function acceptBid(uint256 _id) public {
        uint256 _publication_Id = bids[_id].publication_Id;
        require(userAddresses[msg.sender] == publications[_publication_Id].author_Id, "User not the author of this publication");
        require(publications[_publication_Id].isAuction, "Publication not an auction.");
        require(publications[_publication_Id].isRunning, "Auction is not running.");
        bids[_id].status = bidStatus.Accepted;
        
        uint256 _licence_Id = licences.push(LicenceDesign(bids[_id].owner_Id, _publication_Id, _id));
        licenceOwners[bids[_id].owner_Id].push(_licence_Id);
        publicationLicences[_publication_Id].push(_licence_Id);
        _mint(users[bids[_id].owner_Id].owned_address, _licence_Id);

        emit AcceptedBid(msg.sender,_id);
    }

    /// @notice This function allows the auctioneer to reject the bids
    /// @param _id is the bid Id
    function rejectBid(uint256 _id) public {
        uint256 _publication_Id = bids[_id].publication_Id;
        require(userAddresses[msg.sender] == publications[_publication_Id].author_Id, "User not the author of this publication");
        require(publications[_publication_Id].isAuction, "Publication not an auction.");
        require(publications[_publication_Id].isRunning, "Auction not running.");
        bids[_id].status = bidStatus.Rejected;

        emit RejectedBid(msg.sender,_id);
    }

    /// @notice This function allows the auctioneer to cancel the bids
    /// @param _id is the bid Id
    function cancelBid(uint256 _id) public {
        uint256 _publication_Id = bids[_id].publication_Id;
        require(userAddresses[msg.sender] == publications[_publication_Id].author_Id
        || userAddresses[msg.sender] == bids[_id].owner_Id, "User not the author of this publication");
        require(publications[_publication_Id].isAuction, "Publication not an auction.");
        require(publications[_publication_Id].isRunning, "Auction not running.");
        bids[_id].status = bidStatus.Cancelled;

        emit CancelledBid(msg.sender,_id);
    }

    /// @notice This function allows the auctioneer to change from an auction to a sale
    /// @param _publication_Id publication id number
    /// @param _sell_price for the research
    function changeToSale(uint256 _publication_Id, uint256 _sell_price) public {
        require(userAddresses[msg.sender] == publications[_publication_Id].author_Id, "User not the author of this publication");
        require(publications[_publication_Id].isAuction, "Publication is not an auction");
        publications[_publication_Id].sell_price = _sell_price;
        publications[_publication_Id].isAuction = false;

        emit ChangeToSale(msg.sender, _publication_Id, _sell_price);
    }

    /// @notice This function allows the auctioneer to change from a sale to an auction
    /// @param _publication_Id publication id number
    function changeToAuction(uint256 _publication_Id) public {
        require(userAddresses[msg.sender] == publications[_publication_Id].author_Id, "User not the author of this publication");
        require(!publications[_publication_Id].isAuction, "Publication is already on auction");
        publications[_publication_Id].sell_price = 0;
        publications[_publication_Id].isAuction = true;

        emit ChangeToAuction(msg.sender, _publication_Id);        
    }
    
    /// @notice This function allows the auctioneer to change the sell price
    /// @param _publication_Id publication id number
    /// @param _sell_price for the research
    function changeSellPrice(uint256 _publication_Id, uint256 _sell_price) public {
        require(userAddresses[msg.sender] == publications[_publication_Id].author_Id, "User not the author of this publication");
        require(!publications[_publication_Id].isAuction, "Publication is on auction.");
        publications[_publication_Id].sell_price = _sell_price;

        emit ChangeSellPrice(msg.sender, _publication_Id, _sell_price);        

    }

    /// @notice This function allows the auctioneer to change the running status
    /// @param _publication_Id publication id number
    function changeRunningStatus(uint256 _publication_Id) public {
        require(userAddresses[msg.sender] == publications[_publication_Id].author_Id, "User not the author of this publication");
        publications[_publication_Id].isRunning = !publications[_publication_Id].isRunning;

        emit ChangeRunningStatus(msg.sender, _publication_Id, publications[_publication_Id].isRunning);        

    }

    /// @return This function allows anyone to get the list of publications based on the address of the publisher
    /// @param _address eth address for the user
    function getPublications(address _address) public view returns(uint256[] memory) {
        uint256 _author_Id = userAddresses[_address];
        return publicationOwners[_author_Id];
    }

    /// @return This function allows anyone to get the list of bids based on address of the user
    function getBids(address _address) public view returns(uint256[] memory) {
        uint256 _userAddress = userAddresses[_address];
        return bidOwners[_userAddress];
    }

    // From the user ID, get a list of all publications owned by the user ()
    // function getPublications(uint256 _user_Id) public view returns(uint256[] memory) {
    //     return publicationOwners[_user_Id];
    // }

    // function getBids(uint256 _user_Id) public view returns(uint256[] memory) {
    //     return bidOwners[_user_Id];
    // }

    /// @return This function allows anyone to get list of bids per publication
    /// @param _publication_Id publication id number
    function getPublicationBids(uint256 _publication_Id) public view returns(uint256[] memory) {
        return publications[_publication_Id].publication_bids;
    }

    /// @return This function allows the return of the total number of publications
    function getPublicationLength() public view returns(uint count) {
        return publications.length;
    }

    /// @return Returns information about a spesific publication ID
    /// @param _publication_Id publication id number
    function getPublication(uint256 _publication_Id) public view returns(
        uint256,
        string memory,
        uint256[] memory,
        bool,
        bool,
        uint256,
        uint256[] memory,
        uint256[] memory){
        Publication memory _publication = publications[_publication_Id];
        return (
        _publication.author_Id,
        _publication.publication_uri,
        _publication.publication_bids,
        _publication.isAuction,
        _publication.isRunning,
        _publication.sell_price,
        _publication.contributors,
        _publication.contributors_weightings);
    }

    /// @return get the licences per owner
    /// @param _address of the account holder
    function getLicenceForAddress(address _address) public view returns(uint256[] memory) {
        uint256 _userNumber = userAddresses[_address];
        return licenceOwners[_userNumber];
    }
    
    function getLicence(uint256 _licenceId) public view returns(uint256, uint256, uint256){
        LicenceDesign memory _licence = licences[_licenceId];
        return (
        _licence.buyer_Id,
        _licence.publication_Id,
        _licence.bid_Id);
    }

    /// @notice Donates funds to a research
    /// @param _publication_Id The id of the publication
    /// @param _value the amount that is being donated
    function donate(uint256 _publication_Id, uint256 _value) public {
        require(userAddresses[msg.sender] != 0, "User address is not registered.");
        require(daiContract.allowance(msg.sender, address(this)) >= _value, "Insufficient fund allowance");
        address publisherAddress = users[publications[_publication_Id].author_Id].owned_address;
        daiContract.transferFrom(msg.sender, publisherAddress, _value);
    }
}
