/**
 *Submitted for verification at Etherscan.io on 2019-08-05
*/

pragma solidity ^0.4.23;


contract AxieIncubatorMock {
  struct Axie {
    uint256 genes;
    uint256 bornAt;
  }

  struct Axiegg {
    uint256 genesHash;
    uint256 genes; // `genesHash` and `genes` are mutually exclusive.
    uint256 sireGenes; // (`genesHash`, `genes`) combo and `sireGenes` are mutually exclusive.
    uint256 matronGenes; // (`genesHash`, `genes`) combo and `sireGenes` are mutually exclusive.
    uint256 seed; // (`genesHash`, `genes`) combo and `seed` are mutually exclusive.
  }

  struct PetiteGrowth {
    uint256 axieId;
    uint256 growthDate;
  }

  uint256[] public NEEDED_EXP_FOR_BREEDING = [300, 900, 900, 1500, 2400, 3000, 3000];

  uint256 public TO_LARVA_DURATION = 1 seconds;
  uint256 public TO_PETITE_DURATION = 5 seconds;
  uint256 public TO_ADULT_DURATION = 10 seconds;

  bool public initialized = false;

  uint256 private _breedingFee = 2 finney;

  bool public shouldUseOraclize = false;
  uint256 public defaultGasLimit = 90000;

  bool public shouldBypassPetiteConfirmation = false;

  Axie[] axies;
  mapping (uint256 => Axiegg) public axieggById;

  mapping (uint256 => PetiteGrowth) public petiteGrowth;
  mapping (uint256 => uint256) public petiteGrowthQueryId;

  event PetiteGrowthStarted(uint256 indexed _axieId, bool _withGenes);
  event PetiteGrowthFinished(uint256 indexed _axieId);

  event PetiteGrowthByOraclizeStarted(uint256 indexed _axieId, uint256 _queryId);
  event PetiteGrowthByOraclizeRetried(uint256 indexed _axieId, uint256 _newQueryId, uint256 _oldQueryId);
  event PetiteGrowthByOraclizeFinished(uint256 indexed _axieId, uint256 _queryId);

  constructor() public {
    return;
  }

  function requireEnoughExpForBreeding(
    uint256 _axieId
  )
    external
    view
  {
    _requireEnoughExpForBreeding(_axieId);
  }

  function _requireEnoughExpForBreeding(
    uint256 _axieId
  )
    internal
    view
    returns (bool value)
  {
    return true;
  }

  function _min(uint256 _a, uint256 _b) internal pure returns (uint256) {
    return _a < _b ? _a : _b;
  }

  function growToPetiteAxie(
    uint256 _axieId
  )
    external
  {
    _growToPetiteAxie(_axieId, msg.sender);
  }

  function _growToPetiteAxie(
    uint256 _axieId,
    address _sender
  )
    internal
  {
    Axiegg storage _axiegg = axieggById[_axieId];

    if (_axiegg.genesHash != 0 || !shouldUseOraclize) {
      petiteGrowthQueryId[_axieId] = uint256(-1);
      emit PetiteGrowthStarted(_axieId, _axiegg.genesHash != 0);
    } else {
      emit PetiteGrowthByOraclizeStarted(_axieId, 10);
    }
  }

  function breedAxies(
    uint256 _sireId,
    uint256 _matronId
  )
    external
    payable
    returns (uint256 /* _axieId */)
  {
    return _breedAxies(_sireId, _matronId);
  }

  function _breedAxies(
    uint256 _sireId,
    uint256 _matronId
  )
    internal
    returns (uint256 /* _axieId */)
  {
    require(msg.value >= _breedingFee, "Insufficient Fee");
    Axie memory _axie = Axie(0, now);
    Axiegg memory _axiegg;
    _axiegg.sireGenes = _sireId;
    _axiegg.matronGenes = _matronId;
    _axiegg.seed = 0;

    uint256 _axieId = axies.push(_axie) - 1;
    axieggById[_axieId] = _axiegg;

    return _axieId;
  }

 function finishGrowthToPetiteAxie(
    uint256 _axieId,
    uint256 _genesOrSeed
  )
    external
  {
    require(petiteGrowthQueryId[_axieId] == uint256(-1));
    Axiegg storage _axiegg = axieggById[_axieId];
    _finishGrowthToPetiteAxie(_axieId, _axiegg, _genesOrSeed);
    delete petiteGrowthQueryId[_axieId];
  }

 function _finishGrowthToPetiteAxie(
    uint256 _axieId,
    Axiegg storage _axiegg,
    uint256 _genesOrSeed
  )
    internal
  {
    if (_axiegg.genesHash != 0) {
      _axiegg.genes = _genesOrSeed;
      delete _axiegg.genesHash;
    } else {
      _axiegg.seed = uint256(keccak256(abi.encodePacked(_genesOrSeed)));
    }

    emit PetiteGrowthFinished(_axieId);
  }
}
