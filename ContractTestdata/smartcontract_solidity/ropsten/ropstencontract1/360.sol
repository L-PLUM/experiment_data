/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity 0.5.3;

contract Ahorrar21{
    
    address payable owner;
    address payable _newcontract;
    
    struct Client
    {
        uint256 money;
        bool exist;
    }
    
    
    mapping (address => Client) clients21;
    
    address[] clientAddress21;
    
    constructor() public{
        owner = msg.sender;
    }
	
	event NewClient(address _address);
	
	event AhorrarEvent(address _address, uint256 totalMoney);
	
	event QuitarEvent(address _address, uint256 totalMoney);
	
	event Migration(address _address, uint256 totalMoney);
	
	event ImportedData(address _address, uint256 totalMoney);
	
	function ahorrar() onlyActive public payable {
	    Client memory client = clients21[msg.sender];
	    if (!client.exist){
	        client = Client(0, true);
	        clientAddress21.push(msg.sender);
	        emit NewClient(msg.sender);
	    }
	    client.money += msg.value;
	    clients21[msg.sender] = client;
	    emit AhorrarEvent(msg.sender, client.money);
	}
	
	function quitar() onlyActive public  {
	    Client memory client = clients21[msg.sender];
	    if (!client.exist){
	        revert();
	    }
	   client.money=0;
	   clients21[msg.sender] = client;
	    msg.sender.transfer(client.money);
	    emit QuitarEvent(msg.sender, client.money);
	}
	
	function verDinero() view public returns (uint256){
        return clients21[msg.sender].money;
	}
	
	function getClientAddress() view public returns (address[] memory){
        return clientAddress21;
	}

//

    bool active = true;
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    modifier onlyActive {
        require(active);
        _;
    }
    
    function migrate(address payable _newAddress) public onlyOwner onlyActive {
        _newcontract = address(_newAddress);
        uint256[] memory values = new uint256[](clientAddress21.length);

        for (uint i = 0; i<clientAddress21.length;i++){
            uint256 money = clients21[clientAddress21[i]].money;
            values[i] = money;
            emit Migration(clientAddress21[i], money);
        }

        (bool res, ) = _newcontract.delegatecall(abi.encodeWithSignature("importData(address[],uint256[])", clientAddress21, values));
        if (!res) {
            revert();
        }
        _newcontract.transfer(address(this).balance);
        active = false;
    }
    
    function getNewContractAddress() public view returns (address){
        if (!active){
            return _newcontract;
        } else {
            return address(this);
        }
    }
    
    function importData(address[] memory adresses, uint256[] memory values) public onlyOwner onlyActive {
        require(adresses.length == values.length);
        for (uint i = 0; i<adresses.length;i++){
            clientAddress21.push(adresses[i]);
            clients21[adresses[i]] = Client(values[i],true);
            emit ImportedData(clientAddress21[i], clients21[clientAddress21[i]].money);
        }
    }
    
    function() payable external {}
	
}
