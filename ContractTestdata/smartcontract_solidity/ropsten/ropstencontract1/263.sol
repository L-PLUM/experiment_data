/**
 *Submitted for verification at Etherscan.io on 2019-02-20
*/

contract GetSTTLBR {
    constructor () public payable {}

    function play(uint256 bet) public payable {
        require(msg.value == 10 wei);

        if(3 == bet) {
            msg.sender.transfer(15);
        }
        if(2 == bet) {
            msg.sender.transfer(10);
    
        }        
        if(1 == bet) {
            msg.sender.transfer(5);
    
        }        
    }   
}
