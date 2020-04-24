/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity ^0.5.0;

// File: contracts/IWrappedFiat.sol

/**
 * Reserves backed coin contract interface
 *
 * NB!: It is not for public trading, and it is not ERC20 compatible
 *
 */
interface IWrappedFiat {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address guy, uint amount) external returns (bool);
    function transferFrom(address src, address dst, uint amount) external returns (bool);
    function allowance(address src, address guy) external view returns (uint);
    function move(address src, address dst, uint amount) external;
}

// File: contracts/CustodialAccount.sol

/**
 * The account that is managed by a admin and can transfer coins
 * on behalf of its beneficiary
 */
contract CustodialAccount {

    IWrappedFiat fiat;

    address custodian;
    // address customer;

    constructor(
        IWrappedFiat fiat_,
        address custodian_) public {
        fiat = fiat_;
        custodian = custodian_;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(msg.sender == custodian, "You are not the custodian");
        return fiat.transfer(to, amount);
    }

    function approve(address guy, uint amount) external returns (bool) {
        require(msg.sender == custodian, "You are not the custodian");
        return fiat.approve(guy, amount);
    }

    function call(address target, bytes calldata abiEncodedData) external returns (bool success) {
        require(msg.sender == custodian, "You are not the custodian");
        (success, ) = target.call(abiEncodedData);
        require(success, "target call failed");
    }

    function approveAndCall(address target, uint256 amount, bytes calldata abiEncodedData) external returns (bool success) {
        require(msg.sender == custodian, "You are not the custodian");
        fiat.approve(target, amount);
        (success, ) = target.call(abiEncodedData);
        require(success, "target call failed");
    }
}
