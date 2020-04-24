/**
 *Submitted for verification at Etherscan.io on 2019-02-14
*/

pragma solidity ^0.5.0;
/**
* @title -Name Filter- v0.1.9
* ┌┬┐┌─┐┌─┐┌┬┐   ╦╦ ╦╔═╗╔╦╗  ┌─┐┬─┐┌─┐┌─┐┌─┐┌┐┌┌┬┐┌─┐
*  │ ├┤ ├─┤│││   ║║ ║╚═╗ ║   ├─┘├┬┘├┤ └─┐├┤ │││ │ └─┐
*  ┴ └─┘┴ ┴┴ ┴  ╚╝╚═╝╚═╝ ╩   ┴  ┴└─└─┘└─┘└─┘┘└┘ ┴ └─┘
*                                  _____                      _____
*                                 (, /     /)       /) /)    (, /      /)          /)
*          ┌─┐                      /   _ (/_      // //       /  _   // _   __  _(/
*          ├─┤                  ___/___(/_/(__(_/_(/_(/_   ___/__/_)_(/_(_(_/ (_(_(_
*          ┴ ┴                /   /          .-/ _____   (__ /
*                            (__ /          (_/ (, /                                      /)™
*                                                 /  __  __ __ __  _   __ __  _  _/_ _  _(/
* ┌─┐┬─┐┌─┐┌┬┐┬ ┬┌─┐┌┬┐                          /__/ (_(__(_)/ (_/_)_(_)/ (_(_(_(__(/_(_(_
* ├─┘├┬┘│ │ │││ ││   │                      (__ /              .-/  © Jekyll Island Inc. 2018
* ┴  ┴└─└─┘─┴┘└─┘└─┘ ┴                                        (_/
*              _       __    _      ____      ____  _   _    _____  ____  ___
*=============| |\ |  / /\  | |\/| | |_ =====| |_  | | | |    | |  | |_  | |_)==============*
*=============|_| \| /_/--\ |_|  | |_|__=====|_|   |_| |_|__  |_|  |_|__ |_| \==============*
*
* ╔═╗┌─┐┌┐┌┌┬┐┬─┐┌─┐┌─┐┌┬┐  ╔═╗┌─┐┌┬┐┌─┐ ┌──────────┐
* ║  │ ││││ │ ├┬┘├─┤│   │   ║  │ │ ││├┤  │ Inventor │
* ╚═╝└─┘┘└┘ ┴ ┴└─┴ ┴└─┘ ┴   ╚═╝└─┘─┴┘└─┘ └──────────┘
*/

library NameFilter {
    /**
     * @dev filters name strings
     * -converts uppercase to lower case.
     * -makes sure it does not start/end with a space
     * -makes sure it does not contain multiple spaces in a row
     * -cannot be only numbers
     * -cannot start with 0x
     * -restricts characters to A-Z, a-z, 0-9, and space.
     * @return reprocessed string in bytes32 format
     */
    function nameFilter(string memory _input)
        internal
        pure
        returns(bytes32)
    {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;

        //sorry limited to 32 characters
        require (_length <= 32 && _length > 0, "string must be between 1 and 32 characters");
        // make sure it doesnt start with or end with space
        require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "string cannot start or end with space");
        // make sure first two characters are not 0x
        if (_temp[0] == 0x30)
        {
            require(_temp[1] != 0x78, "string cannot start with 0x");
            require(_temp[1] != 0x58, "string cannot start with 0X");
        }

        // create a bool to track if we have a non number character
        bool _hasNonNumber;

        // convert & check
        for (uint256 i = 0; i < _length; i++)
        {
            // if its uppercase A-Z
            if (_temp[i] > 0x40 && _temp[i] < 0x5b)
            {
                // convert to lower case a-z
                
                _temp[i] = byte(uint8(_temp[i]) + 32);

                // we have a non number
                if (_hasNonNumber == false)
                    _hasNonNumber = true;
            } else {
                // require character is a space  OR lowercase a-z or 0-9
                require(_temp[i] == 0x20 || (_temp[i] > 0x60 && _temp[i] < 0x7b) || (_temp[i] > 0x2f && _temp[i] < 0x3a),"string contains invalid characters");
                // make sure theres not 2x spaces in a row
                if (_temp[i] == 0x20)
                    require(_temp[i+1] != 0x20, "string cannot contain consecutive spaces");

                // see if we have a character other than a number
                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
                    _hasNonNumber = true;
            }
        }

        require(_hasNonNumber == true, "string cannot be only numbers");

        bytes32 _ret;
        assembly {
            _ret := mload(add(_temp, 32))
        }
        return (_ret);
    }
}
interface UserBookInterface {
    
    function registryUser(uint256 gameId,string calldata userName,uint256 inviteUserId) payable external;

    function queryUserByGameIdAndAddr(uint256 _gameId,address _addr) view external returns(uint256 userId,address addr,bytes32 userName,uint256 directInviteUserId,  uint256[] memory inviteUserIds  );

    function queryUserByGameIdAndUserId(uint256 _gameId,uint256 _userId) view external returns(uint256 userId,address addr,bytes32 userName,uint256 directInviteUserId,  uint256[] memory inviteUserIds  );


}
contract TumblerEvents{

    /**
     *用户注册事件
     */
    event onUserRegistry(
        uint256 indexed gameId,
        uint256 indexed userId,
        address addr,
        bytes32 name,
        uint256 inviteUserId
    );

    /**
    *投资事件
    **/
    event onInvest(
        uint256 indexed gameId,
        address indexed userAddr,
        uint256 amount
    );


    /**
    *提现事件
    **/
    event onWithdraw(
        uint256 indexed gameId,
        address indexed userAddr,
        bytes32 name,
        uint256 amount
    );


    /**
    *一轮开始事件
    **/
    event onRoundStart(
        uint256 indexed gameId,
        uint256 indexed roundId,
        uint256 poolAmount
    );

    /**
    *一轮结束事件
    **/
    event onRoundEnd(
        uint256 indexed gameId,
        uint256 indexed roundId,
        address indexed winnerAddr
    );

    /**
    *收益事件
    **/
    event onProfit(
        uint256 indexed gameId,
        uint256 indexed roundId,
        address winnerAddr,
        bytes32 winnerName,
        uint256 winnerGain,
        uint256 shardingGain,
        uint256 platformGain,
        uint256 adminGain,
        uint256 nextPoolAmount
    );

}

library SafeMath {

    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c)
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }

    /**
     * @dev gives square root of given x.
     */
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y)
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y)
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }

    /**
     * @dev gives square. multiplies x by x
     */
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }

    /**
     * @dev x to the power of y
     */
    function pwr(uint256 x, uint256 y)
        internal
        pure
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
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
}
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * @notice Renouncing to ownership will leave the contract without an owner.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * Utility library of inline functions on addresses
 */
library Address {
    /**
     * Returns whether the target address is a contract
     * @dev This function will return false if invoked during the constructor of a contract,
     * as the code is not actually created until after the constructor finishes.
     * @param account address of the account to check
     * @return whether the target address is a contract
     */
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        // XXX Currently there is no better way to check if there is a contract in an address
        // than to check the size of the code at that address.
        // See https://ethereum.stackexchange.com/a/14016/36603
        // for more details about how this works.
        // TODO Check this again before the Serenity release, because all addresses will be
        // contracts then.
        // solium-disable-next-line security/no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}


contract UserBook is UserBookInterface,Ownable,TumblerEvents{
    using NameFilter for string;
    using SafeMath for uint256;
    //注册手续费
    uint256 public registrationFee = 10 finney;  
    uint256 public userIdSeq= 0;
    /**
     * 用户结构体
     */
    struct User {
        uint256 userId;
        address addr;
        bytes32 userName;
        uint256 directInviteUserId;
        //存储十层关系
        uint256[] inviteUserIds;
    } 
    //gameId=>address=>user
    mapping(uint256=>mapping (address=>User)) public addrToUser;
    //gameId=>userId=>user
    mapping(uint256=>mapping (uint256=>User)) public userIdToUser;

    //gameId=>name=>bool用于判断用户名是否已经被注册
    mapping(uint256=>mapping (bytes32=>bool)) public userNameAlreadyRegistry;

    //gameId=>address=>bool用于判断地址是否已经被注册
    mapping(uint256=>mapping (address=>bool)) public addrAlreadyRegistry;    

    //address=>gameids
    mapping(address=>uint256[]) public addrToGameIds;

    address payable public moneyKeeper;


    modifier addrNotRegistry(uint256 gameId){
        address _addr = msg.sender; 
        require(addrAlreadyRegistry[gameId][_addr]==false,"该地址已经注册,不允许重复注册");
        _;
    }

    // modifier userNameNotRegistry(bytes32 userName){
    //     require(userNameCanRegistry[userName]==false,"该用户名已经被占用");
    //     _;
    // }   

    constructor()public{
        moneyKeeper=msg.sender;
    }

 
    /**
     *  用户注册接口
     */
    function registryUser(uint256 gameId,string calldata userName,uint256 inviteUserId) payable external
       addrNotRegistry(gameId)
    {
        require(!Address.isContract(msg.sender), "只允许人类注册");
        require(msg.value>=registrationFee,"需要支付注册手续费");
        //过滤userName
        bytes32 userNameByte=userName.nameFilter();
        require(userNameAlreadyRegistry[gameId][userNameByte]==false,"该用户名已经被占用");


        //获取上家user对象，如果取不到，那么realInviteUserId为0
        User memory partnerUser=userIdToUser[gameId][inviteUserId];
        uint256 realInviteUserId=partnerUser.userId;

        //获取userId
        userIdSeq++;

        //获取地址
        address userAddr=msg.sender;

        
        uint256[] memory selfInviteUserIds = new uint256[](10);

        if(realInviteUserId!=0){
            //看他上级是否有10个
            uint256 length=partnerUser.inviteUserIds.length;
            uint256 startIndex=0;
            uint256 endIndex=length;
            //最多存储10层
            if(length>=10){
                startIndex = length-9;
            }
            uint256 newIndex=0;
            for(uint256 i=startIndex;i<endIndex;i++){
                selfInviteUserIds[newIndex]=partnerUser.inviteUserIds[i];
                newIndex++;
            }

            selfInviteUserIds[newIndex]=realInviteUserId;
        }
        
        User memory nowUser= User(userIdSeq,msg.sender,userNameByte,realInviteUserId,selfInviteUserIds);

        //注册
        addrToUser[gameId][userAddr] = nowUser;
        userIdToUser[gameId][userIdSeq] = nowUser;
        userNameAlreadyRegistry[gameId][userNameByte] = true;
        addrAlreadyRegistry[gameId][userAddr] = true;   
        addrToGameIds[userAddr].push(gameId);


        //把注册费用直接转给moneyKeeper
        moneyKeeper.transfer(address(this).balance);
        
        emit onUserRegistry(gameId,nowUser.userId,nowUser.addr,nowUser.userName,nowUser.directInviteUserId);
    }

    function refreashRegistrationFee(uint256 _registrationFee) external
        onlyOwner
    {
        registrationFee=_registrationFee;
    }

    function queryUserByGameIdAndAddr(uint256 _gameId,address _addr) view external returns(uint256 userId,address addr,bytes32 userName,uint256 directInviteUserId,  uint256[] memory inviteUserIds  )
    {
       User memory user= addrToUser[_gameId][_addr];
       userId=user.userId;
       addr=user.addr;
       userName=user.userName;
       directInviteUserId=user.directInviteUserId;
       inviteUserIds=user.inviteUserIds;  
    }

    function queryUserByGameIdAndUserId(uint256 _gameId,uint256 _userId) view external returns(uint256 userId,address addr,bytes32 userName,uint256 directInviteUserId,  uint256[] memory inviteUserIds  )
    {
       User memory user= userIdToUser[_gameId][_userId];
       userId=user.userId;
       addr=user.addr;
       userName=user.userName;
       directInviteUserId=user.directInviteUserId;
       inviteUserIds=user.inviteUserIds;  
    }

    function queryGameIdsByAddr(address _userAddr)view external returns ( uint256[] memory aa){
        return addrToGameIds[_userAddr];
    }
}
