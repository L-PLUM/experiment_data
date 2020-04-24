pragma solidity 0.4.24;

contract CallValue {

    function withdraw1() {
    // <yes> <report> solidity_call_without_data call01
        if (msg.sender.call.value(1)()) {
        }
    }
    function withdraw2() {
    // <yes> <report> solidity_call_without_data call01
        if (msg.sender.call()) {
        }
    }
    function withdraw3() {
    // <yes> <report> solidity_call_without_data call02
        if (msg.sender.call.gas(100000)()) {
        }
    }
    function withdraw4() {
        if (msg.sender.call.value(1)(3)) {
        }
    }
    function withdraw5() {
        // <yes> <report> solidity_call_without_data call03
        if (msg.sender.call.value(1)("")) {
        }
    }
    function withdraw6() {
        // <yes> <report> solidity_call_without_data call03
        if (msg.sender.call("")) {
        }
    }
    function withdraw7() {
        // <yes> <report> solidity_call_without_data call04
        if (msg.sender.call.gas(100000)("")) {
        }
    }
    function withdraw8() {
        if (msg.sender.call.value(1)(" ")) {
        }
    }
    function withdraw9() {
        if (msg.sender.call("", 1)) {
        }
    }
    function withdraw10() {
        if (msg.sender.call.gas(100000)("", 1)) {
        }
    }
}
