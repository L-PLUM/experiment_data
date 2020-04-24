/**
 *Submitted for verification at Etherscan.io on 2019-02-16
*/

pragma solidity ^0.5.4;

contract TrapdoorLottery {
    /* Public variables of the token */
    string public name = 'TrapdoorLottery 0.1';
    string public symbol = 'LOT';
    string public description;
    uint256 PlayerLimit; // how many people can play at once

    mapping (address => bool) public authorized;
    address payable[] public players;
    mapping (address  => uint256) public submissions;
    address payable[] public winners;
    
    // VDF public parameters
    uint256 public N; // modulus for VDF, only 256 BITS!
    uint256 public T = 120*(2**16 + 2**15 + 2**14 + 2**10 + 2**7 + 2**6 + 2**4 + 7); // approx 1 minute
    uint256 public Input;
    uint256 public RawOutput;
    uint256 public Output;
    uint256 public Proof;
    uint256 public Challenge;

    
    // Timing to determine Submit and Release phases
    uint256 public LotteryDuration = 60 seconds;
    uint256 public LotteryStart = 0 seconds;
    string public LotteryStatus = 'closed';
    
    /* This generates a public event on the blockchain that will notify clients */
    //event Transfer(address indexed from, address indexed to, uint256 value);
    event LotteryCreated(uint256 Modulus, uint256 MaxPlayers);
    event LotteryOpened(uint256 x);
    event Submitted(address from, uint256 value);
    event Revealed(address from, uint256 result, uint256 y, uint256 pi,  uint256 e);
    event LotteryClosed(address payable[] winners, uint256 bestdistance);

    // Initialize contract and VDF Modulus
    constructor (uint256 _N, uint256 _PlayerLimit) public {
        description = 'choose a number from 0 to PlayerLimit, and you win the lottery!';
        N = _N;
        PlayerLimit = _PlayerLimit;
        authorized[msg.sender] = true; // the creator of the contract is the only one who can deposit, since it's a trapdoor lottery
        emit LotteryCreated(N, PlayerLimit);
    }
    
    function start() public
    {
        require(authorized[msg.sender]); // only owner can start lottery
        require(keccak256(abi.encodePacked(LotteryStatus)) == keccak256('closed'));
        require(address(this).balance >= PlayerLimit); // at least 1 wei per winner :)
        LotteryStart = now;
        LotteryStatus = 'open';
        
        // re-initialize state
        Input = uint256(blockhash(block.number - 1)) % N; // must be input of VDF
        delete RawOutput;
        delete Output;
        delete Proof;
        delete Challenge;
        delete winners;
        for (uint256 i=0; i<players.length; i++) delete submissions[players[i]];
        delete players;
        emit LotteryOpened(Input);
    }
    
    function submit(uint256 Guess) public
    {
        require(keccak256(abi.encodePacked(LotteryStatus)) == keccak256('open') && now <= LotteryStart + LotteryDuration); // lottery needs to be Open
        require(submissions[msg.sender] == 0x0 && players.length <= PlayerLimit); // cannot play twice to increase win probability, cannot have more than limit of players
        require(Guess <= PlayerLimit); // the actual guess is a number capped to the player limit
        submissions[msg.sender] = Guess; // save guess
        players.push(msg.sender);
        emit Submitted(msg.sender, Guess);
    }
    
    function reveal(uint256 RawGuess, uint256 GuessProof) public
    {
        require(keccak256(abi.encodePacked(LotteryStatus)) == keccak256('open') && now > LotteryStart + LotteryDuration); // lottery needs to be Opena and waiting
        require(RawGuess <= N &&  GuessProof <= N); // must be elements of VDF
        uint256 _Challenge = HPrime(N, T, Input, RawGuess); // [Wes18] VDF proof system FiatShamir challenge
        require(RawGuess == mulmod(expmod(GuessProof, _Challenge, N), expmod(Input, expmod(2, T, _Challenge), N), N)); // [Wes18] VDF proof system check
        (RawOutput, Challenge, Proof, Output) = (RawGuess, _Challenge, GuessProof, RawGuess % (PlayerLimit+1)); // update globals
        emit Revealed(msg.sender, Output, RawOutput, Proof, Challenge);
        
        // find winners
        uint256 distance = PlayerLimit;
        for (uint256 i=0; i<players.length; i++)
        {
            uint256 new_distance =  absdiff(Output, submissions[players[i]]);
            if (new_distance <= distance)
            {
                if (new_distance != distance)
                {
                    distance = new_distance;
                    delete winners;
                }
                winners.push(players[i]);
            }
        }
        
        // assign rewards
        for (uint256 i=0; i<winners.length; i++)
        {
            winners[i].transfer(PlayerLimit / winners.length);
        }
        emit LotteryClosed(winners, distance);
    }
    
    function absdiff(uint256 a, uint256 b) pure private returns (uint256)
    {
        if (a>b) return a-b;
        return b-a;
    }
    
    function expmod(uint256 Base, uint256 Exponent, uint256 Modulus) pure private returns (uint256)
    {
        (uint256 a, uint256 b, uint256 e) = (Base, 1, Exponent);
        if (e==0) return b;
        if (e%2 == 1) b=a;
        e = e>>1;
        while (e>0) 
        {
            a = mulmod(a,a,Modulus);
            if (e%2 == 1) b = mulmod(a,b,Modulus);
            e = e>>1;
        }
        return b;
    }
  
    function HPrime(uint256 _N, uint256 _T, uint256 _X, uint256 _Y)  view public returns (uint256)
    {
        uint256 i = 0;
        while (true) {
            uint256 p = uint256(keccak256(abi.encodePacked(_N,_T,_X,_Y,i)));

            if (check_probable_pime(p)) return p;
            i = i+1;
        }
    }
    
     uint256[] private FIRST_256_PRIMES = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491, 499, 503, 509, 521, 523, 541, 547, 557, 563, 569, 571, 577, 587, 593, 599, 601, 607, 613, 617, 619, 631, 641, 643, 647, 653, 659, 661, 673, 677, 683, 691, 701, 709, 719, 727, 733, 739, 743, 751, 757, 761, 769, 773, 787, 797, 809, 811, 821, 823, 827, 829, 839, 853, 857, 859, 863, 877, 881, 883, 887, 907, 911, 919, 929, 937, 941, 947, 953, 967, 971, 977, 983, 991, 997, 1009, 1013, 1019, 1021, 1031, 1033, 1039, 1049, 1051, 1061, 1063, 1069, 1087, 1091, 1093, 1097, 1103, 1109, 1117, 1123, 1129, 1151, 1153, 1163, 1171, 1181, 1187, 1193, 1201, 1213, 1217, 1223, 1229, 1231, 1237, 1249, 1259, 1277, 1279, 1283, 1289, 1291, 1297, 1301, 1303, 1307, 1319, 1321, 1327, 1361, 1367, 1373, 1381, 1399, 1409, 1423, 1427, 1429, 1433, 1439, 1447, 1451, 1453, 1459, 1471, 1481, 1483, 1487, 1489, 1493, 1499, 1511, 1523, 1531, 1543, 1549, 1553, 1559, 1567, 1571, 1579, 1583, 1597, 1601, 1607, 1609, 1613, 1619];
     function check_probable_pime(uint256 p) view private returns (bool)
     {
        // trial division is faster than Miller-Rabin
        for (uint256 i=0; i<FIRST_256_PRIMES.length; i++){
            uint256 x = FIRST_256_PRIMES[i];
            if (p%x == 0) {
                if (p == x)    return true;
                else    return false;
            }
        }
        // final check with Miller-Rabin
        return miller_rabin(p, 256);
     }
     
    function miller_rabin(uint256 p, uint256 tests) view private returns (bool)
    {
                // factorize n-1 = 2^s * r, r is odd
        (uint256 even, uint256 s, uint256 r) = (p-1, 0, 1);
        while (even%2 == 0) {
            even = even/2;
            s = s+1;
        }
        r=even;

        // do the tests
        for (uint256 i=0; i<tests; i++) {
            uint256 a = (uint256(blockhash(block.number - 1 - i)) % (p-3)) + 2; // random number from 2 to p-2
            uint256 y = expmod(a,r,p);
            if (y != 1 && y != p-1){
                uint256 j = 1;
                while (j <= s-1 && y != p-1){
                    y = expmod(y,2,p);
                    if (y == 1)    return false;
                    j = j+1;
                }
                if (y != p-1)    return false;
            }
        }
        return true;
    }

    function ()  payable  external {
        require (authorized[msg.sender]); // must authorize people because the VDF is Trapdoor
    }
}
