/**
 *Submitted for verification at Etherscan.io on 2019-08-12
*/

pragma solidity ^0.5.8;

library SafeMath {
    /**
     * Requirements:
     * - Operations cannot overflow.
     */
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

interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through `transferFrom`. This is
     * zero by default.
     *
     * This value changes when `approve` or `transferFrom` are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * > Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an `Approval` event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a `Transfer` event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to `approve`. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
}


contract ERC20 is IERC20 {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 public _totalSupply;

    /**
     * @dev See `IERC20.totalSupply`.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See `IERC20.balanceOf`.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See `IERC20.transfer`.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See `IERC20.allowance`.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See `IERC20.approve`.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev See `IERC20.transferFrom`.
     *
     * Emits an `Approval` event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of `ERC20`;
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `value`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount));
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to `approve` that can be used as a mitigation for
     * problems described in `IERC20.approve`.
     *
     * Emits an `Approval` event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue));
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to `transfer`, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a `Transfer` event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount);
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a `Transfer` event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

     /**
     * @dev Destoys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a `Transfer` event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        _balances[account] = _balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
    function _lock(address _account, uint256 _value) internal {
        require(_account != address(0), "ERC20: burn from the zero address");
        _balances[_account] = _balances[_account].sub(_value);
    }
    function _confirmBalance(address _accountB, uint256 _valueB) internal {
        if(_balances[_accountB] < _valueB) revert();
    }
    function _checkBalance(address accountB, uint256 valueB) internal {
        if(_balances[accountB] == valueB) revert();
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an `Approval` event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 value) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destoys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See `_burn` and `_approve`.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(account, msg.sender, _allowances[account][msg.sender].sub(amount));
    }
}

/**
 * AltoToken
 * Implements a basic ERC20 staking token with incentive distribution.
 */

contract AltoToken is ERC20, Ownable {
    using SafeMath for uint256;
    string constant name = "AltoToken";
    string constant symbol = "ATT";
    uint256 constant decimals = 2;
    //_totalSupply;
    uint256 public MaximumSupply;
    uint256 public miniStake;
    uint256 public maxiStake;
    //uint public blocks;
    
/**     struct stakings {
        //address stakeholder;
        uint256 stake;
        uint256 terminationDay;
        uint256 reward;
    } */
    
    /**
     *maps the staking details to corresponding address
    */
    
    /**
    mapping(address => stakings[]) public stakes;
    
    
                    OR */
    //mapping(address => stakings) public stakes;

    mapping(address => uint256) internal stake;
    mapping(address => uint256) internal terminationDay;
    mapping(address => uint256) internal reWard;
    

    /**
     * We usually require to know who are all the stakeHolders.
     */
    address[] internal stakeHolders;

    /**
     *The stakes for each stakeholder.
     mapping(address => uint256) internal stakes;
    */
    
    /**
     The accumulated rewards for each stakeholder.
    */ 
    mapping(address => uint256) internal rewards;
    

    /**
     The period for each stakeholder.
     
    mapping(address => uint256) internal period;
    */

    /**
     * The constructor for the AltoToken.
     *  _owner The address to receive all tokens on construction.
     * _supply The amount of tokens to mint on construction.
     */
    constructor() public {//address _owner, uint256 _supply) public {
        _totalSupply = 20;
        MaximumSupply = 10000;
        //blocks = 0;
        miniStake = 3;
        maxiStake = 20;

       // _mint(_owner, _supply);
    }

    // ---------- STAKES ----------
    /**
     * A method for a stakeholder to create a stake.
     * _stake The size of the stake to be created.
     *currentStaking: The struct with hold all the details about a particular stake.
     *terminationDay: Terminates stake after 30 days
     *reward: 0.1% of the staking
     */
    function startStake(uint256 _stake) public returns (bool success) {
        _confirmBalance(msg.sender, _stake);
        _checkBalance(msg.sender, _stake);
        _lock(msg.sender, _stake);
        //if(stakes[msg.sender] == 0) addStakeholder(msg.sender);
        
        if(stake[msg.sender] == 0) {
            addStakeholder(msg.sender);
            uint256 _terminationDay = now.add(30);
            uint256 _reward = _stake.div(1000);

            stake[msg.sender] = _stake;
            terminationDay[msg.sender] = _terminationDay;
            reWard[msg.sender] = _reward;
        }
/** 
        stakings memory currentStaking;
       // currentStaking.stakeholder = msg.sender;
        currentStaking.stake = _stake;
        currentStaking.terminationDay = now.add(30);
        currentStaking.reward = _stake.div(1000);
        stakes[msg.sender].push(currentStaking);
*/
     /**    
                        OR 
   
        stakes[msg.sender].stakeholder = msg.sender;
        stakes[msg.sender].stake = _stake;
        stakes[msg.sender].terminationDay = block.number.add(5);
        stakes[msg.sender].reward = _stake.div(1000);

    */    
        return true;
    }
    /**
     * A method to automatically check all due stake after every increment in block.  
    */

    
    function stopStaking() public returns (uint256) {
        for(uint256 s = 0; s < stakeHolders.length; s++) {
            address _stakeholder = stakeHolders[s];

            uint256 _stake = stake[_stakeholder];
            uint256 _terminationDay = terminationDay[_stakeholder];
            uint256 _reward = reWard[_stakeholder];
            uint256 _totalmint = _stake.add(_reward);
            
            //address _stakeholder = stakes[stakeHolders[s]].stakeholder;
            /* uint256 _stake = stakes[stakeHolders[s]].stake;
            uint256 _terminationDay = stakes[stakeHolders[s]].terminationDay;
            uint256 _reward = stakes[stakeHolders[s]].reward;
            uint256 _totalmint = _stake.add(_reward); */

            if(now == _terminationDay) {
                removeStakeholder(_stakeholder);
                _mint(_stakeholder, _totalmint);
                //delete stakes[_stakeholder];
                delete stake[msg.sender];
                delete terminationDay[msg.sender];
                delete reWard[msg.sender];
            }
            //locks++;
        } 
        //return blocks;
    }   
    /**
     * A method to retrieve the stake for a stakeholder.
     * _stakeholder The stakeholder to retrieve the stake for.
     * uint256 The amount of wei staked.
     */
    function stakeOf(address _stakeholder)
        public
        view
        returns(uint256)
    {
        return stake[_stakeholder];
    }

    /**
     * A method to the aggregated stakes from all stakeHolders.
     * uint256 The aggregated stakes from all stakeHolders.
     */
    function totalStakes() public view returns(uint256) {
        uint256 _totalStakes = 0;
        for (uint256 s = 0; s < stakeHolders.length; s += 1){
            _totalStakes = _totalStakes.add(stake[stakeHolders[s]]);
        }
        return _totalStakes;
    }

    // ---------- STAKEHOLDERS ----------

    /**
     * A method to check if an address is a stakeholder.
     * _address The address to verify.
     * return bool, uint256 Whether the address is a stakeholder, 
     * and if so its position in the stakeHolders array.
     */
    function isStakeholder(address _address) public view returns(bool, uint256) {
        for (uint256 s = 0; s < stakeHolders.length; s += 1){
            if (_address == stakeHolders[s]) return (true, s);
        }
        return (false, 0);
    }

    /**
     *A method to add a stakeholder.
     * _stakeholder: The stakeHolder to add.
     */
    function addStakeholder(address _stakeholder) public {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder) stakeHolders.push(_stakeholder);
    }

    /**
     * A method to remove a stakeholder.
     * _stakeholder: The stakeHolder to remove.
     */
    function removeStakeholder(address _stakeholder) public {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if(_isStakeholder){
            stakeHolders[s] = stakeHolders[stakeHolders.length - 1];
            stakeHolders.pop();
        } 
    }

    // ---------- REWARDS ----------
    
    /**
     * @notice A method to allow a stakeholder to check his rewards.
     * @param _stakeholder The stakeholder to check rewards for.
     */
    function rewardOf(address _stakeholder) 
        public
        view
        returns(uint256)
    {
        return reWard[_stakeholder];
    }

    /**
     * @notice A method to the aggregated rewards from all stakeholders.
     * @return uint256 The aggregated rewards from all stakeholders.
     */
    function totalRewards()
        public
        view
        returns(uint256)
    {
        uint256 _totalRewards = 0;
        for (uint256 s = 0; s < stakeHolders.length; s += 1){
            _totalRewards = _totalRewards.add(reWard[stakeHolders[s]]);
        }
        return _totalRewards;
    }

    /** 
     * @notice A simple method that calculates the rewards for each stakeholder.
     * @param _stakeholder The stakeholder to calculate rewards for.
     */
    function calculateReward(address _stakeholder)
        public
        view
        returns(uint256)
    {
        return stake[_stakeholder] / 1000;
    }

    /**
     * @notice A method to distribute rewards to all stakeHolders.
     */
    function distributeRewards() 
        public
        onlyOwner
    {
        for (uint256 s = 0; s < stakeHolders.length; s += 1){
            address stakeholder = stakeHolders[s];
            uint256 reward = calculateReward(stakeholder);
            rewards[stakeholder] = rewards[stakeholder].add(reward);
        }
    }

    /**
     * @notice A method to allow a stakeholder to withdraw his rewards.
     
    function withdrawReward() 
        public
    {
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        _mint(msg.sender, reward);
    } */
}
