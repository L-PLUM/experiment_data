/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity >=0.4.25 <0.6.0;
pragma experimental ABIEncoderV2;


contract Modifiable {
    
    
    
    modifier notNullAddress(address _address) {
        require(_address != address(0));
        _;
    }

    modifier notThisAddress(address _address) {
        require(_address != address(this));
        _;
    }

    modifier notNullOrThisAddress(address _address) {
        require(_address != address(0));
        require(_address != address(this));
        _;
    }

    modifier notSameAddresses(address _address1, address _address2) {
        if (_address1 != _address2)
            _;
    }
}

contract SelfDestructible {
    
    
    
    bool public selfDestructionDisabled;

    
    
    
    event SelfDestructionDisabledEvent(address wallet);
    event TriggerSelfDestructionEvent(address wallet);

    
    
    
    
    function destructor()
    public
    view
    returns (address);

    
    
    function disableSelfDestruction()
    public
    {
        
        require(destructor() == msg.sender);

        
        selfDestructionDisabled = true;

        
        emit SelfDestructionDisabledEvent(msg.sender);
    }

    
    function triggerSelfDestruction()
    public
    {
        
        require(destructor() == msg.sender);

        
        require(!selfDestructionDisabled);

        
        emit TriggerSelfDestructionEvent(msg.sender);

        
        selfdestruct(msg.sender);
    }
}

contract Ownable is Modifiable, SelfDestructible {
    
    
    
    address public deployer;
    address public operator;

    
    
    
    event SetDeployerEvent(address oldDeployer, address newDeployer);
    event SetOperatorEvent(address oldOperator, address newOperator);

    
    
    
    constructor(address _deployer) internal notNullOrThisAddress(_deployer) {
        deployer = _deployer;
        operator = _deployer;
    }

    
    
    
    
    function destructor()
    public
    view
    returns (address)
    {
        return deployer;
    }

    
    
    function setDeployer(address newDeployer)
    public
    onlyDeployer
    notNullOrThisAddress(newDeployer)
    {
        if (newDeployer != deployer) {
            
            address oldDeployer = deployer;
            deployer = newDeployer;

            
            emit SetDeployerEvent(oldDeployer, newDeployer);
        }
    }

    
    
    function setOperator(address newOperator)
    public
    onlyOperator
    notNullOrThisAddress(newOperator)
    {
        if (newOperator != operator) {
            
            address oldOperator = operator;
            operator = newOperator;

            
            emit SetOperatorEvent(oldOperator, newOperator);
        }
    }

    
    
    function isDeployer()
    internal
    view
    returns (bool)
    {
        return msg.sender == deployer;
    }

    
    
    function isOperator()
    internal
    view
    returns (bool)
    {
        return msg.sender == operator;
    }

    
    
    
    function isDeployerOrOperator()
    internal
    view
    returns (bool)
    {
        return isDeployer() || isOperator();
    }

    
    
    modifier onlyDeployer() {
        require(isDeployer());
        _;
    }

    modifier notDeployer() {
        require(!isDeployer());
        _;
    }

    modifier onlyOperator() {
        require(isOperator());
        _;
    }

    modifier notOperator() {
        require(!isOperator());
        _;
    }

    modifier onlyDeployerOrOperator() {
        require(isDeployerOrOperator());
        _;
    }

    modifier notDeployerOrOperator() {
        require(!isDeployerOrOperator());
        _;
    }
}

library MonetaryTypesLib {
    
    
    
    struct Currency {
        address ct;
        uint256 id;
    }

    struct Figure {
        int256 amount;
        Currency currency;
    }

    struct NoncedAmount {
        uint256 nonce;
        int256 amount;
    }
}

library NahmiiTypesLib {
    
    
    
    enum ChallengePhase {Dispute, Closed}

    
    
    
    struct OriginFigure {
        uint256 originId;
        MonetaryTypesLib.Figure figure;
    }

    struct IntendedConjugateCurrency {
        MonetaryTypesLib.Currency intended;
        MonetaryTypesLib.Currency conjugate;
    }

    struct SingleFigureTotalOriginFigures {
        MonetaryTypesLib.Figure single;
        OriginFigure[] total;
    }

    struct TotalOriginFigures {
        OriginFigure[] total;
    }

    struct CurrentPreviousInt256 {
        int256 current;
        int256 previous;
    }

    struct SingleTotalInt256 {
        int256 single;
        int256 total;
    }

    struct IntendedConjugateCurrentPreviousInt256 {
        CurrentPreviousInt256 intended;
        CurrentPreviousInt256 conjugate;
    }

    struct IntendedConjugateSingleTotalInt256 {
        SingleTotalInt256 intended;
        SingleTotalInt256 conjugate;
    }

    struct WalletOperatorHashes {
        bytes32 wallet;
        bytes32 operator;
    }

    struct Signature {
        bytes32 r;
        bytes32 s;
        uint8 v;
    }

    struct Seal {
        bytes32 hash;
        Signature signature;
    }

    struct WalletOperatorSeal {
        Seal wallet;
        Seal operator;
    }
}

library TradeTypesLib {
    
    
    
    enum CurrencyRole {Intended, Conjugate}
    enum LiquidityRole {Maker, Taker}
    enum Intention {Buy, Sell}
    enum TradePartyRole {Buyer, Seller}

    
    
    
    struct OrderPlacement {
        Intention intention;

        int256 amount;
        NahmiiTypesLib.IntendedConjugateCurrency currencies;
        int256 rate;

        NahmiiTypesLib.CurrentPreviousInt256 residuals;
    }

    struct Order {
        uint256 nonce;
        address wallet;

        OrderPlacement placement;

        NahmiiTypesLib.WalletOperatorSeal seals;
        uint256 blockNumber;
        uint256 operatorId;
    }

    struct TradeOrder {
        int256 amount;
        NahmiiTypesLib.WalletOperatorHashes hashes;
        NahmiiTypesLib.CurrentPreviousInt256 residuals;
    }

    struct TradeParty {
        uint256 nonce;
        address wallet;

        uint256 rollingVolume;

        LiquidityRole liquidityRole;

        TradeOrder order;

        NahmiiTypesLib.IntendedConjugateCurrentPreviousInt256 balances;

        NahmiiTypesLib.SingleFigureTotalOriginFigures fees;
    }

    struct Trade {
        uint256 nonce;

        int256 amount;
        NahmiiTypesLib.IntendedConjugateCurrency currencies;
        int256 rate;

        TradeParty buyer;
        TradeParty seller;

        
        
        NahmiiTypesLib.IntendedConjugateSingleTotalInt256 transfers;

        NahmiiTypesLib.Seal seal;
        uint256 blockNumber;
        uint256 operatorId;
    }

    
    
    
    function TRADE_KIND()
    public
    pure
    returns (string memory)
    {
        return "trade";
    }

    function ORDER_KIND()
    public
    pure
    returns (string memory)
    {
        return "order";
    }
}

contract TradeHasher is Ownable {
    
    
    
    constructor(address deployer) Ownable(deployer) public {
    }

    
    
    
    function hashOrderAsWallet(TradeTypesLib.Order memory order)
    public
    pure
    returns (bytes32)
    {
        bytes32 rootHash = hashAddress(order.wallet);
        bytes32 placementHash = hashOrderPlacement(order.placement);

        return keccak256(abi.encodePacked(rootHash, placementHash));
    }

    function hashOrderAsOperator(TradeTypesLib.Order memory order)
    public
    pure
    returns (bytes32)
    {
        bytes32 rootHash = hashUint256(order.nonce);
        bytes32 walletSignatureHash = hashSignature(order.seals.wallet.signature);
        bytes32 placementResidualsHash = hashCurrentPreviousInt256(order.placement.residuals);

        return keccak256(abi.encodePacked(rootHash, walletSignatureHash, placementResidualsHash));
    }

    function hashTrade(TradeTypesLib.Trade memory trade)
    public
    pure
    returns (bytes32)
    {
        bytes32 rootHash = hashTradeRoot(trade);
        bytes32 buyerHash = hashTradeParty(trade.buyer);
        bytes32 sellerHash = hashTradeParty(trade.seller);
        bytes32 transfersHash = hashIntendedConjugateSingleTotalInt256(trade.transfers);

        return keccak256(abi.encodePacked(rootHash, buyerHash, sellerHash, transfersHash));
    }

    function hashOrderPlacement(TradeTypesLib.OrderPlacement memory orderPlacement)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                orderPlacement.intention,
                orderPlacement.amount,
                orderPlacement.currencies.intended.ct,
                orderPlacement.currencies.intended.id,
                orderPlacement.currencies.conjugate.ct,
                orderPlacement.currencies.conjugate.id,
                orderPlacement.rate
            ));
    }

    function hashTradeRoot(TradeTypesLib.Trade memory trade)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                trade.nonce,
                trade.amount,
                trade.currencies.intended.ct,
                trade.currencies.intended.id,
                trade.currencies.conjugate.ct,
                trade.currencies.conjugate.id,
                trade.rate
            ));
    }

    function hashTradeParty(TradeTypesLib.TradeParty memory tradeParty)
    public
    pure
    returns (bytes32)
    {
        bytes32 rootHash = hashTradePartyRoot(tradeParty);
        bytes32 orderHash = hashTradeOrder(tradeParty.order);
        bytes32 balancesHash = hashIntendedConjugateCurrentPreviousInt256(tradeParty.balances);
        bytes32 singleFeeHash = hashFigure(tradeParty.fees.single);
        bytes32 totalFeesHash = hashOriginFigures(tradeParty.fees.total);

        return keccak256(abi.encodePacked(
                rootHash, orderHash, balancesHash, singleFeeHash, totalFeesHash
            ));
    }

    function hashTradePartyRoot(TradeTypesLib.TradeParty memory tradeParty)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                tradeParty.nonce,
                tradeParty.wallet,
                tradeParty.rollingVolume,
                tradeParty.liquidityRole
            ));
    }

    function hashTradeOrder(TradeTypesLib.TradeOrder memory tradeOrder)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                tradeOrder.hashes.wallet,
                tradeOrder.hashes.operator,
                tradeOrder.amount,
                tradeOrder.residuals.current,
                tradeOrder.residuals.previous
            ));
    }

    function hashIntendedConjugateSingleTotalInt256(
        NahmiiTypesLib.IntendedConjugateSingleTotalInt256 memory intededConjugateSingleTotalInt256)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                intededConjugateSingleTotalInt256.intended.single,
                intededConjugateSingleTotalInt256.intended.total,
                intededConjugateSingleTotalInt256.conjugate.single,
                intededConjugateSingleTotalInt256.conjugate.total
            ));
    }

    function hashCurrentPreviousInt256(
        NahmiiTypesLib.CurrentPreviousInt256 memory currentPreviousInt256)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                currentPreviousInt256.current,
                currentPreviousInt256.previous
            ));
    }

    function hashIntendedConjugateCurrentPreviousInt256(
        NahmiiTypesLib.IntendedConjugateCurrentPreviousInt256 memory intendedConjugateCurrentPreviousInt256)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                intendedConjugateCurrentPreviousInt256.intended.current,
                intendedConjugateCurrentPreviousInt256.intended.previous,
                intendedConjugateCurrentPreviousInt256.conjugate.current,
                intendedConjugateCurrentPreviousInt256.conjugate.previous
            ));
    }

    function hashFigure(MonetaryTypesLib.Figure memory figure)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                figure.amount,
                figure.currency.ct,
                figure.currency.id
            ));
    }

    function hashOriginFigures(NahmiiTypesLib.OriginFigure[] memory originFigures)
    public
    pure
    returns (bytes32)
    {
        bytes32 hash;
        for (uint256 i = 0; i < originFigures.length; i++) {
            hash = keccak256(abi.encodePacked(
                    hash,
                    originFigures[i].originId,
                    originFigures[i].figure.amount,
                    originFigures[i].figure.currency.ct,
                    originFigures[i].figure.currency.id
                )
            );
        }
        return hash;
    }

    function hashUint256(uint256 _uint256)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(_uint256));
    }

    function hashAddress(address _address)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(_address));
    }

    function hashSignature(NahmiiTypesLib.Signature memory signature)
    public
    pure
    returns (bytes32)
    {
        return keccak256(abi.encodePacked(
                signature.v,
                signature.r,
                signature.s
            ));
    }
}
