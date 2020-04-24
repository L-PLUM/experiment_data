/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity >=0.4.22 <0.6.0;

contract PledgerGenerator {
    address[] public contracts;
    address public lastContractAddress;
    
    event newPledgerContract (
       address contractAddress
    );

    constructor()
        public
    {

    }

    function getContractCount()
        public
        constant
        returns(uint contractCount)
    {
        return contracts.length;
    }

    function newPledger(string memory pledge)
        public
        returns(address newContract)
    {
        Pledger c = new Pledger(pledge);
        contracts.push(c);
        lastContractAddress = address(c);
        emit newPledgerContract(c);
        return c;
    }

    function seePledger(uint pos)
        public
        constant
        returns(address contractAddress)
    {
        return address(contracts[pos]);
    }
}

contract Revocable {
    /* Define variable owner of the type address */
    address owner;

    /* This constructor is executed at initialization and sets the owner of the contract */
    constructor() public { owner = msg.sender; }

    /* Function to recover the funds on the contract */
    function kill() public { if (msg.sender == owner) selfdestruct(msg.sender); }
}

contract Pledger is Revocable {
    /* Define variable template of the type string */
    string public pledge;

    /* This runs when the contract is executed */
    constructor(string memory _pledge) public {
        pledge = _pledge;
    }

    /* Main function, reads pledge content from constructor */
    function read() public view returns (string memory) {
        return pledge;
    }
}
