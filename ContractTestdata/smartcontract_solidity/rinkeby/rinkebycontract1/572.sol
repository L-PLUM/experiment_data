/**
 *Submitted for verification at Etherscan.io on 2019-02-12
*/

pragma solidity ^0.4.22;

contract FishSupplyChain {
    
    struct Fish {
        uint quantity; 
        string type_of_fish;
        string fish_grade;
        string general_catch_location;
        bytes32 exact_catch_location_encrypted;
        uint container;
        address fisher;
    }
    
    struct FishContainer {
        uint[] fish_ids_in_container;
        address owner;
    }
    
    uint id_counter = 0;
    
    mapping(uint => Fish) private tracked_fish;
    mapping(uint => FishContainer) private tracked_containers;
    mapping(address => uint[]) private tracked_fishermen;
    
    
    /*
        Create: below contains methods to create fish catches and new containers of fish catches. 
    */ 
    
    event LogFishCatchCreated(uint new_id, uint quantity, string type_of_fish, string fish_grade, string general_catch_location, bytes32 exact_catch_location_encrypted, address fisher);
    event LogContainerCreated(uint new_id, address fisher);
        
    function create_fish_catch(uint quantity, string type_of_fish, string fish_grade, string general_catch_location, bytes32 exact_catch_location_encrypted) public returns(uint id) {
        require(quantity > 0);
        uint new_id = generate_new_id();
        tracked_fish[new_id] = Fish(quantity, type_of_fish, fish_grade, general_catch_location, exact_catch_location_encrypted, 0, msg.sender);
        emit LogFishCatchCreated(new_id, quantity, type_of_fish, fish_grade, general_catch_location, exact_catch_location_encrypted, msg.sender);
        
        uint[] catches_by_fisherman = tracked_fishermen[msg.sender];
        catches_by_fisherman.push(new_id);
        tracked_fishermen[msg.sender] = catches_by_fisherman;
        
        return new_id;
    }
    
    function create_container() public returns(uint id) {
        uint new_id = generate_new_id();
        tracked_containers[new_id] = FishContainer({fish_ids_in_container: new uint[](0), owner: msg.sender});
        emit LogContainerCreated(new_id,msg.sender);
        return new_id;
    }
    
    /*
        Retrieve: Below contains methods to retrieve fish catches and containers of fish catches. 
    */ 
    
    function retrieve_fish_catch(uint id) view public returns (uint quantity, string type_of_fish, string fish_grade, string general_catch_location, bytes32 exact_catch_location_encrypted, uint container){
        Fish fish = tracked_fish[id];
        require(fish.quantity != 0);
        return (fish.quantity, fish.type_of_fish, fish.fish_grade, fish.general_catch_location, fish.exact_catch_location_encrypted, fish.container);
    }
    
    function retrieve_container(uint id) view public returns (uint[] fish_ids_in_container, address owner){
        FishContainer container = tracked_containers[id];
        require(container.owner != address(0));
        return (container.fish_ids_in_container, container.owner);
    }
    
    event LogFisherRecord(address indexed fisherman, uint fish_id);
    
    function retrieve_fish_catch_ids_by_fisherman(address fisherman) public {
        
        uint arrayLength = tracked_fishermen[fisherman].length;
        
        for (uint i=0; i<arrayLength; i++) {
            emit LogFisherRecord(fisherman, tracked_fishermen[fisherman][i]);
        }
        
    }
    
    /*
        Update: Below contains methods to update fish catches and containers of fish catches. 
    */ 
    
    function extract_fish_from_catch(uint id, uint quantity_to_extract) public returns (uint new_id){
        Fish fish = tracked_fish[id];
        require(fish.quantity != 0);
        require(quantity_to_extract < fish.quantity);
        fish.quantity = fish.quantity - quantity_to_extract;
        tracked_fish[id] = fish;
        
        new_id = create_fish_catch(quantity_to_extract, fish.type_of_fish, fish.fish_grade, fish.general_catch_location, fish.exact_catch_location_encrypted);
    
        if(fish.container != 0){
            add_fish_to_container(new_id, fish.container);
        }
        
        return new_id;
    }
    
    function change_ownership_of_container(uint id, address new_owner) public {
        FishContainer container = tracked_containers[id];
        require(container.owner != address(0));
        require(container.owner == msg.sender);
        container.owner = new_owner;
        tracked_containers[id] = container;
    }
    
    function add_fish_to_container(uint fish_id, uint container_id) public returns (bool success){
        
        Fish fish = tracked_fish[fish_id];
        require(fish.quantity != 0);
        require(fish.container == 0);
    
        FishContainer container = tracked_containers[container_id];
        require(container.owner != address(0));
        
        fish.container = container_id;
        tracked_fish[fish_id] = fish;
        
        container.fish_ids_in_container.push(fish_id);
        tracked_containers[container_id] = container;
        
        return true; 
    }
    
    function remove_fish_from_container(uint fish_id, uint container_id) public returns (bool success){
        Fish fish = tracked_fish[fish_id];
        require(fish.quantity != 0);
        require(fish.container == container_id);
        
        FishContainer container = tracked_containers[container_id];
        require(container.owner != address(0));
        require(container.owner == msg.sender);
        
        fish.container = 0;
        
        uint arrayLength = container.fish_ids_in_container.length;
        
        for (uint i=0; i<arrayLength; i++) {
            if(container.fish_ids_in_container[i] == fish_id){
               container.fish_ids_in_container[i] = container.fish_ids_in_container[arrayLength - 1];
               container.fish_ids_in_container.length = arrayLength - 1;
               return true;
            }
        }
        
        return false; 
    }
    
    function change_container(uint fish_id, uint old_container_id, uint new_container_id) public returns (bool success){
        require(remove_fish_from_container(fish_id, old_container_id));
        require(add_fish_to_container(fish_id, new_container_id));
        return true; 
    }
    
    
    /*
        The below provides a simple utility method to create a new IDs. 
    */
    
    function generate_new_id() public returns (uint id){
        id_counter = id_counter + 1;
        return id_counter;
    }
    
    /*
        The below methods are for encrypting and paying to decrypt data. 
    */

    event LogAmountPaid(address indexed sender, uint amountPaid, uint fish_id);
        
    function hashSecret(string secret) view public returns(bytes32 hashed){
      return keccak256(abi.encodePacked(secret));
    }
    
    
    function retrieve_data(uint container_id) public returns (bool success){
        FishContainer container = tracked_containers[container_id];
        require(container.owner != address(0));
        
        uint number_to_pay = container.fish_ids_in_container.length;
        
        uint leftover = msg.value % number_to_pay;
        uint split_amount = (msg.value - leftover) / number_to_pay;
        
        for (uint i=0; i<number_to_pay; i++) {
            Fish fish = tracked_fish[container.fish_ids_in_container[i]];
            fish.fisher.transfer(split_amount);
            LogAmountPaid(msg.sender, split_amount, container.fish_ids_in_container[i]);
        }

        
    }
}
