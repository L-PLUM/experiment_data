/**
 *Submitted for verification at Etherscan.io on 2019-02-23
*/

pragma solidity ^0.4.20;
/**
███████╗██████╗ ███████╗███████╗    ████████╗ ██████╗     ██████╗ ██╗      █████╗ ██╗   ██╗    ███╗   ██╗███████╗████████╗██╗    ██╗ ██████╗ ██████╗ ██╗  ██╗
██╔════╝██╔══██╗██╔════╝██╔════╝    ╚══██╔══╝██╔═══██╗    ██╔══██╗██║     ██╔══██╗╚██╗ ██╔╝    ████╗  ██║██╔════╝╚══██╔══╝██║    ██║██╔═══██╗██╔══██╗██║ ██╔╝
█████╗  ██████╔╝█████╗  █████╗         ██║   ██║   ██║    ██████╔╝██║     ███████║ ╚████╔╝     ██╔██╗ ██║█████╗     ██║   ██║ █╗ ██║██║   ██║██████╔╝█████╔╝ 
██╔══╝  ██╔══██╗██╔══╝  ██╔══╝         ██║   ██║   ██║    ██╔═══╝ ██║     ██╔══██║  ╚██╔╝      ██║╚██╗██║██╔══╝     ██║   ██║███╗██║██║   ██║██╔══██╗██╔═██╗ 
██║     ██║  ██║███████╗███████╗       ██║   ╚██████╔╝    ██║     ███████╗██║  ██║   ██║       ██║ ╚████║███████╗   ██║   ╚███╔███╔╝╚██████╔╝██║  ██║██║  ██╗
╚═╝     ╚═╝  ╚═╝╚══════╝╚══════╝       ╚═╝    ╚═════╝     ╚═╝     ╚══════╝╚═╝  ╚═╝   ╚═╝       ╚═╝  ╚═══╝╚══════╝   ╚═╝    ╚══╝╚══╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝   
                                                                                                                    /|
          |\                                                              /|                                      /'||
          | \                                                            / |                                     |  ||
          |  \                                                          /  |                                     |  ||
          |   \                                                        /   |                                     |  ||
          |    \                                                      /    |                                     |  ||
     _____)     \                                                    /     (____                                 |  ||                                                        
     \           \                                                  /          /                                 |  ||
      \           \                                                /          /                                  |  ||
       \           `--_____                                _____--'          /                                   |  ||  
        \                  \                              /                 /                                    |  ||
     ____)                  \                            /                 (____                                 |  ||
     \                       \        /|      |\        /                      /                                 |  ||
      \                       \      | /      \ |      /                      /                                  |  ||
       \                       \     ||        ||     /                      /                                   |  ||
        \                       \    | \______/ |    /                      /                                    |  ||
         \                       \  / \        / \  /                      /                                     |  ||         __.--._                                                  
          /                       \| (●\  \/  /●) |/                      \                                      |  ||  _.-~ / _---._ ~-\/~\
         /                         \   \| \/ |/   /                        \                                     |  || // /  /~/  .-  \  /~-\
        /                           \  \| \/ |/  /                          \                                    |  ||((( /(/_(.-(-~~~~~-)_/ |
       /                            |   |    |   |                           \                                   |  || ) (( |_.----~~~~~-._\ /
      /                             |\ _\____/_ /|                            \                                  |  ||    ) |              \_|
     /______                       | | \)____(/ | |                      ______\                                 |  ||     (| =-_   _.-=-  |~)        ,
            )                      |  \ |/vv\| /  |                     (                                        |  ||      | `~~ |   ~~'  |/~-._-'/'/_,
           /                      /    | |  | |    \                     \                                       |  ||       \    |        /~-.__---~ , ,
          /                      /     ||\^^/||     \                     \                                      |  ||       |   ~-''     || `\_~~~----~
         /                      /     / \====/ \     \                     \                                     |  ||_.ssSS$$\ -====-   / )\_  ~~--~
        /_______           ____/      \________/      \____           ______\                            ___.----|~~~|%$$$$$$/ \_    _.-~ /' )$s._
                )         /   |       |  ____  |       |   \         (                          __---~-~~        |   |%%$$$$/ /  ~~~~   /'  /$$$$$$$s__
                |       /     |       \________/       |     \       |                       /~       ~\    ============$$/ /        /'  /$$$$$$$$$$$SS-.
                |     /       |       |  ____  |       |       \     |                      /'      ./\\\\\\_( ~---._(_))$/ /       /'  /$$$$%$$$$$~      \
                |   /         |       \________/       |         \   |                      (      //////////(~-(..___)/$/ /      /'  /$$%$$%$$$$'         \
                | /            \      \ ______ /      /______..    \ |                       \    |||||||||||(~-(..___)$/ /  /  /'  /$$$%$$$%$$$            |
                /              |      \\______//      |        \     \                        `-__ \\\\\\\\\\\(-.(_____) /  / /'  /$$$$%$$$$$%$             |
                               |       \ ____ /       |LLLLL/_  \                                 ~~""""""""""-\.(____) /   /'  /$$$$$%%$$$$$$\_            /
                               |      / \____/ \      |      \   |                                              $|===|||  /'  /$$$$$$$%%%$$$$$( ~         ,'|
                               |     / / \__/ \ \     |     __\  /__                                        __  $|===|%\/'  /$$$$$$$$$$$%%%%$$|        ,''  |
                               |    | |        | |    |     \      /                                       ///\ $|===|/'  /$$$$$$%$$$$$$$%%%%$(            /'
                               |    | |        | |    |      \    /                                         \///\|===|  /$$$$$$$$$%%$$$$$$%%%%$\_-._       |
                               |    |  \      /  |    |       \  /                                           `\//|===| /$$$$$$$$$$$%%%$$$$$$-~~~    ~      /
                               |     \__\    /__/     |        \/                                             `\|-~~(~~-`$$$$$$$$$%%%///////._       ._  |
                              /    ___\  )  (  /___    \                                                       (__--~(     ~\\\\\\\\\\\\\\\\\\\\        \ \
                             |/\/\|    )      (    |/\/\|                                                      (__--~~(       \\\\\\\\\\\\\\\\\\|        \/
                             ( (  )                (  ) )                                                       (__--~(       ||||||||||||||||||/       _/
                                ▄▄▄▄▄▄▄ ▄ ▄▄▄ ▄▄▄▄▄▄▄                                                            (__.--._____//////////////////__..---~~
                                █ ▄▄▄ █ ▄▄▀█  █ ▄▄▄ █ 
                                █ ███ █ █▀ ▄▀ █ ███ █ 
                                █▄▄▄▄▄█ ▄▀█▀█ █▄▄▄▄▄█ 
                                ▄▄▄▄  ▄ ▄▄▄██▄  ▄▄▄ ▄ 
                                ▄▄▄ ▀ ▄ ▄█▄█▀█ ▄▀▄█▀█ 
                                █ █▄█ ▄██▄▀▀▄ ▄ ▀█ █▀ 
                                ▄▄▄▄▄▄▄ ▀█▀█▄▀▄██▀    
                                █ ▄▄▄ █   ▄ ▄█ ▄ ▄█▀▀ 
                                █ ███ █ █▄█ ▄▀▄  ▀▀▀  
                                █▄▄▄▄▄█ █▄  ███▄▀ ▄ ▀                                                                     
                                                                                                              
                                                                                                                                              
 */                                                                                         
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return a / b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}
contract F2PNetwork {

    string public name = "F2P Network";      //  token name
    string public symbol = "F2P";           //  token symbol
    uint256 public decimals = 6;            //  token digit

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    uint256 public totalSupply = 0;
    bool public stopped = false;

    uint256 constant valueFounder = 990000000000000;
    address owner = 0x0;

    modifier isOwner {
        assert(owner == msg.sender);
        _;
    }

    modifier isRunning {
        assert (!stopped);
        _;
    }

    modifier validAddress {
        assert(0x0 != msg.sender);
        _;
    }

    function F2Pchain(address _addressFounder) {
        owner = msg.sender;
        totalSupply = valueFounder;
        balanceOf[_addressFounder] = valueFounder;
        Transfer(0x0, _addressFounder, valueFounder);
    }

    function transfer(address _to, uint256 _value) isRunning validAddress returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) isRunning validAddress returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        require(allowance[_from][msg.sender] >= _value);
        balanceOf[_to] += _value;
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) isRunning validAddress returns (bool success) {
        require(_value == 0 || allowance[msg.sender][_spender] == 0);
        allowance[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function stop() isOwner {
        stopped = true;
    }

    function start() isOwner {
        stopped = false;
    }

    function setName(string _name) isOwner {
        name = _name;
    }

    function burn(uint256 _value) {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[0x0] += _value;
        Transfer(msg.sender, 0x0, _value);
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}
