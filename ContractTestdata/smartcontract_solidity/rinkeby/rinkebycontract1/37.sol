/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity 0.5.4;
/**
 * @author Band Protocol
 *
 * @dev Example contract to illustrate Band Protocol's Equation Library.
 * DO NOT USE IT IN PRODUCTION. The contract is not fully auditted, and
 * is likely susceptible to common attacks such as front running. 
 */

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
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
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

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

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract ERC20 is IERC20 {
  using SafeMath for uint256;

  mapping (address => uint256) private _balances;

  mapping (address => mapping (address => uint256)) private _allowed;

  uint256 private _totalSupply;

  /**
  * @dev Total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return _totalSupply;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param owner The address to query the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address owner) public view returns (uint256) {
    return _balances[owner];
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param owner address The address which owns the funds.
   * @param spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(
    address owner,
    address spender
   )
    public
    view
    returns (uint256)
  {
    return _allowed[owner][spender];
  }

  /**
  * @dev Transfer token for a specified address
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function transfer(address to, uint256 value) public returns (bool) {
    _transfer(msg.sender, to, value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param spender The address which will spend the funds.
   * @param value The amount of tokens to be spent.
   */
  function approve(address spender, uint256 value) public returns (bool) {
    require(spender != address(0));

    _allowed[msg.sender][spender] = value;
    emit Approval(msg.sender, spender, value);
    return true;
  }

  /**
   * @dev Transfer tokens from one address to another
   * @param from address The address which you want to send tokens from
   * @param to address The address which you want to transfer to
   * @param value uint256 the amount of tokens to be transferred
   */
  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    public
    returns (bool)
  {
    require(value <= _allowed[from][msg.sender]);

    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
    _transfer(from, to, value);
    return true;
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param addedValue The amount of tokens to increase the allowance by.
   */
  function increaseAllowance(
    address spender,
    uint256 addedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].add(addedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   * approve should be called when allowed_[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param spender The address which will spend the funds.
   * @param subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseAllowance(
    address spender,
    uint256 subtractedValue
  )
    public
    returns (bool)
  {
    require(spender != address(0));

    _allowed[msg.sender][spender] = (
      _allowed[msg.sender][spender].sub(subtractedValue));
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);
    return true;
  }

  /**
  * @dev Transfer token for a specified addresses
  * @param from The address to transfer from.
  * @param to The address to transfer to.
  * @param value The amount to be transferred.
  */
  function _transfer(address from, address to, uint256 value) internal {
    require(value <= _balances[from]);
    require(to != address(0));

    _balances[from] = _balances[from].sub(value);
    _balances[to] = _balances[to].add(value);
    emit Transfer(from, to, value);
  }

  /**
   * @dev Internal function that mints an amount of the token and assigns it to
   * an account. This encapsulates the modification of balances such that the
   * proper events are emitted.
   * @param account The account that will receive the created tokens.
   * @param value The amount that will be created.
   */
  function _mint(address account, uint256 value) internal {
    require(account != address(0));
    _totalSupply = _totalSupply.add(value);
    _balances[account] = _balances[account].add(value);
    emit Transfer(address(0), account, value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burn(address account, uint256 value) internal {
    require(account != address(0));
    require(value <= _balances[account]);

    _totalSupply = _totalSupply.sub(value);
    _balances[account] = _balances[account].sub(value);
    emit Transfer(account, address(0), value);
  }

  /**
   * @dev Internal function that burns an amount of the token of a given
   * account, deducting from the sender's allowance for said account. Uses the
   * internal burn function.
   * @param account The account whose tokens will be burnt.
   * @param value The amount that will be burnt.
   */
  function _burnFrom(address account, uint256 value) internal {
    require(value <= _allowed[account][msg.sender]);

    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,
    // this function needs to emit an event with the updated approval.
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(
      value);
    _burn(account, value);
  }
}

// File: contracts/Equation.sol

/**
 * @title Equation
 *
 * @dev Equation library abstracts the representation of mathematics equation.
 * As of current, an equation is basically an expression tree of constants,
 * one variable (X), and operators.
 */
library Equation {
  using SafeMath for uint256;

  /**
   * @dev An expression tree is encoded as a set of nodes, with root node having
   * index zero. Each node consists of 3 values:
   *  1. opcode: the expression that the node represents. See table below.
   * +--------+----------------------------------------+------+------------+
   * | Opcode |              Description               | i.e. | # children |
   * +--------+----------------------------------------+------+------------+
   * |   00   | Integer Constant                       |   c  |      0     |
   * |   01   | Variable                               |   X  |      0     |
   * |   02   | Arithmetic Square Root                 |   √  |      1     |
   * |   03   | Boolean Not Condition                  |   !  |      1     |
   * |   04   | Arithmetic Addition                    |   +  |      2     |
   * |   05   | Arithmetic Subtraction                 |   -  |      2     |
   * |   06   | Arithmetic Multiplication              |   *  |      2     |
   * |   07   | Arithmetic Division                    |   /  |      2     |
   * |   08   | Arithmetic Exponentiation              |  **  |      2     |
   * |   09   | Arithmetic Equal Comparison            |  ==  |      2     |
   * |   10   | Arithmetic Non-Equal Comparison        |  !=  |      2     |
   * |   11   | Arithmetic Less-Than Comparison        |  <   |      2     |
   * |   12   | Arithmetic Greater-Than Comparison     |  >   |      2     |
   * |   13   | Arithmetic Non-Greater-Than Comparison |  <=  |      2     |
   * |   14   | Arithmetic Non-Less-Than Comparison    |  >=  |      2     |
   * |   15   | Boolean And Condition                  |  &&  |      2     |
   * |   16   | Boolean Or Condition                   |  ||  |      2     |
   * |   17   | Ternary Operation                      |  ?:  |      3     |
   * +--------+----------------------------------------+------+------------+
   *  2. children: the list of node indices of this node's sub-expressions.
   *  Different opcode nodes will have different number of children.
   *  3. value: the value inside the node. Currently this is only relevant for
   *  Integer Constant (Opcode 00).
   *
   * An equation's data is a list of nodes. The nodes will link against
   * each other using index as pointer. The root node of the expression tree
   * is the first node in the list
   */
  struct Node {
    uint8 opcode;
    uint8 child0;
    uint8 child1;
    uint8 child2;
    uint256 value;
  }

  /**
   * @dev An internal struct to keep track of expression type. This is to make
   * sure than the given equation type-checks.
   */
  enum ExprType {
    Invalid,
    Math,
    Boolean
  }

  uint8 constant OPCODE_CONST = 0;
  uint8 constant OPCODE_VAR = 1;
  uint8 constant OPCODE_SQRT = 2;
  uint8 constant OPCODE_NOT = 3;
  uint8 constant OPCODE_ADD = 4;
  uint8 constant OPCODE_SUB = 5;
  uint8 constant OPCODE_MUL = 6;
  uint8 constant OPCODE_DIV = 7;
  uint8 constant OPCODE_EXP = 8;
  uint8 constant OPCODE_EQ = 9;
  uint8 constant OPCODE_NE = 10;
  uint8 constant OPCODE_LT = 11;
  uint8 constant OPCODE_GT = 12;
  uint8 constant OPCODE_LE = 13;
  uint8 constant OPCODE_GE = 14;
  uint8 constant OPCODE_AND = 15;
  uint8 constant OPCODE_OR = 16;
  uint8 constant OPCODE_IF = 17;
  uint8 constant OPCODE_INVALID = 18;

  /**
   * @dev Initialize equation by array of opcodes/values in prefix order. Array
   * is read as if it is the *pre-order* traversal of the expression tree.
   * For instance, expression x^2 - 3 is encoded as: [5, 8, 1, 0, 2, 0, 3]
   *
   *                 5 (Opcode -)
   *                    /  \
   *                   /     \
   *                /          \
   *         8 (Opcode **)       \
   *             /   \             \
   *           /       \             \
   *         /           \             \
   *  1 (Opcode X)  0 (Opcode c)  0 (Opcode c)
   *                     |              |
   *                     |              |
   *                 2 (Value)     3 (Value)
   *
   * @param self storage pointer to equation data to initialize.
   * @param _expressions array of opcodes/values to initialize.
   */
  function init(Node[] storage self, uint256[] memory _expressions) internal {
    // Init should only be called when the equation is not yet initialized.
    assert(self.length == 0);

    // Limit expression length to < 256 to make sure gas cost is managable.
    require(_expressions.length < 256);

    for (uint8 idx = 0; idx < _expressions.length; ++idx) {
      // Get the next opcode. Obviously it must be within the opcode range.
      uint256 opcode = _expressions[idx];
      require(opcode < OPCODE_INVALID);

      Node memory node;
      node.opcode = uint8(opcode);

      // Get the node's value. Only applicable on Integer Constant case.
      if (opcode == OPCODE_CONST) {
        node.value = _expressions[++idx];
      }

      self.push(node);
    }

    // Actual code to create the tree. We also assert and the end that all
    // of the provided expressions are exhausted.
    (uint8 lastNodeIndex,) = populateTree(self, 0);
    require(lastNodeIndex == self.length - 1);
  }

  /**
   * @dev Clear the existing equation. Must be called prior to init of the tree
   * has already been initialized.
   */
  function clear(Node[] storage self) internal {
    assert(self.length < 256);

    for (uint8 idx = 0; idx < self.length; ++idx) {
      delete self[idx];
    }

    self.length = 0;
  }

  /**
   * @dev Calculate the Y position from the X position for this equation.
   */
  function calculate(Node[] storage self, uint256 xValue)
    internal
    view
    returns (uint256)
  {
    return solveMath(self, 0, xValue);
  }

  /**
   * @dev Return the number of children the given opcode node has.
   */
  function getChildrenCount(uint8 opcode) private pure returns (uint8) {
    if (opcode <= OPCODE_VAR) {
      return 0;
    } else if (opcode <= OPCODE_NOT) {
      return 1;
    } else if (opcode <= OPCODE_OR) {
      return 2;
    } else if (opcode <= OPCODE_IF) {
      return 3;
    } else {
      assert(false);
    }
  }

  /**
   * @dev Check whether the given opcode and list of expression types match.
   * Execute revert EVM opcode on failure.
   * @return The type of this expression itself.
   */
  function checkExprType(uint8 opcode, ExprType[] memory types)
    private
    pure
    returns (ExprType)
  {
    if (opcode <= OPCODE_VAR) {
      return ExprType.Math;

    } else if (opcode == OPCODE_SQRT) {
      require(types[0] == ExprType.Math);
      return ExprType.Math;

    } else if (opcode == OPCODE_NOT) {
      require(types[0] == ExprType.Boolean);
      return ExprType.Boolean;

    } else if (opcode >= OPCODE_ADD && opcode <= OPCODE_EXP) {
      require(types[0] == ExprType.Math);
      require(types[1] == ExprType.Math);
      return ExprType.Math;

    } else if (opcode >= OPCODE_EQ && opcode <= OPCODE_GE) {
      require(types[0] == ExprType.Math);
      require(types[1] == ExprType.Math);
      return ExprType.Boolean;

    } else if (opcode >= OPCODE_AND && opcode <= OPCODE_OR) {
      require(types[0] == ExprType.Boolean);
      require(types[1] == ExprType.Boolean);
      return ExprType.Boolean;

    } else if (opcode == OPCODE_IF) {
      require(types[0] == ExprType.Boolean);
      require(types[1] != ExprType.Invalid);
      require(types[1] == types[2]);
      return types[1];

    }
  }

  /**
   * @dev Helper function to recursively populate node information following
   * the given pre-order node list. It inspects the opcode and recursively
   * call populateTree(s) accordingly.
   *
   * @param self storage pointer to equation data to build tree.
   * @param currentNodeIndex the index of the current node to populate info.
   * @return An (uint8, bool). The first value represents the last
   * (highest/rightmost) node ndex of the current subtree. The second value
   * indicates the type that one would get from evaluating this subtree.
   */
  function populateTree(Node[] storage self, uint8 currentNodeIndex)
    private
    returns (uint8, ExprType)
  {
    require(currentNodeIndex < self.length);
    Node storage node = self[currentNodeIndex];

    uint8 opcode = node.opcode;
    uint8 childrenCount = getChildrenCount(opcode);

    ExprType[] memory childrenTypes = new ExprType[](childrenCount);
    uint8 lastNodeIndex = currentNodeIndex;

    for (uint8 idx = 0; idx < childrenCount; ++idx) {
      if (idx == 0) {
        node.child0 = lastNodeIndex + 1;
      } else if (idx == 1) {
        node.child1 = lastNodeIndex + 1;
      } else if (idx == 2) {
        node.child2 = lastNodeIndex + 1;
      } else {
        assert(false);
      }

      (lastNodeIndex, childrenTypes[idx]) = populateTree(self, lastNodeIndex + 1);
    }

    ExprType exprType = checkExprType(opcode, childrenTypes);
    return (lastNodeIndex, exprType);
  }


  /**
   * @dev Calculate the arithmetic value of this sub-expression at the given
   * X position.
   */
  function solveMath(Node[] storage self, uint8 nodeIdx, uint256 xValue)
    private
    view
    returns (uint256)
  {
    Node storage node = self[nodeIdx];
    uint8 opcode = node.opcode;

    if (opcode == OPCODE_CONST) {
      return node.value;
    } else if (opcode == OPCODE_VAR) {
      return xValue;
    } else if (opcode == OPCODE_SQRT) {
      uint256 childValue = solveMath(self, node.child0, xValue);
      uint256 temp = childValue.add(1).div(2);
      uint256 result = childValue;

      while (temp < result) {
        result = temp;
        temp = childValue.div(temp).add(temp).div(2);
      }

      return result;

    } else if (opcode >= OPCODE_ADD && opcode <= OPCODE_EXP) {

      uint256 leftValue = solveMath(self, node.child0, xValue);
      uint256 rightValue = solveMath(self, node.child1, xValue);

      if (opcode == OPCODE_ADD) {
        return leftValue.add(rightValue);
      } else if (opcode == OPCODE_SUB) {
        return leftValue.sub(rightValue);
      } else if (opcode == OPCODE_MUL) {
        return leftValue.mul(rightValue);
      } else if (opcode == OPCODE_DIV) {
        return leftValue.div(rightValue);
      } else if (opcode == OPCODE_EXP) {
        uint256 power = rightValue;
        uint256 expResult = 1;
        for (uint256 idx = 0; idx < power; ++idx) {
          expResult = expResult.mul(leftValue);
        }
        return expResult;
      }
    } else if (opcode == OPCODE_IF) {
      bool condValue = solveBool(self, node.child0, xValue);
      if (condValue) {
        return solveMath(self, node.child1, xValue);
      } else {
        return solveMath(self, node.child2, xValue);
      }
    }

    assert(false);
  }

  /**
   * @dev Calculate the arithmetic value of this sub-expression.
   */
  function solveBool(Node[] storage self, uint8 nodeIdx, uint256 xValue)
    private
    view
    returns (bool)
  {
    Node storage node = self[nodeIdx];
    uint8 opcode = node.opcode;

    if (opcode == OPCODE_NOT) {
      return !solveBool(self, node.child0, xValue);
    } else if (opcode >= OPCODE_EQ && opcode <= OPCODE_GE) {

      uint256 leftValue = solveMath(self, node.child0, xValue);
      uint256 rightValue = solveMath(self, node.child1, xValue);

      if (opcode == OPCODE_EQ) {
        return leftValue == rightValue;
      } else if (opcode == OPCODE_NE) {
        return leftValue != rightValue;
      } else if (opcode == OPCODE_LT) {
        return leftValue < rightValue;
      } else if (opcode == OPCODE_GT) {
        return leftValue > rightValue;
      } else if (opcode == OPCODE_LE) {
        return leftValue <= rightValue;
      } else if (opcode == OPCODE_GE) {
        return leftValue >= rightValue;
      }
    } else if (opcode >= OPCODE_AND && opcode <= OPCODE_OR) {

      bool leftBoolValue = solveBool(self, node.child0, xValue);
      bool rightBoolValue = solveBool(self, node.child1, xValue);

      if (opcode == OPCODE_AND) {
        return leftBoolValue && rightBoolValue;
      } else if (opcode == OPCODE_OR) {
        return leftBoolValue || rightBoolValue;
      }
    } else if (opcode == OPCODE_IF) {
      bool condValue = solveBool(self, node.child0, xValue);
      if (condValue) {
        return solveBool(self, node.child1, xValue);
      } else {
        return solveBool(self, node.child2, xValue);
      }
    }

    assert(false);
  }
}

// File: contracts/mock/BondingCurveTokenDemo.sol
contract BondingCurveDemoToken is ERC20 {
  using Equation for Equation.Node[];
  using SafeMath for uint256;

  string public constant name = "BondingCurveDemoToken";
  string public constant symbol = "BCDT";
  uint256 public constant decimals = 18;

  // Equation of the collateral bonding curve that controls how this contract
  // issues new tokens to the system.
  Equation.Node[] equation;

  constructor(uint256[] memory expressions) public {
    equation.init(expressions);
  }
  
  function getCollateralAtSupply(uint256 supply) public view returns (uint256) {
     return equation.calculate(supply);
  }

  /**
   * @dev Buy 'amount' of BCDT with ether. Excessive ether will get refunded.
   */
  function buy(uint256 amount) public payable {
    uint256 collateralChange = equation.calculate(
      totalSupply().add(amount)
    ).sub(equation.calculate(
      totalSupply())
    );
    require(msg.value >= collateralChange);
    _mint(msg.sender, amount);
    if (msg.value > collateralChange) {
      msg.sender.transfer(msg.value.sub(collateralChange));
    }
  }
  
  /**
   * @dev Sell 'amount' of BCDT back to ether.
   */
  function sell(uint256 amount) public {
    require(balanceOf(msg.sender) >= amount);
    uint256 collateralChange = equation.calculate(
      totalSupply()
    ).sub(equation.calculate(
      totalSupply().sub(amount))
    );
    _burn(msg.sender, amount);
    msg.sender.transfer(collateralChange);
  }
}
