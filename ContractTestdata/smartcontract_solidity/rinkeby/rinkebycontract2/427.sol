/**
 *Submitted for verification at Etherscan.io on 2019-07-26
*/

pragma solidity >=0.5.0  <0.6.0;

contract AccessAdmin{
    bool public isPaused = false;
    address public adminAddr;
    address payable public  financeAddr;

    event AdminTransferred(address indexed preAdmin, address indexed newAdmin);
    event FinanceTransferred(address indexed preFinance, address indexed newFinance);

    constructor() public {
        adminAddr = msg.sender;
        financeAddr = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == adminAddr);
        _;
    }

    modifier onlyFinance() {
        require(msg.sender == financeAddr);   
        _;
    }

    modifier whenNotPaused() {
        require(!isPaused);
        _;
    }

    modifier whenPaused {
        require(isPaused);
        _;
    }

    function setAdmin(address _newAdmin) external onlyAdmin {
        require(_newAdmin != address(0));
        emit AdminTransferred(adminAddr, _newAdmin);
        adminAddr = _newAdmin;
    }

    function setFinance(address payable _newFinance) external onlyAdmin{
        require(_newFinance != address(0));
        emit FinanceTransferred(financeAddr,_newFinance);
        financeAddr = _newFinance;
    }

    function doPause() external onlyAdmin whenNotPaused {
        isPaused = true;
    }

    function doUnpause() external onlyAdmin whenPaused {
        isPaused = false;
    }
}

contract Presale is AccessAdmin {
    event DNASaled(uint256 _type,uint256 _subType,uint256 _value,address _from);

    constructor() public{
        adminAddr = msg.sender;
        financeAddr = msg.sender;
    }

    function dnaPresale(uint256 _subType) external payable whenNotPaused{
        require(msg.sender != address(0));
        require(msg.value > 0);

        uint256 mainType = 0;
       // financeAddr.transfer(msg.value);
        emit DNASaled(mainType,_subType,msg.value,msg.sender);
    }

    // Ensure that `msg.value` is an even number.s
    function() external payable{
        require(msg.value > 0);
        uint256 value = msg.value / 2;
        require(msg.value == value * 2);
    }

    function withdraw() external {
        require(msg.sender == adminAddr || msg.sender == financeAddr);
        financeAddr.transfer(address(this).balance);
    }
}
