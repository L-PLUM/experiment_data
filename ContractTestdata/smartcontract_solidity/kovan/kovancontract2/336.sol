/**
 *Submitted for verification at Etherscan.io on 2019-07-16
*/

/*
 * semaphorejs - Zero-knowledge signaling on Ethereum
 * Copyright (C) 2019 Kobi Gurkan <[email protected]>
 *
 * This file is part of semaphorejs.
 *
 * semaphorejs is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * semaphorejs is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with semaphorejs.  If not, see <http://www.gnu.org/licenses/>.
 */
pragma experimental ABIEncoderV2;
pragma solidity >=0.4.21;

library MiMC {
    function MiMCSponge(uint256 in_xL, uint256 in_xR, uint256 in_k)  pure public returns (uint256 xL, uint256 xR);
}
library SafeMath {

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
}

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() pure internal returns (G1Point) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() pure internal returns (G2Point) {
        // Original code point
        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );

/*
        // Changed by Jordi point
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
*/
    }
    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point p) pure internal returns (G1Point) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return the sum of two points of G1
    function addition(G1Point p1, G1Point p2) view internal returns (G1Point r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := staticcall(sub(gas, 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
    }
    /// @return the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point p, uint s) view internal returns (G1Point r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := staticcall(sub(gas, 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] p1, G2Point[] p2) view internal returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := staticcall(sub(gas, 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point a1, G2Point a2, G1Point b1, G2Point b2) view internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point a1, G2Point a2,
            G1Point b1, G2Point b2,
            G1Point c1, G2Point c2
    ) view internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point a1, G2Point a2,
            G1Point b1, G2Point b2,
            G1Point c1, G2Point c2,
            G1Point d1, G2Point d2
    ) view internal returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}
contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alfa1;
        Pairing.G2Point beta2;
        Pairing.G2Point gamma2;
        Pairing.G2Point delta2;
        Pairing.G1Point[] IC;
    }
    struct Proof {
        Pairing.G1Point A;
        Pairing.G2Point B;
        Pairing.G1Point C;
    }
    function verifyingKey() pure internal returns (VerifyingKey vk) {
        vk.alfa1 = Pairing.G1Point(17683828522671550336182899537058064367381756607935117375915519250796159764593,2487065338450330789536951530390891162669275986491425319751523724572549309787);
        vk.beta2 = Pairing.G2Point([14633319191705470440152280690827370641835380660214072788865047565537671724588,2154528846155286628376163349369064884538825884889094902899202440216183231423], [11957314154028067119713992664074931894963027502706021055780876480901594915717,10521800516669572397134547043414502518608901747522859878221517746170129517571]);
        vk.gamma2 = Pairing.G2Point([3637754078793281332581999779811181113750453919926888170599142276734832171050,15356520385171861303128084947230177452153118312565379808822344787510570899260], [12738508143863343666354258065786428068150660927665855336309836860367524049033,13057219449188430165473633784748040695164482646950625962751911502696475064709]);
        vk.delta2 = Pairing.G2Point([19823163797610377216042575766115826751662918541085084619814896381707242123636,21696616653881040238280888879827655717627012003085718735077912896671359418301], [190625003721887350395407645644304679136817477830364489136699878282273192273,19355426986353570179744790259822180541894315571416498514750659903374679254103]);
        vk.IC = new Pairing.G1Point[](6);
        vk.IC[0] = Pairing.G1Point(19292368971449044939077623657509110308006351683344994483437602835596926040524,1493554804965455105729346652231781735154512796266649008338675028836029292580);
        vk.IC[1] = Pairing.G1Point(4877102174734571171455329657163059007609069255047414457018746926317916765900,4980206126297808376586862901900221610922787174773073453323293636265467658790);
        vk.IC[2] = Pairing.G1Point(18668159845093676713694542246541143022934786810863974120232292009106097383334,4237552447340530555703347923271281124745711135495575056872420119250117263023);
        vk.IC[3] = Pairing.G1Point(1817354792827551113568459389300482945865563666951506456107667072514088272017,8113389432290754432368685626372527860729207495729030196118524696686891752433);
        vk.IC[4] = Pairing.G1Point(3932290138012685434949608831730545706217186895464479936357073386112244343624,11295038345027366933121843500026516357214519104701311567397707310016815627778);
        vk.IC[5] = Pairing.G1Point(20797709725407736246751349891647422039172574316763357883789740761019600324804,16444684158634924934708698169950645142580787699427030476484501626568628457000);

    }
    function verify(uint[] input, Proof proof) view internal returns (uint) {
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++)
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        vk_x = Pairing.addition(vk_x, vk.IC[0]);
        if (!Pairing.pairingProd4(
            Pairing.negate(proof.A), proof.B,
            vk.alfa1, vk.beta2,
            vk_x, vk.gamma2,
            proof.C, vk.delta2
        )) return 1;
        return 0;
    }
    function verifyProof(
            uint[2] a,
            uint[2][2] b,
            uint[2] c,
            uint[5] input
        ) view public returns (bool r) {
        Proof memory proof;
        proof.A = Pairing.G1Point(a[0], a[1]);
        proof.B = Pairing.G2Point([b[0][0], b[0][1]], [b[1][0], b[1][1]]);
        proof.C = Pairing.G1Point(c[0], c[1]);
        uint[] memory inputValues = new uint[](input.length);
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}


contract MultipleMerkleTree {
    uint8[] levels;

    uint256[] internal tree_roots;
    uint256[][] filled_subtrees;
    uint256[][] zeros;

    uint32[] next_index;

    event LeafAdded(uint8 tree_index, uint256 leaf, uint32 leaf_index);
    event LeafUpdated(uint8 tree_index, uint256 leaf, uint32 leaf_index);

    function init_tree(uint8 tree_levels, uint256 zero_value) public returns (uint8 tree_index) {
        levels.push(tree_levels);

        uint256[] memory current_zeros = new uint256[](tree_levels);
        current_zeros[0] = zero_value;

        uint256[] memory current_filled_subtrees = new uint256[](tree_levels);
        current_filled_subtrees[0] = current_zeros[0];

        for (uint8 i = 1; i < tree_levels; i++) {
            current_zeros[i] = HashLeftRight(current_zeros[i-1], current_zeros[i-1]);
            current_filled_subtrees[i] = current_zeros[i];
        }

        zeros.push(current_zeros);
        filled_subtrees.push(current_filled_subtrees);

        tree_roots.push(HashLeftRight(current_zeros[tree_levels - 1], current_zeros[tree_levels - 1]));
        next_index.push(0);

        return uint8(tree_roots.length) - 1;
    }

    function HashLeftRight(uint256 left, uint256 right) public pure returns (uint256 mimc_hash) {
        uint256 k =  21888242871839275222246405745257275088548364400416034343698204186575808495617;
        uint256 R = 0;
        uint256 C = 0;

        R = addmod(R, left, k);
        (R, C) = MiMC.MiMCSponge(R, C, 0);

        R = addmod(R, right, k);
        (R, C) = MiMC.MiMCSponge(R, C, 0);

        mimc_hash = R;
    }

    function insert(uint8 tree_index, uint256 leaf) internal {
        uint32 leaf_index = next_index[tree_index];
        uint32 current_index = next_index[tree_index];
        next_index[tree_index] += 1;

        uint256 current_level_hash = leaf;
        uint256 left;
        uint256 right;

        for (uint8 i = 0; i < levels[tree_index]; i++) {
            if (current_index % 2 == 0) {
                left = current_level_hash;
                right = zeros[tree_index][i];

                filled_subtrees[tree_index][i] = current_level_hash;
            } else {
                left = filled_subtrees[tree_index][i];
                right = current_level_hash;
            }

            current_level_hash = HashLeftRight(left, right);

            current_index /= 2;
        }

        tree_roots[tree_index] = current_level_hash;

        emit LeafAdded(tree_index, leaf, leaf_index);
    }

    function update(uint8 tree_index, uint256 old_leaf, uint256 leaf, uint32 leaf_index, uint256[] memory old_path, uint256[] memory path) internal {
        uint32 current_index = leaf_index;

        uint256 current_level_hash = old_leaf;
        uint256 left;
        uint256 right;

        for (uint8 i = 0; i < levels[tree_index]; i++) {
            if (current_index % 2 == 0) {
                left = current_level_hash;
                right = old_path[i];
            } else {
                left = old_path[i];
                right = current_level_hash;
            }

            current_level_hash = HashLeftRight(left, right);

            current_index /= 2;
        }

        require(tree_roots[tree_index] == current_level_hash);

        current_index = leaf_index;

        current_level_hash = leaf;

        for (i = 0; i < levels[tree_index]; i++) {
            if (current_index % 2 == 0) {
                left = current_level_hash;
                right = path[i];
            } else {
                left = path[i];
                right = current_level_hash;
            }

            current_level_hash = HashLeftRight(left, right);

            current_index /= 2;
        }

        tree_roots[tree_index] = current_level_hash;

        emit LeafUpdated(tree_index, leaf, leaf_index);
    }
}

/*
 * semaphorejs - Zero-knowledge signaling on Ethereum
 * Copyright (C) 2019 Kobi Gurkan <[email protected]>
 *
 * This file is part of semaphorejs.
 *
 * semaphorejs is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * semaphorejs is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with semaphorejs.  If not, see <http://www.gnu.org/licenses/>.
 */

contract Semaphore is Verifier, MultipleMerkleTree, Ownable {
    uint256 public external_nullifier;
    uint8 signal_tree_index;
    uint8 id_tree_index;

    uint8 constant root_history_size = 100;
    uint256[root_history_size] root_history;
    uint8 current_root_index = 0;

    mapping (uint => bool) nullifiers_set;

    uint256 reward;

    event SignalBroadcast(bytes signal, uint256 nullifiers_hash, uint256 external_nullifier);

    uint256 public gas_price_max = 30000000000;

    constructor(uint8 tree_levels, uint256 zero_value, uint256 external_nullifier_in, uint256 reward_amount_in_max_gas_price) Ownable() public 
    {

        external_nullifier = external_nullifier_in;
        id_tree_index = init_tree(tree_levels, zero_value);
        signal_tree_index = init_tree(tree_levels, zero_value);

        reward = reward_amount_in_max_gas_price;
    }

    event Funded(uint256 amount);

    function fund() public payable {
      emit Funded(msg.value);
    }

    function insertIdentity(uint256 leaf) public onlyOwner {
        insert(id_tree_index, leaf);
        root_history[current_root_index++ % root_history_size] = tree_roots[id_tree_index];
    }

    function updateIdentity(uint256 old_leaf, uint256 leaf, uint32 leaf_index, uint256[] memory old_path, uint256[] memory path) public onlyOwner {
        update(id_tree_index, old_leaf, leaf, leaf_index, old_path, path);
        root_history[current_root_index++ % root_history_size] = tree_roots[id_tree_index];
    }

    function hasNullifier(uint n) public view returns (bool) {
        return nullifiers_set[n];
    }

    function isInRootHistory(uint n) public view returns (bool) {
        bool found = false;
        for (uint8 i = 0; i < root_history.length; i++) {
            if (root_history[i] == n) {
                found = true;
                break;
            }
        }

        return found;
    }

    function preBroadcastCheck (
        uint[5] input,
        uint256 signal_hash
    ) public view returns (bool) {
        // TODO: figure out why verifyProof() causes an invalid opcode error if
        // called outside of mix()

        return hasNullifier(input[1]) == false &&
            signal_hash == input[2] &&
            external_nullifier == input[3] &&
            isInRootHistory(input[0]);
    }

    function broadcastSignal(
        bytes memory signal,
        uint[2] a,
        uint[2][2] b,
        uint[2] c,
        uint[5] input // (root, nullifiers_hash, signal_hash, external_nullifier, broadcaster_address)
    ) public {
        //uint256 start_gas = gasleft();
        uint256 signal_hash = uint256(sha256(signal)) >> 8;

        // Verify the broadcaster address
        require(address(input[4]) == msg.sender);

        // Check the inputs
        require(preBroadcastCheck(input, signal_hash) == true);

        // Verify the proof
        require(verifyProof(a, b, c, input));

        insert(signal_tree_index, signal_hash);
        nullifiers_set[input[1]] = true;
        emit SignalBroadcast(signal, input[1], external_nullifier);

        //uint256 gas_price = gas_price_max;
        //if (tx.gasprice < gas_price) {
          //gas_price = tx.gasprice;
        //}
        //uint256 gas_used = start_gas - gasleft();

        //// pay back gas: 21000 constant cost + gas used + reward
        ////require((msg.sender).send((21000 + gas_used)*tx.gasprice + reward));
        //require((msg.sender).send((21000 + gas_used + reward)*gas_price));
        ////require(msg.sender.send(1 wei));
    }

    function roots(uint8 tree_index) public view returns (uint256 root) {
      root = tree_roots[tree_index];
    }

    function getIdTreeIndex() public view returns (uint8 index) {
      index = id_tree_index;
    }

    function getSignalTreeIndex() public  view returns (uint8 index) {
      index = signal_tree_index;
    }

    function setExternalNullifier(uint256 new_external_nullifier) public onlyOwner {
      external_nullifier = new_external_nullifier;
    }

    function setMaxGasPrice(uint256 new_max_gas_price) public onlyOwner {
      gas_price_max = new_max_gas_price;
    }
}

contract Mixer {
    using SafeMath for uint256;

    address public operator;
    uint256 public operatorFee;
    uint256 public mixAmt;
    uint256 public feesOwedToOperator;
    Semaphore public semaphore;
    uint256[] public identityCommitments;

    event Deposited(address indexed depositor, uint256 indexed mixAmt, uint256 identityCommitment);
    event Mixed(address indexed recipient, uint256 indexed mixAmt, uint256 indexed operatorFee);

    // input = [root, nullifiers_hash, signal_hash, external_nullifier, broadcaster_address]
    struct DepositProof {
        bytes32 signal;
        uint[2] a;
        uint[2][2] b;
        uint[2] c;
        uint[5] input;
        address recipientAddress;
        uint256 fee;
    }

    /*
     * Constructor
     */
    constructor (address _semaphore, uint256 _mixAmt, uint256 _operatorFee) public {
        require(_semaphore != address(0));
        require(_operatorFee != 0);
        require(_mixAmt > _operatorFee);

        // Set the operator as the contract deployer
        operator = msg.sender;

        // Set the fixed mixing amount
        mixAmt = _mixAmt;

        // Set the fixed operator's fee
        operatorFee = _operatorFee;

        // Set the Semaphore contract
        semaphore = Semaphore(_semaphore);
    }

    /*
     * Sets Semaphore's external nullifier to the mixer's address. Call this
     * function after transferring Semaphore's ownership to this contract's
    *  address.
     */
    function setSemaphoreExternalNulllifier () public {
        semaphore.setExternalNullifier(uint256(address(this)));
    }

    /*
     * @return The amount of fees owed to the operator in wei
     */
    function getFeesOwedToOperator() public view returns (uint256) {
        return feesOwedToOperator;
    }

    /*
     * @return The fee in wei which each user has to pay to mix their funds.
     */
    function getTotalFee() public view returns (uint256) {
        return operatorFee * 2;
    }

    /*
     * @return The total amount of fees burnt. This is equivalent to
     * `operatorFee` multipled by the number of deposits. To save gas, we do
     * not send the burnt fees to a burn address. As this contract provides no
     * way for anyone - not even the operator - to withdraw this amount of ETH,
     * we consider it burnt.
     */
    function calcBurntFees() public view returns (uint256) {
        return address(this).balance.sub(feesOwedToOperator);
    }

    /*
     * Returns the list of all identity commitments, which are the leaves of
     * the Merkle tree
     */
    function getLeaves() public view returns (uint256[]) {
        return identityCommitments;
    }

    /*
     * Transfers all fees owed to the operator and resets the balance of fees
     * owed to 0
     */
    function withdrawFees() public {
        require(msg.sender == operator);
        operator.transfer(feesOwedToOperator);
        feesOwedToOperator = 0;
    }

    /*
     * Deposits `mixAmt` wei into the contract and register the user's identity
     * commitment into Semaphore.
     * @param The identity commitment (the hash of the public key and the
     *        identity nullifier)
     */
    function deposit(uint256 _identityCommitment) public payable {
        require(msg.value == mixAmt);
        require(_identityCommitment != 0);
        semaphore.insertIdentity(_identityCommitment);
        identityCommitments.push(_identityCommitment);
        emit Deposited(msg.sender, msg.value, _identityCommitment);
    }

    /*
     * Withdraw funds to a specified recipient using a zk-SNARK deposit proof
     * @param _proof A deposit proof. This function will send `mixAmt`, minus
     *               fees, to the recipient if the proof is valid.
     */
    function mix(DepositProof _proof) public {
        // Check whether the fee matches the one quoted by this contract
        require(_proof.fee == getTotalFee());

        // Hash the recipient's address, mixer contract address, and fee
        bytes32 computedSignal = keccak256(
            abi.encodePacked(
                _proof.recipientAddress,
                address(this),
                _proof.fee
            )
        );

        // Check whether the signal hash provided matches the one computed above
        require(computedSignal == _proof.signal);

        // Broadcast the signal
        semaphore.broadcastSignal(
            abi.encode(_proof.signal),
            _proof.a,
            _proof.b,
            _proof.c,
            _proof.input
        );

        // Increase the operator's fee balance
        feesOwedToOperator = feesOwedToOperator.add(operatorFee);

        // Transfer the ETH owed to the recipient, minus the totalFee (to
        // prevent griefing).
        // Note that totalFee = operatorFee * 2.
        // Since the remainder is stuck in this contract, it's as good as
        // burned. As such, we don't need to transfer the ETH to 0x0000..., and
        // we can save gas too.
        uint256 recipientMixAmt = mixAmt.sub(operatorFee.mul(2));
        _proof.recipientAddress.transfer(recipientMixAmt);

        emit Mixed(_proof.recipientAddress, recipientMixAmt, operatorFee);
    }
}
