/**
 *Submitted for verification at Etherscan.io on 2019-02-11
*/

pragma solidity ^0.5.2;

//0x26726ef9d6d9651bf816d74866600ca53dce992b

contract ERC20Interface 
{
    function balanceOf(address tokenOwner) public view returns (uint balance);
    function allowance(address tokenOwner, address spender) public view returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    mapping(address => mapping(address => uint)) allowed;
}

contract lottrygame{
    //base setting
    uint256 public people;
    uint numbers;
    uint256 public tickamount = 100;
    uint256 public winnergetETH1 = 0.05 ether;
    uint256 public winnergetETH2 = 0.03 ether;
    uint256 public winnergetETH3 = 0.02 ether;
    uint public gamecount = 0;
    uint public inputsbt = 100;
    uint[]  black;
    uint[]  red;
    uint[]  yellow;
    uint public w;
    uint public x;
    uint public z;
    
    address []public tickplayers;
    address payable owner = msg.sender;
    address tokenAddress = 0x503F9794d6A6bB0Df8FBb19a2b3e2Aeab35339Ad;
    address poolwallet = msg.sender;
    address payable[] tickplayers1;
    
    bool public tickgamelock = true;
    bool public full = true;
    event tickwinner(uint,address,address,address,uint,uint,uint);
    event ticksell(uint gettick,uint paytick);   
    
    modifier ownerOnly() {
    require(msg.sender == owner);
    _;
}    
    modifier ownerPool() {
    require(msg.sender == poolwallet);
    _;
    
}
function getplayer()public view returns(address[] memory){
    return tickplayers;
}

    //function can get ETH
function () external payable ownerOnly{
    tickgamelock=false;
}
    //change winner can get ETH
function changewinnerget(uint ethamount) public ownerOnly{
    require(ethamount!=0);
    require(msg.sender==owner);
    if(ethamount==1){
    winnergetETH1 = 0.05 ether;
    winnergetETH2 = 0.03 ether;
    winnergetETH3 = 0.02 ether;
    inputsbt = 100;
    }
    else if(ethamount==10){
    winnergetETH1 = 0.12 ether;
    winnergetETH2 = 0.08 ether;
    winnergetETH3 = 0.05 ether;
    inputsbt = 250;
    }
    else if(ethamount==100){
    winnergetETH1 = 1 ether;
    winnergetETH2 = 0.6 ether;
    winnergetETH3 = 0.4 ether;
    inputsbt = 1500;
    }
}
    //change tick amount
function changetickamount(uint256 _tickamount) public ownerOnly{
    require(msg.sender==owner);
    tickamount = _tickamount;
}

    //players joingame
function jointickgame(uint gettick) public {
    require(tickgamelock == false);
    require(gettick<=tickamount&&gettick>0);
    require(gettick<=10&&people<=100);
    if(people<tickamount){
        uint paytick=uint(inputsbt)*1e18*gettick;
        uint i;
        //ERC20Interface(tokenAddress).transferFrom(msg.sender,address(poolwallet),paytick);
        for (i=0 ;i<gettick;i++){
        tickplayers.push(msg.sender);
        tickplayers1.push(msg.sender);
        people ++;}
        emit ticksell(gettick,paytick);
    }
    else if (people<=tickamount){
        uint paytick=uint(inputsbt)*1e18*gettick;
        uint i;
       // ERC20Interface(tokenAddress).transferFrom(msg.sender,address(poolwallet),paytick);
        for (i=0 ;i<gettick;i++){
        tickplayers.push(msg.sender);
        tickplayers1.push(msg.sender);
        people ++;}
        emit ticksell(gettick,paytick);
        require(full==false);
        pictickWinner();
    }
}

//===================random====================\\
function changerandom(uint b,uint y,uint r)public ownerOnly{
    require(msg.sender==owner);
    black.push(b);
    yellow.push(y);
    red.push(r);
}
function tickrandom()private view returns(uint) {
    return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp,black))); 
}
function tickrandom1()private view returns(uint) {
    return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp,yellow)));
}
function tickrandom2()private view returns(uint) {
    return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp,red))); 
}
//===============================================\\

    //get winner in players
function pictickWinner()public ownerPool{
    require(msg.sender==poolwallet);
    require(tickgamelock == false);
    require(people>0);
    w = tickrandom() % (tickplayers.length);
    x = tickrandom1() % (tickplayers.length);
    z = tickrandom2() % (tickplayers.length);
    black.push(z);
    black.push(w);
    black.push(x);
    //tickplayers1[w].transfer(winnergetETH1);
    //tickplayers1[x].transfer(winnergetETH2);
    //tickplayers1[z].transfer(winnergetETH3);
    tickplayers = new address[](0);
    tickplayers1 = new address payable[](0);
    people = 0;
    tickamount = 100;
    gamecount++;
    
    
}
    //destory game
function killgame()public ownerOnly {
    require(msg.sender==owner);
    selfdestruct(owner);
}
function changefull()public ownerOnly{
    require(msg.sender==owner);
    if(full== true){
        full=false;
    }else if(full==false){
        full=true;
    }
}

    //setgamelock true=lock,false=unlock
function settickgamelock() public ownerOnly{
    require(msg.sender==owner);
       if(tickgamelock == true){
        tickgamelock = false;
       }
       else if(tickgamelock==false){
           tickgamelock =true;
       }
    }
    //transfer contract inside tokens to owner
function transferanyERC20token(address _tokenAddress,uint tokens)public ownerOnly{
    require(msg.sender==owner);
    ERC20Interface(_tokenAddress).transfer(owner, tokens);
}
}
