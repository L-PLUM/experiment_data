contract f{
    function a(){
    // <yes> <report> solidity_use_if_revert rev101
        if (x>y) { revert(); }
    }
    modifier atStage(Stages _stage) {
    // <yes> <report> solidity_use_if_revert rev101
        if (stage != _stage)
            revert();
        _;
    }
}
contract f{
    function a(){
    // <yes> <report> solidity_use_if_revert rev101
        if (x>y) { throw; }
        if (tokensToSend > 0) {
            allocatedTokens -= tokensToSend;
    // <yes> <report> solidity_use_if_revert rev101
            if (!token.issue(msg.sender, tokensToSend)) {
                revert();
            }
        }
        if (ethToSend > 0) {
            allocatedEth -= ethToSend;
    // <yes> <report> solidity_use_if_revert rev101
            if (!msg.sender.send(ethToSend)) {
                revert();
            }
        }
        if (stage == Stages.PresaleStarted) {
            buyPresale(receiver);
        }
    // <yes> <report> solidity_use_if_revert rev101
        else if (stage == Stages.MainSaleStarted) {
            buyMainSale(receiver);
        } else {
            revert();
        }
    // <yes> <report> solidity_use_if_revert rev101
        if(!ico_ended) {
           eth_received = Add(eth_received, msg.value);
        } else {
           revert();
        }
    }
}