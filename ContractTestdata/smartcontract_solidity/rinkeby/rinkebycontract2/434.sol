/**
 *Submitted for verification at Etherscan.io on 2019-07-26
*/

contract testCall{
    event a();
    address public _owner;
    constructor() public {
        _owner = msg.sender;
    }
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
    function whoAmI() public view returns(uint256){
        // emit a();
        return address(msg.sender).balance;
    }
}
