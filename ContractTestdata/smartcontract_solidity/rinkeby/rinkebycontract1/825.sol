/**
 *Submitted for verification at Etherscan.io on 2019-02-07
*/

pragma solidity ^0.4.25;


contract AxieCore {
  mapping(uint => uint) genes;
  mapping(uint => address) ownersById;
  constructor() public{
    genes[13073]=25343654298568491884339705557113035049976025925777944642078126509067728134408;
    ownersById[13073]=0xca35b7d915458ef540ade6068dfe2f44e8fa733c;
    genes[15863]=4070815637473448366593882792556458090978466895814431788420707853451147937798;
    ownersById[15863]=0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
    genes[26750]=42517407767258217557098465644318251969518079288363379581471642359734544118088;
    ownersById[26750]=0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db;
    genes[20753]=41612782070521370578804587547693777278528706867745784149855385369421543712836;
    ownersById[20753]=0x583031d1113ad414f02576bd6afabfb302140225;

    genes[5]=3166631652923858538795601598543498775743221737576118365001352595973550901574;
    genes[6]=32114653961709840768608836959719865520403130100794028473517228501822987309122;
  }
  function getAxie(
    uint256 _axieId
  )
    external
    view
    returns (uint256 /* _genes */, uint256 /* _bornAt */)
  {
    return (genes[_axieId], 0);
  }
  function ownerOf(uint256 _tokenId) view returns(address)
  {
    return ownersById[_tokenId];
  }
  function getAxie(uint id,uint gene) public{
    ownersById[id]=msg.sender;
    genes[id]=gene;
  }
}
