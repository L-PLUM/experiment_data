/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity 0.4.25;
library Strings {
  // via https://github.com/oraclize/ethereum-api/blob/master/oraclizeAPI_0.5.sol
  function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string) {
      bytes memory _ba = bytes(_a);
      bytes memory _bb = bytes(_b);
      bytes memory _bc = bytes(_c);
      bytes memory _bd = bytes(_d);
      bytes memory _be = bytes(_e);
      string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
      bytes memory babcde = bytes(abcde);
      uint k = 0;
      for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
      for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
      for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
      for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
      for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
      return string(babcde);
    }

    function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string _a, string _b, string _c) internal pure returns (string) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string _a, string _b) internal pure returns (string) {
        return strConcat(_a, _b, "", "", "");
    }

    function uint2str(uint i) internal pure returns (string) {
        if (i == 0) return "0";
        uint j = i;
        uint len;
        while (j != 0){
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }
}
contract Delegate {

    function mint(
        address _sender, 
        address _to,
        uint256 _tokenId,
        string _name,
		string _primaryItem,
        string _secondaryItem,
        string _extItem
    ) public returns (bool);

    function approve(address _sender, address _to, uint256 _tokenId) public returns (bool);

    function setApprovalForAll(address _sender, address _operator, bool _approved) public returns (bool);

    function transferFrom(address _sender, address _from, address _to, uint256 _tokenId) public returns (bool);

    function safeTransferFrom(address _sender, address _from, address _to, uint256 _tokenId) public returns (bool);

    function safeTransferFrom(address _sender, address _from, address _to, uint256 _tokenId, bytes memory _data) public returns (bool);
	
	function getAuthTokenByTokenId(uint256 tokenId) public view returns (
        string name,
		string primaryItem,
        string secondaryItem,
        string extItem
    );
}

contract Ownable {

    address public owner;

    constructor () public {
        owner = msg.sender;
    }

    function setOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    function getOwner() public view returns (address) {
        return owner;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

}

contract AuthTokenDelegate is Delegate, Ownable {
    
    using Strings for string;
    
    string str_split="&";
    
    mapping(address => bool) public minters;
	/**
     * 增加AuthToken
     */
    event AddAuthToken(uint256 indexed authTokenIndex,uint256 indexed tokenId,string indexed name);
	/**
     * 记录发送HPB的发送者地址和发送的金额
     */
    event ReceivedHpb(address indexed sender, uint amount);
    
    struct DelegateAuthToken {
        uint256 tokenId; // TokenId
        string name; // 名称
        string primaryItem;
        string secondaryItem;
        string extItem;
    }
    
    DelegateAuthToken[] authTokens;
    
    mapping(uint256 => uint256) public authTokenIndexs;
	/**
     * 接受HPB转账
     */ 
    function () payable  external{
        emit ReceivedHpb(msg.sender, msg.value);
    }
    /**
     * 销毁合约，并把合约余额返回给合约拥有者
     */
    function kill() onlyOwner public{
        selfdestruct(owner);
    }
    constructor () payable public {
        owner = msg.sender;
        authTokens.push(
            DelegateAuthToken(
                0, 
                "首个token", 
                "", 
                "", 
                ""
            )
        );
        authTokenIndexs[0] = 0;
    }
    
    /**
     * 新建AuthToken
     */
    function _addAuthToken(
        uint256 tokenId,
        string name,
		string primaryItem,
        string secondaryItem,
        string extItem
    ) internal {
        uint256 authTokenIndex=authTokenIndexs[tokenId];
        require(tokenId != 0, "token exist");
        require(authTokenIndex == 0, "token exist");
        authTokenIndex = authTokens.length;
        authTokens.push(
            DelegateAuthToken(
                tokenId, 
                name, 
                primaryItem, 
                secondaryItem, 
                extItem
            )
        );
        authTokenIndexs[tokenId] = authTokenIndex;
        emit AddAuthToken(authTokenIndex,tokenId,name);
    }

    function setCanMint(address minter, bool canMint) public onlyOwner {
        minters[minter] = canMint;
    }

    bool public canAnyMint = true;

    function setCanAnyMint(bool canMint) public onlyOwner {
        canAnyMint = canMint;
    }

    function mint(
        address _sender, 
        address _to,
        uint256 _tokenId,
        string _name,
		string _primaryItem,
        string _secondaryItem,
        string _extItem
    ) public returns (bool) {
        require(canAnyMint, "no minting possible");
        _addAuthToken(_tokenId,_name,_primaryItem,_secondaryItem,_extItem);
        if(!minters[_sender]){
            minters[_sender]=true;
        }
        require(_to!= address(0), "to address is invalid");
        return minters[_sender];
    }
    
    function getAuthTokenByTokenId(uint256 tokenId) public view returns (
        string name,
		string primaryItem,
        string secondaryItem,
        string extItem
    ) {
        if(tokenId>0){
	        uint256 authTokenIndex=authTokenIndexs[tokenId];
	        require(authTokenIndex != 0, "token not exist");
        }
        return (
            authTokens[authTokenIndex].name,
	        authTokens[authTokenIndex].primaryItem,
	        authTokens[authTokenIndex].secondaryItem,
	        authTokens[authTokenIndex].extItem
        );
    }

    function approve(address, address, uint256) public returns (bool) {
        return true;
    }

    function setApprovalForAll(address, address, bool) public returns (bool) {
        return true;
    }

    function transferFrom(address, address, address, uint256) public returns (bool) {
        return false;
    }

    function safeTransferFrom(address, address, address, uint256) public returns (bool) {
        return false;
    }

    function safeTransferFrom(address, address, address, uint256, bytes memory) public returns (bool) {
        return false;
    }
}
