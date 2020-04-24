/**
 *Submitted for verification at Etherscan.io on 2019-02-23
*/

pragma solidity ^0.5.0;

contract StateChannels {

    struct channelDetails{
    	address u1Address;
    	address u2Address;
    	string u1TokenName;
    	string u2TokenName;
    	uint u1InitialTokenBal;
    	uint u2InitialTokenBal;
    	uint terminatingNonce;
    	uint terminatingBlockNum;
    }
    ////////REMOVE THE VARIABLE BELOW
    address public hackyStateOutput3 ;
	
	mapping (uint => channelDetails) public channels;
	mapping (address => uint[]) public channelsAtAddress;

    function CreateChannel(uint8 v1, bytes32 r1, bytes32 s1, uint CID, address u1Address, string memory u1TokenName, string memory u2TokenName, uint u1InitialTokenBal, uint u2InitialTokenBal) public {
        //require CID is not already in the smart contract
        require(channels[CID].u1Address == address(0));
        address u2Address = msg.sender;
        
        //require that sig1 correlates to all the data above
        bytes32 ChHash = keccak256(abi.encodePacked(CID,u1Address,u2Address,u1TokenName,u2TokenName,u1InitialTokenBal,u2InitialTokenBal));
        address calculatedProposingAddress = getOriginAddress(ChHash, v1,r1,s1);
        require(calculatedProposingAddress == u1Address);
        
        //put the given data into the contract
        channels[CID]=channelDetails(u1Address,u2Address,u1TokenName,u2TokenName,u1InitialTokenBal,u2InitialTokenBal,0,0);
    
        //DELETE THIS HACKY DEBUGGIN LINE
        hackyStateOutput3 = calculatedProposingAddress;


    }
    
    function InitChannelTermination(uint8 v, bytes32 r, bytes32 s, uint CID, uint proposedTerminatingBlockNumber, uint u1BalRetained, uint u2BalRetained, uint nonce) public{
        require(msg.sender == channels[CID].u1Address || msg.sender == channels[CID].u2Address);
        
        //require the requested terminating block is at least 24 hours from now
        require((proposedTerminatingBlockNumber - 5760) > block.number); 
        
        require(nonce > channels[CID].terminatingNonce);

        // check sig verifies balances and nonce to the counterparty's address
        bytes32 TxHash = keccak256(abi.encodePacked(CID,nonce,u1BalRetained,u2BalRetained));
        address calculatedProposingAddress = getOriginAddress(TxHash, v,r,s);
        require(channels[CID].u1Address == calculatedProposingAddress || channels[CID].u1Address == msg.sender);
        require(channels[CID].u2Address == calculatedProposingAddress || channels[CID].u2Address == msg.sender);

        //set when the contract can be terminated
        channels[CID].terminatingNonce = nonce;
        channels[CID].terminatingBlockNum = proposedTerminatingBlockNumber;
    }
    
    function TerminateChannel(uint CID) view public{
        require(block.number > channels[CID].terminatingBlockNum);
        //do stuff not considered in out project
        //uint u1Owes = u2InitialTokenBal - u2BalRetained;
        //uint u2Owes = u1InitialTokenBal - u1BalRetained;
        	//transfer u1Owes tokens from u1 to u2 (to be implemented later)
    }
    
    function getOriginAddress(bytes32 signedMessage, uint8 v, bytes32 r, bytes32 s) public pure returns(address) {
        bytes memory prefix = "\x19Ethereum Signed Message:\n32";
        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, signedMessage));
        return ecrecover(prefixedHash, v, r, s);
    }

    
}
