/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity 0.5.3;

contract Ahorrar{
    
    address payable owner;
    address payable _newcontract;
    
    struct Client
    {
        uint256 money;
        bool exist;
    }
    
    
    mapping (address => Client) clients;
    
    address[] clientAddress;
    
    constructor() public{
        owner = msg.sender;
    }
	
	event NewClient(address _address);
	
	event AhorrarEvent(address _address, uint256 totalMoney);
	
	event QuitarEvent(address _address, uint256 totalMoney);
	
	event Migration(address _address, uint256 totalMoney);
	
	event ImportedData(address _address, uint256 totalMoney);
	
	function ahorrar() onlyActive public payable {
	    Client memory client = clients[msg.sender];
	    if (!client.exist){
	        client = Client(0, true);
	        clientAddress.push(msg.sender);
	        emit NewClient(msg.sender);
	    }
	    client.money += msg.value;
	    clients[msg.sender] = client;
	    emit AhorrarEvent(msg.sender, client.money);
	}
	
	function quitar() onlyActive public  {
	    Client memory client = clients[msg.sender];
	    if (!client.exist){
	        revert();
	    }
	   client.money=0;
	   clients[msg.sender] = client;
	    msg.sender.transfer(client.money);
	    emit QuitarEvent(msg.sender, client.money);
	}
	
	function verDinero() view public returns (uint256){
        return clients[msg.sender].money;
	}
	
	function getClientAddress() view public returns (address[] memory){
        return clientAddress;
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
        uint256[] memory values = new uint256[](clientAddress.length);

        for (uint i = 0; i<clientAddress.length;i++){
            uint256 money = clients[clientAddress[i]].money;
            values[i] = money;
            emit Migration(clientAddress[i], money);
        }

        (bool res, ) = _newcontract.delegatecall(abi.encodeWithSignature("importData(address[],uint256[])", clientAddress, values));
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
    
    
    function() payable external {}
	
}
