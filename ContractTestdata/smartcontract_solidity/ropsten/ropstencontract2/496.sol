/**
 *Submitted for verification at Etherscan.io on 2019-08-06
*/

pragma solidity >=0.4.21 <0.6.0;

contract MyPassword {
    mapping(string => string) private password;
    address public owner;
    
    constructor()public{
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function set(string memory key, string memory _password)public onlyOwner {
        password[key] = _password;
    }

    function get(string memory key)public onlyOwner view returns(string memory result) {
        return password[key];
    }
}
