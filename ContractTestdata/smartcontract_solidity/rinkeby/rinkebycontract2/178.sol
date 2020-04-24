/**
 *Submitted for verification at Etherscan.io on 2019-08-06
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
    function getTokenPrice(address _game, uint256 _tokenId) public returns (Price memory);

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
    
    constructor() public {
        CryptoCurrencies['ETH'] = address(0x28caD4dEd0B5E534FeaED71f1Bf8B3ECCd0d6b5C);
    }
    function calPrice(string memory _crypto, address _game, uint256 _tokenId, uint256 _Price, uint _isHightLight) public view returns(uint256 _Need){
        buyNFTInterface cripto = buyNFTInterface(CryptoCurrencies[_crypto]);
        return cripto.calPrice(_game, _tokenId, _Price, _isHightLight);
    }
    // function getCryptoCurrencies() public view returns(address[] memory){
    //     return CryptoCurrencies;
    // }
}
