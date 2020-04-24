/**
 *Submitted for verification at Etherscan.io on 2019-02-16
*/

pragma solidity ^0.5.1;

contract GlobalTradeSystem {

    // ------------------------------------------------------------------------------------------ //
    // STRUCTS / ENUMS
    // ------------------------------------------------------------------------------------------ //

    // Potential states of a TradeOffer
    enum TradeOfferState {
        PENDING,     // offer is valid and awaits confirmation or rejection
        CANCELLED, // offer was cancelled by the sender
        TAKEN    // offer was accepted and assets were successfully
    }

    // Defines a single asset metadata
    struct AssetMetadata {
        address emitter; // address of the trusted third party who emitted the asset
        bytes32 data;            // defines asset's metadata. Format [int, json, keccak256]
    }
    
    // Defines that asset with certain metadata is owner by someone
    struct Asset {
        address owner;
        AssetMetadata metadata;
    }


    // Defines a single trade offer
    struct TradeOffer {
        address sender;                // sender's address 
        address recipient;         // offer recipient address (0x0 if public)
        address[] my_assets_emitters;
        bytes32[] my_assets_data;
        address[] their_assets_emitters;
        bytes32[] their_assets_data;
        TradeOfferState state; // offer state
    }

    // ------------------------------------------------------------------------------------------ //
    // EVENTS
    // ------------------------------------------------------------------------------------------ //

    // Event which fires when a new asset is emitted    
    event AssetAssign (
        uint id,                 // asset id stored in global mapping
        address owner,        // address of user whom an asset has been assigned
        address emitter, // address which emitted the asset
        bytes32 data             // data associated with the asset
    );

    // Event which fires when an asset is burned
    event AssetBurn (
        uint id // id of burned asset
    );

    // Event which fires when an asset changes its owner
    event AssetMove (
        uint id,            // id of the moved asset
        address from, // previous owner of the asset
        address to        // new owner of the asset
    );

    // Event which fires when a trade offer has been sent
    event TradeOfferSend (
        uint id,                                    // id of the offer
        address indexed sender,     // address of the offer's sender
        address indexed receiver, // address of the offer's recipient
        address[] my_assets_emitters,
        bytes32[] my_assets_data,
        address[] their_assets_emitters,
        bytes32[] their_assets_data
    );
    
    // Event fires when a trade offer has been modified
    event TradeOfferModify (
        uint indexed id,            // id of modified offer 
        TradeOfferState state // new state of the offer
    );

    // ------------------------------------------------------------------------------------------ //
    // FIELDS
    // ------------------------------------------------------------------------------------------ //    

    mapping(uint => Asset) assets;            // stores all Assets
    mapping(uint => TradeOffer) offers; // stores all TradeOffers
    uint last_asset_id;                                 // stores last asset id
    uint last_offer_id;                                 // stores last offer id
    mapping(address => uint) assetCount;
    mapping(address => uint[]) inboxedTradeOffers;

    // ------------------------------------------------------------------------------------------ //
    // INTERNAL FUNCTIONS
    // ------------------------------------------------------------------------------------------ //

    // Changes the owner of an Asset    
    function setAssetOwner(uint _id, address _new_owner) internal {
        assetCount[assets[_id].owner]--;
        assetCount[_new_owner]++;
        emit AssetMove(_id, assets[_id].owner, _new_owner);
        assets[_id].owner = _new_owner;
    }

    // ------------------------------------------------------------------------------------------ //
    // EXTERNAL VIEW FUNCTIONS
    // ------------------------------------------------------------------------------------------ //

    // Gets information about an Asset
    function getAsset(uint _id) external view returns(
        address owner,
        address emitter,
        bytes32 data
    ) {
        return (assets[_id].owner, assets[_id].metadata.emitter, assets[_id].metadata.data);
    }

    // Returns TradeOffer details by its id
    function getTradeOffer(uint _id) external view returns(
        address sender,
        address recipient,
        address[] memory my_assets_emitters,
        bytes32[] memory my_assets_data,
        address[] memory their_assets_emitters,
        bytes32[] memory their_assets_data,
        TradeOfferState state
    ) {
        return (
            offers[_id].sender,
            offers[_id].recipient,
            offers[_id].my_assets_emitters,
            offers[_id].my_assets_data,
            offers[_id].their_assets_emitters,
            offers[_id].their_assets_data,
            offers[_id].state
        );
    }

    // ------------------------------------------------------------------------------------------ //
    // EXTERNAL STATE-CHANGING FUNCTIONS
    // ------------------------------------------------------------------------------------------ //

    // Assigns a new asset to given address
    function assign(address _owner, bytes32 _data) external {
        last_asset_id++;
        assetCount[_owner]++;
        assets[last_asset_id] = Asset(_owner, AssetMetadata(msg.sender, _data));
        emit AssetAssign(last_asset_id, _owner, msg.sender, _data);
    }


    // Burns an asset by its id
    function burn(uint _id) external {
        require(
            assets[_id].metadata.emitter == msg.sender,
            "In order to burn an asset, you need to be the one who emitted it."
        );

        assetCount[assets[_id].owner]--;
        delete assets[_id];
        emit AssetBurn(_id);

    }

    // Sends a TradeOffer to other user
    function sendTradeOffer(
        address _partner,
        address[] calldata _my_assets_emitters,
        bytes32[] calldata _my_assets_data,
        address[] calldata _their_assets_emitters,
        bytes32[] calldata _their_assets_data
    ) external returns(uint) {
        last_offer_id++;
        offers[last_offer_id] = TradeOffer(
            msg.sender,
            _partner,
            _my_assets_emitters,
            _my_assets_data,
            _their_assets_emitters,
            _their_assets_data,
            TradeOfferState.PENDING
        );
        emit TradeOfferSend(
            last_offer_id,
            msg.sender,
            _partner,
            _my_assets_emitters,
            _my_assets_data,
            _their_assets_emitters,
            _their_assets_data
        );

        inboxedTradeOffers[_partner].push(last_offer_id);

        return last_offer_id;
    }

    // Cancels a sent TradeOffer
    function cancelTradeOffer(uint offer_id) external {
        require(offers[offer_id].sender == msg.sender, "This is not your offer.");
        require(offers[offer_id].state == TradeOfferState.PENDING, "This offer is not pending.");
        offers[offer_id].state = TradeOfferState.CANCELLED;
        emit TradeOfferModify(
            offer_id,
            TradeOfferState.CANCELLED
        );
    }

    function takeTradeOffer(uint _maker, uint[] calldata _maker_assets, uint _taker, uint[] calldata _taker_assets) external {
        require(offers[_maker].recipient == address(0) || offers[_maker].recipient == offers[_taker].sender, "Wrong recipient 1");
        require(offers[_taker].recipient == address(0) || offers[_taker].recipient == offers[_maker].sender, "Wrong recipient 2");
        for(uint i = 0; i < offers[_maker].my_assets_emitters.length; i++) {
            require(assets[_maker_assets[i]].owner == offers[_maker].sender, "1 Invalid ownership of maker assets.");
            require(assets[_maker_assets[i]].metadata.emitter == offers[_maker].my_assets_emitters[i], "1 Invalid emitter of maker asset.");
            require(assets[_maker_assets[i]].metadata.data == offers[_maker].my_assets_data[i], "1 Invalid data of maker asset.");
        }
        for(uint i = 0; i < offers[_taker].my_assets_emitters.length; i++) {
            require(assets[_taker_assets[i]].owner == offers[_taker].sender, "2 Invalid ownership of taker assets.");
            require(assets[_taker_assets[i]].metadata.emitter == offers[_taker].my_assets_emitters[i], "2 Invalid emitter of taker asset.");
            require(assets[_taker_assets[i]].metadata.data == offers[_taker].my_assets_data[i], "2 Invalid data of taker asset.");
        }
        for(uint i = 0; i < offers[_maker].their_assets_emitters.length; i++) {
            require(assets[_taker_assets[i]].owner == offers[_taker].sender, "3 Invalid ownership of maker assets.");
            require(assets[_taker_assets[i]].metadata.emitter == offers[_taker].their_assets_emitters[i], "3 Invalid emitter of maker asset.");
            require(assets[_taker_assets[i]].metadata.data == offers[_taker].their_assets_data[i], "3 Invalid data of maker asset.");
        }
        for(uint i = 0; i < offers[_taker].their_assets_emitters.length; i++) {
            require(assets[_maker_assets[i]].owner == offers[_maker].sender, "4 Invalid ownership of taker assets.");
            require(assets[_maker_assets[i]].metadata.emitter == offers[_maker].their_assets_emitters[i], "4 Invalid emitter of taker asset.");
            require(assets[_maker_assets[i]].metadata.data == offers[_maker].their_assets_data[i], "4 Invalid data of taker asset.");
        }
        for(uint i = 0; i < _maker_assets.length; i++) {
            setAssetOwner(i, offers[_taker].sender);
        }
        for(uint i = 0; i < _taker_assets.length; i++) {
            setAssetOwner(i, offers[_maker].sender);
        }
        offers[_maker].state = TradeOfferState.TAKEN;
        emit TradeOfferModify(_maker, TradeOfferState.TAKEN);
        offers[_taker].state = TradeOfferState.TAKEN;
        emit TradeOfferModify(_taker, TradeOfferState.TAKEN);
    }
    
    function getMyInventory() external view returns (uint[] memory) {
        uint[] memory asset_ids = new uint[](assetCount[msg.sender]);
        uint last = 0;
        for(uint i = 0; i <= last_asset_id; i++)
        {
            if(assets[i].owner == msg.sender)
            {
                asset_ids[last++] = i;
            }
        }
        return asset_ids;
    }

    function getMyOffers() external view returns(uint[] memory) {
        uint[] memory _offers = new uint[](inboxedTradeOffers[address(0)].length + inboxedTradeOffers[msg.sender].length);

        // append addressed offers 

        for(uint i = 0; i < inboxedTradeOffers[msg.sender].length; i++) {
            _offers[i] = inboxedTradeOffers[msg.sender][i];
        }
        
        // append public offers

        for(uint i = 0; i < inboxedTradeOffers[address(0)].length; i++) {
            _offers[inboxedTradeOffers[msg.sender].length + i - 1] = inboxedTradeOffers[address(0)][i];
        }

        return _offers;
    }
    
    function getUserInventory(address user) external view returns (uint[] memory) {
        uint[] memory asset_ids = new uint[](assetCount[user]);
        uint last = 0;
        for(uint i = 0; i <= last_asset_id; i++)
        {
            if(assets[i].owner == user)
            {
                asset_ids[last++] = i;
            }
        }
        return asset_ids;
    }

}
