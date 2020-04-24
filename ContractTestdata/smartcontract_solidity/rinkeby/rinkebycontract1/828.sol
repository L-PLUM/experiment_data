/**
 *Submitted for verification at Etherscan.io on 2019-02-07
*/

pragma solidity ^0.5.2;

contract BigOneEvents {

    event onTokenDeposit
    (
        uint256 indexed playerID,
        address indexed playerAddress,
        uint256 tokenIn
    );

    event onEndTx
    (
        uint256 indexed playerID,
        address indexed playerAddress,
        uint256 roundID,
        uint256 tokenIn,
        uint256 pot
    );

    event onWithdraw
    (
        uint256 indexed playerID,
        address playerAddress,
        bytes32 playerName,
        uint256 tokenOut,
        uint256 timeStamp
    );

    event onEndRound
    (
        uint256 roundID,
        uint256 roundTypeID,
        address winnerAddr,
        uint256 winnerNum,
        uint256 amountWon
    );
}

contract BigOneDC is BigOneEvents {
    using SafeMath for *;

    DCTokenInterface private dcTokenContract = DCTokenInterface(0x8E660440F97aFaB88661320E052eD60d459a78A7);

    //****************
    // constant
    //****************
    address private ceo = msg.sender;

    string constant public name = "bigOne";
    string constant public symbol = "bigOne";   
    
    //****************
    // var
    //****************
    address private coo;

    uint256 pIdCount = 0;

    //****************
    // PLAYER DATA
    //****************
    mapping (address => uint256) public pIDxAddr;          // (addr => pID) returns player id by address
    mapping (uint256 => BigOneData.Player) public playerMap;   // (pID => data) player data


    //==============================================================================
    // init
    //==============================================================================
    constructor() public {

        pIdCount++;
        playerMap[pIdCount].id = pIdCount;
        playerMap[pIdCount].addr = address(0xe27C188521248A49aDfc61090D3c8ab7C3754E0a);
        playerMap[pIdCount].name = "matt";
        pIDxAddr[0xe27C188521248A49aDfc61090D3c8ab7C3754E0a] = pIdCount;
    }

    //==============================================================================
    // checks
    //==============================================================================
    modifier onlyCLevel() {
        require(
            msg.sender == coo || msg.sender == ceo
            ,"msg sender is not c level"
        );
        _;
    }

    modifier isHuman() {
        address _addr = msg.sender;
        uint256 _codeLength;

        assembly {_codeLength := extcodesize(_addr)}
        require(_codeLength == 0, "sorry humans only");
        _;
    }

    //==============================================================================
    // admin
    //==============================================================================
    function setDCContract(address _newAddr) public onlyCLevel {
        dcTokenContract = DCTokenInterface(_newAddr);
    }

    function setCoo(address _newCoo) public onlyCLevel {
        require(_newCoo != address(0));
        coo = _newCoo;
    }

    //==============================================================================
    // public
    //==============================================================================
    function receiveDeposit(address _from, uint256 _value, bytes calldata _data)
        external
    {
        uint256 _pId = determinePID(_from);

        bool _isSuccess = dcTokenContract.transferFrom(_from, address(this), _value);
        require(_isSuccess, "dc transfer from failed");

        playerMap[_pId].deposit += _value;
        
        emit BigOneEvents.onTokenDeposit({
            playerID: _pId,
            playerAddress: _from,
            tokenIn: _value
        });
    }


    //==============================================================================
    // private
    //==============================================================================
    function determinePID(address _addr)
        private
        returns(uint256)
    {
        if (pIDxAddr[_addr] == 0)
        {
            pIdCount++;
            pIDxAddr[_addr] = pIdCount;

            playerMap[pIdCount].id = pIdCount;
            playerMap[pIdCount].addr = _addr;
        } 
        uint256 _pId = pIDxAddr[_addr];
        return _pId;
    }

}

//==============================================================================
// struct
//==============================================================================
library BigOneData {

    struct Player {
        uint256 id;
        address addr;   // player address
        bytes32 name;   // player name
        uint256 deposit; //deposit dc

        uint256 win;    // winnings vault
        uint256 gen;    // general vault
        uint256 aff;    // affiliate vault
        uint256 lrnd;   // last round played
        uint256 laff;   // last affiliate id used
    }

}


//==============================================================================
// interface
//==============================================================================
interface DCTokenInterface {
    function transferFrom(address from, address to, uint256 value) external returns (bool);
    function transfer(address to, uint256 value) external returns (bool);
    function balanceOf(address addr) external view returns (uint256);
    function getCurrentPrice() external view returns (uint256);
}

library SafeMath 
{
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (_a == 0) {
            return 0;
        }

        uint256 c = _a * _b;
        require(c / _a == _b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b > 0); // Solidity only automatically asserts when dividing by 0
        uint256 c = _a / _b;
        // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
        require(_b <= _a);
        uint256 c = _a - _b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
        uint256 c = _a + _b;
        require(c >= _a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}
