/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

// solium-disable linebreak-style
pragma solidity ^0.5.0;

pragma experimental ABIEncoderV2;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract ERC721 {
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

    function balanceOf(address _owner) public view returns (uint256 _balance);
    function ownerOf(uint256 _tokenId) public view returns (address _owner);
    function transfer(address _to, uint256 _tokenId) public;
    function approve(address _to, uint256 _tokenId) public;
    function takeOwnership(uint256 _tokenId) public;
}

contract ERC721Metadata is ERC721 {
    event MetadataUpdated(address _owner, uint256 _tokenId, string _newMetadata);
    event StatusUpdated(uint256 _tokenId, uint256 _newStatus);

    function setTokenMetadata(uint256 _tokenId, string memory _metadata) public;
    function tokenMetadata(uint256 _tokenId) public view returns (string memory infoUrl);
    function setTokenStatus(uint256 _tokenId, uint256 _newStatus) public;
    function tokenStatus(uint256 _tokenId) public view returns (uint256 status);
    function tokenDate(uint256 _tokenId) public view returns (uint256 date);
}

contract ExtendedERC721Token is ERC721Metadata, Ownable {
    using SafeMath for uint256;

    // Total amount of tokens
    uint256 private totalTokens;

    // Mapping from token ID to owner
    mapping (uint256 => address) private tokenOwner;

    // Mapping from token ID to approved address
    mapping (uint256 => address) private tokenApprovals;

    // Mapping from owner to list of owned token IDs
    mapping (address => uint256[]) private ownedTokens;

    // Mapping from token ID to index of the owner tokens list
    mapping(uint256 => uint256) private ownedTokensIndex;

    // Tokens metadata
    mapping (uint256 => string) private _metadata;

    // Maps token id to bool
    mapping (uint256 => bool) private _isMinted;
    
    //we are mapping status with uint256
    //0 - unclaimed, 1 - claimed, 2 - lost, 3 - stolen, 4 - for sale, 5 - destroyed
    mapping (uint256 => uint256) private _status;
    
    mapping (uint256 => uint256) private _date;

    modifier onlyOwnerOf(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender);
        _;
    }

    function tokenMetadata(uint256 _tokenId) public view returns (string memory) {
        return _metadata[_tokenId];
    }

    /// This is used in case we try to mint a product with same ID
    function isMinted(uint256 _tokenId) public view returns (bool) {
        return _isMinted[_tokenId];
    }
	
    function tokenStatus(uint256 _tokenId) public view returns (uint256) {
        return _status[_tokenId];
    }
	
    function tokenDate(uint256 _tokenId) public view returns (uint256) {
        return _date[_tokenId];
    }

    function setTokenMetadata(uint256 _tokenId, string memory _newMetadata) public onlyOwnerOf(_tokenId) {
        _metadata[_tokenId] = _newMetadata;
        emit MetadataUpdated(msg.sender, _tokenId, _newMetadata);
    }
    
    function setTokenStatus(uint256 _tokenId, uint256 _newStatus) public onlyOwner {
        _status[_tokenId] = _newStatus;
        emit StatusUpdated(_tokenId, _newStatus);
    }

    function mint(address _to, uint256 _tokenId, string memory _tokenMetadata) public onlyOwner {
        require(_to != address(0));
        require(!_isMinted[_tokenId]);
        addToken(_to, _tokenId);
        _date[_tokenId] = block.number;
        _status[_tokenId] = 0;
        _metadata[_tokenId] = _tokenMetadata;
        emit Transfer(address(0), _to, _tokenId);
    }

    /// Batch minting of products
    function batchMint(address[] memory _destinations, uint256[] memory _tokens, string[] memory _metadatas) public onlyOwner {
        require(_destinations.length == _tokens.length);
        require(_tokens.length == _metadatas.length);
        for(uint i=0; i<_destinations.length; i++) {
            mint(_destinations[i], _tokens[i], _metadatas[i]);
        }
    }

    function totalSupply() public view returns (uint256) {
        return totalTokens;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return ownedTokens[_owner].length;
    }

    function tokensOf(address _owner) public view returns (uint256[] memory) {
        return ownedTokens[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = tokenOwner[_tokenId];
        require(owner != address(0));
        return owner;
    }

    function approvedFor(uint256 _tokenId) public view returns (address) {
        return tokenApprovals[_tokenId];
    }

    function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        clearApprovalAndTransfer(msg.sender, _to, _tokenId);
        _date[_tokenId] = block.number;
    }

    function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        address owner = ownerOf(_tokenId);
        require(_to != owner);
        if (approvedFor(_tokenId) != address(0) || _to != address(0)) {
            tokenApprovals[_tokenId] = _to;
            emit Approval(owner, _to, _tokenId);
        }
    }

    function takeOwnership(uint256 _tokenId) public {
        require(isApprovedFor(msg.sender, _tokenId));
        clearApprovalAndTransfer(ownerOf(_tokenId), msg.sender, _tokenId);
    }

    function isApprovedFor(address _owner, uint256 _tokenId) internal view returns (bool) {
        return approvedFor(_tokenId) == _owner;
    }

    function clearApprovalAndTransfer(address _from, address _to, uint256 _tokenId) internal {
        require(_to != address(0));
        require(_to != ownerOf(_tokenId));
        require(ownerOf(_tokenId) == _from);
        _status[_tokenId] = 1;
        clearApproval(_from, _tokenId);
        removeToken(_from, _tokenId);
        addToken(_to, _tokenId);
        emit Transfer(_from, _to, _tokenId);
    }

    function clearApproval(address _owner, uint256 _tokenId) private {
        require(ownerOf(_tokenId) == _owner);
        tokenApprovals[_tokenId] = address(0);
        emit Approval(_owner, address(0), _tokenId);
    }

    function addToken(address _to, uint256 _tokenId) private {
        require(tokenOwner[_tokenId] == address(0));
        tokenOwner[_tokenId] = _to;
        uint256 length = balanceOf(_to);
        ownedTokens[_to].push(_tokenId);
        ownedTokensIndex[_tokenId] = length;
        totalTokens = totalTokens.add(1);
        _isMinted[_tokenId] = true;
    }

    function removeToken(address _from, uint256 _tokenId) private {
        require(ownerOf(_tokenId) == _from);

        uint256 tokenIndex = ownedTokensIndex[_tokenId];
        uint256 lastTokenIndex = balanceOf(_from).sub(1);
        uint256 lastToken = ownedTokens[_from][lastTokenIndex];

        tokenOwner[_tokenId] = address(0);
        ownedTokens[_from][tokenIndex] = lastToken;
        ownedTokens[_from][lastTokenIndex] = 0;
        // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
        // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
        // the lastToken to the first position, and then dropping the element placed in the last position of the list

        ownedTokens[_from].length--;
        ownedTokensIndex[_tokenId] = 0;
        ownedTokensIndex[lastToken] = tokenIndex;
        totalTokens = totalTokens.sub(1);
    }

    function removeToken(address _from, address _to, uint256 _tokenId) public onlyOwner {
        clearApproval(_from, _tokenId);
        removeToken(_from, _tokenId);
        addToken(_to, _tokenId);
        _date[_tokenId] = block.number;
        emit Transfer(_from, _to, _tokenId);
    }

}

contract IlmioToken is ExtendedERC721Token {
    string public constant name = "Ilmio Token";
    string public constant symbol = "IT";
    string public constant version = "v1";
    constructor() public {
      
    }
}
