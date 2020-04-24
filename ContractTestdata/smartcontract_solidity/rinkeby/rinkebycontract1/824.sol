/**
 *Submitted for verification at Etherscan.io on 2019-02-07
*/

pragma solidity ^0.4.25;


contract AxieCore{
  function getAxie(
    uint256 _axieId
  )
    external
    view
    returns (uint256 , uint256 );
  function ownerOf(uint256 _tokenId) view returns(address);
}

contract Race{
  event RaceStep(
    uint indexed axieId,
    uint indexed raceId,
    bool didCrit,
    bool gainSpeed
  );
  event FinalScore(
    uint indexed axieId,
    uint raceTime
  );
  event RacerParams(
    uint baseSpeed,
    uint critChance,
    uint speedChance,
    uint,
    uint,
    uint
  );
  struct Type{
    uint hp;
    uint speed;
    uint skill;
    uint morale;
  }
  //race variables
  address[] public racers;
  uint[] public axiesRacing;
  mapping(uint=>bool) public axiesUsed;
  uint numRacers=4;
  uint public entryCursor=0;
  uint public entryFee=0 ether;//0.01 ether;
  uint public raceFinishedAt=0;
  uint public raceId=0;

  //race constants
    uint TOTAL_SUSHIS = 20;
    uint MIN_STAT = 27;
    uint MAX_STAT = 61;
    uint STAT_SPREAD = MAX_STAT - MIN_STAT;

    uint MIN_BASE_SPEED = 1000;
    uint MAX_BASE_SPEED = 850;

  //x10000
    uint PROBABILITY_MULTIPLIER=10000;
    uint MIN_CRIT_CHANCE = 1000;//0.1;
    uint MAX_CRIT_CHANCE = 2810;//0.281;

    uint MIN_SPEED_CHANCE = 1000;//0.1;
    uint MAX_SPEED_CHANCE = 2910;//0.291;

    // for base speed max = min, because we substract from the value of base speed, not add
    //TODO: hardcode these values and avoid rounding issues
    uint BASE_SPEED_POINT;
    uint CRIT_CHANCE_POINT;
    uint SPEED_CHANCE_POINT;

  //stats calculation final variables
  mapping(uint => Type) internal typeMap;
  mapping(uint => Type) internal bonusMap;
  uint[] internal masks;
  AxieCore public axie=AxieCore(0x704Eb9Ac4e15953d8522943459bCa8aE65766145);//new AxieCore();////(0xF5b0A3eFB8e8E4c201e2A935F110eAaF3FFEcb8d); //0xC2093A90a4046B7F347c84f512651e6977BD11a0);
  constructor() public{
    racers=new address[](numRacers);
    axiesRacing=new uint[](numRacers);
    //Beast
    typeMap[0]=Type({hp: 2, speed: 3, skill: 2, morale: 5});
    bonusMap[0]=Type({hp: 0, speed: 1, skill: 0, morale: 3});
    //Bug
    typeMap[1]=Type({hp: 3, speed: 2, skill: 3, morale: 4});
    bonusMap[1]=Type({hp: 1, speed: 0, skill: 0, morale: 3});
    //Bird
    typeMap[2]=Type({hp: 1, speed: 5, skill: 3, morale: 3});
    bonusMap[2]=Type({hp: 0, speed: 3, skill: 0, morale: 1});
    //Plant
    typeMap[3]=Type({hp: 5, speed: 2, skill: 2, morale: 3});
    bonusMap[3]=Type({hp: 3, speed: 0, skill: 0, morale: 1});
    //Aquatic
    typeMap[4]=Type({hp: 4, speed: 4, skill: 3, morale: 1});
    bonusMap[4]=Type({hp: 1, speed: 3, skill: 0, morale: 0});
    //Reptile
    typeMap[5]=Type({hp: 4, speed: 3, skill: 2, morale: 3});
    bonusMap[5]=Type({hp: 3, speed: 1, skill: 0, morale: 0});
    //hidden_1
    typeMap[6]=Type({hp: 2, speed: 4, skill: 5, morale: 1});
    //hidden_2
    typeMap[7]=Type({hp: 3, speed: 3, skill: 4, morale: 2});
    //hidden_3
    typeMap[7]=Type({hp: 5, speed: 4, skill: 1, morale: 2});

    masks=new uint[](6);
    masks[0]=uint(0x3C0000000000000000000000000000000000000000000000);//eyes
    masks[1]=uint(0x3C00000000000000000000000000000000000000);//mouth
    masks[2]=uint(0x3C000000000000000000000000000000);//ears
    masks[3]=uint(0x3C0000000000000000000000);//horn
    masks[4]=uint(0x3C00000000000000);//back
    masks[5]=uint(0x3C000000);//tail

    uint TOTAL_SUSHIS = 20;
    uint MIN_STAT = 27;
    uint MAX_STAT = 61;
    uint STAT_SPREAD = MAX_STAT - MIN_STAT;

    uint MIN_BASE_SPEED = 1000;
    uint MAX_BASE_SPEED = 850;

  //x10000
    uint PROBABILITY_MULTIPLIER=10000;
    uint MIN_CRIT_CHANCE = 1000;//0.1;
    uint MAX_CRIT_CHANCE = 2810;//0.281;

    uint MIN_SPEED_CHANCE = 1000;//0.1;
    uint MAX_SPEED_CHANCE = 2910;//0.291;
    // for base speed max = min, because we substract from the value of base speed, not add
    //TODO: hardcode these values and avoid rounding issues
    //Original decimal values multiplied by PROBABILITY_MULTIPLIER
    BASE_SPEED_POINT = 44120;//statPoint(MIN_BASE_SPEED, MAX_BASE_SPEED, STAT_SPREAD);
    CRIT_CHANCE_POINT = 532350;//statPoint(MAX_CRIT_CHANCE, MIN_CRIT_CHANCE, STAT_SPREAD);
    SPEED_CHANCE_POINT = 561760;//statPoint(MAX_SPEED_CHANCE, MIN_SPEED_CHANCE, STAT_SPREAD);
  }
  function statPoint(uint max, uint min, uint spread) public pure returns(uint){
    return (max - min) / spread;
  }
  function getStats(uint id) public view returns (uint,uint,uint,uint){
    var (_genes,_bornAt) = axie.getAxie(id);
    return computeStatsFromGene(_genes);
  }
  function computeStatsFromGene(uint gene) public view returns(uint,uint,uint,uint){
    assert(gene!=0);
    uint base=uint(gene & 0xF000000000000000000000000000000000000000000000000000000000000000) >> 252;
    uint hp=23+4*typeMap[base].hp;
    uint speed=23+4*typeMap[base].speed;
    uint skill=23+4*typeMap[base].skill;
    uint morale=23+4*typeMap[base].morale;
    uint partType;
    for(uint8 i=0;i<6;i++){
      partType=uint(gene & masks[i]) >> (186-32*i);
      hp+=bonusMap[partType].hp;
      speed+=bonusMap[partType].speed;
      skill+=bonusMap[partType].skill;
      morale+=bonusMap[partType].morale;
    }
    return(hp,speed,skill,morale);
  }
  function enterRace(uint axieId) public payable{
    //first confirm caller is valid owner of axie
    require(axie.ownerOf(axieId)==msg.sender);
    require(raceFinishedAt==0);//no current race
    var (_genes,_bornAt) = axie.getAxie(axieId);
    require(_genes!=0);
    require(msg.value==entryFee);
    require(!axiesUsed[axieId]);
    axiesUsed[axieId]=true;
    racers[entryCursor]=msg.sender;
    axiesRacing[entryCursor]=axieId;
    entryCursor++;
    if(entryCursor>numRacers-1){
      raceFinishedAt=block.number+1;
      entryCursor=0;
    }
  }
  /*
    duplicate race processing code in order to have a way to know the winner from a view-only call, so that the winner can be the one tasked with the transaction to finalize the race (in case this is how we want to do it. These methods also assist with testing).
  */
  function processRaceView() public view returns(address winner){

  }
  function processRacerView(uint axieId,uint randomSeed) public view returns(uint timeToFinish){

  }
  /*
    TODO: CHANGE TO PRIVATE BEFORE MAINNET
  */
  function processRaceEmit() public returns(address){
    require(block.number>raceFinishedAt && raceFinishedAt>0);
    uint seed=getRandomSeed(raceFinishedAt);
    uint lowestScore=0;
    lowestScore-=1; //maximum uint value
    address currentWinner;
    for(uint8 i=0;i<numRacers;i++){
      uint score=processRacer(axiesRacing[i],seed);
      if(score<lowestScore){
        lowestScore=score;
        currentWinner=racers[i];
      }
    }
    return currentWinner;
  }
  function processRacer(uint axieId,uint randomSeed) public returns(uint timeToFinish){
      var (hp,speed,skill,morale) = getStats(axieId);

      // An array is used instead of normal variables because the amount of variables here exceeds Solidity stack limitations
      uint[8] memory uintValues=[
        0, //score
        0, //eatenSushis
        0, //bites
        0, //speedBites
        MIN_BASE_SPEED * PROBABILITY_MULTIPLIER - ((hp + skill - 2 * 27) * (BASE_SPEED_POINT)), //baseSpeed
        ((morale - 27) * (CRIT_CHANCE_POINT)) + MIN_CRIT_CHANCE, //critChance
        ((speed - 27) * (SPEED_CHANCE_POINT)) + MIN_SPEED_CHANCE, //speedChance
        0 //prandIndex
      ];
      emit RacerParams(uintValues[4],uintValues[5],uintValues[6],BASE_SPEED_POINT,hp,skill);
      bool speedBuffActive = false;
      int speedBites = 0;
      while (uintValues[1] < TOTAL_SUSHIS) {
        bool didCrit=random(PROBABILITY_MULTIPLIER, randomSeed, uintValues[7], uint256(msg.sender)) * PROBABILITY_MULTIPLIER < uintValues[5];
        uintValues[7]++;
        bool gainSpeed=random(PROBABILITY_MULTIPLIER, randomSeed, uintValues[7], uint256(msg.sender)) * PROBABILITY_MULTIPLIER < uintValues[6];
        uintValues[7]++;
        emit RaceStep(axieId,raceId,didCrit,gainSpeed);
        if(didCrit){
          uintValues[1]+=2;
        }
        else{
          uintValues[1]+=1;
        }
        if(speedBuffActive){
          uintValues[3]-=1;
          if(!(uintValues[3]>0)){
            speedBuffActive=false;
          }
          uintValues[0]+=uintValues[4]/2;
        }
        else{
          uintValues[0]+=uintValues[4];
        }
        if(!speedBuffActive && gainSpeed){
          speedBuffActive=true;
          uintValues[3]=2;
        }
        uintValues[2]+=1;
      }
      emit FinalScore(axieId,uintValues[0]);
      return uintValues[0];
  }
  function finalizeRace() public{
    //must be executed some blocks after all race participants have entered
    require(block.number>raceFinishedAt && raceFinishedAt>0);
    address winner=processRaceEmit();
    //set things back to pre-race state
    raceFinishedAt=0;
    for(uint8 i=0;i<numRacers;i++){
      axiesUsed[axiesRacing[i]]=false;
    }
    raceId++;
    //send payment (can change this to a separate transaction withdraw if necessary)
    winner.transfer(this.balance);
  }

  /*
    debug only functions
    DELETE THESE BEFORE MAINNET
  */
  function cannedEntry() public{
    racers[0]=0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
    axiesRacing[0]=13073;
    racers[1]=0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
    axiesRacing[1]=15863;
    racers[2]=0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db;
    axiesRacing[2]=26750;
    racers[3]=0x583031d1113ad414f02576bd6afabfb302140225;
    axiesRacing[3]=20753;
    raceFinishedAt=block.number+1;
    entryCursor=0;
    raceFinishedAt=block.number+1;
  }
  function progress() public{

  }
  function setEntryFee(uint fee) public{
    entryFee=fee;
  }
  function nowBlock() public view returns(uint){
    return block.number;
  }

  /*
    Random number generation
    Optional: make internal for small optimization
  */
  function getRandomSeed(uint blockn)
    public
    returns (uint256 randomNumber)
  {
      return uint256(keccak256(
          abi.encodePacked(
            blockhash(blockn))
      ));
  }
  function random(uint256 upper, uint256 seed, uint256 index, uint256 entropy)
    public
    returns (uint256 randomNumber)
  {
      return uint256(keccak256(abi.encodePacked(seed,index,entropy))) % upper + 1;
  }
}
