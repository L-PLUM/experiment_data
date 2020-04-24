/**
 *Submitted for verification at Etherscan.io on 2019-07-29
*/

contract Attestation{

    address private owner;

    mapping(string => bool) attested;

    modifier isOwner {
        require(msg.sender == owner, "You are not authorized to attest this certifcate");
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function sign(string memory hash) public isOwner() {
        attested[hash] = true;
    }

    function verify(string memory hash) public view returns (bool) {
        return attested[hash];
    }
}
