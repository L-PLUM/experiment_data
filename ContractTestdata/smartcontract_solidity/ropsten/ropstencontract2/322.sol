/**
 *Submitted for verification at Etherscan.io on 2019-08-08
*/

pragma solidity ^0.5.0;


library SafeMath {
    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract EllipticCurve {

  
  
  
  
  function invMod(uint256 x, uint256 pp) public pure returns (uint256 q) {
    if (x == 0 || x == pp || pp == 0) {
      revert("Invalid number");
    }
    q = 0;
    uint256 newT = 1;
    uint256 r = pp;
    uint256 newR = x;
    uint256 t;
    while (newR != 0) {
      t = r / newR;
      (q, newT) = (newT, addmod(q, (pp - mulmod(t, newT, pp)), pp));
      (r, newR) = (newR, r - t * newR );
    }
  }

  
  
  
  
  
  
  function expMod(uint256 base, uint256 e, uint256 pp) public pure returns (uint256 r) {
    if (base == 0)
      return 0;
    if (e == 0)
      return 1;
    if (pp == 0)
      revert("Modulus is zero");
    r = 1;
    uint256 bit = 2 ** 255;

    assembly {
      for { } gt(bit, 0) { }{
        r := mulmod(mulmod(r, r, pp), exp(base, iszero(iszero(and(e, bit)))), pp)
        r := mulmod(mulmod(r, r, pp), exp(base, iszero(iszero(and(e, div(bit, 2))))), pp)
        r := mulmod(mulmod(r, r, pp), exp(base, iszero(iszero(and(e, div(bit, 4))))), pp)
        r := mulmod(mulmod(r, r, pp), exp(base, iszero(iszero(and(e, div(bit, 8))))), pp)
        bit := div(bit, 16)
      }
    }
  }

  
  
  
  
  
  
  function toAffine(
    uint256 x,
    uint256 y,
    uint256 z,
    uint pp)
  public pure returns (uint256 x2, uint256 y2)
  {
    uint zInv = invMod(z, pp);
    uint zInv2 = mulmod(zInv, zInv, pp);
    x2 = mulmod(x, zInv2, pp);
    y2 = mulmod(y, mulmod(zInv, zInv2, pp), pp);
  }

  
  
  
  
  
  
  
  function deriveY(
    uint8 prefix,
    uint256 x,
    uint256 a,
    uint256 b,
    uint256 pp)
  public pure returns (uint256 y)
  {
    
    uint256 y2 = addmod(mulmod(x, mulmod(x, x, pp), pp), addmod(mulmod(x, a, pp), b, pp), pp);
    uint256 y_ = expMod(y2, (pp + 1) / 4, pp);
    
    y = (y_ + prefix) % 2 == 0 ? y_ : pp - y_;
  }

  
  
  
  
  
  
  
  function isOnCurve(
    uint x,
    uint y,
    uint a,
    uint b,
    uint pp)
  public pure returns (bool)
  {
    if (0 == x || x == pp || 0 == y || y == pp) {
      return false;
    }
    
    uint lhs = mulmod(y, y, pp);
    
    uint rhs = mulmod(mulmod(x, x, pp), x, pp);
    if (a != 0) {
      
      rhs = addmod(rhs, mulmod(x, a, pp), pp);
    }
    if (b != 0) {
      
      rhs = addmod(rhs, b, pp);
    }

    return lhs == rhs;
  }

  
  
  
  
  
  function ecInv(
    uint256 x,
    uint256 y,
    uint256 pp)
  public pure returns (uint256 qx, uint256 qy)
  {
    (qx, qy) = (x, (pp - y) % pp);
  }

  
  
  
  
  
  
  
  
  function ecAdd(
    uint256 x1,
    uint256 y1,
    uint256 x2,
    uint256 y2,
    uint256 a,
    uint256 pp)
    public pure returns(uint256 qx, uint256 qy)
  {
    uint x = 0;
    uint y = 0;
    uint z = 0;
    
    if (x1==x2) {
      (x, y, z) = jacDouble(
        x1,
        y1,
        1,
        a,
        pp);
    } else {
      (x, y, z) = jacAdd(
        x1,
        y1,
        1,
        x2,
        y2,
        1,
        pp);
    }
    
    (qx, qy) = toAffine(
      x,
      y,
      z,
      pp);
  }

  
  
  
  
  
  
  
  
  function ecSub(
    uint256 x1,
    uint256 y1,
    uint256 x2,
    uint256 y2,
    uint256 a,
    uint256 pp)
  public pure returns(uint256 qx, uint256 qy)
  {
    
    (uint256 x, uint256 y) = ecInv(x2, y2, pp);
    
    (qx, qy) = ecAdd(
      x1,
      y1,
      x,
      y,
      a,
      pp);
  }

  
  
  
  
  
  
  
  function ecMul(
    uint256 d,
    uint256 x,
    uint256 y,
    uint256 a,
    uint256 pp)
  public pure returns(uint256 qx, uint256 qy)
  {
    
    (uint256 x1, uint256 y1, uint256 z1) = jacMul(
      d,
      x,
      y,
      1,
      a,
      pp);
    
    (qx, qy) = toAffine(
      x1,
      y1,
      z1,
      pp);
  }

  
  
  
  
  
  
  
  
  
  function jacAdd(
    uint256 x1,
    uint256 y1,
    uint256 z1,
    uint256 x2,
    uint256 y2,
    uint256 z2,
    uint256 pp)
  internal pure returns (uint256 qx, uint256 qy, uint256 qz)
  {
    if ((x1==0)&&(y1==0))
      return (x2, y2, z2);
    if ((x2==0)&&(y2==0))
      return (x1, y1, z1);
    

    uint[4] memory zs; 
    zs[0] = mulmod(z1, z1, pp);
    zs[1] = mulmod(z1, zs[0], pp);
    zs[2] = mulmod(z2, z2, pp);
    zs[3] = mulmod(z2, zs[2], pp);

    
    zs = [
      mulmod(x1, zs[2], pp),
      mulmod(y1, zs[3], pp),
      mulmod(x2, zs[0], pp),
      mulmod(y2, zs[1], pp)
    ];
    if (zs[0] == zs[2]) {
      if (zs[1] != zs[3])
        revert("Wrong data");
      else {
        revert("Use double instead");
      }
    }
    uint[4] memory hr;
    
    hr[0] = addmod(zs[2], pp - zs[0], pp);
    
    hr[1] = addmod(zs[3], pp - zs[1], pp);
    
    hr[2] = mulmod(hr[0], hr[0], pp);
    
    hr[3] = mulmod(hr[2], hr[0], pp);
    
    qx = addmod(mulmod(hr[1], hr[1], pp), pp - hr[3], pp);
    qx = addmod(qx, pp - mulmod(2, mulmod(zs[0], hr[2], pp), pp), pp);
    
    qy = mulmod(hr[1], addmod(mulmod(zs[0], hr[2], pp), pp - qx, pp), pp);
    qy = addmod(qy, pp - mulmod(zs[1], hr[3], pp), pp);
    
    qz = mulmod(hr[0], mulmod(z1, z2, pp), pp);
  }

  
  
  
  
  
  
  
  function jacDouble(
    uint256 x,
    uint256 y,
    uint256 z,
    uint256 a,
    uint256 pp)
  internal pure returns (uint256 qx, uint256 qy, uint256 qz)
  {
    if (z == 0)
      return (x, y, z);
    uint256[3] memory square;
    
    
    square[0] = mulmod(x, x, pp); 
    square[1] = mulmod(y, y, pp); 
    square[2] = mulmod(z, z, pp); 

    
    uint s = mulmod(4, mulmod(x, square[1], pp), pp);
    
    uint m = addmod(mulmod(3, square[0], pp), mulmod(a, mulmod(square[2], square[2], pp), pp), pp);
    
    uint256 t = addmod(mulmod(m, m, pp), pp - addmod(s, s, pp), pp);
    qx = t;
    
    qy = addmod(mulmod(m, addmod(s, pp - qx, pp), pp), pp - mulmod(8, mulmod(square[1], square[1], pp), pp), pp);
    
    qz = mulmod(2, mulmod(y, z, pp), pp);
  }

  
  
  
  
  
  
  
  
  function jacMul(
    uint256 d,
    uint256 x,
    uint256 y,
    uint256 z,
    uint256 a,
    uint256 pp)
  internal pure returns (uint256 qx, uint256 qy, uint256 qz)
  {
    uint256 remaining = d;
    uint256[3] memory point;
    point[0] = x;
    point[1] = y;
    point[2] = z;
    qx = 0;
    qy = 0;
    qz = 1;

    if (d == 0) {
      return (0, 0, 1);
    }
    
    while (remaining != 0) {
      if ((remaining & 1) != 0) {
        (qx, qy, qz) = jacAdd(
          qx,
          qy,
          qz,
          point[0],
          point[1],
          point[2],
          pp);
      }
      remaining = remaining / 2;
      (point[0], point[1], point[2]) = jacDouble(
        point[0],
        point[1],
        point[2],
        a,
        pp);
    }
  }
}

contract Secp256k1 is EllipticCurve {

  
  uint256 constant GX = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798;
  
  uint256 constant GY = 0x483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8;
  
  uint256 constant AA = 0;
  
  uint256 constant BB = 7;
  
  uint256 constant PP = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;
  
  uint256 constant NN = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141;

  
  
  
  
  
  function derivePoint(uint256 _d, uint256 _x, uint256 _y) public pure returns(uint256 qx, uint256 qy) {
    (qx, qy) = ecMul(
      _d,
      _x,
      _y,
      AA,
      PP
    );
  }

  
  
  
  
  function deriveY(uint8 _yByte, uint256 _x) public pure returns (uint256) {
    require(_yByte == 0x02 || _yByte == 0x03, "Invalid compressed EC point prefix");
    uint256 y2 = addmod(mulmod(_x, mulmod(_x, _x, PP), PP), 7, PP);
    uint256 y = expMod(y2, (PP + 1) / 4, PP);
    y = (y + _yByte) % 2 == 0 ? y : PP - y;

    return y;
  }
}

contract VRF is Secp256k1 {

  
  
  
  
  
  
  function verify(uint256[2] memory _publicKey, uint256[4] memory _proof, bytes memory _message) public pure returns (bool) {
    
    uint256[2] memory hPoint;
    (hPoint[0], hPoint[1]) = hashToTryAndIncrement(_publicKey, _message);

    
    (uint256 uPointX, uint256 uPointY) = ecMulSubMul(
      _proof[3],
      GX,
      GY,
      _proof[2],
      _publicKey[0],
      _publicKey[1]);

    
    (uint256 vPointX, uint256 vPointY) = ecMulSubMul(
      _proof[3],
      hPoint[0],
      hPoint[1],
      _proof[2],
      _proof[0],_proof[1]);

    
    bytes16 derivedC = hashPoints(
      hPoint[0],
      hPoint[1],
      _proof[0],
      _proof[1],
      uPointX,
      uPointY,
      vPointX,
      vPointY);

    
    return uint128(derivedC) == _proof[2];
  }

  
  
  
  
  
  
  
  
  
  function fastVerify(
    uint256[2] memory _publicKey,
    uint256[4] memory _proof,
    bytes memory _message,
    uint256[2] memory _uPoint,
    uint256[4] memory _vComponents)
  public pure returns (bool)
  {
    
    uint256[2] memory hPoint;
    (hPoint[0], hPoint[1]) = hashToTryAndIncrement(_publicKey, _message);

    
    
    
    if (!ecMulSubMulVerify(
      _proof[3],
      _proof[2],
      _publicKey[0],
      _publicKey[1],
      _uPoint[0],
      _uPoint[1]) ||
      !ecMulVerify(
        _proof[3],
        hPoint[0],
        hPoint[1],
        _vComponents[0],
        _vComponents[1]) ||
      !ecMulVerify(
        _proof[2],
        _proof[0],
        _proof[1],
        _vComponents[2],
        _vComponents[3])
      )
    {
      return false;
    }
    (uint256 vPointX, uint256 vPointY) = ecSub(
      _vComponents[0],
      _vComponents[1],
      _vComponents[2],
      _vComponents[3],
      AA,
      PP);

    
    bytes16 derivedC = hashPoints(
      hPoint[0],
      hPoint[1],
      _proof[0],
      _proof[1],
      _uPoint[0],
      _uPoint[1],
      vPointX,
      vPointY);

    
    return uint128(derivedC) == _proof[2];
  }

  
  
  
  function decodeProof(bytes memory _proof) public pure returns (uint[4] memory) {
    require(_proof.length == 81, "Malformed VRF proof");
    uint8 gammaSign;
    uint256 gammaX;
    uint128 c;
    uint256 s;
    assembly {
      gammaSign := mload(add(_proof, 1))
	    gammaX := mload(add(_proof, 33))
      c := mload(add(_proof, 49))
      s := mload(add(_proof, 81))
    }
    uint256 gammaY = deriveY(gammaSign, gammaX);

    return [
      gammaX,
      gammaY,
      c,
      s];
  }

  
  
  
  function decodePoint(bytes memory _point) public pure returns (uint[2] memory) {
    require(_point.length == 33, "Malformed compressed EC point");
    uint8 sign;
    uint256 x;
    assembly {
      sign := mload(add(_point, 1))
	    x := mload(add(_point, 33))
    }
    uint256 y = deriveY(sign, x);

    return [x, y];
  }

  
  
  
  
  
  function computeFastVerifyParams(uint256[2] memory _publicKey, uint256[4] memory _proof, bytes memory _message)
    public pure returns (uint256[2] memory, uint256[4] memory)
  {
    
    uint256[2] memory hPoint;
    (hPoint[0], hPoint[1]) = hashToTryAndIncrement(_publicKey, _message);
    (uint256 uPointX, uint256 uPointY) = ecMulSubMul(
      _proof[3],
      GX,
      GY,
      _proof[2],
      _publicKey[0],
      _publicKey[1]);
    
    (uint256 sHX, uint256 sHY) = derivePoint(_proof[3], hPoint[0], hPoint[1]);
    (uint256 cGammaX, uint256 cGammaY) = derivePoint(_proof[2], _proof[0], _proof[1]);

    return (
      [uPointX, uPointY],
      [
        sHX,
        sHY,
        cGammaX,
        cGammaY
      ]);
  }

  
  
  
  
  
  function hashToTryAndIncrement(uint256[2] memory _publicKey, bytes memory _message) internal pure returns (uint, uint) {
    
    uint cLength = 2 + 33 + _message.length + 1;
    bytes memory c = new bytes(cLength);

    
    bytes memory pkBytes = encodePoint(_publicKey[0], _publicKey[1]);

    
    
    c[0] = byte(uint8(254));
    c[1] = byte(uint8(1));
    for (uint i = 0; i < pkBytes.length; i++) {
      c[2+i] = pkBytes[i];
    }
    for (uint i = 0; i < _message.length; i++) {
      c[35+i] = _message[i];
    }

    
    
    for (uint8 ctr = 0; ctr < 256; ctr++) {
      
      c[cLength-1] = byte(ctr);
      bytes32 sha = sha256(c);
      
      uint hPointX = uint256(sha);
      uint hPointY = deriveY(2, hPointX);
      if (isOnCurve(
        hPointX,
        hPointY,
        AA,
        BB,
        PP))
      {
        
        
        return (hPointX, hPointY);
      }
    }
    revert("No valid point was found");
  }

  
  
  
  
  
  
  
  
  
  
  
  function hashPoints(
    uint256 _hPointX,
    uint256 _hPointY,
    uint256 _gammaX,
    uint256 _gammaY,
    uint256 _uPointX,
    uint256 _uPointY,
    uint256 _vPointX,
    uint256 _vPointY)
  internal pure returns (bytes16)
  {
    bytes memory c = new bytes(134);
    
    c[0] = byte(uint8(254));
    
    c[1] = byte(uint8(2));
    
    bytes memory hBytes = encodePoint(_hPointX, _hPointY);
    for (uint i = 0; i < hBytes.length; i++) {
      c[2+i] = hBytes[i];
    }
    bytes memory gammaBytes = encodePoint(_gammaX, _gammaY);
    for (uint i = 0; i < gammaBytes.length; i++) {
      c[35+i] = gammaBytes[i];
    }
    bytes memory uBytes = encodePoint(_uPointX, _uPointY);
    for (uint i = 0; i < uBytes.length; i++) {
      c[68+i] = uBytes[i];
    }
    bytes memory vBytes = encodePoint(_vPointX, _vPointY);
    for (uint i = 0; i < vBytes.length; i++) {
      c[101+i] = vBytes[i];
    }
    
    bytes32 sha = sha256(c);
    bytes16 half1;
    assembly {
      let freemem_pointer := mload(0x40)
      mstore(add(freemem_pointer,0x00), sha)
      half1 := mload(add(freemem_pointer,0x00))
    }

    return half1;
  }

  
  
  
  
  function encodePoint(uint256 _x, uint256 _y) internal pure returns (bytes memory) {
    uint8 prefix = uint8(2 + (_y % 2));

    return abi.encodePacked(prefix, _x);
  }

  
  
  
  
  
  
  
  
  function ecMulSubMul(
    uint256 _scalar1,
    uint256 _a1,
    uint256 _a2,
    uint256 _scalar2,
    uint256 _b1,
    uint256 _b2)
  internal pure returns (uint256, uint256)
  {
    (uint256 m1, uint256 m2) = derivePoint(_scalar1, _a1, _a2);
    (uint256 n1, uint256 n2) = derivePoint(_scalar2, _b1, _b2);
    (uint256 r1, uint256 r2) = ecSub(
      m1,
      m2,
      n1,
      n2,
      AA,
      PP);

    return (r1, r2);
  }

  
  
  
  
  
  
  
  
  
  function ecMulVerify(
    uint256 _scalar,
    uint256 _x,
    uint256 _y,
    uint256 _qx,
    uint256 _qy)
  internal pure returns(bool)
  {
    address result = ecrecover(
      0,
      _y % 2 != 0 ? 28 : 27,
      bytes32(_x),
      bytes32(mulmod(_scalar, _x, NN)));

    return pointToAddress(_qx, _qy) == result;
  }

  
  
  
  
  
  
  
  
  
  
  function ecMulSubMulVerify(
    uint256 _scalar1,
    uint256 _scalar2,
    uint256 _x,
    uint256 _y,
    uint256 _qx,
    uint256 _qy)
  internal pure returns(bool)
  {
    uint256 scalar1 = (NN - _scalar1) % NN;
    scalar1 = mulmod(scalar1, _x, NN);
    uint256 scalar2 = (NN - _scalar2) % NN;

    address result = ecrecover(
      bytes32(scalar1),
      _y % 2 != 0 ? 28 : 27,
      bytes32(_x),
      bytes32(mulmod(scalar2, _x, NN)));

    return pointToAddress(_qx, _qy) == result;
  }

  
  
  
  
  
  function pointToAddress(uint256 _x, uint256 _y)
      internal pure returns(address)
  {
    return address(uint256(keccak256(abi.encodePacked(_x, _y))) & 0x00FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF);
  }
}

contract BlockRelay {

  struct MerkleRoots {
    
    uint256 drHashMerkleRoot;
    
    uint256 tallyHashMerkleRoot;
  }
  struct Beacon {
    
    uint256 blockHash;
    
    uint256 epoch;
  }

  
  address witnet;
  
  Beacon lastBlock;

  mapping (uint256 => MerkleRoots) public blocks;

  
  event NewBlock(address indexed _from, uint256 _id);

  constructor() public{
    
    witnet = msg.sender;
  }

  
  modifier isOwner() {
    require(msg.sender == witnet, "Sender not authorized"); 
    _; 
  }
  
  modifier blockExists(uint256 _id){
    require(blocks[_id].drHashMerkleRoot!=0, "Non-existing block");
    _;
  }
   
  modifier blockDoesNotExist(uint256 _id){
    require(blocks[_id].drHashMerkleRoot==0, "The block already existed");
    _;
  }

  
  
  
  
  
  function postNewBlock(uint256 _blockHash, uint256 _epoch, uint256 _drMerkleRoot, uint256 _tallyMerkleRoot)
    public
    isOwner
    blockDoesNotExist(_blockHash)
  {
    uint256 id = _blockHash;
    lastBlock.blockHash = id;
    lastBlock.epoch = _epoch;
    blocks[id].drHashMerkleRoot = _drMerkleRoot;
    blocks[id].tallyHashMerkleRoot = _tallyMerkleRoot;
  }

  
  
  
  function readDrMerkleRoot(uint256 _blockHash)
    public
    view
    blockExists(_blockHash)
  returns(uint256 drMerkleRoot)
    {
    drMerkleRoot = blocks[_blockHash].drHashMerkleRoot;
  }

  
  
  
  function readTallyMerkleRoot(uint256 _blockHash)
    public
    view
    blockExists(_blockHash)
  returns(uint256 tallyMerkleRoot)
  {
    tallyMerkleRoot = blocks[_blockHash].tallyHashMerkleRoot;
  }

  
  
  function getLastBeacon()
    public
    view
  returns(bytes memory)
  {
    return abi.encodePacked(lastBlock.blockHash, lastBlock.epoch);
  }
}

contract WitnetBridgeInterface is VRF {

  using SafeMath for uint256;

  struct DataRequest {
    bytes dr;
    uint256 inclusionReward;
    uint256 tallyReward;
    bytes result;
    uint256 timestamp;
    uint256 drHash;
    address payable pkhClaim;
  }

  BlockRelay blockRelay;

  mapping (uint256 => DataRequest) public requests;

  
  event PostedRequest(address indexed _from, uint256 _id);

  
  event IncludedRequest(address indexed _from, uint256 _id);

  
  event PostedResult(address indexed _from, uint256 _id);

  
  modifier payingEnough(uint256 _value, uint256 _tally) {
    require(_value >= _tally, "Transaction value needs to be equal or greater than tally reward");
    _;
  }

  
  modifier poeValid(
    uint256[4] memory _poe,
    uint256[2] memory _publicKey,
    uint256[2] memory _uPoint,
    uint256[4] memory _vPointHelpers) {
    require(verifyPoe(_poe, _publicKey, _uPoint, _vPointHelpers) == true, "Not a valid PoE");
    _;
  }

  
  modifier validSignature(
    uint256[2] memory _publicKey,
    bytes memory addrSignature) {
    require(verifySig(abi.encodePacked(msg.sender), _publicKey, addrSignature) == true, "Not a valid signature");
    _;
  }

  
  modifier drNotIncluded(uint256 _id) {
    require(requests[_id].drHash == 0, "DR already included");
    _;
  }

  
  modifier drIncluded(uint256 _id) {
    require(requests[_id].drHash != 0, "DR not yet included");
    _;
  }
  
  modifier resultNotIncluded(uint256 _id) {
    require(requests[_id].result.length == 0, "Result already included");
    _;
  }

  constructor (address _blockRelayAddress) public {
    blockRelay = BlockRelay(_blockRelayAddress);
  }

  
  
  
  
  function postDataRequest(bytes memory _dr, uint256 _tallyReward)
    public
    payable
    payingEnough(msg.value, _tallyReward)
  returns(uint256 _id) {
    _id = uint256(sha256(_dr));
    if(requests[_id].dr.length != 0) {
      requests[_id].tallyReward += _tallyReward;
      requests[_id].inclusionReward += msg.value - _tallyReward;
      return _id;
    }

    requests[_id].dr = _dr;
    requests[_id].inclusionReward = msg.value - _tallyReward;
    requests[_id].tallyReward = _tallyReward;
    requests[_id].result = "";
    requests[_id].timestamp = 0;
    requests[_id].drHash = 0;
    requests[_id].pkhClaim = address(0);
    emit PostedRequest(msg.sender, _id);
    return _id;
  }

  
  
  
  function upgradeDataRequest(uint256 _id, uint256 _tallyReward)
    public
    payable
    payingEnough(msg.value, _tallyReward)
  {
    requests[_id].inclusionReward += msg.value - _tallyReward;
    requests[_id].tallyReward += _tallyReward;
  }

  
  
  
  
  
  function claimDataRequests(
    uint256[] memory _ids,
    uint256[4] memory _poe,
    uint256[2] memory _publicKey,
    uint256[2] memory _uPoint,
    uint256[4] memory _vPointHelpers,
    bytes memory addrSignature)
    public
    validSignature(_publicKey, addrSignature)
    poeValid(_poe,_publicKey, _uPoint,_vPointHelpers)
    returns(bool)
  {
    uint256 currentEpoch = block.number;
    uint256 index;
    for (uint i = 0; i < _ids.length; i++) {
      index = _ids[i];
      if((requests[index].timestamp == 0 || currentEpoch-requests[index].timestamp > 13) &&
      requests[index].drHash == 0 &&
      requests[index].result.length == 0){
        requests[index].pkhClaim = msg.sender;
        requests[index].timestamp = currentEpoch;
      }
      else{
        revert("One of the listed data requests was already claimed");
      }
    }
    return true;
  }

  
  
  
  
  
  function reportDataRequestInclusion (
    uint256 _id,
    uint256[] memory _poi,
    uint256 _index,
    uint256 _blockHash
    )
    public
    drNotIncluded(_id)
 {
    uint256 drRoot = blockRelay.readDrMerkleRoot(_blockHash);
    uint256 drHash = uint256(sha256(abi.encodePacked(_id, _poi[0])));
    if (verifyPoi(_poi, drRoot, _index, _id)) {
      requests[_id].drHash = drHash;
      requests[_id].pkhClaim.transfer(requests[_id].inclusionReward);
      emit IncludedRequest(msg.sender, _id);
    } else {
      revert("Invalid PoI");
    }
  }

  
  
  
  
  
  
  function reportResult (
    uint256 _id,
    uint256[] memory _poi,
    uint256 _index,
    uint256 _blockHash,
    bytes memory _result
    )
    public
    drIncluded(_id)
    resultNotIncluded(_id)
 {
    uint256 tallyRoot = blockRelay.readTallyMerkleRoot(_blockHash);
    
    uint256 resHash = uint256(sha256(abi.encodePacked(requests[_id].drHash, _result)));
    if (verifyPoi(_poi, tallyRoot, _index, resHash)){
      requests[_id].result = _result;
      msg.sender.transfer(requests[_id].tallyReward);
      emit PostedResult(msg.sender, _id);
    }
    else{
      revert("Invalid PoI");
    }
  }

  
  
  
  function readDataRequest (uint256 _id) public view returns(bytes memory){
    return requests[_id].dr;
  }

  
  
  
  function readResult (uint256 _id) public view returns(bytes memory){
    return requests[_id].result;
  }

  
  
  
  function readDrHash (uint256 _id) public view returns(uint256){
    return requests[_id].drHash;
  }

  
  
  function getLastBeacon()
    public
    view
  returns(bytes memory)
  {
    return blockRelay.getLastBeacon();
  }

  
  
  
  
  
  function verifyPoe(
    uint256[4] memory _poe,
    uint256[2] memory _publicKey,
    uint256[2] memory _uPoint,
    uint256[4] memory _vPointHelpers)
  internal view returns(bool) {
    bytes memory message = getLastBeacon();

    return fastVerify(
      _publicKey,
      _poe,
      message,
      _uPoint,
      _vPointHelpers);
  }

  
  
  
  
  
  
  function verifyPoi(
    uint256[] memory _poi,
    uint256 _root,
    uint256 _index,
    uint256 _element)
  internal pure returns(bool){
    uint256 tree = _element;
    uint256 index = _index;
    for (uint i = 0; i<_poi.length; i++){
      if(index%2 == 0){
        tree = uint256(sha256(abi.encodePacked(tree, _poi[i])));
      }
      else{
        tree = uint256(sha256(abi.encodePacked(_poi[i], tree)));
      }
      index = index>>1;
    }
    return _root==tree;
  }

  
  
  
  
  
  function verifySig(
    bytes memory _message,
    uint256[2] memory _publicKey,
    bytes memory _addrSignature
    )
  internal returns(bool){
    bytes32 r;
    bytes32 s;
    uint8 v;
    assembly {
            r := mload(add(_addrSignature, 0x20))
            s := mload(add(_addrSignature, 0x40))
            v := byte(0, mload(add(_addrSignature, 0x60)))
    }

    if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
      return false;
    }

    if (v != 0 && v != 1) {
      return false;
    }
    v = 28 - v;

    bytes32 msg_hash = sha256(_message);
    address hashed_key = pointToAddress(_publicKey[0], _publicKey[1]);
    return ecrecover(msg_hash, v, r, s) == hashed_key;
  }
}
