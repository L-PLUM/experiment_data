/**
 *Submitted for verification at Etherscan.io on 2019-02-14
*/

pragma solidity ^0.4.24;

// File: libs/TransferAgentControlled.sol

contract TransferAgentControlled {
    address public transferAgent;

    constructor(address _initialTransferAgent) public {
        transferAgent = _initialTransferAgent;
    }

    modifier onlyTransferAgent() {
        require(msg.sender == transferAgent, "Only Transfer Agent can perform this action.");
        _;
    }

    function isTransferAgent(address _lookup) public view returns (bool) {
        return _lookup == transferAgent;
    }
}

// File: libs/Owned.sol

contract Owned {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor(address _initialOwner) public {
        owner = _initialOwner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only current owner can perform this action.");
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {
        require(_newOwner != address(0), "New owner cannot be null.");
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

// File: libs/IssuerControlled.sol

contract IssuerControlled {
    address public issuer;

    constructor(address _issuer) public {
        issuer = _issuer;
    }

    // look up TransferAgent role of the issuer
    modifier onlyIssuerTransferAgent() {
        LDGRIssuer c = LDGRIssuer(issuer);
        require(c.isTransferAgent(msg.sender), "Only Transfer Agent can perform this action.");
        _;
    }
}

// File: libs/openzeppelin/math/SafeMath.sol

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

// File: contracts/LDGRToken.sol

/*
Interface for LDGR
*/



contract LDGRToken is IssuerControlled {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint256 public issuanceNumber;
    mapping(address => uint256) balances;
    uint256 public totalSupply;
    uint8 public decimals;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 value
    );

    event Mint(
        address indexed to,
        uint256 value
    );

    event Burn(
        address indexed who,
        uint256 value
    );

    constructor(
        address _issuer,
        string _name,
        string _symbol,
        uint256 _issuanceNumber
    ) IssuerControlled(_issuer) public {
        name = _name;
        symbol = _symbol;
        issuanceNumber = _issuanceNumber;
        decimals = 0;
    }

    function balanceOf(address _investor) public view returns (uint256) {
        return balances[_investor];
    }

    function transferFrom(address _from, address _to, uint256 _value) public onlyIssuerTransferAgent returns (bool) {
        require(_value <= balances[_from], "Not enough balance.");
        require(_to != address(0), "_to is not valid.");
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function mint(address _to, uint256 _value) public onlyIssuerTransferAgent returns (bool) {
        require(_to != address(0), "_to is not valid.");
        balances[_to] = balances[_to].add(_value);
        totalSupply = totalSupply.add(_value);
        //emit Mint(_to, _value);
        emit Transfer(address(0), _to, _value);
        return true;
    }

    function burnFrom(address _who, uint256 _value) public onlyIssuerTransferAgent returns (bool) {
        require(_value <= balances[_who], "_value cannot be greater than balance.");
        balances[_who] = balances[_who].sub(_value);
        totalSupply = totalSupply.sub(_value);
        //emit Burn(_who, _value);
        emit Transfer(_who, address(0), _value);
        return true;
    }
}

// File: contracts/LDGRSecurity.sol

contract LDGRSecurity is IssuerControlled {
    string public name;
    string public symbol;
    address public token; // main token 0
    address[] tokens; // all tokens

    event CreateToken(
        address indexed newToken,
        uint256 indexed issuanceNumber
    );

    constructor (
        address _issuer,
        string _name,
        string _symbol
    ) IssuerControlled(_issuer) public {
        name = _name;
        symbol = _symbol;
        token = new LDGRToken(_issuer, _name, _symbol, 0);
        tokens.push(token);
        emit CreateToken(token, 0);
    }

    function getAllTokens() public view returns (address[]) {
        return tokens;
    }

    function createToken(uint256 _issuanceNumber) public onlyIssuerTransferAgent returns (address) {
        return _createToken(_issuanceNumber);
    }

    function _createToken(uint256 _issuanceNumber) internal returns (address) {
        LDGRToken newToken = new LDGRToken(issuer, name, symbol, _issuanceNumber);
        tokens.push(newToken);
        emit CreateToken(newToken, _issuanceNumber);
        return newToken;
    }
}

// File: contracts/LDGRIssuer.sol

contract LDGRIssuer is Owned, TransferAgentControlled {
    string public name;
    string public stateFileNumber;
    string public stateOfIncorporation;
    string public physicalAddressOfOperation;
    address[] securities;

    event CreateSecurity(
        address indexed newSecurity,
        string name,
        string symbol
    );

    event TransferAgentUpdated(
        address indexed previousTransferAgent,
        address indexed newTransferAgent
    );

    event PhysicalAddressOfOperationUpdated(
        string previousPhysicalAddressOfOperation,
        string newPhysicalAddressOfOperation
    );

    constructor (
        address _initialOwner,
        address _initialTransferAgent,
        string _name,
        string _stateFileNumber,
        string _stateOfIncorporation,
        string _physicalAddressOfOperation
    ) Owned(_initialOwner) TransferAgentControlled(_initialTransferAgent) public {
        name = _name;
        stateFileNumber = _stateFileNumber;
        stateOfIncorporation = _stateOfIncorporation;
        physicalAddressOfOperation = _physicalAddressOfOperation;
    }

    function setTransferAgent(address _newTransferAgent) public onlyOwner {
        _setTransferAgent(_newTransferAgent);
    }

    function setPhysicalAddressOfOperation(string _newPhysicalAddressOfOperation) public onlyOwner {
        _setPhysicalAddressOfOperation(_newPhysicalAddressOfOperation);
    }

    function _setPhysicalAddressOfOperation(string _newPhysicalAddressOfOperation) internal {
        emit PhysicalAddressOfOperationUpdated(physicalAddressOfOperation, _newPhysicalAddressOfOperation);
        physicalAddressOfOperation = _newPhysicalAddressOfOperation;
    }

    function _setTransferAgent(address _newTransferAgent) internal {
        require(_newTransferAgent != address(0), "Address cannot be 0.");
        emit TransferAgentUpdated(transferAgent, _newTransferAgent);
        transferAgent = _newTransferAgent;
    }

    function getSecurities() public view returns (address[]) {
        return securities;
    }

    function createSecurity(string _name, string _symbol) public onlyTransferAgent returns (address) {
        return _createSecurity(_name, _symbol);
    }

    function _createSecurity(string _name, string _symbol) internal returns (address) {
        address newSecurity = new LDGRSecurity(this, _name, _symbol);
        securities.push(newSecurity);
        emit CreateSecurity(newSecurity, _name, _symbol);
        return newSecurity;
    }
}
