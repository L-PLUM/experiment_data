pragma solidity ^0.5.0;
import "./FixedSupplyToken.sol";

contract CampaignFactory {
    address[] public deployedFunds;
        
    function createCampaign(string memory name, string memory symbol, uint8 decimals,
        address[] memory _partnersAccounts, uint[] memory _percentages,
            address _vTokenAddress, uint _entryPrice) public {
            
            address newCampaign = address(new Campaign(name, symbol, decimals, _partnersAccounts,
                _percentages, _vTokenAddress, _entryPrice, msg.sender));
            
            deployedFunds.push(newCampaign);
    }
    
    function getDeployedFunds() public view returns (address[] memory) {
        return deployedFunds;
    }
}

contract vTokenContract {
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);
    function balanceOf(address account) public view returns (uint256);
    function transfer(address recipient, uint256 amount) public returns (bool);
}

contract Campaign is FixedSupplyToken{
    using SafeMath for uint;
    
    struct Partner {
        address accountAddress;
        uint percentage;
    }
    
    address[] public partnersAccounts;
    
    Partner public organizer;
    Partner public celebrity;
    Partner public promoter;
    Partner public virtuBlock;
    
    address public vTokenAddress;
    address[] public contributersAddresses;
    mapping(address => bool) public contributers;
    uint public contributersCount;
    uint public entryPrice;
    address public winner;
    address public manager;
    
    event DistributeToPartner(address indexed _partner);
    event PickRandomWinner(address indexed _winner);
    
    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }

    constructor (string memory name, string memory symbol, uint8 decimals, address[] memory _partnersAccounts, uint[] memory _percentages,  
    address _vTokenAddress, uint _entryPrice, address _manager) public 
        FixedSupplyToken(symbol, name, decimals) {
        partnersAccounts = _partnersAccounts;
        
        organizer.accountAddress = _partnersAccounts[0];
        organizer.percentage = _percentages[0];
        
        celebrity.accountAddress = _partnersAccounts[1];
        celebrity.percentage = _percentages[1];
        
        promoter.accountAddress = _partnersAccounts[2];
        promoter.percentage = _percentages[2];
        
        virtuBlock.accountAddress = _partnersAccounts[3];
        virtuBlock.percentage = _percentages[3];
        
        vTokenAddress = _vTokenAddress;
        entryPrice = _entryPrice;
        manager = _manager;
        
    }
    
    function giveEntries(address reciever, uint amount) public onlyManager returns (bool){
        require(amount > 0, "amount  must be greater than zero");
        uint count = amount.div(entryPrice);
        
        balances[owner] = balances[owner].sub(count);
        balances[reciever] = balances[reciever].add(count);
        
        if (contributers[reciever] == false) {
            contributers[reciever] == true;
            contributersCount++;
            contributersAddresses.push(reciever);   
        }
        
        emit Transfer(owner, reciever, count);
        return true;
    }
    
    
    function distributeOrganizer () public onlyManager distribute(organizer.accountAddress, organizer.percentage) returns (bool) {
        emit DistributeToPartner(organizer.accountAddress);
        return true;
    }
    
    
    function distributeCelebrity () public onlyManager distribute(celebrity.accountAddress, celebrity.percentage) returns (bool) {
        emit DistributeToPartner(celebrity.accountAddress);
        return true;
    }
    
    function distributePromoter () public onlyManager distribute(promoter.accountAddress, promoter.percentage) returns (bool) {
        emit DistributeToPartner(promoter.accountAddress);
        return true;
    }
    
    function distributeVirtuBlock () public onlyManager distribute(virtuBlock.accountAddress, virtuBlock.percentage) returns (bool) {
        emit DistributeToPartner(virtuBlock.accountAddress);
        return true;
    }
    
    modifier distribute (address account, uint percent) {
        vTokenContract vEGP = vTokenContract(vTokenAddress);
        uint balance = vEGP.balanceOf(address(this));
        require(balance > 0, "No balance to distribute");
        vEGP.transfer(account, balance.div(100).mul(percent));
        _;
    }
    
    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, now, contributersAddresses)));
    }
    
    
    function pickWinner() public onlyManager returns (address) {
	require(contributersAddresses.length > 0, "No contributers to pick winner");
        uint index = random() % contributersAddresses.length;
        winner = contributersAddresses[index];
        emit PickRandomWinner(winner);
        delete contributersAddresses[index];
        return winner;
    }
     
}
