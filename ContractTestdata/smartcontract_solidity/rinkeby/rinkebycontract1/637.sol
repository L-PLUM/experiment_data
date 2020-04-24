/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

pragma solidity 0.5.2;

// File: contracts/ERC20Interface.sol

// https://github.com/ethereum/EIPs/issues/20
interface ERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}


contract ERC20WithSymbol is ERC20 {
    function symbol() external view returns (string memory _symbol);
}

// File: contracts/ForTestingOnly/MockKyberNetworkProxy.sol

contract MockKyberNetworkProxy {
    // This is the representation of ETH as a Token for Kyber Network.
    address constant internal KYBER_ETH_ADDRESS = address(
        0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
    );

    // Token -> Token -> rate
    mapping(address => mapping(address => uint)) public rates;

    event RateUpdated(
        ERC20 src,
        uint rate
    );

    function setRate(
        ERC20 token,
        uint rate
    )
        public
    {
        require(address(token) != address(0), "Source token address cannot be 0");
        require(rate > 0, "Rate must be larger than 0");

        rates[address(token)][KYBER_ETH_ADDRESS] = rate;
        rates[KYBER_ETH_ADDRESS][address(token)] = 10**18 / rate;

        emit RateUpdated(token, rate);
    }

    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty)
        public
        view
        returns (uint expectedRate, uint slippageRate) {
            // Removing compilation warnings
            srcQty;

            return (rates[address(src)][address(dest)], 0);
        }
}
