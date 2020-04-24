/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity ^0.5.10;

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// ProfitLineInc contract
contract IPO  {
    using SafeMath for uint;
    // IPO specifics
    //uint256 public target; //funding target/cap
    address payable public hubFundAdmin;
    uint256 public payoutPot;
    // interface
    PlincInterface constant hub_ = PlincInterface(0xa5102b032096dd8DBF6Bf254A8B850a3471e955B);// hubplinc
    // setup vars
    mapping(uint256 => uint256)public  bondsOutstanding; // redeemablebonds switched to uint256 instead of address
    uint256 public totalSupplyBonds; //totalsupply of bonds outstanding
    mapping(address => uint256)public  playerVault; // in contract eth balance
    mapping(uint256 => uint256) public  totalsupplyStake; // stake totalsupply
    
    mapping(uint256 => uint256)public  pendingFills; //eth to fill bonds
    
    mapping(address => uint256)public  playerId; //investor to playerid
    mapping(uint256 => uint256)public  IPOtoID; //IPO to playerid
    mapping(uint256 => address payable)public  IdToAdress; //address which is owner of ID
    uint256  public nextPlayerID;
    
    uint256 public nextIPO;// IPO registration number
    mapping(uint256 => address)public  IPOcreator; 
    mapping(uint256 => bool)public  IPOhasTarget;
    mapping(uint256 => uint256)public  IPOtarget;
    mapping(uint256 => bool)public  IPOisActive;
    mapping(uint256 => bytes32)public  IPOinfo;
    
    
    //sale vars
    mapping(uint256 =>  mapping(address => uint256))public  IPOpurchases;// IPO - address - amount
    mapping(uint256 =>  mapping(uint256 => address))public  IPOadresslist;// IPO - adressno - address
    mapping(uint256 => uint256)public  IPOnextAddressPointer;
    mapping(uint256 => uint256)public  IPOamountFunded;
    mapping(uint256 =>  uint256)public  IdVaultedEths;// IPO - address - amount
    // ranking
    mapping(uint256 => uint256)public  IPOprofile;
    mapping(uint256 => bool)public  UIblacklist;
    
    //mapping(uint256 => bytes32)public  IPOreview;
    
    
    // IPO functions
    function registerIPO(address payable creator,bool hasTarget, uint256 target,bytes32 info) public updateAccount(playerId[msg.sender]){
        uint256 next = nextIPO;
         
        // write IPO in Investorbook
        
           IPOtoID[next] = nextPlayerID; //retrieve this ID to know the location of IPO's bonds
           IdToAdress[nextPlayerID] = creator; //register who can withdraw from the ID
           fetchdivs(nextPlayerID);
           nextPlayerID++;
            
        // set creator
        IPOcreator[next] = creator;
        // set hasTarget
        IPOhasTarget[next] = hasTarget;
        // set target
        IPOtarget[next] = target;
        // set info
        IPOinfo[next] = info;
        
        // activate IPO
        IPOisActive[next] = true;
        // update IPO pointer
        nextIPO++;
    }
    function fundIPO(uint256 IPOidentifier) public payable updateAccount(playerId[msg.sender])updateAccount(IPOtoID[IPOidentifier]){
        // check if IPO is active
        uint256 value = msg.value;
        address payable sender = msg.sender;
        require(IPOisActive[IPOidentifier] = true);
        // check if it has target
        if(IPOhasTarget[IPOidentifier] = true)
        {
            // check if funding vs target overflow
            if(IPOamountFunded[IPOidentifier].add(value)  > IPOtarget[IPOidentifier]){
                // add excess to playervault
                playerVault[sender] = playerVault[sender].add(IPOamountFunded[IPOidentifier].add(value)).sub(IPOtarget[IPOidentifier]);
                // change value to amount of able to fund
                value = IPOtarget[IPOidentifier].sub(IPOamountFunded[IPOidentifier]);
            }
        }
         // update Investorbook
        if(playerId[sender] == 0){
           playerId[sender] = nextPlayerID;
           IdToAdress[nextPlayerID] = sender;
           fetchdivs(nextPlayerID);
           nextPlayerID++;
            }
        // Update bonds sender
        bondsOutstanding[playerId[sender]] = bondsOutstanding[playerId[sender]].add(value);
        // update bonds IPOcreator
        bondsOutstanding[IPOtoID[IPOidentifier]] = bondsOutstanding[IPOtoID[IPOidentifier]].add(value.div(10));
        // ADJUST totalsupply
        totalSupplyBonds = totalSupplyBonds.add(value).add(value.div(10));
        // update IPOpurchases for the sender
        IPOpurchases[IPOidentifier][sender] =  IPOpurchases[IPOidentifier][sender].add(value);
        // add address to IPOadresslist
        IPOadresslist[IPOidentifier][IPOnextAddressPointer[IPOidentifier]] = sender;
        // update IPOnextAddressPointer
        IPOnextAddressPointer[IPOidentifier] = IPOnextAddressPointer[IPOidentifier].add(1);
        // update IPOamountFunded
        IPOamountFunded[IPOidentifier] = IPOamountFunded[IPOidentifier].add(value);
        //buy hub bonds
        hub_.buyBonds.value(value)(0x0B0eFad4aE088a88fFDC50BCe5Fb63c6936b9220) ;
    }
    // PIMP UPGRADE START
    function giftExcessBonds(address payable _IPOidentifier) public payable updateAccount(playerId[msg.sender])updateAccount(playerId[_IPOidentifier]){
        // check if IPO is active
        uint256 value = msg.value;
        address payable sender = msg.sender;
        
         // update Investorbook for sender
        if(playerId[sender] == 0){
           playerId[sender] = nextPlayerID;
           IdToAdress[nextPlayerID] = sender;
           fetchdivs(nextPlayerID);
           nextPlayerID++;
            }
            // update Investorbook for giftee
        if(playerId[_IPOidentifier] == 0){
           playerId[_IPOidentifier] = nextPlayerID;
           IdToAdress[nextPlayerID] = _IPOidentifier;
           fetchdivs(nextPlayerID);
           nextPlayerID++;
            }
        // Update bonds sender
        bondsOutstanding[playerId[sender]] = bondsOutstanding[playerId[sender]].add(value);
        // update bonds receiver
        bondsOutstanding[playerId[_IPOidentifier]] = bondsOutstanding[playerId[_IPOidentifier]].add(value.div(10));
        // ADJUST totalsupply
        totalSupplyBonds = totalSupplyBonds.add(value).add(value.div(10));
        //buy hub bonds
        hub_.buyBonds.value(value)(0x0B0eFad4aE088a88fFDC50BCe5Fb63c6936b9220) ;
    }
    function giftAll(address payable _IPOidentifier) public payable updateAccount(playerId[msg.sender])updateAccount(playerId[_IPOidentifier]){
        // check if IPO is active
        uint256 value = msg.value;
        address payable sender = msg.sender;
        
         // update Investorbook for sender
        if(playerId[sender] == 0){
           playerId[sender] = nextPlayerID;
           IdToAdress[nextPlayerID] = sender;
           fetchdivs(nextPlayerID);
           nextPlayerID++;
            }
            // update Investorbook for giftee
        if(playerId[_IPOidentifier] == 0){
           playerId[_IPOidentifier] = nextPlayerID;
           IdToAdress[nextPlayerID] = _IPOidentifier;
           fetchdivs(nextPlayerID);
           nextPlayerID++;
            }
        // Update bonds sender
        bondsOutstanding[playerId[_IPOidentifier]] = bondsOutstanding[playerId[_IPOidentifier]].add(value);
        // update bonds receiver
        bondsOutstanding[playerId[_IPOidentifier]] = bondsOutstanding[playerId[_IPOidentifier]].add(value.div(10));
        // ADJUST totalsupply
        totalSupplyBonds = totalSupplyBonds.add(value).add(value.div(10));
        //buy hub bonds
        hub_.buyBonds.value(value)(0x0B0eFad4aE088a88fFDC50BCe5Fb63c6936b9220) ;
    }
    // PIMP upgrade end
    function changeIPOstate(uint256 IPOidentifier, bool state) public payable {
        address sender = msg.sender;
        require(sender == IPOcreator[IPOidentifier]);
        // activate or deactive IPO
        IPOisActive[IPOidentifier] = state;
    }
    function changeUIblacklist(uint256 IPOidentifier, bool state) public payable {
        
        address sender = msg.sender;
        require(sender == hubFundAdmin);
        // activate or deactive IPO for UI
        UIblacklist[IPOidentifier] = state;
    }
    function changeIPOinfo(uint256 IPOidentifier, bytes32 info) public payable {
        address sender = msg.sender;
        require(sender == IPOcreator[IPOidentifier]);
        // set info
        IPOinfo[IPOidentifier] = info;
        
    }
    // pay to get higher visibillity
    function RaiseProfile(uint256 IPOidentifier) public payable updateAccount(playerId[msg.sender])updateAccount(playerId[hubFundAdmin]){
        // check if IPO is active
        uint256 value = msg.value;
        address sender = msg.sender;
        require(IPOisActive[IPOidentifier] == true);
        
        // Update bonds sender
        bondsOutstanding[playerId[sender]] = bondsOutstanding[playerId[sender]].add(value);
        // update bonds admin
        bondsOutstanding[playerId[hubFundAdmin]] = bondsOutstanding[playerId[hubFundAdmin]].add(value.div(10));
        // raise profile of IPO
        IPOprofile[IPOidentifier] = IPOprofile[IPOidentifier].add(value);
    }
    //div setup type bonds
    uint256 public pointMultiplier = 10e18;
    struct Account {
        uint256 owned;
        uint256 lastDividendPoints;
        }
    mapping(uint256=>Account)public  accounts;
    
    uint256 public totalDividendPoints;
    uint256 public unclaimedDividends;

    function dividendsOwing(uint256 account) public view returns(uint256) {
        uint256 newDividendPoints = totalDividendPoints.sub(accounts[account].lastDividendPoints);
        return (bondsOutstanding[account] * newDividendPoints) / pointMultiplier;
    }
    function fetchdivs(uint256 toupdate) public updateAccount(toupdate){}
    
    
    modifier updateAccount(uint256 account) {
        uint256 owing = dividendsOwing(account);
        if(owing > 0) {
            
            unclaimedDividends = unclaimedDividends.sub(owing);
            pendingFills[account] = pendingFills[account].add(owing);
        }
        accounts[account].lastDividendPoints = totalDividendPoints;
        _;
        }
    function () external payable{} // needs for divs
    function vaultToWallet(uint256 _ID) public {
        
        address payable _sendTo = IdToAdress[_ID];
        require(playerVault[IdToAdress[_ID]] > 0);
        //require(IdToAdress[_ID] = _sender);
        uint256 value = playerVault[IdToAdress[_ID]];
        playerVault[_sendTo] = 0;
        _sendTo.transfer(value);
        
    }
    
    function fillBonds (uint256 bondsOwner) updateAccount(bondsOwner) public {
        uint256 pendingz = pendingFills[bondsOwner];
        require(bondsOutstanding[bondsOwner] > 1000 && pendingz > 1000);
        if(pendingz > bondsOutstanding[bondsOwner]){
            // if has excess fills, excess to redistibution
            payoutPot = payoutPot.add(pendingz.sub(bondsOutstanding[bondsOwner]));
            pendingz = bondsOutstanding[bondsOwner];
            
        }
        //require(pendingz <= bondsOutstanding[bondsOwner]);
        // empty the pendings
        pendingFills[bondsOwner] = 0;
        // decrease bonds outstanding
        bondsOutstanding[bondsOwner] = bondsOutstanding[bondsOwner].sub(pendingz);
        // adjust totalSupplyBonds
        totalSupplyBonds = totalSupplyBonds.sub(pendingz);
        // add to vault
        playerVault[IdToAdress[bondsOwner]] = playerVault[IdToAdress[bondsOwner]].add(pendingz);
        // count amount for transparancy IPO
        IdVaultedEths[bondsOwner] = IdVaultedEths[bondsOwner].add(pendingz);
    }
    function setHubAuto(uint256 percentage) public{
        require(msg.sender == hubFundAdmin);
        hub_.setAuto(percentage);
    }
    function fetchHubVault() public{
        
        uint256 value = hub_.playerVault(address(this));
        require(value >0);
        require(msg.sender == hubFundAdmin);
        hub_.vaultToWallet();
        payoutPot = payoutPot.add(value);
    }
    function fetchHubPiggy() public{
        
        uint256 value = hub_.piggyBank(address(this));
        require(value >0);
        hub_.piggyToWallet();
        payoutPot = payoutPot.add(value);
    }
    function potToPayout() public {
        uint256 value = payoutPot;
        payoutPot = 0;
        require(value > 1 finney);
        totalDividendPoints = totalDividendPoints.add(value.mul(pointMultiplier).div(totalSupplyBonds));
        unclaimedDividends = unclaimedDividends.add(value);
    }    
    constructor()
        public
        
    {
        hubFundAdmin = 0x0B0eFad4aE088a88fFDC50BCe5Fb63c6936b9220;// change to new address for marketing fund
        playerId[hubFundAdmin] = 1;
        IdToAdress[1] = hubFundAdmin;
        nextPlayerID = 2;
        hub_.setAuto(10);
    }

// UI helper functions
    function getPlayerInfo() public view returns(address[] memory _Owner, uint256[] memory locationData,address[] memory infoRef ){
          uint i;
          address[] memory _locationOwner = new address[](nextPlayerID); //address
          uint[] memory _locationData = new uint[](nextPlayerID*4); //bonds - divs - pending - vault 
          address[] memory _info = new address[](nextPlayerID*2);
          //bool[] memory _locationData2 = new bool[](nextPlayerID); //isAlive
          uint y;
          uint z;
          for(uint x = 0; x < nextPlayerID; x+=1){
            
             
                _locationOwner[i] = IdToAdress[i];
                _locationData[y] = bondsOutstanding[playerId[IdToAdress[i]]];
                _locationData[y+1] = dividendsOwing(playerId[IdToAdress[i]]);
                _locationData[y+2] = pendingFills[playerId[IdToAdress[i]]];
                _locationData[y+3] = playerVault[IdToAdress[i]];
                _info[z] = IdToAdress[i];
                _info[z+1] = IdToAdress[i];
                
                //_locationData2[i] = allowAutoInvest[IdToAdress[i]];
              y += 4;
              z += 2;
              i+=1;
            }
          
          return (_locationOwner,_locationData, _info);
        }
        function getIPOInfo(address user) public view returns(address[] memory _Owner, uint256[] memory locationData , bool[] memory states, bytes32[] memory infos){
          uint i;
          address[] memory _locationOwner = new address[](nextIPO); // IPO creator
          uint[] memory _locationData = new uint[](nextIPO * 6); // IPOtarget - IPOamountFunded - IPOprofile - owned
          bool[] memory _states = new bool[](nextIPO * 3); //hastarget - isactive - isblacklisted
          bytes32[] memory _infos = new bytes32[](nextIPO);// info - info2 info3
          uint y;
          uint z;
          for(uint x = 0; x < nextIPO; x+=1){
            
             
                _locationOwner[i] = IPOcreator[i];
                _locationData[y] = IPOtarget[i];
                _locationData[y+1] = IPOamountFunded[i];
                _locationData[y+2] = IPOprofile[i];
                _locationData[y+3] = IPOpurchases[i][user];
                _locationData[y+4] = IdVaultedEths[IPOtoID[i]];
                _locationData[y+5] = IPOtoID[i];
                _states[z] = IPOhasTarget[i];
                _states[z+1] = IPOisActive[i];
                _states[z+2] = UIblacklist[i];
                _infos[i] = IPOinfo[i];
                
              y += 6;
              z += 3;
              i+=1;
            }
          
          return (_locationOwner,_locationData, _states, _infos);
        }
        
}
interface PlincInterface {
    
    function IdToAdress(uint256 index) external view returns(address);
    function nextPlayerID() external view returns(uint256);
    function bondsOutstanding(address player) external view returns(uint256);
    function playerVault(address player) external view returns(uint256);
    function piggyBank(address player) external view returns(uint256);
    function vaultToWallet() external ;
    function piggyToWallet() external ;
    function setAuto (uint256 percentage)external ;
    function buyBonds( address referral)external payable ;
}
