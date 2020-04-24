/**
 *Submitted for verification at Etherscan.io on 2019-01-23
*/

pragma solidity ^0.4.24;

// File: contracts/BankUtil.sol

interface Bank {
    function balanceOf(address token, address user) external view returns (uint256);
}

contract BankUtil {
    function depositedBalances(address bankAddr, address user, address[] tokens) external view returns (uint[] memory balances) {
        balances = new uint[](tokens.length);
        Bank bank = Bank(bankAddr);
        for (uint i = 0; i < tokens.length; i++) {
            balances[i] = bank.balanceOf(tokens[i], user);
        }
        return balances;
    }
}
