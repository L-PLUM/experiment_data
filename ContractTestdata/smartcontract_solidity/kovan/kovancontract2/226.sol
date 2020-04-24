/**
 *Submitted for verification at Etherscan.io on 2019-07-25
*/

pragma solidity ^0.5.0;

contract stub {
    function transfer(address destination, uint256 amount) public returns (bool);
    function balanceOf(address moi) public view returns (uint256);
}

contract proxy {
    address owner = msg.sender;

    event Transferred(stub token, address destination, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner,"Unauthorised");
        _;
    }

    function forward(stub token, address destination, uint256 amount) public onlyOwner {
        if (token.transfer(destination,amount)) {
            emit Transferred(token,destination,amount);
        }

    }

}
