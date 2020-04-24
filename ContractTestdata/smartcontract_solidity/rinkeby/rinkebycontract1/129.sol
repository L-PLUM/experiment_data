/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

/**
 * Copyright (C) 2018 Smartz, LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).
 */

pragma solidity ^0.4.20;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
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
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


/**
 * @title Booking
 * @author Vladimir Khramov <[email protected]>
 */
contract Booking is Ownable {

    function Booking() public payable {

        m_address = 'qqqqqqqqqqqqqqqqqqqqqqq';
        m_description = 'qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq';
        m_fileUrl = 'javascript: alert(1)';
        m_fileHash = 0;
        m_price = 1000000000000;
        m_cancellationFee = 10000000000;
        m_rentDateStart = 1550782800;
        m_rentDateEnd = 1550869200;
        m_noCancelPeriod = 1;
        m_acceptObjectPeriod = 1;

        assert(m_price > 0);
        assert(m_price > m_cancellationFee);
        assert(m_rentDateStart > getCurrentTime());
        assert(m_rentDateEnd > m_rentDateStart);

        assert(m_rentDateStart+m_acceptObjectPeriod*60*60 < m_rentDateEnd);
        assert(m_rentDateStart > m_noCancelPeriod*60*60);
        
        
    }

    /************************** STRUCTS **********************/
    enum State {OFFER, PAID, NO_CANCEL, RENT, CANCELED, FINISHED}

    /************************** MODIFIERS **********************/

    modifier onlyState(State _state) {
        require(getCurrentState() == _state);
        _;
    }

    modifier onlyClient() {
        require(msg.sender == m_client);
        _;
    }

    /************************** EVENTS **********************/

    event StateChanged(State newState);

    /************************** CONSTANTS **********************/

    /************************** PROPERTIES **********************/

    string public m_address;
    string public m_description;
    string public m_fileUrl;
    bytes32 public m_fileHash;


    uint256 public m_price;
    uint256 public m_cancellationFee;

    uint256 public m_rentDateStart;
    uint256 public m_rentDateEnd;

    uint256 public m_noCancelPeriod;
    uint256 public m_acceptObjectPeriod;

    address public m_client;

    State internal m_state;


    /************************** FALLBACK **********************/

    function() external payable onlyState(State.OFFER) {
        require(msg.value >= m_price);
        require(msg.sender != owner);
        require(m_rentDateStart > getCurrentTime());


        changeState(State.PAID);
        m_client = msg.sender;

        if (msg.value > m_price) {
            msg.sender.transfer(msg.value-m_price);
        }
    }
    /************************** EXTERNAL **********************/


    function rejectPayment() external onlyOwner onlyState(State.PAID) {
        refundWithoutCancellationFee();
    }


    function refund() external onlyClient onlyState(State.PAID) {
        refundWithoutCancellationFee();
    }

    function startRent() external onlyClient onlyState(State.NO_CANCEL) {
        require(getCurrentTime() > m_rentDateStart);

        changeState(State.RENT);
        owner.transfer(address(this).balance);
    }

    function cancelBooking() external onlyState(State.NO_CANCEL) {
        if (getCurrentTime() >= m_rentDateStart+m_acceptObjectPeriod*60*60) {
            require(msg.sender == owner);
        } else {
            require(msg.sender == m_client);
        }

        refundWithCancellationFee();
    }

    /************************** PUBLIC **********************/

    function getCurrentState() public view returns(State) {
        if (m_state == State.PAID) {
            if (getCurrentTime() >= m_rentDateStart - m_noCancelPeriod*60*60) {
                return State.NO_CANCEL;
            } else {
                return State.PAID;
            }
        } if (m_state == State.RENT)  {
            if (getCurrentTime() >= m_rentDateEnd) {
                return State.FINISHED;
            } else {
                return State.RENT;
            }
        } else {
            return m_state;
        }
    }

    /************************** INTERNAL **********************/


    function changeState(State _newState) internal {
        State currentState = getCurrentState();

        if (State.OFFER == _newState) {
            assert(State.PAID == currentState || State.NO_CANCEL == currentState);

        } else if (State.PAID == _newState) {
            assert(State.OFFER == currentState);
            assert(address(this).balance > 0);

        } else if (State.NO_CANCEL == _newState) {
            assert(false); // no direct change

        } else if (State.CANCELED == _newState) {
            assert(State.NO_CANCEL == currentState);

        } else if (State.RENT == _newState) {
            assert(State.NO_CANCEL == currentState);

        } else if (State.FINISHED == _newState) {
            assert(false); // no direct change

        }

        m_state = _newState;
        StateChanged(_newState);
    }

    function getCurrentTime() internal view returns (uint256) {
        return now;
    }

    /************************** PRIVATE **********************/

    function refundWithoutCancellationFee() private  {
        address client = m_client;
        m_client = address(0);
        changeState(State.OFFER);


        client.transfer(address(this).balance);
    }

    function refundWithCancellationFee() private {
        address client = m_client;
        m_client = address(0);
        changeState(State.CANCELED);

        owner.transfer(m_cancellationFee);
        client.transfer(address(this).balance);
    }

}
