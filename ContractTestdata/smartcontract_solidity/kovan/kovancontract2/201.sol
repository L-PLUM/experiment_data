/**
 *Submitted for verification at Etherscan.io on 2019-07-26
*/

pragma solidity ^0.5.10;

contract Derivatives
{
    struct Client
	{
		uint256 hard_balance_unit_cents;
		uint256 soft_balance_unit_cents;
		
		uint256 position_type; // 0 long, 1 short
		uint256 quantity_usd;
		uint256 price_in_usd_cents;
	}
	
    address public master;
    address public service;
	uint256 public price_in_usd_cents;
	uint256 public hard_reserved_unit_cents;
	mapping (address => Client) public clients;

    function deposit() external payable;
    function withdrawal(uint256 value) external;
	function set_price(uint256 new_price) external;
	function set_price_and_liquidation(uint256 new_price, address[] calldata to_liquidate) external;
	function liquidation(address[] calldata to_liquidate) external;
    function create_order_long(uint256 quantity_usd) external;
    function create_order_short(uint256 quantity_usd) external;
}

contract DerivativeService is Derivatives
{
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
		uint256 quantity_usd_cents = quantity_usd*100;
		uint256 quantity_unit_cents = convert_to_unit_cents_by_price(quantity_usd_cents, price_in_usd_cents);
        
		uint256 fee_unit_cents = calculate_fee(quantity_unit_cents);
		
		return fee_unit_cents;
	}
    
    function convert_to_unit_cents_by_price(uint256 value_usd_cents, uint256 price_usd_cents) internal pure returns (uint256)
	{
        uint256 value_unit_cents = (10 ** 18)*value_usd_cents/price_usd_cents;
        
        uint256 restored_usd_cents = value_unit_cents*price_usd_cents/(10 ** 18);
        if(restored_usd_cents < value_usd_cents) value_unit_cents++;
        
        return value_unit_cents;
	}
	
    function get_margin(address target) internal view returns (uint256)
	{
		uint256 quantity_usd_cents = clients[target].quantity_usd*100;
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
    
	function liquidate(address target) internal
	{
		uint256 quantity_usd_cents = clients[target].quantity_usd*100;
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
	
	function extend_position(address target, uint256 quantity_usd, uint256 position_type) internal
	{
	    Client storage client = clients[target];
	    Client memory mem = client;
	    
		uint256 balance_unit_cents = mem.hard_balance_unit_cents + mem.soft_balance_unit_cents;
		uint256 new_quantity_usd = mem.quantity_usd + quantity_usd;
	    
		uint256 new_price_in_usd_cents = (mem.quantity_usd*mem.price_in_usd_cents + quantity_usd*price_in_usd_cents)/new_quantity_usd;
		
		uint256 new_quantity_usd_cents = new_quantity_usd*100;
		uint256 new_quantity_unit_cents = convert_to_unit_cents_by_price(new_quantity_usd_cents, new_price_in_usd_cents);
		uint256 initial_margin_unit_cents = calculate_initial_margin(new_quantity_unit_cents);
		
		require(initial_margin_unit_cents <= balance_unit_cents);
		
		uint256 fee_unit_cents = calculate_fee_for_usd(quantity_usd, price_in_usd_cents);
		
		require(fee_unit_cents <= balance_unit_cents);
		
		uint256 soft_fee = min(fee_unit_cents, mem.soft_balance_unit_cents);
		uint256 hard_fee = fee_unit_cents - soft_fee;
		mem.soft_balance_unit_cents -= soft_fee;
		mem.hard_balance_unit_cents -= hard_fee;

		if(client.hard_balance_unit_cents != mem.hard_balance_unit_cents) client.hard_balance_unit_cents = mem.hard_balance_unit_cents;
		if(client.soft_balance_unit_cents != mem.soft_balance_unit_cents) client.soft_balance_unit_cents = mem.soft_balance_unit_cents;
		
		if(client.position_type != position_type) client.position_type = position_type;
		if(client.quantity_usd != new_quantity_usd) client.quantity_usd = new_quantity_usd;
		if(client.price_in_usd_cents != new_price_in_usd_cents) client.price_in_usd_cents = new_price_in_usd_cents;
		
		if(soft_fee > 0) clients[master].soft_balance_unit_cents += soft_fee;
		if(hard_fee > 0) clients[master].hard_balance_unit_cents += hard_fee;
	}
	
	function reduce_position(address target, uint256 quantity_usd, uint256 position_type, uint256 force) internal
	{
	    Client storage client = clients[target];
	    Client memory mem = client;
	    
		uint256 delta_usd = min(quantity_usd, mem.quantity_usd);
		uint256 delta_usd_cents = delta_usd*100;
		
		uint256 profit_unit_cents = convert_to_unit_cents_by_price(delta_usd_cents, price_in_usd_cents);
		uint256 lose_unit_cents = convert_to_unit_cents_by_price(delta_usd_cents, client.price_in_usd_cents);
		
		if(position_type == 1) (lose_unit_cents, profit_unit_cents) = (profit_unit_cents, lose_unit_cents);
		
		uint256 hard_profit = 0;
		uint256 hard_lose = 0;
		if(profit_unit_cents >= lose_unit_cents)
		{
		    profit_unit_cents -= lose_unit_cents;
		    uint256 hard_potencial = address(this).balance - hard_reserved_unit_cents;
		    hard_profit = min(hard_potencial, profit_unit_cents);
		    uint256 soft_profit = profit_unit_cents - hard_profit;
		    mem.soft_balance_unit_cents += soft_profit;
		    mem.hard_balance_unit_cents += hard_profit;
		}else{
		    lose_unit_cents -= profit_unit_cents;
		    uint256 soft_lose = min(mem.soft_balance_unit_cents, lose_unit_cents);
		    hard_lose = lose_unit_cents - soft_lose;
		    mem.soft_balance_unit_cents -= soft_lose;
		    mem.hard_balance_unit_cents -= hard_lose;
		}

	    uint256 balance_unit_cents = mem.soft_balance_unit_cents + mem.hard_balance_unit_cents;
		
		uint256 overhead_usd = quantity_usd - delta_usd;
		if(overhead_usd > 0)
		{
		    uint256 new_quantity_usd_cents = overhead_usd*100;
		    uint256 new_quantity_unit_cents = convert_to_unit_cents_by_price(new_quantity_usd_cents, price_in_usd_cents);
		    uint256 initial_margin_unit_cents = calculate_initial_margin(new_quantity_unit_cents);
		
		    require(initial_margin_unit_cents <= balance_unit_cents);

			mem.position_type = position_type;
			mem.quantity_usd = delta_usd;
			mem.price_in_usd_cents = price_in_usd_cents;
		}else mem.quantity_usd -= quantity_usd;
		
		uint256 fee_unit_cents = calculate_fee_for_usd(quantity_usd, price_in_usd_cents);
		
		require(force == 1 || fee_unit_cents <= balance_unit_cents);

		fee_unit_cents = min(fee_unit_cents, balance_unit_cents);
		
		uint256 soft_fee = min(mem.soft_balance_unit_cents, fee_unit_cents);
		uint256 hard_fee = fee_unit_cents - soft_fee;
		mem.soft_balance_unit_cents -= soft_fee;
		mem.hard_balance_unit_cents -= hard_fee;
		
		if(client.soft_balance_unit_cents != mem.soft_balance_unit_cents) client.soft_balance_unit_cents = mem.soft_balance_unit_cents;
		if(client.hard_balance_unit_cents != mem.hard_balance_unit_cents) client.hard_balance_unit_cents = mem.hard_balance_unit_cents;
		
		if(client.quantity_usd != mem.quantity_usd) client.quantity_usd = mem.quantity_usd;
		if(mem.quantity_usd > 0)
		{
			if(client.position_type != mem.position_type) client.position_type = mem.position_type;
			if(client.price_in_usd_cents != mem.price_in_usd_cents) client.price_in_usd_cents = mem.price_in_usd_cents;
		}
		
		if(hard_profit > 0) hard_reserved_unit_cents += hard_profit;
		if(hard_lose > 0) hard_reserved_unit_cents -= hard_lose;
		
		clients[master].hard_balance_unit_cents += soft_fee;
		clients[master].soft_balance_unit_cents += hard_fee;
	}
    
    /**
     * IDerivatives implementation
     **/
    function deposit() external payable
    {
        require(address(service) != address(0));
        
	    if(msg.sender != master)
	    {
	    	clients[msg.sender].hard_balance_unit_cents += msg.value;
	    	hard_reserved_unit_cents += msg.value;
	    }
    }
    
    function withdrawal(uint256 value) external
    {
        require(address(service) != address(0));
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
    
    event on_set_price(address addr);

    function set_price(uint256 new_price) external
    {
        emit on_set_price(address(service));
        require(address(service) != address(0));
        emit on_set_price(msg.sender);
        emit on_set_price(master);
        require(msg.sender == master);
		
		price_in_usd_cents = new_price;
    }
    
    function set_price_and_liquidation(uint256 new_price, address[] calldata to_liquidate) external
    {
        require(address(service) != address(0));
        require(msg.sender == master);
		
		price_in_usd_cents = new_price;
		
        for(uint256 i = 0; i < to_liquidate.length; i++)
	    {
	        address target = to_liquidate[i];
	        
	    	if(clients[target].quantity_usd == 0) continue;
	    	
	    	liquidate(target);
	    }
    }
    
	function liquidation(address[] calldata to_liquidate) external
	{
	    require(address(service) != address(0));
	    
        for(uint256 i = 0; i < to_liquidate.length; i++)
	    {
	        address target = to_liquidate[i];
	        
	    	if(clients[target].quantity_usd > 0) liquidate(target);
	    }
	}
	
    function create_order_long(uint256 quantity_usd) public
    {
        require(address(service) != address(0));
        require(quantity_usd > 0);
	    
		if(clients[msg.sender].position_type == 0 || clients[msg.sender].quantity_usd == 0) extend_position(msg.sender, quantity_usd, 0);
		else reduce_position(msg.sender, quantity_usd, 0, 0);
    }
    
    function create_order_short(uint256 quantity_usd) public
    {
        require(address(service) != address(0));
        require(quantity_usd > 0);
	    
		if(clients[msg.sender].position_type == 1 || clients[msg.sender].quantity_usd == 0) extend_position(msg.sender, quantity_usd, 1);
		else reduce_position(msg.sender, quantity_usd, 1, 0);
    }
    
    event on_delegate(uint256 value);

    
    function delegate_function(uint256 value) external
    {
        emit on_delegate(value);
    }
}
