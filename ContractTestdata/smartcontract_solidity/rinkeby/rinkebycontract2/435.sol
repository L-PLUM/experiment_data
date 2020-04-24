/**
 *Submitted for verification at Etherscan.io on 2019-07-26
*/

contract testCall{
    event a();

    function whoAmI() public view returns(address){
        // emit a();
        return msg.sender;
    }
    address public _owner;
    constructor() public {
        _owner = msg.sender;
    }
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }
}
