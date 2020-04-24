/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^0.4.25;

//2019.02.21
//master 3.0.0測試版


contract owned {

    address public manager;

    constructor() public{
        manager = msg.sender;
    }
 
    modifier onlymanager{
        require(msg.sender == manager);
        _;
    }

    function transferownership(address _new_manager) public onlymanager {
        manager = _new_manager;
    }
}

///ERC20 interface
interface ERC20_interface {
  function decimals() external view returns(uint8);
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  
  function transfer(address to, uint256 value) external returns(bool);
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) ;
}

///ERC721 interface
interface ERC721_interface{
     function balanceOf(address _owner) external view returns (uint256);
     function ownerOf(uint256 _tokenId) external view returns (address);
     function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;
     function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
     function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
     function approve(address _approved, uint256 _tokenId) external payable;
     function setApprovalForAll(address _operator, bool _approved) external;
     function getApproved(uint256 _tokenId) external view returns (address);
     function isApprovedForAll(address _owner, address _operator) external view returns (bool);
 } 
 
 ///slave interface
 interface slave{
    function transferMastership(address new_master) external ;
    function city_number() external view returns(uint16);
    
    function inquire_totdomains_amount() external view returns(uint16);
    function inquire_domain_level(uint16 _id) external view returns(uint8);
    function inquire_domain_star(uint16 _id) external view returns(uint8);
    function inquire_domain_level_star(uint16 _id) external view returns(uint8, uint8);
    function inquire_domain_building(uint16 _id, uint8 _index) external view returns(uint8);
    function inquire_domain_cooltime(uint16 _id) external view returns(uint);
    function inquire_tot_domain_building(uint16 _id) external view returns(uint8[]);
    function inquire_own_domain(address _sender) external view returns(uint16[]);
    
    function domain_build(uint16 _id, uint8 _building) external;
    function reconstruction(uint16 _id, uint8 _index, uint8 _building)external;
    
    function domain_reward(address _user, uint16 _id) external;
    function transfer_master(address _to, uint16 _id) external;
    function retrieve_domain(address _user, uint _id) external;
    function at_Area() external view returns(string);
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
 
 contract master is owned {
    using SafeMath for uint;
    using SafeMath16 for uint16;
     
    uint random_seed;
     
    mapping (uint8 => string) public building_type;  //建築物類型
    mapping (uint8 => uint) public building_price; //建造建築物的價格

     constructor() public{
        random_seed = uint((keccak256(abi.encodePacked(now))));
                
        //建築物名稱
        building_type[0] = "null" ; //空地
        building_type[1] = "Farm" ; //農場
        building_type[2] = "Mine" ; //礦場
        building_type[3] = "Workshop" ; //工坊
        building_type[4] = "Bazaar" ; //市場
        building_type[5] = "Arena" ;//競技場
        building_type[6] = "Adventurer's Guild" ; //冒險者公會
        building_type[7] = "Dungeon" ; //地下城
        building_type[8] = "Lucky Fountain" ; //幸運池
        building_type[9] = "Stable" ; //馬廄
        building_type[10] = "Mega Tower" ; //魔法塔

        //建築物價格
        building_price[0] = 0 ; 
        building_price[1] = 2000*10**8 ;
        building_price[2] = 2000*10**8 ;
        building_price[3] = 2000*10**8 ; 
        building_price[4] = 2000*10**8 ; 
        building_price[5] = 5000*10**8 ;
        building_price[6] = 5000*10**8 ;
        building_price[7] = 5000*10**8 ;
        building_price[8] = 5000*10**8 ;
        building_price[9] = 5000*10**8 ;
        building_price[10] = 5000*10**8 ; 
     }
     
     mapping(uint16 => address) public owner_slave; //擁有的土地合約地址(編號 => 地址)
     
     address arina_contract = 0x2b09049cd57980778200eF4e35BF82bA7c57b36E;
     address GIC_contract = 0x3Cba97A4095dadaEe630F025A0Bc7b4395B53eb6;
     
     
     uint16 public owner_slave_amount = 0; //擁有土地合約地址的數量
     
     
    function payRoadETH_amount(uint8 _level, uint8 _star) public pure returns(uint){
         
        if(_level <= 1){
    	   return  0.02 ether * 2**(uint(_star)-1) ;
    	} 
    	else if(_level > 1) {    
    	   return  0.02 ether * 2**(uint(_star)-1)*(3**(uint(_level)-1))/(2**(uint(_level)-1)) ;
    	} 
    }
     
    function buyLandETH_amount(uint8 _level, uint8 _star) public pure returns(uint){

         
        if(_level <= 1){
    	   return  0.2 ether * 2**(uint(_star)-1) ;
    	} 
    	else if(_level > 1) {    
    	   return  0.2 ether * 2**(uint(_star)-1)*(3**(uint(_level)-1))/(2**(uint(_level)-1)) ;
    	} 
    }
     
    function payARINA_amount(uint8 _level, uint8 _star) public pure returns(uint){

        
        if(_level <= 1){
    	return (10**8) * (2**(uint(_star)-1)*10);
    	} 
    	
    	else if(_level > 1) {   
    	return (10**8) * (2**(uint(_star)-1)*10)*(3**(uint(_level)-1))/(2**(uint(_level)-1));
    	}

    }
     
    function buyLandARINA_amount() public pure returns(uint){
        return 2000*10**8;
    }
     
    
     
    struct _info{
        uint16 city; //哪個區域
        uint16 domain; //區域內的id
        bool unmovable; //是否 "不可" 移動
        bool lotto; //可不可以抽樂透
        bool build; //可不可以建築
    }
     
    mapping(address => _info) public player_info;  //使用者當前資訊
     
    event RollDice(address indexed player, uint16 city, uint16 id, bool unmovable); 
    event PlayLotto(address indexed player,uint player_number, uint lotto_number);
    event PayArina(address indexed player, uint value);
    event BuyArina(address indexed player, uint value);
    event PayEth(address indexed player, uint value);
    event BuyEth(address indexed player, uint value);
    event Build(address indexed player, uint8 building);
    event Reconstruction(address indexed player, uint8 building);
     
    uint public probability = 20;
    bool public all_stop = false;
    
////manage function

    function set_all_stop(bool _stop) public onlymanager{
        all_stop = _stop;
    }

    function withdraw() public onlymanager{
        manager.transfer(address(this).balance);
    }

    function set_slave_master(uint16 _index, address new_address) public onlymanager{
        address contract_address = owner_slave[_index];
        slave(contract_address).transferMastership(new_address);
    }
     
    function set_slave_address(uint16 _index, address _address) external onlymanager{
        require(_index == slave(_address).city_number());
        if(owner_slave[_index] == 0x0){
            owner_slave[_index] = _address;
            owner_slave_amount = owner_slave_amount.add(1);
        }
        else{
            owner_slave[_index] = _address; 
        }
    }
    
    function set_building_type(uint8 _type, string _name) public onlymanager{
        building_type[_type] = _name;
    }
    
    function set_type_price(uint8 _type, uint _price) public onlymanager{
        building_price[_type] = _price;
    }
    
    function fly(uint16 _city, uint16 _domain) public{
        
        require(owner_slave_amount >= 1);
        require(!player_info[msg.sender].unmovable);
        
        player_info[msg.sender].city = _city;
        player_info[msg.sender].domain = _domain;
        
        address city_address = owner_slave[_city];
        address domain_owner = ERC721_interface(city_address).ownerOf(_domain);
        
        if (domain_owner != 0x0){
            if(domain_owner == msg.sender){
                player_info[msg.sender].build = true; //踩到自己的地後可以建築
                //如果領地擁有者是自己則可以繼續移動
            }
            else{
                player_info[msg.sender].unmovable = true; //如果領地有人則不可移動
            }
		}
        
        emit RollDice(msg.sender, _city, _domain , player_info[msg.sender].unmovable);
    }//測試用function
    
////inquire function

    function inquire_owner(uint16 _city, uint16 _domain) public view returns(address){
        address city_address = owner_slave[_city];
        return ERC721_interface(city_address).ownerOf(_domain);
    }
    
    function inquire_have_owner(uint16 _city, uint16 _domain) public view returns(bool){
        address city_address = owner_slave[_city];
        address domain_owner = ERC721_interface(city_address).ownerOf(_domain);
        if(domain_owner == 0x0){
        return false;
        }
        else{return true;}
    }
    
    function inquire_level(uint16 _city, uint16 _domain) public view returns(uint8){
        address city_address = owner_slave[_city];
        return slave(city_address).inquire_domain_level(_domain);
    }
    
    function inquire_domain_star(uint16 _city, uint16 _domain) public view 
    returns(uint8){
        address _address = inquire_slave_address(_city);
        return slave(_address).inquire_domain_star(_domain);
    }
    
    function inquire_domain_level_star(uint16 _city, uint16 _domain) public view 
    returns(uint8, uint8){
        address _address = inquire_slave_address(_city);
        return slave(_address).inquire_domain_level_star(_domain);
    }
    
    function inquire_slave_address(uint16 _slave) public view returns(address){
        return owner_slave[_slave];
    }
    
    function inquire_slave_name(uint16 _slave) public view returns(string){
        address _address = owner_slave[_slave];
        return slave(_address).at_Area();
    }
    
    function inquire_city_totdomains(uint16 _index) public view returns(uint16){
        address _address = inquire_slave_address(_index);
        return  slave(_address).inquire_totdomains_amount();
    }
    
    function inquire_location(address _address) public view returns(uint16, uint16){
        return (player_info[_address].city, player_info[_address].domain);
    }
    
    function inquire_status(address _address) public view returns(bool, bool){
        return (player_info[_address].unmovable, player_info[_address].lotto);
    }
    
    function inquire_type(uint8 _typeid) public view returns(string){
        return building_type[_typeid];
    }
    
    function inquire_type_price(uint8 _typeid) public view returns(uint){
        return building_price[_typeid];
    }
    
    function inquire_building(uint16 _slave, uint16 _domain, uint8 _index)
    public view returns(uint8){
        address _address = inquire_slave_address(_slave);
        return slave(_address).inquire_domain_building(_domain, _index);
    }
    
    function inquire_cooltime(uint16 _slave, uint16 _domain)
    public view returns(uint){
        address _address = inquire_slave_address(_slave);
        return slave(_address).inquire_domain_cooltime(_domain);
    }
    
    function inquire_tot_building(uint16 _slave, uint16 _domain)
    public view returns(uint8[]){
        address _address = inquire_slave_address(_slave);
        return slave(_address).inquire_tot_domain_building(_domain);
    }
    
    function inquire_own_domain(uint16 _city) public view returns(uint16[]){
 
        address _address = inquire_slave_address(_city);
        return slave(_address).inquire_own_domain(msg.sender);
    }
    
    
    
    function inquire_GIClevel(address _address) view public returns(uint8 _level){
        uint GIC_balance = ERC20_interface(GIC_contract).balanceOf(_address);
        if (GIC_balance <= 1000*10**18){
            return 1;
        }
        else if(1000*10**18 < GIC_balance && GIC_balance <=10000*10**18){
            return 2;
        }
        else if(10000*10**18 < GIC_balance && GIC_balance <=100000*10**18){
            return 3;
        }
        else if(100000*10**18 < GIC_balance && GIC_balance <=500000*10**18){
            return 4;
        }
        else if(500000*10**18 < GIC_balance){
            return 5;
        }
        else revert();
    }
    
     
////game function

    function() public payable{}
    
    function rollDice() external{
        require(!all_stop);
        require(owner_slave_amount >= 1);
        require(!player_info[msg.sender].unmovable,"不可移動");
        uint16 random = uint16((keccak256(abi.encodePacked(now, random_seed))));
        random_seed.add(1);
        
        uint16 go_city = (random % owner_slave_amount).add(1); 
        
        uint16 tot_domains = inquire_city_totdomains(go_city);
        uint16 go_domains_id = random % tot_domains; 
        
        player_info[msg.sender].city = go_city;
        player_info[msg.sender].domain = go_domains_id;
        
        address city_address = owner_slave[go_city];
        address domain_owner = ERC721_interface(city_address).ownerOf(go_domains_id);
        
        if (domain_owner != 0x0){
            if(domain_owner == msg.sender){
                player_info[msg.sender].build = true; //踩到自己的地後可以建築
                //如果領地擁有者是自己則可以繼續移動
            }
            else{
                player_info[msg.sender].unmovable = true; //如果領地有人則不可移動
            }
		}
        
        emit RollDice(msg.sender, go_city, go_domains_id, player_info[msg.sender].unmovable);
    }
    
    function playLotto() public{
        require(!all_stop);
        require(player_info[msg.sender].lotto);
        
        uint random = uint((keccak256(abi.encodePacked(now, random_seed))));
        uint random2 = uint((keccak256(abi.encodePacked(random_seed, msg.sender))));
        random_seed = random_seed.add(1);
        
        uint lotto_number = random % probability;
        uint player_number =  random2 % probability;
        
        if(lotto_number == player_number){
            msg.sender.transfer(address(this).balance);
        }
        
        player_info[msg.sender].lotto = false;
        
        //玩樂透，在用以太支付過路費後才能執行
        emit PlayLotto(msg.sender, player_number, lotto_number);
    }

     
////pay and buy function

    function payRent_ETH() external payable{
        require(!all_stop);
        require(player_info[msg.sender].unmovable,"檢查不可移動");
        
        uint16 city = player_info[msg.sender].city; //所在土地編號
        uint16 domains_id = player_info[msg.sender].domain;  //所在土地id
        
        address city_address = owner_slave[city];
		address domain_owner = ERC721_interface(city_address).ownerOf(domains_id);
		
		if (domain_owner == 0x0){
		    revert("不用付手續費");
		}
        
        uint8 _level = slave(city_address).inquire_domain_level(domains_id);
        uint8 _star = slave(city_address).inquire_domain_star(domains_id);
        
        uint _payRoadETH_amount = payRoadETH_amount(_level, _star);
        
        require(msg.value == _payRoadETH_amount);
        
        player_info[msg.sender].unmovable = false;

        uint payRent_ETH_50toOwner = msg.value.div(10).mul(5);
		uint payRent_ETH_10toTeam = msg.value.div(10);
		uint payRent_ETH_20toCity = msg.value.div(10).mul(2); 
		uint payRent_ETH_20toPool = msg.value.div(10).mul(2);
		uint pay = payRent_ETH_50toOwner + payRent_ETH_10toTeam + payRent_ETH_20toCity + payRent_ETH_20toPool;
		require(msg.value == pay);

		domain_owner.transfer(payRent_ETH_50toOwner); //原土地擁有者
        manager.transfer(payRent_ETH_10toTeam); //master contract owner
        city_address.transfer(payRent_ETH_20toCity); //注意slave合約要能接收
        //給pool的直接放在合約
        
        player_info[msg.sender].lotto = true;
        emit PayEth(msg.sender, msg.value);
    }
    
    function buyLand_ETH() external payable{
        require(!all_stop);
        require(player_info[msg.sender].unmovable,"檢查不可移動");
        
        uint16 city = player_info[msg.sender].city;
        uint16 domains_id = player_info[msg.sender].domain;
        
        address city_address = owner_slave[city];
        address domain_owner = ERC721_interface(city_address).ownerOf(domains_id);
        
        uint8 _level = slave(city_address).inquire_domain_level(domains_id);
        uint8 _star = slave(city_address).inquire_domain_star(domains_id);
        
        uint _buyLandETH_amount = buyLandETH_amount(_level, _star);
        require(msg.value == _buyLandETH_amount); //用ETH購買土地
        
        if(domain_owner == 0x0){
            revert("第一次請用Arina購買");
        }
        
        uint BuyLand_ETH_50toOwner;
        uint BuyLand_ETH_10toTeam;
        uint BuyLand_ETH_20toCity; 
        uint BuyLand_ETH_20toPool;
        uint pay;
        
        if(_level <= 1){
            BuyLand_ETH_50toOwner = msg.value.div(10).mul(5);
        	BuyLand_ETH_10toTeam = msg.value.div(10);
        	BuyLand_ETH_20toCity = msg.value.div(10).mul(2); 
        	BuyLand_ETH_20toPool = msg.value.div(10).mul(2);
        	pay = BuyLand_ETH_50toOwner + BuyLand_ETH_10toTeam + BuyLand_ETH_20toCity +BuyLand_ETH_20toPool;
        	require(msg.value == pay);
        		
        	domain_owner.transfer(BuyLand_ETH_50toOwner); //原土地擁有者
            manager.transfer(BuyLand_ETH_10toTeam); //master contract owner
            city_address.transfer(BuyLand_ETH_20toCity); //注意slave合約要能接收
            //給pool的直接放在合約
        }
        else{
            BuyLand_ETH_50toOwner = msg.value.div(10).mul(8);
        	BuyLand_ETH_10toTeam = msg.value.div(20);
        	BuyLand_ETH_20toCity = msg.value.div(20);
        	BuyLand_ETH_20toPool = msg.value.div(10);
        	pay = BuyLand_ETH_50toOwner + BuyLand_ETH_10toTeam + BuyLand_ETH_20toCity +BuyLand_ETH_20toPool;
        	require(msg.value == pay);
        		
        	domain_owner.transfer(BuyLand_ETH_50toOwner); //原土地擁有者
            manager.transfer(BuyLand_ETH_10toTeam); //master contract owner
            city_address.transfer(BuyLand_ETH_20toCity); //注意slave合約要能接收
            //給pool的直接放在合約
        }
        
        slave(city_address).transfer_master(msg.sender, domains_id); //土地轉移
        //_to, _id
        player_info[msg.sender].unmovable = false;
        player_info[msg.sender].lotto = true;
        
        emit BuyEth(msg.sender, msg.value);
    }
     
    function _payRent_ARINA(address _sender, uint _value) private{
        require(!all_stop);
        //已經檢查支付金額
        require(player_info[_sender].unmovable,"檢查不可移動");
        
        uint16 city = player_info[_sender].city;
        uint16 domains_id = player_info[_sender].domain;
        
        address city_address = owner_slave[city];
		address domain_owner = ERC721_interface(city_address).ownerOf(domains_id);
		
		if(domain_owner == 0x0){
            revert("空地不用付手續費");
        }

        uint8 level = slave(city_address).inquire_domain_level(domains_id);
        uint8 _star = slave(city_address).inquire_domain_star(domains_id);
        
        uint _payARINA_amount = payARINA_amount(level, _star);
        
    	require(_value == _payARINA_amount,"金額不對");
        ERC20_interface arina = ERC20_interface(arina_contract);
        require(arina.transferFrom(_sender, domain_owner, _value),"交易失敗"); //把錢給原擁有者

        player_info[_sender].unmovable = false;
        
        //用ARINA付過路費
        emit PayArina(_sender, _value);
    }

    function _buyLand_ARINA(address _sender, uint _value) private{ //用ARINA購買土地
        //已經檢查支付金額
        //空地才能執行
        require(!all_stop);
        uint16 city = player_info[_sender].city;
        uint16 domains_id = player_info[_sender].domain;
        
        address city_address = owner_slave[city];
		address domain_owner = ERC721_interface(city_address).ownerOf(domains_id);
        
        if(domain_owner != 0x0){
            revert("空地才能用Arina買");
        }
        
        uint _buyLandARINA_amount = buyLandARINA_amount();
        
        require(_value ==  _buyLandARINA_amount,"金額不對");
        ERC20_interface arina = ERC20_interface(arina_contract);
        require(arina.transferFrom(_sender, city_address, _value)); //把Arina給slave
        
        slave(city_address).transfer_master(_sender, domains_id); //土地轉移
        //_to, _id
        player_info[_sender].unmovable = false;
        emit BuyArina(_sender, _value);
    }
    
    function _build(address _sender, uint8 _building) private {
        require(!all_stop);
        require(player_info[_sender].build == true,"不能建設");
        uint16 city = player_info[_sender].city;
        uint16 domains_id = player_info[_sender].domain;
        
        address city_address = owner_slave[city];
		address domain_owner = ERC721_interface(city_address).ownerOf(domains_id);
		require(_sender == domain_owner,"擁有者不是自己");
		
		slave(city_address).domain_build(domains_id, _building);
		player_info[_sender].build = false;
		
		emit Build(_sender, _building);
    }
    
    function reconstruction(uint8 _index, uint8 _building)public payable{
        uint16 city = player_info[msg.sender].city;
        uint16 domains_id = player_info[msg.sender].domain;
        
        address city_address = owner_slave[city];
		address domain_owner = ERC721_interface(city_address).ownerOf(domains_id);
		require(msg.sender == domain_owner, "限定擁有者");
        
        uint arina_price = inquire_type_price(_building);
        uint eth_price = arina_price.mul(10**6); //換算成eth
        // *(10**10)/10000
        require(msg.value == eth_price,"價格不對");
        
        slave(city_address).reconstruction(domains_id, _index, _building);
        player_info[msg.sender].lotto = true;
        emit Reconstruction(msg.sender, _building);
    }
    
    function reward(uint16 _city, uint16 _domains_id) public{
        require(!all_stop);
        address city_address = owner_slave[_city];
        slave(city_address).domain_reward(msg.sender, _domains_id);
    }


////callback function
    
    function receiveApproval(address _sender, uint256 _value,
    address _tokenContract, bytes _extraData) public{
        
      require(_tokenContract == arina_contract);

      uint256 payloadSize;
      uint256 payload;
      assembly {
        payloadSize := mload(_extraData)
        payload := mload(add(_extraData, 0x20))
      }
      payload = payload >> 8*(32 - payloadSize);

      if (payload == 0){
          
          _payRent_ARINA(_sender, _value);
      }
      
      else if(payload == 1){
          
          _buyLand_ARINA(_sender, _value);
      }
      
      else if(payload >= 2){ //
        
        
        uint8 _building = uint8(payload-2);
          
        uint build_value = inquire_type_price(_building);
		
		require(_value == build_value,"金額不對");
        ERC20_interface arina = ERC20_interface(arina_contract);
        require(arina.transferFrom(_sender, manager, _value),"交易失敗");
          
        _build(_sender, _building);
      }

    }
    
 }
