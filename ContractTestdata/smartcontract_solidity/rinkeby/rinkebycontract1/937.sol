/**
 *Submitted for verification at Etherscan.io on 2019-02-03
*/

pragma solidity ^0.4.25;

contract ERC20 {
    
    //Ownership portion
    address public owner = msg.sender;
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function getOwner() public view returns (address) {
        return owner;
    }
    
    function setOwner(address _newOwner) public onlyOwner {
        owner = _newOwner;
    }
    
    //Token portion
    
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
    
    uint public TotalSupply;
    
    function totalSupply() public constant returns (uint) {
        return TotalSupply;
    }
    
    mapping (address => uint) Balances;
    
    function balanceOf(address tokenOwner) public constant returns (uint balance) {
        return Balances[tokenOwner];
    }
    
    mapping (address => address) Approvals;
    mapping (address => uint) Allowances;
    
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {
        if(Approvals[tokenOwner] == spender) {
            return Allowances[tokenOwner];
        } else {
            return 0;
        }
    }
    
    function _transfer(address _from, address _to, uint amount) internal returns (bool) {
        if (balanceOf(_from) >= amount) {
            Balances[_from] -= amount;
            Balances[_to] += amount;
            emit Transfer(_from, _to, amount);
            return true;
        } else {
            return false;
        }
    }
    
    function transfer(address to, uint tokens) public returns (bool success) {
        return _transfer(msg.sender, to, tokens);
    }
    
    function approve(address spender, uint tokens) public returns (bool success) {
        require(msg.sender != spender);
        Approvals[msg.sender] = spender;
        Allowances[msg.sender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }
    
    function transferFrom(address from, address to, uint tokens) public {
        if(Approvals[from] == msg.sender || from == msg.sender || msg.sender == owner) {
            _transfer(from, to, tokens);
        } else {
            revert();
        }
    }
    
    function mint(address _target, uint _amount) external onlyOwner returns (bool) {
        Balances[_target] += _amount;
        TotalSupply += _amount;
        emit Transfer(address(this), _target, _amount);
        return true;
    }
    
    string public constant name = "EtherKin Currency";
    string public constant symbol = "EKC";
    uint8 public constant decimals = 0;
    
    //Do not accept Ether.
    function () public payable {
        revert();
    }
    
}

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

contract EtherKinCore is Ownable{
    
    ERC20 public CoinContract;
    
    uint public totalSupply;

	event NewEtherKin(uint kinID, string name, uint dna, uint32 promoType);
	event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);

	uint dnaDigits = 2;
    uint dnaModulus = 10 ** dnaDigits;
	uint cooldownTime = 1 days;

	struct EtherKin {
		string name;
		uint dna;
		uint32 level;
		uint32 readyTime;
		uint32 promoType;
	}

	EtherKin[] public EtherKins;

	mapping (uint => address) public etherKinToOwner;
	mapping (address => uint) ownerEtherKinCount;
	bool GenesisKinGenerated = false;

	function _createEtherKin(string _name, uint _dna, uint32 _promoType) internal {
		uint id = EtherKins.push(EtherKin(_name, _dna, 1, uint32(now + (1 days / 48)), _promoType)) - 1;
		etherKinToOwner[id] = msg.sender;
		ownerEtherKinCount[msg.sender]++;
		NewEtherKin(id, _name, _dna, _promoType);
		Transfer(address(0), address(msg.sender), id);
		totalSupply++;
		
	}

	function _generateRandomDna(string _str) internal view returns(uint) {
		uint rand = uint(keccak256(_str, now, msg.sender, EtherKins.length));
		return rand % dnaModulus;
	}

	function createRandomEtherKin(string _name) public {
		require(ownerEtherKinCount[msg.sender] == 0);
		uint randDna = _generateRandomDna(_name);
		if (msg.sender == owner && GenesisKinGenerated == false) {
		    _createEtherKin("Agtosú", 99, 1);
		    GenesisKinGenerated = true;
		} else {
		    _createEtherKin(_name, randDna, 0);
		}
	}
}

contract EtherKinNeoGenerator is EtherKinCore {
    
    uint newKinPrice = 15;
    
    mapping (address => address) EtherKinOperatorApprovals;

	modifier onlyOwnerOf(uint _kinId) {
	require(etherKinToOwner[_kinId] == msg.sender || EtherKinOperatorApprovals[etherKinToOwner[_kinId]] == msg.sender);
	_;
	}

	function _triggerCooldown(EtherKin storage _etherKin) internal {
		_etherKin.readyTime = uint32(now + cooldownTime);
	}

	function _isReady(EtherKin storage _etherKin) internal view returns(bool) {
		return (_etherKin.readyTime <= now);
	}

	function KinGenesis(uint _kinId, uint _targetDna) internal onlyOwnerOf(_kinId) {
		EtherKin storage myEtherKin = EtherKins[_kinId];
		require(_isReady(myEtherKin));
		_targetDna = _targetDna % dnaModulus;
		uint newDna = (myEtherKin.dna + _targetDna) / 2;
		_createEtherKin("Ganainm", newDna, 2);
		_triggerCooldown(myEtherKin);
	}
	
	function issuePromoKin(string _name, uint _dna, uint32 _promoType) public {
	    require(address(msg.sender) == address(etherKinToOwner[0]) || address(msg.sender) == address(owner));
	    _createEtherKin(_name, _dna, _promoType);
	}
	
	function buyNewKin(string _name) external returns (bool) {
	    require(CoinContract.balanceOf(address(msg.sender)) >= newKinPrice);
	    CoinContract.transferFrom(msg.sender, address(this), newKinPrice);
	    uint _newDna = _generateRandomDna(_name);
	    _createEtherKin(_name, _newDna, 2);
	}
	
	function setNewKinPrice(uint _newPrice) external onlyOwner {
	    newKinPrice = _newPrice;
	}
}

contract EtherKinHelper is EtherKinNeoGenerator{

	uint cooldownFee = 5;

	modifier aboveLevel(uint _level, uint _kinId) {
		require(EtherKins[_kinId].level >= _level);
		_;
	}

	function withdraw() external onlyOwner {
	    CoinContract.transferFrom(address(this), address(msg.sender), CoinContract.balanceOf(address(this)));
	}

	function setCooldownFee(uint _fee) external onlyOwner {
		cooldownFee = _fee;
	}

	function quickCooldown(uint _kinId) external onlyOwnerOf(_kinId) {
		require(EtherKins[_kinId].readyTime > now);
		require(CoinContract.balanceOf(address(msg.sender)) >= cooldownFee);
		CoinContract.transferFrom(address(msg.sender), address(this), cooldownFee);
		EtherKins[_kinId].readyTime = uint32(now);
	}

	function changeName(uint _kinId, string _newName) external aboveLevel(2, _kinId) onlyOwnerOf(_kinId) {
		require(_kinId != 0);
		EtherKins[_kinId].name = _newName;
	}

	function getEtherKindredByOwner(address _owner) external view returns(uint[]) {
		uint[] memory result = new uint[](ownerEtherKinCount[_owner]);
		uint counter = 0;
		for (uint i = 0; i < EtherKins.length; i++) {
			if (etherKinToOwner[i] == _owner) {
				result[counter] = i;
				counter++;
			}
		}
		return result;
	}

}

contract EtherKinContest is EtherKinHelper {
    
    mapping (uint256 => address) EtherKinDeployedBy;

	uint randNonce = 0;
	uint contestVictoryProbability = 50;

	function randMod(uint _modulus) internal returns(uint) {
		randNonce++;
		return uint(keccak256(abi.encodePacked(now, msg.sender, randNonce))) % _modulus;
	}

	function contest(uint _kinId, uint _targetId) external onlyOwnerOf(_kinId) {
	    require(EtherKinDeployedBy[_kinId] == address(0) && EtherKinDeployedBy[_targetId] != address(0) && EtherKinDeployedBy[_targetId] != address(msg.sender));
		EtherKin storage myEtherKin = EtherKins[_kinId];
		EtherKin storage rivalEtherKin = EtherKins[_targetId];
		require (now >= myEtherKin.readyTime);
		uint rand = randMod(100);
		uint modifiedChances;
		if (myEtherKin.level == rivalEtherKin.level) {
			modifiedChances = contestVictoryProbability;
		}
		if (myEtherKin.level > rivalEtherKin.level) {
			modifiedChances = contestVictoryProbability + 10;
		}
		if (myEtherKin.level < rivalEtherKin.level) {
			modifiedChances = contestVictoryProbability - 10;
		}
		if (myEtherKin.promoType == 2) {
		    modifiedChances += 15;
		}
		if (rivalEtherKin.promoType == 2) {
		    modifiedChances -= 15;
		}
		if (myEtherKin.promoType >= 3) {
		    modifiedChances += 25;
		}
		if (rivalEtherKin.promoType >= 3) {
		    modifiedChances -= 25;
		}
		if (myEtherKin.promoType == 1) {
		    modifiedChances = 100;
		}
		if (rivalEtherKin.promoType == 1) {
		    modifiedChances = 0;
		}
		if (rand <= modifiedChances) {
			myEtherKin.level += 2;
			rivalEtherKin.level++;
			KinGenesis(_kinId, rivalEtherKin.dna);
			CoinContract.mint(msg.sender, 2);
			CoinContract.mint(EtherKinDeployedBy[_targetId], 1);
		} else {
			rivalEtherKin.level +=2;
			myEtherKin.level++;
			CoinContract.mint(msg.sender, 1);
			CoinContract.mint(EtherKinDeployedBy[_targetId], 2);
		}

	}
}
    contract ERC721 {
        event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
        event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

        function balanceOf(address _owner) public view returns (uint256 _balance);
        function ownerOf(uint256 _tokenId) public view returns (address _owner);
        function transfer(address _to, uint256 _tokenId) public;
        function approve(address _to, uint256 _tokenId) public;
        function takeOwnership(uint256 _tokenId) public;
}

         
contract EtherKinOwnerShip is EtherKinContest, ERC721 {
    
	mapping (uint => address) EtherKinApprovals;
	
	function setApprovalForAll(address _operator, bool _approved) external {
	    if(_approved == true) {
	        EtherKinOperatorApprovals[msg.sender] = _operator;
	        emit ApprovalForAll(msg.sender, _operator, _approved);
	    } else {
	        EtherKinOperatorApprovals[msg.sender] = msg.sender;
	        emit ApprovalForAll(msg.sender, _operator, _approved);
	    }
	}

	function balanceOf(address _owner) public view returns (uint256 _balance) {
		return ownerEtherKinCount[_owner];
	}

	function ownerOf(uint256 _tokenId) public view returns(address) {
		return etherKinToOwner[_tokenId];
	}

	function _transfer(address _from, address _to, uint256 _tokenId) internal {
		ownerEtherKinCount[_to]++;
		ownerEtherKinCount[_from]--;
		etherKinToOwner[_tokenId] = _to;
		emit Transfer(_from, _to, _tokenId);
	}

	function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
	    require(EtherKinDeployedBy[_tokenId] == address(0));
		_transfer(msg.sender, _to, _tokenId);
	}

	function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
	    require(EtherKinDeployedBy[_tokenId] == address(0));
		EtherKinApprovals[_tokenId] = _to;
		emit Approval(msg.sender, _to, _tokenId);
	}

	function takeOwnership(uint256 _tokenId) public {
	    require(EtherKinDeployedBy[_tokenId] == address(0));
		require(EtherKinApprovals[_tokenId] == msg.sender);
		_transfer(ownerOf(_tokenId), msg.sender, _tokenId);
	}

    function whoDeployed(uint256 _tokenId) public view returns(address) {
        return EtherKinDeployedBy[_tokenId];
    }

    function deployEtherKin(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
        require(_isReady(EtherKins[_tokenId]));
        EtherKinDeployedBy[_tokenId] = address(msg.sender);
        _triggerCooldown(EtherKins[_tokenId]);
        _transfer(msg.sender, _to, _tokenId);
    }
    
    function recallEtherKin(uint256 _tokenId) public {
        require(EtherKinDeployedBy[_tokenId] == address(msg.sender) && _isReady(EtherKins[_tokenId]));
        _transfer(etherKinToOwner[_tokenId], msg.sender, _tokenId);
        _triggerCooldown(EtherKins[_tokenId]);
        EtherKinDeployedBy[_tokenId] = address(0);
    }
    
    mapping (uint => string) FreeURIs;
    mapping (uint => string) PremiumURIs;
    mapping (uint => string) PromoURIs;
    
    function setClassURI(uint PromoType, uint DNASector, string URI) onlyOwner {
        require(DNASector <= 20 && DNASector >= 0);
        if(PromoType == 0) { //Free Kins
            require(DNASector > 0);
            FreeURIs[DNASector] = URI;
        }
        if(PromoType == 1) { //Premium Kins
            require(DNASector > 0);
            PremiumURIs[DNASector] = URI;
        }
        if(PromoType == 2) { //Promo Kins
            PromoURIs[DNASector] = URI;
        }
    }
}

contract EtherKin is EtherKinOwnerShip {
    
    constructor() public {
        setClassURI(2, 1, "https://api.myjson.com/bins/15e7sw");
        createRandomEtherKin("");
    }
    
    function createCoinContract() public onlyOwner returns (address) {
        require(address(CoinContract) == address(0));
        CoinContract = new ERC20();
        CoinContract.mint(address(msg.sender), newKinPrice);
        return address(CoinContract);
    }
    
    string public name = "EtherKin";
    string public symbol = "EKIN";
    uint8 public decimals = 0;

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    
    function tokenURI(uint256 _tokenId) external view returns (string) {
        require(EtherKins[_tokenId].level > 0);
        if(EtherKins[_tokenId].promoType == 0) { //Free kins
            if(EtherKins[_tokenId].dna >= 0 && EtherKins[_tokenId].dna <= 24) {
                return FreeURIs[1];
            }
            if(EtherKins[_tokenId].dna >= 25 && EtherKins[_tokenId].dna <= 49) {
                return FreeURIs[2];
            }
            if(EtherKins[_tokenId].dna >= 50 && EtherKins[_tokenId].dna <= 74) {
                return FreeURIs[3];
            }
            if(EtherKins[_tokenId].dna >= 75 && EtherKins[_tokenId].dna <= 99) {
                return FreeURIs[4];
            }
        }
        if(EtherKins[_tokenId].promoType == 2) { //Premium kins
            if(EtherKins[_tokenId].dna >= 0 && EtherKins[_tokenId].dna <= 24) {
                return PremiumURIs[1];
            }
            if(EtherKins[_tokenId].dna >= 25 && EtherKins[_tokenId].dna <= 49) {
                return PremiumURIs[2];
            }
            if(EtherKins[_tokenId].dna >= 50 && EtherKins[_tokenId].dna <= 74) {
                return PremiumURIs[3];
            }
            if(EtherKins[_tokenId].dna >= 75 && EtherKins[_tokenId].dna <= 99) {
                return PremiumURIs[4];
            }
        }
        if(EtherKins[_tokenId].promoType >= 3 || EtherKins[_tokenId].promoType == 1) { //Promo kins
            return PromoURIs[EtherKins[_tokenId].promoType];
        }
    }
    
    function transferFrom(address from, address to, uint tokens) public {
        if((EtherKinApprovals[tokens] == msg.sender || msg.sender == etherKinToOwner[tokens] || msg.sender == owner) && EtherKinDeployedBy[tokens] == address(0)) {
            return _transfer(from, to, tokens);
        } else {
            revert();
        }
    }
    
    //Do not accept Ether
    function () public payable {
        revert();
    }
}
