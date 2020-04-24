/**
 *Submitted for verification at Etherscan.io on 2019-08-09
*/

pragma solidity ^0.5.2;

library Address {
    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

library SafeMath {
 
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }


    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}
library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    /**
     * @dev Give an account access to this role.
     */
    function add(Role storage role, address account) internal {
        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    /**
     * @dev Remove an account's access to this role.
     */
    function remove(Role storage role, address account) internal {
        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    /**
     * @dev Check if an account has this role.
     * @return bool
     */
     
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}
library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {
        // Check the signature length
        if (signature.length != 65) {
            return (address(0));
        }

        // Divide the signature in r, s and v variables
        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return address(0);
        }

        if (v != 27 && v != 28) {
            return address(0);
        }

        // If the signature is valid (and not malleable), return the signer address
        return ecrecover(hash, v, r, s);
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        // 32 is the length in bytes of hash,
        // enforced by the type signature above
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface AUUGameTokenIER20 {
    function balanceOf(address account) external view returns (uint256);
}
contract AUUGameToken is AUUGameTokenIER20{
    using SafeMath for uint256;
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public round;
    mapping (address => mapping(uint256 => uint256)) internal _balances;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    constructor () public {
        name = "AuuGm";
        symbol = "AuuGm";
        decimals = 12;
        round = 1;
        _balances[address(this)][round] = 50000000000 szabo;
        
    }
    
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account][round];
    }
    
    function _transfer(address sender, address recipient, uint256 amount ) internal{
        require(sender != address(0));
        require(recipient != address(0));

        _balances[sender][round] = _balances[sender][round].sub(amount);
        _balances[recipient][round] = _balances[recipient][round].add(amount);
    }
}
contract Ownable {
    
    address  private  _owner;
    mapping(address => bool) private uservalid;

    // mapping(address => bool) public financerAdmin;
    mapping(address => bool) public authorizedWithdrawal;
    
    address[5] public financerAdmins;
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }
    
    modifier onlyfinancerAdmin(){
        //require(financerAdmin[msg.sender],"Ownable: caller is not the financerAdmin");
        require(isfinancerAdmin(msg.sender));
        _;
    }
    
    function isfinancerAdmin(address user) public view returns(bool){
        for(uint256 i=0;i<financerAdmins.length;i++){
            if(financerAdmins[i] == user){
                return true;
            }
        }
        return false;
    }

    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }


    function transferOwnership(address  newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address  newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    
       
    
    modifier Onlyvalider() {
        require(!isFreeze(msg.sender), "validuser: caller is not valid");
        _;
    }
    
    function isFreeze(address _user) public view returns(bool){
        return uservalid[_user];
    }
    
    function freezeUser(address user,bool isfreeze) public onlyOwner  returns(bool){
        require(uservalid[user] != isfreeze);
        uservalid[user] = isfreeze;
    }
}

contract ECDSAMock is Ownable {
    using ECDSA for bytes32;
    using Roles for Roles.Role;

    event SignerAdded(address indexed account);
    event SignerRemoved(address indexed account);
    Roles.Role private _signers;
    
 
    
    function isSigner(address account) public view returns (bool) {
        return _signers.has(account);
    }
    function addSigner(address account) public onlyOwner {
        _addSigner(account);
    }

    function renounceSigner() public onlyOwner {
        _removeSigner(msg.sender);
    }

    function _addSigner(address account) internal {
        _signers.add(account);
        emit SignerAdded(account);
    }

    function _removeSigner(address account) internal {
        _signers.remove(account);
        emit SignerRemoved(account);
    }    
    function recover(bytes32 hash, bytes memory signature) public pure returns (address) {
        return hash.recover(signature);
    }

    function toEthSignedMessageHash(bytes32 hash) public pure returns (bytes32) {
        return hash.toEthSignedMessageHash();
    }

    function test(uint256 _v) public view returns (bytes32 hash,bytes memory data){
        hash = keccak256(abi.encodePacked(msg.sender,_v));
        data = abi.encodePacked(msg.sender,_v);
    }
    function tosha3(uint256 _v,bytes memory signature) public view returns (bytes32 hash,bytes memory data,address signaddress){
        hash = keccak256(abi.encodePacked(msg.sender,_v));
        data = abi.encodePacked(msg.sender,_v);
        signaddress = recover(hash,signature);
    }

}



contract AUCCGame is ECDSAMock,AUUGameToken{
    using Address for address;
    using SafeMath for uint256;
    
    struct userset{
        address parent;
        uint256 id;
        uint256 members;
        uint256 nonce;
        uint256 inverstcount;
        uint256 inverstnum;
    }
    struct inverstset{
         uint256 inverstamount;
         uint256 inversttime;
    }
    //1
    mapping(address=> mapping(uint256 => mapping(uint256=>inverstset))) public inverstinfo;
    //6
    mapping(uint256 => uint256) public id;
    //5
    mapping(uint256 => uint256) public _inverstcount;
    uint256 public resetinterval;
    uint256 public inverstInterval;
    uint256 public lastinversttime;
    struct inverstlimitset{
        uint256 lowlimit;
        uint256 highlimit;
    }
    inverstlimitset public inverstlimitinfo;
    //2
    mapping(address => mapping(uint256 => userset)) public userinfo;
    IERC20 public  auu;
    uint256 public auu_decimals;
    address private _beneficiary;
    uint256 public capitalpoollimit;
    uint256 public maxinverstcount ;
    
    uint256 public LuckRewardscount;
    uint256 public LuckRewards;
    //3
    mapping(address=>mapping(uint256 => bool)) public hasGetLuckRewards;
    //mapping(uint256 => address) public inverstrecords;
    //4
    mapping(address => mapping(uint256 => mapping(uint256 => bytes))) public rewardRecords;
    mapping(uint256 => uint256) public daily_investment;
    uint256 public daily_investment_limit;
    
    
    modifier nonReentrant() {
        _inverstcount[round] += 1;
        uint256 localCounter = _inverstcount[round];
        _;
        require(localCounter == _inverstcount[round], "ReentrancyGuard: reentrant call");
    }
    
    event Inverst(address indexed user,address indexed referrer, uint value,uint daily); 
    event GetRwards(address indexed user,uint value,uint256 index,bytes signData); 
    event GetLastLuckReward(address indexed user,uint256 id,uint256 value);
    event AdminWithdraw(address indexed user,uint256 value);
    //uint256 private authorizedWithdrawalcount;
    constructor() public {
        _addSigner(0x61f5870E66F0f8d988F4D93bfce42e9a488B95df);
        auu = IERC20(0xBa051262bf577E84c7DEC71A0fdE4666b6584c1F);
        auu_decimals = 12;
        id[round] = 1;
        _inverstcount[round] = 0;

        resetinterval = 1 days;
        inverstInterval = 1 days;
        LuckRewardscount = 1000;
        LuckRewards = 10000000*10**auu_decimals;
        
        capitalpoollimit = 1000*10**auu_decimals;
        maxinverstcount  =  3;

        _beneficiary = address(this);
        inverstlimitinfo.lowlimit = 500*10**auu_decimals;
        inverstlimitinfo.highlimit = 5000*10**auu_decimals;
        
        daily_investment_limit = 100000*10**auu_decimals;
        
        financerAdmins[0] = 0xcF1044266B61c9F7740f22C315a1C04adEB6Ae03;
        financerAdmins[1] = 0x38572dfF383D84524e343E2F47C6b2bC24bAD7a3;
        financerAdmins[2] = 0xE0e666bE45876934A78c86B45fad660B65C2D4Ec;
        financerAdmins[3] = 0x2B0e8a7F353D5AC3128838af52c7BAde7445796E;
        financerAdmins[4] = 0x54eC4F81f6f54Fe6A17c1251640C7440991507De;
        
        
    }
    function startGame() public onlyOwner returns(bool){
        round++;
        _balances[address(this)][round] = 50000000000 szabo;
        lastinversttime = 0;
        id[round] = 1;
        _inverstcount[round] = 0;
        
    }
    
    function setfinancerAdmin(uint256 _index,address _financerAdmin) public onlyOwner returns(bool){
        require(_financerAdmin != address(this) && _financerAdmin != address(0) && _index <= 4 && _index >=0 );
        financerAdmins[_index] = _financerAdmin;
    }
    
    function setAuuAddress(address _auuAddress) public onlyOwner {
        require(Address.isContract(_auuAddress));
        auu = IERC20(_auuAddress);
    }
    
    function ApproveAuthorizedWithdrawal(bool authorized) public onlyfinancerAdmin {
        require(authorizedWithdrawal[msg.sender] != authorized,"AuthorizedWithdrawal not change");
        authorizedWithdrawal[msg.sender] = authorized;
    }
    
    function setresetinterval(uint256 interval) public onlyOwner {
        require(interval >0 && interval != resetinterval);
        resetinterval = interval;
    } 
    function setinverstInterval(uint256 _interval) public onlyOwner {
        require(_interval > 0 && _interval != inverstInterval);
        inverstInterval = _interval;
    }
    
    function setMaxinverstCount(uint256 _count) public onlyfinancerAdmin {
        require(_count >= 0 && _count != maxinverstcount);
        maxinverstcount = _count;
    }
    function setLuckRewards(uint256 _rewards) public onlyfinancerAdmin{
        require(_rewards != LuckRewards && _rewards > 0 );
        LuckRewards = _rewards;
    }
    
    function setnverstlimit(uint256 lowlimit,uint256 highlimit ) public onlyfinancerAdmin {
        require(highlimit>=lowlimit && lowlimit >0);
        inverstlimitinfo.lowlimit = lowlimit;
        inverstlimitinfo.highlimit = highlimit;
    }
    
    function setcapitalpoollimit(uint256 limit) public onlyfinancerAdmin {
        require(limit >=0);
        capitalpoollimit = limit;
    }
    
    function setDaily_investment_limit(uint256 limit) public onlyfinancerAdmin{
        require(limit != daily_investment_limit && limit >= 0);
        daily_investment_limit = limit;
    }
    /*
    function restartgame() onlyOwner public {
        
        lastinversttime = 0;
    }
    */
    function isValidSigner(address _user,uint256 _amount,uint256 _nonce,bytes memory signature) public view returns (bool){
 
        bytes32 hash = keccak256(abi.encodePacked(_user,_amount,_nonce));
        //bytes memory data = abi.encodePacked(msg.sender,_v);
        address signaddress = recover(hash,signature);
        return isSigner(signaddress);
    }
    
    function setBeneficiary(address beneficiary) public onlyOwner{
        require(address(beneficiary)!=address(0));
        _beneficiary = beneficiary;
    }

    
    function caninverst(address _user) public view returns(bool result){
        result = true;
        if(isFreeze(_user) || invssertCount(_user) >= maxinverstcount || isCuruntGameOver() || daily_investment[now.div(1 days)] >= daily_investment_limit) {
            result =  false;
        }
        
    }
    
    function isCuruntGameOver() public view returns(bool){
        
        if(lastinversttime > 0){
            if(now.sub(lastinversttime) > resetinterval){
                return true;
            }
        }
        return false;
    }
    
    
    function invssertCount(address _user) public view returns(uint256 count){
        uint256 nowtime =now;
        if(userinfo[_user][round].inverstcount == 0){
            return 0;
        }
        for(uint256 i=userinfo[_user][round].inverstcount;i>0;i--){
            uint256 stime = inverstinfo[_user][round][i].inversttime;
            if(nowtime.sub(stime) >= inverstInterval){
                break;
            }
            count++;
        }
    }
    
    function inverst(uint256 amount,address parent) public  Onlyvalider nonReentrant  returns(bool){
        
        require(parent != address(0) && parent != address(this)&& parent != msg.sender );
        require(amount >= inverstlimitinfo.lowlimit && amount <=inverstlimitinfo.highlimit);

        address _user = msg.sender;

        require(amount<= auu.allowance(msg.sender, address(this) ) && auu.balanceOf(_user) >=amount ,"allowance or balance is not enough");
        require(invssertCount(_user) < maxinverstcount && ! isCuruntGameOver());
        
        uint256 nowtime = now;
        
        uint256 daysnum = nowtime.div(1 days);
        
        daily_investment[daysnum] = daily_investment[daysnum].add(amount);
        require(daily_investment[daysnum] <= daily_investment_limit);
        
        if(userinfo[_user][1].parent == address(0)){
            userinfo[_user][1].parent = parent;
            userinfo[parent][1].members = userinfo[parent][1].members.add(1);
        }
        
        if(userinfo[_user][round].id == 0){
            userinfo[_user][round].id = id[round];
            id[round] = id[round].add(1);
        }
        userinfo[_user][round].inverstnum = _inverstcount[round];

        uint256 curruntcount = userinfo[_user][round].inverstcount.add(1);
        userinfo[_user][round].inverstcount = curruntcount;
        inverstinfo[_user][round][curruntcount].inversttime = nowtime;
        inverstinfo[_user][round][curruntcount].inverstamount = amount;
        
        lastinversttime = nowtime;
        callOptionalReturn(auu, abi.encodeWithSelector(auu.transferFrom.selector,msg.sender, _beneficiary, amount));
        _transfer(address(this),_user,amount);
        emit Inverst(_user,userinfo[_user][1].parent,amount,daysnum);
    }
    
    function canGetRwards(uint256 _amount,uint256 _nonce,bytes memory _signature) public view Onlyvalider returns(bool res){
        res = false;
        if(auu.balanceOf(address(this))>= capitalpoollimit.add(LuckRewards).add(_amount) && userinfo[msg.sender][round].inverstcount > 0
         && _nonce == userinfo[msg.sender][round].nonce.add(1) && isValidSigner(msg.sender,_amount,_nonce,_signature) ){
            res = true;
        }
    }
    
    function getRwards(uint256 _amount,uint256 _nonce,bytes memory _signature) public Onlyvalider returns(bool){

        require(canGetRwards(_amount,_nonce,_signature));
        
        address _user = msg.sender;
        userinfo[_user][round].nonce = userinfo[_user][round].nonce.add(1);
        rewardRecords[msg.sender][round][_nonce] = _signature;
        callOptionalReturn(auu, abi.encodeWithSelector(auu.transfer.selector,msg.sender, _amount));
        emit GetRwards(_user,_amount,_nonce,_signature);
        
        _amount = _amount>=balanceOf(_user)?balanceOf(_user):_amount;
        _transfer(_user,address(this),_amount);
        return true;
    }
 
    function getAuthorizedWithdrawalcount() public  view returns(uint256 count){
        for(uint256 i=0;i<financerAdmins.length;i++){
            if(authorizedWithdrawal[financerAdmins[i]]){
                count++;
            }
        }
    }
    
    
    function adminWithdraw(uint256 amount) public onlyfinancerAdmin {
        
        require(amount<=auu.balanceOf(address(this)),"has not enough balance");
        require(getAuthorizedWithdrawalcount() > financerAdmins.length.div(2),"Insufficient authorized financerAdmin");
        callOptionalReturn(auu, abi.encodeWithSelector(auu.transfer.selector,msg.sender, amount));
        //reset authorizedWithdrawal
        for(uint256 i=0;i<financerAdmins.length;i++){
            address financerAdmin = financerAdmins[i];
            if(authorizedWithdrawal[financerAdmin]){
                authorizedWithdrawal[financerAdmin] = false;
            }
        }
        emit AdminWithdraw(msg.sender,amount);
    }
    
    function HasLuckReward() public view returns(bool result){
        result = false;
        if(isCuruntGameOver() && _inverstcount[round].sub(userinfo[msg.sender][round].inverstnum) <= LuckRewardscount && ! hasGetLuckRewards[msg.sender][round]){
            result = true;
        }
    }
    
    function getLastLuckReward() public returns(bool){

        require(HasLuckReward());
        
        uint256 rewards = LuckRewards.div(LuckRewardscount);
        
        callOptionalReturn(auu, abi.encodeWithSelector(auu.transfer.selector,msg.sender, rewards));
        hasGetLuckRewards[msg.sender][round] = true;
        
        emit GetLastLuckReward(msg.sender,userinfo[msg.sender][round].id,rewards);
        return true;
    }
    
    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(address(auu).isContract(), "SafeERC20: call to non-contract");
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
    
    function kill(address payable reciver) public onlyOwner {
        callOptionalReturn(auu, abi.encodeWithSelector(auu.transfer.selector,reciver, auu.balanceOf(address(this))));
        selfdestruct(reciver);
    }
}
