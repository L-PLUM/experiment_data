/**
 *Submitted for verification at Etherscan.io on 2019-02-21
*/

// File: contracts/ProviderRating.sol

pragma solidity ^0.4.24;

contract ProviderRating {

    constructor() public{

    }
    struct Provider {
        bytes32 name;
        string providerPostalAddress; // we use a string data type here because bytes32 can only fit 32 characters (addresses might be longer)
        bytes32 providerIdentificationNumber;
        bool isValue;
    }

    struct User {
        bytes32 surveyKey;
        bool isValue; //https://ethereum.stackexchange.com/questions/13021/how-can-you-figure-out-if-a-certain-key-exists-in-a-mapping-struct-defined-insi
    }

    struct Rating {
        User author;
        Provider provider;
        uint score;
        string comment; // we use a string data type here because bytes32 can onl fit 32 characters (comments might be longer)
        bool isValue;
    }

    mapping (bytes32 => Provider) providers; // we map the providers through their identification number
    mapping(bytes32 => User) users;
    mapping(bytes32 => Rating) ratings; // we map the ratings through a hash string that gets created out of the



    // the key for the users that voted is the survey key that they used
    bytes32[] public surveyKeys;
    bytes32[] ratingHashes;
    address[] public providerIdentificationNumbers;



        bytes input;

    function setInput(bytes enterBytes){
        input = enterBytes;
    }

    function getInput()
    returns (bytes)
    {
        return input;
    }




    function validRatingHash(bytes32 ratingHash) view public returns (bool) {
        // we assure that a rating hash does not exist yet
        for (uint i = 0; i < ratingHashes.length; i++) {
            if (ratingHashes[i] == ratingHash) {
                return false;
            }
        }
        return false;
    }

    function rateProvider(bytes32 _surveyKey, bytes32 hashOfProviderNameAndSurveyKey, bytes32 _providerName, string memory _providerPostalAddress, bytes32 _providerIdentificationNumber, uint _score, string memory _comment) public {
        // it is faster and costs less gas to compute the hash of of the providerName and the SurveyKey on the client and pass it to this function rather than to securely compute it here


        User memory userToUseForRating;
        // we check if the user that voted already exists in our storage
        if(users[_surveyKey].isValue){
            userToUseForRating = users[_surveyKey];
        }else{
        // we create a new user
            users[_surveyKey].surveyKey = _surveyKey;
            users[_surveyKey].isValue = true;
            userToUseForRating = users[_surveyKey];

        }
        Provider memory providerToUseForRating;
        // we check if the provider that got a review already exists in our storage
        if(providers[_providerIdentificationNumber].isValue){
            providerToUseForRating = providers[_providerIdentificationNumber];
        }else{
        // we create a new Provider
            providers[_providerIdentificationNumber].name = _providerName;
            providers[_providerIdentificationNumber].providerPostalAddress = _providerPostalAddress;
            providers[_providerIdentificationNumber].providerIdentificationNumber = _providerIdentificationNumber;
            providers[_providerIdentificationNumber].isValue = true;
            providerToUseForRating = providers[_providerIdentificationNumber];
        }
        if(ratings[hashOfProviderNameAndSurveyKey].isValue){
            revert(); // duplicate submission this should not be allowed
        }else{
            ratings[hashOfProviderNameAndSurveyKey].author = userToUseForRating;
            ratings[hashOfProviderNameAndSurveyKey].provider = providerToUseForRating;
            ratings[hashOfProviderNameAndSurveyKey].score = _score;
            ratings[hashOfProviderNameAndSurveyKey].comment = _comment;
            ratings[hashOfProviderNameAndSurveyKey].isValue = true;
            ratingHashes.push(hashOfProviderNameAndSurveyKey);
        }

    }
    function getRatingAuthorKeyForRatingHash(bytes32 ratingHash)  public view returns(bytes32){
        return ratings[ratingHash].author.surveyKey;

    }
    function getRatingProviderNameForRatingHash(bytes32 ratingHash) view public returns(bytes32){
        return ratings[ratingHash].provider.name;

    }
    function getRatingCommentForRatingHash(bytes32 ratingHash) view public returns (string memory){
        return ratings[ratingHash].comment;

    }

    function getRatingScoreForRatingHash(bytes32 ratingHash) view public returns(uint) {
        return ratings[ratingHash].score;
    }

    function getNumberOfRatingsSaved() view public returns(uint){
        return ratingHashes.length;
    }

    function getRatingHashAtIndex(uint index) view public returns(bytes32){
        return ratingHashes[index];
    }


}
