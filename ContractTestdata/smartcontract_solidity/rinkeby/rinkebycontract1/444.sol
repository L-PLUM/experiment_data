/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.5.0;

/**
* @title a collection of functions for manipulating the VM memory
* @author Sami MÃ¤kelÃ¤
*/
contract VMMemory {

    // a and b are integer values that represent 8 bytes each
    function toMemory(uint a, uint b) internal pure returns (uint8[] memory) {
        uint8[] memory arr = new uint8[](16);
        storeN(arr, 0, 8, a);
        storeN(arr, 8, 8, b);
        return arr;
    }
    function storeN(uint8[] memory mem, uint addr, uint n, uint v) internal pure {
        for (uint i = 0; i < n; i++) {
            mem[addr+i] = uint8(v);
            v = v/256;
        }
    }
    function loadN(uint8[] memory mem, uint addr, uint n) internal pure returns (uint) {
        uint res = 0;
        uint exp = 1;
        for (uint i = 0; i < n; i++) {
            res += mem[addr+i]*exp;
            exp = exp*256;
        }
        return res;
    }
    function fromMemory(uint8[] memory mem) internal pure returns (uint a, uint b) {
        a = loadN(mem, 0, 8);
        b = loadN(mem, 8, 8);
    }
    
    function typeSize(uint ty) internal pure returns (uint) {
        if (ty == 0) return 4; // I32
        else if (ty == 1) return 8; // I64
        else if (ty == 2) return 4; // F32
        else if (ty == 3) return 8; // F64
    }
    
    function store(uint8[] memory mem, uint addr, uint v, uint ty, uint packing) internal pure {
        if (packing == 0) storeN(mem, addr, typeSize(ty), v);
        else {
            // Only integers can be packed, also cannot pack I32 to 32-bit?
            require(ty < 2 && !(ty == 0 && packing == 4));
            storeN(mem, addr, packing, v);
        }
    }
    
    function storeX(uint8[] memory mem, uint addr, uint v, uint hint) internal pure {
        store(mem, addr, v, (hint/2**3)&0x3, hint&0x7);
    }
    
    function load(uint8[] memory mem, uint addr, uint ty, uint packing, bool sign_extend) internal pure returns (uint) {
        if (packing == 0) return loadN(mem, addr, typeSize(ty));
        else {
            require(ty < 2 && !(ty == 0 && packing == 4));
            uint res = loadN(mem, addr, packing);
            if (sign_extend) {
                res = res | uint(-1)*2**(8*packing)*(res/2**(8*packing-1));
            }
            if (ty == 0) res = res % (2**32);
            else res = res % (2**64);
            return res;
        }
    }
    
    function loadX(uint8[] memory mem, uint addr, uint hint) internal pure returns (uint) {
        return load(mem, addr, (hint/2**4)&0x3, (hint/2)&0x7, hint&0x1 == 1);
    }
    
    /*
    function test(uint a, uint b) returns (uint, uint) {
        return fromMemory(toMemory(a,b));
    }*/
}



contract Onchain {

    uint debug;
    bytes32 debugb;

    struct Roots {
        bytes32 code;
        bytes32 stack;
        bytes32 mem;
        bytes32 globals;
        bytes32 calltable;
        bytes32 calltypes;
        bytes32 call_stack;
        bytes32 input_size;
        bytes32 input_name;
        bytes32 input_data;
    }

    struct VM {
        uint pc;
        uint stack_ptr;
        uint call_ptr;
        uint memsize;
    }

    struct Machine {
        bytes32 vm;
        bytes32 op;
        uint reg1;
        uint reg2;
        uint reg3;
        uint ireg;
        bool exit;
    }

    VM vm;
    Roots vm_r;
    Machine m;
    bytes32[] proof;
    bytes32[] proof2;

    bytes32 state;

    function setVM(bytes32[10] memory roots, uint[4] memory pointers) internal {
        vm_r.code = roots[0];
        vm_r.stack = roots[1];
        vm_r.mem = roots[2];
        vm_r.call_stack = roots[3];
        vm_r.globals = roots[4];
        vm_r.calltable = roots[5];
        vm_r.calltypes = roots[6];
        vm_r.input_size = roots[7];
        vm_r.input_name = roots[8];
        vm_r.input_data = roots[9];

        vm.pc = pointers[0];
        vm.stack_ptr = pointers[1];
        vm.call_ptr = pointers[2];
        vm.memsize = pointers[3];
    }
    
    function hashVM() internal view returns (bytes32) {
        bytes32[] memory arr = new bytes32[](14);
        arr[0] = vm_r.code;
        arr[1] = vm_r.mem;
        arr[2] = vm_r.stack;
        arr[3] = vm_r.globals;
        arr[4] = vm_r.call_stack;
        arr[5] = vm_r.calltable;
        arr[6] = vm_r.calltypes;
        arr[7] = vm_r.input_size;
        arr[8] = vm_r.input_name;
        arr[9] = vm_r.input_data;
        arr[10] = bytes32(vm.pc);
        arr[11] = bytes32(vm.stack_ptr);
        arr[12] = bytes32(vm.call_ptr);
        arr[13] = bytes32(vm.memsize);
        return keccak256(abi.encodePacked(arr));
    }
    
    function setMachine(
        bytes32 vm_,
        bytes32 op,
        uint reg1,
        uint reg2,
        uint reg3,
        uint ireg) internal {
        m.vm = vm_;
        m.op = op;
        m.reg1 = reg1;
        m.reg2 = reg2;
        m.reg3 = reg3;
        m.ireg = ireg;
    }
    
    function hashMachine() internal view returns (bytes32) {
        return keccak256(abi.encodePacked(m.vm, m.op, m.reg1, m.reg2, m.reg3, m.ireg));
    }
    
    function getLeaf(uint loc) internal view returns (uint) {
        require(proof.length >= 2);
        if (loc%2 == 0) return uint(proof[0]);
        else return uint(proof[1]);
    }
    
    function setLeaf(uint loc, uint v) internal {
        require(proof.length >= 2);
        if (loc%2 == 0) proof[0] = bytes32(v);
        else proof[1] = bytes32(v);
    }

    function checkWriteAccess(uint loc, uint /* hint */) internal view returns (bool) {
        require(proof.length >= 2);
        for (uint i = 2; i < proof.length; i++) {
            loc = loc/2;
        }
        return loc < 2;
    }
    
    function checkInputDataAccess(uint /* loc2 */, uint loc) internal view returns (bool) {
        require(proof2.length >= 2);
        for (uint i = 2; i < proof2.length; i++) {
            loc = loc/2;
        }
        return loc < 2;
    }

    function checkReadAccess(uint loc, uint hint) internal view returns (bool) {
        return checkWriteAccess(loc, hint);
    }

    function checkInputNameAccess(uint loc2, uint loc) internal view returns (bool) {
        return checkInputDataAccess(loc2, loc);
    }

    function getRoot(uint loc) internal view returns (bytes32) {
        require(proof.length >= 2);
        bytes32 res = keccak256(abi.encodePacked(proof[0], proof[1]));
        for (uint i = 2; i < proof.length; i++) {
            loc = loc/2;
            if (loc%2 == 0) res = keccak256(abi.encodePacked(res, proof[i]));
            else res = keccak256(abi.encodePacked(proof[i], res));
        }
        require(loc < 2); // This should be runtime error, access over bounds
        return res;
    }

    function getLeaf2(uint loc) internal view returns (uint) {
        require(proof2.length >= 2);
        if (loc%2 == 0) return uint(proof2[0]);
        else return uint(proof2[1]);
    }
    
    function setLeaf2(uint loc, uint v) internal {
        require(proof2.length >= 2);
        if (loc%2 == 0) proof2[0] = bytes32(v);
        else proof2[1] = bytes32(v);
    }

    function getRoot2(uint loc) internal view returns (bytes32) {
        require(proof2.length >= 2);
        bytes32 res = keccak256(abi.encodePacked(proof2[0], proof2[1]));
        for (uint i = 2; i < proof2.length; i++) {
            loc = loc/2;
            if (loc%2 == 0) res = keccak256(abi.encodePacked(res, proof2[i]));
            else res = keccak256(abi.encodePacked(proof2[i], res));
        }
        require(loc < 2);
        return res;
    }

    function getRoot2_16(uint loc) internal view returns (bytes32) {
        require(proof2.length >= 2);
        bytes32 res = keccak256(abi.encodePacked(uint128(uint256(proof2[0])), uint128(uint256(proof2[1]))));
        for (uint i = 2; i < proof2.length; i++) {
            loc = loc/2;
            if (loc%2 == 0) res = keccak256(abi.encodePacked(res, proof2[i]));
            else res = keccak256(abi.encodePacked(proof2[i], res));
        }
        require(loc < 2);
        return res;
    }

    function getCode(uint loc) internal view returns (bytes32) {
        require(hashMachine() == state && hashVM() == m.vm);
        require(getRoot(loc) == vm_r.code);
        require(proof2.length == 0);
        return bytes32(getLeaf(loc));
    }

    function getStack(uint loc) internal view returns (uint) {
        require(hashMachine() == state && hashVM() == m.vm);
        require(getRoot(loc) == vm_r.stack);
        require(proof2.length == 0);
        return getLeaf(loc);
    }

    function getCallStack(uint loc) internal view returns (uint) {
        require(hashMachine() == state && hashVM() == m.vm);
        require(getRoot(loc) == vm_r.call_stack);
        require(proof2.length == 0);
        return getLeaf(loc);
    }

    function getCallTable(uint loc) internal view returns (uint) {
        require(hashMachine() == state && hashVM() == m.vm);
        require(getRoot(loc) == vm_r.calltable);
        require(proof2.length == 0);
        return getLeaf(loc);
    }

    function getCallTypes(uint loc) internal view returns (uint) {
        require(hashMachine() == state && hashVM() == m.vm);
        require(getRoot(loc) == vm_r.calltypes);
        require(proof2.length == 0);
        return getLeaf(loc);
    }

    function getMemory(uint loc) internal view returns (uint) {
        require(hashMachine() == state && hashVM() == m.vm);
        require(getRoot(loc) == vm_r.mem);
        require(proof2.length == 0);
        return getLeaf(loc);
    }

    function getGlobal(uint loc) internal view returns (uint) {
        require(hashMachine() == state && hashVM() == m.vm);
        require(getRoot(loc) == vm_r.globals);
        require(proof2.length == 0);
        return getLeaf(loc);
    }
    
    uint constant INPUT_FILES = 11;

    function getInputSize(uint loc) internal view returns (uint) {
        require(hashMachine() == state && hashVM() == m.vm);
        require(getRoot(loc) == vm_r.input_size && proof.length == INPUT_FILES);
        require(proof2.length == 0);
        return getLeaf(loc);
    }
    
    function getInputName(uint loc, uint loc2) internal view returns (uint) {
        require(hashMachine() == state && hashVM() == m.vm);
        require(getRoot(loc) == vm_r.input_name && proof.length == INPUT_FILES);
        require(getRoot2(loc2) == bytes32(getLeaf(loc)));
        return getLeaf2(loc2);
    }

    function setInputName(uint loc, uint loc2, uint v) internal {
        require(hashMachine() == state && hashVM() == m.vm);
        require(getRoot(loc) == vm_r.input_name && proof.length == INPUT_FILES);
        require(getRoot2(loc2) == bytes32(getLeaf(loc)));
        setLeaf2(loc2, v);
        // setLeaf(loc, getLeaf2(loc));
        setLeaf(loc, uint(getRoot2(loc2)));
        vm_r.input_name = getRoot(loc);
        m.vm = hashVM();
        state = hashMachine();
    }

    function setInputSize(uint loc, uint v) internal {
        require(hashMachine() == state && hashVM() == m.vm);
        require(getRoot(loc) == vm_r.input_size && proof.length == INPUT_FILES);
        setLeaf(loc, v);
        vm_r.input_size = getRoot(loc);
        m.vm = hashVM();
        require(proof2.length == 0);
        state = hashMachine();
    }

    function setInputFile(uint loc, bytes32 v) internal {
        require(hashMachine() == state && hashVM() == m.vm);
        require(getRoot(loc) == vm_r.input_data && proof.length == INPUT_FILES);
        setLeaf(loc, uint(v));
        vm_r.input_data = getRoot(loc);
        m.vm = hashVM();
        state = hashMachine();
    }

    function setNthByte(uint a, uint n, uint8 bte) pure internal returns (bytes32) {
       uint mask = uint(-1)*(2**(8*(15-n))) | uint(-1)/(2**(8*(15-n+1)));
       return bytes32((a&mask) | (2**(8*(15-n)))*uint256(bte));
    }

    function setInputData(uint loc, uint loc2, uint v) internal {
        require(hashMachine() == state && hashVM() == m.vm);
        require(getRoot(loc) == vm_r.input_data && proof.length == INPUT_FILES);
        require(getRoot2_16(loc2/16) == bytes32(getLeaf(loc)));
        uint leaf = getLeaf2(loc2/16);
        uint idx = loc2 % 16;
        
        debugb = bytes32(leaf);
        debug = idx;
        uint nleaf = uint(setNthByte(leaf, idx, uint8(v)));
        debugb = bytes32(nleaf);
        
        setLeaf2(loc2/16, nleaf);
        setLeaf(loc, uint(getRoot2_16(loc2/16)));
        debugb = proof2[0];
        debug = proof2.length;
        vm_r.input_data = getRoot(loc);
        m.vm = hashVM();
        state = hashMachine();
    }

    function getInputData(uint loc, uint loc2) internal view returns (uint) {
        require(hashMachine() == state && hashVM() == m.vm);
        require(getRoot(loc) == vm_r.input_data && proof.length == INPUT_FILES);
        require(getRoot2_16(loc2/16) == bytes32(getLeaf(loc)));
        uint leaf = getLeaf2(loc2/16);
        uint idx = loc2 % 16;
        
        return (leaf / 2**((15-idx)*8)) & 0xff;
    }

    function createInputData(uint loc, uint sz) internal {
        require(hashMachine() == state && hashVM() == m.vm);
        require(getRoot(loc) == vm_r.input_data && proof.length == INPUT_FILES);
        
        sz = sz/32;
        bytes32 zero = keccak256(abi.encodePacked(bytes16(0), bytes16(0)));
        while (sz > 1) {
            sz = sz/2;
            zero = keccak256(abi.encodePacked(zero, zero));
        }
        setLeaf(loc, uint(zero));
        vm_r.input_data = getRoot(loc);
        m.vm = hashVM();
        state = hashMachine();
    }

    function setCallStack(uint loc, uint v) internal  {
        require(hashMachine() == state && hashVM() == m.vm);
        require(getRoot(loc) == vm_r.call_stack);
        require(proof2.length == 0);
        setLeaf(loc, v);
        vm_r.call_stack = getRoot(loc);
        m.vm = hashVM();
        state = hashMachine();
    }

    function setMemory(uint loc, uint v) internal  {
        require(hashMachine() == state && hashVM() == m.vm);
        require(getRoot(loc) == vm_r.mem);
        require(proof2.length == 0);
        setLeaf(loc, v);
        vm_r.mem = getRoot(loc);
        m.vm = hashVM();
        state = hashMachine();
    }

    function setStack(uint loc, uint v) internal {
        require(hashMachine() == state && hashVM() == m.vm);
        require(getRoot(loc) == vm_r.stack);
        require(proof2.length == 0);
        setLeaf(loc, v);
        vm_r.stack = getRoot(loc);
        m.vm = hashVM();
        state = hashMachine();
    }

    function setGlobal(uint loc, uint v) internal {
        require(hashMachine() == state && hashVM() == m.vm);
        require(getRoot(loc) == vm_r.globals);
        require(proof2.length == 0);
        setLeaf(loc, v);
        vm_r.globals = getRoot(loc);
        m.vm = hashVM();
        state = hashMachine();
    }

    function setCallTable(uint loc, uint v) internal {
        require(hashMachine() == state && hashVM() == m.vm);
        require(getRoot(loc) == vm_r.calltable);
        require(proof2.length == 0);
        setLeaf(loc, v);
        vm_r.calltable = getRoot(loc);
        m.vm = hashVM();
        state = hashMachine();
    }

    function setCallType(uint loc, uint v) internal {
        require(hashMachine() == state && hashVM() == m.vm);
        require(getRoot(loc) == vm_r.calltypes);
        require(proof2.length == 0);
        setLeaf(loc, v);
        vm_r.calltypes = getRoot(loc);
        m.vm = hashVM();
        state = hashMachine();
    }

    function getPC() internal view returns (uint) {
        require(hashMachine() == state && hashVM() == m.vm);
        return vm.pc;
    }
    
    function getMemsize() internal view returns (uint) {
        require(hashMachine() == state && hashVM() == m.vm);
        return vm.memsize;
    }
    
    function getStackPtr() internal view returns (uint) {
        require(hashMachine() == state && hashVM() == m.vm);
        return vm.stack_ptr;
    }
    
    function getCallPtr() internal view returns (uint) {
        require(hashMachine() == state && hashVM() == m.vm);
        return vm.call_ptr;
    }
    
    function getReg1() internal view returns (uint) {
        require(hashMachine() == state);
        return m.reg1;
    }
    
    function getReg2() internal view returns (uint) {
        require(hashMachine() == state);
        return m.reg2;
    }
    
    function getReg3() internal view returns (uint) {
        require(hashMachine() == state);
        return m.reg3;
    }

    function getIreg() internal view returns (uint) {
        require(hashMachine() == state);
        return m.ireg;
    }
    
    function getOp() internal view returns (bytes32) {
        require(hashMachine() == state);
        return m.op;
    }
    
    function setMemsize(uint v) internal {
        vm.memsize = v;
        m.vm = hashVM();
        state = hashMachine();
    }
    
    function setIreg(uint v) internal  {
        m.ireg = v;
        state = hashMachine();
    }
    
    function setReg1(uint v) internal  {
        m.reg1 = v;
        state = hashMachine();
    }

    function setReg2(uint v) internal  {
        m.reg2 = v;
        state = hashMachine();
    }

    function setReg3(uint v) internal  {
        m.reg3 = v;
        state = hashMachine();
    }

    function setPC(uint v) internal {
        vm.pc = v;
        m.vm = hashVM();
        state = hashMachine();
    }

    function setStackPtr(uint v) internal {
        vm.stack_ptr = v;
        m.vm = hashVM();
        state = hashMachine();
    }

    function setCallPtr(uint v) internal {
        vm.call_ptr = v;
        m.vm = hashVM();
        state = hashMachine();
    }

    function setOp(bytes32 op) internal {
        m.op = op;
        m.vm = hashVM();
        state = hashMachine();
    }
    
    function makeZero(uint n) internal pure returns (bytes32) {
       bytes32 res = 0;
       for (uint i = 0; i < n; i++) res = keccak256(abi.encodePacked(res, res));
       return res;
    }
    
    function setStackSize(uint sz) internal {
        vm_r.stack = makeZero(sz);
        m.vm = hashVM();
        state = hashMachine();
    }

    function setCallStackSize(uint sz) internal {
        vm_r.call_stack = makeZero(sz);
        m.vm = hashVM();
        state = hashMachine();
    }

    function setGlobalsSize(uint sz) internal {
        vm_r.globals = makeZero(sz);
        m.vm = hashVM();
        state = hashMachine();
    }

    function setMemorySize(uint sz) internal {
        vm_r.mem = makeZero(sz);
        m.vm = hashVM();
        state = hashMachine();
    }

    function setTableSize(uint sz) internal {
        bytes32 res = bytes32(uint256(uint32(-1)));
        debugb = res;
        for (uint i = 0; i < sz; i++) res = keccak256(abi.encodePacked(res, res));
        vm_r.calltable = res;
        m.vm = hashVM();
        state = hashMachine();
    }

    function setTableTypesSize(uint sz) internal {
        vm_r.calltypes = makeZero(sz);
        m.vm = hashVM();
        state = hashMachine();
    }


}


/**
* @title collection of getter and setter methods for manipulating the WASM runtime and initialization
* @author Sami MÃ¤kelÃ¤
*/
contract Offchain {

    struct Roots {
        bytes32[] code;
        bytes32[] stack;
        bytes32[] mem;
        bytes32[] globals;
        bytes32[] calltable;
        bytes32[] calltypes;
        bytes32[] call_stack;
        bytes32[] input_size;
        bytes32[][] input_name;
        bytes32[][] input_data;
    }

    struct VM {
        uint pc;
        uint stack_ptr;
        uint call_ptr;
        uint memsize;
    }
    
    struct Machine {
        bytes32 op;
        uint reg1;
        uint reg2;
        uint reg3;
        uint ireg;
    }
    
    VM vm;
    Roots vm_r;
    Machine m;
    
    uint debug;
    
    function checkReadAccess(uint loc, uint hint) internal view returns (bool) {
        if (hint == 5) return loc < vm_r.globals.length;
        else if (hint == 6) return loc < vm_r.stack.length;
        else if (hint == 7) return loc < vm_r.stack.length;
        else if (hint == 8) return loc < vm_r.stack.length;
        else if (hint == 9) return loc < vm_r.stack.length;
        else if (hint == 14) return loc < vm_r.call_stack.length;
        else if (hint == 15) return loc < vm_r.mem.length;
        else if (hint == 16) return loc < vm_r.calltable.length;
        else if (hint == 17) return loc < vm_r.mem.length;
        else if (hint == 18) return loc < vm_r.calltypes.length;
        else if (hint == 19) return loc < vm_r.input_size.length;
        else if (hint == 0x16) return loc < vm_r.stack.length;
        return true;
    }
    
    function checkWriteAccess(uint loc, uint hint) internal view returns (bool) {
        if (hint & 0xc0 == 0x80) return loc < vm_r.mem.length;
        else if (hint & 0xc0 == 0xc0) return loc < vm_r.mem.length;
        else if (hint == 2) return loc < vm_r.stack.length;
        else if (hint == 3) return loc < vm_r.stack.length;
        else if (hint == 4) return loc < vm_r.stack.length;
        else if (hint == 6) return loc < vm_r.call_stack.length;
        else if (hint == 8) return loc < vm_r.globals.length;
        else if (hint == 9) return loc < vm_r.stack.length;
        else if (hint == 0x0a) return loc < vm_r.input_size.length;
        else if (hint == 0x0e) return loc < vm_r.calltable.length;
        else if (hint == 0x0f) return loc < vm_r.calltypes.length;
        return true;
    }
    
    function checkInputDataAccess(uint /* loc */, uint /* hint */) internal pure returns (bool) {
        return true;
    }
    
    function checkInputNameAccess(uint /* loc */, uint /* hint */) internal pure returns (bool) {
        return true;
    }
    
    // TODO: these should be cleared first
    function setStackSize(uint sz) internal {
        vm_r.stack.length = 0;
        vm_r.stack.length = 2**sz;
    }

    function setCallStackSize(uint sz) internal {
        vm_r.call_stack.length = 0;
        vm_r.call_stack.length = 2**sz;
    }

    function setGlobalsSize(uint sz) internal {
        vm_r.globals.length = 0;
        vm_r.globals.length = 2**sz;
    }

    function setMemorySize(uint sz) internal {
        vm_r.mem.length = 0;
        vm_r.mem.length = 2**sz;
    }

    function setTableSize(uint sz) internal {
        vm_r.calltable.length = 0;
        vm_r.calltable.length = 2**sz;
        vm_r.calltypes.length = 0;
        vm_r.calltypes.length = 2**sz;
    }

    function setTableTypesSize(uint sz) internal {
        vm_r.calltypes.length = 0;
        vm_r.calltypes.length = 2**sz;
    }

    function getCode(uint loc) internal view returns (bytes32) {
        return vm_r.code[loc];
    }

    function getStack(uint loc) internal view returns (uint) {
        return uint(vm_r.stack[loc]);
    }

    function getCallStack(uint loc) internal view returns (uint) {
        return uint(vm_r.call_stack[loc]);
    }

    function setCallStack(uint loc, uint v) internal  {
        vm_r.call_stack[loc] = bytes32(v);
    }

    function getCallTable(uint loc) internal view returns (uint) {
        return uint(vm_r.calltable[loc]);
    }

    function getCallTypes(uint loc) internal view returns (uint) {
        return uint(vm_r.calltypes[loc]);
    }

    function getMemory(uint loc) internal view returns (uint) {
        return uint(vm_r.mem[loc]);
    }

    function setMemory(uint loc, uint v) internal  {
        vm_r.mem[loc] = bytes32(v);
    }

    function setStack(uint loc, uint v) internal {
        vm_r.stack[loc] = bytes32(v);
    }

    function getGlobal(uint loc) internal view returns (uint) {
        return uint(vm_r.globals[loc]);
    }

    function setGlobal(uint loc, uint v) internal {
        vm_r.globals[loc] = bytes32(v);
    }

    function setCallTable(uint loc, uint v) internal {
        vm_r.calltable[loc] = bytes32(v);
    }

    function setCallType(uint loc, uint v) internal {
        vm_r.calltypes[loc] = bytes32(v);
    }

    function getInputSize(uint loc) internal view returns (uint) {
        return uint(vm_r.input_size[loc]);
    }
    
    function getInputName(uint loc, uint loc2) internal view returns (uint) {
        return uint(vm_r.input_name[loc][loc2]);
    }
    
    function getInputData(uint loc, uint loc2) internal view returns (uint) {
        return uint(vm_r.input_data[loc][loc2]);
    }
    
    function createInputData(uint loc, uint sz) internal {
        vm_r.input_data[loc].length = sz;
    }
    
    function setInputSize(uint loc, uint v) internal {
        vm_r.input_size[loc] = bytes32(v);
    }
    
    function setInputName(uint loc, uint loc2, uint v) internal {
        vm_r.input_name[loc][loc2] = bytes32(v);
    }
    function setInputData(uint loc, uint loc2, uint v) internal {
        vm_r.input_data[loc][loc2] = bytes32(v);
    }
    
    function getPC() internal view returns (uint) {
        return vm.pc;
    }
    
    function getMemsize() internal view returns (uint) {
        return vm.memsize;
    }
    
    function setMemsize(uint v) internal {
        vm.memsize = v;
    }
    
    function getStackPtr() internal view returns (uint) {
        return vm.stack_ptr;
    }
    
    function getCallPtr() internal view returns (uint) {
        return vm.call_ptr;
    }
    
    function getIreg() internal view returns (uint) {
        return m.ireg;
    }
    
    function setIreg(uint v) internal  {
        m.ireg = v;
    }
    
    function setReg1(uint v) internal  {
        m.reg1 = v;
    }
    
    function setReg2(uint v) internal  {
        m.reg2 = v;
    }
    
    function setReg3(uint v) internal  {
        m.reg3 = v;
    }
    
    function getReg1() internal view returns (uint) {
        return m.reg1;
    }
    
    function getReg2() internal view returns (uint) {
        return m.reg2;
    }
    
    function getReg3() internal view returns (uint) {
        return m.reg3;
    }

    function setPC(uint v) internal {
        vm.pc = v;
    }

    function setStackPtr(uint v) internal {
        vm.stack_ptr = v;
    }

    function setCallPtr(uint v) internal {
        vm.call_ptr = v;
    }

    function getOp() internal view returns (bytes32) {
        return m.op;
    }
    
    function setOp(bytes32 op) internal {
        m.op = op;
    }
    


}










/**
* @title the ALU for the solidity interpreter.
* @author Sami MÃ¤kelÃ¤
*/
contract ALU is VMMemory {
    /**
    * @dev handles the ALU operations of the WASM machine i.e. the WASM instructions are implemented and run here
    *
    * @param hint the actual opcode
    * @param r1 register one
    * @param r2 register two
    * @param r3 register three
    * @param ireg the register holding the immediate value
    *
    * @return returns the result of the operation
    */
    function handleALU(uint hint, uint r1, uint r2, uint r3, uint ireg) internal pure returns (uint, bool) {
        uint res = r1;
        if (hint == 0) return (r1, false);
        else if (hint == 1 || hint == 6) {
            return (0, true);
            // revert(); // Trap
        }
        // Loading from memory
        else if (hint & 0xc0 == 0xc0) {
            uint8[] memory arr = toMemory(r2, r3);
            res = loadX(arr, (r1+ireg)%8, hint);
        }
        else if (hint == 2) {
            if (r1 < r2) res = r1;
            else res = r2;
        }
        // Calculate conditional jump
        else if (hint == 3) {
            if (r2 != 0) res = r1;
            else res = r3;
        }
        // Calculate conditional jump
        else if (hint == 8) {
            if (r2 != 0) res = r3;
            else res = r1;
        }
        // Calculate jump to jump table
        else if (hint == 4) {
            res = r2 + (r1 >= ireg ? ireg : r1);
        }
        // Check dynamic call
        else if (hint == 7) {
            if (ireg != r2) return (0, true);
            res = 0;
        }
        else if (hint == 0x45 || hint == 0x50) {
            if (r1 == 0) res = 1;
            else res = 0;
        }
        else if (hint == 0x46 || hint == 0x51) {
            if (r1 == r2) res = 1;
            else res = 0;
        }
        else if (hint == 0x47 || hint == 0x52) {
            if (r1 != r2) res = 1;
            else res = 0;
        }
        else if (hint == 0x48) {
            if (int32(r1) < int32(r2)) res = 1;
            else res = 0;
        }
        else if (hint == 0x49) {
            if (uint32(r1) < uint32(r2)) res = 1;
            else res = 0;
        }
        else if (hint == 0x4a) {
            if (int32(r1) > int32(r2)) res = 1;
            else res = 0;
        }
        else if (hint == 0x4b) {
            if (uint32(r1) > uint32(r2)) res = 1;
            else res = 0;
        }
        else if (hint == 0x4c) {
            if (int32(r1) <= int32(r2)) res = 1;
            else res = 0;
        }
        else if (hint == 0x4d) {
            if (uint32(r1) <= uint32(r2)) res = 1;
            else res = 0;
        }
        else if (hint == 0x4e) {
            if (int32(r1) >= int32(r2)) res = 1;
            else res = 0;
        }
        else if (hint == 0x4f) {
            if (uint32(r1) >= uint32(r2)) res = 1;
            else res = 0;
        }

        else if (hint == 0x53) {
            if (int64(r1) < int64(r2)) res = 1;
            else res = 0;
        }
        else if (hint == 0x54) {
            if (uint64(r1) < uint64(r2)) res = 1;
            else res = 0;
        }
        else if (hint == 0x55) {
            if (int64(r1) > int64(r2)) res = 1;
            else res = 0;
        }
        else if (hint == 0x56) {
            if (uint64(r1) > uint64(r2)) res = 1;
            else res = 0;
        }
        else if (hint == 0x57) {
            if (int64(r1) <= int64(r2)) res = 1;
            else res = 0;
        }
        else if (hint == 0x58) {
            if (uint64(r1) <= uint64(r2)) res = 1;
            else res = 0;
        }
        else if (hint == 0x59) {
            if (int64(r1) >= int64(r2)) res = 1;
            else res = 0;
        }
        else if (hint == 0x5a) {
            if (uint64(r1) >= uint64(r2)) res = 1;
            else res = 0;
        }
        else if (hint == 0x67) {
            res = clz32(uint32(r1));
        }
        else if (hint == 0x68) {
            res = ctz32(uint32(r1));
        }
        else if (hint == 0x69) {
            res = popcnt32(uint32(r1));
        }
        else if (hint == 0x79) {
            res = clz64(uint64(r1));
        }
        else if (hint == 0x7a) {
            res = ctz64(uint64(r1));
        }
        else if (hint == 0x7b) {
            res = popcnt64(uint64(r1));
        }
        else if (hint == 0x6a || hint == 0x7c) {
            res = r1+r2;
        }
        else if (hint == 0x6b || hint == 0x7d) {
            res = r1-r2;
        }
        else if (hint == 0x6c || hint == 0x7e) {
            res = r1*r2;
        }
        else if (hint == 0x6d) {
            if (int32(r2) == 0) return (0, true);
            res = uint(int32(r1)/int32(r2));
        }
        else if (hint == 0x7f) {
            if (int64(r2) == 0) return (0, true);
            res = uint(int64(r1)/int64(r2));
        }
        else if (hint == 0x6e || hint == 0x80) {
            if (int64(r2) == 0) return (0, true);
            res = r1/r2;
        }
        else if (hint == 0x6f) {
            if (int32(r2) == 0) return (0, true);
            res = uint(int32(r1)%int32(r2));
        }
        else if (hint == 0x81) {
            if (int64(r2) == 0) return (0, true);
            res = uint(int64(r1)%int64(r2));
        }
        else if (hint == 0x70 || hint == 0x82) {
            if (int64(r2) == 0) return (0, true);
            res = r1%r2;
        }
        else if (hint == 0x71 || hint == 0x83) {
            res = r1&r2;
        }
        else if (hint == 0x72 || hint == 0x84) {
            res = r1|r2;
        }
        else if (hint == 0x73 || hint == 0x85) {
            res = r1^r2;
        }
        else if (hint == 0x74) {
            res = r1*2**(r2%32); // shift 
        }
        else if (hint == 0x86) {
            res = r1*2**(r2%64); // shift 
        }
        else if (hint == 0x76) {
            res = uint(uint32(r1) >> uint32(r2%32));
        }
        else if (hint == 0x87) {
            res = sar64(r1, r2);
        }
        else if (hint == 0x75) {
            res = sar32(r1, r2);
        }
        else if (hint == 0x88) {
            res = uint(uint64(r1) >> uint64(r2%64));
        }
        // rol, ror -- fix
        else if (hint == 0x77) {
            uint rt = r2 % 32;
            res = ((r1*2**rt) | (r1/2**(32-rt)));
        }
        else if (hint == 0x78) {
            uint rt2 = (r2 % 32);
            res = ((r1*2**(32-rt2)) | (r1/2**rt2)) & 0xffffffffffffffff;
        }
        else if (hint == 0x89) {
            uint rot = r2 % 64;
            res = ((r1*2**rot) | (r1/2**(64-rot))) & 0xffffffffffffffff;
        }
        else if (hint == 0x8a) {
            uint rot2 = (r2 % 64);
            res = ((r1*2**(64-rot2)) | (r1/2**rot2)) & 0xffffffffffffffff;
//            res = (r1/2**rot2) | (r1*2**64);
        }
        else if (hint == 0xac) {
            if (r1 & 0x80000000 != 0) res = r1 | 0xffffffff00000000;
            else res = r1;
        }
        else if (hint == 0xa7) {
            res = r1 & 0xffffffff;
        }
        
        if (hint >= 0x62 && hint <= 0x78) {
            res = res % (2**32);
        }
        else if (hint >= 0x7c && hint <= 0x8a) {
            res = res % (2**64);
        }
        
        return (res, false);
    }

    function sar64(uint r1, uint r2) internal pure returns (uint) {
        r2 = r2 % 64;
        uint sgn = 0x8000000000000000 & r1;
        uint tmp = r1;
        for (uint i = 0; i < r2; i++) {
            tmp = tmp >> 1;
            tmp = sgn | tmp;
        }
        return tmp;
    }

    function sar32(uint r1, uint r2) internal pure returns (uint) {
        r2 = r2 % 32;
        uint sgn = 0x80000000 & r1;
        uint tmp = r1;
        for (uint i = 0; i < r2; i++) {
            tmp = tmp >> 1;
            tmp = sgn | tmp;
        }
        return tmp;
    }

  /**
  * @dev counts the number of set bits for a 32 bit value
  *
  * @param r1 the input value
  *
  * @return number of sit bits in r1
  */
  function popcnt32(uint32 r1) internal pure returns (uint8) {
    uint32 temp = r1;
    temp = (temp & 0x55555555) + ((temp >> 1) & 0x55555555);
    temp = (temp & 0x33333333) + ((temp >> 2) & 0x33333333);
    temp = (temp & 0x0f0f0f0f) + ((temp >> 4) & 0x0f0f0f0f);
    temp = (temp & 0x00ff00ff) + ((temp >> 8) & 0x00ff00ff);
    temp = (temp & 0x0000ffff) + ((temp >> 16) & 0x0000ffff);
    return uint8(temp);
  }

  /**
  * @dev counts the number of set bits for a 64 bit value
  *
  * @param r1 the input value
  *
  * @return returns the number of set bits for r1
  */
  function popcnt64(uint64 r1) internal pure returns (uint8) {
    uint64 temp = r1;
    temp = (temp & 0x5555555555555555) + ((temp >> 1) & 0x5555555555555555);
    temp = (temp & 0x3333333333333333) + ((temp >> 2) & 0x3333333333333333);
    temp = (temp & 0x0f0f0f0f0f0f0f0f) + ((temp >> 4) & 0x0f0f0f0f0f0f0f0f);
    temp = (temp & 0x00ff00ff00ff00ff) + ((temp >> 8) & 0x00ff00ff00ff00ff);
    temp = (temp & 0x0000ffff0000ffff) + ((temp >> 16) & 0x0000ffff0000ffff);
    temp = (temp & 0x00000000ffffffff) + ((temp >> 32) & 0x00000000ffffffff);
    return uint8(temp);
  }

  /**
  * @dev counts the number of leading zeroes for a 32-bit value using binary search
  *
  * @param r1 the input
  *
  * @return returns the number of leading zeroes for r1
  */
  function clz32(uint32 r1) internal pure returns (uint8) {
    if (r1 == 0) return 32;
    uint32 temp_r1 = r1;
    uint8 n = 0;
    if (temp_r1 & 0xffff0000 == 0) {
      n += 16;
      temp_r1 = temp_r1 << 16;
    }
    if (temp_r1 & 0xff000000 == 0) {
      n += 8;
      temp_r1 = temp_r1 << 8;
    }
    if (temp_r1 & 0xf0000000 == 0) {
      n += 4;
      temp_r1 = temp_r1 << 4;
    }
    if (temp_r1 & 0xc0000000 == 0) {
      n += 2;
      temp_r1 = temp_r1 << 2;
    }
    if (temp_r1 & 0x80000000 == 0) {
      n++;
    }
    return n;
  }

  /**
  * @dev counts the number of leading zeroes for a 64-bit value using binary search
  *
  * @param r1 the input value
  *
  * @return returns the number of leading zeroes for the input vlaue
  */
  function clz64(uint64 r1) internal pure returns (uint8) {
    if (r1 == 0) return 64;
    uint64 temp_r1 = r1;
    uint8 n = 0;
    if (temp_r1 & 0xffffffff00000000 == 0) {
      n += 32;
      temp_r1 = temp_r1 << 32;
    }
    if (temp_r1 & 0xffff000000000000 == 0) {
      n += 16;
      temp_r1 = temp_r1 << 16;
    }
    if (temp_r1 & 0xff00000000000000 == 0) {
      n+= 8;
      temp_r1 = temp_r1 << 8;
    }
    if (temp_r1 & 0xf000000000000000 == 0) {
      n += 4;
      temp_r1 = temp_r1 << 4;
    }
    if (temp_r1 & 0xc000000000000000 == 0) {
      n += 2;
      temp_r1 = temp_r1 << 2;
    }
    if (temp_r1 & 0x8000000000000000 == 0) {
      n += 1;
    }
    return n;
  }

  /**
  * @dev counts the number of trailing zeroes for a 32-bit value using binary search
  *
  * @param r1 the input value
  *
  * @return returns the number of trailing zeroes for the input value
  */
  function ctz32(uint32 r1) internal pure returns (uint8) {
    if (r1 == 0) return 32;
    uint32 temp_r1 = r1;
    uint8 n = 0;
    if (temp_r1 & 0x0000ffff == 0) {
      n += 16;
      temp_r1 = temp_r1 >> 16;
    }
    if (temp_r1 & 0x000000ff == 0) {
      n += 8;
      temp_r1 = temp_r1 >> 8;
    }
    if (temp_r1 & 0x0000000f == 0) {
      n += 4;
      temp_r1 = temp_r1 >> 4;
    }
    if (temp_r1 & 0x00000003 == 0) {
      n += 2;
      temp_r1 = temp_r1 >> 2;
    }
    if (temp_r1 & 0x00000001 == 0) {
      n += 1;
    }
    return n;
  }

  /**
  * @dev returns the number of trailing zeroes for a 64-bit input value using binary search
  *
  * @param r1 the input value
  *
  * @return returns the trailing zeroes count for the input value
  */
  function ctz64(uint64 r1) internal pure returns (uint8) {
    if (r1 == 0) return 64;
    uint64 temp_r1 = r1;
    uint8 n = 0;
    if (temp_r1 & 0x00000000ffffffff == 0) {
      n += 32;
      temp_r1 = temp_r1 >> 32;
    }
    if (temp_r1 & 0x000000000000ffff == 0) {
      n += 16;
      temp_r1 = temp_r1 >> 16;
    }
    if (temp_r1 & 0x00000000000000ff == 0) {
      n += 8;
      temp_r1 = temp_r1 >> 8;
    }
    if (temp_r1 & 0x000000000000000f == 0) {
      n += 4;
      temp_r1 = temp_r1 >> 4;
    }
    if (temp_r1 & 0x0000000000000003 == 0) {
      n += 2;
      temp_r1 = temp_r1 >> 2;
    }
    if (temp_r1 & 0x0000000000000001 == 0) {
      n += 1;
    }
    return n;
  }
}


/**
* @title VM Interpreter
* @author Sami MÃ¤kelÃ¤
*/
contract CommonOnchain is Onchain, ALU {
    /**
    * @dev get a pointer for the place we want to perform a read from, based on the opcode
    *
    * @param hint the opcode
    *
    * @return returns a pointer to where to read from
    */
    function readPosition(uint hint) internal view returns (uint) {
        assert(hint > 4);
        if (hint == 5) return getReg1();
        else if (hint == 6) return getStackPtr()-1;
        else if (hint == 7) return getStackPtr()-2;
        else if (hint == 8) return getStackPtr()-getReg1(); // Stack in reg
        else if (hint == 9) return getStackPtr()-getReg2();
        else if (hint == 14) return getCallPtr()-1;
        else if (hint == 15) return (getReg1()+getIreg())/8;
        else if (hint == 16) return getReg1();
        else if (hint == 17) return (getReg1()+getIreg())/8 + 1;
        else if (hint == 18) return getReg1();
        else if (hint == 19) return getReg1();
        else if (hint == 0x16) return getStackPtr()-3;
        else assert(false);
    }
    
    uint constant FINAL_STATE = 0xffffffffff;

    /**
    * @dev perform a read based on the opcode
    *
    * @param hint the opcode
    *
    * @return return the read value
    */
    function readFrom(uint hint) internal returns (uint res, bool fin4l) {
        if (hint == 0) res = 0;
        else if (hint == 1) res = getIreg();
        else if (hint == 2) res = getPC()+1;
        else if (hint == 3) res = getStackPtr();
        else if (hint == 4) res = getMemsize();
        // Add special cases for input data, input name
        else if (hint == 0x14) {
            if (getReg2() >= 1024) fin4l = true;
            else if (!checkInputNameAccess(getReg2(), getReg1())) {
                fin4l = true;
                getInputName(getReg2(), 0);
            }
            else res = getInputName(getReg2(), getReg1());
        }
        else if (hint == 0x15) {
            if (getReg2() >= 1024) fin4l = true;
            else if (!checkInputDataAccess(getReg2(), getReg1())) {
                fin4l = true;
                getInputData(getReg2(), 0);
            }
            else res = getInputData(getReg2(), getReg1());
        }
        else {
          uint loc = readPosition(hint);
        
          if (!checkReadAccess(loc, hint)) {
                setPC(FINAL_STATE);
                res = 0;
                fin4l = true;
                if (hint == 5) res = getGlobal(0);
                else if (hint == 6) res = getStack(0);
                else if (hint == 7) res = getStack(0);
                else if (hint == 8) res = getStack(0);
                else if (hint == 9) res = getStack(0);
                else if (hint == 14) res = getCallStack(0);
                else if (hint == 15) res = getMemory(0);
                else if (hint == 16) res = getCallTable(0);
                else if (hint == 17) res = getMemory(0);
                else if (hint == 18) res = getCallTypes(0);
                else if (hint == 19) res = getInputSize(0);
                else if (hint == 0x16) res = getStack(0);
          }
          else if (hint == 5) res = getGlobal(loc);
          else if (hint == 6) res = getStack(loc);
          else if (hint == 7) res = getStack(loc);
          else if (hint == 8) res = getStack(loc);
          else if (hint == 9) res = getStack(loc);
          else if (hint == 14) res = getCallStack(loc);
          else if (hint == 15) res = getMemory(loc);
          else if (hint == 16) res = getCallTable(loc);
          else if (hint == 17) res = getMemory(loc);
          else if (hint == 18) res = getCallTypes(loc);
          else if (hint == 19) res = getInputSize(loc);
          else if (hint == 0x16) res = getStack(loc);
          else assert(false);
        }
    }

    /**
    * @dev make changes to a memory location
    *
    * @param loc where should be changed inside memory
    * @param v the value to change the memory position to
    * @param hint denoted v's type and packing value
    *
    * @return none
    */
    function makeMemChange1(uint loc, uint v, uint hint) internal  {
        uint old = getMemory(loc);
        uint8[] memory mem = toMemory(old, 0);
        storeX(mem, (getReg1()+getIreg())%8, v, hint);
        uint res; uint extra;
        (res, extra) = fromMemory(mem);
        setMemory(loc, res);
    }
    
    /**
    * @dev make changes to a memory location
    *
    * @param loc where should the write be performed
    * @param v the value to be written to memory
    * @param hint denotes v's type and packing value
    *
    * @return none
    */
    function makeMemChange2(uint loc, uint v, uint hint) internal {
        uint old = getMemory(loc);
        uint8[] memory mem = toMemory(0, old);
        storeX(mem, (getReg1()+getIreg())%8, v, hint);
        uint res; uint extra;
        (extra, res) = fromMemory(mem);
        setMemory(loc, res);
        
    }

    /**
    * @dev get a pointer to where we want to write to based on the opcode
    *
    * @param hint the opcode
    *
    * @return returns a pointer to where to write to
    */
    function writePosition(uint hint) internal view returns (uint) {
        assert(hint > 0);
        if (hint == 2) return getStackPtr()-getReg1();
        else if (hint == 3) return getStackPtr();
        else if (hint == 4) return getStackPtr()-1;
        else if (hint == 5) return getReg1()+getReg2();
        else if (hint == 6) return getCallPtr();
        else if (hint == 8) return getReg1();
        else if (hint == 9) return getStackPtr()-2;
        else if (hint == 0x0a) return getReg1();
        else if (hint == 0x0c) return getReg1();
        else if (hint == 0x0e) return getIreg();
        else if (hint == 0x0f) return getIreg();
        else if (hint & 0xc0 == 0x80) return (getReg1()+getIreg())/8;
        else if (hint & 0xc0 == 0xc0) return (getReg1()+getIreg())/8 + 1;
        else assert(false);
    }
    
    /**
    * @dev perform a write
    *
    * @param hint the opcode
    * @param v the value to be written
    *
    * @return none
    */
    function writeStuff(uint hint, uint v) internal {
        if (hint == 0) return;
        // Special cases for creation, other output
        uint r1;
        if (hint == 0x0b) {
            r1 = getReg1();
            if (r1 >= 1024) setPC(FINAL_STATE);
            else if (!checkInputNameAccess(r1, getReg2())) {
                setPC(FINAL_STATE);
                getInputName(r1, 0);
            }
            else setInputName(r1, getReg2(), v);
        }
        else if (hint == 0x0c) {
            r1 = getReg1();
            if (r1 >= 1024) setPC(FINAL_STATE);
            else createInputData(r1, v);
        }
        else if (hint == 0x0d) {
            r1 = getReg1();
            if (r1 >= 1024) setPC(FINAL_STATE);
            else if (!checkInputDataAccess(r1, getReg2())) {
                setPC(FINAL_STATE);
                getInputData(r1, 0);
            }
            else setInputData(r1, getReg2(), v);
        }
        else if (hint == 0x10) setStackSize(v);
        else if (hint == 0x11) setCallStackSize(v);
        else if (hint == 0x12) setGlobalsSize(v);
        else if (hint == 0x13) setTableSize(v);
        else if (hint == 0x14) setTableTypesSize(v);
        else if (hint == 0x15) setMemorySize(v);
        else {
          uint loc = writePosition(hint);
          if (!checkWriteAccess(loc, hint)) {
              setPC(FINAL_STATE);
              if (hint & 0xc0 == 0x80) getMemory(0);
              else if (hint & 0xc0 == 0xc0) getMemory(0);
              else if (hint == 2) getStack(0);
              else if (hint == 3) getStack(0);
              else if (hint == 4) getStack(0);
              else if (hint == 6) getCallStack(0);
              else if (hint == 8) getGlobal(0);
              else if (hint == 9) getStack(0);
              else if (hint == 0x0a) getInputSize(0);
              else if (hint == 0x0e) getCallTable(0);
              else if (hint == 0x0f) getCallTypes(0);
          }
          else if (hint & 0xc0 == 0x80) makeMemChange1(loc, v, hint);
          else if (hint & 0xc0 == 0xc0) makeMemChange2(loc, v, hint);
          else if (hint == 2) setStack(loc, v);
          else if (hint == 3) setStack(loc, v);
          else if (hint == 4) setStack(loc, v);
          else if (hint == 6) setCallStack(loc, v);
          else if (hint == 8) setGlobal(loc, v);
          else if (hint == 9) setStack(loc, v);
          else if (hint == 0x0a) setInputSize(loc, v);
          else if (hint == 0x0e) setCallTable(loc, v);
          else if (hint == 0x0f) setCallType(loc, v);
          else assert(false);
        }
    }
    
    /**
    * @dev makes the necessary changes to a pointer based on the addressing mode provided by hint
    *
    * @param hint provides a hint as to what changes to make to the input pointer
    * @param ptr the pointer that's going to be handled
    *
    * @return returns the pointer after processing
    */
    function handlePointer(uint hint, uint ptr) internal view returns (uint) {
        if (hint == 0) return ptr - getReg1();
        else if (hint == 1) return getReg1();
        else if (hint == 2) return getReg2();
        else if (hint == 3) return getReg3();
        else if (hint == 4) return ptr+1;
        else if (hint == 5) return ptr-1;
        else if (hint == 6) return ptr;
        else if (hint == 7) return ptr-2;
        else if (hint == 8) return ptr-1-getIreg();
        else assert(false);
    }
    
    /**
    * @dev get the immediate value of an instruction
    */
    function getImmed(bytes32 op) internal pure returns (uint256) {
        // it is the first 8 bytes
        return uint(op)/(2**(13*8));
    }

    /**
    * @dev "fetch" an instruction
    */
    function performFetch() internal {
        setOp(getCode(getPC()));
    }

    /**
    * @dev initialize the Truebit register machine's registers
    */
    function performInit() internal  {
        setReg1(0);
        setReg2(0);
        setReg3(0);
        setIreg(getImmed(getOp()));
    }
    
    /**
    * @dev get the opcode
    *
    * @param n which opcode byte to read
    *
    * @return returns the opcode
    */
    function getHint(uint n) internal view returns (uint) {
        return (uint(getOp())/2**(8*n))&0xff;
    }
    
    /**
    * @dev read the first byte of the opcode and then read the value based on the hint into REG1
    */
    function performRead1() internal {
        uint res;
        bool fin4l;
        (res, fin4l) = readFrom(getHint(0));
        if (!fin4l) setReg1(res);
    }

    /**
    * @dev read the second byte of the opcode and then read the value based on the hint into REG2
    */
    function performRead2() internal {
        uint res;
        bool fin4l;
        (res, fin4l) = readFrom(getHint(1));
        if (!fin4l) setReg2(res);
    }

    /**
    * @dev read the third byte of the opcode and then read the value based on the hint into REG3
    */
    function performRead3() internal {
        uint res;
        bool fin4l;
        (res, fin4l) = readFrom(getHint(2));
        if (!fin4l) setReg3(res);
    }
    
    /**
    * @dev execute the opcode, put the result back in REG1
    */
    function performALU() internal {
        uint res;
        bool fin4l;
        (res, fin4l) = handleALU(getHint(3), getReg1(), getReg2(), getReg3(), getIreg());
        if (fin4l) setPC(FINAL_STATE);
        else setReg1(res);
    }
    
    /**
    * @dev write a value stored in REG to a location using the 4th and 5th hint bytes
    */
    function performWrite1() internal {
        uint target = getHint(4);
        uint hint = getHint(5);
        uint v;
        if (target == 1) v = getReg1();
        if (target == 2) v = getReg2();
        if (target == 3) v = getReg3();
        writeStuff(hint, v);
    }

    /**
    * @dev write a value stored in REG to a location using the 6th and 7th hint bytes
    */
    function performWrite2() internal {
        uint target = getHint(6);
        uint hint = getHint(7);
        uint v;
        if (target == 1) v = getReg1();
        if (target == 2) v = getReg2();
        if (target == 3) v = getReg3();
        writeStuff(hint, v);
    }
    
    function performUpdatePC() internal {
        setPC(handlePointer(getHint(11), getPC()));
    }
    function performUpdateStackPtr() internal {
        setStackPtr(handlePointer(getHint(9), getStackPtr()));
    }
    function performUpdateCallPtr() internal {
        setCallPtr(handlePointer(getHint(8), getCallPtr()));
    }
    function performUpdateMemsize() internal {
        if (getHint(12) == 1) setMemsize(getReg1());
    }
    
    uint phase;
    
    
    function performPhase() internal {
        if (getPC() == FINAL_STATE) {}
        else if (phase == 0) performFetch();
        else if (phase == 1) performInit();
        else if (phase == 2) performRead1();
        else if (phase == 3) performRead2();
        else if (phase == 4) performRead3();
        else if (phase == 5) performALU();
        else if (phase == 6) performWrite1();
        else if (phase == 7) performWrite2();
        else if (phase == 8) performUpdatePC();
        else if (phase == 9) performUpdateStackPtr();
        else if (phase == 10) performUpdateCallPtr();
        else if (phase == 11) performUpdateMemsize();
        phase = (phase+1) % 12;
    }
    
}



contract Judge is CommonOnchain {

    address winner;
    
    bytes32 mask = bytes32(uint256(0xffffffffffffffffffffffffffffffffffffffffffffffff));
    
    function checkProof(bytes32[] memory pr, bytes32[] memory pr2) internal view {
       if (pr2.length == 0 && !(phase == 7 && getHint(7) == 0x0c)) require (pr.length == 0 || (pr.length != 1 && pr[0] == pr[0]&mask && pr[1] == pr[1]&mask));
    }

    function judgeCustom(bytes32 start, bytes32 next, bytes32 ex_state, uint ex_size, bytes32 op, uint[4] memory regs, bytes32[10] memory roots,
     uint[4] memory pointers, bytes32[] memory _proof) public {
         
         setVM(roots, pointers);
         setMachine(hashVM(), op, regs[0], regs[1], regs[2], regs[3]);
         proof = _proof;
         
         require(hashMachine() == start);
         require(getRoot(regs[0]) == vm_r.input_data);
         
         // state after execution
         regs[1] = ex_size;
         // checkProof(_proof);
         setInputFile(regs[0], ex_state);
         
         m.vm = hashVM();
         require(hashMachine() == next);
    }

    function judge(bytes32[13] memory res, uint q,
                        bytes32[] memory _proof, bytes32[] memory _proof2,
                        bytes32 vm_, bytes32 op, uint[4] memory regs,
                        bytes32[10] memory roots, uint[4] memory pointers) public returns (uint) {
        setMachine(vm_, op, regs[0], regs[1], regs[2], regs[3]);
        setVM(roots, pointers);
        // Special initial state
        if (q == 0) {
            m.vm = hashVM();
            state = hashMachine();
            require(m.vm == res[q]);
        }
        else {
           require(hashVM() == m.vm);
           state = res[q];
           require(state == hashMachine());
        }
        phase = q;
        checkProof(_proof, _proof2);
        proof = _proof;
        proof2 = _proof2;
        performPhase();
        // Special final state
        if (q == 11) state = m.vm;
        require (state == res[q+1]);
        winner = msg.sender;
        return q;
    }

    function debug_judge(bytes32[13] memory res, uint q,
                        bytes32[] memory _proof, bytes32[] memory _proof2,
                        bytes32 vm_, bytes32 op, uint[4] memory regs,
                        bytes32[10] memory roots, uint[4] memory pointers) public returns (uint, bytes32, bytes32, uint) {
        setMachine(vm_, op, regs[0], regs[1], regs[2], regs[3]);
        setVM(roots, pointers);
        // Special initial state
        if (q == 0) {
            m.vm = hashVM();
            state = hashMachine();
            // require(m.vm == res[q]);
        }
        else {
           state = res[q];
           // require(state == hashMachine());
        }
        phase = q;
        checkProof(_proof, _proof2);
        proof = _proof;
        proof2 = _proof2;
        performPhase();
        // Special final state
        if (q == 11) state = m.vm;
        // require (state == res[q+1]);
        winner = msg.sender;
        return (q, state, debugb, debug);
    }

    function checkFileProof(bytes32 state, bytes32[10] memory roots, uint[4] memory pointers, bytes32[] memory _proof, uint loc) public returns (bool) {
        setVM(roots, pointers);
        proof = _proof;
        return state == calcIOHash(roots) && vm_r.input_data == getRoot(loc);
    }

    function checkProof(bytes32 hash, bytes32 root, bytes32[] memory _proof, uint loc) public returns (bool) {
        proof = _proof;
        return uint(hash) == getLeaf(loc) && root == getRoot(loc);
    }

    function calcStateHash(bytes32[10] memory roots, uint[4] memory pointers) public returns (bytes32) {
        setVM(roots, pointers);
        return hashVM();
    }

    function calcIOHash(bytes32[10] memory roots) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(roots[0], roots[7], roots[8], roots[9]));
    }

}
