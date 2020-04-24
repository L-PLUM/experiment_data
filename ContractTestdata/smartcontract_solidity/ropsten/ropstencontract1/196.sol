/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

pragma solidity ^0.4.0;

contract ERC20 {
    function totalSupply() public view returns (uint256);//totalSupply is to check how many tokens we have created, public view is getter

    function balanceOf(address _person) public view returns (uint256);//balaceOf is to check the balance of the person whose address will be mentioned
    function transferTokens(address _receiver,uint _amount) public returns (bool);// transferTokens to transfer the tokens to the person whose adress will be mentioned in reciever and value
}

contract task is ERC20 {
    mapping (address=> uint256)  public bal;//bal => balance
    uint256 totalTokens;
    string public tokenName;
    string public symb;// for symbol
    uint256 public decimal;

constructor (uint256 _num,string _name,string _symbol,uint256 deci) public {
    totalTokens=_num * 10**deci;
    bal[msg.sender]=totalTokens;
    tokenName=_name;
    symb=_symbol;
    decimal=deci;
}
function totalSupply() public view returns (uint256){
    return totalTokens;
}
function balanceOf(address _person) public view returns (uint256){
    return (bal[_person]);
}
 function transferTokens(address _receiver,uint amount) public returns (bool){
     require(bal[msg.sender]>=amount);
     bal[msg.sender]=bal[msg.sender]-amount;
     bal[_receiver]=bal[_receiver]+amount;
     return true;
 }
}
