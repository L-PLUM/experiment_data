/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

pragma solidity 0.5.4;


library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }
  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;
    return c;
  }

 
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}

contract Token {
    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract LockTokenContract {
    using SafeMath for uint;
 
    uint256[] public FoundationReleaseStage = [
        0,
        94444444,
        188888888,
        283333333,
        377777777,
        472222222,
        566666666,
        661111111,
        755555555,
        850000000,
        944444444,
        1038888888,
        1133333333,
        1227777777,
        1322222222,
        1416666666,
        1511111111,
        1605555555,
        1700000000,
        1794444444,
        1888888888,
        1983333333,
        2077777777,
        2172222222,
        2266666666,
        2361111111,
        2455555555,
        2550000000,
        2644444444,
        2738888888,
        2833333333,
        2927777777,
        3022222222,
        3116666666,
        3211111111,
        3305555555,
        3400000000
    ];
    
    uint256[] public TeamAndAdviserAddreesOneStage = [
        0,
        0,
        0,
        0,
        3000000,
        6000000,
        9000000,
        12000000,
        15000000,
        18000000,
        21000000,
        24000000,
        27000000,
        30000000,
        33000000,
        36000000,
        39000000,
        42000000,
        45000000,
        48000000,
        51000000,
        54000000,
        57000000,
        60000000,
        63000000,
        66000000,
        69000000,
        72000000,
        75000000,
        78000000,
        81000000,
        84000000,
        87000000,
        90000000,
        93000000,
        96000000,
        99000000,
        102000000,
        105000000,
        300000000
    ];
    
    uint256[] public TeamAndAdviserAddreesTwoStage = [
        0,
        0,
        0,
        0,
        7000000,
        14000000,
        21000000,
        28000000,
        35000000,
        42000000,
        49000000,
        56000000,
        63000000,
        70000000,
        77000000,
        84000000,
        91000000,
        98000000,
        105000000,
        112000000,
        119000000,
        126000000,
        133000000,
        140000000,
        147000000,
        154000000,
        161000000,
        168000000,
        175000000,
        182000000,
        189000000,
        196000000,
        203000000,
        210000000,
        217000000,
        224000000,
        231000000,
        238000000,
        245000000,
        1300000000
    ];
    
    
    address public FoundationAddress = address(0xEe6B81553fd32370865c74b05e0731B0404d523d);
    address public TeamAndAdviserAddreesOne = address(0x14294C60eaA6d8ae880c06899122478ac2E0008e);
    address public TeamAndAdviserAddreesTwo = address(0xfCE6CFAf6CcCF91ffaB21bd05243D0f395D1Bb08);
    address public GubiTokenAddress  = address(0x89A61846a0deDCE44ac10468E7C832657C71F918);
    
    // for test
    // uint public constant StageSection  = 1 minutes;
    // uint public StartTime = now + 120;
    
    uint public constant StageSection  = 1 days * 30;
    uint public StartTime = 1552089600; // 2019-03-09 00:00:00
    
    mapping(address => uint256) AddressWithdrawals;


    constructor() public {
    }


    function () payable external {
        require(msg.sender == FoundationAddress || msg.sender == TeamAndAdviserAddreesOne || msg.sender == TeamAndAdviserAddreesTwo );
        require(msg.value == 0);
        require(now > StartTime);

        Token token = Token(GubiTokenAddress);
        uint balance = token.balanceOf(address(this));
        require(balance > 0);

        uint256[] memory stage;
        if (msg.sender == FoundationAddress) {
            stage = FoundationReleaseStage;
        } else if (msg.sender == TeamAndAdviserAddreesOne) {
            stage = TeamAndAdviserAddreesOneStage;
        } else if (msg.sender == TeamAndAdviserAddreesTwo) {
            stage = TeamAndAdviserAddreesTwoStage;
        }
        uint amount = calculateUnlockAmount(now, balance, stage);
        if (amount > 0) {
            AddressWithdrawals[msg.sender] = AddressWithdrawals[msg.sender].add(amount);

            require(token.transfer(msg.sender, amount.mul(1e18)));
        }
    }

    function calculateUnlockAmount(uint _now, uint _balance, uint256[] memory stage) internal view returns (uint amount) {
        uint phase = _now
            .sub(StartTime)
            .div(StageSection);
            
        if (phase >= stage.length) {
            phase = stage.length - 1;
        }
        
        uint256 unlockable = stage[phase]
            .sub(AddressWithdrawals[msg.sender]);

        if (unlockable <= 0) {
            return 0;
        }

        if (unlockable > _balance) {
            return _balance;
        }
        
        return unlockable;
    }
}
