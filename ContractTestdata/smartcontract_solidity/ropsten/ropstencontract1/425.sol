/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity ^0.4.25;

//2019.02.19
///設定合約管理者為master合約
//land1
//slave 2.1.0測試版


contract owned {
    address public master;
    address public contract_owner;

    constructor() public{
        master = 0x188A71fb2582bc51451Af29b2D06567856C4C7D6; //測試
        contract_owner = msg.sender;
    }

    modifier onlyMaster{
        require(msg.sender == master);
        _;
    }

    modifier onlyowner{
        require(msg.sender == contract_owner);
        _;
    }

    function transferMastership(address new_master) public onlyMaster {
        master = new_master;
    }

    function transferownership(address new_owner) public onlyowner {
        contract_owner = new_owner;
    }
}

interface IERC165 {
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

interface IERC721Receiver {
    function onERC721Received(address _operator, address _from, uint256 _tokenId, bytes _data) external returns(bytes4);
}

contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;
    
    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) external view returns (bool) {
        return _supportedInterfaces[interfaceId];
    }
    
    function _registerInterface(bytes4 interfaceId) internal {
        require(interfaceId != 0xffffffff);
        _supportedInterfaces[interfaceId] = true;
    }
}


///ERC20 interface
interface ERC20_interface {
  function balanceOf(address who) external view returns (uint256);
  function transfer(address to, uint256 value) external returns(bool);
}

 interface treasure{
     function callTreasureMin(uint index, address target, uint16 mintedAmount) external;
     function callTreasureBurn(uint index, address target, uint16 burnedAmount) external;
 }

///ERC20 標準
contract ERC20 {
  uint256 public totalSupply;
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns(bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}

library Address {
    
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

library SafeMath{
    
     function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c;
    }
    
     function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
        return c;
    }
    
    
 }
 
 library SafeMath16{
     function add(uint16 a, uint16 b) internal pure returns (uint16) {
        uint16 c = a + b;
        require(c >= a);

        return c;
    }
    
    function sub(uint16 a, uint16 b) internal pure returns (uint16) {
        require(b <= a);
        uint16 c = a - b;
        return c;
    }
    
     function mul(uint16 a, uint16 b) internal pure returns (uint16) {
        if (a == 0) {
            return 0;
        }
        uint16 c = a * b;
        require(c / a == b);
        return c;
    }
    
    function div(uint16 a, uint16 b) internal pure returns (uint16) {
        require(b > 0);
        uint16 c = a / b;
        return c;
    }
 }

///ERC721標準
contract ERC721{

     event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
     event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
     event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

     function balanceOf(address _owner) public view returns (uint256);
     function ownerOf(uint256 _tokenId) public view returns (address);
     function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) public payable;
     function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable;
     function transferFrom(address _from, address _to, uint256 _tokenId) public payable;
     function approve(address _approved, uint256 _tokenId) external payable;
     function setApprovalForAll(address _operator, bool _approved) external;
     function getApproved(uint256 _tokenId) public view returns (address);
     function isApprovedForAll(address _owner, address _operator) public view returns (bool);
 }

contract external_function{
    function inquire_totdomains_amount() public view returns(uint16);
    function inquire_domain_level(uint16 _id) public view returns(uint8);
    function inquire_domain_building(uint16 _id, uint8 _index) public view returns(uint8);
    function inquire_domain_cooltime(uint16 _id) public view returns(uint);
    
    function domain_build(uint16 _id,  uint8 _building) external;
    function reconstruction(uint16 _id, uint8 _index, uint8 _building)external;
    
    function domain_reward(address _user, uint16 _id) external;
    function transfer_master(address _to, uint16 _id) public;
    function retrieve_domain(uint16 _id) external;
}



contract slave is ERC165, ERC721, external_function, owned{
    
    constructor() public{
        // register the supported interfaces to conform to ERC721 via ERC165
        _registerInterface(_InterfaceId_ERC721);

    }
    
    address treasure_contract = 0x0Cb9ae3b581e874bE6363d71D5d0d3449eC93640;
    
    string public at_Area = "魔幻魔法區";
    
    uint16 public city_number = 1; //給主合約辨識，每個Area編號不能重複
    
    string name = "land1";
    string symbol = "land1";
    
    using SafeMath for uint256;
    using SafeMath16 for uint16;
    using Address for address;
    
    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
    bytes4 private constant _InterfaceId_ERC721 = 0x80ac58cd;


    // Mapping from owner to number of owned domain
    mapping (address => uint256) private owned_domain_amount;

    // Mapping from owner to operator approvals
    mapping (address => mapping (address => bool)) private _operatorApprovals;

  

    struct domain{
        address owner; //領土擁有者
        address backup; //避免擁有者丟失地址
        
        uint8 star; //星級
        uint8 level; //等級
        uint8[] building; //建築(開始時四座建築) 
        uint cooltime; //收割冷卻結束時間
        
        address approvals; //轉移權所有者 (ERC721標準)
    }
    
    uint public every_cooltime = 86400;

    struct city_info{
        address mayor; //市長
    }
    
    uint8 public building_amount = 4; //建築物數量
    uint8 public building_type_amount = 11; //建築物類型數量(包含空地)
    
    
    uint8 level_limit = 5; //等級上限
    uint8 star_limit = 5; //星級上限
    
    uint8 public domains_amount = 100; //每個城市土地數量
    
    domain[100] public citys; //一個區域有100個土 地

//manage
    function set_building_amount(uint8 _building_amount) public onlyowner{
        building_amount = _building_amount;
    }
    
    function set_building_type_amount(uint8 _building_type_amount) public onlyowner{
        building_type_amount = _building_type_amount;
    }
    
    
    
    function set_level_limit(uint8 _level_limit) public onlyowner{
        level_limit = _level_limit;
    }
    
    function set_star_limit(uint8 _star_limit) public onlyowner{
        star_limit = _star_limit;
    }

    function set_Area_name(string _Area_name) public onlyowner{
        at_Area = _Area_name;
    }
    

//inquire function

    function inquire_domain_level(uint16 _id) public view returns(uint8){
        if(citys[_id].level <= level_limit){
            return citys[_id].level;
        }
        else 
            return 0;
    }
    
    function inquire_domain_star(uint16 _id) public view returns(uint8){
        return citys[_id].star;
    }
    
    function inquire_domain_building(uint16 _id, uint8 _index) public view returns(uint8){
        return citys[_id].building[_index];
    }
    
    
    function inquire_tot_domain_building(uint16 _id) public view returns(uint8[]){
        return citys[_id].building;
    }
    
    function inquire_domain_cooltime(uint16 _id) public view returns(uint){
        return citys[_id].cooltime;
    }

    function inquire_totdomains_amount() public view returns(uint16){
      return uint16(citys.length);
    }//查詢共有幾座城市


//external function

    function() payable public{
    }

    function domain_build(uint16 _id,  uint8 _building) external onlyMaster{
        require(citys[_id].building.length < building_amount,"不能超出可建設區塊數");
        // 0 ~ building_amount-1
        require(_building != 0, "不能蓋空地");
        require(_building < building_type_amount,"不能超出可建設種類"); //必須是已開放種類
        citys[_id].building.push(_building);
            
        if(citys[_id].star < star_limit){
            citys[_id].star += 1;
        }
    }
    
    function reconstruction(uint16 _id, uint8 _index, uint8 _building)
    external onlyMaster{
        
        require(_index < building_amount); // 0 ~ building_amount-1
        require(_building != 0); //不能蓋 "空地"
        require(_building < building_type_amount); //必須是已開放種類
        
        require(citys[_id].building[_index] != 0); //確認不是空建築

        citys[_id].building[_index] = _building; //改建建築物
    }

    function domain_reward(address _user, uint16 _id) external onlyMaster{
        uint index = 0;
        uint8 star = inquire_domain_star(_id);
        require(citys[_id].owner == _user);
        require(citys[_id].cooltime <= now);
        citys[_id].cooltime = now.add(every_cooltime);
        treasure(treasure_contract).callTreasureMin(index, _user , star);

    }//領取領土獎勵

    function transfer_master(address _to, uint16 _id) public onlyMaster{
        require(_to != address(0));
        
        address domain_owner = citys[_id].owner;
        
        if (domain_owner != 0x0){
            owned_domain_amount[domain_owner] = owned_domain_amount[domain_owner].sub(1);
        }
        
        if(citys[_id].star == 0){ 
            citys[_id].star += 1;
        }
        
        owned_domain_amount[_to] = owned_domain_amount[_to].add(1);
        citys[_id].owner = _to;
        if(citys[_id].level < level_limit){
            citys[_id].level += 1;
        }
        
        emit Transfer(domain_owner, _to, _id);
    }//透過master合約執行的轉移

    function retrieve_domain(uint16 _id) external onlyMaster{
        require(msg.sender == citys[_id].backup);
        transfer_master(contract_owner, _id);
        emit Transfer(citys[_id].owner, contract_owner, _id);
    }//領土遺失領回



//ERC721 function
    function balanceOf(address _owner) public view returns (uint256){
        require(_owner != address(0));
        return owned_domain_amount[_owner];
    }
    function ownerOf(uint256 _tokenId) public view returns (address){
        address owner = citys[_tokenId].owner;
        return owner;
    }
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public payable{
        transferFrom(_from, _to, _tokenId);
        require(_checkOnERC721Received(_from, _to, _tokenId, _data));
    }
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) public payable{
        safeTransferFrom(_from, _to, _tokenId, "");
    }
    function transferFrom(address _from, address _to, uint256 _tokenId) public payable{
        require(_isApprovedOrOwner(msg.sender, _tokenId));
        _transferFrom(_from, _to, _tokenId);
    }
    function approve(address _approved, uint256 _tokenId) external payable{
        address owner = ownerOf(_tokenId);
        require(_approved != owner);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        citys[_tokenId].approvals = _approved;
        emit Approval(owner, _approved, _tokenId);
    }
    function setApprovalForAll(address _operator, bool _approved) external{
        require(_operator != msg.sender);
        _operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }
    function getApproved(uint256 _tokenId) public view returns (address){
        require(_exists(_tokenId));
        return citys[_tokenId].approvals;
    }
    function isApprovedForAll(address _owner, address _operator) public view returns (bool){
        return _operatorApprovals[_owner][_operator];
    }
    
    function _exists(uint256 _tokenId) internal view returns (bool) {
        address owner = citys[_tokenId].owner;
        return owner != address(0);
    }

    function _isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
        address owner = ownerOf(_tokenId);
        return (_spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender));
    }
    
    function _transferFrom(address _from, address _to, uint256 _tokenId) internal {
        require(ownerOf(_tokenId) == _from);
        require(_to != address(0));

        _clearApproval(_tokenId);

        owned_domain_amount[_from] = owned_domain_amount[_from].sub(1);
        owned_domain_amount[_to] = owned_domain_amount[_to].add(1);

        citys[_tokenId].owner = _to;

        emit Transfer(_from, _to, _tokenId);
    }
    
    function _checkOnERC721Received(address _from, address _to, uint256 _tokenId, bytes memory _data)
        internal returns (bool)
    {
        if (!_to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    function _clearApproval(uint256 _tokenId) private {
        if (citys[_tokenId].approvals != address(0)) {
            citys[_tokenId].approvals = address(0);
        }
    }


}
