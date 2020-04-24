/**
 *Submitted for verification at Etherscan.io on 2019-08-06
*/

/**
https://tornado.cash (https://github.com/peppersec/tornado-mixer)
*/

pragma solidity ^0.5.0;


library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    
    function P1() internal pure returns (G1Point memory) {
        return G1Point(1, 2);
    }
    
    function P2() internal pure returns (G2Point memory) {
        
        return G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );


    }
    
    function negate(G1Point memory p) internal pure returns (G1Point memory) {
        
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        
        assembly {
            success := staticcall(sub(gas, 2000), 6, input, 0xc0, r, 0x60)
            
            switch success case 0 { invalid() }
        }
        require(success,"pairing-add-failed");
    }
    
    
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        
        assembly {
            success := staticcall(sub(gas, 2000), 7, input, 0x80, r, 0x60)
            
            switch success case 0 { invalid() }
        }
        require (success,"pairing-mul-failed");
    }
    
    
    
    
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length,"pairing-lengths-failed");
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
            
            switch success case 0 { invalid() }
        }
        require(success,"pairing-opcode-failed");
        return out[0] != 0;
    }
    
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal view returns (bool) {
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
    
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal view returns (bool) {
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
    function verifyingKey() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = Pairing.G1Point(19041221914080290667071137300923499123734264324957016325464264370615697718065,9034883978245447970612210032252297436686357403226399009203903689775144955293);
        vk.beta2 = Pairing.G2Point([9058926182629587859414349798672009186338512195966225772503416138908754052484,11005426632997692409309088707766425384129835437685161160000231977909347071606], [18095535067973855900033538759347971672629218263767601171757345187385574244694,1172072632583761807396823885277474098726871846500284980931828386419738710607]);
        vk.gamma2 = Pairing.G2Point([4753211332536522258437428627733541886911356200405329066234638011161309270522,19426351064180596422727539146021376624895326214027568087849336860684926218742], [11085287139806892323995230032795910967451663034153107392536951282449742465037,9766292937460717065417514954777187578215416830525394740776809147893030601379]);
        vk.delta2 = Pairing.G2Point([927354981824011055014079128146938315547309371545027653702576661051916692318,17719517077094089332786648623720100186061437612749886711080235108645540914223], [1574152839033094616193964152723701563000618107097234638188432290512351039191,10411477022323198540716367935593730384913696194331935098141775424602912630771]);
        vk.IC = new Pairing.G1Point[](5);
        vk.IC[0] = Pairing.G1Point(6829140947325268995899001409313498006381784691591478069169694335971017998927,18978356833433203232826674577394053547996841918915243704868880010888843732951);
        vk.IC[1] = Pairing.G1Point(10035810485818848039534467798261037499801816217210149761513288565126573991157,5675361047656845048410631196505486244698435576418545404936474046156075290499);
        vk.IC[2] = Pairing.G1Point(754448112646204651690825715653333807098625973220905321153060338244677176392,18120383061004928846476887925873044045926898359498069656232762310149539996921);
        vk.IC[3] = Pairing.G1Point(5165975111757817903162258062595490171770172879619944384381826002864342445477,15775368260898884388082829016189918981930649258434479372307740380215287446546);
        vk.IC[4] = Pairing.G1Point(7526397383687443514994155188534769084432649670654722690968224497318538070458,2668275472755825332113951534319181528830528505599841356338680384124648031204);

    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.IC.length,"verifier-bad-input");
        
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field,"verifier-gte-snark-scalar-field");
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.IC[i + 1], input[i]));
        }
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
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[4] memory input
        ) public view returns (bool r) {
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
