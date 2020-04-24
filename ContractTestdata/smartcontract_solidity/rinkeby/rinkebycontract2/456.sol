/**
 *Submitted for verification at Etherscan.io on 2019-07-25
*/

pragma solidity ^0.5.1;

contract AskSomething {

    struct Topic {
        address payable creator;
        string subject;
        string publicKey;
        bool isEncrypted;
        uint maxNumber;
        uint deposit;
        uint askEndTime;
        uint resEndTime;
        uint distributedNumber;
        uint donated;
        mapping(address => QuestionerInfo) questioner;
        address[] questionerAddrs;
    }

    struct Question {
        address payable creator;
        uint creatorNumber;
        string description;
        bool isEncrypted;
        string secretKey;
        string reply;
        uint donated;
        mapping(uint => uint) questionerReaction;
        mapping(uint => uint) reactionSum;
    }

    struct QuestionerInfo {
        uint number;
        uint depositValue;
        bool isWithdraw;
        bool withdrawable;
    }

    address payable public contractOwner;

    mapping(bytes32 => Topic) public allTopic;

    mapping(bytes32 => Question[]) public allQuestion;

    event TopicCreated(bytes32 key);

    event TopicDonate(bytes32 indexed key, address from, uint value);

    event QuestionDonate(bytes32 indexed key, uint indexed index, address from, uint value);

    event ContractDonate(address from, uint value);

    modifier onlyTopicOwner(bytes32 key) {
        require(allTopic[key].creator == msg.sender, "topic creator only");
        _;
    }

    modifier onlyQuestionOwner(bytes32 key, uint index) {
        require(allQuestion[key][index].creator == msg.sender, "question creator only");
        _;
    }

    modifier onlyTopicQuestioner(bytes32 key) {
        require(allTopic[key].questioner[msg.sender].number > 0, "please take number first");
        _;
    }

    modifier topicExist(bytes32 key) {
        require(allTopic[key].creator != address(0), "topic not exist");
        _;
    }

    modifier questionExist(bytes32 key, uint index) {
        require(allQuestion[key].length > index, "question not exist");
        _;
    }

    modifier beforeAskEndTime(bytes32 key) {
        require(now <= allTopic[key].askEndTime, "reached the time of questioning");
        _;
    }

    modifier beforeResEndTime(bytes32 key) {
        require(now > allTopic[key].askEndTime, "response time is not start yet");
        require(now <= allTopic[key].resEndTime, "response timeout");
        _;
    }

    modifier afterResEndTime(bytes32 key) {
        require(now > allTopic[key].resEndTime, "response time is not ending yet");
        _;
    }

    modifier transferRemainValue() {
        _;
        donateContractOwner();
    }

    constructor() public {
        contractOwner = msg.sender;
    }

    function createTopic(
        string calldata subject,
        string calldata publicKey,
        bool isEncrypted,
        uint maxNumber,
        uint deposit,
        uint askEndTime,
        uint resEndTime
    )
        external
    {
        bytes32 key = keccak256(abi.encodePacked(subject, msg.sender, block.number));
        allTopic[key] = Topic({
                creator : msg.sender,
                subject : subject,
                publicKey : publicKey,
                isEncrypted : isEncrypted,
                maxNumber : maxNumber,
                deposit : deposit,
                askEndTime : askEndTime,
                resEndTime : resEndTime,
                distributedNumber : 0,
                donated: 0,
                questionerAddrs : new address[](0)
            });
        emit TopicCreated(key);
    }

    function takeNumberByTopic(
        bytes32 key
    )
        topicExist(key)
        beforeAskEndTime(key
    )
        payable
        external
    {
        require(allTopic[key].distributedNumber < allTopic[key].maxNumber, "no remaining number");
        require(msg.value >= allTopic[key].deposit, "invalid deposit value");
        require(allTopic[key].questioner[msg.sender].number == 0, "number exist");

        allTopic[key].distributedNumber++;
        QuestionerInfo memory info = QuestionerInfo(allTopic[key].distributedNumber, msg.value, false, true);
        allTopic[key].questioner[msg.sender] = info;
        allTopic[key].questionerAddrs.push(msg.sender);
    }

    function createQuestion(
        bytes32 key,
        string calldata description,
        bool isEncrypted
    )
        topicExist(key)
        onlyTopicQuestioner(key)
        beforeAskEndTime(key)
        external
    {
        allQuestion[key].push(
            Question({
                creator : msg.sender,
                creatorNumber : allTopic[key].questioner[msg.sender].number,
                description : description,
                isEncrypted : isEncrypted,
                secretKey : "",
                reply: "",
                donated : 0
            })
        );
    }

    function submitQuestionSecret(
        bytes32 key,
        uint index,
        string calldata secretKey
    )
        topicExist(key)
        questionExist(key, index)
        onlyQuestionOwner(key, index)
        external
    {
        allQuestion[key][index].secretKey = secretKey;
    }

    function replyQuestion(
        bytes32 key,
        uint index,
        string calldata reply
    )
        topicExist(key)
        questionExist(key, index)
        onlyTopicOwner(key)
        external
    {
        allQuestion[key][index].reply = reply;
    }

    function withdraw(
        bytes32 key
    )
        transferRemainValue
        topicExist(key)
        onlyTopicQuestioner(key)
        afterResEndTime(key)
        payable
        external
    {
        require(allTopic[key].questioner[msg.sender].withdrawable, "this address deposit cannot be withdrawn");
        require(!allTopic[key].questioner[msg.sender].isWithdraw, "this address deposit has been withdrawn");

        msg.sender.transfer(allTopic[key].questioner[msg.sender].depositValue);
        allTopic[key].questioner[msg.sender].isWithdraw = true;
    }

    function forceWithdraw(
        bytes32 key,
        address payable addr
    )
        transferRemainValue
        topicExist(key)
        onlyTopicOwner(key)
        afterResEndTime(key)
        payable
        external
    {
        require(allTopic[key].questioner[addr].number > 0, "address not exist");
        require(!allTopic[key].questioner[addr].isWithdraw, "this address deposit has been withdrawn");

        addr.transfer(allTopic[key].questioner[addr].depositValue);
        allTopic[key].questioner[addr].isWithdraw = true;
    }

    function getQuestionerInfo(
        bytes32 key,
        uint index
    )
        topicExist(key)
        view
        external
        returns (
            uint number,
            uint depositValue,
            bool isWithdraw,
            bool withdrawable
        )
    {
        require(allTopic[key].questionerAddrs.length > index, "can not find questioner");

        QuestionerInfo memory info = allTopic[key].questioner[allTopic[key].questionerAddrs[index]];
        return (info.number, info.depositValue, info.isWithdraw, info.withdrawable);
    }

    function getQuestionerNumber(bytes32 key) topicExist(key) view external returns (uint number) {
        return allTopic[key].questioner[msg.sender].number;
    }

    function getTopicQuestionCount(bytes32 key) topicExist(key) view external returns (uint count) {
        return allQuestion[key].length;
    }

    function getQuestionerReaction(
        bytes32 key,
        uint index,
        uint number
    )
        topicExist(key)
        questionExist(key, index)
        view
        external
        returns (uint reaction)
    {
        return (allQuestion[key][index].questionerReaction[number]);
    }

    function getQuestionReactionSum(
        bytes32 key,
        uint index,
        uint reaction
    )
        topicExist(key)
        questionExist(key, index)
        view
        external
        returns (uint sum)
    {
        return (allQuestion[key][index].reactionSum[reaction]);
    }

    function reactQuestion(
        bytes32 key,
        uint index,
        uint reaction
    )
        transferRemainValue
        topicExist(key)
        questionExist(key, index)
        onlyTopicQuestioner(key)
        beforeResEndTime(key)
        payable
        external
    {
        uint number = allTopic[key].questioner[msg.sender].number;
        require(reaction > 0 && reaction <= 4, "invalid reaction");
        require(allQuestion[key][index].questionerReaction[number] == 0, "reacted already");

        if (reaction == 4) {
            require(number == allQuestion[key][index].creatorNumber, "question creator only");
        }

        allQuestion[key][index].questionerReaction[number] = reaction;
        allQuestion[key][index].reactionSum[reaction]++;

        if (reaction == 3) {
            uint threshold = allTopic[key].distributedNumber / 2;
            if (allQuestion[key][index].reactionSum[reaction] > threshold) {
                address questionerAddr = allQuestion[key][index].creator;
                allTopic[key].questioner[questionerAddr].withdrawable = false;
            }
        }
    }

    function donateTopicCreator(bytes32 key) topicExist(key) payable external {
        allTopic[key].creator.transfer(msg.value);
        allTopic[key].donated += msg.value;
        emit TopicDonate(key, msg.sender, msg.value);
    }

    function donateQuestionCreator(
        bytes32 key,
        uint index
    )
        topicExist(key)
        questionExist(key, index)
        payable
        external
    {
        allQuestion[key][index].creator.transfer(msg.value);
        allQuestion[key][index].donated += msg.value;
        emit QuestionDonate(key, index, msg.sender, msg.value);
    }

    function donateContractOwner() payable public {
        if (msg.value > 0) {
            contractOwner.transfer(msg.value);
            emit ContractDonate(msg.sender, msg.value);
        }
    }
}
