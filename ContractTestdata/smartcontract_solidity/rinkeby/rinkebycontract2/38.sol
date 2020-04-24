/**
 *Submitted for verification at Etherscan.io on 2019-08-12
*/

pragma solidity >=0.4.22 <0.6.0;

contract AssetContract{
	event MinEvent(string from, string to, string asset_code, uint256 amount, uint256 resut_account, uint256 cur_seq);
	event BurnOK(string from,string asset_code, uint256 amount, uint256 resut_account, uint256 cur_seq);
	event BurnError(string from, string to, string asset_code, uint256 amount, uint256 resut_account, uint256 cur_seq);
	event Transfer(string from, string to, string asset_code, uint256 amount, uint256 resut_account, uint256 cur_seq);

	string msg_sender_;
	
	//账户信息
	struct UserAccount{
		uint256 last_opt_seq;
		uint256 amount;
	}

	//通讯合约证据
	struct Proof{
		uint256 dis_type;
		uint256 seq;
		string asset_code;
		string from;
		string to;
		uint256 amount;
	}
	
	//操作记录
	struct OptRecord{
		string from;
		string to;
		uint256 amount;
		string proof_type;//mine,mine-back,burn,trans
		Proof proof; 
	}

	//四个存储列表
	mapping(string => uint256) m_opt_seq;	//资产标识 - 操作序号
	mapping(string => mapping(string => UserAccount)) m_accounts;	//资产标识 - 账号地址 - 账号信息
	mapping(string => mapping(string => uint256)) m_prev_seq;	//资产标识 - 地址+ "_prev_" + seq - 上一个序号
	mapping(string => mapping(uint256 => OptRecord)) m_records;//资产标识 - 序号 - 记录
	
	//字符串比较
	function compare(string memory _a, string memory _b) internal pure returns (int) {
        bytes memory a = bytes(_a);
        bytes memory b = bytes(_b);
        uint minLength = a.length;
        if (b.length < minLength) minLength = b.length;
        //@todo unroll the loop into increments of 32 and do full 32 byte comparisons
        for (uint i = 0; i < minLength; i ++)
            if (a[i] < b[i])
                return -1;
            else if (a[i] > b[i])
                return 1;
        if (a.length < b.length)
            return -1;
        else if (a.length > b.length)
            return 1;
        else
            return 0;
    }

	//判断是否相等
	function equal(string memory _a, string memory _b) internal pure returns (bool) {
        return compare(_a, _b) == 0;
    }

	//字符串连接
	function strConcat(string memory _a, string memory _b) internal pure returns (string memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        string memory ret = new string(_ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        uint i = 0;
        for (i = 0; i < _ba.length; i++)bret[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) bret[k++] = _bb[i];
        return string(ret);
   }  

	//字符串连接
   	function strConcat(string memory _a, string memory _b, string memory _c) internal pure returns (string memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
		bytes memory _bc = bytes(_c);
        string memory ret = new string(_ba.length + _bb.length + _bc.length);
        bytes memory bret = bytes(ret);
        uint k = 0;
        uint i = 0;
        for ( i = 0; i < _ba.length; i++)bret[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) bret[k++] = _bb[i];
		for (i = 0; i < _bc.length; i++) bret[k++] = _bc[i];
        return string(ret);
   }  

	//uint 转字符串
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }
    
	//字符串转地址
    function parseAddr(string memory _a) internal pure returns (address _parsedAddress) {
        bytes memory tmp = bytes(_a);
        uint160 iaddr = 0;
        uint160 b1;
        uint160 b2;
        for (uint i = 2; i < 2 + 2 * 20; i += 2) {
            iaddr *= 256;
            b1 = uint160(uint8(tmp[i]));
            b2 = uint160(uint8(tmp[i + 1]));
            if ((b1 >= 97) && (b1 <= 102)) {
                b1 -= 87;
            } else if ((b1 >= 65) && (b1 <= 70)) {
                b1 -= 55;
            } else if ((b1 >= 48) && (b1 <= 57)) {
                b1 -= 48;
            }
            if ((b2 >= 97) && (b2 <= 102)) {
                b2 -= 87;
            } else if ((b2 >= 65) && (b2 <= 70)) {
                b2 -= 55;
            } else if ((b2 >= 48) && (b2 <= 57)) {
                b2 -= 48;
            }
            iaddr += (b1 * 16 + b2);
        }
        return address(iaddr);
    }

	//字符串转int
    function parseInt(string memory _a) internal pure returns (uint _parsedInt) {
        return parseInt(_a, 0);
    }

	//字符串转int
    function parseInt(string memory _a, uint _b) internal pure returns (uint _parsedInt) {
        bytes memory bresult = bytes(_a);
        uint mint = 0;
        bool decimals = false;
        for (uint i = 0; i < bresult.length; i++) {
            if ((uint(uint8(bresult[i])) >= 48) && (uint(uint8(bresult[i])) <= 57)) {
                if (decimals) {
                   if (_b == 0) {
                       break;
                   } else {
                       _b--;
                   }
                }
                mint *= 10;
                mint += uint(uint8(bresult[i])) - 48;
            } else if (uint(uint8(bresult[i])) == 46) {
                decimals = true;
            }
        }
        if (_b > 0) {
            mint *= 10 ** _b;
        }
        return mint;
    }
	//地址转字符串
	function addressToString(address _address) internal pure returns(string memory) {
        bytes32 _bytes = bytes32(uint256(_address));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _string = new bytes(42);
        _string[0] = '0';
        _string[1] = 'x';
        for(uint i = 0; i < 20; i++) {
            _string[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _string[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }
        return string(_string);
    }

	//账号的 prev 序号 key 值
	function makeUserPrevKey(string memory addr, string memory cur_seq) internal pure returns (string memory){
		return strConcat(addr, '_prev_', cur_seq);
	}
	
	//挖矿资产
	function minAsset(Proof memory proof) internal{
		//1、t_asset地址必须一样，4资产类型为；2、必须为通讯合约触发
		//assert(proposal.proposals[0].data.t_asset_addr == thisAddress, 'Failed to check t_asset_addr.');
		//assert(proposal.proposals[0].data.type == 1, 'Failed to check type.');
		string memory from = addressToString(msg.sender);
		
		//获取当前序号，并加一
		uint256 cur_seq = m_opt_seq[proof.asset_code];
		cur_seq += 1;
	
		//获取挖矿者账号信息
		UserAccount memory from_account = m_accounts[proof.asset_code][from];
		
		//存储挖矿者上一个序号
		m_prev_seq[proof.asset_code][makeUserPrevKey(from, uint2str(cur_seq))] = from_account.last_opt_seq;
		
		//保存挖矿者账号信息
		from_account.last_opt_seq = cur_seq;
		m_accounts[proof.asset_code][from] = from_account;
		
		//查保存接受者的余额
		string memory to = proof.to;
		uint256 amount = proof.amount;
		UserAccount memory to_account = m_accounts[proof.asset_code][to];
		to_account.amount = amount + to_account.amount;
		m_accounts[proof.asset_code][to] = to_account;
		
		//保存操作记录
		OptRecord memory record;
		record.from = from;
		record.to = to;
		record.amount = amount;
		record.proof_type = "mine";
		record.proof = proof;
		m_records[proof.asset_code][cur_seq] = record;
		
		//保存最大序号，更新资产列表
		m_opt_seq[proof.asset_code] = cur_seq;
		
		emit MinEvent(from, to, proof.asset_code, amount, to_account.amount, cur_seq);
	}
	
	//销毁资产成功，需要销毁
	function burnOK(Proof memory proof) internal{
		//1、t_asset地址必须一样，4资产类型为；2、必须为通讯合约触发
		//assert(proposal.proposals[0].data.t_asset_addr == thisAddress, 'Failed to check t_asset_addr.');
		//assert(proposal.proposals[0].data.type == 1, 'Failed to check type.');
	
		//断言资产必须存在
		require(m_opt_seq[proof.asset_code] != 0x0f);
		
		//获取发送，获取销毁金额
		uint256 amount = proof.amount;
		string memory from = addressToString(msg.sender);
		
		//获取当前序号，并加一
		uint256 cur_seq = m_opt_seq[proof.asset_code];
		cur_seq += 1;
		
		//查询销毁者信息
		UserAccount memory from_account = m_accounts[proof.asset_code][from];
		
		//存储用户上一个序号
		m_prev_seq[proof.asset_code][makeUserPrevKey(from, uint2str(cur_seq))] = from_account.last_opt_seq;
		
		//保存销毁者账号
		from_account.last_opt_seq = cur_seq;
		from_account.amount = from_account.amount - amount;
		m_accounts[proof.asset_code][from] = from_account;
		
		//保存操作记录
		OptRecord memory record;
		record.from = from;
		record.to = "";
		record.amount = amount;
		record.proof_type = "brun";
		record.proof = proof;
		m_records[proof.asset_code][cur_seq] = record;
		
		//保存最大操作序号
		m_opt_seq[proof.asset_code] = cur_seq;
		emit BurnOK(from, proof.asset_code, amount, from_account.amount, cur_seq);
	}
	
	//兑回资产失败，产生一笔转账交易
	function burnError(Proof memory proof) internal{
		//1、t_asset地址必须一样，4资产类型为；2、必须为通讯合约触发
		//assert(proposal.proposals[0].data.t_asset_addr == thisAddress, 'Failed to check t_asset_addr.');
		//assert(proposal.proposals[0].data.type == 1, 'Failed to check type.');
		
		//断言资产必须存在
		require(m_opt_seq[proof.asset_code] != 0x0f);
		
		//获取原始发送失败者的地址，获取失败金额
		uint256 amount = proof.amount;
		string memory from = addressToString(msg.sender);
		string memory to = proof.to;
		
		//获取当前序号，并加一
		uint256 cur_seq = m_opt_seq[proof.asset_code];
		cur_seq += 1;
		
		//获取发送者信息
		UserAccount memory from_account = m_accounts[proof.asset_code][from];
		require(from_account.amount >= amount);
		
		//保存发送者上一个序号
		m_prev_seq[proof.asset_code][makeUserPrevKey(from, uint2str(cur_seq))] = from_account.last_opt_seq;
		
		//保存发送者账号
		from_account.last_opt_seq = cur_seq;
		from_account.amount = from_account.amount - amount;
		m_accounts[proof.asset_code][from] = from_account;
		
		//查保存接受者的余额
		UserAccount memory to_account = m_accounts[proof.asset_code][proof.to];
		to_account.last_opt_seq = cur_seq;
		to_account.amount = amount + to_account.amount;
		m_accounts[proof.asset_code][to] = to_account;
		
		//保存完整的交易序号
		OptRecord memory record;
		record.from = from;
		record.to = to;
		record.amount = amount;
		record.proof_type = "brun-back";
		record.proof = proof;
		m_records[proof.asset_code][cur_seq] = record;
		
		//保存最大序号
		m_opt_seq[proof.asset_code] = cur_seq;
		
		emit BurnError(from, to, proof.asset_code, amount, to_account.amount, cur_seq);
	}

	function dispatchCrossMsg(uint256 dis_type, uint256 seq, string memory asset_code, string memory from, string memory to, uint256 amount) public 
	{
		//校验数据合法性: 必须为通讯合约。
		Proof memory proof;
		proof.dis_type = dis_type;
		proof.seq = seq;
		proof.asset_code = asset_code;
		proof.from = from;
		proof.to = to;
		proof.amount = amount;
		
		if(dis_type == 1){
			minAsset(proof);
		}
		else if(dis_type == 2){
			burnOK(proof);
		}
		else if(dis_type == 3){
			burnError(proof);
		}
		else{
			require(false);
		}
	}
	
	//转移资产
	function transfer(string memory to, uint256 value, string memory asset_code) public 
	{
		uint256 amount = value;
		//断言地址合法
		//断言value合法
		//断言资产存在
		require(m_opt_seq[asset_code] != 0);
		string memory from = addressToString(msg.sender); 
		if(equal(from, to)){
			return;
		}
		//获取当前序号，并加一
		uint256 cur_seq = m_opt_seq[asset_code];
		cur_seq += 1;

		//查询发送用户，保存用户操作序号
		UserAccount memory from_account = m_accounts[asset_code][from];
		m_prev_seq[asset_code][makeUserPrevKey(from, uint2str(cur_seq))] = from_account.last_opt_seq;
		require(from_account.amount >= amount);
		
		//保存发送账号
		from_account.last_opt_seq = cur_seq;
		from_account.amount = from_account.amount - amount;
		m_accounts[asset_code][from] = from_account;
		
		//查保存接受者的余额
		UserAccount memory to_account = m_accounts[asset_code][to];
		to_account.amount = amount + to_account.amount;
		m_accounts[asset_code][to] = to_account;
		
		//保存完整的交易序号
		OptRecord memory record;
		record.from = from;
		record.to = to;
		record.amount = amount;
		record.proof_type = "normal";
		m_records[asset_code][cur_seq] = record;
		
		//保存最大序号
		m_opt_seq[asset_code] = cur_seq;
		
		emit Transfer(from, to, asset_code, amount, to_account.amount, cur_seq);
	}
	
	function balanceOf(string memory acc, string memory asset_code) public view returns (uint256 amount, uint256 opt_seq) {
		UserAccount memory account = m_accounts[asset_code][acc];
		amount = account.amount;
		opt_seq = account.last_opt_seq;
	}
	
	function getTargetSeq(string memory acc, uint256 cur_seq, uint256 target_seq, string memory asset_code) private view returns (uint256){
		uint256 pre_seq = m_prev_seq[asset_code][makeUserPrevKey(acc, uint2str(cur_seq))];
		/*
		if(pre_seq === false){
			return 0;
		}
		*/
	
		if(cur_seq == target_seq){
			return 0;
		}
		
		if(pre_seq == 0){
			return cur_seq;
		}

		if(pre_seq < target_seq){
			return 0;
		}
		
		if(pre_seq == target_seq){
			return cur_seq;
		}
		
		return getTargetSeq(acc, pre_seq, target_seq, asset_code);
	}

	function queryCrossTransferLastest(uint256 target_seq, string memory acc, string memory asset_code) public view returns (string memory from, string memory to, uint256 amount, uint256 seq) {
		UserAccount memory acc_account = m_accounts[asset_code][acc];
		seq = getTargetSeq(acc, acc_account.last_opt_seq, target_seq, asset_code);
		if(seq == 0){
			return ("", "", 0, 0);
		}
		
		from = m_records[asset_code][seq].from;
		to = m_records[asset_code][seq].to;
		amount = m_records[asset_code][seq].amount;
	}
	
	function getAssetOptSeq(string memory asset_code) public view returns(uint256 seq){
		return m_opt_seq[asset_code];
	}
	
	function getRecord(string memory asset_code, uint256 target_seq) public view returns(string memory from, string memory to, uint256 amount, string memory proof_type){
		OptRecord memory opt = m_records[asset_code][target_seq];
		from = opt.from;
		to = opt.to;
		amount = opt.amount;
		proof_type = opt.proof_type;
	}
}
