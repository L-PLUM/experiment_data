/**
 *Submitted for verification at Etherscan.io on 2019-08-04
*/

pragma solidity ^0.4.17;

contract ioTProject
{
    bool LEDturnedOn;
    bool tempUpdated;
    int256 currentTemp;
    uint256 lastTempUpdate;
    address owner;
    
    modifier onlyOwner()
    {
        require(msg.sender == owner);
        _;
    }
    
    function tempSensor() public
    {
        LEDturnedOn = false;
        tempUpdated = true;
        lastTempUpdate = block.number;
        owner = msg.sender;
    }
    
    function isLightTurnedOn() public constant returns (bool)
    {
        return LEDturnedOn;
    }
    
    function isTempCurrent() public constant returns (bool)
    {
        return tempUpdated;
    }
    
    function turnLightOn() public payable
    {
        if( msg.value < 1000 finney){ revert(); }
        LEDturnedOn = true;
    }
    
    function turnLightOffAdminOnly() public onlyOwner
    {
        LEDturnedOn = false;
    }
    
    function updateTemp() public payable
    {
        if(msg.value < 10 finney){ revert(); }
        tempUpdated = false;
    }
    
    function setTempDeviceOnly(int256 _temp) public onlyOwner
    {
        currentTemp = _temp;
        lastTempUpdate = block.number;
        tempUpdated = true;
    }
    
    function getTemp() public constant returns (int256, uint256)
    {
        return (currentTemp, lastTempUpdate);
    }

    function getTempDeviceOnly() public onlyOwner constant returns (int256){
        return currentTemp;
    }
}
