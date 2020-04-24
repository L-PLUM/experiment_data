/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity >=0.5.0 <0.6.0;
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b, "Ошибка умножения чисел.");
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "Ошибка деления чисел.");
        uint256 c = a / b;
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "Ошибка вычитания чисел.");
        uint256 c = a - b;
        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "Ошибка сложения чисел.");
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "Ошибка определения остатка от деления.");
        return a % b;
    }
}
contract CryptoLotto {
    using SafeMath for *;
    uint256 constant None = uint256(0);
    uint256 constant private MAX_PERCENTS = 10000;
    uint256 constant private FULL_PART = 10000;
    uint256 constant private FEE = 1000;
    uint constant MAX_RECENT_BLOCK_NUMBER = 250;
    string constant private MSG_INVALID_LOTTERY_ID = "Несуществующий id лотереи.";
    enum LotteryStatus {
        Open,
        Finished
    }
    enum LotteryPrizeType {
        T10,
        T30,
        All,
        First
    }
    struct Player {
        address addr;
        uint blockNumber;
    }
    struct Lottery {
        uint256 id;
        string name;
        address owner;
        uint256 price;
        uint begin;
        uint end;
        uint256 number;
        uint256 pot;
        LotteryStatus status;
        LotteryPrizeType prizeType;
        uint256 parentId;
        uint256 childId;
        bool isContinued;
        uint256 winNumber;
        uint blockNumberForRandom;
        bytes32 blockHashForRandom;
    }
    address private _owner;
    uint private _totalFee;
    address[] private _admins;
    mapping (address => uint256) private _adminsParts;
    mapping (uint256 => Lottery) private _lotteries;
    uint256 _lastLotteryId;
    mapping (uint256 => Player[]) private _players;
    mapping (uint256 => address[]) private _winPlayers;
    mapping (uint256 => uint256[]) private _winPlayerPrizes;
    uint256[] _openLotteries;
    event BuyTicketEvent(
        address indexed from,
        uint256 indexed lotteryId
    );
    event NewLotteryEvent(
        uint256 indexed lotteryId
    );
    event FinishedLotteryEvent(
        uint256 indexed lotteryId
    );
    event DeleteLotteryEvent(
        uint256 indexed lotteryId
    );
    event WinPrizeEvent(
        address indexed player,
        uint256 indexed prize,
        uint256 indexed lotteryId
    );
    event TransferAdminPartEvent(
        address indexed from,
        address indexed to,
        uint256 indexed part
    );
    event DividendEvent(
        address indexed admin,
        uint256 indexed sum
    );
    modifier onlyOwner() {
        require(msg.sender == _owner, "Разрешено только владельцу контракта.");
        _;
    }
    modifier onlyAdmin() {
        require(checkIsAdmin(msg.sender), "Разрешено только админам контракта.");
        _;
    }
    constructor() public {
        _owner = msg.sender;
        _admins.push(_owner);
        _adminsParts[_owner] = FULL_PART;
    }
    function transferAdminPart(address addr, uint256 part)
        public
        onlyAdmin
    {
        require(
            part <= _adminsParts[msg.sender],
            "Передаваемая доля больше доли владения."
        );
        distributeDividend();
        if (!checkIsAdmin(addr)) {
            _admins.push(addr);
        }
        _adminsParts[msg.sender] = _adminsParts[msg.sender].sub(part);
        _adminsParts[addr] = _adminsParts[addr].add(part);
        if (_adminsParts[msg.sender] == 0) {
            removeAdmin(msg.sender);
        }
        emit TransferAdminPartEvent(msg.sender, addr, part);
    }
    function distributeDividend() public onlyAdmin {
        if (_totalFee == 0)
            return;
        uint totalSum = _totalFee;
        for (uint i = 0; i < _admins.length; i++) {
            address payable addr = address(uint160(_admins[i]));
            uint sum = totalSum.mul(_adminsParts[addr]).div(FULL_PART);
            if (sum > 0) {
                _totalFee = _totalFee.sub(sum);
                addr.transfer(sum);
                emit DividendEvent(addr, sum);
            }
        }
    }
    function createLottery(
        string memory name,
        uint256 price,
        uint begin,
        uint end,
        LotteryPrizeType prizeType
    )
        public
        onlyOwner
    {
        require(begin < end, "Время начала лотереи должно быть меньше окончания.");
        _lastLotteryId = _lastLotteryId.add(1);
        _lotteries[_lastLotteryId] = Lottery({
            id: _lastLotteryId,
            name: name,
            owner: msg.sender,
            price: price,
            begin: begin,
            end: end,
            number: 1,
            pot: 0,
            status: LotteryStatus.Open,
            prizeType: prizeType,
            parentId: None,
            childId: None,
            isContinued: true,
            winNumber: 0,
            blockNumberForRandom: 0,
            blockHashForRandom: 0x0
         });
        _openLotteries.push(_lastLotteryId);
        emit NewLotteryEvent(_lastLotteryId);
    }
    function buyTicket(uint256 lotteryId) public payable {
        require(lotteryId <= _lastLotteryId, MSG_INVALID_LOTTERY_ID);
        finalizeLotteries();
        uint256 actualLotteryId = getActualLotteryId(lotteryId);
        require(
            actualLotteryId != None,
            "Лотерея завершена и не возобновится. Покупка билета не возможна."
        );
        Lottery storage lottery = _lotteries[actualLotteryId];
        uint actualPrice = getActualLotteryPrice(lottery);
        require(
            msg.value >= actualPrice,
            "Сумма перевода меньше стоимости участия в лотереи."
        );
        addPlayerToLottery(lottery);
        uint feeSum = actualPrice.mul(FEE).div(MAX_PERCENTS);
        lottery.pot = lottery.pot.add(actualPrice.sub(feeSum));
        _totalFee = _totalFee.add(feeSum);
        uint remainder = msg.value.sub(actualPrice);
        if (remainder > 0)
            msg.sender.transfer(remainder);
        emit BuyTicketEvent(msg.sender, actualLotteryId);
    }
    function finalizeLotteries() public {
        for (uint i = 0; i < _openLotteries.length; i++) {
            uint256 lotteryId = _openLotteries[i];
            if (_lotteries[lotteryId].end < now) {
                if (_players[lotteryId].length > 0) {
                    uint256 lastIndex = _players[lotteryId].length.sub(1);
                    uint blockNumber = _players[lotteryId][lastIndex].blockNumber;
                    if (block.number.sub(blockNumber) == 1) {
                        continue;
                    }
                }
                finalizeLottery(_lotteries[lotteryId]);
            }
        }
    }
    function deleteLottery(uint256 lotteryId) public onlyOwner {
        require(lotteryId <= _lastLotteryId, MSG_INVALID_LOTTERY_ID);

        Lottery storage lottery = _lotteries[lotteryId];

        require(
            lottery.status == LotteryStatus.Open,
            "Лотерея уже завершена, удаление невозможно."
        );
        require(
            lottery.isContinued,
            "Лотерея уже отмечена к удалению, повторное удаление невозможно."
        );
        lottery.isContinued = false;
        emit DeleteLotteryEvent(lotteryId);
    }
    function() external payable {
        uint256 lotteryId = None;
        uint256 price = 0;
        for (uint256 i = 0; i < _openLotteries.length; i++) {
            uint256 openLotteryId = _openLotteries[i];
            uint256 openLotteryPrice = _lotteries[openLotteryId].price;
            if (msg.value >= openLotteryPrice && openLotteryPrice > price) {
                lotteryId = openLotteryId;
                price = openLotteryPrice;
            }
        }
        if (lotteryId != None) {
            buyTicket(lotteryId);
        } else {
            revert("Не найдена подходящая лотерея. Покупка билета невозможна.");
        }
    }
    function getOwner() public view returns (address) {
        return _owner;
    }
    function getTotalFee() public view returns (uint) {
        return _totalFee;
    }
    function getAdmins() public view returns (address[] memory) {
        return _admins;
    }
    function getAdminPartByAddress(address addr) public view returns (uint256) {
        return _adminsParts[addr];
    }

    function getLotteryInfo(uint256 id)
        public
        view
        returns (
            uint256,
            address,
            uint256,
            uint,
            uint,
            uint256,
            uint256,
            LotteryStatus,
            LotteryPrizeType,
            uint256,
            uint256,
            bool
        )
    {
        Lottery memory lottery = _lotteries[id];
        return (
            lottery.id,
            lottery.owner,
            lottery.price,
            lottery.begin,
            lottery.end,
            lottery.number,
            lottery.pot,
            lottery.status,
            lottery.prizeType,
            lottery.parentId,
            lottery.childId,
            lottery.isContinued
        );
    }
    function getFinishedLotteryInfo(uint256 id)
        public
        view
        returns (
            uint256,
            uint256,
            uint,
            bytes32,
            uint256,
            uint256
        )
    {
        Lottery memory lottery = _lotteries[id];
        require(
            lottery.status == LotteryStatus.Finished,
            "Лотерея еще не завершена."
        );
        return (
            lottery.id,
            lottery.winNumber,
            lottery.blockNumberForRandom,
            lottery.blockHashForRandom,
            lottery.pot,
            _players[id].length
        );
    }
    function getLotteryName(uint256 id) public view returns (string memory) {
        return _lotteries[id].name;
    }
    function getLotteryPlayers(uint256 lotteryId)
        public
        view
        returns (address[] memory, uint[] memory)
    {
        require(lotteryId <= _lastLotteryId, MSG_INVALID_LOTTERY_ID);
        Player[] memory players = _players[lotteryId];
        address[] memory addresses = new address[](players.length);
        uint[] memory blockNumbers = new uint[](players.length);
        for (uint i = 0; i < players.length; i++) {
            addresses[i] = players[i].addr;
            blockNumbers[i] = players[i].blockNumber;
        }
        return (addresses, blockNumbers);
    }
    function getLotteryPlayerAddresses(uint256 lotteryId)
        public
        view
        returns (address[] memory)
    {
        require(lotteryId <= _lastLotteryId, MSG_INVALID_LOTTERY_ID);
        Player[] memory players = _players[lotteryId];
        address[] memory result = new address[](players.length);
        for (uint i = 0; i < players.length; i++) {
            result[i] = players[i].addr;
        }
        return result;
    }
    function getWinPlayers(uint256 lotteryId)
        public
        view
        returns (address[] memory, uint256[] memory)
    {
        require(lotteryId <= _lastLotteryId, MSG_INVALID_LOTTERY_ID);
        address[] memory addresses = new address[](_winPlayers[lotteryId].length);
        uint256[] memory prizes = new uint256[](_winPlayerPrizes[lotteryId].length);
        for (uint256 i = 0; i < _winPlayers[lotteryId].length; i++) {
            addresses[i] = _winPlayers[lotteryId][i];
        }
        for (uint256 i = 0; i < _winPlayerPrizes[lotteryId].length; i++) {
            prizes[i] = _winPlayerPrizes[lotteryId][i];
        }
        return (addresses, prizes);
    }
    function getActualLotteryId(uint256 lotteryId)
        public
        view
        returns (uint256)
    {
        require(lotteryId <= _lastLotteryId, MSG_INVALID_LOTTERY_ID);
        uint256 actualLotteryId = None;
        bool isLotteryDeleted = false;
        Lottery memory lottery = _lotteries[lotteryId];
        while (lottery.status == LotteryStatus.Finished) {
            if (lottery.childId == None) {
                isLotteryDeleted = true;
                break;
            }
            lottery = _lotteries[lottery.childId];
        }
        if (!isLotteryDeleted)
            actualLotteryId = lottery.id;
        return actualLotteryId;
    }
    function getOpenedLotteries() public view returns (uint256[] memory) {
        return _openLotteries;
    }
    function checkIsAdmin(address addr) private view returns (bool) {
        bool isAdmin = false;
        for (uint i = 0; i < _admins.length; i++) {
            if (addr == _admins[i]) {
                isAdmin = true;
                break;
            }
        }
        return isAdmin;
    }
    function removeAdmin(address addr) private {
        require(
            checkIsAdmin(addr),
            "Невозможно удалить админа, пользователь не админ."
        );
        require(
            _adminsParts[addr] == 0,
            "Невозможно удалить админа, доля не ровна 0."
        );
        uint index;
        for (uint i = 0; i < _admins.length; i++) {
            if (_admins[i] == addr) {
                index = i;
                break;
            }
        }
        for (uint i = index; i < _admins.length.sub(1); i++) {
            _admins[i] = _admins[i + 1];
        }
        _admins.length--;
    }
    function addPlayerToLottery(Lottery memory lottery) private {
        require(
            lottery.begin <= now && lottery.end >= now,
            "Невозможно добавить участника в лотерею с данным периодом."
        );
        require(
            lottery.status == LotteryStatus.Open,
            "Лотерея закрыта для участия. Добавление участника невозможно."
        );
        Player memory player = Player({
            addr: msg.sender,
            blockNumber: block.number
        });
        _players[lottery.id].push(player);
    }
    function createChildLottery(Lottery storage parentLottery) private {
        if (!parentLottery.isContinued)
            return;
        uint period = parentLottery.end.sub(parentLottery.begin);
        uint begin = parentLottery.end;
        uint end = begin.add(period);
        if (end < now)
            (begin, end) = getPeriodBorders(begin, end, now);
        _lastLotteryId = _lastLotteryId.add(1);
        _lotteries[_lastLotteryId] = Lottery({
            id: _lastLotteryId,
            name: parentLottery.name,
            owner: msg.sender,
            price: parentLottery.price,
            begin: begin,
            end: end,
            number: parentLottery.number.add(1),
            pot: 0,
            status: LotteryStatus.Open,
            prizeType: parentLottery.prizeType,
            parentId: parentLottery.id,
            childId: None,
            isContinued: parentLottery.isContinued,
            winNumber: 0,
            blockNumberForRandom: 0,
            blockHashForRandom: 0x0
         });
        parentLottery.childId = _lastLotteryId;
        _openLotteries.push(_lastLotteryId);
        emit NewLotteryEvent(_lastLotteryId);
    }

    function getPeriodBorders(uint begin, uint end, uint currentTime)
        private
        pure
        returns (uint, uint)
    {
        if (end < currentTime) {
            uint period = end.sub(begin);
            uint n = currentTime.sub(end);
            n = n.div(period);
            n = n.add(1);
            uint delta = n.mul(period);
            begin = begin.add(delta);
            end = end.add(delta);
        }
        return (begin, end);
    }
    function finalizeLottery(Lottery storage lottery) private {
        if (_players[lottery.id].length == 0)
            finalizeEmptyLottery(lottery);
        else
            finalizeNotEmptyLottery(lottery);
    }
    function finalizeEmptyLottery(Lottery storage lottery) private {
        lottery.status = LotteryStatus.Finished;
        removeFinishedLotteryFromOpened(lottery.id);
        emit FinishedLotteryEvent(lottery.id);
        if (lottery.isContinued)
            createChildLottery(lottery);
    }
    function finalizeNotEmptyLottery(Lottery storage lottery) private {
        (
            lottery.winNumber,
            lottery.blockNumberForRandom,
            lottery.blockHashForRandom
        ) = getWinNumber(lottery);
        lottery.status = LotteryStatus.Finished;
        removeFinishedLotteryFromOpened(lottery.id);
        emit FinishedLotteryEvent(lottery.id);
        uint256 n = getWinningsCount(lottery);
        uint256[] memory shareOfWinnings = getShareOfWinnings(n);
        uint256 remainder = lottery.pot;
        for (uint256 i = 0; i < n; i++) {
            uint256 playerIndex = lottery.winNumber.add(i);
            if (playerIndex >= _players[lottery.id].length)
                playerIndex = playerIndex.sub(_players[lottery.id].length);
            uint256 prize = shareOfWinnings[i].mul(lottery.pot).div(MAX_PERCENTS);
            if (prize > 0) {
                remainder = remainder.sub(prize);
                address payable addr = address(uint160(_players[lottery.id][playerIndex].addr));
                _winPlayers[lottery.id].push(addr);
                _winPlayerPrizes[lottery.id].push(prize);
                addr.transfer(prize);
                emit WinPrizeEvent(addr, prize, lottery.id);
            }
        }
        if (remainder > 0) {
            _totalFee = _totalFee.add(remainder);
        }
        if (lottery.isContinued)
            createChildLottery(lottery);
    }
    function removeFinishedLotteryFromOpened(uint256 lotteryId) private {
        bool exists = false;
        uint index;
        for (uint i = 0; i < _openLotteries.length; i++) {
            if (_openLotteries[i] == lotteryId) {
                index = i;
                exists = true;
                break;
            }
        }
        require(exists, "id лотереи нет в списке открытых.");
        for (uint i = index; i < _openLotteries.length.sub(1); i++) {
            _openLotteries[i] = _openLotteries[i + 1];
        }
        _openLotteries.length--;
    }
    function getWinningsCount(Lottery memory lottery)
        private
        view
        returns (uint256)
    {
        require(
            _players[lottery.id].length > 0,
            "Невозможно вычислить количество победителей для 0 участников."
        );
        uint256 result;
        uint256 remainder = 0;
        uint256 playersCount = _players[lottery.id].length;
        if (lottery.prizeType == LotteryPrizeType.First) {
            result = 1;
        } else if (lottery.prizeType == LotteryPrizeType.All) {
            result = _players[lottery.id].length;
        } else if (lottery.prizeType == LotteryPrizeType.T10) {
            remainder = playersCount.mod(10);
            result = playersCount.div(10);
        } else if (lottery.prizeType == LotteryPrizeType.T30) {
            result = playersCount.mul(30);
            remainder = result.mod(100);
            result = result.div(100);
        } else {
            revert("Лотерея имеет неизвестный тип распределения выигрышей.");
        }
        if (remainder > 0 && result < playersCount) {
            result = result.add(1);
        }
        return result;
    }
    function getWinNumber(Lottery memory lottery)
        private
        view
        returns (uint256, uint, bytes32)
    {
        require(
            lottery.end < now,
            "Дата окончания лотереи должна быть меньше текущего времени. Определение победного номера невозможно."
        );
        require(
            _players[lottery.id].length > 0,
             "Пустой список участников. Определение победного номера невозможно."
        );
        uint256 lastIndex = _players[lottery.id].length.sub(1);
        uint blockNumber = _players[lottery.id][lastIndex].blockNumber;
        if (block.number.sub(blockNumber) > MAX_RECENT_BLOCK_NUMBER)
            blockNumber = block.number.sub(MAX_RECENT_BLOCK_NUMBER);
        bytes32 hash = blockhash(blockNumber);
        return (getRandomNumber(hash, _players[lottery.id].length), blockNumber, hash);
    }
    function getRandomNumber(bytes32 hash, uint256 n)
        private
        pure
        returns (uint256)
    {
        return uint256(keccak256(abi.encodePacked(hash))).mod(n);
    }
    function getActualLotteryPrice(Lottery memory lottery)
        private
        view
        returns (uint)
    {
        uint256 discount = 0;
        uint256 percent = 0;
        (uint b1, uint b2, uint b3) = splitPeriod(lottery.begin, lottery.end);
        if (lottery.begin <= now && now < b1) {
            percent = 300;
        } else if (b1 <= now && now < b2) {
            percent = 200;
        } else if (b2 <= now && now < b3) {
            percent = 100;
        }
        discount = lottery.price.mul(percent).div(MAX_PERCENTS);
        return lottery.price.sub(discount);
    }
    function splitPeriod(uint begin, uint end)
        private
        pure
        returns (uint, uint, uint)
    {
        require(
            begin < end,
            "Невозможно разделить период. Время начала периода больше окончания."
        );
        uint step = (end.sub(begin)).div(4);
        uint b1 = begin.add(step);
        uint b2 = b1.add(step);
        uint b3 = b2.add(step);
        return (b1, b2, b3);
    }
    function getShareOfWinnings(uint256 n)
        private
        pure
        returns (uint[] memory)
    {
        uint[] memory result = new uint[](n);
        uint256 divider = n.mul(n.add(1));
        for (uint256 k = 0; k < n; k++) {
            uint256 p = (n.sub(k)).mul(20000);
            p = p.div(divider);
            result[k] = p;
        }
        return result;
    }
}
