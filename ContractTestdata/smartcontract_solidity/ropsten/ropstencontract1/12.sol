/**
 *Submitted for verification at Etherscan.io on 2019-02-23
*/

pragma solidity 0.4.25;


contract ERC20 {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function allowance(address owner, address spender) public view returns (uint256);
    function approve(address spender, uint256 value) public returns (bool);

    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
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

contract StandardToken is ERC20 {
    using SafeMath for uint256;
    mapping (address => uint256) internal balances;
    uint256 public totalSupply_;
    mapping (address => mapping (address => uint256)) internal allowed;

    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    function balanceOf(address who) public view returns (uint256) {
        return balances[who];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(to != address(0));
        require(value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(value);
        balances[to] = balances[to].add(value);
        emit Transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {
        require(to != address(0));
        require(value <= balances[from]);
        require(value <= allowed[from][msg.sender]);
        balances[from] = balances[from].sub(value);
        balances[to] = balances[to].add(value);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(value);
        emit Transfer(from, to, value);
        return  true;
    }

    function allowance(address owner, address spender) public view returns (uint256) {
        return allowed[owner][spender];
    }

    function approve(address spender, uint256 value) public returns (bool) {
        allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function increaseApproval(address spender, uint256 value) public returns (bool) {
        allowed[msg.sender][spender] = allowed[msg.sender][spender].add(value);
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }

    function decreaseApproval(address spender, uint256 value) public returns (bool) {
        uint256 oldValue = allowed[msg.sender][spender];
        if (value > oldValue)
            allowed[msg.sender][spender] = 0;
        else
            allowed[msg.sender][spender] = allowed[msg.sender][spender].sub(value);
        emit Approval(msg.sender, spender, allowed[msg.sender][spender]);
        return true;
    }
}


contract BWToken is StandardToken {
    string public name;
    string public symbol;
    string public version;
    uint256 public decimals;

    uint256 public initialPrice;
    uint256 public initialPrice2;
    address public fundHolder;
    uint256 public constant WEIS_IN_ETHER = 1e18;

    event Burned(string text, uint256 value);

    constructor() public {
        name = "BW-Fund";
        symbol = "BWT";
        version = "1.0";
        decimals = 4;
        totalSupply_ = 5000000000 * 10 ** decimals;
        fundHolder = msg.sender;
        initialPrice = 1; // 1/3000 Ether per 1 RLD
        initialPrice2 = 3000; // 1/3000 Ether per 1 RLD
        balances[fundHolder] = totalSupply_;
    }

    function() public payable {
        buyToken();
    }

    function buyToken() public payable {
        require(msg.sender != fundHolder);
        uint256 tokenAmount = msg.value * 10**decimals / WEIS_IN_ETHER / initialPrice * initialPrice2;
        require(balances[fundHolder] >= tokenAmount);
        balances[fundHolder] = balances[fundHolder].sub(tokenAmount);
        balances[msg.sender] = balances[msg.sender].add(tokenAmount);
        emit Transfer(fundHolder, msg.sender, tokenAmount);
        fundHolder.transfer(msg.value);
    }

    function burnToken(uint256 value) public {
        uint256 tokenAmount = value * 10**decimals;
        require(balances[fundHolder] >= tokenAmount);
        require(msg.sender == fundHolder);
        balances[fundHolder] = balances[fundHolder].sub(tokenAmount);
        totalSupply_ = totalSupply_.sub(tokenAmount);
        emit Burned("Burned", tokenAmount);
    }
}
