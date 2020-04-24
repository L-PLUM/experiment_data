pragma solidity ^0.5.0;

//import 'openzeppelin-solidity/contracts/math/SafeMath.sol';
//import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';
import './SafeMath.sol';
import './Ownable.sol';
import './IBadERC20.sol';

contract WithStablecoins is Ownable {
    using SafeMath for uint256;

    mapping (address => bool) _tokens;

    event AddedStablecoin(address indexed token);
    event RemovedStablecoin(address indexed token);

    function supportStablecoin(address token) external onlyOwner {
        require(token != address(0), 'token address must be != 0');

        if (_tokens[token]) {
            return;
        }

        _tokens[token] = true;
        emit AddedStablecoin(token);
    }

    function unsupportStablecoin(address token) external onlyOwner {
        if (!_tokens[token]) {
            return;
        }

        delete _tokens[token];
        emit RemovedStablecoin(token);
    }

    function isSupport(address token) public view returns (bool) {
        return _tokens[token];
    }

    function transferFrom(address token, address from, address to, uint256 dollar) internal {
        require(from != address(0), 'from address must be != 0');
        require(to != address(0), 'to address must be != 0');

        bool result;

        IBadERC20 erc20 = IBadERC20(token);
        uint decimals = erc20.decimals();

        uint256 value = dollar.mul(10 ** decimals);

        erc20.transferFrom(from, to, value);

        assembly {
            switch returndatasize()
                case 0 {                      // This is a non-standard ERC-20
                    result := not(0)          // set result to true
                }
                case 32 {                     // This is a complaint ERC-20
                    returndatacopy(0, 0, 32)
                    result := mload(0)        // Set `result = returndata` of external call
                }
                default {                     // This is an excessively non-compliant ERC-20, revert.
                    revert(0, 0)
                }
        }

        require(
            result,
            "call transferFrom must be successed"
        );
    }
}

contract CKBContribution is WithStablecoins {
    using SafeMath for uint256;

    struct ContributionWithToken {
        address token;
        uint256 value;
    }

    uint constant public minPurchase = 100;
    uint constant public defaultQuota = 1000;

    uint256 constant public totalSupply = 28000000;
    uint256 private _totalPurchased = 0 ;

    address private _payee;
    bool private _started = false;

    mapping (address => uint256) private _purchased;
    mapping (address => uint256) private _redeemed;
    mapping (address => ContributionWithToken[]) private _purchasedWithToken;

    mapping (address => uint256) private _quota;
    mapping (address => bytes32) private _ckbAddress;

    event Purchase(address indexed purchaser, address indexed token, uint256 amount);
    event Redeem(address indexed purchaser, uint256 amount);
    event ChangePayee(address indexed oldPayee, address indexed newPayee);
    event SetQuota(address indexed purchaser, uint256 amount);

    constructor() public {
        _payee = msg.sender;
    }

    modifier whenStarted() {
        require(_started, 'must have been started');
        _;
    }

    function _max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }

    function _getRemainingQuota(address sender) internal view returns (uint256) {
        uint256 quota = _max(_quota[sender], defaultQuota);

        uint256 remainingQuota = _purchased[sender].add(_redeemed[sender]);
        if (remainingQuota > quota) {
            remainingQuota = 0;
        } else {
            remainingQuota = quota.sub(remainingQuota);
        }

        return remainingQuota;
    }

    function start() external onlyOwner {
        _started = true;
    }

    function stop() external onlyOwner {
        _started = false;
    }

    function changePayee(address payee) external onlyOwner {
        require(payee != address(0), 'payee must be != 0');

        if (_payee == payee) {
            return;
        }

        address old = _payee;
        _payee = payee;

        emit ChangePayee(old, payee);
    }

    function setQuota(address[] calldata purchasers, uint256[] calldata quotas) external onlyOwner {
        require(purchasers.length == quotas.length, 'length purchasers must be = length quotas');
        require(purchasers.length > 0, 'length purchasers must be > 0');

        for (uint i = 0; i < purchasers.length; i ++) {
           address purchaser = purchasers[i];
           uint256 quota = quotas[i];

           require(purchaser != address(0), 'purchaser address must be != 0');
           if (_quota[purchaser] == quota) {
               continue;
           }

           _quota[purchaser] = quota;

           emit SetQuota(purchaser, quota);
        }
    }

    function register(bytes32 ckbAddress) external whenStarted {
        if (_ckbAddress[msg.sender] != ckbAddress) {
           _ckbAddress[msg.sender] = ckbAddress;
        }
    }

    function purchase(address token, uint256 amount) external whenStarted {
        require(isSupport(token), 'token must be supported');
        require(amount >= minPurchase, 'purchase amount must be >= minimum');

        require(_totalPurchased.add(amount) <= totalSupply,
                'purchase amount must be <= total supply');
        require(_getRemainingQuota(msg.sender) >= amount,
                'purchase amount must be <= purchase quota');

        transferFrom(token, msg.sender, _payee, amount);

        _purchased[msg.sender] = _purchased[msg.sender].add(amount);
        _totalPurchased = _totalPurchased.add(amount);

        ContributionWithToken[] storage withTokens = _purchasedWithToken[msg.sender];

        bool found = false;
        for (uint i = 0; i < withTokens.length ; i ++) {
            if (withTokens[i].token == token) {
                withTokens[i].value = withTokens[i].value.add(amount);
                found = true;
            }
        }

        if (!found) {
            withTokens.push(ContributionWithToken(token, amount));
        }

        emit Purchase(msg.sender, token, amount);
    }

    function redeem(uint256 amount) external whenStarted {
        require(amount <= _purchased[msg.sender], 'redemption amount must be <= purchase amount');
        require(amount > 0, 'redemption amount must be > 0');

        uint256 total = amount;

        ContributionWithToken[] storage withTokens = _purchasedWithToken[msg.sender];

        for (uint i = 0; i < withTokens.length && total > 0; i ++) {
            uint256 tokenAmount = withTokens[i].value;

            if (tokenAmount == 0)  {
                continue;
            }

            if (tokenAmount <= total) {
                transferFrom(withTokens[i].token, _payee, msg.sender, tokenAmount);
                total = total.sub(tokenAmount);
                withTokens[i].value = 0;
            } else {
                transferFrom(withTokens[i].token, _payee, msg.sender, total);
                withTokens[i].value = tokenAmount.sub(total);
                total = 0;
            }
        }

        require(total == 0, 'the remainder must be = 0');

        _purchased[msg.sender] = _purchased[msg.sender].sub(amount);
        _redeemed[msg.sender] = _redeemed[msg.sender].add(amount);
        _totalPurchased = _totalPurchased.sub(amount);

        emit Redeem(msg.sender, amount);
    }

    function purchaserInfo(address purchaser) external view returns (uint256, uint256, uint256, uint256, bytes32) {
        return (_purchased[purchaser], _redeemed[purchaser], _max(_quota[purchaser], defaultQuota),
        _getRemainingQuota(purchaser), _ckbAddress[purchaser]);
    }

    function status() external view returns (bool, uint256, uint256) {
        return (_started, totalSupply, _totalPurchased);
    }

}
