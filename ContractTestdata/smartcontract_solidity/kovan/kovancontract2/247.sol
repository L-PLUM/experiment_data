/**
 *Submitted for verification at Etherscan.io on 2019-07-24
*/

pragma solidity ^0.5.10;

contract AbstractContract
{
    struct Client
	{
		uint256 hard_balance_unit_cents;
		uint256 soft_balance_unit_cents;
		
		uint256 position_type; // 0 uint256, 1 short
		uint256 quantity_usd;
		uint256 price_in_usd_cents;
	}
	
    address public master;
	
	uint256 public price_in_usd_cents;
	
	uint256 public contract_unit_cents;
	uint256 public hard_reserved_unit_cents;
	
	mapping (address => Client) public clients;

    function deposit() external payable;
    function withdrawal(uint256 value) external;
	function set_price(uint256 new_price, address[] calldata to_liquidate) external;
	function liquidation(address[] calldata to_liquidate) external;
    function create_order_uint256(uint256 quantity_usd) external;
    function create_order_short(uint256 quantity_usd) external;
}

contract DerivativeService is AbstractContract
{
    uint256 internal constant usd_cents = 100;
    uint256 internal constant unit_cents = 10 ** 18;
  
    constructor() public
    {
        master = msg.sender;
    }
    
    function min(uint256 a, uint256 b) internal pure returns (uint256)
	{
		return a < b? a:b;
	}
	
    function reduce(uint256 base, uint256 value) internal pure returns (uint256)
	{
		if(base >= value) return base - value;
		else return 0;
	}
	
	function calculate_initial_margin(uint256 value) internal pure returns (uint256)
	{
		// initial maintenance margin factor 0.02
        uint256 margin = value*2/100;
        
        uint256 restored_value = margin*100/2;
        if(restored_value < value) margin++;

        return margin;
	}
	
	function calculate_margin(uint256 value) internal pure returns (uint256)
	{
		// maintenance margin factor 0.01
        uint256 margin = value*1/100;
        
        uint256 restored_value = margin*100/1;
        if(restored_value < value) margin++;

        return margin;
	}
    
    function convert_to_unit_cents_by_price(uint256 value_usd_cents, uint256 price_usd_cents) internal pure returns (uint256)
	{
        uint256 value_unit_cents = unit_cents*value_usd_cents/price_usd_cents;
        
        uint256 restored_usd_cents = value_unit_cents*price_usd_cents/unit_cents;
        if(restored_usd_cents < value_usd_cents) value_unit_cents++;
        
        return value_unit_cents;
	}
	
    function get_margin(address target) internal view returns (uint256)
	{
		uint256 quantity_usd_cents = clients[target].quantity_usd*usd_cents;
		if(quantity_usd_cents == 0) return 0;
		
		uint256 quantity_unit_cents = convert_to_unit_cents_by_price(quantity_usd_cents, clients[target].price_in_usd_cents);
		
		return calculate_margin(quantity_unit_cents);
	}
    
    function available(address target) internal view returns (uint256)
    {
		uint256 balance = clients[target].hard_balance_unit_cents + clients[target].soft_balance_unit_cents;
		uint256 margin_unit_cents = get_margin(target);
		
		return reduce(balance, margin_unit_cents);
    }
    
    function deposit() external payable
    {
	    if(msg.sender != master)
	    {
	    	clients[msg.sender].hard_balance_unit_cents += msg.value;
	    	hard_reserved_unit_cents += msg.value;
	    }
    }
    
    function withdrawal(uint256 value) external
    {
        require(available(msg.sender) >= value);
		
		uint256 hard_value = min(clients[msg.sender].hard_balance_unit_cents, value);
		uint256 soft_value = value - hard_value;
		
		uint256 contract_soft_available = address(this).balance - hard_reserved_unit_cents;
		
		require(soft_value <= contract_soft_available);
		
		hard_reserved_unit_cents -= hard_value;
		clients[msg.sender].hard_balance_unit_cents -= hard_value;
		clients[msg.sender].soft_balance_unit_cents -= soft_value;
		
		msg.sender.transfer(value);
    }
    
    function set_price(uint256 new_price, address[] calldata to_liquidate) external
    {
        require(msg.sender == master);
		
		price_in_usd_cents = new_price;
		
	    this.liquidation(to_liquidate);
    }
    
	function liquidation(address[] calldata to_liquidate) external
	{
        for(uint256 i = 0; i < to_liquidate.length; i++)
	    {
	        address target = to_liquidate[i];
	        
	    	if(clients[target].quantity_usd == 0) continue;
	    	
	    	liquidate(target);
	    }
	}
	
	function liquidate(address target) internal
	{
		uint256 quantity_usd_cents = clients[target].quantity_usd*usd_cents;
		uint256 quantity_unit_cents = convert_to_unit_cents_by_price(quantity_usd_cents, clients[target].price_in_usd_cents);
		uint256 margin_unit_cents = calculate_margin(quantity_unit_cents);
		
		uint256 balance_unit_cents = clients[target].hard_balance_unit_cents + clients[target].soft_balance_unit_cents;
		uint256 available_unit_cents = balance_unit_cents - margin_unit_cents;
		
		if(clients[target].position_type == 0)
		{
			uint256 base_liquidation_price = clients[target].price_in_usd_cents*quantity_unit_cents/(quantity_unit_cents + available_unit_cents);
			uint256 liquidation_price = base_liquidation_price + calculate_margin(clients[target].price_in_usd_cents);
			
			if(price_in_usd_cents < liquidation_price) reduce_position(target, clients[target].quantity_usd, 1, 1);
		}else{
			uint256 base_liquidation_price = clients[target].price_in_usd_cents*quantity_unit_cents/(quantity_unit_cents - available_unit_cents);
			uint256 liquidation_price = base_liquidation_price - calculate_margin(clients[target].price_in_usd_cents);
			
			if(price_in_usd_cents > liquidation_price) reduce_position(target, clients[target].quantity_usd, 0, 1);
		}
	}
	
	function calculate_fee(uint256 value) internal pure returns (uint256)
	{
		// fee is 0.075% of value
		// fee = 0.00075*value
		
        uint256 fee = 75*value/100000;
        
        uint256 restored_value = 100000*fee/75;
        if(restored_value < value) fee++;

        return fee;
	}
	
	function calculate_fee_for_usd(uint256 quantity_usd, uint256 price_in_usd_cents) internal pure returns (uint256)
	{
		uint256 quantity_usd_cents = quantity_usd*usd_cents;
		uint256 quantity_unit_cents = convert_to_unit_cents_by_price(quantity_usd_cents, price_in_usd_cents);
        
		uint256 fee_unit_cents = calculate_fee(quantity_unit_cents);
		
		return fee_unit_cents;
	}
	
	function extend_position(address target, uint256 quantity_usd, uint256 position_type) internal
	{
		uint256 mem_hard_balance_unit_cents = clients[target].hard_balance_unit_cents;
		uint256 mem_soft_balance_unit_cents = clients[target].soft_balance_unit_cents;
		uint256 mem_quantity_usd = clients[target].quantity_usd;
		uint256 mem_price_in_usd_cents = clients[target].price_in_usd_cents;
		
		uint256 balance_unit_cents = mem_hard_balance_unit_cents + mem_soft_balance_unit_cents;
		uint256 new_quantity_usd = mem_quantity_usd + quantity_usd;
	    
		uint256 new_price_in_usd_cents = (mem_quantity_usd*mem_price_in_usd_cents + quantity_usd*price_in_usd_cents)/new_quantity_usd;
		
		uint256 initial_margin_unit_cents = calculate_initial_margin(convert_to_unit_cents_by_price(new_quantity_usd*usd_cents, new_price_in_usd_cents));
		
		require(initial_margin_unit_cents <= balance_unit_cents);
		
		uint256 fee_unit_cents = calculate_fee_for_usd(quantity_usd, price_in_usd_cents);
		
		require(fee_unit_cents <= balance_unit_cents);
		
		uint256 soft_fee = min(mem_soft_balance_unit_cents, fee_unit_cents);
		mem_soft_balance_unit_cents -= soft_fee;
		mem_hard_balance_unit_cents -= fee_unit_cents - soft_fee;
		
		if(clients[target].hard_balance_unit_cents != mem_hard_balance_unit_cents) clients[target].hard_balance_unit_cents = mem_hard_balance_unit_cents;
		if(clients[target].soft_balance_unit_cents != mem_soft_balance_unit_cents) clients[target].soft_balance_unit_cents = mem_soft_balance_unit_cents;
		
		if(clients[target].position_type != position_type) clients[target].position_type = position_type;
		if(clients[target].quantity_usd != new_quantity_usd) clients[target].quantity_usd = new_quantity_usd;
		if(clients[target].price_in_usd_cents != new_price_in_usd_cents) clients[target].price_in_usd_cents = new_price_in_usd_cents;
		
		hard_reserved_unit_cents += soft_fee; // -hard_fee from client, +fee for system = soft_fee
		clients[master].hard_balance_unit_cents += fee_unit_cents;
	}
	
	function reduce_position(address target, uint256 quantity_usd, uint256 position_type, uint256 force) internal
	{
		uint256 mem_hard_balance_unit_cents = clients[target].hard_balance_unit_cents;
		uint256 mem_soft_balance_unit_cents = clients[target].soft_balance_unit_cents;
		uint256 mem_type = clients[target].position_type;
		uint256 mem_quantity_usd = clients[target].quantity_usd;
		uint256 mem_price_in_usd_cents = clients[target].price_in_usd_cents;
		
		uint256 delta_usd = min(quantity_usd, mem_quantity_usd);
		
		uint256 lose;
		if(position_type == 0)
		{
		    mem_soft_balance_unit_cents += convert_to_unit_cents_by_price(delta_usd*usd_cents, price_in_usd_cents);
		    lose = convert_to_unit_cents_by_price(delta_usd*usd_cents, clients[target].price_in_usd_cents);
		}else{
		    mem_soft_balance_unit_cents += convert_to_unit_cents_by_price(delta_usd*usd_cents, clients[target].price_in_usd_cents);
		    lose = convert_to_unit_cents_by_price(delta_usd*usd_cents, price_in_usd_cents);
		}

		mem_soft_balance_unit_cents -= min(lose, mem_soft_balance_unit_cents);
		mem_hard_balance_unit_cents = reduce(mem_hard_balance_unit_cents, lose - min(lose, mem_soft_balance_unit_cents));
		
		delta_usd = quantity_usd - delta_usd;
		if(delta_usd > 0)
		{
			require(calculate_initial_margin(convert_to_unit_cents_by_price(delta_usd*usd_cents, price_in_usd_cents)) <= (mem_soft_balance_unit_cents + mem_hard_balance_unit_cents));

			mem_type = position_type;
			mem_quantity_usd = delta_usd;
			mem_price_in_usd_cents = price_in_usd_cents;
		}else mem_quantity_usd = mem_quantity_usd - quantity_usd;
		
		uint256 fee_unit_cents = calculate_fee_for_usd(quantity_usd, price_in_usd_cents);
		
		require(force == 1 || fee_unit_cents <= (mem_soft_balance_unit_cents + mem_hard_balance_unit_cents));

		fee_unit_cents = min(fee_unit_cents, mem_soft_balance_unit_cents + mem_hard_balance_unit_cents);
		uint256 soft_fee = min(mem_soft_balance_unit_cents, fee_unit_cents);
		mem_soft_balance_unit_cents -= soft_fee;
		mem_hard_balance_unit_cents -= fee_unit_cents - soft_fee;
		
		if(mem_hard_balance_unit_cents < clients[target].hard_balance_unit_cents) hard_reserved_unit_cents -= clients[target].hard_balance_unit_cents - mem_hard_balance_unit_cents;
		
		if(clients[target].soft_balance_unit_cents != mem_soft_balance_unit_cents) clients[target].soft_balance_unit_cents = mem_soft_balance_unit_cents;
		if(clients[target].hard_balance_unit_cents != mem_hard_balance_unit_cents) clients[target].hard_balance_unit_cents = mem_hard_balance_unit_cents;
		
		if(clients[target].quantity_usd != mem_quantity_usd) clients[target].quantity_usd = mem_quantity_usd;
		if(mem_quantity_usd > 0)
		{
			if(clients[target].position_type != mem_type) clients[target].position_type = mem_type;
			if(clients[target].price_in_usd_cents != mem_price_in_usd_cents) clients[target].price_in_usd_cents = mem_price_in_usd_cents;
		}
		
		hard_reserved_unit_cents += fee_unit_cents - soft_fee;
		clients[master].hard_balance_unit_cents += fee_unit_cents - soft_fee;
		clients[master].soft_balance_unit_cents += soft_fee;
	}
	
	function open_position(address target, uint256 quantity_usd, uint256 position_type) internal
	{
		require(quantity_usd > 0);
	    
		if(clients[target].position_type == position_type || clients[target].quantity_usd == 0) extend_position(target, quantity_usd, position_type);
		else reduce_position(target, quantity_usd, position_type, 0);
	}
    
    function create_order_uint256(uint256 quantity_usd) public
    {
        open_position(msg.sender, quantity_usd, 0);
    }
    
    function create_order_short(uint256 quantity_usd) public
    {
        open_position(msg.sender, quantity_usd, 1);
    }
}
