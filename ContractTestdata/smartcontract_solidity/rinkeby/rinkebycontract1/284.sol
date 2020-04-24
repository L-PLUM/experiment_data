/**
 *Submitted for verification at Etherscan.io on 2019-02-18
*/

pragma solidity 0.5.4;


contract ERC20 {
  function transfer(address to, uint256 value) public returns (bool);
}

contract MultiSign {
    address public Exchange = address(0xEe6B81553fd32370865c74b05e0731B0404d523d);
    address public Foundation = address(0x14294C60eaA6d8ae880c06899122478ac2E0008e);
    uint256 public ProposalID = 0;
    mapping(uint => Proposal) public Proposals;

    struct Proposal {
        uint256 id;
        address to;
        bool close; // false open, true close
        address tokenContractAddress; // ERC20 token contract address
        uint256 amount;
        bool approvalByExchange;
        bool approvalByFoundation;
    }
    
    
    constructor() public {
    }
    
    function lookProposal(uint256 id) public view returns (uint256 _id, address _to, bool _close, address _tokenContractAddress, uint256 _amount, bool _approvalByExchange, bool _approvalByFoundation) {
        Proposal memory p = Proposals[id];
        return (p.id, p.to, p.close, p.tokenContractAddress, p.amount, p.approvalByExchange, p.approvalByFoundation);
    }
    
    function proposal (address _to, address _tokenContractAddress, uint256 _amount) public returns (uint256 id) {
        require(msg.sender == Foundation || msg.sender == Exchange);
        ProposalID = ProposalID + 1;
        Proposals[ProposalID] = Proposal(ProposalID, _to, false, _tokenContractAddress, _amount, false, false);
        return id;
    }
    
    function approval (uint256 id) public returns (bool) {
        Proposal storage p = Proposals[id];
        require(p.close == false);
        if (msg.sender == Foundation && !p.approvalByFoundation) {
            p.approvalByFoundation = true;
            Proposals[ProposalID] = p;
        }
        if (msg.sender == Exchange && !p.approvalByExchange) {
            p.approvalByExchange = true;
            Proposals[ProposalID] = p;
        }
        
        if (p.approvalByExchange && p.approvalByFoundation) {
            p.close = true;
            Proposals[ProposalID] = p;
            ERC20(p.tokenContractAddress).transfer(p.to, p.amount);
        }
        return true;
    }
    
    
    function() payable external{
        require(msg.value == 0);
        // default to approval current proposal
        approval(ProposalID);
    }
}
