/**
 *Submitted for verification at Etherscan.io on 2019-08-06
*/

pragma solidity ^0.5.10;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}

contract ApproveAndCallFallBack {
    function receiveApproval(address _from, uint256 tokens, address token, bytes memory data) public;
}

contract Direction {

    mapping(address => bool) directors;
    uint256 totalDirectors;

    constructor() public {
        directors[msg.sender] = true;
        totalDirectors = 1;
    }

    modifier onlyDirector {
        require(directors[msg.sender] == true);
        _;
    }

    function addDirectors(address _newDirector) public returns(bool success){
        require(directors[msg.sender] && !directors[_newDirector]);
        totalDirectors++;
        directors[_newDirector] = true;
        
        return true;
    }
    
    function removeDirectors(address _director) public returns(bool success){
        require(directors[msg.sender] && directors[_director]);
        
        directors[_director] = false;
        
        return true;
    }
    
    function seeDirector(address _address) public view onlyDirector returns(bool success){
        require(_address != address(0x0));
        
        return directors[_address];
    }
}

contract Service is Direction {

    mapping(address => bool) contractWhiteList;
    mapping(address => address) ownerContract;
    
    modifier onlyPermitted {
        require(contractWhiteList[address(this)] == true);
        _;
    }
    
    function addContract(address _addressContract, address _ownerContract) public onlyDirector returns(bool success) {
        require(_addressContract != address(0x0));
        contractWhiteList[_addressContract] = true;
        ownerContract[_addressContract] = _ownerContract;
        return true;
    }
    
    function seeContractWhiteList(address _addressContract) view public onlyDirector returns(bool) {
        return contractWhiteList[_addressContract] == true;
    }
    
    function removeContract(address _addressContract) public onlyDirector returns(bool success) {
        require(_addressContract != address(0x0) && contractWhiteList[_addressContract]);
        contractWhiteList[_addressContract] = false;
        return true;
    }

}

contract Requirement is Direction, Service{
    
    //1 - Adicionar um endereco como diretor
    //2 - Remover um  diretor
    //3 - Adicionar um contrato de servico
    //4 - Remover um contrato de servicos
    
    struct Request{
        string name;
        string description;
        address applicant;
        address addressToAdd;
        address optional;
        uint256 group;
        bool complete;
        uint256 approvalCounting;
        mapping(address => bool) approvals;
    }

    Request[] public request;
    
    function createRequest(string memory _name, string memory _description, address _add, address _optional, uint256 _group) public onlyDirector {
        require(_group == 1 || _group == 2 || _group == 3 || _group == 4, "Invalid option");
        require(bytes(_name).length > 0 && bytes(_description).length > 0, "Name or description invalid");
       
        Request memory newRequest = Request({
            name: _name,
            description: _description,
            applicant: msg.sender,
            addressToAdd: _add,
            optional: _optional,
            group: _group,
            complete: false,
            approvalCounting: 0
        });
        
        request.push(newRequest);
    } 
    
    function getRequestLength() public view returns(uint){
        return request.length;
    }
    
    function approveRequest(uint256 _index) public {
        Request storage requests = request[_index];
        
        require(requests.approvals[msg.sender] == false);
    
        requests.approvals[msg.sender] = true;
        requests.approvalCounting++;
    }
    
    function finalizeRequest(uint256 _index) public onlyDirector{
        Request storage requests = request[_index];
        
        require((requests.approvalCounting > (totalDirectors/2)) && !requests.complete);
        
        if(requests.group == 1) {
            addDirectors(requests.addressToAdd);
        } else if(requests.group == 2) {
            removeDirectors(requests.addressToAdd);
        } else if(requests.group == 3) {
            addContract(requests.addressToAdd, requests.optional);
        } else if(requests.group == 4) {
            removeContract(requests.addressToAdd);
        }
        
        requests.complete = true;
    }
}

contract Imon is Requirement {
    using SafeMath for uint256;

    //IMON STRUCTURES
    struct Cotation {
        uint256 numerator;
        uint256 denominator;
    }

    //IMON EVENTS
    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );
    
    event Approval(
        address indexed _tokenOwner, 
        address indexed _spender, 
        uint256 _tokens
    );

    //ERC20 PROPERTIES
    string public name = "IMON";
    string public symbol = "iMo";
    string public standard = "IMON Token v2.0";
    uint8 decimals = 2;
    uint256 private supply;
    
    mapping(address => uint) private etherCredit;
    mapping(address => mapping(address => uint)) allowed;
    
    //BOT
    address payable private bot;
    
    modifier onlyBot {
        require(msg.sender == bot);
        _;
    }
    
    uint256 regressiveDays;

    //IMON PROPERTIES
    Cotation public ethCotation;

    constructor(uint256 _cotationNumerator, uint256 _cotationDenominator, address payable _bot) public payable {
        ethCotation.numerator = _cotationNumerator;
        ethCotation.denominator = _cotationDenominator;
        contractWhiteList[address(this)] = true;
        bot = _bot;
        regressiveDays = 0;
    }

    //ERC20
    function transfer(address _to, uint256 _imonValue) public returns(bool success){
        require(etherCredit[msg.sender] >= toEther(_imonValue), "Sender has insufficient balance");
        require(_imonValue > 0, "Imon vaalue must be greater than zero");
        
        uint256 ethValue = toEther(_imonValue);
        
        etherCredit[msg.sender] = etherCredit[msg.sender].sub(ethValue);
        etherCredit[_to] = etherCredit[_to].add(ethValue);

        emit Transfer(msg.sender, _to, ethValue);

        return true;
    }

    function balanceOf(address _address) public view returns(uint256 balance){
        return getImon(etherCredit[_address]);
    }

    function totalSupply() public view returns(uint256 _imonValue){
        return getImon(supply);
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining){
        return allowed[_owner][_spender];        
    }
    
    function approve(address _spender, uint256 _imonValue) public returns (bool success){
        require(etherCredit[msg.sender] >= _imonValue, "Sender has insufficient balance");
        require(_spender != address(0x0), "Invalid address spender");
        
        allowed[msg.sender][_spender] = _imonValue;
        
        emit Approval(msg.sender, _spender, _imonValue);
        
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _imonValue) public returns (bool success){
        require(etherCredit[_from] >= _imonValue, "Address from has insufficient balance");
        require(allowed[_from][msg.sender] >= _imonValue, "Unauthorized value to spend");
        require(_imonValue > 0, "Invalid imon value");
        require(_to != address(0x0), "Invalid address spender");
        
        etherCredit[_from] = etherCredit[_from].sub(_imonValue);
        etherCredit[_to] = etherCredit[_to].add(_imonValue);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_imonValue);
        
        emit Transfer(msg.sender, _to, _imonValue);
        
        return true;
    }
    
    function approveAndCall(address _spender, uint256 _tokens, bytes memory _data) public returns (bool success) {
        allowed[msg.sender][_spender] = _tokens;
        
        emit Approval(msg.sender, _spender, _tokens);
        ApproveAndCallFallBack(_spender).receiveApproval(msg.sender, _tokens, address(this), _data);
        
        return true;
    }
    
    //IMON
    function depositEther() public payable returns(bool success){
        require(msg.value > 0, "Value to deposit must be greater than zero");
        
        etherCredit[msg.sender] = etherCredit[msg.sender].add(msg.value);
        supply = supply.add(msg.value);
        
        return true;
    }
    
    function walletDepositImon(uint256 _imonValue) public returns(bool success){
        require(etherCredit[msg.sender] >= toEther(_imonValue), "Sender has insufficient balance");
        require(_imonValue > 0, "Imon value must be greater than zero");
        
        uint256 ethValue = toEther(_imonValue);
        
        msg.sender.transfer(ethValue);
        etherCredit[msg.sender] = etherCredit[msg.sender].sub(ethValue);
        supply = supply.sub(ethValue);
        
        emit Transfer(address(this), msg.sender, ethValue);
        
        return true;
    }
    
    function serviceDepositImon(address _contractAddress, address payable _address, uint256 _imonValue) public returns(bool success){
        require(etherCredit[_address] >= toEther(_imonValue), "Sender has insufficient balance");
        require(_imonValue > 0, "Imon value must be greater than zero");
        require(contractWhiteList[_contractAddress], "Unauthorized contract");
        
        uint256 ethValue = toEther(_imonValue);
        
        _address.transfer(ethValue);
        etherCredit[_address] = etherCredit[_address].sub(ethValue);
        supply = supply.sub(ethValue);
        
        emit Transfer(address(this), _address, ethValue);
        
        return true;
    }  

    //PRIVATE
    function getImon(uint _value) private view returns(uint imon){
        uint256 result = _value * ethCotation.numerator / ethCotation.denominator ;
        require(result >= 0);
        return result;
    }

    function toEther(uint _imon) private view returns(uint value){
        uint256 result = _imon * ethCotation.denominator / ethCotation.numerator;
        require(result >= 0);
        return result;
    }
    
    //BOT FUNCTIONS
    function signTransaction (address _addressFrom,  address _addressContract, uint256 _imonValue) public onlyBot returns (bool success){
        require(etherCredit[_addressFrom] >= toEther(_imonValue), "Address from has insuficient funds");
        require(contractWhiteList[_addressContract], "Unauthorized contract");
        
        uint256 ethValue = toEther(_imonValue);
        etherCredit[_addressFrom] = etherCredit[_addressFrom].sub(ethValue);
        etherCredit[_addressContract] = etherCredit[_addressContract].add(ethValue);

        //emit Transfer(_addressFrom, _addressContract, ethValue);

        return true;
    }
    
    function cashWithdrawalBot(uint256 _etherValue) public onlyBot returns(bool success) {
        require(now >= regressiveDays, "Unable to withdraw for time");
        require(_etherValue > 0, "Invalid ether value");
        
        msg.sender.transfer(_etherValue);
        supply = supply.sub(_etherValue);

        //emit Transfer(address(this), msg.sender, _etherValue);
        regressiveDays = now + 1 minutes;
        
        return true;
    }
}
