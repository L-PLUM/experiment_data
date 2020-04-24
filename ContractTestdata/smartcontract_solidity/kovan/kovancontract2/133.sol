/**
 *Submitted for verification at Etherscan.io on 2019-07-31
*/

pragma solidity >=0.5.0;

contract DSNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  usr,
        bytes32  indexed  arg1,
        bytes32  indexed  arg2,
        bytes             data
    ) anonymous;

    modifier note {
        _;
        assembly {
            // log an 'anonymous' event with a constant 6 words of calldata
            // and four indexed topics: selector, caller, arg1 and arg2
            let mark := msize                         // end of memory ensures zero
            mstore(0x40, add(mark, 288))              // update free memory pointer
            mstore(mark, 0x20)                        // bytes type data offset
            mstore(add(mark, 0x20), 224)              // bytes size (padded)
            calldatacopy(add(mark, 0x40), 0, 224)     // bytes payload
            log4(mark, 288,                           // calldata
                 shl(224, shr(224, calldataload(0))), // msg.sig
                 caller,                              // msg.sender
                 calldataload(4),                     // arg1
                 calldataload(36)                     // arg2
                )
        }
    }
}
contract VatLike {
    function slip(bytes32,address,int) public;
}

// GemJoin1

contract GemLike {
    function decimals() public view returns (uint);
    function transfer(address,uint) public returns (bool);
    function transferFrom(address,address,uint) public returns (bool);
}

contract GemJoin1 is DSNote {
    VatLike public vat;
    bytes32 public ilk;
    GemLike public gem;
    uint    public dec;

    constructor(address vat_, bytes32 ilk_, address gem_) public {
        vat = VatLike(vat_);
        ilk = ilk_;
        gem = GemLike(gem_);
        dec = gem.decimals();
    }

    function join(address usr, uint wad) public note {
        require(int(wad) >= 0, "GemJoin1/overflow");
        vat.slip(ilk, usr, int(wad));
        require(gem.transferFrom(msg.sender, address(this), wad), "GemJoin1/failed-transfer");
    }

    function exit(address usr, uint wad) public note {
        require(wad <= 2 ** 255, "GemJoin1/overflow");
        vat.slip(ilk, msg.sender, -int(wad));
        require(gem.transfer(usr, wad), "GemJoin1/failed-transfer");
    }
}
