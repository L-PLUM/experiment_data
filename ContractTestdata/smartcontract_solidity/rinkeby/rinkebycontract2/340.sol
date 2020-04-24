/**
 *Submitted for verification at Etherscan.io on 2019-07-30
*/

pragma solidity >=0.5.0;

contract BridgeLike {
    function unlock(address _receiver, uint256 _amount) public returns(bool);
}

contract FederatedManager {
    address                         owner;
    mapping(address => bool) public federators;
    uint public                     federatorLength;
    mapping(bytes32 => address[])   votes;
    mapping(bytes32 => bool)        processed;
    BridgeLike public               bridge;
    
    modifier ownable() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    modifier federatorable() {
        require(isFederator(msg.sender), "Only federator");
        _;
    }

    constructor(address[] memory _federators) public {
        federatorLength = _federators.length;
        for (uint k = 0; k < federatorLength; k++) {
            federators[_federators[k]] = true;
        }
        owner = msg.sender;
    }
    
    function setBridge(address _bridge) public ownable {
        require(_bridge == address(0), "Bad bridge address");
        bridge = BridgeLike(_bridge);
    }

    function voteTransaction(uint _blockNumber, bytes32 _blockHash, bytes32 _transactionHash, address _receiver, uint _amount)
        public federatorable
    {
        bytes32 voteId = hashTransactionVoteId(_blockNumber, _blockHash, _transactionHash, _receiver, _amount);
        
        if (processed[voteId])
            return;

        address[] storage transactionVotes = votes[voteId];
        uint n = transactionVotes.length;
        
        for (uint16 k = 0; k < n; k++)
            if (transactionVotes[k] == msg.sender)
                return;
        
        transactionVotes.push(msg.sender);
        
        if (transactionVotes.length < federatorLength / 2 + 1)
            return;
            
        if (bridge.unlock(_receiver, _amount)) {
            delete votes[voteId];
            processed[voteId] = true;
        }
    }
    
    function transactionVotes(uint _blockNumber, bytes32 _blockHash, bytes32 _transactionHash, address _receiver, uint _amount)
        public view returns(address[] memory)
    {
        bytes32 voteId = hashTransactionVoteId(_blockNumber, _blockHash, _transactionHash, _receiver, _amount);
        return votes[voteId];
    }

    function transactionVotesCount(uint _blockNumber, bytes32 _blockHash, bytes32 _transactionHash, address _receiver, uint _amount)
        public view returns(uint)
    {
        bytes32 voteId = hashTransactionVoteId(_blockNumber, _blockHash, _transactionHash, _receiver, _amount);
        return votes[voteId].length;
    }

    function transactionProcessed(uint _blockNumber, bytes32 _blockHash, bytes32 _transactionHash, address _receiver, uint _amount)
        public view returns(bool)
    {
        bytes32 voteId = hashTransactionVoteId(_blockNumber, _blockHash, _transactionHash, _receiver, _amount);
        return processed[voteId];
    }
    
    function hashTransactionVoteId(uint _blockNumber, bytes32 _blockHash, bytes32 _transactionHash, address _receiver, uint _amount)
        public pure returns(bytes32)
    {
        return keccak256(abi.encodePacked(_blockNumber, _blockHash, _transactionHash, _receiver, _amount));
    }
    
    //federator manager
    
    function isFederator(address m) public view returns(bool)
    {
        return federators[m];
    }

    function addFederator(address _federator) public ownable
    {
        if (isFederator(_federator)){
            return;
        }
        ++federatorLength;
        federators[_federator] = true;
    }

    function delFederator(address _federator) public ownable
    {
         if (isFederator(_federator)) {
             --federatorLength;
            federators[_federator] = false;
         }
    }
}
