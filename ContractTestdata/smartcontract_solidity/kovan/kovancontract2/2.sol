/**
 *Submitted for verification at Etherscan.io on 2019-08-12
*/

pragma solidity >=0.5.0;

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity >=0.4.23;

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

interface ERC20Like {
    function balanceOf(address) external view returns (uint256);
    function transfer(address,uint256) external; // return bool?
}

contract TokenFaucet is DSNote {
    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address guy) public auth note { wards[guy] = 1; }
    function deny(address guy) public auth note { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    uint256 public amt;
    mapping (address => mapping (address => bool)) public done;

    constructor (uint256 amt_) public {
        wards[msg.sender] = 1;
        amt = amt_;
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function gulp(address gem) external {
        require(!done[msg.sender][address(gem)], "token-faucet: already used faucet");
        require(ERC20Like(gem).balanceOf(address(this)) >= amt, "token-faucet: not enough balance");
        done[msg.sender][address(gem)] = true;
        ERC20Like(gem).transfer(msg.sender, amt);
    }

    function gulp(address gem, address[] calldata addrs) external {
        require(ERC20Like(gem).balanceOf(address(this)) >= mul(amt, addrs.length), "token-faucet: not enough balance");

        for (uint i = 0; i < addrs.length; i++) {
            require(!done[addrs[i]][address(gem)], "token-faucet: already used faucet");
            done[addrs[i]][address(gem)] = true;
            ERC20Like(gem).transfer(addrs[i], amt);
        }
    }

    function shut(ERC20Like gem) external auth {
        gem.transfer(msg.sender, gem.balanceOf(address(this)));
    }

    function setamt(uint256 amt_) external auth note {
        amt = amt_;
    }
}
