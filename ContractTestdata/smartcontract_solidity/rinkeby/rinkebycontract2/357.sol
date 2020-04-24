/**
 *Submitted for verification at Etherscan.io on 2019-07-29
*/

// File: @axie/contract-library/contracts/access/HasAdmin.sol

pragma solidity ^0.5.2;


contract HasAdmin {
  event AdminChanged(address indexed _oldAdmin, address indexed _newAdmin);
  event AdminRemoved(address indexed _oldAdmin);

  address public admin;

  modifier onlyAdmin {
    require(msg.sender == admin);
    _;
  }

  constructor() internal {
    admin = msg.sender;
    emit AdminChanged(address(0), admin);
  }

  function changeAdmin(address _newAdmin) external onlyAdmin {
    require(_newAdmin != address(0));
    emit AdminChanged(admin, _newAdmin);
    admin = _newAdmin;
  }

  function removeAdmin() external onlyAdmin {
    emit AdminRemoved(admin);
    admin = address(0);
  }
}

// File: @axie/contract-library/contracts/lifecycle/Pausable.sol

pragma solidity ^0.5.2;



contract Pausable is HasAdmin {
  event Paused();
  event Unpaused();

  bool public paused;

  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  modifier whenPaused() {
    require(paused);
    _;
  }

  function pause() public onlyAdmin whenNotPaused {
    paused = true;
    emit Paused();
  }

  function unpause() public onlyAdmin whenPaused {
    paused = false;
    emit Unpaused();
  }
}

// File: @axie/contract-library/contracts/math/Math.sol

pragma solidity ^0.5.2;


library Math {
  function max(uint256 a, uint256 b) internal pure returns (uint256 c) {
    return a >= b ? a : b;
  }

  function min(uint256 a, uint256 b) internal pure returns (uint256 c) {
    return a < b ? a : b;
  }
}

// File: @axie/contract-library/contracts/token/erc20/IERC20.sol

pragma solidity ^0.5.2;


interface IERC20 {
  event Transfer(address indexed _from, address indexed _to, uint256 _value);
  event Approval(address indexed _owner, address indexed _spender, uint256 _value);

  function totalSupply() external view returns (uint256 _supply);
  function balanceOf(address _owner) external view returns (uint256 _balance);

  function approve(address _spender, uint256 _value) external returns (bool _success);
  function allowance(address _owner, address _spender) external view returns (uint256 _value);

  function transfer(address _to, uint256 _value) external returns (bool _success);
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool _success);
}

// File: @axie/contract-library/contracts/ownership/Withdrawable.sol

pragma solidity ^0.5.2;




contract Withdrawable is HasAdmin {
  function withdrawEther() external onlyAdmin {
    msg.sender.transfer(address(this).balance);
  }

  function withdrawToken(IERC20 _token) external onlyAdmin {
    require(_token.transfer(msg.sender, _token.balanceOf(address(this))));
  }
}

// File: @axie/contract-library/contracts/util/AddressUtils.sol

pragma solidity ^0.5.2;


library AddressUtils {
  function toPayable(address _address) internal pure returns (address payable _payable) {
    return address(uint160(_address));
  }

  function isContract(address _address) internal view returns (bool _correct) {
    uint256 _size;
    // solium-disable-next-line security/no-inline-assembly
    assembly { _size := extcodesize(_address) }
    return _size > 0;
  }
}

// File: AxieSushiMath.sol

pragma solidity ^0.5.2;


contract AxieSushiMath is HasAdmin {

  uint256 public minBaseSpeed = 850;
  uint256 public maxBaseSpeed = 1000;

  uint256 public minCritChance = 1000; // should be divided by 10000
  uint256 public maxCritChance = 2810;

  uint256 public minSpeedChance = 1000;
  uint256 public maxSpeedChance = 2910;

  uint256 public statSpread = 34;

  uint256 _randomSeed = 1;

  function editParameters(
    uint256 _minBaseSpeed,
    uint256 _maxBaseSpeed,
    uint256 _minCritChance,
    uint256 _maxCritChance,
    uint256 _minSpeedChance,
    uint256 _maxSpeedChance,
    uint256 _statSpread
  )
    external
    onlyAdmin
  {
    minBaseSpeed = _minBaseSpeed;
    maxBaseSpeed = _maxBaseSpeed;
    minCritChance = _minCritChance;
    maxCritChance = _maxCritChance;
    minSpeedChance = _minSpeedChance;
    maxSpeedChance = _maxSpeedChance;
  }

  function calculateScore(
    uint256 _hp,
    uint256 _speed,
    uint256 _skill,
    uint256 _morale,
    uint256 _sushiCnt
  )
    external
    returns (uint256 _score, bool[] memory _didCrit, bool[] memory _speedBuffed, uint8[] memory _speedBites)
  {
    uint256 _baseSpeed = maxBaseSpeed - (_hp + _skill - 54) * 5;
    uint256 _critChance = (_morale - 27) * (maxCritChance - minCritChance) / statSpread + minCritChance;
    uint256 _speedChance = (_speed - 27) * (maxSpeedChance - minSpeedChance) / statSpread + minSpeedChance;
    uint8 _bitingSpeed = 0;
    bool _buffingSpeed = false;
    uint256 _eatenSushis = 0;
    uint256 _index = 0;
    uint256 _seed = _randomSeed;

    _didCrit = new bool[](_sushiCnt);
    _speedBuffed = new bool[](_sushiCnt);
    _speedBites = new uint8[](_sushiCnt);

    while (_eatenSushis < _sushiCnt) {
      bool _shouldCrit = _getRandomNumber(10000, _seed++) < _critChance;
      _eatenSushis += _shouldCrit ? 2 : 1;

      _didCrit[_index] = _shouldCrit;
      _speedBuffed[_index] = _buffingSpeed;
      _speedBites[_index] = _bitingSpeed;
      _index++;

      if (_buffingSpeed) {
        _bitingSpeed--;
        if (_bitingSpeed == 0) {
          _buffingSpeed = false;
        }
        _score += _baseSpeed / 2;
      } else {
        _score += _baseSpeed;
      }

      bool _shouldGainSpeed = _getRandomNumber(10000, _seed++) < _speedChance;
      if (!_buffingSpeed && _shouldGainSpeed) {
        _buffingSpeed = true;
        _bitingSpeed = 2;
      }
    }

    _randomSeed = _seed;
  }

  function _getRandomNumber(uint256 _upper, uint256 _seed) internal view returns (uint256) {
    uint256 _entropy = uint256(
      keccak256(
        abi.encodePacked(
          _seed,
          blockhash(block.number - 1),
          block.coinbase,
          block.difficulty
        )
      )
    );

    return _entropy % _upper;
  }
}

// File: @axie/contract-library/contracts/introspection/erc165/IERC165.sol

pragma solidity ^0.5.2;


interface IERC165 {
  function supportsInterface(bytes4 _interfaceID) external view returns (bool _supported);
}

// File: @axie/contract-library/contracts/token/erc721/IERC721.sol

pragma solidity ^0.5.2;


interface IERC721 {
  event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

  function balanceOf(address _owner) external view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) external view returns (address _owner);

  function approve(address _to, uint256 _tokenId) external;
  function getApproved(uint256 _tokenId) external view returns (address _operator);

  function setApprovalForAll(address _operator, bool _approved) external;
  function isApprovedForAll(address _owner, address _operator) external view returns (bool _approved);

  function transferFrom(address _from, address _to, uint256 _tokenId) external;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata _data) external;
}

// File: ../core/AxieCore.sol

pragma solidity ^0.5.2;




contract AxieCore is IERC721, IERC165 {
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event AxieSpawned(uint256 indexed _axieId, address indexed _owner, uint256 _genes);
  event AxieRebirthed(uint256 indexed _axieId, uint256 _genes);
  event AxieRetired(uint256 indexed _axieId);
  event AxieEvolved(uint256 indexed _axieId, uint256 _oldGenes, uint256 _newGenes);

  function getAxie(uint256 _axieId) external view returns (uint256 _genes, uint256 _birthDate);
}

// File: AxieSushi.sol

pragma solidity ^0.5.2;








contract AxieSushi is Pausable, Withdrawable {
  using AddressUtils for address;
  address constant public ethAddress = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

  event RacerJoined(uint256 _raceIndex, uint256 _racer, address _owner);
  event RaceFinished(uint256 _raceIndex, uint256 _racer, address _winner, uint256 _reward, address _tokenAddress);

  enum AxieClass {
    Beast,
    Bug,
    Bird,
    Plant,
    Aquatic,
    Reptile,
    HiddenOne,
    HiddenTwo,
    HiddenThree
  }

  struct Race {
    address _bettingTokenAddress;
    uint256 _bettingValue;
    address _executor;
    uint256 _winnerIndex;
    uint256 _reward;
  }

  Race[] public races;
  mapping (uint256 => uint256[]) public racers;
  mapping (uint256 => uint256[]) public genes;
  mapping (uint256 => address[]) public owners;

  mapping (uint256 => mapping (uint256 => uint256)) public raceLogs;

  AxieCore public axieCore;
  AxieSushiMath public axieSushiMath;
  uint256 public maxRacer = 10;
  uint256 public sushiCnt = 10;
  uint256 public executorReward = 50; // 0.5%

  mapping(address => bool) public acceptedTokens;
  mapping(address => uint256) public bettingAmounts;

  constructor(AxieCore _axieCoreAddress, AxieSushiMath _axieSushiMathAddress) public {
    axieCore = _axieCoreAddress;
    axieSushiMath = _axieSushiMathAddress;
    acceptedTokens[ethAddress] = true;
  }

  function getRaceLength() external view returns (uint256) {
    return races.length;
  }

  function setParameters(uint256 _maxRacer, uint256 _sushiCnt, uint256 _executorReward) external onlyAdmin {
    maxRacer = _maxRacer;
    sushiCnt = _sushiCnt;
    require(_executorReward < 10000);
    executorReward = _executorReward;
  }

  function setBettingAmount(
    address _bettingToken,
    uint256 _bettingAmount
  ) external onlyAdmin {
    bettingAmounts[_bettingToken] = _bettingAmount;
    acceptedTokens[_bettingToken] = true;
  }

  function setAcceptedToken(address _bettingToken, bool _accepted) external onlyAdmin {
    acceptedTokens[_bettingToken] = _accepted;
  }

  function setAxieSushiMathAddress(AxieSushiMath _axieSushiMathAddress) external onlyAdmin {
    axieSushiMath = _axieSushiMathAddress;
  }

  function joinRace(
    uint256 _raceIndex,
    uint256 _axieId,
    address _bettingToken,
    uint256 _bettingAmount
  ) external payable {
    require(acceptedTokens[_bettingToken] && bettingAmounts[_bettingToken] == _bettingAmount);

    require(_raceIndex <= races.length);
    if (_raceIndex == races.length) {
      races.push(
        Race(
          _bettingToken,
          _bettingAmount,
          address(0),
          0,
          0
        )
      );
    }

    Race storage _race = races[_raceIndex];
    require(_race._executor == address(0) && racers[_raceIndex].length < maxRacer);
    require(_bettingToken == _race._bettingTokenAddress && _bettingAmount == _race._bettingValue);

    if (_bettingToken == ethAddress) {
      require(_bettingAmount == msg.value);
    } else {
      IERC20(_bettingToken).transferFrom(msg.sender, address(this), _bettingAmount);
    }

    address _owner = axieCore.ownerOf(_axieId);
    require(msg.sender == _owner);
    (uint256 _genes, ) = axieCore.getAxie(_axieId);
    require(_genes > 0);

    racers[_raceIndex].push(_axieId);
    genes[_raceIndex].push(_genes);
    owners[_raceIndex].push(_owner);

    emit RacerJoined(_raceIndex, _axieId, _owner);
  }

  function startRace(uint256 _raceIndex) external {
    require(_raceIndex < races.length);
    Race storage _race = races[_raceIndex];
    require(racers[_raceIndex].length > 1 && _race._executor == address(0));

    uint256 _bestScore = 1 << 255;
    uint256 _winnerIndex = 0;

    for (uint256 i = 0; i < racers[_raceIndex].length; i++) {
      uint256 _genes = genes[_raceIndex][i];
      (uint256 _hp, uint256 _speed, uint256 _skill, uint256 _morale) = deconstructAxie(_genes);
      (
        uint256 _score,
        bool[] memory _didCrit,
        bool[] memory _speedBuffed,
        uint8[] memory _speedBites
      ) = axieSushiMath.calculateScore(
        _hp,
        _speed,
        _skill,
        _morale,
        sushiCnt
      );

      _storeLogs(_raceIndex, i, _score, _didCrit, _speedBuffed, _speedBites);

      if (_score < _bestScore) {
        _bestScore = _score;
        _winnerIndex = i;
      }
    }

    _race._winnerIndex = _winnerIndex;
    _race._executor = msg.sender;

    address _winner = owners[_raceIndex][_winnerIndex];
    uint256 _reward = _sendReward(_winner, _raceIndex);

    emit RaceFinished(_raceIndex, racers[_raceIndex][_winnerIndex], _winner, _reward, _race._bettingTokenAddress);
  }

  function deconstructAxie(uint256 _genes)
    public
    pure
    returns (uint256 _hp, uint256 _speed, uint256 _skill, uint256 _morale)
  {
    uint256 _bodyClass = (_genes >> 252) & 0xf;
    (
      int256 _hpBodyDelta,
      int256 _speedBodyDelta,
      int256 _skillBodyDelta,
      int256 _moraleBodyDelta
    ) = _getBodyClassDelta(_bodyClass);

    uint256[] memory _parts = new uint256[](6);
    _parts[0] = (_genes >> 186) & 0xf; // eyes
    _parts[1] = (_genes >> 154) & 0xf; // ears
    _parts[2] = (_genes >> 122) & 0xf; // mouth
    _parts[3] = (_genes >> 90) & 0xf; // horn
    _parts[4] = (_genes >> 58) & 0xf; // back
    _parts[5] = (_genes >> 26) & 0xf; // tail
    (
      int256 _hpPartDelta,
      int256 _speedPartDelta,
      int256 _skillPartDelta,
      int256 _moralePartDelta
    ) = _getPartClassDelta(_parts);

    _hp = uint256(35 + _hpBodyDelta * 4 + _hpPartDelta);
    _speed = uint256(35 + _speedBodyDelta * 4 + _speedPartDelta);
    _skill = uint256(35 + _skillBodyDelta * 4 + _skillPartDelta);
    _morale = uint256(35 + _moraleBodyDelta * 4 + _moralePartDelta);
  }

  function getAxieClass(uint256 _class) public pure returns (AxieClass) {
    if (_class == 0) return AxieClass.Beast;
    if (_class == 1) return AxieClass.Bug;
    if (_class == 2) return AxieClass.Bird;
    if (_class == 3) return AxieClass.Plant;
    if (_class == 4) return AxieClass.Aquatic;
    if (_class == 5) return AxieClass.Reptile;
    if (_class == 8) return AxieClass.HiddenOne;
    if (_class == 9) return AxieClass.HiddenTwo;
    if (_class == 10) return AxieClass.HiddenThree;

    revert('Unsupported Axie class');
  }

  function _getBodyClassDelta(uint256 _bodyClass)
    internal
    pure
    returns (int256 _hpDelta, int256 _speedDelta, int256 _skillDelta, int256 _moraleDelta)
  {
    AxieClass _class = getAxieClass(_bodyClass);

    if (_class == AxieClass.Beast) return (-1, 0, -1, 2);
    if (_class == AxieClass.Bug) return (0, -1, 0, 1);
    if (_class == AxieClass.Bird) return (-2, 2, 0, 0);
    if (_class == AxieClass.Plant) return (2, -1, -1, 0);
    if (_class == AxieClass.Aquatic) return (1, 1, 0, -2);
    if (_class == AxieClass.Reptile) return (1, 0, -1, 0);
    if (_class == AxieClass.HiddenOne) return (-1, 1, 2, -2);
    if (_class == AxieClass.HiddenTwo) return (0, 0, 1, -1);
    if (_class == AxieClass.HiddenThree) return (2, 1, -2, -1);
  }

  function _getPartClassDelta(uint256[] memory _parts)
    internal
    pure

    returns (int256 _hpDelta, int256 _speedDelta, int256 _skillDelta, int256 _moraleDelta)
  {
    for (uint256 i = 0; i < _parts.length; i++) {
      AxieClass _class = getAxieClass(_parts[i]);

      if (_class == AxieClass.Beast) {
        _moraleDelta += 3;
        _speedDelta += 1;
      }
      if (_class == AxieClass.Bug) {
        _moraleDelta += 3;
        _hpDelta += 1;
      }
      if (_class == AxieClass.Bird) {
        _speedDelta += 3;
        _moraleDelta += 1;
      }
      if (_class == AxieClass.Plant) {
        _hpDelta += 3;
        _moraleDelta += 1;
      }
      if (_class == AxieClass.Aquatic) {
        _speedDelta += 3;
        _hpDelta += 1;
      }
      if (_class == AxieClass.Reptile) {
        _hpDelta += 3;
        _speedDelta += 1;
      }
    }
  }

  function _storeLogs(
    uint256 _raceIndex,
    uint256 _racerIndex,
    uint256 _score,
    bool[] memory _didCrit,
    bool[] memory _speedBuffed,
    uint8[] memory _speedBites
  ) internal {
    uint256 _raceLog = _score;
    uint256 _stepCount = _didCrit.length;
    _raceLog |= (_stepCount << 32);

    for (uint256 i = 0; i < _stepCount; i++) {
      uint256 _offset = 40 + i * 8;
      _raceLog |= uint256(_didCrit[i] ? 1 : 0) << _offset;
      _raceLog |= uint256(_speedBuffed[i] ? 1 : 0) << (_offset + 1);
      _raceLog |= uint256(_speedBites[i]) << (_offset + 2);
    }

    raceLogs[_raceIndex][_racerIndex] = _raceLog;
  }

  function _sendReward(address _winner, uint256 _raceIndex) internal returns (uint256 _reward) {
    Race storage _race = races[_raceIndex];
    uint256 _racerCount = racers[_raceIndex].length;

    _reward = _race._bettingValue * _racerCount * (10000 - executorReward) / 10000;

    if (_race._bettingTokenAddress == ethAddress) {
      _winner.toPayable().transfer(_reward);
    } else {
      IERC20(_race._bettingTokenAddress).transferFrom(address(this), msg.sender, _reward);
    }
  }
}
