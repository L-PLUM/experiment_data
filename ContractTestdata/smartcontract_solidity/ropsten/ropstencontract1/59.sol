/**
 *Submitted for verification at Etherscan.io on 2019-02-22
*/

pragma solidity ^0.5.0;

// File: paradigm-subcontract-sdk/contracts/SubContract.sol

interface SubContract {
    function makerArguments() external view returns (string memory);
    function takerArguments() external view returns (string memory);
    function isValid(bytes32[] calldata) external view returns (bool);
    function amountRemaining(bytes32[] calldata) external view returns (uint);
    function participate(bytes32[] calldata, bytes32[] calldata) external returns (bool);
}

// File: contracts/external/OrderGateway.sol

contract OrderGateway {

    constructor() public {
    }

    event Participation(address indexed subContract, string id);

    function participate(address subContract, string memory id, bytes32[] memory makerData, bytes32[] memory takerData) public returns (bool) {
        emit Participation(subContract, id);
        return SubContract(subContract).participate(makerData, takerData);
    }

    function isValid(address subContract, bytes32[] memory makerData) public view returns (bool) {
        return SubContract(subContract).isValid(makerData);
    }

    function amountRemaining(address subContract, bytes32[] memory makerData) public view returns (uint) {
        return SubContract(subContract).amountRemaining(makerData);
    }

    function makerArguments(address subContract) public view returns (string memory) {
        return SubContract(subContract).makerArguments();
    }

    function takerArguments(address subContract) public view returns (string memory) {
        return SubContract(subContract).takerArguments();
    }
}
