pragma solidity ^0.5.4;

import "./AGDNF-ProductFactory.sol";
import "./AGDF-ProductFactory.sol";
import "./AGDOwnable.sol";
import "./AGDStorage.sol";

contract GenieToken is Ownable{ 
    
    address _storageSpace;
    
    modifier isRegisted (address addr){
        Storage storageSpace = Storage(_storageSpace);
        require(storageSpace.getAccountToEntityContractAddress(addr) != 0x0000000000000000000000000000000000000000);
        _;
    }

    constructor (
        address _storage, 
        address _ff,
        address _fn
    ) 
    public 
    {
        _storageSpace = _storage;
        Storage storageSpace = Storage(_storage);
        storageSpace.setFProductFactoryAddress(_ff);
        storageSpace.setNFProductFactoryAddress(_fn);
        NF_ProductFactory nfFactory = NF_ProductFactory(storageSpace.getNFProductFactoryAddress());
        nfFactory.setStorageSpace(_storageSpace);
        F_ProductFactory fFactory = F_ProductFactory(storageSpace.getFProductFactoryAddress());
        fFactory.setStorageSpace(_storageSpace);
    }
    
   function NewKindOfNon_FungibleAssetCreated(string memory name, string memory symbol, address _connectedAsset) public isRegisted(tx.origin) returns (address) {
        Storage storageSpace = Storage(_storageSpace);
        NF_ProductFactory factories = NF_ProductFactory(storageSpace.getNFProductFactoryAddress());
        return factories.createNewNFProduct(name, symbol, _connectedAsset);
    }
    
    function NewKindOfFungibleAssetCreated(string memory _name, string memory _symbol, uint8 _decimals, uint totalSupply) public isRegisted(tx.origin) returns (address) {
        Storage storageSpace = Storage(_storageSpace);
        F_ProductFactory factories = F_ProductFactory(storageSpace.getFProductFactoryAddress());
        return factories.createNewFProduct(_name, _symbol, _decimals, totalSupply);
    }
    
    function getDeployedNFProduct() public view returns (AGDNF_Token[] memory) {
        Storage storageSpace = Storage(_storageSpace);
        NF_ProductFactory factories = NF_ProductFactory(storageSpace.getNFProductFactoryAddress());
        return factories.getDeployedNFProduct();
    }
    
    function getDeployedFProduct() public view returns (F_Product[] memory) {
        Storage storageSpace = Storage(_storageSpace);
       F_ProductFactory factories = F_ProductFactory(storageSpace.getFProductFactoryAddress());
        return factories.getDeployedFProduct();
    }
    
    //
    function Non_FungibleAsset_BalanceOf(address owner, address contractAddress) public view returns (uint256) {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.balanceOf(owner);
    }
    
    function Non_FungibleAsset_OwnerOf(uint256 tokenId, address contractAddress) public view returns (address) {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.ownerOf(tokenId);
    }
    
    function Non_FungibleAsset_GetConnectedAsset(address contractAddress) public view returns (address) {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.getConnectedAsset();
    }
    
    function Non_FungibleAsset_ProductIdOfEvent(uint256 eventId, address contractAddress) public view returns (uint256) {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.productIdOfEvent(eventId);
    }
    
    function Non_FungibleAsset_ProductIdOfRent(uint256 rentId, address contractAddress) public view returns (uint256) {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.productIdOfRent(rentId);
    }
    
    function Non_FungibleAsset_EventIdOf(uint256 tokenId, address contractAddress) public view returns (uint256[] memory) {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.eventIdOf(tokenId);
    }
    
    function Non_FungibleAsset_RentIdOf(uint256 tokenId, address contractAddress) public view returns (uint256) {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.rentIdOf(tokenId);
    }
    
    function Non_FungibleAsset_BatchIdOf(uint256 tokenId, address contractAddress) public view returns (uint256) {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.batchIdOf(tokenId);
    }
    
    function Non_FungibleAsset_GetApproved(uint256 tokenId, address contractAddress) public view returns (address) {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.getApproved(tokenId);
    }
    
    function Non_FungibleAsset_IsApprovedForAll(address owner, address operator, address contractAddress) public view returns (bool) {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.isApprovedForAll(owner, operator);
    }
    
    function Non_FungibleAsset_TransferFrom(address _from, address to, uint256 tokenId, address contractAddress) public {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.transferFrom(_from, to, tokenId);
    }
    
    function Non_FungibleAsset_SetApprovalForAll(address to, bool approved, address contractAddress) public {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.setApprovalForAll(to, approved);
    }
    
    function Non_FungibleAsset_Approve(address to, uint256 tokenId, address contractAddress) public {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.approve(to, tokenId);
    }
    
    function Non_FungibleAsset_RemoveAsset(uint256 tokenId, address contractAddress) public {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.removeAsset(tokenId);
    }
    
    function Non_FungibleAsset_Sell(uint tokenId, uint[] memory items, address contractAddress) public {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.Sell(tokenId, items);
    }
    
    function Non_FungibleAsset_SafeTransferFrom(address _from, address to, uint256 tokenId, bytes memory data, address contractAddress) public {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.safeTransferFrom(_from, to, tokenId, data);
    }
    
    function Non_FungibleAsset_NewNon_FungibleProductCreated(string memory _uri, address contractAddress) public isRegisted(tx.origin) {
	    AGDNF_Token nf_product = AGDNF_Token(contractAddress);
	    nf_product.createNewNFProduct(_uri);
	}
	
	function Non_FungibleAsset_NewNon_FungibleProductBatchCreated(string memory _code, uint _from, uint _to, string memory _uri, address contractAddress) public isRegisted(tx.origin) {
	    AGDNF_Token nf_product = AGDNF_Token(contractAddress);
	    nf_product.createNewBatch(_code, _from, _to, _uri);
	}
	
	function Non_FungibleAsset_Name(address contractAddress) external view returns (string memory) {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.name();
    }
    
    function Non_FungibleAsset_Symbol(address contractAddress) external view returns (string memory) {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.symbol();
    }
    
    function Non_FungibleAsset_TokenURI(uint256 tokenId, address contractAddress) external view returns (string memory) {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.tokenURI(tokenId);
    }
    
    function Non_FungibleAsset_TotalSupply(address contractAddress) public view returns (uint){
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.totalSupply();
    }
    
    function Non_FungibleAsset_ActionToDiary(uint tokenId, string memory action, string memory fromID, string memory toID, string memory description, string memory date, address contractAddress) public {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.SentToDiary(tokenId, action, fromID, toID, description, date); 
    }
    
    function Non_FungibleAsset_EventIDList(uint tokenId, address contractAddress) public view returns(uint[] memory){
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
	    return nf_product.getEventIDList(tokenId);
	}
	
	function Non_FungibleAsset_Event(uint eventId, address contractAddress) public view 
	    returns(
          string memory action,
          string memory fromID,
          string memory toID,
          string memory description,
          string memory date
        )
    {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.getEvent(eventId);
    }
    
    function Non_FungibleAsset_RentDiary(uint tokenId, string memory owner, string memory renter, string memory deadline, address contractAddress) public {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.RentedDiary(tokenId, owner, renter, deadline); 
    }
    
    function Non_FungibleAsset_IndexRentedInfo(uint tokenId, address contractAddress) public view returns(uint){
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
	    return nf_product.getIndexRentedInfo(tokenId);
	}
	
	function Non_FungibleAsset_IsSold(uint tokenId, uint itemToCheck, address contractAddress) public view returns(bool){
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
	    return nf_product.isSold(tokenId, itemToCheck);
	}
	
	function Non_FungibleAsset_Rent(uint rentId, address contractAddress) public view 
	    returns(
          string memory owner,
          string memory renter,
          string memory deadline
        )
    {
        AGDNF_Token nf_product = AGDNF_Token(contractAddress);
        return nf_product.getRent(rentId);
    }
    
    function FungibleAsset_TotalSupply(address contractAddress) public view returns (uint256) {
        F_Product f_product = F_Product(contractAddress);
        return f_product.totalSupply();
    }
    
    function FungibleAsset_Name(address contractAddress) public view returns (string memory) {
        F_Product f_product = F_Product(contractAddress);
        return f_product.name();
    }
    
    function FungibleAsset_Symbol(address contractAddress) public view returns (string memory) {
        F_Product f_product = F_Product(contractAddress);
        return f_product.symbol();
    }
    
    function FungibleAsset_Decimals(address contractAddress) public view returns (uint8) {
        F_Product f_product = F_Product(contractAddress);
        return f_product.decimals();
    }
    
    function FungibleAsset_BalanceOf(address owner, address contractAddress) public view returns (uint256) {
        F_Product f_product = F_Product(contractAddress);
        return f_product.balanceOf(owner);
    }
    
    function FungibleAsset_Allowance(address owner, address spender, address contractAddress) public view returns (uint256) {
        F_Product f_product = F_Product(contractAddress);
        return f_product.allowance(owner, spender);
    }
    
    function FungibleAsset_Approve(address spender, uint256 value, address contractAddress) public returns (bool) {
        F_Product f_product = F_Product(contractAddress);
        return f_product.approve(spender, value);
    }
    
    function FungibleAsset_AddAllowedTransactor(address _transactor, address contractAddress) public {
        F_Product f_product = F_Product(contractAddress);
        return f_product.addAllowedTransactor(_transactor);
    }
    
    function FungibleAsset_AddCallSpenderWhitelist(address _spender, address contractAddress) public {
        F_Product f_product = F_Product(contractAddress);
        return f_product.addCallSpenderWhitelist(_spender);
    }
    
    function FungibleAsset_AddMinter(address account, address contractAddress) public {
        F_Product f_product = F_Product(contractAddress);
        return f_product.addMinter(account);
    }
    
    function FungibleAsset_AddPauser(address account, address contractAddress) public {
        F_Product f_product = F_Product(contractAddress);
        return f_product.addPauser(account);
    }
    
    function FungibleAsset_Burn(uint256 _value, address contractAddress) public {
        F_Product f_product = F_Product(contractAddress);
        return f_product.burn(_value);
    }
    
    function FungibleAsset_BurnFrom(address account, uint256 amount, address contractAddress) public {
        F_Product f_product = F_Product(contractAddress);
        return f_product.burnFrom(account, amount);
    }
    
    function FungibleAsset_DecreaseAllowance(address spender, uint subtractedValue, address contractAddress) public returns (bool){
        F_Product f_product = F_Product(contractAddress);
        return f_product.decreaseAllowance(spender, subtractedValue);
    }
    
    function FungibleAsset_IncreaseAllowance(address spender, uint addedValue, address contractAddress) public returns (bool){
        F_Product f_product = F_Product(contractAddress);
        return f_product.increaseAllowance(spender, addedValue);
    }
    
    function FungibleAsset_Mint(address account, uint256 amount, address contractAddress) public returns (bool){
        F_Product f_product = F_Product(contractAddress);
        return f_product.mint(account, amount);
    }
    
    function FungibleAsset_Pause(address contractAddress) public {
        F_Product f_product = F_Product(contractAddress);
        return f_product.pause();
    }
    
    function FungibleAsset_Unpause(address contractAddress) public {
        F_Product f_product = F_Product(contractAddress);
        return f_product.unpause();
    }
    
    function FungibleAsset_RemoveAllowedTransactor(address _transactor, address contractAddress) public {
        F_Product f_product = F_Product(contractAddress);
        return f_product.removeAllowedTransactor(_transactor);
    }
    
    function FungibleAsset_RemoveCallSpenderWhitelist(address _spender, address contractAddress) public {
        F_Product f_product = F_Product(contractAddress);
        return f_product.removeCallSpenderWhitelist(_spender);
    }
    
    function FungibleAsset_RenounceMinter(address contractAddress) public {
        F_Product f_product = F_Product(contractAddress);
        return f_product.renounceMinter();
    }
    
    // function RenounceOwnership(address contractAddress) public {
    //     F_Product f_product = F_Product(contractAddress);
    //     return f_product.renounceOwnership();
    // }
    
    function FungibleAsset_RenouncePauser(address contractAddress) public {
        F_Product f_product = F_Product(contractAddress);
        return f_product.renouncePauser();
    }
    
    function FungibleAsset_SetWhitelistExpiration(uint256 _expiration, address contractAddress) public {
        F_Product f_product = F_Product(contractAddress);
        return f_product.setWhitelistExpiration(_expiration);
    }
    
    function FungibleAsset_TransferFrom(address _from, address to, uint256 value, address contractAddress) public returns (bool) {
        F_Product f_product = F_Product(contractAddress);
        return f_product.transferFrom(_from, to, value);
    }
    
    function FungibleAsset_Transfer(address to, uint256 value, address contractAddress) public returns (bool) {
        F_Product f_product = F_Product(contractAddress);
        return f_product.transfer(to, value);
    }
    
    // function TransferOwnership(address to, uint256 value, address contractAddress) public returns (bool) {
    //     F_Product f_product = F_Product(contractAddress);
    //     return f_product.transferOwnership(to, value);
    // }
    
    function FungibleAsset_IsMinter(address account, address contractAddress) public view returns (bool) {
        F_Product f_product = F_Product(contractAddress);
        return f_product.isMinter(account);
    }
    
    // function IsOwner(address account, address contractAddress) public view returns (uint256) {
    //     F_Product f_product = F_Product(contractAddress);
    //     return f_product.isOwner(account);
    // }
    
    function FungibleAsset_IsPauser(address account, address contractAddress) public view returns (bool) {
        F_Product f_product = F_Product(contractAddress);
        return f_product.isPauser(account);
    }
    
    
    function FungibleAsset_WhitelistActive(address contractAddress) public view returns (bool) {
        F_Product f_product = F_Product(contractAddress);
        return f_product.whitelistActive();
    }

}
