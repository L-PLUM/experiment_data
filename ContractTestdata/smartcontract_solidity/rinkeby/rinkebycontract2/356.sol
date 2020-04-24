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
