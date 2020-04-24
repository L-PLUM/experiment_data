/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity ^0.4.20;
 
 /* https://github.com/LykkeCity/EthereumApiDotNetCore/blob/master/src/ContractBuilder/contracts/token/SafeMath.sol */
library SafeMath {
    uint256 constant public MAX_UINT256 =
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    function safeAdd(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (x > MAX_UINT256 - y) revert();
        return x + y;
    }

    function safeSub(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (x < y) revert();
        return x - y;
    }

    function safeMul(uint256 x, uint256 y) pure internal returns (uint256 z) {
        if (y == 0) return 0;
        if (x > MAX_UINT256 / y) revert();
        return x * y;
    }
}

interface ContractReceiver {
  function tokenFallback( address _from, uint _value, bytes _data) external;
}
 
contract ALUS {

    using SafeMath for uint256;
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value, bytes _data);
    event Print(address indexed _to, uint256 _value);


    mapping(address => uint) public balances;
  
    string public name  = "ALUnits";
    string public symbol  = "ALU";
    uint8 public decimals = 2;
    uint256 public totalSupply;
    bool ableToPrint = true;
    uint signatures = 0;
    uint public price = 1000000;
    uint public totalInCirculation = 0;
    address public central;
    address[] public owners;
    address[] public signedOwners;
    
    constructor() public {
        balances[msg.sender] = 30000000000000 * (10 ** uint256(decimals));
        totalSupply = balances[msg.sender];
        central = msg.sender;
        owners.push(0x1C08fC155a8eA2f8f93d14A1A22c548125450331);
        owners.push(0x880C6b41130DaeD081014443fbAd5f6Fb1790D5f);
        owners.push(0xe2296c9ddCB8DF1f5B74B63a0B8f0aad3d72339d);
    }
    
    
    function () payable external {
        require(ableToPrint);
        require(isOwner(msg.sender));
        uint amount = msg.value.safeMul(price);
        transferFromContract(msg.sender, amount);
        totalInCirculation += amount;
        emit Print(msg.sender, amount);
        ableToPrint = false;
    }
    
    
    function transferOwnerShip(address _newOwner) public returns (bool success) {
        require(isOwner(msg.sender));
        for (uint i=0; i<owners.length;i++){
            if (owners[i] == msg.sender) {
                owners[i] = _newOwner;
            }
        }
        return true;
    }
    
    
    function isOwner(address _sender) public returns (bool) {
        bool isOwner = false;
        for (uint i=0; i<owners.length; i++){
            if (owners[i] == _sender) {
                isOwner = true;
            }
        }
        return isOwner;
    }


    function addSignature() public returns (bool success) {
        uint totalSig = 0;
        require(isOwner(msg.sender));
        signedOwners.push(msg.sender);
        if (signedOwners.length == 2) {
            ableToPrint = true;
            delete signedOwners;
        }
        return true;
    }
    
    
    // Function that is called when a user or another contract wants to transfer funds .
    function transfer(address _to, uint _value, bytes memory _data, bytes memory _custom_fallback) public returns (bool success) {
        require(msg.sender != central);
        if(isContract(_to)) {
            if (balanceOf(msg.sender) < _value) revert();
            balances[msg.sender] = balanceOf(msg.sender).safeSub(_value);
            balances[_to] = balanceOf(_to).safeAdd(_value);
            ContractReceiver rx = ContractReceiver(_to);
            assert(address(rx).call.value(0)(bytes4(keccak256(_custom_fallback)),msg.sender,_value, _data));
            emit Transfer(msg.sender, _to, _value, _data);
            return true;
        }
        else {
            return transferToAddress(_to, _value, _data);
        }
    }
  

  // Function that is called when a user or another contract wants to transfer funds .
    function transfer(address _to, uint _value, bytes memory _data) public returns (bool success) {
        require(msg.sender != central);
        if(isContract(_to)) {
            return transferToContract(_to, _value, _data);
        }
        else {
            return transferToAddress(_to, _value, _data);
        }
    }
  
  // Standard function transfer similar to ERC20 transfer with no _data .
  // Added due to backwards compatibility reasons .
    function transfer(address _to, uint _value) public returns (bool success) {
        require(msg.sender != central);
        //standard function transfer similar to ERC20 transfer with no _data
        //added due to backwards compatibility reasons
        bytes memory empty;
        if(isContract(_to)) {
            return transferToContract(_to, _value, empty);
        }
        else {
            return transferToAddress(_to, _value, empty);
        }
    }

//assemble the given address bytecode. If bytecode exists then the _addr is a contract.
    function isContract(address _addr) private view returns (bool is_contract) {
        uint length;
        assembly {
                //retrieve the size of the code on target address, this needs assembly
                length := extcodesize(_addr)
        }
        return (length>0);
    }

  //function that is called when transaction target is an address
    function transferToAddress(address _to, uint _value, bytes memory _data) private returns (bool success) {
        require(msg.sender != central);
        if (balanceOf(msg.sender) < _value) revert();
        balances[msg.sender] = balanceOf(msg.sender).safeSub(_value);
        balances[_to] = balanceOf(_to).safeAdd(_value);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }
    
    function transferFromContract(address _to, uint _value) private returns (bool success) {
        require(msg.sender != central);
        bytes memory _data;
        if (balanceOf(central) < _value) revert();
        balances[central] = balanceOf(central).safeSub(_value);
        balances[_to] = balanceOf(_to).safeAdd(_value);
        central.transfer(msg.value);
        emit Transfer(central, _to, _value, _data);
        return true;
    }
  
  //function that is called when transaction target is a contract
    function transferToContract(address _to, uint _value, bytes memory _data) private returns (bool success) {
        require(msg.sender != central);
        if (balanceOf(msg.sender) < _value) revert();
        balances[msg.sender] = balanceOf(msg.sender).safeSub(_value);
        balances[_to] = balanceOf(_to).safeAdd(_value);
        ContractReceiver receiver = ContractReceiver(_to);
        receiver.tokenFallback(msg.sender, _value, _data);
        emit Transfer(msg.sender, _to, _value, _data);
        return true;
    }

    function balanceOf(address _owner) view public returns (uint balance) {
        return balances[_owner];
    }
  
  
}
