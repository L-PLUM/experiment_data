/**
 *Submitted for verification at Etherscan.io on 2019-02-19
*/

pragma solidity 0.5.2;
contract InstagramPosting{ 
    struct Post{ 
        address owner;
        string imgHash; 
        string textHash; 
    }
    mapping(address => string) public username; 
    mapping(uint256 => Post) posts; 
    uint256 postCtr;
event NewPost(); 
    event SetName();
function sendHash( 
        string memory _img, 
        string memory _text 
    ) 
        public 
    { 
        Post storage posting = posts[++postCtr];
        posting.owner = msg.sender;
        posting.imgHash = _img;
        posting.textHash = _text;
emit NewPost();
    }
function getHash(uint256 _index) 
        public 
        view 
        returns ( 
            string memory img,
            string memory text, 
            address owner 
        ) 
    { 
        owner = posts[_index].owner; 
        img = posts[_index].imgHash; 
        text = posts[_index].textHash; 
    }
function getCounter() public view returns(uint256) { return postCtr; }
function setName(string memory _name) public { 
        username[msg.sender] = _name; 
        emit SetName(); 
    } 
}
