/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

// File: contracts/commons/Ownable.sol

pragma solidity ^0.5.10;


contract Ownable {
    address internal _owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    modifier onlyOwner() {
        require(msg.sender == _owner, "The owner should be the sender");
        _;
    }

    constructor() public {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0x0), msg.sender);
    }

    function owner() external view returns (address) {
        return _owner;
    }

    /**
        @dev Transfers the ownership of the contract.
        @param _newOwner Address of the new owner
    */
    function transferOwnership(address _newOwner) external onlyOwner {
        require(_newOwner != address(0), "0x0 Is not a valid owner");
        emit OwnershipTransferred(_owner, _newOwner);
        _owner = _newOwner;
    }
}

// File: contracts/commons/SortedListDelegate.sol

pragma solidity 0.5.10;

/**
 * @title SortedListDelegate
 * @author Joaquin Gonzalez ([email protected])
 * @dev Delegate for SortedList can know node value.
 */
interface SortedListDelegate {
    
    /**
     * @dev Get node value
     * @param _id node_id
     * @return uint256 the node value
     */
    function getValue(uint256 _id) external view returns (uint256);
}

// File: contracts/commons/SortedList.sol

pragma solidity 0.5.10;



/**
 * @title SortedList
 * @author Joaquin Gonzalez ([email protected])
 * @dev An utility library for using sorted list data structures.
 */
library SortedList {

    uint256 private constant NULL = 0;
    uint256 private constant HEAD = 0;

    bool private constant LEFT = false;
    bool private constant RIGHT = true;

    struct List {
        // node_id => prev or next => node_id
        mapping(uint256 => mapping(bool => uint256)) list;
    }

    /**
     * @dev Checks if the node exists
     * @param self stored linked list from contract
     * @param _node a node to search for
     * @return bool true if node exists, false otherwise
     */
    function exists(List storage self, uint256 _node) internal view returns (bool) {
        if (self.list[_node][LEFT] == HEAD && self.list[_node][RIGHT] == HEAD) {
            return (self.list[HEAD][RIGHT] == _node);
        } 
        return true;
    }

    /**
     * @dev Returns the number of elements in the list
     * @param self stored linked list from contract
     * @return uint256
     */
    function sizeOf(List storage self) internal view returns (uint256) {
        uint256 total;
        (, uint256 i) = getAdjacent(self, HEAD);
        while (i != HEAD) {
            (, i) = getAdjacent(self, i);
            total++;
        }
        return total;
    }

    /**
     * @dev Returns the links of a node as a tuple
     * @param self stored linked list from contract
     * @param _node id of the node to get
     * @return bool, uint256, uint256 true if node exists or false otherwise, previous node, next node
     */
    function getNode(List storage self, uint256 _node) internal view returns (bool, uint256, uint256) {
        
        if (!exists(self, _node)) {
            return (false, 0, 0);
        } 
        return (true, self.list[_node][LEFT], self.list[_node][RIGHT]);
    
    }

    /**
     * @dev Returns the link of a node `_node` in direction `RIGHT`.
     * @param self stored linked list from contract
     * @param _node id of the node to step from
     * @return bool, uint256 true if node exists or false otherwise, next node
     */
    function getNextNode(List storage self, uint256 _node) internal view returns (bool, uint256) {
        return getAdjacent(self, _node);
    }

    /**
     * @dev Returns the link of a node `_node` in direction `_direction`.
     * @param self stored linked list from contract
     * @param _node id of the node to step from
     * @return bool, uint256 true if node exists or false otherwise, node in _direction
     */
    function getAdjacent(List storage self, uint256 _node) internal view returns (bool, uint256) {
        if (exists(self, _node)) {
            return (true, self.list[_node][RIGHT]);
        }
        return (false, 0);

    }

    /**
     * @dev Creates a bidirectional link between two nodes on direction `_direction` (LEFT or RIGHT)
     * @param self stored linked list from contract
     * @param _node first node for linking
     * @param _link  node to link to in the _direction
     */
    function createLink(List storage self, uint256 _node, uint256 _link, bool _direction) internal {
        self.list[_link][!_direction] = _node;
        self.list[_node][_direction] = _link;
    }

    /**
     * @dev Insert node `_node`
     * @param self stored linked list from contract
     * @param _node  new node to insert
     * @return bool true if success, false otherwise
     */
    function insert(List storage self, uint256 _node, address _delegate) internal returns (bool) {

        uint256 position = getPosition(self, _node, _delegate);
        if (exists(self, _node) && !exists(self, position)) {
            return false;
        }

        uint256 c = self.list[position][LEFT];
        createLink(self, position, _node, LEFT);
        createLink(self, _node, c, LEFT);
        return true;
        
    }

    /**
     * @dev Get the node position to add.
     * @param self stored linked list from contract
     * @param _node value to seek
     * @param _delegate the delagete instance
     * @return uint256 next node with a value less than _node
     */
    function getPosition(List storage self, uint256 _node, address _delegate) internal view returns (uint256) {
        
        (, uint256 next) = getAdjacent(self, HEAD);
        while (next != 0 && SortedListDelegate(_delegate).getValue(_node) > SortedListDelegate(_delegate).getValue(next)) {
            next = self.list[next][RIGHT];
        }
        return next;

    }

    /**
     * @dev Get node value given position
     * @param self stored linked list from contract
     * @param _position node position to consult
     * @param _delegate the delagete instance
     * @return uint256 the node value
     */
    function getValue(List storage self, uint256 _position, address _delegate) internal view returns (uint256) {
        
        (, uint256 next) = getAdjacent(self, HEAD);
        for (uint256 i = 0; i < _position; i++) {
            next = self.list[next][RIGHT];
        }

        return SortedListDelegate(_delegate).getValue(next);
    }

    /**
     * @dev Removes an entry from the sorted list
     * @param self stored linked list from contract
     * @param _node node to remove from the list
     * @return uint256 the removed node
     */
    function remove(List storage self, uint256 _node) internal returns (uint256) {
        if (_node == NULL || !exists(self, _node)) {
            return 0;
        }
        createLink(self, self.list[_node][LEFT], self.list[_node][RIGHT], RIGHT);
        delete self.list[_node][LEFT];
        delete self.list[_node][RIGHT];
        return _node;
    }

    /**
     * @dev Get median beetween entry from the sorted list
     * @param self stored linked list from contract
     * @param _delegate the delagete instance
     * @return uint256 the median
     */
    function median(List storage self, address _delegate) internal view returns (uint256) {

        uint256 elements = sizeOf(self);
        if (elements % 2 == 0) {
            uint256 sum = getValue(self, elements / 2, _delegate) + getValue(self, elements / 2 - 1, _delegate);
            return sum / 2;
        } else {
            return getValue(self, elements / 2, _delegate);
        } 

    }

}

// File: contracts/commons/SortedStructList.sol

pragma solidity 0.5.10;




contract SortedStructList is SortedListDelegate {
    using SortedList for SortedList.List;

    struct Node {
        uint256 value;
    }

    mapping(uint256 => Node) internal nodes;
    SortedList.List private list;
    uint256 public id = 0;

    event AddNode(uint256 _id);
    event RemoveNode(uint256 _id);

    function newNode(address, uint256 _value) external returns (uint256) {
        id = id + 1;
        nodes[id] = Node(_value);
        return id;
    }
    
    function getValue(uint256 _id) external view returns (uint256) {
        return nodes[_id].value;
    }

    function exists(uint256 _id) external view returns (bool) {
        return list.exists(_id);
    }

    function sizeOf() external view returns (uint256) {
        return list.sizeOf();
    }

    function insert(uint256 _id) external {
        if (list.insert(_id, address(this))) {
            emit AddNode(_id);
        }
    }

    function getNode(uint256 _id) external view returns (bool, uint256, uint256) {
        return list.getNode(_id);
    }

    function getNextNode(uint256 _id) external view returns (bool, uint256) {
        return list.getNextNode(_id);
    }

    function remove(uint256 _id) public returns (uint256) {
        uint256 result = list.remove(_id);
        if (result > 0) {
            emit RemoveNode(_id);
        }
        return result;
    }

    function median() external view returns (uint256) {
        return list.median(address(this));
    }

}

// File: contracts/interfaces/RateOracle.sol

pragma solidity ^0.5.10;


/**
    @dev Defines the interface of a standard Diaspore RCN Oracle,
    The contract should also implement it's ERC165 interface: 0xa265d8e0
    @notice Each oracle can only support one currency
    @author Agustin Aguilar
*/
contract RateOracle {
    uint256 public constant VERSION = 5;
    bytes4 internal constant RATE_ORACLE_INTERFACE = 0xa265d8e0;

    /**
        3 or 4 letters symbol of the currency, Ej: ETH
    */
    function symbol() external view returns (string memory);

    /**
        Descriptive name of the currency, Ej: Ethereum
    */
    function name() external view returns (string memory);

    /**
        The number of decimals of the currency represented by this Oracle,
            it should be the most common number of decimal places
    */
    function decimals() external view returns (uint256);

    /**
        The base token on which the sample is returned
            should be the RCN Token address.
    */
    function token() external view returns (address);

    /**
        The currency symbol encoded on a UTF-8 Hex
    */
    function currency() external view returns (bytes32);

    /**
        The name of the Individual or Company in charge of this Oracle
    */
    function maintainer() external view returns (string memory);

    /**
        Returns the url where the oracle exposes a valid "oracleData" if needed
    */
    function url() external view returns (string memory);

    /**
        Returns a sample on how many token() are equals to how many currency()
    */
    function readSample(bytes calldata _data) external view returns (uint256 _tokens, uint256 _equivalent);
}

// File: contracts/MultiSourceOracle.sol

pragma solidity ^0.5.10;





contract MultiSourceOracle is SortedStructList, RateOracle, Ownable {

    event SetName(string _prev, string _new);
    event SetMaintainer(string _prev, string _new);

    uint256 public constant BASE = 10 ** 18;


    mapping(address => uint256) private signers;

    mapping(address => bool) public isSigner;

    string private isymbol;
    string private iname;
    uint256 private idecimals;
    address private itoken;
    bytes32 private icurrency;
    string private imaintainer;

    constructor(
        string memory _symbol,
        string memory _name,
        uint256 _decimals,
        address _token,
        bytes32 _currency,
        string memory _maintainer
    ) public {
        isymbol = _symbol;
        iname = _name;
        idecimals = _decimals;
        itoken = _token;
        icurrency = _currency;
        imaintainer = _maintainer;
        emit SetName("", _name);
        emit SetMaintainer("", _maintainer);
    }

    function readSample(bytes calldata) external view returns (uint256, uint256) {
        return _readSample();
    }

    function readSample() external view returns (uint256, uint256) {
        return _readSample();
    }

    function symbol() external view returns (string memory) {
        return isymbol;
    }

    function name() external view returns (string memory) {
        return iname;
    }

    function decimals() external view returns (uint256) {
        return idecimals;
    }

    function token() external view returns (address) {
        return itoken;
    }

    function currency() external view returns (bytes32) {
        return icurrency;
    }

    function maintainer() external view returns (string memory) {
        return imaintainer;
    }

    function url() external view returns (string memory) {
        return "";
    }

    function getProvided(address _addr) external view returns (
        uint256 _rate,
        uint256 _index
    ) {

        uint256 id = signers[_addr];
        Node memory node = nodes[id];
        return (node.value, id);
    }

    function setName(string calldata _name) external onlyOwner {
        emit SetName(iname, _name);
        iname = _name;
    }

    function setMaintainer(string calldata _maintainer) external onlyOwner {
        emit SetMaintainer(imaintainer, _maintainer);
        imaintainer = _maintainer;
    }

    function addSigner(address _signer) external onlyOwner {
        require(!isSigner[_signer], "signer already defined");
        isSigner[_signer] = true;
    }

    function removeSigner(address _signer) external onlyOwner {

        isSigner[_signer] = false;
        this.remove(signers[_signer]);
        signers[_signer] = 0;

    }

    function provide(address _signer, uint256 _rate) external onlyOwner {

        require(isSigner[_signer], "signer not valid");
        require(_rate > 0, "rate can't be zero");
        require(_rate < uint96(uint256(-1)), "rate too high");
        
        uint256 id = this.newNode(_signer, _rate);
        signers[_signer] = id;
        this.insert(id);

    }

    function _readSample() private view returns (uint256 _tokens, uint256 _equivalent) {
        // Tokens is always base
        _tokens = BASE;
        _equivalent = this.median();
    }
}

// File: contracts/utils/StringUtils.sol

pragma solidity ^0.5.10;


library StringUtils {
    function concat(string memory _a, string memory _b) internal pure returns (string memory) {
        return string(abi.encodePacked(_a, _b));
    }

    function toBytes32(string memory _a) internal pure returns (bytes32 b) {
        require(bytes(_a).length <= 32, "string too long");

        assembly {
            let bi := mul(mload(_a), 8)
            b := and(mload(add(_a, 32)), shl(sub(256, bi), sub(exp(2, bi), 1)))
        }
    }

    function fromBytes32(bytes32 _b) internal pure returns (string memory o) {
        assembly {
            let mask := shl(248, 0xff)
            let s := 0

            for { } lt(s, 256) { s := add(s, 8) } {
                if iszero(and(mask, shl(s, _b))) {
                    break
                }
            }

            mstore(o, div(s, 8))
            mstore(add(o, 32), _b)
        }
    }

    function toString(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }

        uint256 i = _i;
        uint256 j = i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }

        bytes memory bstr = new bytes(len);
        uint256 k = len - 1;
        while (i != 0) {
            bstr[k--] = byte(uint8(48 + i % 10));
            i /= 10;
        }

        return string(bstr);
    }
}

// File: contracts/OracleFactory.sol

pragma solidity ^0.5.10;





contract OracleFactory is Ownable {
    using StringUtils for string;

    mapping(string => address) public symbolToOracle;
    mapping(address => string) public oracleToSymbol;

    event NewOracle(string _symbol, address _oracle);
    event AddSigner(address _oracle, address _signer);
    event RemoveSigner(address _oracle, address _signer);
    event Provide(address _oracle, address _signer, uint256 _rate);

    function newOracle(
        string calldata _symbol,
        string calldata _name,
        uint256 _decimals,
        address _token,
        string calldata _maintainer
    ) external onlyOwner {
        // Create oracle contract
        MultiSourceOracle oracle = new MultiSourceOracle(
            _symbol,
            _name,
            _decimals,
            _token,
            _symbol.toBytes32(),
            _maintainer
        );

        // Save Oracle in registry
        symbolToOracle[_symbol] = address(oracle);
        oracleToSymbol[address(oracle)] = _symbol;
        // Emit events
        emit NewOracle(_symbol, address(oracle));
    }

    function addSigner(address _oracle, address _signer) external onlyOwner {
        MultiSourceOracle(_oracle).addSigner(_signer);
        emit AddSigner(_oracle, _signer);
    }

    function removeSigner(address _oracle, address _signer) external onlyOwner {
        MultiSourceOracle(_oracle).removeSigner(_signer);
        emit RemoveSigner(_oracle, _signer);
    }

    function setName(address _oracle, string calldata _name) external onlyOwner {
        MultiSourceOracle(_oracle).setName(_name);
    }

    function setMaintainer(address _oracle, string calldata _maintainer) external onlyOwner {
        MultiSourceOracle(_oracle).setMaintainer(_maintainer);
    }

    function provide(address _oracle, uint256 _rate) external {
        MultiSourceOracle(_oracle).provide(msg.sender, _rate);
        emit Provide(_oracle, msg.sender, _rate);
    }

}
