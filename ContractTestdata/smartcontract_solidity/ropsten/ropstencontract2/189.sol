/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity >=0.4.25 <0.6.0;


library SafeMathIntLib {
    int256 constant INT256_MIN = int256((uint256(1) << 255));
    int256 constant INT256_MAX = int256(~((uint256(1) << 255)));

    
    
    
    function div(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        require(a != INT256_MIN || b != - 1);
        return a / b;
    }

    function mul(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        require(a != - 1 || b != INT256_MIN);
        
        require(b != - 1 || a != INT256_MIN);
        
        int256 c = a * b;
        require((b == 0) || (c / b == a));
        return c;
    }

    function sub(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        require((b >= 0 && a - b <= a) || (b < 0 && a - b > a));
        return a - b;
    }

    function add(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));
        return c;
    }

    
    
    
    function div_nn(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        require(a >= 0 && b > 0);
        return a / b;
    }

    function mul_nn(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        require(a >= 0 && b >= 0);
        int256 c = a * b;
        require(a == 0 || c / a == b);
        require(c >= 0);
        return c;
    }

    function sub_nn(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        require(a >= 0 && b >= 0 && b <= a);
        return a - b;
    }

    function add_nn(int256 a, int256 b)
    internal
    pure
    returns (int256)
    {
        require(a >= 0 && b >= 0);
        int256 c = a + b;
        require(c >= a);
        return c;
    }

    
    
    
    function abs(int256 a)
    public
    pure
    returns (int256)
    {
        return a < 0 ? neg(a) : a;
    }

    function neg(int256 a)
    public
    pure
    returns (int256)
    {
        return mul(a, - 1);
    }

    function toNonZeroInt256(uint256 a)
    public
    pure
    returns (int256)
    {
        require(a > 0 && a < (uint256(1) << 255));
        return int256(a);
    }

    function toInt256(uint256 a)
    public
    pure
    returns (int256)
    {
        require(a >= 0 && a < (uint256(1) << 255));
        return int256(a);
    }

    function toUInt256(int256 a)
    public
    pure
    returns (uint256)
    {
        require(a >= 0);
        return uint256(a);
    }

    function isNonZeroPositiveInt256(int256 a)
    public
    pure
    returns (bool)
    {
        return (a > 0);
    }

    function isPositiveInt256(int256 a)
    public
    pure
    returns (bool)
    {
        return (a >= 0);
    }

    function isNonZeroNegativeInt256(int256 a)
    public
    pure
    returns (bool)
    {
        return (a < 0);
    }

    function isNegativeInt256(int256 a)
    public
    pure
    returns (bool)
    {
        return (a <= 0);
    }

    
    
    
    function clamp(int256 a, int256 min, int256 max)
    public
    pure
    returns (int256)
    {
        if (a < min)
            return min;
        return (a > max) ? max : a;
    }

    function clampMin(int256 a, int256 min)
    public
    pure
    returns (int256)
    {
        return (a < min) ? min : a;
    }

    function clampMax(int256 a, int256 max)
    public
    pure
    returns (int256)
    {
        return (a > max) ? max : a;
    }
}

library SafeMathUintLib {
    function mul(uint256 a, uint256 b)
    internal
    pure
    returns (uint256)
    {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b)
    internal
    pure
    returns (uint256)
    {
        
        uint256 c = a / b;
        
        return c;
    }

    function sub(uint256 a, uint256 b)
    internal
    pure
    returns (uint256)
    {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b)
    internal
    pure
    returns (uint256)
    {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

    
    
    
    function clamp(uint256 a, uint256 min, uint256 max)
    public
    pure
    returns (uint256)
    {
        return (a > max) ? max : ((a < min) ? min : a);
    }

    function clampMin(uint256 a, uint256 min)
    public
    pure
    returns (uint256)
    {
        return (a < min) ? min : a;
    }

    function clampMax(uint256 a, uint256 max)
    public
    pure
    returns (uint256)
    {
        return (a > max) ? max : a;
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

library CurrenciesLib {
    using SafeMathUintLib for uint256;

    
    
    
    struct Currencies {
        MonetaryTypesLib.Currency[] currencies;
        mapping(address => mapping(uint256 => uint256)) indexByCurrency;
    }

    
    
    
    function add(Currencies storage self, address currencyCt, uint256 currencyId)
    internal
    {
        
        if (0 == self.indexByCurrency[currencyCt][currencyId]) {
            self.currencies.push(MonetaryTypesLib.Currency(currencyCt, currencyId));
            self.indexByCurrency[currencyCt][currencyId] = self.currencies.length;
        }
    }

    function removeByCurrency(Currencies storage self, address currencyCt, uint256 currencyId)
    internal
    {
        
        uint256 index = self.indexByCurrency[currencyCt][currencyId];
        if (0 < index)
            removeByIndex(self, index - 1);
    }

    function removeByIndex(Currencies storage self, uint256 index)
    internal
    {
        require(index < self.currencies.length, "Index out of bounds [CurrenciesLib.sol:51]");

        address currencyCt = self.currencies[index].ct;
        uint256 currencyId = self.currencies[index].id;

        if (index < self.currencies.length - 1) {
            self.currencies[index] = self.currencies[self.currencies.length - 1];
            self.indexByCurrency[self.currencies[index].ct][self.currencies[index].id] = index + 1;
        }
        self.currencies.length--;
        self.indexByCurrency[currencyCt][currencyId] = 0;
    }

    function count(Currencies storage self)
    internal
    view
    returns (uint256)
    {
        return self.currencies.length;
    }

    function has(Currencies storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (bool)
    {
        return 0 != self.indexByCurrency[currencyCt][currencyId];
    }

    function getByIndex(Currencies storage self, uint256 index)
    internal
    view
    returns (MonetaryTypesLib.Currency memory)
    {
        require(index < self.currencies.length, "Index out of bounds [CurrenciesLib.sol:85]");
        return self.currencies[index];
    }

    function getByIndices(Currencies storage self, uint256 low, uint256 up)
    internal
    view
    returns (MonetaryTypesLib.Currency[] memory)
    {
        require(0 < self.currencies.length, "No currencies found [CurrenciesLib.sol:94]");
        require(low <= up, "Bounds parameters mismatch [CurrenciesLib.sol:95]");

        up = up.clampMax(self.currencies.length - 1);
        MonetaryTypesLib.Currency[] memory _currencies = new MonetaryTypesLib.Currency[](up - low + 1);
        for (uint256 i = low; i <= up; i++)
            _currencies[i - low] = self.currencies[i];

        return _currencies;
    }
}

library NonFungibleBalanceLib {
    using SafeMathIntLib for int256;
    using SafeMathUintLib for uint256;
    using CurrenciesLib for CurrenciesLib.Currencies;

    
    
    
    struct Record {
        int256[] ids;
        uint256 blockNumber;
    }

    struct Balance {
        mapping(address => mapping(uint256 => int256[])) idsByCurrency;
        mapping(address => mapping(uint256 => mapping(int256 => uint256))) idIndexById;
        mapping(address => mapping(uint256 => Record[])) recordsByCurrency;

        CurrenciesLib.Currencies inUseCurrencies;
        CurrenciesLib.Currencies everUsedCurrencies;
    }

    
    
    
    function get(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (int256[] memory)
    {
        return self.idsByCurrency[currencyCt][currencyId];
    }

    function getByIndices(Balance storage self, address currencyCt, uint256 currencyId, uint256 indexLow, uint256 indexUp)
    internal
    view
    returns (int256[] memory)
    {
        if (0 == self.idsByCurrency[currencyCt][currencyId].length)
            return new int256[](0);

        indexUp = indexUp.clampMax(self.idsByCurrency[currencyCt][currencyId].length - 1);

        int256[] memory idsByCurrency = new int256[](indexUp - indexLow + 1);
        for (uint256 i = indexLow; i < indexUp; i++)
            idsByCurrency[i - indexLow] = self.idsByCurrency[currencyCt][currencyId][i];

        return idsByCurrency;
    }

    function idsCount(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (uint256)
    {
        return self.idsByCurrency[currencyCt][currencyId].length;
    }

    function hasId(Balance storage self, int256 id, address currencyCt, uint256 currencyId)
    internal
    view
    returns (bool)
    {
        return 0 < self.idIndexById[currencyCt][currencyId][id];
    }

    function recordByBlockNumber(Balance storage self, address currencyCt, uint256 currencyId, uint256 blockNumber)
    internal
    view
    returns (int256[] memory, uint256)
    {
        uint256 index = indexByBlockNumber(self, currencyCt, currencyId, blockNumber);
        return 0 < index ? recordByIndex(self, currencyCt, currencyId, index - 1) : (new int256[](0), 0);
    }

    function recordByIndex(Balance storage self, address currencyCt, uint256 currencyId, uint256 index)
    internal
    view
    returns (int256[] memory, uint256)
    {
        if (0 == self.recordsByCurrency[currencyCt][currencyId].length)
            return (new int256[](0), 0);

        index = index.clampMax(self.recordsByCurrency[currencyCt][currencyId].length - 1);
        Record storage record = self.recordsByCurrency[currencyCt][currencyId][index];
        return (record.ids, record.blockNumber);
    }

    function lastRecord(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (int256[] memory, uint256)
    {
        if (0 == self.recordsByCurrency[currencyCt][currencyId].length)
            return (new int256[](0), 0);

        Record storage record = self.recordsByCurrency[currencyCt][currencyId][self.recordsByCurrency[currencyCt][currencyId].length - 1];
        return (record.ids, record.blockNumber);
    }

    function recordsCount(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (uint256)
    {
        return self.recordsByCurrency[currencyCt][currencyId].length;
    }

    function set(Balance storage self, int256 id, address currencyCt, uint256 currencyId)
    internal
    {
        int256[] memory ids = new int256[](1);
        ids[0] = id;
        set(self, ids, currencyCt, currencyId);
    }

    function set(Balance storage self, int256[] memory ids, address currencyCt, uint256 currencyId)
    internal
    {
        uint256 i;
        for (i = 0; i < self.idsByCurrency[currencyCt][currencyId].length; i++)
            self.idIndexById[currencyCt][currencyId][self.idsByCurrency[currencyCt][currencyId][i]] = 0;

        self.idsByCurrency[currencyCt][currencyId] = ids;

        for (i = 0; i < self.idsByCurrency[currencyCt][currencyId].length; i++)
            self.idIndexById[currencyCt][currencyId][self.idsByCurrency[currencyCt][currencyId][i]] = i + 1;

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.idsByCurrency[currencyCt][currencyId], block.number)
        );

        updateInUseCurrencies(self, currencyCt, currencyId);
    }

    function reset(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    {
        for (uint256 i = 0; i < self.idsByCurrency[currencyCt][currencyId].length; i++)
            self.idIndexById[currencyCt][currencyId][self.idsByCurrency[currencyCt][currencyId][i]] = 0;

        self.idsByCurrency[currencyCt][currencyId].length = 0;

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.idsByCurrency[currencyCt][currencyId], block.number)
        );

        updateInUseCurrencies(self, currencyCt, currencyId);
    }

    function add(Balance storage self, int256 id, address currencyCt, uint256 currencyId)
    internal
    returns (bool)
    {
        if (0 < self.idIndexById[currencyCt][currencyId][id])
            return false;

        self.idsByCurrency[currencyCt][currencyId].push(id);

        self.idIndexById[currencyCt][currencyId][id] = self.idsByCurrency[currencyCt][currencyId].length;

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.idsByCurrency[currencyCt][currencyId], block.number)
        );

        updateInUseCurrencies(self, currencyCt, currencyId);

        return true;
    }

    function sub(Balance storage self, int256 id, address currencyCt, uint256 currencyId)
    internal
    returns (bool)
    {
        uint256 index = self.idIndexById[currencyCt][currencyId][id];

        if (0 == index)
            return false;

        if (index < self.idsByCurrency[currencyCt][currencyId].length) {
            self.idsByCurrency[currencyCt][currencyId][index - 1] = self.idsByCurrency[currencyCt][currencyId][self.idsByCurrency[currencyCt][currencyId].length - 1];
            self.idIndexById[currencyCt][currencyId][self.idsByCurrency[currencyCt][currencyId][index - 1]] = index;
        }
        self.idsByCurrency[currencyCt][currencyId].length--;
        self.idIndexById[currencyCt][currencyId][id] = 0;

        self.recordsByCurrency[currencyCt][currencyId].push(
            Record(self.idsByCurrency[currencyCt][currencyId], block.number)
        );

        updateInUseCurrencies(self, currencyCt, currencyId);

        return true;
    }

    function transfer(Balance storage _from, Balance storage _to, int256 id,
        address currencyCt, uint256 currencyId)
    internal
    returns (bool)
    {
        return sub(_from, id, currencyCt, currencyId) && add(_to, id, currencyCt, currencyId);
    }

    function hasInUseCurrency(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (bool)
    {
        return self.inUseCurrencies.has(currencyCt, currencyId);
    }

    function hasEverUsedCurrency(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    view
    returns (bool)
    {
        return self.everUsedCurrencies.has(currencyCt, currencyId);
    }

    function updateInUseCurrencies(Balance storage self, address currencyCt, uint256 currencyId)
    internal
    {
        if (0 == self.idsByCurrency[currencyCt][currencyId].length && self.inUseCurrencies.has(currencyCt, currencyId))
            self.inUseCurrencies.removeByCurrency(currencyCt, currencyId);
        else if (!self.inUseCurrencies.has(currencyCt, currencyId)) {
            self.inUseCurrencies.add(currencyCt, currencyId);
            self.everUsedCurrencies.add(currencyCt, currencyId);
        }
    }

    function indexByBlockNumber(Balance storage self, address currencyCt, uint256 currencyId, uint256 blockNumber)
    internal
    view
    returns (uint256)
    {
        if (0 == self.recordsByCurrency[currencyCt][currencyId].length)
            return 0;
        for (uint256 i = self.recordsByCurrency[currencyCt][currencyId].length; i > 0; i--)
            if (self.recordsByCurrency[currencyCt][currencyId][i - 1].blockNumber <= blockNumber)
                return i;
        return 0;
    }
}
