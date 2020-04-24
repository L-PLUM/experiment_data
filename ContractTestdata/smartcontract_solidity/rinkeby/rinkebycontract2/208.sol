/**
 *Submitted for verification at Etherscan.io on 2019-08-05
*/

pragma solidity ^0.4.16;

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }

/**
 * 标准 ERC-20 合约
 */
contract ERC_20 {
    //- Token 名称
    string public name; 
    //- Token 符号
    string public symbol;
    //- Token 小数位
    uint8 public decimals;
    //- Token 总发行量
    uint256 public totalSupply;

    //- 地址映射关系
    mapping (address => uint256) public balanceOf;
    //- 地址对应 Token
    mapping (address => mapping (address => uint256)) public allowance;

    //- Token 交易通知事件
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    //- Token 批准通知事件
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    /**
     * 构造函数
     *
     * 初始化一个合约
     * @param initialSupplyHM 初始总量（单位亿）
     * @param tokenName Token 名称
     * @param tokenSymbol Token 符号
     * @param tokenDecimals Token 小数位
     */
    constructor(uint256 initialSupplyHM, string tokenName, string tokenSymbol, uint8 tokenDecimals) public {
        name = tokenName;
        symbol = tokenSymbol;
        decimals = tokenDecimals;
        totalSupply = initialSupplyHM * 10000 * 10000 * 10 ** uint256(decimals);
        
        balanceOf[msg.sender] = totalSupply;
    }

    /**
     * 从持有方转移指定数量的 Token 给接收方
     * @param _from 持有方
     * @param _to 接收方
     * @param _value 数量
     */
    function _transfer(address _from, address _to, uint256 _value) internal {
        //- 地址有效验证
        require(_to != 0x0, "无效接收地址");
        //- 非负数验证
        require(_value > 0, "无效数量");
        //- 余额验证
        require(balanceOf[_from] >= _value, "持有方转移数量不足");

        //- 保存预校验总量
        uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
        //- 持有方减少代币
        balanceOf[_from] -= _value;
        //- 接收方增加代币
        balanceOf[_to] += _value;
        //- 触发转账事件
        emit Transfer(_from, _to, _value);
        //- 确保交易过后，持有方和接收方持有总量不变
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * 转移转指定数量的 Token 给接收方
     *
     * @param _to 接收方地址
     * @param _value 数量
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * 从持有方转移指定数量的 Token 给接收方
     *
     * @param _from 持有方
     * @param _to 接收方
     * @param _value 数量
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        //- 授权额度校验
        require(_value <= allowance[_from][msg.sender], "授权额度不足");

        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * 授权指定地址的转移额度
     *
     * @param _spender 代理方
     * @param _value 授权额度
     */
    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function() payable public{
    }
}
