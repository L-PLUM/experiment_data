/**
 *Submitted for verification at Etherscan.io on 2019-02-10
*/

pragma solidity ^0.5.0;

// File: /home/waseem/Documents/Waseem/FinalProjectPOE/contracts/DateTime.sol

// Note: This library was copied from https://github.com/pipermerriam/ethereum-datetime/blob/master/contracts/DateTime.sol

library DateTime {
        /*
         *  Date and Time utilities for ethereum contracts
         *
         */
        struct _DateTime {
                uint16 year;
                uint8 month;
                uint8 day;
                uint8 hour;
                uint8 minute;
                uint8 second;
                uint8 weekday;
        }

        uint constant DAY_IN_SECONDS = 86400;
        uint constant YEAR_IN_SECONDS = 31536000;
        uint constant LEAP_YEAR_IN_SECONDS = 31622400;

        uint constant HOUR_IN_SECONDS = 3600;
        uint constant MINUTE_IN_SECONDS = 60;

        uint16 constant ORIGIN_YEAR = 1970;

        function isLeapYear(uint16 year) public pure returns (bool) {
                if (year % 4 != 0) {
                        return false;
                }
                if (year % 100 != 0) {
                        return true;
                }
                if (year % 400 != 0) {
                        return false;
                }
                return true;
        }

        function leapYearsBefore(uint year) public pure returns (uint) {
                year -= 1;
                return year / 4 - year / 100 + year / 400;
        }

        function getDaysInMonth(uint8 month, uint16 year) public pure returns (uint8) {
                if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
                        return 31;
                }
                else if (month == 4 || month == 6 || month == 9 || month == 11) {
                        return 30;
                }
                else if (isLeapYear(year)) {
                        return 29;
                }
                else {
                        return 28;
                }
        }

        function parseTimestamp(uint timestamp) internal pure returns (_DateTime memory self) {
                uint secondsAccountedFor = 0;
                uint buf;
                uint8 i;

                // Year
                self.year = getYear(timestamp);
                buf = leapYearsBefore(self.year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;
                secondsAccountedFor += YEAR_IN_SECONDS * (self.year - ORIGIN_YEAR - buf);

                // Month
                uint secondsInMonth;
                for (i = 1; i <= 12; i++) {
                        secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, self.year);
                        if (secondsInMonth + secondsAccountedFor > timestamp) {
                                self.month = i;
                                break;
                        }
                        secondsAccountedFor += secondsInMonth;
                }

                // Day
                for (i = 1; i <= getDaysInMonth(self.month, self.year); i++) {
                        if (DAY_IN_SECONDS + secondsAccountedFor > timestamp) {
                                self.day = i;
                                break;
                        }
                        secondsAccountedFor += DAY_IN_SECONDS;
                }

                // Hour
                self.hour = getHour(timestamp);

                // Minute
                self.minute = getMinute(timestamp);

                // Second
                self.second = getSecond(timestamp);

                // Day of week.
                self.weekday = getWeekday(timestamp);
        }

        function getYear(uint timestamp) public pure returns (uint16) {
                uint secondsAccountedFor = 0;
                uint16 year;
                uint numLeapYears;

                // Year
                year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);
                numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);

                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;
                secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);

                while (secondsAccountedFor > timestamp) {
                        if (isLeapYear(uint16(year - 1))) {
                                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                secondsAccountedFor -= YEAR_IN_SECONDS;
                        }
                        year -= 1;
                }
                return year;
        }

        function getMonth(uint timestamp) public pure returns (uint8) {
                return parseTimestamp(timestamp).month;
        }

        function getDay(uint timestamp) public pure returns (uint8) {
                return parseTimestamp(timestamp).day;
        }

        function getHour(uint timestamp) public pure returns (uint8) {
                return uint8((timestamp / 60 / 60) % 24);
        }

        function getMinute(uint timestamp) public pure returns (uint8) {
                return uint8((timestamp / 60) % 60);
        }

        function getSecond(uint timestamp) public pure returns (uint8) {
                return uint8(timestamp % 60);
        }

        function getWeekday(uint timestamp) public pure returns (uint8) {
                return uint8((timestamp / DAY_IN_SECONDS + 4) % 7);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day) public pure returns (uint timestamp) {
                return toTimestamp(year, month, day, 0, 0, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour) public pure returns (uint timestamp) {
                return toTimestamp(year, month, day, hour, 0, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute) public pure returns (uint timestamp) {
                return toTimestamp(year, month, day, hour, minute, 0);
        }

        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) public pure returns (uint timestamp) {
                uint16 i;

                // Year
                for (i = ORIGIN_YEAR; i < year; i++) {
                        if (isLeapYear(i)) {
                                timestamp += LEAP_YEAR_IN_SECONDS;
                        }
                        else {
                                timestamp += YEAR_IN_SECONDS;
                        }
                }

                // Month
                uint8[12] memory monthDayCounts;
                monthDayCounts[0] = 31;
                if (isLeapYear(year)) {
                        monthDayCounts[1] = 29;
                }
                else {
                        monthDayCounts[1] = 28;
                }
                monthDayCounts[2] = 31;
                monthDayCounts[3] = 30;
                monthDayCounts[4] = 31;
                monthDayCounts[5] = 30;
                monthDayCounts[6] = 31;
                monthDayCounts[7] = 31;
                monthDayCounts[8] = 30;
                monthDayCounts[9] = 31;
                monthDayCounts[10] = 30;
                monthDayCounts[11] = 31;

                for (i = 1; i < month; i++) {
                        timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];
                }

                // Day
                timestamp += DAY_IN_SECONDS * (day - 1);

                // Hour
                timestamp += HOUR_IN_SECONDS * (hour);

                // Minute
                timestamp += MINUTE_IN_SECONDS * (minute);

                // Second
                timestamp += second;

                return timestamp;
        }
}

// File: contracts/ProofOfExistence.sol

contract ProofOfExistence  {

  struct Picture{
    bytes32 fileHash; 
    string fileName;
    address fileOwner;
    uint year;
    uint month;
    uint day;
    uint hour;
    uint minute;
    uint second;	
  }
 
  uint256 public pictureCount;

  mapping(uint256 => Picture) public pictures;

  address[] public owners; // used to store the owners in the array location of their picture hashes.

  bytes32[] public pictureHashes; // used for returning set of owners' pictures

  uint public x;
 
  DateTime._DateTime private dateTimeStruct;
  string public concatDateString;

  bool isStopped = false;
  address contractOwner;

  /* Constructor     
  */ 

  constructor() public {
      pictureCount = 0;
      contractOwner = msg.sender;	
  }

 
  // This public function is called to upload a "picture" (hash string) to the blockchain
  /* @param fileHash - this is the hash of the file stored in IPFS, or a normal text string for now.
     @param fileName - name of the file to be stored
     @returns pictureId - Id of pic stored 
  */ 

  function submitPicture(string memory fileHash, string memory fileName)
    validNewPicSubmission(fileHash)
    public returns (uint256 pictureId){
		
	require(!emptyString(fileName));
	require(!isStopped);
      
	bytes32 fileHashBytes32 = keccak256(abi.encodePacked(fileHash));            	
	
      pictureId = addPicture(fileHashBytes32, fileName);
      //owners[pictureId] = msg.sender;
      owners.push(msg.sender);

  }

  // Modifier that validates that this picture has not already been stored. Must be new.
  /* @param fileHash - this is the hash of the file stored in IPFS, or a normal text string for now.     
  */ 

  modifier validNewPicSubmission(string memory fileHash) {

    // First check for empty string.
    if (emptyString(fileHash)) {
	revert(); //throw exception and return ether to caller. 
    }

    // Get the hash.
    bytes32 fileHashBytes32 = keccak256(abi.encodePacked(fileHash));

    // Loop through the existing hashes to see if it's already there.
    for (uint i = 0; i < pictureCount; i++) {
        if (fileHashBytes32 == pictures[i].fileHash) {
	  revert(); //throw exception and return ether to caller. 	
	}
    }
    _; // continue with code of calling function
	
  }

  /* This internal function is the one that actually creates the entry on the blockchain
     It can only be called by submitPicture().
     @param fileHash - this is the hash of the file stored in IPFS, or a normal text string for now.
     @param fileName - name of the file to be stored
     @returns pictureId - Id of pic stored 
  */ 

  function addPicture(bytes32 _fileHash, string memory _fileName)
    internal returns (uint256 pictureId) {

    require(!isStopped); // still check for emergency stop, just in case someone can illegally reach this method.

    // Get the current datetime to store with the picture. Calls the DateTime library. 
  
    uint _dateCreated = now;
    dateTimeStruct = DateTime.parseTimestamp(_dateCreated); 
    
    // Add the picture entry to the struct.

    pictureId = pictureCount;
    pictures[pictureId] =
      Picture({
          fileHash: 	_fileHash,
          fileName: 	_fileName,
	  fileOwner: 	msg.sender,
          year: 	dateTimeStruct.year,
	  month: 	dateTimeStruct.month,
	  day: 		dateTimeStruct.day,
	  hour: 	dateTimeStruct.hour,
	  minute: 	dateTimeStruct.minute,
	  second:	dateTimeStruct.second
	
        });

    pictureCount += 1;
  }

 
 /* Public function to find the hashes of the pictures belonging to the sender and return as byte32 array
    Not a transaction. Uses no ether.     
    @Returns = bytes32 array of hashes 
 */  
 
  function getPictureHashes() public view returns (bytes32[] memory) {

	require(!isStopped);

	// Count number of times the sender's address occurs in owners array. Same as number of pics stored for the account.
	uint counter = 0;
	for(uint i = 0; i < owners.length; i++){
	  if (owners[i] == msg.sender){
		counter++;
	  }
	}

	// create array for the picture hashes, using size of counter. Will send this to UI.
	
	bytes32[] memory pictureHashes = new bytes32[](counter);	

	uint arrayIndex = 0;

	for(uint i = 0; i < owners.length; i++){

	  if (owners[i] == msg.sender){ // find the positions of the owner's entries in owners array in storage.
	 
	      pictureHashes[arrayIndex] = pictures[i].fileHash; // use the position (i) to get hash from pictures struct
		      	
	      arrayIndex++;
	      		
	  }

	}

	return pictureHashes;	  
	
  }

 /* Public function to find the datetime stamp of the pictures belonging to the sender and return as byte32 array
    Not a transaction. Uses no ether.     
    @Returns = uint array with date values.
 */

 function getPictureDates() public view returns (uint[] memory) {

	require(!isStopped);

	// Count number of times this address occurs in owners array. Equals number of pics stored for the account.
	uint counter = 0;
	for(uint i = 0; i < owners.length; i++){
	  if (owners[i] == msg.sender){
		counter++;
	  }
	}	

	// create array of dateTime stamps, using size of counter. Will send this to UI.
	uint[] memory pictureDates = new uint[](counter * 6);	// multiple by 6. Place for Y, M, D, Hr, Min, Sec.

	uint arrayIndex = 0;
	
	for(uint i = 0; i < owners.length; i++){
          if (owners[i] == msg.sender){
            
              pictureDates[arrayIndex] = pictures[i].year;
	      arrayIndex++;  
	      pictureDates[arrayIndex] = pictures[i].month;
	      arrayIndex++;
	      pictureDates[arrayIndex] = pictures[i].day;
	      arrayIndex++;
	      pictureDates[arrayIndex] = pictures[i].hour;
	      arrayIndex++;
	      pictureDates[arrayIndex] = pictures[i].minute;
	      arrayIndex++;
	      pictureDates[arrayIndex] = pictures[i].second;	
	      
	      arrayIndex++;
          }
        }

	return pictureDates;	  

  }

  
 /* Public function used to verify ownership of a picture hash
    Not a transaction. Uses no ether.
    @param - address of alleged owner
    @param - file hash
    @Returns - uint value for true or false. Boolean was giving errors for some reason.
 */

  function verifyOwnership(address _allegedOwner, string memory _fileHash) 
    public view returns(uint) {

    // validations
    require(!isStopped);
    require(!emptyString(_fileHash));
  
    bytes32 fileHashBytes32 = keccak256(abi.encodePacked(_fileHash));
    
    uint returnValue = 0; // initialise to zero which means "false" or no match.
	
    // go through all the entries and check if a hash and owner match is found.
    for(uint i = 0; i < pictureCount; i++) {

      if (pictures[i].fileHash == fileHashBytes32) {
	
        if (pictures[i].fileOwner == _allegedOwner) {          
          returnValue = 1; // set to one meaning "true" a match has been found.
        }
        
      }

    }
    return returnValue;

  }

  /* Utility validation function for checking empty input strings
     @param - input string to validate
     @return - true or false
  */

  function emptyString(string memory inputString) internal pure returns (bool) {
    bytes memory tempEmptyStringTest = bytes(inputString);
	if (tempEmptyStringTest.length == 0) {
	   return true;	
	}
	return false;
  }
 

  /* Emergency stop function.
     Can only be called by the contract owner.
  */

  function stopContract() public {
    require(contractOwner == msg.sender);
    isStopped = true;
  }		



}
