/**
 *Submitted for verification at Etherscan.io on 2019-02-14
*/

contract BlockTO {
    address[] addresses;
    mapping (address => uint) addressIndex;
    
    function becomeValidator() public {
        require(!isValidator(msg.sender));
        require(addresses.length < 10);
        addresses.push(msg.sender);
        addressIndex[msg.sender] = addresses.length;
    }

    function isValidator(address who) public view returns (bool) {
        return addressIndex[who] > 0;
    }

    function getValidators() public returns(address[]) {
        return addresses;
    }
}
