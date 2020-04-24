/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^0.5.4;
contract gvcCoin{
    string public constant name="global vc";
    string public constant symbol="gvc";
    uint public constant totalSupply=10000000;
    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
    constructor(address OWNER)public{
        balanceOf[OWNER]=totalSupply;
    }
    mapping(address=>uint)balanceOf;
    function balance(address _owner)public view returns(uint){
        return(balanceOf[_owner]);
    }
    mapping(uint=>address)tokenOwners;
    mapping(uint=>bool)tokenExists;
    function ownerOf(uint _tokenID)public view returns(address){
        require(tokenExists[_tokenID]);
        return(tokenOwners[_tokenID]);
    }
    mapping(address=>mapping(address=>uint))allowed;
    function approve(address _to,uint _tokenID)public{
        require(msg.sender==ownerOf(_tokenID));
        require(msg.sender!=_to);
        allowed[msg.sender][_to] = _tokenID;
        emit  Approval(msg.sender, _to, _tokenID);
    }
    function takeOwnership(uint _tokenID)public{
        require(tokenExists[_tokenID]);
        address oldOwner=ownerOf(_tokenID);
        address newOwner=msg.sender;
        require(newOwner != oldOwner);
        require(allowed[oldOwner][newOwner] == _tokenID);
        balanceOf[oldOwner]-= 1;
        tokenOwners[_tokenID] = newOwner;
        balanceOf[newOwner]+= 1;
        emit Transfer(oldOwner, newOwner, _tokenID);
    }
    mapping(address=>mapping(uint=>uint))ownerTokens;
    
    function transfer(address _to,uint _tokenID)public{
        address currentOwner = msg.sender;
        address newOwner = _to;
        require(tokenExists[_tokenID]);
        require(currentOwner==ownerOf(_tokenID));
        require(currentOwner!=newOwner);
        require(newOwner!=address(0x0));
        
        for(uint i=0;ownerTokens[currentOwner][i] != _tokenID;i++){
            ownerTokens[currentOwner][i] = 0;
        }
        balanceOf[currentOwner]-=1;
        tokenOwners[_tokenID]=newOwner;
        balanceOf[newOwner]+=1;
        emit Transfer(currentOwner,newOwner,_tokenID);
    }
    function tokenOfOwnerByIndex(address _owner,uint _index)public view returns(uint){
        return ownerTokens[_owner][_index];
    }
    mapping(uint=>string)tokenLinks;
    function tokenMetadata(uint _tokenId)public view returns(string memory) {
        return tokenLinks[_tokenId];
    }
}
