/**
 *Submitted for verification at Etherscan.io on 2019-02-13
*/

pragma solidity ^0.4.24;

// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        require(b > 0);
        c = a / b;
    }
}


contract ERC20 {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}

contract Academy {
  using SafeMath for uint256;
  address public admin; //the admin address
  address public cto;  // the CTO address
  address public tokenEVOT; //evot token address
  mapping(address => MyStruct) myStructsOfVideos;
  uint256 public videoPriceForEth;
  uint256 public videoPriceForEvot;
  
  struct MyStruct {
    uint256[] videoIds;
  }

  constructor() public {
    admin = msg.sender;
  }
  
  modifier onlyCEO {
      require(msg.sender == admin);
        _;
   }

   modifier onlyAdmin {
       require(msg.sender == admin || msg.sender == cto);
       _;
   }
  
  // set CTO
  function setCTO(address _cto) onlyCEO() public {
    cto = _cto;
  }
  
  // set the EVOT token contract address
  function setTokenAddress(address _token) onlyAdmin() public {
      tokenEVOT = _token;
  }
  
  // set video price for ether
  function setVideoPriceForEth(uint256 _price) onlyAdmin() public {
    videoPriceForEth = _price;    
  }
  
  // set video price for evot
  function setVideoPriceForEvot(uint256 _price) onlyAdmin() public {
    videoPriceForEvot = _price;    
  }
  
  //get video price for ether
  function getVideoPriceForEth() public constant returns(uint256) {
    return videoPriceForEth;    
  }
  
  //get video price for evot
  function getVideoPriceForEvot() public constant returns(uint256) {
    return videoPriceForEvot;    
  }
  
  //fall back
  function() payable public {
      
  }
  
  // buy video for ETH
  function buyVideoByEth(uint256 videoId) payable public {
    require(msg.value >= videoPriceForEth);
    if(msg.value > videoPriceForEth) {
        msg.sender.transfer(msg.value.sub(videoPriceForEth));    
    }
    myStructsOfVideos[msg.sender].videoIds.push(videoId);
  }
  
  // buy video for evot
  function buyVideoByEvot(uint256 videoId, uint256 amount) public {
    require(amount >= videoPriceForEvot);
    if (!ERC20(tokenEVOT).transferFrom(msg.sender, this, amount)) revert();
    myStructsOfVideos[msg.sender].videoIds.push(videoId);
  }
  
  function withdrawAll() onlyAdmin() public {
    msg.sender.transfer(address(this).balance);
  }
  
  // withdraw all token by admin
  function withdrawAllTokens(uint256 amount) onlyAdmin() public {
      if(!ERC20(tokenEVOT).transfer(msg.sender, amount)) revert();
  }
  
  function paidAcademyVideo(address user, uint256 videoId) onlyAdmin() public {
    myStructsOfVideos[user].videoIds.push(videoId);
  }

  function getCount(address _user) public constant returns(uint256 length) {
    return myStructsOfVideos[_user].videoIds.length;
  }

  function getVideoIdAtIndex(address _user, uint256 _index) public constant returns(bool) {
      uint256 j = 0;
      for (uint256 i = 0; i < myStructsOfVideos[_user].videoIds.length; i++) {
        if(myStructsOfVideos[_user].videoIds[i] == _index) {
            j++;
        }
      }
      
      if(j == 0) {
        return false;
      } else {
        return true;
      }
  }
  
  function getVideoIdByUser(address _user) public view returns(uint256[]) {
      return myStructsOfVideos[_user].videoIds;
  } 
  
}
