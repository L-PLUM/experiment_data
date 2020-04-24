/**
 *Submitted for verification at Etherscan.io on 2019-07-08
*/

pragma solidity ^0.4.23;

pragma solidity ^0.4.23;

contract Operators
{
    mapping (address=>bool) ownerAddress;
    mapping (address=>bool) operatorAddress;

    constructor() public
    {
        ownerAddress[msg.sender] = true;
    }

    modifier onlyOwner()
    {
        require(ownerAddress[msg.sender]);
        _;
    }

    function isOwner(address _addr) public view returns (bool) {
        return ownerAddress[_addr];
    }

    function addOwner(address _newOwner) external onlyOwner {
        require(_newOwner != address(0));

        ownerAddress[_newOwner] = true;
    }

    function removeOwner(address _oldOwner) external onlyOwner {
        delete(ownerAddress[_oldOwner]);
    }

    modifier onlyOperator() {
        require(isOperator(msg.sender));
        _;
    }

    function isOperator(address _addr) public view returns (bool) {
        return operatorAddress[_addr] || ownerAddress[_addr];
    }

    function addOperator(address _newOperator) external onlyOwner {
        require(_newOperator != address(0));

        operatorAddress[_newOperator] = true;
    }

    function removeOperator(address _oldOperator) external onlyOwner {
        delete(operatorAddress[_oldOperator]);
    }
}

pragma solidity ^0.4.23;

/// @title Auction Market for Blockchain Cuties.
/// @author https://BlockChainArchitect.io
contract MarketInterface 
{
    function withdrawEthFromBalance() external;

    function createAuction(uint40 _cutieId, uint128 _startPrice, uint128 _endPrice, uint40 _duration, address _seller) external payable;
    function createAuctionWithTokens(uint40 _cutieId, uint128 _startPrice, uint128 _endPrice, uint40 _duration, address _seller, address[] allowedTokens) external payable;

    function bid(uint40 _cutieId) external payable;

    function cancelActiveAuctionWhenPaused(uint40 _cutieId) external;

	function getAuctionInfo(uint40 _cutieId)
        external
        view
        returns
    (
        address seller,
        uint128 startPrice,
        uint128 endPrice,
        uint40 duration,
        uint40 startedAt,
        uint128 featuringFee,
        address[] allowedTokens
    );
}

pragma solidity ^0.4.23;

pragma solidity ^0.4.23;

/// @title BlockchainCuties: Collectible and breedable cuties on the Ethereum blockchain.
/// @author https://BlockChainArchitect.io
/// @dev This is the BlockchainCuties configuration. It can be changed redeploying another version.
interface ConfigInterface
{
    function isConfig() external pure returns (bool);

    function getCooldownIndexFromGeneration(uint16 _generation, uint40 _cutieId) external view returns (uint16);
    function getCooldownEndTimeFromIndex(uint16 _cooldownIndex, uint40 _cutieId) external view returns (uint40);
    function getCooldownIndexFromGeneration(uint16 _generation) external view returns (uint16);
    function getCooldownEndTimeFromIndex(uint16 _cooldownIndex) external view returns (uint40);

    function getCooldownIndexCount() external view returns (uint256);

    function getBabyGenFromId(uint40 _momId, uint40 _dadId) external view returns (uint16);
    function getBabyGen(uint16 _momGen, uint16 _dadGen) external pure returns (uint16);

    function getTutorialBabyGen(uint16 _dadGen) external pure returns (uint16);

    function getBreedingFee(uint40 _momId, uint40 _dadId) external view returns (uint256);
}


contract CutieCoreInterface
{
    function isCutieCore() pure public returns (bool);

    ConfigInterface public config;

    function transferFrom(address _from, address _to, uint256 _cutieId) external;
    function transfer(address _to, uint256 _cutieId) external;

    function ownerOf(uint256 _cutieId)
        external
        view
        returns (address owner);

    function getCutie(uint40 _id)
        external
        view
        returns (
        uint256 genes,
        uint40 birthTime,
        uint40 cooldownEndTime,
        uint40 momId,
        uint40 dadId,
        uint16 cooldownIndex,
        uint16 generation
    );

    function getGenes(uint40 _id)
        public
        view
        returns (
        uint256 genes
    );


    function getCooldownEndTime(uint40 _id)
        public
        view
        returns (
        uint40 cooldownEndTime
    );

    function getCooldownIndex(uint40 _id)
        public
        view
        returns (
        uint16 cooldownIndex
    );


    function getGeneration(uint40 _id)
        public
        view
        returns (
        uint16 generation
    );

    function getOptional(uint40 _id)
        public
        view
        returns (
        uint64 optional
    );


    function changeGenes(
        uint40 _cutieId,
        uint256 _genes)
        public;

    function changeCooldownEndTime(
        uint40 _cutieId,
        uint40 _cooldownEndTime)
        public;

    function changeCooldownIndex(
        uint40 _cutieId,
        uint16 _cooldownIndex)
        public;

    function changeOptional(
        uint40 _cutieId,
        uint64 _optional)
        public;

    function changeGeneration(
        uint40 _cutieId,
        uint16 _generation)
        public;

    function createSaleAuction(
        uint40 _cutieId,
        uint128 _startPrice,
        uint128 _endPrice,
        uint40 _duration
    )
    public;

    function getApproved(uint256 _tokenId) external returns (address);
    function totalSupply() view external returns (uint256);
    function createPromoCutie(uint256 _genes, address _owner) external;
    function checkOwnerAndApprove(address _claimant, uint40 _cutieId, address _pluginsContract) external view;
    function breedWith(uint40 _momId, uint40 _dadId) public payable returns (uint40);
    function getBreedingFee(uint40 _momId, uint40 _dadId) public view returns (uint256);
    function restoreCutieToAddress(uint40 _cutieId, address _recipient) external;
    function createGen0Auction(uint256 _genes, uint128 startPrice, uint128 endPrice, uint40 duration) external;
    function createGen0AuctionWithTokens(uint256 _genes, uint128 startPrice, uint128 endPrice, uint40 duration, address[] allowedTokens) external;
    function createPromoCutieWithGeneration(uint256 _genes, address _owner, uint16 _generation) external;
    function createPromoCutieBulk(uint256[] _genes, address _owner, uint16 _generation) external;
}

pragma solidity ^0.4.23;

/// @title BlockchainCuties Sale Contract
/// @author https://BlockChainArchitect.io
interface SaleInterface
{
    function bidWithPlugin(uint32 lotId, uint valueForEvent, address tokenForEvent) external payable;
    function getLotNftFixedRewards(uint32 lotId) external view returns (
        uint256 rewardsNFTFixedKind,
        uint256 rewardsNFTFixedIndex
    );
    function getLotToken1155Rewards(uint32 lotId) external view returns (
        uint256[5] memory rewardsToken1155tokenId,
        uint256[5] memory rewardsToken1155count
    );
    function getLotCutieRewards(uint32 lotId) external view returns (
        uint256[5] memory rewardsCutieGenome,
        uint256[5] memory rewardsCutieGeneration
    );
    function getLotNftMintRewards(uint32 lotId) external view returns (
        uint256[5] memory rewardsNFTMintNftKind
    );

    function getLotRewards(uint32 lotId) external view returns (
        uint256[5] memory rewardsToken1155tokenId,
        uint256[5] memory rewardsToken1155count,
        uint256[5] memory rewardsNFTMintNftKind,
        uint256[5] memory rewardsNFTFixedKind,
        uint256[5] memory rewardsNFTFixedIndex,
        uint256[5] memory rewardsCutieGenome,
        uint256[5] memory rewardsCutieGeneration
    );
}

pragma solidity ^0.4.23;

interface BlockchainCutiesERC1155Interface
{
    function mintNonFungibleSingleShort(uint128 _type, address _to) external;
    function mintNonFungibleSingle(uint256 _type, address _to) external;
    function mintNonFungibleShort(uint128 _type, address[] _to) external;
    function mintNonFungible(uint256 _type, address[] _to) external;
    function mintFungibleSingle(uint256 _id, address _to, uint256 _quantity) external;
    function mintFungible(uint256 _id, address[] _to, uint256[] _quantities) external;
    function isNonFungible(uint256 _id) external pure returns(bool);
    function ownerOf(uint256 _id) external view returns (address);
    function totalSupplyNonFungible(uint256 _type) view external returns (uint256);
    function totalSupplyNonFungibleShort(uint128 _type) view external returns (uint256);

    /**
        @notice A distinct Uniform Resource Identifier (URI) for a given token.
        @dev URIs are defined in RFC 3986.
        The URI may point to a JSON file that conforms to the "ERC-1155 Metadata URI JSON Schema".
        @return URI string
    */
    function uri(uint256 _id) external view returns (string memory);
    function proxyTransfer721(address _from, address _to, uint256 _tokenId, bytes _data) external;
    function proxyTransfer20(address _from, address _to, uint256 _tokenId, uint256 _value) external;
    /**
        @notice Get the balance of an account's Tokens.
        @param _owner  The address of the token holder
        @param _id     ID of the Token
        @return        The _owner's balance of the Token type requested
     */
    function balanceOf(address _owner, uint256 _id) external view returns (uint256);
    /**
        @notice Transfers `_value` amount of an `_id` from the `_from` address to the `_to` address specified (with safety call).
        @dev Caller must be approved to manage the tokens being transferred out of the `_from` account (see "Approval" section of the standard).
        MUST revert if `_to` is the zero address.
        MUST revert if balance of holder for token `_id` is lower than the `_value` sent.
        MUST revert on any other error.
        MUST emit the `TransferSingle` event to reflect the balance change (see "Safe Transfer Rules" section of the standard).
        After the above conditions are met, this function MUST check if `_to` is a smart contract (e.g. code size > 0). If so, it MUST call `onERC1155Received` on `_to` and act appropriately (see "Safe Transfer Rules" section of the standard).
        @param _from    Source address
        @param _to      Target address
        @param _id      ID of the token type
        @param _value   Transfer amount
        @param _data    Additional data with no specified format, MUST be sent unaltered in call to `onERC1155Received` on `_to`
    */
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes _data) external;
}

pragma solidity ^0.4.23;

interface PluginsInterface
{
    function isPlugin(address contractAddress) external view returns(bool);
    function withdraw() external;
    function setMinSign(uint40 _newMinSignId) external;

    function runPluginOperator(
        address _pluginAddress,
        uint40 _signId,
        uint40 _cutieId,
        uint128 _value,
        uint256 _parameter,
        address _sender) external payable;
}

pragma solidity ^0.4.23;

/**
    Note: The ERC-165 identifier for this interface is 0x43b236a2.
*/
interface IERC1155TokenReceiver {

    /**
        @notice Handle the receipt of a single ERC1155 token type.
        @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeTransferFrom` after the balance has been updated.
        This function MUST return `bytes4(keccak256("accept_erc1155_tokens()"))` (i.e. 0x4dc21a2f) if it accepts the transfer.
        This function MUST revert if it rejects the transfer.
        Return of any other value than the prescribed keccak256 generated value MUST result in the transaction being reverted by the caller.
        @param _operator  The address which initiated the transfer (i.e. msg.sender)
        @param _from      The address which previously owned the token
        @param _id        The id of the token being transferred
        @param _value     The amount of tokens being transferred
        @param _data      Additional data with no specified format
        @return           `bytes4(keccak256("accept_erc1155_tokens()"))`
    */
    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes _data) external returns(bytes4);

    /**
        @notice Handle the receipt of multiple ERC1155 token types.
        @dev An ERC1155-compliant smart contract MUST call this function on the token recipient contract, at the end of a `safeBatchTransferFrom` after the balances have been updated.
        This function MUST return `bytes4(keccak256("accept_batch_erc1155_tokens()"))` (i.e. 0xac007889) if it accepts the transfer(s).
        This function MUST revert if it rejects the transfer(s).
        Return of any other value than the prescribed keccak256 generated value MUST result in the transaction being reverted by the caller.
        @param _operator  The address which initiated the batch transfer (i.e. msg.sender)
        @param _from      The address which previously owned the token
        @param _ids       An array containing ids of each token being transferred (order and length must match _values array)
        @param _values    An array containing amounts of each token being transferred (order and length must match _ids array)
        @param _data      Additional data with no specified format
        @return           `bytes4(keccak256("accept_batch_erc1155_tokens()"))`
    */
    function onERC1155BatchReceived(address _operator, address _from, uint256[] _ids, uint256[] _values, bytes _data) external returns(bytes4);

    /**
        @notice Indicates whether a contract implements the `ERC1155TokenReceiver` functions and so can accept ERC1155 token types.
        @dev This function MUST return `bytes4(keccak256("isERC1155TokenReceiver()"))` (i.e. 0x0d912442).
        This function MUST NOT consume more than 5,000 gas.
        @return           `bytes4(keccak256("isERC1155TokenReceiver()"))`
    */
    function isERC1155TokenReceiver() external view returns (bytes4);
}


/// @title BlockchainCuties: Collectible and breedable cuties on the Ethereum blockchain.
/// @dev This contract allows players to buy cutie for fiat currency.
///      Server accepts fiat payment and call proxy contract bo buy cutie on market and
///      transfer it to purchaser.
/// @author https://BlockChainArchitect.io
contract FiatProxy is Operators, IERC1155TokenReceiver {

    CutieCoreInterface public core;
    PluginsInterface public plugins;
    SaleInterface public sale;
    BlockchainCutiesERC1155Interface public token1155; // TODO: Token1155

    event OrderSuccess(uint orderId, uint value, address purchaser);

    function setup(CutieCoreInterface _core, PluginsInterface _plugins, SaleInterface _sale, BlockchainCutiesERC1155Interface _token1155) external onlyOwner
    {
        core = _core;
        plugins = _plugins;
        sale = _sale;
        token1155 = _token1155;
    }

    function deposit() external payable
    {
        // accept money
    }

    function buyCutie(uint40 _orderId, uint40 _cutieId, uint _value, address _saleMarketAddress, address _purchaser) external onlyOperator
    {
        MarketInterface market = MarketInterface(_saleMarketAddress);
        market.bid.value(_value)(_cutieId);

        core.transfer(_purchaser, _cutieId);

        emit OrderSuccess(_orderId, _value, _purchaser);
    }

    function buySaleLot(uint40 _orderId, uint32 _lotId, uint _value, address _purchaser) external onlyOperator
    {
        uint256[5] memory rewardsToken1155tokenId;
        uint256[5] memory rewardsToken1155count;
        //uint256[5] memory rewardsNFTMintNftKind;
        uint256[5] memory rewardsNFTFixedKind;
        uint256[5] memory rewardsNFTFixedIndex;
        //uint256[5] memory rewardsCutieGenome;
        //uint256[5] memory rewardsCutieGeneration;

        (rewardsToken1155tokenId,
        rewardsToken1155count,
        ,
        rewardsNFTFixedKind,
        rewardsNFTFixedIndex,
        ,
        ) = sale.getLotRewards(_lotId);
        uint totalCutiesBefore = core.totalSupply();

        sale.bidWithPlugin(_lotId, _value, address(0x0));

        uint totalCutiesAfter = core.totalSupply();

        uint i;

        // assume that all new cuties are created inside bidWithPlugin and owner is this proxy contract.
        for (i = totalCutiesBefore + 1; i <= totalCutiesAfter; i++)
        {
            core.transfer(_purchaser, i);
        }

        for (i = 0; i < 5; i++)
        {
            if (rewardsToken1155tokenId[i] > 0)
            {
                token1155.safeTransferFrom(address(this), _purchaser, rewardsToken1155tokenId[i], rewardsToken1155count[i], "");
            }
        }

        for (i = 5-1; ; i--)
        {
            if (rewardsNFTFixedKind[i] > 0)
            {
                uint tokenId = (uint256(rewardsNFTFixedKind[i]) << 128) | (1 << 255) | rewardsNFTFixedIndex[i];
                token1155.safeTransferFrom(address(this), _purchaser, tokenId, 1, "");
                break;
            }
            if (i == 0) break;
        }

        emit OrderSuccess(_orderId, _value, _purchaser);
    }

    function runPlugin(
        uint40 _orderId,
        address _pluginAddress,
        uint40 _signId,
        uint40 _cutieId,
        uint128 _value,
        uint256 _parameter,
        address _purchaser) external onlyOperator
    {
        plugins.runPluginOperator.value(_value)(_pluginAddress, _signId, _cutieId, _value, _parameter, _purchaser);

        emit OrderSuccess(_orderId, _value, _purchaser);
    }

    function isERC1155TokenReceiver() external view returns (bytes4)
    {
        return bytes4(keccak256("isERC1155TokenReceiver()"));
    }

    function onERC1155BatchReceived(address, address, uint256[], uint256[], bytes) external returns(bytes4)
    {
        return bytes4(keccak256("accept_batch_erc1155_tokens()"));
    }

    function onERC1155Received(address, address, uint256, uint256, bytes) external returns(bytes4)
    {
        return bytes4(keccak256("accept_erc1155_tokens()"));
    }
}
