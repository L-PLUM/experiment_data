/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity ^0.4.24;

contract Application {
    function Application() public {}
    enum Assets {
        room, message
    }
    Assets _createRoom = Assets.room;
    Assets _sendMessage = Assets.message;

    function createRoom (
        string assetId, /* parameter needed for linking assets and transactions */
        string name, /* optional parameter */
        string creator, /* optional parameter */
        string _bundleHash)   /* optional parameter */
    public {}

    function sendMessage (
        string assetId, /* parameter needed for linking assets and transactions */
        string room, /* optional parameter */
        string sender, /* optional parameter */
        string _bundleHash)   /* optional parameter */
    public {}
}
