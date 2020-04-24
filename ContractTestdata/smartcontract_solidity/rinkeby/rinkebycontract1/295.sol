/**
 *Submitted for verification at Etherscan.io on 2019-02-18
*/

pragma solidity 0.5.1;

contract messageBoard {
    string public message;
    int public num = 129;
    int public people = 0;
    constructor(string memory initMessage) public  {
        message = initMessage;
    }
    function editMessage(string memory _editMessage) public{
        message = _editMessage;
    }
    function showMessage() public view returns(string memory){
        return message;
    }
    function pay() public payable{
        people++;
    }
}
