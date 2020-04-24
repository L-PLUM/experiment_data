/**
 *Submitted for verification at Etherscan.io on 2019-02-08
*/

pragma solidity ^0.4.23;


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev Integer division of two numbers, truncating the quotient.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        // uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return a / b;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender)
    public view returns (uint256);

    function transferFrom(address from, address to, uint256 value)
    public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}


contract HoQuConfigI {
    address public commissionWallet;
    uint256 public commission = 0.005 ether;
    mapping (uint16 => address) public owners;
    uint16 public ownersCount;

    function setCommissionWallet(address _commissionWallet) public;
    function setCommission(uint256 _commission) public;
    function addOwner(address _owner) public;
    function changeOwner(uint16 i, address _owner) public;
    function deleteOwner(uint16 i) public;
    function isAllowed(address _owner) public returns (bool);
}


contract HoQuStorageSchema {
    enum Status {NotExists, Created, Pending, Active, Done, Declined}
    enum KycLevel {Undefined, Tier1, Tier2, Tier3, Tier4, Tier5}

    struct User {
        address ownerAddress;
        mapping (uint8 => address) addresses;
        uint8 numOfAddresses;
        string role;
        KycLevel kycLevel;
        string pubKey;
        uint createdAt;
        Status status;
    }

    struct Identification {
        bytes16 userId;
        bytes16 companyId;
        string idType;
        string name;
        mapping (uint16 => KycReport) kycReports;
        uint16 numOfKycReports;
        uint createdAt;
        Status status;
    }

    struct KycReport {
        string meta;
        KycLevel kycLevel;
        string dataUrl;
        uint createdAt;
    }

    struct Stats {
        uint256 rating;
        uint256 volume;
        uint256 members;
        uint256 alfa;
        uint256 beta;
        Status status;
    }

    struct Company {
        bytes16 ownerId;
        string name;
        string dataUrl;
        uint createdAt;
        Status status;
    }

    struct Network {
        bytes16 ownerId;
        string name;
        string dataUrl;
        uint createdAt;
        Status status;
    }

    struct Tracker {
        bytes16 ownerId;
        bytes16 networkId;
        string name;
        string dataUrl;
        uint createdAt;
        Status status;
    }

    struct Offer {
        bytes16 ownerId;
        bytes16 networkId;
        bytes16 merchantId;
        address payerAddress;
        string name;
        string dataUrl;
        mapping (uint8 => bytes16) tariffGroups;
        uint8 numOfTariffGroups;
        uint createdAt;
        Status status;
    }

    struct AdCampaign {
        bytes16 ownerId;
        bytes16 offerId;
        address contractAddress;
        uint createdAt;
        Status status;
    }

    struct TariffGroup {
        bytes16 ownerId;
        string name;
        mapping (uint8 => bytes16) tariffs;
        uint8 numOfTariffs;
        uint createdAt;
        Status status;
    }

    struct Tariff {
        bytes16 tariffGroupId;
        string name;
        string action;
        string calcMethod;
        uint256 price;
        uint createdAt;
        Status status;
    }
}


contract HoQuStorageI {
    mapping (bytes16 => HoQuStorageSchema.User) public users;
    mapping (bytes16 => HoQuStorageSchema.Identification) public ids;
    mapping (bytes16 => HoQuStorageSchema.Stats) public stats;
    mapping (bytes16 => HoQuStorageSchema.Company) public companies;
    mapping (bytes16 => HoQuStorageSchema.Network) public networks;
    mapping (bytes16 => HoQuStorageSchema.Offer) public offers;
    mapping (bytes16 => HoQuStorageSchema.Tracker) public trackers;
    mapping (bytes16 => HoQuStorageSchema.AdCampaign) public adCampaigns;
    mapping (bytes16 => HoQuStorageSchema.Tariff) public tariffs;
    mapping (bytes16 => HoQuStorageSchema.TariffGroup) public tariffGroups;

    function setUser(bytes16 id, string role, address ownerAddress, HoQuStorageSchema.KycLevel kycLevel, string pubKey, HoQuStorageSchema.Status status) public;
    function addUserAddress(bytes16 id, address ownerAddress) public;
    function getUserAddress(bytes16 id, uint8 num) public constant returns (address);
    function setIdentification(bytes16 id, bytes16 userId, string idType, string name, bytes16 companyId, HoQuStorageSchema.Status status) public;
    function setStats(bytes16 id, bytes16 userId, uint256 rating, uint256 volume, uint256 members, uint256 alfa, uint256 beta, HoQuStorageSchema.Status status) public;
    function addKycReport(bytes16 id, string meta, HoQuStorageSchema.KycLevel kycLevel, string dataUrl) public;
    function getKycReport(bytes16 id, uint16 num) public constant returns (uint, string, HoQuStorageSchema.KycLevel, string);
    function setCompany(bytes16 id, bytes16 ownerId, string name, string dataUrl, HoQuStorageSchema.Status status) public;
    function setNetwork(bytes16 id, bytes16 ownerId, string name, string dataUrl, HoQuStorageSchema.Status status) public;
    function setTracker(bytes16 id, bytes16 ownerId, bytes16 networkId, string name, string dataUrl, HoQuStorageSchema.Status status) public;
    function setOffer(bytes16 id, bytes16 ownerId, bytes16 networkId, bytes16 merchantId, address payerAddress, string name, string dataUrl, HoQuStorageSchema.Status status) public;
    function addOfferTariffGroup(bytes16 id, bytes16 tariffGroupId) public;
    function getOfferTariffGroup(bytes16 id, uint8 num) public constant returns (bytes16);
    function setAdCampaign(bytes16 id, bytes16 ownerId, bytes16 offerId, address contractAddress, HoQuStorageSchema.Status status) public;
    function setTariffGroup(bytes16 id, bytes16 ownerId, string name, HoQuStorageSchema.Status status) public;
    function getTariffGroupTariff(bytes16 id, uint8 num) public constant returns (bytes16);
    function setTariff(bytes16 id, bytes16 tariffGroupId, string name, string action, string calcMethod, uint256 price, HoQuStorageSchema.Status status) public;
}


contract HoQuAdCampaignI {
    function saveLead(bytes16 id, bytes16 trackerId, bytes16 tariffId, string meta, string dataUrl, uint256 price, HoQuStorageSchema.Status status) public;
    function addLeadIntermediary(bytes16 id, address intermediaryAddress, uint32 percent) public;
    function transactLead(bytes16 id) public;
}


contract HoQuRaterI {
    function processAddLead(bytes16 offerId, bytes16 trackerId, bytes16 affiliateId, uint256 price) public;
    function processTransactLead(bytes16 offerId, bytes16 trackerId, bytes16 affiliateId, uint256 price) public;
}


contract HoQuTransactor {
    using SafeMath for uint256;

    HoQuConfigI public config;
    ERC20 public token;

    event TokenWithdrew(address indexed payerAddress, uint256 amount);
    event TokenSent(address indexed beneficiaryAddress, uint256 amount);

    modifier onlyOwner() {
        require(config.isAllowed(msg.sender), 'action is not allowed');
        _;
    }

    constructor(
        address configAddress,
        address tokenAddress
    ) public {
        config = HoQuConfigI(configAddress);
        token = ERC20(tokenAddress);
    }

    function setConfigAddress(address configAddress) public onlyOwner {
        config = HoQuConfigI(configAddress);
    }

    function setTokenAddress(address tokenAddress) public onlyOwner {
        token = ERC20(tokenAddress);
    }

    function withdraw(address payerAddress, uint256 amount) public onlyOwner {
        require(token.allowance(payerAddress, this) >= amount, 'not enough allowance to withdraw tokens');
        require(token.balanceOf(payerAddress) >= amount, 'not enough balance to withdraw tokens');
        token.transferFrom(payerAddress, this, amount);

        emit TokenWithdrew(payerAddress, amount);
    }

    function send(address beneficiaryAddress, uint256 amount) public onlyOwner {
        token.transfer(beneficiaryAddress, amount);

        emit TokenSent(beneficiaryAddress, amount);
    }
}


contract HoQuStorageAccessor {
    using SafeMath for uint256;

    HoQuConfigI public config;
    HoQuStorageI public store;

    modifier onlyOwner() {
        require(config.isAllowed(msg.sender), 'action is not allowed');
        _;
    }

    constructor(
        address configAddress,
        address storageAddress
    ) public {
        config = HoQuConfigI(configAddress);
        store = HoQuStorageI(storageAddress);
    }

    function setConfigAddress(address configAddress) public onlyOwner {
        config = HoQuConfigI(configAddress);
    }

    function setStorageAddress(address storageAddress) public onlyOwner {
        store = HoQuStorageI(storageAddress);
    }

    function getUser(bytes16 id) internal returns (HoQuStorageSchema.User) {
        HoQuStorageSchema.User memory user;
        (user.ownerAddress, user.numOfAddresses, user.role, user.kycLevel, user.pubKey, user.createdAt, user.status) = store.users(id);
        require(user.status != HoQuStorageSchema.Status.NotExists, 'user does not exists');

        return user;
    }

    function setUser(bytes16 id, HoQuStorageSchema.User user) internal {
        return store.setUser(id, user.role, user.ownerAddress, user.kycLevel, user.pubKey, user.status);
    }

    function getUserAddress(bytes16 id, uint8 num) public constant returns (address) {
        return store.getUserAddress(id, num);
    }

    function getIdentification(bytes16 id) internal returns (HoQuStorageSchema.Identification) {
        HoQuStorageSchema.Identification memory identification;
        (identification.userId, identification.companyId, identification.idType, identification.name, identification.numOfKycReports, identification.createdAt, identification.status) = store.ids(id);
        require(identification.status != HoQuStorageSchema.Status.NotExists, 'identification does not exists');

        return identification;
    }

    function getKyc(bytes16 id, uint16 num) internal returns (HoQuStorageSchema.KycReport) {
        HoQuStorageSchema.KycReport memory kycReport;
        (kycReport.createdAt, kycReport.meta, kycReport.kycLevel, kycReport.dataUrl) = store.getKycReport(id, num);

        return kycReport;
    }

    function addKyc(bytes16 id, HoQuStorageSchema.KycReport kycReport) internal {
        return store.addKycReport(id, kycReport.meta, kycReport.kycLevel, kycReport.dataUrl);
    }

    function getCompany(bytes16 id) internal returns (HoQuStorageSchema.Company) {
        HoQuStorageSchema.Company memory company;
        (company.ownerId, company.name, company.dataUrl, company.createdAt, company.status) = store.companies(id);
        require(company.status != HoQuStorageSchema.Status.NotExists, 'company does not exists');

        return company;
    }

    function getNetwork(bytes16 id) internal returns (HoQuStorageSchema.Network) {
        HoQuStorageSchema.Network memory network;
        (network.ownerId, network.name, network.dataUrl, network.createdAt, network.status) = store.networks(id);
        require(network.status != HoQuStorageSchema.Status.NotExists, 'network does not exists');

        return network;
    }

    function getTracker(bytes16 id) internal returns (HoQuStorageSchema.Tracker) {
        HoQuStorageSchema.Tracker memory tracker;
        (tracker.ownerId, tracker.networkId, tracker.name, tracker.dataUrl, tracker.createdAt, tracker.status) = store.trackers(id);
        require(tracker.status != HoQuStorageSchema.Status.NotExists, 'tracker does not exists');

        return tracker;
    }

    function getOffer(bytes16 id) internal returns (HoQuStorageSchema.Offer) {
        HoQuStorageSchema.Offer memory offer;
        (offer.ownerId, offer.networkId, offer.merchantId, offer.payerAddress, offer.name, offer.dataUrl,) = store.offers(id);
        (, offer.createdAt, offer.status) = store.offers(id);
        require(offer.status != HoQuStorageSchema.Status.NotExists, 'offer does not exists');

        return offer;
    }

    function getOfferTariffGroup(bytes16 id, uint8 num) public constant returns (bytes16) {
        return store.getOfferTariffGroup(id, num);
    }

    function getAdCampaign(bytes16 id) internal returns (HoQuStorageSchema.AdCampaign) {
        HoQuStorageSchema.AdCampaign memory adCampaign;
        (adCampaign.ownerId, adCampaign.offerId, adCampaign.contractAddress, adCampaign.createdAt, adCampaign.status) = store.adCampaigns(id);
        require(adCampaign.status != HoQuStorageSchema.Status.NotExists, 'adCampaign does not exists');

        return adCampaign;
    }

    function setAdCampaign(bytes16 id, HoQuStorageSchema.AdCampaign adCampaign) internal {
        return store.setAdCampaign(id, adCampaign.ownerId, adCampaign.offerId, adCampaign.contractAddress, adCampaign.status);
    }

    function getTariffGroup(bytes16 id) internal returns (HoQuStorageSchema.TariffGroup) {
        HoQuStorageSchema.TariffGroup memory tariffGroup;
        (tariffGroup.ownerId, tariffGroup.name, ) = store.tariffGroups(id);
        (, tariffGroup.numOfTariffs, tariffGroup.createdAt, tariffGroup.status) = store.tariffGroups(id);
        require(tariffGroup.status != HoQuStorageSchema.Status.NotExists, 'tariffGroup does not exists');

        return tariffGroup;
    }

    function getTariff(bytes16 id) internal returns (HoQuStorageSchema.Tariff) {
        HoQuStorageSchema.Tariff memory tariff;
        (tariff.tariffGroupId, tariff.name, tariff.action, tariff.calcMethod, tariff.price,) = store.tariffs(id);
        (, tariff.createdAt, tariff.status) = store.tariffs(id);
        require(tariff.status != HoQuStorageSchema.Status.NotExists, 'tariff does not exists');

        return tariff;
    }
}


contract HoQuAdCampaign is HoQuAdCampaignI, HoQuStorageAccessor {
    using SafeMath for uint256;

    struct Lead {
        uint createdAt;
        bytes16 trackerId;
        bytes16 tariffId;
        string dataUrl;
        string meta;
        uint256 price;
        mapping (uint8 => address) intermediaryAddresses;
        mapping (uint8 => uint32) intermediaryPercents;
        uint8 numOfIntermediaries;
        HoQuStorageSchema.Status status;
    }

    HoQuTransactor public transactor;
    HoQuRaterI public rater;

    bytes16 public adId;
    bytes16 public offerId;
    bytes16 public affiliateId;
    address public beneficiaryAddress;
    address public payerAddress;
    HoQuStorageSchema.Status public status;

    mapping (bytes16 => Lead) public leads;
    mapping (address => bytes16) public trackers;

    event StatusChanged(address indexed payerAddress, HoQuStorageSchema.Status newStatus);
    event BeneficiaryAddressChanged(address indexed beneficiaryAddress, address indexed newBeneficiaryAddress);
    event PayerAddressChanged(address indexed payerAddress, address indexed newPayerAddress);
    event LeadAdded(address indexed beneficiaryAddress, bytes16 id, uint256 price, address senderAddress);
    event LeadTransacted(address indexed beneficiaryAddress, bytes16 id, uint256 amount, address senderAddress);
    event LeadChanged(address indexed senderAddress, bytes16 id);
    event TrackerAdded(address indexed ownerAddress, bytes16 id);

    modifier onlyOwnerOrTracker() {
        require(config.isAllowed(msg.sender) || trackers[msg.sender] != 0, 'action is not allowed');
        _;
    }

    constructor(
        address configAddress,
        address transactorAddress,
        address storageAddress,
        address raterAddress,
        bytes16 _adId,
        bytes16 _offerId,
        bytes16 _affiliateId,
        address _beneficiaryAddress,
        address _payerAddress
    ) HoQuStorageAccessor(
        configAddress,
        storageAddress
    ) public {
        transactor = HoQuTransactor(transactorAddress);
        rater = HoQuRaterI(raterAddress);
        adId = _adId;
        offerId = _offerId;
        affiliateId = _affiliateId;
        beneficiaryAddress = _beneficiaryAddress;
        payerAddress = _payerAddress;
        status = HoQuStorageSchema.Status.Created;
    }

    function setTransactorAddress(address transactorAddress) public onlyOwner {
        transactor = HoQuTransactor(transactorAddress);
    }

    function setRaterAddress(address raterAddress) public onlyOwner {
        rater = HoQuRaterI(raterAddress);
    }

    function setBeneficiaryAddress(address _beneficiaryAddress) public onlyOwner {
        emit BeneficiaryAddressChanged(beneficiaryAddress, _beneficiaryAddress);

        beneficiaryAddress = _beneficiaryAddress;
    }

    function setPayerAddress(address _payerAddress) public onlyOwner {
        emit PayerAddressChanged(payerAddress, _payerAddress);

        payerAddress = _payerAddress;
    }

    function addTracker(address ownerAddress, bytes16 id) public onlyOwner {
        trackers[ownerAddress] = id;

        emit TrackerAdded(ownerAddress, id);
    }

    function setStatus(HoQuStorageSchema.Status _status) public onlyOwner {
        status = _status;

        HoQuStorageSchema.AdCampaign memory adCampaign = getAdCampaign(adId);
        require(adCampaign.status != HoQuStorageSchema.Status.NotExists, 'ad campaign does not exist');

        adCampaign.status = _status;
        setAdCampaign(adId, adCampaign);

        emit StatusChanged(payerAddress, _status);
    }

    function test1(bytes16 trackerId) public constant returns (HoQuStorageSchema.Status) {
        HoQuStorageSchema.Tracker memory tracker = getTracker(trackerId);
        return tracker.status;
    }

    function test2() public onlyOwnerOrTracker returns (uint8) {
        return 1;
    }

    function test3(bytes16 trackerId, uint256 price) public constant returns (uint8) {
        rater.processAddLead(offerId, trackerId, affiliateId, price);

        return 1;
    }

    function saveLead(bytes16 id, bytes16 trackerId, bytes16 tariffId, string meta, string dataUrl, uint256 price, HoQuStorageSchema.Status _status) public onlyOwnerOrTracker {
        HoQuStorageSchema.Tracker memory tracker = getTracker(trackerId);

        if(leads[id].status == HoQuStorageSchema.Status.NotExists) {
            leads[id] = Lead({
                createdAt : now,
                trackerId : trackerId,
                tariffId : tariffId,
                meta : meta,
                dataUrl : dataUrl,
                price : price,
                numOfIntermediaries : 0,
                status : HoQuStorageSchema.Status.Created
                });

            rater.processAddLead(offerId, trackerId, affiliateId, price);

            emit LeadAdded(beneficiaryAddress, id, price, msg.sender);
        } else {
            if (trackerId != 0) {
                leads[id].trackerId = trackerId;
            }
            if (tariffId != 0) {
                leads[id].tariffId = tariffId;
            }
            if (bytes(meta).length != 0) {
                leads[id].meta = meta;
            }
            if (bytes(dataUrl).length != 0) {
                leads[id].dataUrl = dataUrl;
            }
            if (price > 0) {
                leads[id].price = price;
            }
            if (_status != HoQuStorageSchema.Status.NotExists) {
                leads[id].status = _status;
            }

            emit LeadChanged(msg.sender, id);
        }
    }

    function addLeadIntermediary(bytes16 id, address intermediaryAddress, uint32 percent) public onlyOwnerOrTracker {
        require(leads[id].status != HoQuStorageSchema.Status.NotExists, 'lead does not exist');

        leads[id].intermediaryAddresses[leads[id].numOfIntermediaries] = intermediaryAddress;
        leads[id].intermediaryPercents[leads[id].numOfIntermediaries] = percent;
        leads[id].numOfIntermediaries++;
    }

    function transactLead(bytes16 id) public onlyOwnerOrTracker {
        require(leads[id].status != HoQuStorageSchema.Status.Done && leads[id].status != HoQuStorageSchema.Status.Declined, 'wrong lead status');
        require(leads[id].price > 0, 'lead price should be positive');

        leads[id].status = HoQuStorageSchema.Status.Done;

        Lead storage lead = leads[id];

        uint256 commissionAmount = lead.price.mul(config.commission()).div(1 ether);
        uint256 ownerAmount = lead.price.sub(commissionAmount);

        transactor.withdraw(payerAddress, lead.price);
        transactor.send(config.commissionWallet(), commissionAmount);

        for (uint8 i = 0; i < lead.numOfIntermediaries; i++) {
            address receiver = lead.intermediaryAddresses[i];
            // Percent in micro-percents, i.e. 0.04% = 400 000 micro-percents
            uint32 percent = lead.intermediaryPercents[i];
            uint256 intermediaryAmount = lead.price.mul(percent).div(1e8);

            require(ownerAmount > intermediaryAmount, 'not enough tokens to pay intermediary');
            ownerAmount = ownerAmount.sub(intermediaryAmount);

            transactor.send(receiver, intermediaryAmount);
        }

        transactor.send(beneficiaryAddress, ownerAmount);

        rater.processTransactLead(offerId, lead.trackerId, affiliateId, lead.price);

        emit LeadTransacted(beneficiaryAddress, id, ownerAmount, msg.sender);
    }

    function getLeadIntermediaryAddress(bytes16 id, uint8 num) public constant returns (address) {
        require(leads[id].status != HoQuStorageSchema.Status.NotExists, 'lead does not exist');

        return leads[id].intermediaryAddresses[num];
    }

    function getLeadIntermediaryPercent(bytes16 id, uint8 num) public constant returns (uint32) {
        require(leads[id].status != HoQuStorageSchema.Status.NotExists, 'lead does not exist');

        return leads[id].intermediaryPercents[num];
    }
}
