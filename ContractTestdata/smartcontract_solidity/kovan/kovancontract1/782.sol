/**
 *Submitted for verification at Etherscan.io on 2019-01-07
*/

pragma solidity ^0.4.0;

contract AgmoPet {
    //Constants
    address owner;
    enum Rarity { NORMAL, RARE, SUPERRARE } //normal = 0, rare = 1, superrare = 2 
    enum Seasonal { NONSEASONAL, SEASONAL } // NON-seasonal = 0, seasonal = 1
    
    //Global Identifiers
    uint globalPetId;
    uint globalEquipmentId;
    uint globalEquipmentTypeId;
    
    //Variables
    uint currentSeason;
    int distanceTolerance;
    uint expPerScan;
    uint expPerFeed;
    uint scanResetHour;
    uint feedResetHour;
    uint levelCap;
    uint levelUpReward;
    uint capLevelScanReward;
    uint gachaponPrice;
    
    //States
    address[] userAddress;
    mapping(uint => string) seasonDescription;
    mapping(address => User) users;
    //PetId => Pet
    mapping(uint => Pet) pets;
    //PetId => TargetPetId => LastScanTime (Unix)
    mapping(uint => mapping(uint => uint)) matchings;
    //PetId => Coordinate
    mapping(uint => Coordinate) listeners;
    //TypeId => Equipment
    mapping(uint => Equipment) equipmentTypes;
    //EquipmentId => TypeId
    mapping(uint => uint) equipments;
    //Rarity => EquipmentType
    mapping(uint => uint[]) equipmentsRarityPool;
    //Season => Rarity => EquipmentType
    mapping(uint => mapping(uint => uint[])) seasonalEquipmentsRarityPool;
    //goldcoin
    mapping(address => uint) goldcoins;
    //feeding (petId => lastFeedTime)
    mapping(uint => uint) feedings;
    uint[100] chancesPool;
    uint[100] seasonalPool;
    
    //Events
    event AddedNewSeason(address indexed _from, uint _seasonId, string _seasonDescription);
    event AddedNewEquipment(address indexed _from, uint _equipmentTypeId, Rarity _rarity, uint _seasonId);
    event AddedNewUser(address indexed _from, address _newUserAddress, string _name);
    event UpdatedPet(address indexed _from, uint indexed _petId, string _petName, uint _petPersonality);
    event ListeningScan(address indexed _from, uint _petId, int _latitude, int _longitude);
    event Scanned(address indexed _from, uint _petId, uint _targetPetId, uint _time);
    event Feed(address indexed _from, uint _petId, uint _time);
    event PetLevelUp(uint indexed _petId, uint _level, uint _currentExp, uint _expNeeded);
    event GotNewEquipment(address indexed _from, uint _equipmentId, uint _equipmentTypeId, Rarity _rarity, Seasonal _seasonal, string _equipmentName, uint petTypeId, uint position, uint minPetPhase);
    event AddedGoldCoins(address indexed _toAddress, uint _amount, uint _total);
    
    struct Coordinate {
        int Latitude;
        int Longitude;
    }
    
    struct Pet{
        mapping(uint => uint) Equipments;
        uint Id;
        uint[] EquipmentIdList;
        uint Type;
        uint Exp;
        uint Level;
        uint Personality;
        string Name;
        address Owner;
    }
    
    struct User {
        string Name;
        uint[] InventoryList;
        uint[] PetIdList;
        bool Intialized;
    }
    
    struct Equipment {
        uint TypeId;
        string Name;
        uint Position;
        uint Rarity;
        uint PetTypeId;
        uint MinPetPhase;
        Seasonal IsSeasonal;
    }
    
    constructor() public {
        currentSeason = 1;
        globalPetId = 1;
        distanceTolerance = 5000;
        expPerScan = 50;
        scanResetHour = 24;
        levelCap = 50;
        levelUpReward = 50;
        capLevelScanReward = 5;
        gachaponPrice = 100;
        globalEquipmentTypeId = 0;
        globalEquipmentId = 0;
        expPerFeed = 25;
        feedResetHour = 3;
        seasonDescription[currentSeason] = "Christmas 2018";
        updateChances(3, 20);
        updateSeasonalChances(100);
        owner = msg.sender;
    }
    
    function addSeason(string _name) public ownerOnly{
        currentSeason++;
        seasonDescription[currentSeason] = _name;
        addSeasonPetForEveryone(currentSeason);
        emit AddedNewSeason(msg.sender, currentSeason, _name);
    }
    
    function addSeasonPetForEveryone(uint _seasonId) private {
        for(uint i=0; i < userAddress.length; i++){
            addPet(userAddress[i], _seasonId);
        }
    }
    
    function addPet(address _address, uint _seasonId) private {
        string memory name = strConcat(users[_address].Name, "'s pet");
        users[_address].PetIdList.push(globalPetId);
        pets[globalPetId] = Pet({Type: _seasonId, Exp:1, Level:1, Personality:0, Name: name, EquipmentIdList : new uint[](0), Id : globalPetId, Owner: _address});
        globalPetId++;
    }
    
    function addNewUser(address _address, string _name) public ownerOnly {
        //Only register if new user
        require(!users[_address].Intialized);
        
        //Start Adding new user
        userAddress.push(_address);
        User memory newUser;
        newUser.Name = _name;
        newUser.Intialized = true;
        users[_address] = newUser;
        
        //Add current season pet for him
        addPet(_address, currentSeason);
        emit AddedNewUser(msg.sender, _address, _name);
    }
    
    function addGoldCoins(address _toAddress, uint _amount) public ownerOnly {
        goldcoins[_toAddress] = goldcoins[_toAddress] + _amount;
        emit AddedGoldCoins(_toAddress, _amount, goldcoins[_toAddress]);
    }

    function getCurrentSeason() public view returns (uint, string) {
        return (currentSeason, seasonDescription[currentSeason]);
    }
    
    function getAllSeason() public view returns (string){
        string memory ret = "\x5B";
        
        for (uint i=1; i <= currentSeason; i++) {
            string memory result = strConcat('{"name": "', seasonDescription[i] , '","id": "');
            result = appendUintToString(result, i);
            result = strConcat(result, '"}');
            if(i != currentSeason){
                result = strConcat(result, ",");
            }
            ret = strConcat(ret, result);
        }
        ret = strConcat(ret, "\x5D");
        return ret;
    }
    
    function updatePet(uint _petId, string _name, uint _personality) public petOwnerOnly(_petId) {
        pets[_petId].Name = _name;
        pets[_petId].Personality = _personality;
        emit UpdatedPet(msg.sender, _petId, _name, _personality);
    }
    
    function getPets(address _user) public view returns (string){
        User storage user = users[_user];
        return getPetsJson(user.PetIdList);
    }
    
    function getPet(uint _petId) public view returns (string){
        return getPetJson(pets[_petId]);
    }
    
    function getPetsJson(uint[] _petIds) private view returns (string){
        string memory ret = "\x5B";
        for (uint i=0; i < _petIds.length; i++) {
            uint currentPetId = _petIds[i];
            Pet storage userPet = pets[currentPetId];
            string memory result = getPetJson(userPet);
            if(i != _petIds.length - 1){
                result = strConcat(result, ",");
            }
            ret = strConcat(ret, result);
        }
        ret = strConcat(ret, "\x5D");
        return ret;
    }
    
    function getPetJson(Pet _pet) private view returns (string) {
        string memory result = strConcat('{"name": "', _pet.Name , '","type": "');
        result = appendUintToString(result, _pet.Type);
        result = strConcat(result, '", "exp" : "');
        result = appendUintToString(result, _pet.Exp);
        result = strConcat(result, '", "level" : "');
        result = appendUintToString(result, _pet.Level);
        result = strConcat(result, '", "personality" : "');
        result = appendUintToString(result, _pet.Personality);
        result = strConcat(result, '", "id" : "');
        result = appendUintToString(result, _pet.Id);
        
        //Append Equipment
        result = strConcat(result, '", "equipmentList" : ');
        result = strConcat(result, getEquipmentByIdsJson(_pet.EquipmentIdList));
        
        result = strConcat(result, '}');
        return result;
    }
    
    function getEquipmentJson(uint _typeId, uint _id) private view returns (string){
        Equipment memory equipment = equipmentTypes[_typeId];
        string memory result = strConcat('{"name": "', equipment.Name , '","typeid": "');
        result = appendUintToString(result, equipment.TypeId);
        result = strConcat(result, '", "position" : "');
        result = appendUintToString(result, equipment.Position);
        if(_id > 0){
            result = strConcat(result, '", "id" : "');
            result = appendUintToString(result, _id);
        }
        result = strConcat(result, '", "isseasonal" : "');
        if(equipment.IsSeasonal == Seasonal.NONSEASONAL)
            result = strConcat(result, "0");    
        else
            result = appendUintToString(result, uint(equipment.IsSeasonal));
            
        result = strConcat(result, '", "petTypeId" : "');
        if(equipment.PetTypeId == 0)
            result = strConcat(result, "0");    
        else
            result = appendUintToString(result, equipment.PetTypeId);
            
        result = strConcat(result, '", "minPetPhase" : "');
        if(equipment.MinPetPhase == 0)
            result = strConcat(result, "0");    
        else
            result = appendUintToString(result, equipment.MinPetPhase);
        
        result = strConcat(result, '", "rarity" : "');
        if(equipment.Rarity == 0)
            result = strConcat(result, "0");    
        else
            result = appendUintToString(result, equipment.Rarity);
        result = strConcat(result, '"}');
        return result;
    }
    
    function getGachaPrice() public view returns (uint) {
        return gachaponPrice;
    }
    
    function getAllEquipments() public view returns (string){
        uint[] memory ids = new uint[](globalEquipmentTypeId);
        for(uint i = globalEquipmentTypeId; i > 0; i--){
            ids[i - 1] = i;
        }
        
        string memory ret = "\x5B";
        for(i = 0 ; i < ids.length; i++){
            ret = strConcat(ret, getEquipmentJson(ids[i],0));
            if(i != ids.length - 1){
                ret = strConcat(ret, ",");
            }
        }
        ret = strConcat(ret, "\x5D");
        return ret;
    }
    
    function getMyEquipments(address _user) public view returns (string) {
        return getEquipmentByIdsJson(users[_user].InventoryList);
    }
    
    function getEquipmentByIdsJson(uint[] _equipmentIds) private view returns (string) {
        uint[] memory typeIds = new uint[](_equipmentIds.length);
        for(uint i=0 ; i < _equipmentIds.length; i++){
            typeIds[i] = equipments[_equipmentIds[i]];
        }
        
        string memory ret = "\x5B";
        for(i = 0 ; i < _equipmentIds.length; i++){
            ret = strConcat(ret, getEquipmentJson(typeIds[i], _equipmentIds[i]));
            if(i != _equipmentIds.length - 1){
                ret = strConcat(ret, ",");
            }
        }
        ret = strConcat(ret, "\x5D");
        return ret;
    }
    
    function feedPet(uint _petId) public petOwnerOnly(_petId) {
        uint totalHours = (now - feedings[_petId] / 60 / 60);
        require(totalHours > feedResetHour);
        
        feedings[_petId] = now;
        pets[_petId].Exp = pets[_petId].Exp + expPerFeed;
        levelUpPet(pets[_petId].Owner, pets[_petId]);
        emit Feed(msg.sender, _petId, feedings[_petId]);
    }
    
    function addEquipment(string _name, uint _position, uint _petTypeId, Rarity _rarity, uint _minPetPhase, bool _isCurrentSeason) public ownerOnly {
        Seasonal seasonal = Seasonal.NONSEASONAL;
        if(_isCurrentSeason)
            seasonal = Seasonal.SEASONAL;
        
        globalEquipmentTypeId++;
        equipmentTypes[globalEquipmentTypeId] = Equipment(globalEquipmentTypeId, _name, _position, uint(_rarity), _petTypeId, _minPetPhase, seasonal);
        if(_isCurrentSeason)
            seasonalEquipmentsRarityPool[currentSeason][uint(_rarity)].push(globalEquipmentTypeId);
        else
            equipmentsRarityPool[uint(_rarity)].push(globalEquipmentTypeId);
        
        emit AddedNewEquipment(msg.sender, globalEquipmentTypeId, _rarity, currentSeason);
    }
    
    function updateEquipment(uint _id, string _name, uint _position, uint _petTypeId) public ownerOnly{
        equipmentTypes[_id].Name = _name;
        equipmentTypes[_id].Position = _position;
        equipmentTypes[_id].PetTypeId = _petTypeId;
    }
    
    function addExistingEquipmentToCurrentSeason(uint _typeId) public ownerOnly {
        Equipment storage equipment = equipmentTypes[_typeId];
        seasonalEquipmentsRarityPool[currentSeason][uint(equipment.Rarity)].push(equipment.TypeId);
    }
    
    //Exp needed to level y = x^2 + 100
    function getExpNeededToLevel(uint _level) private pure returns (uint){
        return (_level * _level) + 100;
    }
    
    function updateChances(uint _extraRare, uint _rare) public {
        require((_extraRare + _rare) < 100);
        uint normal = 100 - _extraRare - _rare;
        uint count = 0;
        //SuperRare
        for(uint i = 0; i < _extraRare; i++){
            chancesPool[count] = 2;
            count++;
        }
        //Rare
        for(i = 0; i < _rare; i++){
            chancesPool[count] = 1;
            count++;
        }
        //Normal
        for(i = 0; i < normal; i++){
            chancesPool[count] = 0;
            count++;
        }
    }
    
    function updateSeasonalChances(uint _seasonalProbability) public {
        require(_seasonalProbability <= 100);
        uint nonSeasonal = 100 - _seasonalProbability;
        uint count = 0;
        //Seasonal
        for(uint i = 0; i < _seasonalProbability; i++){
            seasonalPool[count] = uint(Seasonal.SEASONAL);
            count++;
        }
        //Non Seasonal
        for(i = 0; i < nonSeasonal; i++){
            seasonalPool[count] = uint(Seasonal.NONSEASONAL);
            count++;
        }
    }
    
    function testGiveExp(uint _petId, uint _amount) public ownerOnly {
        pets[_petId].Exp = pets[_petId].Exp + _amount;
        levelUpPet(pets[_petId].Owner, pets[_petId]);
    }
    
    function equip(uint[] _toEquip, uint[] _toUnequip, uint _petId) public petOwnerOnly(_petId) {
        unequip(_toUnequip, _petId);
        equip(_toEquip, _petId);
    }
    
    function equip(uint[] _equipmentIds, uint _petId) public petOwnerOnly(_petId) {
        for(uint i = 0 ; i < _equipmentIds.length; i++){
            uint _equipmentId = _equipmentIds[i];
            require(arrayExist(users[msg.sender].InventoryList, _equipmentId));
            arrayRemove(users[msg.sender].InventoryList, arrayFindIndex(users[msg.sender].InventoryList, _equipmentId));
            pets[_petId].EquipmentIdList.push(_equipmentId);
        }
    }
    
    function unequip(uint[] _equipmentIds, uint _petId) public petOwnerOnly(_petId) {
        for(uint i = 0; i < _equipmentIds.length; i++){
            uint _equipmentId = _equipmentIds[i];
            require(arrayExist(pets[_petId].EquipmentIdList, _equipmentId));
            arrayRemove(pets[_petId].EquipmentIdList, arrayFindIndex(pets[_petId].EquipmentIdList, _equipmentId));
            users[msg.sender].InventoryList.push(_equipmentId);
        }
    }
    
    function listen(uint _petId, int _latitude, int _longitude) public petOwnerOnly(_petId) {
        listeners[_petId] = Coordinate(_latitude, _longitude);
        emit ListeningScan(msg.sender, _petId, _latitude, _longitude);
    }
    
    function scan(uint _petId, int _latitude, int _longitude, uint _targetPetId) public petOwnerOnly(_petId) {
        Coordinate memory targetCoordinate = listeners[_targetPetId];
        //Cannot scan self
        require(pets[_targetPetId].Owner != msg.sender);
        //Must be near together
        require(targetCoordinate.Latitude != 0 && targetCoordinate.Longitude != 0);
        require(isNear(_latitude, _longitude, targetCoordinate.Latitude, targetCoordinate.Longitude));
        //Must exceed scanResetHour hours
        uint totalHours = (now - matchings[_petId][_targetPetId]) / 60 / 60;
        require(totalHours >= scanResetHour);
        
        //Credit exp
        pets[_petId].Exp = pets[_petId].Exp + expPerScan;
        
        //Levelup if possible
        levelUpPet(pets[_petId].Owner, pets[_petId]);
        
        //Set last scan to now
        matchings[_petId][_targetPetId] = now;
        
        emit Scanned(msg.sender, _petId, _targetPetId, now);
    }
    
    function levelUpPet(address _address, Pet storage _pet) private {
        //TODO need to give extra reward
        if(_pet.Level >= levelCap){
            goldcoins[_address] = goldcoins[_address] + capLevelScanReward;
            return; 
        }
        while(getExpNeededToLevel(_pet.Level) < _pet.Exp){
            uint expNeeded = getExpNeededToLevel(_pet.Level);
            _pet.Level++;
            _pet.Exp = _pet.Exp - expNeeded;
            goldcoins[_address] = goldcoins[_address] + levelUpReward;
            emit PetLevelUp(_pet.Id, _pet.Level, _pet.Exp, getExpNeededToLevel(_pet.Level));
        }
    }
    
    function getLastScanned(uint _petId, uint _targetPetId) public view returns (uint) {
        return matchings[_petId][_targetPetId];
    }
    
    function getGoldCoinBalance(address _user) public view returns (uint){
        return goldcoins[_user];
    }
    
    function setDistanceTolerance(int newTolerance) public ownerOnly {
        distanceTolerance = newTolerance;
    }
    
    function getDistanceTolerance() public view returns (int) {
        return distanceTolerance;
    }
    
    function setExpPerScan(uint _newExp) public ownerOnly {
        expPerScan = _newExp;
    }
    
    function getExpPerScan() public view returns (uint){
        return expPerScan;
    }
    
    function setLevelCap(uint _newLevelCap) public ownerOnly {
        levelCap = _newLevelCap;
    }
    
    function getLevelCap() public view returns (uint){
        return levelCap;
    }
    
    function setScanResetHour(uint _newScanResetHour) public ownerOnly {
        scanResetHour = _newScanResetHour;
    }
    
    function getScanResetHour() public view returns (uint){
        return scanResetHour;
    }
    
    function getEquipment() public userOnly {
        //Deduct money
        goldcoins[msg.sender] = goldcoins[msg.sender] - gachaponPrice;
        //randomize rarity
        uint rarity = chancesPool[random(0, chancesPool.length)];
        //randomize is it get seasonal item
        Seasonal seasonalType = Seasonal(seasonalPool[random(0, seasonalPool.length)]);
        uint newEquipmentId;
        if(seasonalType == Seasonal.SEASONAL && seasonalEquipmentsRarityPool[currentSeason][rarity].length > 0)
            newEquipmentId = seasonalEquipmentsRarityPool[currentSeason][rarity][random(0, seasonalEquipmentsRarityPool[currentSeason][rarity].length)];
        else
            newEquipmentId = equipmentsRarityPool[rarity][random(0, equipmentsRarityPool[rarity].length)];
        
        globalEquipmentId++;
        //assign id to user
        users[msg.sender].InventoryList.push(globalEquipmentId);
        equipments[globalEquipmentId] = newEquipmentId;
        emit GotNewEquipment(msg.sender, globalEquipmentId, newEquipmentId, Rarity(equipmentTypes[newEquipmentId].Rarity), equipmentTypes[newEquipmentId].IsSeasonal, equipmentTypes[newEquipmentId].Name, equipmentTypes[newEquipmentId].PetTypeId, equipmentTypes[newEquipmentId].Position, equipmentTypes[newEquipmentId].MinPetPhase);
    }
    
    function getExpRequiredToLevelUp(uint _petId) public view returns (string) {
        Pet storage currentPet = pets[_petId];
        string memory result = strConcat('{"currentExp": ', uintToString(currentPet.Exp) , ',"requiredExp": ');
        result = appendUintToString(result, getExpNeededToLevel(currentPet.Level));
        result = strConcat(result, '}');
        return result;
    }
    
    modifier ownerOnly {
        require(msg.sender == owner);
        _;
    }
    
    modifier userOnly() {
        require(users[msg.sender].Intialized);
        _;
    }
    
    modifier petOwnerOnly(uint _petId) {
        require(users[msg.sender].Intialized);
        require(pets[_petId].Owner == msg.sender);
        _;
    }
    
    uint nonce;
    
    function random(uint _from, uint _to) public returns (uint) {
        uint randomnumber = uint(keccak256(abi.encodePacked(now, msg.sender, nonce))) % _to;
        randomnumber = randomnumber + _from;
        nonce++;
        return randomnumber;
    }
    
    function isNear(int _lat1, int _long1, int _lat2, int _long2) internal view returns (bool){
        int latDifference = _lat1 - _lat2;
        if(latDifference < 0){
            latDifference = latDifference * -1;
        }
        int longDifference = _long1 - _long2;
        if(longDifference < 0){
            longDifference = longDifference * -1;
        }
        
        int difference = latDifference + longDifference;
        if(difference < distanceTolerance){
            return true;
        }
        return false;
    }
    
    //library
    function uintToString(uint v) pure internal returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory s = new bytes(i);
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - 1 - j];
        }
        str = string(s);
    }

    function appendUintToString(string inStr, uint v) pure internal returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory inStrb = bytes(inStr);
        bytes memory s = new bytes(inStrb.length + i);
        uint j;
        for (j = 0; j < inStrb.length; j++) {
            s[j] = inStrb[j];
        }
        for (j = 0; j < i; j++) {
            s[j + inStrb.length] = reversed[i - 1 - j];
        }
        str = string(s);
    }
    
    function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }
    
    function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string) {
        return strConcat(_a, _b, _c, _d, "");
    }
    
    function strConcat(string _a, string _b, string _c) internal pure returns (string) {
        return strConcat(_a, _b, _c, "", "");
    }
    
    function strConcat(string _a, string _b) internal pure returns (string) {
        return strConcat(_a, _b, "", "", "");
    }
    
    function arrayFindIndex(uint[] _array, uint _input) internal pure returns (uint) {
        for(uint i = 0; i < _array.length; i++){
            if(_array[i] == _input)
                return i;
        }
    }
    
    function arrayExist(uint[] _array, uint _input) internal pure returns (bool) {
        for(uint i = 0; i < _array.length; i++){
            if(_array[i] == _input)
                return true;
        }
    }
    
    function arrayRemove(uint[] storage _array, uint index) internal returns(uint[]) {
        if (index >= _array.length) return;

        for (uint i = index; i<_array.length-1; i++){
            _array[i] = _array[i+1];
        }
        delete _array[_array.length-1];
        _array.length--;
        return _array;
    }
    
}
