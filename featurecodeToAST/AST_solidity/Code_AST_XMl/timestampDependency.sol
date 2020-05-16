pragma solidity 0.4.24;

contract TimestampDependence {

    function doSomething() {
        uint startTime = now;
        // <yes> <report> solidity_timestamp_dependency tim101
        if ( startTime + 1 minutes == block.timestamp) {}
        // <yes> <report> solidity_timestamp_dependency tim101
        if ( startTime + 1 minutes != now) {}
        require(true == ICOisEnd(now));
        require(now >= startTime && now <= startTime + 1 minutes);
        require(now > startTime + 1 minutes);
    }

    function ICOisEnd(uint _time) returns(bool) {
        return _time > 1000000000;
    }
}