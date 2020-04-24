/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

pragma solidity ^0.5.10;
pragma experimental ABIEncoderV2;

contract Ownable {
    address public owner;


    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


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
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract buyNFTInterface {
    struct Price {
        address payable tokenOwner;
        uint256 Price;
        uint256 fee;
        uint isHightlight;
    }
    function getTokenPrice(address _game, uint256 _tokenId) public
    returns (address _tokenOwner, uint256 _Price, uint256 _fee, uint _isHightlight);

    function ownerOf(address _game, uint256 _tokenId) public view returns (address);

    function balanceOf() public view returns (uint256);

    function getApproved(address _game, uint256 _tokenId) public view returns (address);

    function calFee(address _game, uint256 _price) public view returns (uint256);

    function calFeeHightLight(address _game, uint256 _tokenId, uint _isHightLight) public view returns (uint256);

    function calPrice(address _game, uint256 _tokenId, uint256 _Price, uint _isHightLight) public view returns(uint256 _Need);

    function setPriceFee(address _game, uint256 _tokenId, uint256 _Price, uint _isHightLight) public payable;

    function removePrice(address _game, uint256 _tokenId) public;

    function setLimitFee(address _game, uint256 _Fee, uint256 _limitFee, uint256 _hightLightFee) public;
    function withdraw(uint256 amount) public;
    function revenue() public view returns (uint256);
    function buy(address _game, uint256 tokenId) public payable;
    function buyWithoutCheckApproved(address _game, uint256 tokenId) public payable;
    function buyFromSmartcontractViaTransfer(address _game, uint256 _tokenId) public payable;
}

contract BuyNFTProxy is Ownable {

    mapping(string => address) public CryptoCurrencies;
    struct Price {
        address payable tokenOwner;
        uint256 Price;
        uint256 fee;
        uint isHightlight;
    }
    constructor() public {
        CryptoCurrencies['ETH'] = address(0x197c868969A05560561aF690A7d919e5ad73BCF9);
    }
    function getTokenPrice(string memory _crypto, address _game, uint256 _tokenId) public 
    returns (address _tokenOwner, uint256 _Price, uint256 _fee, uint _isHightlight){

        buyNFTInterface cripto = buyNFTInterface(CryptoCurrencies[_crypto]);
        return (cripto.getTokenPrice(_game, _tokenId));
    }
    function calFee(string memory _crypto, address _game, uint256 _price) public view returns (uint256){
        buyNFTInterface cripto = buyNFTInterface(CryptoCurrencies[_crypto]);
        return cripto.calFee(_game, _price);
    }
    function calPrice(string memory _crypto, address _game, uint256 _tokenId, uint256 _Price, uint _isHightLight) public view returns(uint256 _Need){
        buyNFTInterface cripto = buyNFTInterface(CryptoCurrencies[_crypto]);
        return cripto.calPrice(_game, _tokenId, _Price, _isHightLight);
    }
    function calFeeHightLight(string memory _crypto, address _game, uint256 _tokenId, uint _isHightLight) public view returns (uint256){
        buyNFTInterface cripto = buyNFTInterface(CryptoCurrencies[_crypto]);
        return cripto.calFeeHightLight(_game, _tokenId, _isHightLight);
    }
    function setPriceFee(string memory _crypto, address _game, uint256 _tokenId, uint256 _Price, uint _isHightLight) public payable{
        buyNFTInterface cripto = buyNFTInterface(CryptoCurrencies[_crypto]);
        return cripto.setPriceFee.value(msg.value)(_game, _tokenId, _Price, _isHightLight);
    }
    function removePrice(string memory _crypto, address _game, uint256 _tokenId) public{
        buyNFTInterface cripto = buyNFTInterface(CryptoCurrencies[_crypto]);
        return cripto.removePrice(_game, _tokenId);
    }
    function withdraw(string memory _crypto, uint256 amount) public{
        buyNFTInterface cripto = buyNFTInterface(CryptoCurrencies[_crypto]);
        return cripto.withdraw(amount);
    }
    function revenue(string memory _crypto) public view returns (uint256){
        buyNFTInterface cripto = buyNFTInterface(CryptoCurrencies[_crypto]);
        return cripto.revenue();
    }
    function buy(string memory _crypto, address _game, uint256 tokenId) public payable{
        buyNFTInterface cripto = buyNFTInterface(CryptoCurrencies[_crypto]);
        return cripto.buy.value(msg.value)(_game, tokenId);
    }
    function buyWithoutCheckApproved(string memory _crypto, address _game, uint256 tokenId) public payable{
        buyNFTInterface cripto = buyNFTInterface(CryptoCurrencies[_crypto]);
        return cripto.buyWithoutCheckApproved.value(msg.value)(_game, tokenId);
    }
    function buyFromSmartcontractViaTransfer(string memory _crypto, address _game, uint256 _tokenId) public payable{
        buyNFTInterface cripto = buyNFTInterface(CryptoCurrencies[_crypto]);
        return cripto.buyFromSmartcontractViaTransfer.value(msg.value)(_game, _tokenId);
    }
    function ownerOf(string memory _crypto, address _game, uint256 _tokenId) public view returns (address) {
        buyNFTInterface cripto = buyNFTInterface(CryptoCurrencies[_crypto]);
        return cripto.ownerOf(_game, _tokenId);
    }
    function balanceOf(string memory _crypto) public view returns (uint256){
        buyNFTInterface cripto = buyNFTInterface(CryptoCurrencies[_crypto]);
        return cripto.balanceOf();
    }
    function getApproved(string memory _crypto, address _game, uint256 _tokenId) public view returns (address){
        buyNFTInterface cripto = buyNFTInterface(CryptoCurrencies[_crypto]);
        return cripto.getApproved(_game, _tokenId);
    }
}
