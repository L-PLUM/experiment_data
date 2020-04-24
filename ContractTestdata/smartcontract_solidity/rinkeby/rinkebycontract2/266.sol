/**
 *Submitted for verification at Etherscan.io on 2019-08-01
*/

// hevm: flattened sources of src/CdcExchange.sol
pragma solidity >0.4.13 >0.4.20 >=0.4.23 >=0.4.25 <0.5.0;

////// lib/ds-auth/src/auth.sol
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

/* pragma solidity >=0.4.23; */

contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig), "ds-auth-unauthorized");
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, address(this), sig);
        }
    }
}

////// lib/ds-math/src/math.sol
/// math.sol -- mixin for inline numerical wizardry

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

/* pragma solidity >0.4.13; */

contract DSMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}

////// lib/ds-note/src/note.sol
/// note.sol -- the `note' modifier, for logging calls as events

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

/* pragma solidity >=0.4.23; */

contract DSNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint256           wad,
        bytes             fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;
        uint256 wad;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
            wad := callvalue
        }

        emit LogNote(msg.sig, msg.sender, foo, bar, wad, msg.data);

        _;
    }
}

////// lib/ds-stop/src/stop.sol
/// stop.sol -- mixin for enable/disable functionality

// Copyright (C) 2017  DappHub, LLC

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

/* pragma solidity >=0.4.23; */

/* import "ds-auth/auth.sol"; */
/* import "ds-note/note.sol"; */

contract DSStop is DSNote, DSAuth {
    bool public stopped;

    modifier stoppable {
        require(!stopped, "ds-stop-is-stopped");
        _;
    }
    function stop() public auth note {
        stopped = true;
    }
    function start() public auth note {
        stopped = false;
    }

}

////// lib/ds-token/lib/erc20/src/erc20.sol
/// erc20.sol -- API for the ERC20 token standard

// See <https://github.com/ethereum/EIPs/issues/20>.

// This file likely does not meet the threshold of originality
// required for copyright to apply.  As a result, this is free and
// unencumbered software belonging to the public domain.

/* pragma solidity >0.4.20; */

contract ERC20Events {
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
}

contract ERC20 is ERC20Events {
    function totalSupply() public view returns (uint);
    function balanceOf(address guy) public view returns (uint);
    function allowance(address src, address guy) public view returns (uint);

    function approve(address guy, uint wad) public returns (bool);
    function transfer(address dst, uint wad) public returns (bool);
    function transferFrom(
        address src, address dst, uint wad
    ) public returns (bool);
}

////// lib/ds-token/src/base.sol
/// base.sol -- basic ERC20 implementation

// Copyright (C) 2015, 2016, 2017  DappHub, LLC

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

/* pragma solidity >=0.4.23; */

/* import "erc20/erc20.sol"; */
/* import "ds-math/math.sol"; */

contract DSTokenBase is ERC20, DSMath {
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

    constructor(uint supply) public {
        _balances[msg.sender] = supply;
        _supply = supply;
    }

    function totalSupply() public view returns (uint) {
        return _supply;
    }
    function balanceOf(address src) public view returns (uint) {
        return _balances[src];
    }
    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        if (src != msg.sender) {
            require(_approvals[src][msg.sender] >= wad, "ds-token-insufficient-approval");
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        require(_balances[src] >= wad, "ds-token-insufficient-balance");
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;

        emit Approval(msg.sender, guy, wad);

        return true;
    }
}

////// lib/ds-token/src/token.sol
/// token.sol -- ERC20 implementation with minting and burning

// Copyright (C) 2015, 2016, 2017  DappHub, LLC

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

/* pragma solidity >=0.4.23; */

/* import "ds-stop/stop.sol"; */

/* import "./base.sol"; */

contract DSToken is DSTokenBase(0), DSStop {

    bytes32  public  symbol;
    uint256  public  decimals = 18; // standard token precision. override to customize

    constructor(bytes32 symbol_) public {
        symbol = symbol_;
    }

    event Mint(address indexed guy, uint wad);
    event Burn(address indexed guy, uint wad);

    function approve(address guy) public stoppable returns (bool) {
        return super.approve(guy, uint(-1));
    }

    function approve(address guy, uint wad) public stoppable returns (bool) {
        return super.approve(guy, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        stoppable
        returns (bool)
    {
        if (src != msg.sender && _approvals[src][msg.sender] != uint(-1)) {
            require(_approvals[src][msg.sender] >= wad, "ds-token-insufficient-approval");
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        require(_balances[src] >= wad, "ds-token-insufficient-balance");
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        emit Transfer(src, dst, wad);

        return true;
    }

    function push(address dst, uint wad) public {
        transferFrom(msg.sender, dst, wad);
    }
    function pull(address src, uint wad) public {
        transferFrom(src, msg.sender, wad);
    }
    function move(address src, address dst, uint wad) public {
        transferFrom(src, dst, wad);
    }

    function mint(uint wad) public {
        mint(msg.sender, wad);
    }
    function burn(uint wad) public {
        burn(msg.sender, wad);
    }
    function mint(address guy, uint wad) public auth stoppable {
        _balances[guy] = add(_balances[guy], wad);
        _supply = add(_supply, wad);
        emit Mint(guy, wad);
    }
    function burn(address guy, uint wad) public auth stoppable {
        if (guy != msg.sender && _approvals[guy][msg.sender] != uint(-1)) {
            require(_approvals[guy][msg.sender] >= wad, "ds-token-insufficient-approval");
            _approvals[guy][msg.sender] = sub(_approvals[guy][msg.sender], wad);
        }

        require(_balances[guy] >= wad, "ds-token-insufficient-balance");
        _balances[guy] = sub(_balances[guy], wad);
        _supply = sub(_supply, wad);
        emit Burn(guy, wad);
    }

    // Optional token name
    bytes32   public  name = "";

    function setName(bytes32 name_) public auth {
        name = name_;
    }
}

////// src/CdcExchange.sol
/* pragma solidity ^0.4.25; */

/* import "ds-math/math.sol"; */
/* import "ds-auth/auth.sol"; */
/* import "ds-token/token.sol"; */
/* import "ds-stop/stop.sol"; */
/* import "ds-note/note.sol"; */


/**
* @dev Contract to getting ETH/USD price
*/
contract MedianizerLike {
    function peek() external view returns (bytes32, bool);
}

/**
* @dev Contract to calculating fee by user and sended amount
*/
contract CdcFinance {
    function calculateFee(address sender, uint value) external view returns (uint);
}

/**
 * @title Cdc
 * @dev Cdc Exchange contract.
 */
contract CdcExchangeEvents {
    event LogBuyToken(
        address owner,
        address sender,
        uint ethValue,
        uint cdcValue,
        uint rate
    );
    event LogBuyTokenWithFee(
        address owner,
        address sender,
        uint ethValue,
        uint cdcValue,
        uint rate,
        uint fee
    );
    event LogBuyDptFee(address sender, uint ethValue, uint ethUsdRate, uint dptUsdRate, uint fee);

    event LogDptSellerChange(address dptSeller);
    event LogSetFee(uint fee);

    event LogSetEthUsdRate(uint rate);
    event LogSetCdcUsdRate(uint rate);
    event LogSetDptUsdRate(uint rate);

    event LogSetManualCdcRate(bool value);
    event LogSetManualDptRate(bool value);
    event LogSetManualEthRate(bool value);

    event LogSetEthPriceFeed(address priceFeed);
    event LogSetDptPriceFeed(address priceFeed);
    event LogSetCdcPriceFeed(address priceFeed);
    event LogSetCfo(address cfo);
}

contract CdcExchange is DSAuth, DSStop, DSMath, CdcExchangeEvents {
    DSToken public cdc;                     //CDC token contract
    DSToken public dpt;                     //DPT token contract

    MedianizerLike public ethPriceFeed;     //address of the ETH/USD price feed
    MedianizerLike public dptPriceFeed;     //address of the DPT/USD price feed
    MedianizerLike public cdcPriceFeed;     //address of the CDC/USD price feed

    uint public dptUsdRate;                 //how many USD 1 DPT cost. 18 digit precision
    uint public cdcUsdRate;                 //how many USD 1 CDC cost. 18 digit precision
    uint public ethUsdRate;                 //how many USD 1 ETH cost. 18 digit precision
    bool public manualEthRate = true;       //allow to use/set manually setted DPT/USD rate
    bool public manualDptRate = true;       //allow to use/set manually setted CDC/USD rate
    bool public manualCdcRate = true;       //allow to use/set manually setted CDC/USD rate

    uint public fee = 0.5 ether;            //fee in USD on buying CDC
    CdcFinance public cfo;                  //CFO of CDC contract

    address public dptSeller;               //from this address user buy DPT fee
    address public burner;                  //contract where DPT as fee are stored before be burned

    constructor(
        address cdc_,
        address dpt_,
        address ethPriceFeed_,
        address dptPriceFeed_,
        address cdcPriceFeed_,
        address dptSeller_,
        address burner_,
        uint dptUsdRate_,
        uint cdcUsdRate_,
        uint ethUsdRate_
    ) public {
        cdc = DSToken(cdc_);
        dpt = DSToken(dpt_);
        ethPriceFeed = MedianizerLike(ethPriceFeed_);
        dptPriceFeed = MedianizerLike(dptPriceFeed_);
        cdcPriceFeed = MedianizerLike(cdcPriceFeed_);
        dptSeller = dptSeller_;
        burner = burner_;
        dptUsdRate = dptUsdRate_;
        cdcUsdRate = cdcUsdRate_;
        ethUsdRate = ethUsdRate_;
    }

    /**
    * @dev Fallback function is used to buy tokens.
    */
    function () external payable {
        buyTokensWithFee();
    }

    /**
    * @dev Тoken purchase with fee. User have to approve DPT before (if it has already)
    * otherwise transaction w'll fail
    */
    function buyTokensWithFee() public payable stoppable returns (uint tokens) {
        require(msg.value != 0, "Invalid amount");

        // Getting rates from price feeds
        updateRates();

        uint amountEthToBuyCdc = msg.value;
        // Get fee in USD
        fee = calculateFee(msg.sender, msg.value);

        if (fee > 0) {
            // take or sell fee and return remaining ETH amount to buy CDC
            amountEthToBuyCdc = takeFee(fee, amountEthToBuyCdc);
        }

        // send CDC to user
        tokens = sellCdc(msg.sender, amountEthToBuyCdc);

        emit LogBuyTokenWithFee(owner, msg.sender, msg.value, tokens, cdcUsdRate, fee);
        return tokens;
    }

    /**
    * @dev Ability to delegate fee calculating to external contract.
    * @return the fee amount in USD
    */
    function calculateFee(address sender, uint value) public view returns (uint) {
        if (cfo == CdcFinance(0)) {
            return fee;
        } else {
            return cfo.calculateFee(sender, value);
        }
    }

    /**
    * @dev Set the fee to buying CDC
    */
    function setFee(uint fee_) public auth {
        fee = fee_;
        emit LogSetFee(fee);
    }

    /**
    * @dev Set the ETH/USD price feed
    */
    function setEthPriceFeed(address ethPriceFeed_) public auth {
        require(ethPriceFeed_ != 0x0, "Wrong PriceFeed address");
        ethPriceFeed = MedianizerLike(ethPriceFeed_);
        emit LogSetEthPriceFeed(ethPriceFeed);
    }

    /**
    * @dev Set the DPT/USD price feed
    */
    function setDptPriceFeed(address dptPriceFeed_) public auth {
        require(dptPriceFeed_ != 0x0, "Wrong PriceFeed address");
        dptPriceFeed = MedianizerLike(dptPriceFeed_);
        emit LogSetDptPriceFeed(dptPriceFeed);
    }

    /**
    * @dev Set the CDC/USD price feed
    */
    function setCdcPriceFeed(address cdcPriceFeed_) public auth {
        require(cdcPriceFeed_ != 0x0, "Wrong PriceFeed address");
        cdcPriceFeed = MedianizerLike(cdcPriceFeed_);
        emit LogSetCdcPriceFeed(cdcPriceFeed);
    }

    /**
    * @dev Set the DPT seller with balance > 0
    */
    function setDptSeller(address dptSeller_) public auth {
        require(dptSeller_ != 0x0, "Wrong address");
        require(dpt.balanceOf(dptSeller_) > 0, "Insufficient funds of DPT");
        dptSeller = dptSeller_;
        emit LogDptSellerChange(dptSeller);
    }

    /**
    * @dev Set manual feed update
    *
    * If `manualDptRate` is true, then `buyDptFee()` will calculate the DPT amount based on latest valid `dptUsdRate`,
    * so `dptEthRate` must be updated by admins if priceFeed fails to provide valid price data.
    *
    * If manualEthRate is false, then buyDptFee() will simply revert if priceFeed does not provide valid price data.
    */
    function setManualDptRate(bool manualDptRate_) public auth {
        manualDptRate = manualDptRate_;
        emit LogSetManualDptRate(manualDptRate);
    }

    function setManualCdcRate(bool manualCdcRate_) public auth {
        manualCdcRate = manualCdcRate_;
        emit LogSetManualCdcRate(manualCdcRate);
    }

    function setManualEthRate(bool manualEthRate_) public auth {
        manualEthRate = manualEthRate_;
        emit LogSetManualEthRate(manualEthRate);
    }

    function setCfo(address cfo_) public auth {
        require(cfo_ != 0x0, "Wrong address");
        cfo = CdcFinance(cfo_);
        emit LogSetCfo(cfo);
    }

    function setDptUsdRate(uint dptUsdRate_) public auth {
        require(dptUsdRate_ > 0, "Rate have to be larger than 0");
        dptUsdRate = dptUsdRate_;
        emit LogSetDptUsdRate(dptUsdRate);
    }

    function setCdcUsdRate(uint cdcUsdRate_) public auth {
        require(cdcUsdRate_ > 0, "Rate have to be larger than 0");
        cdcUsdRate = cdcUsdRate_;
        emit LogSetCdcUsdRate(cdcUsdRate);
    }

    function setEthUsdRate(uint ethUsdRate_) public auth {
        require(ethUsdRate_ > 0, "Rate have to be larger than 0");
        ethUsdRate = ethUsdRate_;
        emit LogSetEthUsdRate(ethUsdRate);
    }


    // internal functions

    /**
    * @dev Get ETH/USD rate from priceFeed or if allowed manually setted ethUsdRate
    * Revert transaction if not valid feed and manual value not allowed
    */
    function updateEthUsdRate() internal {
        bool feedValid;
        bytes32 ethUsdRateBytes;

        // receive ETH/DPT price
        (ethUsdRateBytes, feedValid) = ethPriceFeed.peek();

        // if feed is valid, load ETH/USD rate from it
        if (feedValid) {
            ethUsdRate = uint(ethUsdRateBytes);
        } else {
            // if feed invalid revert if manualEthRate is NOT allowed
            require(manualEthRate, "Feed is invalid and manual rate is not allowed");
        }
    }

    /**
    * @dev Get DPT/USD rate from priceFeed or if allowed manually setted dptUsdRate
    * Revert transaction if not valid feed and manual value not allowed
    */
    function updateDptUsdRate() internal {
        bool feedValid;
        bytes32 dptUsdRateBytes;

        // receive DPT/USD price
        (dptUsdRateBytes, feedValid) = dptPriceFeed.peek();

        // if feed is valid, load DPT/USD rate from it
        if (feedValid) {
            dptUsdRate = uint(dptUsdRateBytes);
        } else {
            // if feed invalid revert if manualEthRate is NOT allowed
            require(manualDptRate, "Manual rate not allowed");
        }
    }

    /**
    * @dev Get CDC/USD rate from priceFeed or if allowed manually setted cdcUsdRate
    * Revert transaction if not valid feed and manual value not allowed
    */
    function updateCdcUsdRate() internal {
        bool feedValid;
        bytes32 cdcUsdRateBytes;

        // receive DPT/USD price
        (cdcUsdRateBytes, feedValid) = cdcPriceFeed.peek();

        // if feed is valid, load DPT/USD rate from it
        if (feedValid) {
            cdcUsdRate = uint(cdcUsdRateBytes);
        } else {
            // if feed invalid revert if manualEthRate is NOT allowed
            require(manualCdcRate, "Manual rate not allowed");
        }
    }

    function updateRates() internal {
        updateEthUsdRate();
        updateDptUsdRate();
        updateCdcUsdRate();
    }

    /**
    * @dev Taking fee from user. If user has DPT take it, if there are no funds buy it
    * @return the amount of remaining ETH after buying fee if it was required
    */
    function takeFee(uint feeUsd, uint amountEth) internal returns(uint remainingEth) {
        remainingEth = amountEth;
        // Convert to DPT
        uint feeDpt = wdiv(feeUsd, dptUsdRate);
        // Take fee in DPT from user balance
        uint remainingFeeDpt = takeFeeInDptFromUser(msg.sender, feeDpt);

        // insufficient funds of DPT => user has to buy remaining fee by ETH
        if (remainingFeeDpt > 0) {
            uint feeEth = buyDptFee(remainingFeeDpt);
            remainingEth = sub(remainingEth, feeEth);
        }

        // "burn" DPT fee
        dpt.transfer(burner, feeDpt);
        return remainingEth;
    }

    /**
    * @dev User buy fee from dptSeller in DPT by ETH with actual DPT/USD and ETH/USD rate.
    * @return the amount of sold fee in ETH
    */
    function buyDptFee(uint feeDpt) internal returns (uint amountEth) {
        uint feeUsd = wmul(feeDpt, dptUsdRate);
        // calculate fee in ETH
        amountEth = wdiv(feeUsd, ethUsdRate);
        // user pays for fee
        address(dptSeller).transfer(amountEth);
        // transfer bought fee to contract, this fee will be burned
        dpt.transferFrom(dptSeller, address(this), feeDpt);

        emit LogBuyDptFee(msg.sender, amountEth, ethUsdRate, dptUsdRate, feeUsd);
        return amountEth;
    }

    /**
    * @dev Take fee in DPT from user if it has any
    * @param feeDpt the fee amount in DPT
    * @return the remaining fee amount in DPT
    */
    function takeFeeInDptFromUser(address user, uint feeDpt) internal returns (uint remainingFee) {
        uint dptUserBalance = dpt.balanceOf(user);

        // calculate how many DPT user have to buy
        uint minDpt = min(feeDpt, dptUserBalance);
        remainingFee = sub(feeDpt, minDpt);

        // transfer to contract for future burn
        if (minDpt > 0) dpt.transferFrom(user, address(this), minDpt);

        return remainingFee;
    }

    /**
    * @dev Calculate and transfer CDC tokens to user. Transfer ETH to owner for CDC
    * @return sold token amount
    */
    function sellCdc(address user, uint amountEth) internal returns (uint tokens) {
        tokens = wdiv(wmul(amountEth, ethUsdRate), cdcUsdRate);
        cdc.transferFrom(owner, user, tokens);
        address(owner).transfer(amountEth);
        return tokens;
    }
}
