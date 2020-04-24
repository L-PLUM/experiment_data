/**
 *Submitted for verification at Etherscan.io on 2019-02-08
*/

pragma solidity ^0.4.25;


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


contract HoQuStorage is HoQuStorageI, HoQuStorageSchema {
    using SafeMath for uint256;

    HoQuConfigI public config;

    modifier onlyOwner() {
        require(config.isAllowed(msg.sender), 'action is not allowed');
        _;
    }

    constructor(address configAddress) public {
        config = HoQuConfigI(configAddress);
    }

    function setConfigAddress(address configAddress) public onlyOwner {
        config = HoQuConfigI(configAddress);
    }

    function setUser(bytes16 id, string role, address ownerAddress, KycLevel kycLevel, string pubKey, Status status) public onlyOwner {
        if (users[id].status == Status.NotExists) {
            users[id] = User({
                ownerAddress: ownerAddress,
                createdAt : now,
                numOfAddresses : 1,
                role : role,
                kycLevel : KycLevel.Tier1,
                pubKey : pubKey,
                status : Status.Created
                });
            users[id].addresses[0] = ownerAddress;
        } else {
            if (bytes(role).length != 0) {
                users[id].role = role;
            }
            if (ownerAddress != address(0)) {
                users[id].addresses[0] = ownerAddress;
            }
            if (kycLevel != KycLevel.Undefined) {
                users[id].kycLevel = kycLevel;
            }
            if (bytes(pubKey).length != 0) {
                users[id].pubKey = pubKey;
            }
            if (status != Status.NotExists) {
                users[id].status = status;
            }
        }
    }

    function addUserAddress(bytes16 id, address ownerAddress) public onlyOwner {
        require(users[id].status != Status.NotExists, 'user does not exist');

        users[id].addresses[users[id].numOfAddresses] = ownerAddress;
        users[id].numOfAddresses++;
    }

    function getUserAddress(bytes16 id, uint8 num) public constant returns (address) {
        require(users[id].status != Status.NotExists, 'user does not exist');

        return users[id].addresses[num];
    }

    function setIdentification(bytes16 id, bytes16 userId, string idType, string name, bytes16 companyId, Status status) public onlyOwner {
        if (ids[id].status == Status.NotExists) {
            address ownerAddress = getUserAddress(userId, 0);

            ids[id] = Identification({
                createdAt : now,
                userId : userId,
                idType : idType,
                name: name,
                companyId : companyId,
                numOfKycReports : 0,
                status : Status.Created
                });
        } else {
            if (bytes(idType).length != 0) {
                ids[id].idType = idType;
            }
            if (companyId != 0) {
                ids[id].companyId = companyId;
            }
            if (status != Status.NotExists) {
                ids[id].status = status;
            }
        }
    }

    function setStats(bytes16 id, bytes16 userId, uint256 rating, uint256 volume, uint256 members, uint256 alfa, uint256 beta, Status status) public onlyOwner {
        if (stats[id].status == Status.NotExists) {
            address ownerAddress = userId > 0 ? getUserAddress(userId, 0) : address(0);

            stats[id] = Stats({
                rating : rating,
                volume : volume,
                members : members,
                alfa : alfa,
                beta : beta,
                status : Status.Created
                });
            if (userId > 0) {
                stats[userId] = stats[id];
            }
        } else {
            if (rating != 0) {
                stats[id].rating = rating;
                if (userId > 0) {
                    stats[userId].rating = rating;
                }
            }
            if (volume != 0) {
                stats[id].volume = volume;
                if (userId > 0) {
                    stats[userId].volume = volume;
                }
            }
            if (members != 0) {
                stats[id].members = members;
                if (userId > 0) {
                    stats[userId].members = members;
                }
            }
            if (alfa != 0) {
                stats[id].alfa = alfa;
                if (userId > 0) {
                    stats[userId].alfa = alfa;
                }
            }
            if (beta != 0) {
                stats[id].beta = beta;
                if (userId > 0) {
                    stats[userId].beta = beta;
                }
            }
            if (status != Status.NotExists) {
                stats[id].status = status;
            }
        }
    }

    function addKycReport(bytes16 id, string meta, KycLevel kycLevel, string dataUrl) public onlyOwner {
        require(ids[id].status != Status.NotExists, 'identification does not exist');

        ids[id].kycReports[ids[id].numOfKycReports] = KycReport({
            createdAt : now,
            meta : meta,
            kycLevel : kycLevel,
            dataUrl : dataUrl
            });
        ids[id].numOfKycReports++;
    }

    function getKycReport(bytes16 id, uint16 num) public constant returns (uint, string, KycLevel, string) {
        require(ids[id].status != Status.NotExists, 'identification does not exist');

        return (
        ids[id].kycReports[num].createdAt,
        ids[id].kycReports[num].meta,
        ids[id].kycReports[num].kycLevel,
        ids[id].kycReports[num].dataUrl
        );
    }

    function setCompany(bytes16 id, bytes16 ownerId, string name, string dataUrl, Status status) public onlyOwner {
        if (companies[id].status == Status.NotExists) {
            require(users[ownerId].status != Status.NotExists, 'user does not exist');
            require(users[ownerId].addresses[0] != address(0));

            companies[id] = Company({
                createdAt : now,
                ownerId : ownerId,
                name : name,
                dataUrl : dataUrl,
                status : Status.Created
                });
        } else {
            if (bytes(name).length != 0) {
                companies[id].name = name;
            }
            if (bytes(dataUrl).length != 0) {
                companies[id].dataUrl = dataUrl;
            }
            if (status != Status.NotExists) {
                companies[id].status = status;
            }
        }
    }

    function setNetwork(bytes16 id, bytes16 ownerId, string name, string dataUrl, Status status) public onlyOwner {
        if (networks[id].status == Status.NotExists) {
            require(users[ownerId].status != Status.NotExists, 'user does not exist');
            require(users[ownerId].addresses[0] != address(0));

            networks[id] = Network({
                createdAt : now,
                ownerId : ownerId,
                name : name,
                dataUrl : dataUrl,
                status : Status.Created
                });
        } else {
            if (bytes(name).length != 0) {
                networks[id].name = name;
            }
            if (bytes(dataUrl).length != 0) {
                networks[id].dataUrl = dataUrl;
            }
            if (status != Status.NotExists) {
                networks[id].status = status;
            }
        }
    }

    function setTracker(bytes16 id, bytes16 ownerId, bytes16 networkId, string name, string dataUrl, Status status) public onlyOwner {
        if (networkId != 0) {
            require(networks[networkId].status != Status.NotExists, 'network does not exist');
        }

        if (trackers[id].status == Status.NotExists) {
            require(users[ownerId].status != Status.NotExists, 'user does not exist');
            require(users[ownerId].addresses[0] != address(0));

            trackers[id] = Tracker({
                createdAt : now,
                ownerId : ownerId,
                networkId : networkId,
                name : name,
                dataUrl : dataUrl,
                status : Status.Created
                });
        } else {
            if (networkId != 0) {
                trackers[id].networkId = networkId;
            }
            if (bytes(name).length != 0) {
                trackers[id].name = name;
            }
            if (bytes(dataUrl).length != 0) {
                trackers[id].dataUrl = dataUrl;
            }
            if (status != Status.NotExists) {
                trackers[id].status = status;
            }
        }
    }

    function setOffer(bytes16 id, bytes16 ownerId, bytes16 networkId, bytes16 merchantId, address payerAddress, string name, string dataUrl, Status status) public onlyOwner {
        if (networkId != 0) {
            require(networks[networkId].status != Status.NotExists, 'network does not exist');
        }
        if (merchantId != 0) {
            require(users[merchantId].status != Status.NotExists, 'merchant user does not exist');
        }

        if (offers[id].status == Status.NotExists) {
            require(users[ownerId].status != Status.NotExists, 'user does not exist');
            require(users[ownerId].addresses[0] != address(0));

            offers[id] = Offer({
                createdAt : now,
                networkId : networkId,
                merchantId: merchantId,
                ownerId : ownerId,
                payerAddress : payerAddress,
                name : name,
                dataUrl : dataUrl,
                numOfTariffGroups: 0,
                status : Status.Created
                });
        } else {
            if (networkId != 0) {
                offers[id].networkId = networkId;
            }
            if (merchantId != 0) {
                offers[id].merchantId = merchantId;
            }
            if (payerAddress != address(0)) {
                offers[id].payerAddress = payerAddress;
            }
            if (bytes(name).length != 0) {
                offers[id].name = name;
            }
            if (bytes(dataUrl).length != 0) {
                offers[id].dataUrl = dataUrl;
            }
            if (status != Status.NotExists) {
                offers[id].status = status;
            }
        }
    }

    function addOfferTariffGroup(bytes16 id, bytes16 tariffGroupId) public onlyOwner {
        require(offers[id].status != Status.NotExists, 'offer does not exist');

        offers[id].tariffGroups[offers[id].numOfTariffGroups] = tariffGroupId;
        offers[id].numOfTariffGroups++;

        address ownerAddress = getUserAddress(offers[id].ownerId, 0);
    }

    function getOfferTariffGroup(bytes16 id, uint8 num) public constant returns (bytes16) {
        require(offers[id].status != Status.NotExists, 'offer does not exist');

        return offers[id].tariffGroups[num];
    }

    function setAdCampaign(bytes16 id, bytes16 ownerId, bytes16 offerId, address contractAddress, Status status) public onlyOwner {
        if (adCampaigns[id].status == Status.NotExists) {
            require(users[ownerId].status != Status.NotExists, 'user does not exist');
            require(users[ownerId].addresses[0] != address(0));
            require(offers[offerId].status != Status.NotExists, 'offer does not exist');

            address ownerAddress = getUserAddress(ownerId, 0);

            adCampaigns[id] = AdCampaign({
                createdAt : now,
                offerId : offerId,
                ownerId : ownerId,
                contractAddress : contractAddress,
                status : Status.Created
                });
        } else {
            if (contractAddress != address(0)) {
                adCampaigns[id].contractAddress = contractAddress;
            }
            if (status != Status.NotExists) {
                adCampaigns[id].status = status;
            }
        }
    }

    function setTariffGroup(bytes16 id, bytes16 ownerId, string name, Status status) public onlyOwner {
        if (tariffGroups[id].status == Status.NotExists) {
            require(users[ownerId].status != Status.NotExists, 'user does not exist');

            address ownerAddress = getUserAddress(ownerId, 0);

            tariffGroups[id] = TariffGroup({
                createdAt : now,
                ownerId : ownerId,
                name : name,
                numOfTariffs: 0,
                status : Status.Created
                });
        } else {
            if (bytes(name).length != 0) {
                tariffGroups[id].name = name;
            }
            if (status != Status.NotExists) {
                tariffGroups[id].status = status;
            }
        }
    }

    function getTariffGroupTariff(bytes16 id, uint8 num) public constant returns (bytes16) {
        require(tariffGroups[id].status != Status.NotExists, 'tariff group does not exist');

        return tariffGroups[id].tariffs[num];
    }

    function setTariff(bytes16 id, bytes16 tariffGroupId, string name, string action, string calcMethod, uint256 price, Status status) public onlyOwner {
        if (tariffs[id].status == Status.NotExists) {
            require(tariffGroups[tariffGroupId].status != Status.NotExists, 'tariff group does not exist');

            address ownerAddress = getUserAddress(tariffGroups[tariffGroupId].ownerId, 0);

            tariffs[id] = Tariff({
                createdAt : now,
                tariffGroupId : tariffGroupId,
                name : name,
                action : action,
                calcMethod : calcMethod,
                price : price,
                status : Status.Created
                });

            tariffGroups[tariffGroupId].tariffs[tariffGroups[tariffGroupId].numOfTariffs] = id;
            tariffGroups[tariffGroupId].numOfTariffs++;
        } else {
            if (bytes(name).length != 0) {
                tariffs[id].name = name;
            }
            if (bytes(action).length != 0) {
                tariffs[id].action = action;
            }
            if (bytes(calcMethod).length != 0) {
                tariffs[id].calcMethod = calcMethod;
            }
            if (price != 0) {
                tariffs[id].price = price;
            }
            if (status != Status.NotExists) {
                tariffs[id].status = status;
            }
        }
    }
}
