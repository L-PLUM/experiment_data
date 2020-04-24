/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

contract WeiCasino {
    constructor () public payable {}

    function play(uint256 bet) public payable {
        require(msg.value == 1 wei);
        uint256 seed = uint256(keccak256(abi.encodePacked(now, blockhash(block.number - 1))));
        if(seed % 256 == bet) {
            msg.sender.transfer(address(this).balance > 100 wei ? 100 wei : address(this).balance);
        }
    }
}
