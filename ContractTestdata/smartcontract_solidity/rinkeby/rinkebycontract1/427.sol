/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.4.24;
pragma experimental ABIEncoderV2;

contract ParentLib {
  //////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////

    /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    c = _a * _b;
    assert(c / _a == _b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // assert(_b > 0); // Solidity automatically throws when dividing by 0
    // uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold
    return _a / _b;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    assert(_b <= _a);
    return _a - _b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {
    c = _a + _b;
    assert(c >= _a);
    return c;
  }

    uint256 constant public gx = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
    uint256 constant public gy = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
    uint256 constant public n = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
    uint256 constant public a = 0;
    uint256 constant public b = 7;

    function _jAdd(
        uint256 x1, uint256 z1,
        uint256 x2, uint256 z2)
        public
        pure
        returns(uint256 x3, uint256 z3)
    {
        (x3, z3) = (
            addmod(
                mulmod(z2, x1, n),
                mulmod(x2, z1, n),
                n
            ),
            mulmod(z1, z2, n)
        );
    }

    function _jSub(
        uint256 x1, uint256 z1,
        uint256 x2, uint256 z2)
        public
        pure
        returns(uint256 x3, uint256 z3)
    {
        (x3, z3) = (
            addmod(
                mulmod(z2, x1, n),
                mulmod(n - x2, z1, n),
                n
            ),
            mulmod(z1, z2, n)
        );
    }

    function _jMul(
        uint256 x1, uint256 z1,
        uint256 x2, uint256 z2)
        public
        pure
        returns(uint256 x3, uint256 z3)
    {
        (x3, z3) = (
            mulmod(x1, x2, n),
            mulmod(z1, z2, n)
        );
    }

    function _jDiv(
        uint256 x1, uint256 z1,
        uint256 x2, uint256 z2)
        public
        pure
        returns(uint256 x3, uint256 z3)
    {
        (x3, z3) = (
            mulmod(x1, z2, n),
            mulmod(z1, x2, n)
        );
    }

    function _inverse(uint256 val) public pure
        returns(uint256 invVal)
    {
        uint256 t = 0;
        uint256 newT = 1;
        uint256 r = n;
        uint256 newR = val;
        uint256 q;
        while (newR != 0) {
            q = r / newR;

            (t, newT) = (newT, addmod(t, (n - mulmod(q, newT, n)), n));
            (r, newR) = (newR, r - q * newR );
        }

        return t;
    }

    function _ecAdd(
        uint256 x1, uint256 y1, uint256 z1,
        uint256 x2, uint256 y2, uint256 z2)
        public
        pure
        returns(uint256 x3, uint256 y3, uint256 z3)
    {
        uint256 lx;
        uint256 lz;
        uint256 da;
        uint256 db;

        if (x1 == 0 && y1 == 0) {
            return (x2, y2, z2);
        }

        if (x2 == 0 && y2 == 0) {
            return (x1, y1, z1);
        }

        if (x1 == x2 && y1 == y2) {
            (lx, lz) = _jMul(x1, z1, x1, z1);
            (lx, lz) = _jMul(lx, lz, 3, 1);
            (lx, lz) = _jAdd(lx, lz, a, 1);

            (da,db) = _jMul(y1, z1, 2, 1);
        } else {
            (lx, lz) = _jSub(y2, z2, y1, z1);
            (da, db) = _jSub(x2, z2, x1, z1);
        }

        (lx, lz) = _jDiv(lx, lz, da, db);

        (x3, da) = _jMul(lx, lz, lx, lz);
        (x3, da) = _jSub(x3, da, x1, z1);
        (x3, da) = _jSub(x3, da, x2, z2);

        (y3, db) = _jSub(x1, z1, x3, da);
        (y3, db) = _jMul(y3, db, lx, lz);
        (y3, db) = _jSub(y3, db, y1, z1);

        if (da != db) {
            x3 = mulmod(x3, db, n);
            y3 = mulmod(y3, da, n);
            z3 = mulmod(da, db, n);
        } else {
            z3 = da;
        }
    }

    function _ecDouble(uint256 x1, uint256 y1, uint256 z1) public pure
        returns(uint256 x3, uint256 y3, uint256 z3)
    {
        (x3, y3, z3) = _ecAdd(x1, y1, z1, x1, y1, z1);
    }

    function _ecMul(uint256 d, uint256 x1, uint256 y1, uint256 z1) public pure
        returns(uint256 x3, uint256 y3, uint256 z3)
    {
        uint256 remaining = d;
        uint256 px = x1;
        uint256 py = y1;
        uint256 pz = z1;
        uint256 acx = 0;
        uint256 acy = 0;
        uint256 acz = 1;

        if (d == 0) {
            return (0, 0, 1);
        }

        while (remaining != 0) {
            if ((remaining & 1) != 0) {
                (acx,acy,acz) = _ecAdd(acx, acy, acz, px, py, pz);
            }
            remaining = remaining / 2;
            (px, py, pz) = _ecDouble(px, py, pz);
        }

        (x3, y3, z3) = (acx, acy, acz);
    }

    function ecadd(
        uint256 x1, uint256 y1,
        uint256 x2, uint256 y2)
        public
        pure
        returns(uint256 x3, uint256 y3)
    {
        uint256 z;
        (x3, y3, z) = _ecAdd(x1, y1, 1, x2, y2, 1);
        z = _inverse(z);
        x3 = mulmod(x3, z, n);
        y3 = mulmod(y3, z, n);
    }

    function ecmul(uint256 x1, uint256 y1, uint256 scalar) public pure
        returns(uint256 x2, uint256 y2)
    {
        uint256 z;
        (x2, y2, z) = _ecMul(scalar, x1, y1, 1);
        z = _inverse(z);
        x2 = mulmod(x2, z, n);
        y2 = mulmod(y2, z, n);
    }

    //
    // Based on the original idea of Vitalik Buterin:
    // https://ethresear.ch/t/you-can-kinda-abuse-ecrecover-to-do-ecmul-in-secp256k1-today/2384/9
    //
    function ecmulVerify(uint256 x1, uint256 y1, uint256 scalar, uint256 qx, uint256 qy) public pure
        returns(bool)
    {
        uint256 m = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
        address signer = ecrecover(0, y1 % 2 != 0 ? 28 : 27, bytes32(x1), bytes32(mulmod(scalar, x1, m)));
        address xyAddress = address(uint256(keccak256(abi.encodePacked(qx, qy))) & 0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
        return (xyAddress == signer);
    }

    function publicKey(uint256 privKey) public pure
        returns(uint256 qx, uint256 qy)
    {
        return ecmul(gx, gy, privKey);
    }

    function publicKeyVerify(uint256 privKey, uint256 x, uint256 y) public pure
        returns(bool)
    {
        return ecmulVerify(gx, gy, privKey, x, y);
    }

    function deriveKey(uint256 privKey, uint256 pubX, uint256 pubY) public pure
        returns(uint256 qx, uint256 qy)
    {
        uint256 z;
        (qx, qy, z) = _ecMul(privKey, pubX, pubY, 1);
        z = _inverse(z);
        qx = mulmod(qx, z, n);
        qy = mulmod(qy, z, n);
    }

    function onCurve(uint[2] P) public pure returns (bool) {
        uint p = n;
        if (0 == P[0] || P[0] == p || 0 == P[1] || P[1] == p)
            return false;
        uint LHS = mulmod(P[1], P[1], p);
        uint RHS = addmod(mulmod(mulmod(P[0], P[0], p), P[0], p), 7, p);
        return LHS == RHS;
    }


    function isPubKey(uint[2] memory P) public pure returns (bool isPK) {
        isPK = onCurve(P);
    }


  

  /*
  uint256 Gx, uint256 Gy,uint256 Ax, uint256 Ay, uint256 Bx, uint256 By, uint256 Cx, uint256 Cy,
  uint256 s, uint256 y1x, uint256 y1y, uint256 y2x, uint256 y2y, uint256 z,
  uint256 zGx, uint256 zGy, uint256 sAx, uint256 sAy,
  uint256 zBx, uint256 zBy, uint256 sCx, uint256 sCy
  Contract needs to verify the correctness of scalar multiplication of elliptic curve points,
  for that end we use ecrecover, a trick suggested by Vitalik:
  https://ethresear.ch/t/you-can-kinda-abuse-ecrecover-to-do-ecmul-in-secp256k1-today/2384
  */
  function verifyChaumPedersen(uint256[22] params) public pure returns (bool) {
    uint256[12] memory params1 = [params[0], params[1], params[2], params[3], params[9], params[10], params[8], params[13], params[14], params[15], params[16], params[17]];
    bool b1 = verifyChaumPedersenSub(params1);
    uint256[12] memory params2 = [params[4], params[5], params[6], params[7], params[11], params[12], params[8], params[13], params[18], params[19], params[20], params[21]];
    bool b2 = verifyChaumPedersenSub(params2);

    return b1 && b2;
  }

/*
  uint256 Gx, uint256 Gy, uint256 Ax, uint256 Ay, uint256 y1x, uint256 y1y,
  uint256 s, uint256 z, uint256 zGx, uint256 zGy, uint256 sAx, uint256 sAy

  uint256 Bx, uint256 By, uint256 Cx, uint256 Cy, uint256 y2x, uint256 y2y,
  uint256 s, uint256 z, uint256 zBx, uint256 zBy, uint256 sCx, uint256 sCy
  */
  function verifyChaumPedersenSub(uint256[12] params) internal pure returns (bool) {
    require(ecmulVerify(params[0], params[1], params[7], params[8], params[9]));
    require(ecmulVerify(params[2], params[3], params[6], params[10], params[11]));

    (uint256 sCy2x, uint256 sCy2y)= ecadd(params[10], params[11], params[4], params[5]);

    return (params[8] == sCy2x) && (params[9] == sCy2y);
  }

  uint256 constant public n2 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;
  

/*
  uint256 Gx, uint256 Gy, uint256 pKx, uint256 pKy,
  uint256 msgHash, uint256 r, uint256 s,
  uint256 u1Gx, uint256 u1Gy, uint256 u2pKx, uint256 u2pKy,
  uint256 w
*/
  function verify(uint256[12] params) public pure returns(bool) {

    uint256 u1 = mulmod(params[4], params[11], n2);
    uint256 u2 = mulmod(params[5], params[11], n2);
    require(ecmulVerify(params[0], params[1], u1, params[7], params[8]));
    require(ecmulVerify(params[2], params[3], u2, params[9], params[10]));

    (uint Qx, uint Qy) = ecadd(params[7], params[8], params[9], params[10]);

    return (Qx == params[5]);
  }



  /////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////
}
// File: openzeppelin-solidity/contracts/math/SafeMath.sol



/*
 * ERC223 token compatible contract
**/
contract ERC223ReceivingContract {
    // See: https://github.com/Dexaran/ERC223-token-standard/blob/Recommended/Receiver_Interface.sol
    struct Token {
        address sender;
        uint value;
        bytes data;
        bytes4 sig;
    }

    function tokenFallback(address from, uint value, bytes data) public pure {
        Token memory tkn;
        tkn.sender = from;
        tkn.value = value;
        tkn.data = data;
        uint32 u = uint32(data[3]) + (uint32(data[2]) << 8) + (uint32(data[1]) << 16) + (uint32(data[0]) << 24);
        tkn.sig = bytes4(u);
    }
}

/*
 * Declare the ERC20Compatible interface in order to handle ERC20 tokens transfers
 * to and from the Mixer. Note that we only declare the functions we are interested in,
 * namely, transferFrom() (used to do a Deposit), and transfer() (used to do a withdrawal)
**/
contract ERC20Compatible {
  function transferFrom(address from, address to, uint256 value) public;
  function transfer(address to, uint256 value) public;
}

contract MixEth is ERC223ReceivingContract {
    ParentLib lib;
    
    constructor(ParentLib _lib) public {
        lib = _lib;
    }
   
uint256 public amt = 100000000000000000; //1 ether in wei, the amount of ether to be mixed;
  uint256 public shufflingDeposit = 100000000000000000; // 1 ether, TBD
  mapping(address => bool) public shuffleRound; //token address to the parity of the round. we only store the parity of the shuffle round! false -> 0, true -> 1
  mapping(address => Status) public shufflers; //shuffler address to their state
  mapping(address => mapping(bool => Shuffle)) public Shuffles; //token address to round to shuffle

  /*
  describes a shuffle: contains the shuffled pubKeys and shuffling accumulated constant
  */
  struct Shuffle {
    mapping(uint256 => bool) shuffle; //whether a particular point is present in the shuffle or not
    uint256[2] shufflingAccumulatedConstant; //C^*, the new generator curve point
    address shuffler;
    uint256 noOfPoints; //note that one of these points is always the shuffling accumulated constant
    uint256 blockNo;
  }

  struct Status {
    bool alreadyShuffled;
    bool slashed;
  }

  event newDeposit(address indexed token, bool actualRound, uint256[2] newPubKey);
  event newShuffle(address indexed token, bool actualRound, address shuffler, uint256[] shuffle, uint256[2] shufflingAccumulatedConstant);
  event successfulChallenge(address indexed token, bool actualRound, address shuffler);
  event successfulWithdraw(address indexed token, bool actualRound, uint256[2] withdrawnPubKey);

  function () public {
    revert();
  }
  
  function depositEther(uint256 initPubKeyX, uint256 initPubKeyY) public payable onlyInWithdrawalDepositPeriod(0x0) {
    require(msg.value == amt, "Ether denomination is not correct!");
    require(lib.onCurve([initPubKeyX, initPubKeyY]), "Invalid public key!");
    require(!Shuffles[0x0][shuffleRound[0x0]].shuffle[initPubKeyX] &&
      !Shuffles[0x0][shuffleRound[0x0]].shuffle[initPubKeyY], "This public key was already added to the shuffle");
    Shuffles[0x0][shuffleRound[0x0]].shuffle[initPubKeyX] = true;
    Shuffles[0x0][shuffleRound[0x0]].shuffle[initPubKeyY] = true;
    Shuffles[0x0][shuffleRound[0x0]].noOfPoints = Shuffles[0x0][shuffleRound[0x0]].noOfPoints + 1;

    emit newDeposit(0x0, shuffleRound[0x0], [initPubKeyX, initPubKeyY]);
  }

  /*
     * Deposit a specific denomination of ERC20 compatible tokens which can only be withdrawn
     * by providing a modified ECDSA sig by one of the public keys.
    **/
  function depositERC20Compatible(address token, uint256 initPubKeyX, uint256 initPubKeyY) public onlyInWithdrawalDepositPeriod(token) {
    uint256 codeLength;
    assembly {
        codeLength := extcodesize(token)
    }
    require(token != 0 && codeLength > 0);
    require(lib.onCurve([initPubKeyX, initPubKeyY]), "Invalid public key!");
    require(!Shuffles[token][shuffleRound[token]].shuffle[initPubKeyX] &&
      !Shuffles[token][shuffleRound[token]].shuffle[initPubKeyY], "This public key was already added to the shuffle");
    Shuffles[token][shuffleRound[token]].shuffle[initPubKeyX] = true;
    Shuffles[token][shuffleRound[token]].shuffle[initPubKeyY] = true;
    Shuffles[token][shuffleRound[token]].noOfPoints = Shuffles[token][shuffleRound[token]].noOfPoints + 1;

    ERC20Compatible untrustedErc20Token = ERC20Compatible(token);
    untrustedErc20Token.transferFrom(msg.sender, this, 100);

    emit newDeposit(token, shuffleRound[token], [initPubKeyX, initPubKeyY]);
  }
  
  

  /*
    @param address token: refers to the token address shuffler wants to shuffle
    @param uint256[] _oldShuffle: refers to the last but one to-be-deleted shuffle
    @param uint256[] _shuffle: the new to-be-uploaded shuffle
  */
  function uploadShuffle(address token, uint256[] _oldShuffle, uint256[] _shuffle, uint256[2] _newShufflingConstant) public onlyInShufflingPeriod(token) payable {
    require(msg.value == shufflingDeposit+(_shuffle.length/2-Shuffles[token][shuffleRound[token]].noOfPoints)*1 ether, "Invalid shuffler deposit amount!"); //shuffler can also deposit new pubkeys
    //require(!shufflers[msg.sender].alreadyShuffled, "Shuffler is not allowed to shuffle more than once!");
    require(_oldShuffle.length/2 == Shuffles[token][!shuffleRound[token]].noOfPoints, "Incorrectly referenced the last but one shuffle");
    // remove the last but one shuffler
    for(uint256 i = 0; i < _oldShuffle.length; i++) {
      require(Shuffles[token][!shuffleRound[token]].shuffle[_oldShuffle[i]],"A public key was added twice to the shuffle");
      Shuffles[token][!shuffleRound[token]].shuffle[_oldShuffle[i]] = false;
    }
    
    Shuffles[token][!shuffleRound[token]].shufflingAccumulatedConstant[0] = _newShufflingConstant[0];
    Shuffles[token][!shuffleRound[token]].shufflingAccumulatedConstant[1] = _newShufflingConstant[1];
    
      //upload new shuffle
    for(i = 0; i < _shuffle.length; i++) {
        require(!Shuffles[token][!shuffleRound[token]].shuffle[_shuffle[i]], "Public keys can be added only once to the shuffle!");
        Shuffles[token][!shuffleRound[token]].shuffle[_shuffle[i]] = true;
    }
    
    
    Shuffles[token][!shuffleRound[token]].shuffler = msg.sender;
    Shuffles[token][!shuffleRound[token]].noOfPoints = (_shuffle.length)/2;
    Shuffles[token][!shuffleRound[token]].blockNo = block.number;
    shuffleRound[token] = !shuffleRound[token];
    shufflers[msg.sender].alreadyShuffled = true; // a receiver can only shuffle once

    emit newShuffle(token, !shuffleRound[token], msg.sender, _shuffle, _newShufflingConstant);


    
    
  }
  
  
  /*
    MixEth checks the correctness of the round-th shuffle
    which is stored at Shuffles[round].
    If challenge accepted malicious shuffler's deposit is slashed.
  */
  function challengeShuffle(uint256[22] proofTranscript, address token) public onlyInChallengingPeriod(token) {
    bool round = shuffleRound[token]; //only current shuffles can be challenged
    require(proofTranscript[0] == Shuffles[token][!round].shufflingAccumulatedConstant[0]
      && proofTranscript[1] == Shuffles[token][!round].shufflingAccumulatedConstant[1], "Wrong shuffling accumulated constant for previous round "); //checking correctness of C*_{i-1}
    require(Shuffles[token][!round].shuffle[proofTranscript[2]] && Shuffles[token][!round].shuffle[proofTranscript[3]], "Shuffled key is not included in previous round"); //checking that shuffled key is indeed included in previous shuffle
    require(proofTranscript[4] == Shuffles[token][round].shufflingAccumulatedConstant[0]
      && proofTranscript[5] == Shuffles[token][round].shufflingAccumulatedConstant[1], "Wrong current shuffling accumulated constant"); //checking correctness of C*_{i}
    require(!Shuffles[token][round].shuffle[proofTranscript[6]] || !Shuffles[token][round].shuffle[proofTranscript[7]], "Final public key is indeed included in current shuffle");
    require(lib.verifyChaumPedersen(proofTranscript), "Chaum-Pedersen Proof not verified");
    shufflers[Shuffles[token][round].shuffler].slashed = true;
    shuffleRound[token] = !shuffleRound[token];

    emit successfulChallenge(token, round, Shuffles[token][round].shuffler);
  }

  //receivers can withdraw funds at most once
  function withdrawAmt(uint256[12] sig) public {
    withdrawChecks(sig, 0x0);

    msg.sender.transfer(amt);
  }

  function withdrawERC20Compatible(uint256[12] sig, address token) public {
    withdrawChecks(sig, token);

    ERC20Compatible untrustedErc20Token = ERC20Compatible(token);
    untrustedErc20Token.transfer(msg.sender, 100); //to-be-overwritten TODO:
   }

   function withdrawChecks(uint256[12] sig, address token) internal onlyInWithdrawalDepositPeriod(token) {
     require(Shuffles[token][shuffleRound[token]].shuffle[sig[2]] && Shuffles[token][shuffleRound[token]].shuffle[sig[3]], "Your public key is not included in the final shuffle!"); //public key is included in Shuffled
     require(sig[0] == Shuffles[token][shuffleRound[token]].shufflingAccumulatedConstant[0]
       && sig[1] == Shuffles[token][shuffleRound[token]].shufflingAccumulatedConstant[1], "Your signature is using a wrong generator!"); //shuffling accumulated constant is correct
     require(sig[4] == uint(keccak256(abi.encodePacked(msg.sender, sig[2], sig[3]))), "Signed an invalid message!"); //this check is needed to deter front-running attacks
     require(lib.verify(sig), "Your signature is not verified!");
     Shuffles[token][shuffleRound[token]].shuffle[sig[2]] = false;
     Shuffles[token][shuffleRound[token]].shuffle[sig[3]] = false;
     Shuffles[token][shuffleRound[token]].noOfPoints = Shuffles[token][shuffleRound[token]].noOfPoints - 1;

     emit successfulWithdraw(token, shuffleRound[token], [sig[2], sig[3]]);
   }


  
  
  
  function withdrawDeposit() public onlyShuffler onlyHonestShuffler {
    shufflers[msg.sender].slashed = true; //we only allow to withdraw shuffler deposits once
    msg.sender.transfer(shufflingDeposit);
  }

  //maybe these time parameters needs to be changed, but might be enough
  modifier onlyInChallengingPeriod(address token) {
    //require(block.number <= Shuffles[token][shuffleRound[token]].blockNo + 10, "You can not challenge this shuffle right now!");
    _;
  }

  modifier onlyInWithdrawalDepositPeriod(address token) {
    //require(Shuffles[token][shuffleRound[token]].blockNo + 10 < block.number, "You can not withdraw/deposit right now!");
    _;
  }

  modifier onlyInShufflingPeriod(address token) {
    //require(Shuffles[token][shuffleRound[token]].blockNo + 20 < block.number, "You can not shuffle right now!");
    _;
  }

  modifier onlyShuffler() {
    require(shufflers[msg.sender].alreadyShuffled, "You have not shuffled!");
    _;
  }

  modifier onlyHonestShuffler() {
    require(!shufflers[msg.sender].slashed, "Your shuffling deposit has been slashed!");
    _;
  }




















}
