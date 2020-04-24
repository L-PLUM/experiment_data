/**
 *Submitted for verification at Etherscan.io on 2018-12-14
*/

pragma solidity ^0.4.24;

contract Property {

    string public address1;
    string public address2;
    string public city;
    string public country;
    string public postCode;
    string public state;
    uint256 public markerValue;
    string public propertyClass;
    uint256 public squareFootage;
    uint256 public vacancy;
    uint256 public cashFlow;
    uint256 public currentNet;
    uint256 public totalDebt;
    uint256 public payoffDate;
    string public proForm;
    uint256 public floorAmount;
    uint256 public totalCapital;
    uint256 public equityRaise;
    address public  securityToken;


    function setFirstInfo(string _address1,
        string _address2,
        string _city,
        string _country){
        address1 = _address1;
        address2 = _address2;
        city = _city;
        country = _country;
    }

    function setSecondInfo(string _postCode,
        string _state,
        uint256 _markerValue,
        string _propertyClass){
        postCode = _postCode;
        state = _state;
        markerValue = _markerValue;
        propertyClass = _propertyClass;
    }

    function setThirdInfo(
        uint256 _squareFootage,
        uint256 _vacancy,
        uint256 _cashFlow,
        uint256 _currentNet
    ){
        squareFootage = _squareFootage;
        vacancy = _vacancy;
        cashFlow = _cashFlow;
        currentNet = _currentNet;
    }

    function setFourth(uint256 _totalDebt,
        uint256 _payoffDate,
        string _proForm,
        uint256 _floorAmount){
        totalDebt = _totalDebt;
        payoffDate = _payoffDate;
        proForm = _proForm;
        floorAmount = _floorAmount;
    }

    function setSecurityToken(address _securityToken) {
        securityToken = _securityToken;
    }

    function getProperty() public view returns(string a){
        return "PROPERTY";
    }



}
