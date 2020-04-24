/**
 *Submitted for verification at Etherscan.io on 2019-02-23
*/

pragma solidity ^0.4.24;

contract Ownable {
    address public owner;

    function Ownable() public{
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) onlyOwner public{
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}

contract HumanStandardToken is  Ownable {
	uint256 public totalSupply;
	string public name;
	uint256 public decimals;
	string public symbol;
	bool public mintable;
	bool public inited;

	mapping (address => uint256) balances;
	mapping (address => mapping (address => uint256)) allowed;

	//Event which is triggered to log all transfers to this contract's event log
	event Transfer(
		address indexed _from,
		address indexed _to,
		uint256 _value
		);

	//Event which is triggered whenever an owner approves a new allowance for a spender.
	event Approval(
		address indexed _owner,
		address indexed _spender,
		uint256 _value
		);

  function HumanStandardToken() public {}
  function init(uint256 _totalSupply, string _symbol, uint256 _decimals, string _name,bool _mintable) public {
        require(!inited);
		decimals = _decimals;
		symbol = _symbol;
		name = _name;
		mintable = _mintable;
        totalSupply = _totalSupply;
        balances[msg.sender] = totalSupply;
        inited = true;
  }

	//Fix for short address attack against ERC20
	modifier onlyPayloadSize(uint size) {
		assert(msg.data.length == size + 4);
		_;
	}

	function balanceOf(address _owner) constant public returns (uint256) {
		return balances[_owner];
	}

	function transfer(address _to, uint256 _value) onlyPayloadSize(2*32) public {
		require(balances[msg.sender] >= _value && _value > 0);
	    balances[msg.sender] -= _value;
	    balances[_to] += _value;
	    emit Transfer(msg.sender, _to, _value);
    }

	function transferFrom(address _from, address _to, uint256 _value) public {
		require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
    }

	function approve(address _spender, uint256 _value) public {
		allowed[msg.sender][_spender] = _value;
		emit Approval(msg.sender, _spender, _value);
	}

	function allowance(address _owner, address _spender) constant public returns (uint256) {
		return allowed[_owner][_spender];
	}

	function mint(uint256 amount) onlyOwner public {
		require(mintable == true);
		require(amount >= 0);
		balances[msg.sender] += amount;
		totalSupply += amount;
	}



    function burn(uint256 _value) onlyOwner public returns (bool) {
        require(balances[msg.sender] >= _value  && totalSupply >=_value && _value > 0);
        balances[msg.sender] -= _value;
        totalSupply -= _value;
        emit Transfer(msg.sender, 0x0, _value);
        return true;
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        //require(_spender.call(bytes4(keccak256("receiveApproval(address,uint256,address,bytes)")), abi.encode(msg.sender, _value, this, _extraData)));
        require(_spender.call(abi.encodeWithSelector(bytes4(keccak256("receiveApproval(address,uint256,address,bytes)")),msg.sender, _value, this, _extraData)));

        return true;
    }

}

contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract TokenCreation is Ownable{


    event LogTokenCreated(HumanStandardToken token);

    address public receiverAddress;
    uint public txFee = 0.1 ether;
    uint public VIPFee = 1 ether;

    /* VIP List */
    mapping(address => bool) public vipList;
	uint public numContracts;

    mapping(uint => HumanStandardToken) deployedContracts;

	mapping(address => address[]) public userDeployedContracts;



    function () payable public{}

    function getBalance(address _tokenAddress) onlyOwner public {
      address _receiverAddress = getReceiverAddress();
      if(_tokenAddress == address(0)){
          require(_receiverAddress.send(address(this).balance));
          return;
      }
      ERC20 token = ERC20(_tokenAddress);
      uint256 balance = token.balanceOf(this);
      token.transfer(_receiverAddress, balance);
  }


    //Register VIP
    function registerVIP() payable public {
      require(msg.value >= VIPFee);
      address _receiverAddress = getReceiverAddress();
      require(_receiverAddress.send(msg.value));
      vipList[msg.sender] = true;
  }


    function addToVIPList(address[] _vipList) onlyOwner public {
        for (uint i =0;i<_vipList.length;i++){
            vipList[_vipList[i]] = true;
        }
    }


    function removeFromVIPList(address[] _vipList) onlyOwner public {
        for (uint i =0;i<_vipList.length;i++){
        vipList[_vipList[i]] = false;
        }
   }

    function isVIP(address _addr) public view returns (bool) {
        return _addr == owner || vipList[_addr];
    }


    function setReceiverAddress(address _addr) onlyOwner public {
        require(_addr != address(0));
        receiverAddress = _addr;
    }

    function getReceiverAddress() public view returns  (address){
        if(receiverAddress == address(0)){
            return owner;
        }

        return receiverAddress;
    }

    function setVIPFee(uint _fee) onlyOwner public {
        VIPFee = _fee;
    }


    function setTxFee(uint _fee) onlyOwner public {
        txFee = _fee;
    }

     function getUserCreatedTokens(address from) public view returns  (address[]){

        return userDeployedContracts[from];
    }


    function create(uint256 _totalSupply, string _symbol, uint256 _decimals, string _name, bool _mintable) payable public returns(address a){

        //check the tx fee
        uint sendValue = msg.value;
	    bool vip = isVIP(msg.sender);
        if(!vip){
		    require(sendValue >= txFee);
        }

        HumanStandardToken token = new HumanStandardToken();
        token.init(_totalSupply, _symbol, _decimals, _name, _mintable);
        token.transfer(msg.sender,_totalSupply);
        token.transferOwnership(msg.sender);

        numContracts++;

        address[] userAddresses = userDeployedContracts[msg.sender];
        userAddresses.push(token);
        userDeployedContracts[msg.sender] = userAddresses;

        deployedContracts[numContracts] = token;

        emit LogTokenCreated(token);

		return token;
     }
}
