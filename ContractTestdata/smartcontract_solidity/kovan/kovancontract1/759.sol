/**
 *Submitted for verification at Etherscan.io on 2019-01-09
*/

pragma solidity ^0.5.2;


interface PriceOracleInterface {

    function getPrice(address token) external view returns (uint, uint);

}
contract PriceOracleMock is PriceOracleInterface {

    struct Price {
        uint256 numerator;
        uint256 denominator;
    }

    // user => amount
    mapping (address => Price) public tokenPrices;

    function getPrice(address token) public view returns (uint, uint) {
        Price memory price = tokenPrices[token];
        return (price.numerator, price.denominator);
    }

    function setTokenPrice(address token, uint256 numerator, uint256 denominator) public {
        tokenPrices[token] = Price(numerator, denominator);
    }
}
