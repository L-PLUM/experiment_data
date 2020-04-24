/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^0.5.3;

//-----------------------------------------------------------------------------------------------
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "overflows");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "divder is zero.");
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "a is too small");
        uint256 c = a - b;
        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "overflows");
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "b is zero");
        return a % b;
    }
}
library ECDSA {
    /**
     * @dev Recover signer address from a message by using their signature
     * @param hash bytes32 message, the hash is the signed message. What is recovered is the signer address.
     * @param signature bytes signature, the signature is generated using web3.eth.sign()
     */
    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        // ecrecover takes the signature parameters, and the only way to get them
        // currently is to use assembly.
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        // Version of signature should be 27 or 28, but 0 and 1 are also possible versions
        if (v < 27) {
            v += 27;
        }

        // If the version is correct return the signer address
        if (v != 27 && v != 28) {
            return (address(0));
        } else {
            // solium-disable-next-line arg-overflow
            return ecrecover(hash, v, r, s);
        }
    }

    /**
     * toEthSignedMessageHash
     * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
     * and hash the result
     */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}
//-----------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------
contract _ERC20Interface {
    function totalSupply() public view returns (uint256);
    function balanceOf(address tokenOwner) public view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public returns (bool success);
    function approve(address spender, uint256 tokens) public returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) public returns (bool success);
}
contract _ERC20Mileage is _ERC20Interface {
    function mileage(address _to, uint256 tokens) public returns (bool success);
}
//-----------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------
interface _ERC721 {
    function balanceOf(address _owner) external view returns (uint256);
    function ownerOf(uint256 _tokenId) external view returns (address);
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
    function approve(address _approved, uint256 _tokenId) external payable;
    function setApprovalForAll(address _operator, bool _approved) external;

    function getApproved(uint256 _tokenId) external view returns (address);
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}
//-----------------------------------------------------------------------------------------------

contract _Proxy {
    using ECDSA for bytes32;
    mapping(bytes32=>bool) private _signatures;

    event PROXY(address indexed delegate, bytes32 _hash, address _token, uint256 _fee);
    function preProcess(address _signer, bytes memory _sig, bytes memory _hashedTx) internal view returns (bytes32) {
        bytes32 hash = keccak256(_sig);
        require(_signatures[hash] == false, "double spent");

        address from = keccak256(_hashedTx).toEthSignedMessageHash().recover(_sig);
        require(from == _signer, "signed error");

        return hash;
    }
    function postProcess(uint256 _value, bytes32 _hash) internal returns (bool) {
        if (_value > 0)
             msg.sender.transfer(_value);
        _signatures[_hash] = true;
        emit PROXY(msg.sender, _hash, address(0), _value);
        return true;
    }
    function postProcess(address _erc20, uint256 _value, bytes32 _hash) internal returns (bool) {
        if (_value > 0 )
            _ERC20Interface(_erc20).transfer(msg.sender, _value);
        _signatures[_hash] = true;
        emit PROXY(msg.sender, _hash, _erc20, _value);
        return true;
    }
}
//-----------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------
contract _IKeyCtrl {
    function keyset() external view returns (address[3] memory);
    function master() external view returns (address);
    function payment() external view returns (address);
    function proxy() external view returns (address);
}
//-----------------------------------------------------------------------------------------------
contract _IAccountFactory {
    function isAccount(address _account) external view returns (bool);
    function accountByUID(bytes32 _uid) external view returns (address);
    function newKey(address _key) external returns (bool);
    function updatePayment(address _key) external returns (bool);
}
//-----------------------------------------------------------------------------------------------
contract _IPayment {
    function confirmItem(uint256[2][] calldata _item) external payable returns (bool);
    function confirmItem20(uint256[2][] calldata _item) external payable returns (bool);
    function confirmData(bytes calldata _data) external payable returns (bool);
    function confirmData20(bytes calldata _data) external payable returns (bool);
}
//-----------------------------------------------------------------------------------------------

contract _Owner is _Proxy {
    address[4] internal  _links;

    uint8 constant _OWNER = 0;
    uint8 constant _ACCOUNT_FACTORY = 1;
    uint8 constant _STORE_FACTORY = 2;
    uint8 constant _HUB = 3;

    string constant ERR_NOT_MEMBER = "It's not member";
    string constant ERR_NOT_HUB = "It's not hub";

    constructor(address[4] memory _linkers) internal {
        _links = _linkers;
    }

    modifier onlyAccount(address who) {
        require(_IAccountFactory(_links[_ACCOUNT_FACTORY]).isAccount(who), "is not account");
        _;
    }
    modifier onlyOwnerMaster() {
        require(_IKeyCtrl(_links[_OWNER]).master()==msg.sender, "is not master");
        _;
    }
    modifier onlyOwnerPayment() {
        require(_IKeyCtrl(_links[_OWNER]).payment()==msg.sender, "is not payment");
        _;
    }
    modifier onlyOwnerProxy() {
        require(_IKeyCtrl(_links[_OWNER]).proxy()==msg.sender, "is not proxy");
        _;
    }

    function account() view public returns (address) {
        return _links[_OWNER];
    }

    //-------------------------------------------------------
    // ownership
    //-------------------------------------------------------
    function transfer(address _to, uint256[2] calldata _validate) external onlyOwnerPayment onlyAccount(_to) {
        _links[_OWNER] = _to;
    }
    function transfer(bytes calldata _sig, address _to, uint256[2] calldata _validate) external onlyOwnerProxy onlyAccount(_to) {
        // transfer(address,uint256[2])
        require(postProcess(_validate[1], preProcess(_IKeyCtrl(_links[_OWNER]).payment(), _sig, abi.encodeWithSelector(bytes4(0x0b80d0c8), _to, _validate))));
        _links[_OWNER] = _to;
    }
    //-------------------------------------------------------
    // _hub
    //-------------------------------------------------------
    function hub(address _to) external returns (bool) {
        require(msg.sender==_links[_HUB], ERR_NOT_HUB);
        _links[_HUB] = _to;
        return true;
    }
}
contract _Withdraw is _Owner {
    function _withdraw(address _erc20, uint256 _value) private {
        if(_erc20==address(0))
            address(uint160(_links[_OWNER])).transfer(_value);
        else
            _ERC20Interface(_erc20).transfer(_links[_OWNER], _value);
    }
    function withdraw(address _erc20, uint[3] calldata _values) external onlyOwnerPayment {
        _withdraw(_erc20, _values[0]);
    }
    function withdraw(bytes calldata _sig, address _erc20, uint[3] calldata _values) external onlyOwnerProxy {
        // withdraw(address,uint[3])
        require(postProcess(_values[1], preProcess(_IKeyCtrl(_links[_OWNER]).payment(), _sig, abi.encodeWithSelector(bytes4(0x67a06b7b), _erc20, _values))));
        _withdraw(_erc20, _values[0]);
    }
}
contract _MemberCtrl {
    using SafeMath for uint256;
    
    mapping(address=>bool) internal _members;
    uint256 internal _count;

    function create(address _ownerAccount) external returns (address);
    function isMember(address _who) external view returns (bool) {
        return _members[_who];
    }
    function members() external view returns (uint256) {
        return _count;
    }
}
//-----------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------
contract _Store is _IPayment, _Withdraw {
    using SafeMath for uint256;

    address[2] internal _erc20s;
    uint256[2] internal _prices;

    constructor(address[4] memory _linkers) _Owner(_linkers) internal {}

    function reset(address[2] calldata _erc20, uint256[4] calldata _values) external onlyOwnerMaster {
        _erc20s = _erc20;
        _prices = [_values[0],_values[1]];  // price, mileage, fee, timestamp
    }
    function reset(bytes calldata _sig, address[2] calldata _erc20, uint256[4] calldata _values) external onlyOwnerProxy {
        // reset(address[2],uint256[4])
        require(postProcess(_values[2], preProcess(_IKeyCtrl(_links[_OWNER]).payment(), _sig, abi.encodeWithSelector(bytes4(0x5a33bd42), _erc20, _values))));
        _erc20s = _erc20;
        _prices = [_values[0],_values[1]];
    }

    function about() public view returns (address[2] memory, uint256[2] memory) {
        return (_erc20s,_prices);
    }

    function min(uint _a, uint _b) internal pure returns (uint256) {
        if(_a>_b)
            return _b;
        return _a;
    }
    function confirm() internal view returns (uint256) {
        require(_erc20s[0]==address(0),"it's not ether");
        return msg.value;
    }
    function confirm20() internal view returns (uint256) {
        require(_erc20s[0]!=address(0),"it's not erc20");
        return min(_ERC20Interface(_erc20s[0]).allowance(msg.sender,address(this)),_ERC20Interface(_erc20s[0]).balanceOf(msg.sender));
    }
    function mileage() internal {
        if(_prices[0]>0&&_prices[1]>0&&_erc20s[1]!=address(0))
          _ERC20Mileage(_erc20s[1]).mileage(msg.sender,_prices[1]);
    }
}
//-----------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------
contract _StoreHub is _Withdraw, _MemberCtrl {
    function recive(address _store) external returns (bool) {
        require(_MemberCtrl(_links[_STORE_FACTORY]).isMember(msg.sender), ERR_NOT_HUB);
        require(_MemberCtrl(msg.sender).isMember(_store), ERR_NOT_MEMBER);
        _members[_store] = true;
        return true;
    }
    function emitTransfer(address _store, address _to) internal;
    function send(address _store, address _to) external onlyOwnerPayment {
        require(_members[_store]);
        require(_MemberCtrl(_links[_STORE_FACTORY]).isMember(_to), ERR_NOT_HUB);
        require(_StoreHub(_to).recive(_store));
        require(_Owner(_store).hub(_to));
        _members[_store] = false;
        emitTransfer(_store, address(this));
    }
}
//-----------------------------------------------------------------------------------------------

//-----------------------------------------------------------------------------------------------
contract _StoreFactory is _MemberCtrl {
    address internal _af;
    constructor(address _accountFactory) internal {
        _af = _accountFactory;
    }
    modifier onlyAccount(address who) {
        require(_IAccountFactory(_af).isAccount(who), "is not account");
        _;
    }
}
//-----------------------------------------------------------------------------------------------

contract Store is _Store {
    constructor(address[4] memory _linkers) _Store(_linkers) public {}

    //-------------------------------------------------------
    // _Payment
    //-------------------------------------------------------
    function confirmItem(uint256[2][] calldata _item) external payable returns (bool) {
        revert();
    }
    function confirmItem20(uint256[2][] calldata _item) external payable returns (bool) {
        revert();
    }
    function confirmData(bytes calldata _data) external payable returns (bool) {
        uint256 _value = confirm();
        require(_prices[0]==0||_value==_prices[0]);
        mileage();
        StoreFactory(_links[_STORE_FACTORY]).register(msg.sender, _data);
        return true;
    }
    function confirmData20(bytes calldata _data) external payable returns (bool) {        
        uint256 _value = confirm20();
        require(_prices[0]==0||_value>=_prices[0]);
        mileage();
        _ERC20Interface(_erc20s[0]).transferFrom(msg.sender,address(this),_value);
        StoreFactory(_links[_STORE_FACTORY]).register(msg.sender, _data);
        return true;
    }

    //-------------------------------------------------------
    // register assets
    //-------------------------------------------------------
    uint256 index;
    event ASSET(uint256 indexed _category, uint256 indexed _index, bytes _asset);
    function asset(uint256 _category, bytes calldata _asset) external onlyOwnerPayment {
        emit ASSET(_category,index,_asset);
        index = index.add(1);
    }

    //-------------------------------------------------------
    // register setting
    //-------------------------------------------------------
    event SETTING(bytes _msgPack);
    function setting(bytes calldata _msgPack) external onlyOwnerPayment {
        emit SETTING(_msgPack);
    }
}

contract StoreFactory is _StoreFactory {
    constructor(address _accountFactory) _StoreFactory(_accountFactory) public {}

    //-------------------------------------------------------
    // Avatar - store
    //-------------------------------------------------------
    function create(address _ownerAccount) public onlyAccount(_ownerAccount) returns (address) {
        address temp = address(new Store([_ownerAccount, _af, address(this), address(0)]));
        _members[temp] = true;
        _count = _count.add(1);
        return temp;
    }

    //-------------------------------------------------------
    // Avatar - register
    //-------------------------------------------------------
    event USER(address indexed _user, address indexed _avatar, bytes _msgPack);
    function register(address _user, bytes calldata _msgPack) external {
        require(_members[msg.sender]);
        emit USER(_user,msg.sender,_msgPack);
    }
}
