/**
 *Submitted for verification at Etherscan.io on 2019-02-15
*/

pragma solidity ^0.5.0;

// File: contracts/Zippie/IZippieCardNonces.sol

/**
 * @title ZippieCardNonce interface
 * @dev check if nonce has been used or mark nonce as used
 */
interface IZippieCardNonces {
    function isNonceUsed(address signer, bytes32 nonce) 
        external returns (bool);

    function useNonce(address signer, bytes32 nonce, uint8 v, bytes32 r, bytes32 s) 
        external returns(bool);
}

// File: contracts/Zippie/ZippieUtils.sol

library ZippieUtils {

    /** 
      * @dev check if an address is in part of an array of addresses (using offset and count)
      */
    function isAddressInArray(
        address item, 
        uint8 offset, 
        uint8 length, 
        address[] memory items
    ) 
        internal 
        pure 
        returns(bool) 
    {
        require(
            items.length >= offset + length, 
            "Not enough number of items"
        );
        for (uint8 i = 0; i < length; i++) {
            if (items[offset+i] == item) {
                return true;
            }
        }
        return false;
    }

    /**
      * @dev prefix a bytes32 value with "\x19Ethereum Signed Message:"
      * and hash the result
      */
    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}

// File: contracts/Zippie/ZippieCard.sol

/**
  * @title Zippie Card
  * @dev Multi signature and nonce verification for smart cards (2FA) 
  * nonces are globally stored in it's own contract so they cannot 
  * be resused between different contracts using the same card
 */
contract ZippieCard {

    // address to shared card nonce data contract 
    // (for replay protection)
    address private _zippieCardNonces;

    /**
      * @dev Connect this contract to use the shared nonce data contract
      * @param zippieCardNonces address to shared card nonce data contract
      */
    constructor(address zippieCardNonces) public {
        _zippieCardNonces = zippieCardNonces;
    }

    /** 
      * @dev Verify that all provided card signatures are valid 
      * and nonces has not been used yet
      * @param cardNonces random values generated and signed by cards at every read
      * @param cardOffset offset values to cardAddresses array 
      * [0] offset index to first card address
      * [1] number of card addresses    
      * @param cardAddresses card addresses (starting from offset index)
      * @param signatureOffset offset values to signature arrays (v, r, s)
      * [0] offset index to first card signature
      * [1] number of card signatures   
      * @param v v values of card signatures (starting from offset index)
      * @param r r values of card signatures (starting from offset index)
      * @param s s values of card signatures (starting from offset index)
      */
    function verifyCardSignatures(
        bytes32[] memory cardNonces, 
        uint8[2] memory cardOffset, 
        address[] memory cardAddresses, 
        uint8[2] memory signatureOffset, 
        uint8[] memory v, 
        bytes32[] memory r, 
        bytes32[] memory s
    ) 
        internal 
        returns (bool)
    {
        require(
            cardNonces.length == cardOffset[1], 
            "Incorrect number of card nonces"
        ); 
        require(
            signatureOffset[1] <= cardOffset[1], 
            "Required number of card signatures cannot be higher than number of possible cards"
        );
        require(
            cardOffset[0] != 0xFF, 
            "Card offset cannot be MAX UINT8"
        );
        require(
            cardOffset[1] != 0xFF, 
            "Nr of cards cannot be MAX UINT8"
        );
        require(
            signatureOffset[0] != 0xFF, 
            "Signature offset cannot be MAX UINT8"
        );
        require(
            signatureOffset[1] != 0xFF, 
            "Nr of signatures cannot be MAX UINT8"
        );
        require(
            cardAddresses.length >= cardOffset[0] + cardOffset[1], 
            "Incorrect number of cardAddresses"
        ); 
        require(
            v.length >= signatureOffset[0] + signatureOffset[1], 
            "Incorrect number of signatures (v)"
        ); 
        require(
            r.length >= signatureOffset[0] + signatureOffset[1], 
            "Incorrect number of signatures (r)"
        ); 
        require(
            s.length >= signatureOffset[0] + signatureOffset[1], 
            "Incorrect number of signatures (s)"
        ); 

        // remember used card addresses to check for duplicates
        address[] memory usedCardAddresses = new address[](signatureOffset[1]);
       
        // recovered card address 
        address cardAddress;

        // check all card signatures
        for (uint8 i = 0; i < signatureOffset[1]; i++) {

            // recover card address
            cardAddress = ecrecover(
                cardNonces[i], 
                v[signatureOffset[0]+i], 
                r[signatureOffset[0]+i], 
                s[signatureOffset[0]+i]
            );

            // check that address is a valid card address
            require(
                ZippieUtils.isAddressInArray(
                    cardAddress, 
                    cardOffset[0], 
                    cardOffset[1], 
                    cardAddresses
                ), 
                "Invalid address found when verifying card signatures"
            );

            // check that this address is not a duplicate
            require(
                !ZippieUtils.isAddressInArray(
                    cardAddress, 
                    0, 
                    i, 
                    usedCardAddresses
                ), 
                "Card address has been used already"
            );

            // add this card address to the used list
            usedCardAddresses[i] = cardAddress;

            // flag card nonce as used in the card nonce contract,
            // revert if used already
            require(
                IZippieCardNonces(_zippieCardNonces).useNonce(
                    cardAddress,
                    cardNonces[i],
                    v[signatureOffset[0]+i],
                    r[signatureOffset[0]+i],
                    s[signatureOffset[0]+i]
                )
            );
        }
        return true;
    }
}

// File: contracts/Zippie/ZippieMultisig.sol

/**
  * @title Zippie Multisig
  * @dev Multi signature and nonce verification for multisig accounts 
  * it's enough if nonces are unique for a specific multisig contract
  * since a multsig account must always be created with a temp private key 
  * and will therefor only be useful in the contract that was used 
  * and sepcified during the setup of a new multisig account
 */
contract ZippieMultisig {

    // nonces for replay protection 
    mapping (address => mapping(address => bool)) public usedNonces;

    /** 
      * @dev Verify that a random nonce account (one time private key) 
      * signed an arbitrary hash and mark the nonce address 
      * as used for the specific multisig address
      * @param multisigAddress address of this multisig account
      * @param nonceAddress address of this nonce account
      * @param signedHash hash signed by nonce account
      * @param v v values of the nonce account signatures
      * @param r r values of the nonce account signatures
      * @param s s values of the nonce account signatures
      */
    function verifyMultisigNonce(
        address multisigAddress, 
        address nonceAddress, 
        bytes32 signedHash, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) 
        internal 
        returns (bool)
    {
        require(
            usedNonces[multisigAddress][nonceAddress] == false, 
            "Nonce already used"
        ); 
        require(
            nonceAddress == ecrecover(signedHash, v, r, s), 
            "Invalid nonce"
        );
        
        // flag nonce as used to prevent reuse
        usedNonces[multisigAddress][nonceAddress] = true; 
        return true;  
    }

    /** 
      * @dev Verify that the multisig account (temp private key)
      *  signed the array of possible signer addresses 
      *  and required number of signatures
      * @param signers all possible signers for this multsig account
      * @param m required number of signatures for this multisig account
      * @param multisigAddress address of this multisig account
      * @param v v values of the multisig account signatures
      * @param r r values of the multisig account signatures
      * @param s s values of the multisig account signatures
      */
    function verifyMultisigAccountSignature(
        address[] memory signers, 
        uint8[] memory m, 
        address multisigAddress, 
        uint8 v, 
        bytes32 r, 
        bytes32 s
    ) 
        internal 
        pure 
        returns (bool)
    {
        require(
            multisigAddress == ecrecover(
                ZippieUtils.toEthSignedMessageHash(
                    keccak256(abi.encodePacked(signers, m))
                ), 
                v, 
                r, 
                s
            ), 
            "Invalid account"
        );
        return true; 
    }

    /** 
      * @dev Verify that all provided signer signatures are valid
      * and that they all signed the same hash
      * @param signedHash hash signed by all signers
      * @param signerOffset offset values to signerAddresses array 
      * [0] offset index to first signer address
      * [1] number of signer addresses    
      * @param signerAddresses card addresses (starting from offset index)
      * @param signatureOffset offset values to signature arrays (v, r, s)
      * [0] offset index to first signer signature
      * [1] number of signer signatures   
      * @param v v values of card signatures (starting from offset index)
      * @param r r values of card signatures (starting from offset index)
      * @param s s values of card signatures (starting from offset index)
      */
    function verifyMultisigSignerSignatures(
        bytes32 signedHash, 
        uint8[2] memory signerOffset, 
        address[] memory signerAddresses, 
        uint8[2] memory signatureOffset, 
        uint8[] memory v, 
        bytes32[] memory r, 
        bytes32[] memory s
    ) 
        internal 
        pure 
        returns (bool)
    {     
        require(
            signatureOffset[1] <= signerOffset[1], 
            "Required number of signer signatures cannot be higher than number of possible signers"
        );
        require(
            signerOffset[0] != 0xFF, 
            "Signer offset cannot be MAX UINT8"
        );
        require(
            signerOffset[1] != 0xFF, 
            "Nr of signers cannot be MAX UINT8"
        );
        require(
            signatureOffset[0] != 0xFF,
            "Signature offset cannot be MAX UINT8"
        );
        require(
            signatureOffset[1] != 0xFF, 
            "Nr of signatures cannot be MAX UINT8"
        );
        require(
            signerAddresses.length >= signerOffset[0] + signerOffset[1], 
            "Incorrect number of signerAddresses"
        ); 
        require(
            v.length >= signatureOffset[0] + signatureOffset[1], 
            "Incorrect number of signatures (v)"
        ); 
        require(
            r.length >= signatureOffset[0] + signatureOffset[1], 
            "Incorrect number of signatures (r)"
        ); 
        require(
            s.length >= signatureOffset[0] + signatureOffset[1], 
            "Incorrect number of signatures (s)"
        ); 
        
        // remember used signer addresses to check for duplicates
        address[] memory usedSignerAddresses = new address[](signatureOffset[1]);

        // recovered signer address 
        address signerAddress;

        // check all signer signatures
        for (uint8 i = 0; i < signatureOffset[1]; i++) {

            // recover signer address
            signerAddress = ecrecover(
                signedHash, 
                v[signatureOffset[0]+i], 
                r[signatureOffset[0]+i], 
                s[signatureOffset[0]+i]
            );

            // check that address is a valid signer address 
            require(
                ZippieUtils.isAddressInArray(
                    signerAddress, 
                    signerOffset[0], 
                    signerOffset[1], 
                    signerAddresses
                ), 
                "Invalid address found when verifying signer signatures"
            );

            // check that this address is not a duplicate
            require(
                !ZippieUtils.isAddressInArray(
                    signerAddress, 
                    0, 
                    i, 
                    usedSignerAddresses
                ), 
                "Signer address has been used already"
            );

             // add this signer address to the used list
            usedSignerAddresses[i] = signerAddress;
        }
        return true; 
    }
}

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/Zippie/ZippieWallet.sol

/**
  * @title Zippie Multisig Wallet (with 2FA smart card)
  * @notice Transfer ERC20 tokens using multiple signatures
  * @dev Zippie smart cards can be used for 2FA
 */
contract ZippieWallet is ZippieMultisig, ZippieCard {

    mapping (address => uint256) public accountLimits;

    constructor(address zippieCardNonces) ZippieCard(zippieCardNonces) public {}
    
    /** @notice Redeems a check after verifying required signers/cards 
      * (recipient is specified when check is created) 
      * @dev Transfer ERC20 tokens when verified that 
      * enough signers has signed keccak256(recipient, amount, verification key)
      * card signatures are not required if amount doesn't exceeded the current limit
      * @param addresses required addresses
      * [0] multisig account to withdraw ERC20 tokens from
      * [1] ERC20 contract to use
      * [2] recipient of the ERC20 tokens
      * [3] verification key (nonce)
      * @param signers all possible signers and cards
      * [0..i] signer addresses
      * [i+1..j] card adresses
      * @param m the amount of signatures required for this multisig account
      * [0] possible number of signers
      * [1] required number of signers
      * [2] possible number of cards
      * [3] reqiuired number of cards
      * @param v v values of all signatures
      * [0] multisig account signature
      * [1] verification key signature
      * [2..i] signer signatures of check hash
      * [i+1..j] card signatures of random card nonces
      * @param r r values of all signatures (structured as v)
      * @param s s values of all signatures (structured as v)
      * @param amount amount to transfer
      * @param cardNonces random nonce values generated by cards at every read
      * @return true if transfer successful 
      */
    function redeemCheck(
        address[] memory addresses, 
        address[] memory signers, 
        uint8[] memory m, 
        uint8[] memory v, 
        bytes32[] memory r, 
        bytes32[] memory s, 
        uint256 amount, 
        bytes32[] memory cardNonces
    ) 
        public 
        returns (bool)
    {
        require(
            addresses.length == 4, 
            "Incorrect number of addresses"
        );
        require(
            amount > 0, 
            "Amount must be greater than 0"
        );

        // sanity check of signature parameters 
        bool limitExceeded = isLimitExceeded(amount, addresses[0]);
        checkSignatureParameters(
            m, 
            signers.length, 
            v.length, 
            r.length, 
            s.length, 
            cardNonces.length, 
            limitExceeded
        );
        
        // verify that account signature is valid
        verifyMultisigAccountSignature(
            signers, 
            m, 
            addresses[0], 
            v[0], 
            r[0], 
            s[0]
        );

        // verify that account nonce is valid (for replay protection)
        // (verification key signing recipient address)
        bytes32 recipientHash = ZippieUtils.toEthSignedMessageHash(
            keccak256(abi.encodePacked(addresses[2]))
        );
        verifyMultisigNonce(
            addresses[0], 
            addresses[3], 
            recipientHash, 
            v[1], 
            r[1], 
            s[1]
        );

        // get the check hash (amount, recipient, nonce) 
        // and verify that required number of signers signed it 
        // (recipient is specified when check is created)
        // prepend with function name "redeemCheck"
        // so a hash for another function with same parameter 
        // layout don't get the same hash
        bytes32 checkHash = ZippieUtils.toEthSignedMessageHash(
            keccak256(abi.encodePacked("redeemCheck", amount, addresses[2], addresses[3]))
        );
        verifyMultisigSignerSignatures(
            checkHash, 
            [0, m[0]], 
            signers, 
            [2, m[1]], 
            v, 
            r, 
            s
        );

        // if limit is exceeded (2FA)
        // verify that requied number of 
        // card signatures has been provided 
        if (limitExceeded) {
            // verify that card nonces are valid 
            // and has not been used already
            verifyCardSignatures(
                cardNonces, 
                [m[0], m[2]], 
                signers, 
                [2+m[1], m[3]], 
                v, 
                r, 
                s
            );
        }

        // transfer tokens from multisig account to recipient address
        require(
            IERC20(addresses[1]).transferFrom(addresses[0], addresses[2], amount), 
            "Transfer failed"
        );
        return true;
    }

    /** @notice Redeems a blank check after verifying required signers/cards 
      * (recipient is specified when check is claimed) 
      * @dev Transfer ERC20 tokens when verified that 
      * enough signers has signed keccak256(amount, verification key)
      * card signatures are not required if amount doesn't exceeded the current limit
      * @param addresses required addresses
      * [0] multisig account to withdraw ERC20 tokens from
      * [1] ERC20 contract to use
      * [2] recipient of the ERC20 tokens
      * [3] verification key (nonce)
      * @param signers all possible signers and cards
      * [0..i] signer adresses
      * [i+1..j] card addresses
      * @param m the amount of signatures required for this multisig account
      * [0] possible number of signers
      * [1] required number of signers
      * [2] possible number of cards
      * [3] reqiuired number of cards
      * @param v v values of all signatures
      * [0] multisig account signature
      * [1] verification key signature
      * [2..i] signer signatures of check hash
      * [i+1..j] card signatures of random card nonces
      * @param r r values of all signatures (structured as v)
      * @param s s values of all signatures (structured as v)
      * @param amount amount to transfer
      * @param cardNonces random nonce values generated by cards at every read
      * @return true if transfer successful 
      */
    function redeemBlankCheck(
        address[] memory addresses, 
        address[] memory signers, 
        uint8[] memory m, 
        uint8[] memory v, 
        bytes32[] memory r, 
        bytes32[] memory s, 
        uint256 amount, 
        bytes32[] memory cardNonces
    ) 
        public 
        returns (bool)
    {
        require(
            addresses.length == 4, 
            "Incorrect number of addresses"
        ); 
        require(
            amount > 0, 
            "Amount must be greater than 0"
        );
       
        // sanity check of signature parameters 
        bool limitExceeded = isLimitExceeded(amount, addresses[0]);
        checkSignatureParameters(
            m, 
            signers.length, 
            v.length, 
            r.length, 
            s.length, 
            cardNonces.length, 
            limitExceeded
        );
        
        // verify that account signature is valid
        verifyMultisigAccountSignature(
            signers, 
            m, 
            addresses[0], 
            v[0], 
            r[0], 
            s[0]
        );

        // verify that account nonce is valid (for replay protection)
        // (verification key signing recipient address)
        bytes32 recipientHash = ZippieUtils.toEthSignedMessageHash(
            keccak256(abi.encodePacked(addresses[2]))
        );
        verifyMultisigNonce(
            addresses[0], 
            addresses[3], 
            recipientHash, 
            v[1], 
            r[1], 
            s[1]
        );

        // get the check hash (amount, nonce) 
        // and verify that required number of signers signed it 
        // (recipient is specified when check is claimed)
        // prepend with function name "redeemBlankCheck"
        // so a hash for another function with same parameter 
        // layout don't get the same hash
        bytes32 blankCheckHash = ZippieUtils.toEthSignedMessageHash(
            keccak256(abi.encodePacked("redeemBlankCheck", amount, addresses[3]))
        );
        verifyMultisigSignerSignatures(
            blankCheckHash, 
            [0, m[0]], 
            signers, 
            [2, m[1]], 
            v, 
            r, 
            s
        );

        // if limit is exceeded (2FA)
        // verify that requied number of 
        // card signatures has been provided 
        if (limitExceeded) {
            // verify that card nonces are valid 
            // and has not been used already
            verifyCardSignatures(
                cardNonces, 
                [m[0], m[2]], 
                signers, 
                [2+m[1], m[3]], 
                v, 
                r, 
                s
            );
        }

        // transfer tokens from multisig account to recipient address
        require(
            IERC20(addresses[1]).transferFrom(addresses[0], addresses[2], amount), 
            "Transfer failed"
        );
        return true;
    }

    /** @notice Set new card (2FA) limit for account
      * card signatures are not required 
      * if amount doesn't exceeded 
      * the current limit when creating checks
      * @dev Change limit when verified that 
      * enough signers has signed keccak256(amount, verification key)
      * card signatures are not required if limit is decreased
      * only if increased
      * @param addresses required addresses
      * [0] multisig account to withdraw ERC20 tokens from
      * [1] verification key (nonce)
      * @param signers all possible signers and cards
      * [0..i] signer addresses
      * [i+1..j] card addresses
      * @param m the amount of signatures required for this multisig account
      * [0] possible number of signers
      * [1] required number of signers
      * [2] possible number of cards
      * [3] reqiuired number of cards
      * @param v v values of all signatures
      * [0] multisig account signature
      * [1] verification key signature
      * [2..i] signer signatures of check hash
      * [i+1..j] card signatures of random card nonces
      * @param r r values of all signatures (structured as v)
      * @param s s values of all signatures (structured as v)
      * @param amount new limit amount
      * @param cardNonces random values generated by cards at every read
      * @return true if new limit was set successful 
      */
    function setLimit(
        address[] memory addresses, 
        address[] memory signers, 
        uint8[] memory m, 
        uint8[] memory v, 
        bytes32[] memory r, 
        bytes32[] memory s, 
        uint256 amount, 
        bytes32[] memory cardNonces
    ) 
        public 
        returns (bool)
    {
        require(
            addresses.length == 2, 
            "Incorrect number of addresses"
        );
        
        // sanity check of signature parameters 
        bool limitExceeded = isLimitExceeded(amount, addresses[0]);
        checkSignatureParameters(
            m, 
            signers.length, 
            v.length, 
            r.length, 
            s.length, 
            cardNonces.length, 
            limitExceeded
        );
        
        // verify that account signature is valid
        verifyMultisigAccountSignature(
            signers, 
            m, 
            addresses[0], 
            v[0], 
            r[0], 
            s[0]
        );

        // verify that account nonce is valid (for replay protection)
        // (nonce signing this multisig account address)
        bytes32 recipientHash = ZippieUtils.toEthSignedMessageHash(
            keccak256(abi.encodePacked(addresses[0]))
        );
        verifyMultisigNonce(
            addresses[0], 
            addresses[1], 
            recipientHash, 
            v[1], 
            r[1], 
            s[1]
        );

        // get the limit hash (amount, nonce) 
        // and verify that required number of signers signed it
        // prepend with function name "setLimit"
        // so a hash for another function with same parameter 
        // layout don't get the same hash
        bytes32 limitHash = ZippieUtils.toEthSignedMessageHash(
            keccak256(abi.encodePacked("setLimit", amount, addresses[1]))
        );
        verifyMultisigSignerSignatures(
            limitHash, 
            [0, m[0]], 
            signers, 
            [2, m[1]], 
            v, 
            r, 
            s
        );

        // in order to increase the account limit (2FA)
        // verify that requied number of 
        // card signatures has been provided 
        if (limitExceeded) {
            // verify that card nonces are valid 
            // and has not been used already
            verifyCardSignatures(
                cardNonces, 
                [m[0], m[2]], 
                signers, 
                [2+m[1], m[3]], 
                v, 
                r, 
                s
            );
        }

        // set the new limit fot this account
        accountLimits[addresses[0]] = amount;
        return true;
    }

    /** 
      * @dev sanity check of signature related parameters
      */
    function checkSignatureParameters(
        uint8[] memory m, 
        uint256 nrOfSigners, 
        uint256 nrOfVs, 
        uint256 nrOfRs, 
        uint256 nrOfSs, 
        uint256 nrOfCardNonces, 
        bool amountLimitExceeded
    ) 
        private 
        pure
        returns (bool)
    {
        require(
            m.length == 4, 
            "Invalid m[]"
        ); 
        require(
            m[1] <= m[0],
            "Required number of signers cannot be higher than number of possible signers"
        );
        require(
            m[3] <= m[2], 
            "Required number of cards cannot be higher than number of possible cards"
        );
        require(
            m[0] > 0, 
            "Required number of signers cannot be 0"
        );           
        require(
            m[1] > 0, 
            "Possible number of signers cannot be 0"
        );  
        require(
            m[0] != 0xFF, 
            "Required number of signers cannot be MAX UINT8"
        ); 
        require(
            m[1] != 0xFF, 
            "Possible number of signers cannot be MAX UINT8"
        ); 
        require(
            m[2] != 0xFF, 
            "Required number of cards cannot be MAX UINT8"
        ); 
        require(
            m[3] != 0xFF, 
            "Possible number of cards cannot be MAX UINT8"
        ); 
        
        // Card signatures must be appended to signers list
        if (amountLimitExceeded) {
            require(
                nrOfSigners == m[0] + m[2], 
                "Incorrect number of signers"
            ); 
            require(
                nrOfVs == 2 + m[1] + m[3], 
                "Incorrect number of signatures (v)"
            ); 
            require(
                nrOfRs == 2 + m[1] + m[3], 
                "Incorrect number of signatures (r)"
            ); 
            require(
                nrOfSs == 2 + m[1] + m[3], 
                "Incorrect number of signatures (s)"
            ); 
            require(
                nrOfCardNonces == m[3], 
                "Incorrect number of card nonces"
            ); 
        } else {
            // Accept either card signatures appended or missing 
            // (even if not required since amount is below limit)
            require(
                nrOfSigners == m[0] || nrOfSigners == m[0] + m[2], 
                "Incorrect number of signers"
            ); 
            require(
                nrOfVs == 2 + m[1] || nrOfVs == 2 + m[1] + m[3], 
                "Incorrect number of signatures (v)"
            ); 
            require(
                nrOfRs == 2 + m[1] || nrOfRs == 2 + m[1] + m[3], 
                "Incorrect number of signatures (r)"
            ); 
            require(
                nrOfSs == 2 + m[1] || nrOfSs == 2 + m[1] + m[3], 
                "Incorrect number of signatures (s)"
            ); 
            require(
                nrOfCardNonces == 0 || nrOfCardNonces == m[3], 
                "Incorrect number of card nonces"
            ); 
        }
        return true;
    }

    /** 
      * @dev checks if an amont is above the current limit
      */
    function isLimitExceeded(
        uint256 amount, 
        address account
    ) 
        private 
        view 
        returns(bool)
    {
        return amount > accountLimits[account];
    }
}
