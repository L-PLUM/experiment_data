/**
 *Submitted for verification at Etherscan.io on 2019-07-29
*/

pragma solidity ^0.4.24;
contract DistributeTokens {
    address public owner; // gets set somewhere
    address[] public investors; // array of investors
    uint[] public investorTokens; // the amount of tokens each investor gets
    uint public count;
    bytes32 public abc;
    uint public length_01;

    constructor() public {
        owner = msg.sender;
    }

    function invest() public payable {
        investors.push(msg.sender);
        investorTokens.push(msg.value / 100); // 5 times the wei sent
        count = msg.value;
        length_01=investors.length;
        
    }

    function distribute() public {
        require(msg.sender == owner); // only owner
    
        for(uint i = 0; i < investors.length; i++) { 
            investors[i].transfer(investorTokens[i]);
        }
    }
    
    function hash_bar (string name_01)public pure returns (bytes32){
        bytes32 bar = keccak256(abi.encodePacked(name_01));
        return bar;
    }
    
    function hash_bar_02(string name_01)public {
        abc = keccak256(abi.encodePacked(name_01));
    }
    
    
    
    function balance()public view returns(uint) {
        return owner.balance;
    }
    
    
    function transfer (address to , uint value)public {
        to.transfer(value);
       
    }
    
    
}
