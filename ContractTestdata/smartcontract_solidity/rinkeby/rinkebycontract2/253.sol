/**
 *Submitted for verification at Etherscan.io on 2019-08-02
*/

pragma solidity ^0.5.8;

contract storestr{
    struct Value{
        string value;
    }
    mapping(int => Value) KeyValue;

    int private key = 0;

    function createValue(string memory value) public returns (int) {
        Value memory val = Value(value);
        KeyValue[key] = val;
        key += 1;
        return key - 1;
    }

    function getValue(int _key) public view returns (string memory _val){
        return KeyValue[_key].value;
    }

    //no setvalue to ensure immutability

    function getKey() public view returns (int){
        return key;
    }
}
