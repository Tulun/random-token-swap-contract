pragma solidity ^0.4.24;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";

// ----------------------------------------------------------------------------
// 'FIXED' 'Example Fixed Supply Token' token contract
//
// Symbol      : FIXED
// Name        : Example Fixed Supply Token
// Total supply: 1,000,000.000000000000000000
// Decimals    : 18
//
// Enjoy.
//
// (c) BokkyPooBah / Bok Consulting Pty Ltd 2018. The MIT Licence.
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// Safe maths
// ----------------------------------------------------------------------------
library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    }
}


library StringUtils {
    /// @dev Does a byte-by-byte lexicographical comparison of two strings.
    /// @return a negative number if `_a` is smaller, zero if they are equal
    /// and a positive numbe if `_b` is smaller.
    function compare(string _a, string _b) returns (int) {
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
    /// @dev Compares two strings and returns true iff they are equal.
    function equal(string _a, string _b) returns (bool) {
        return compare(_a, _b) == 0;
    }
    /// @dev Finds the index of the first occurrence of _needle in _haystack
    function indexOf(string _haystack, string _needle) returns (int)
    {
    	bytes memory h = bytes(_haystack);
    	bytes memory n = bytes(_needle);
    	if(h.length < 1 || n.length < 1 || (n.length > h.length)) 
    		return -1;
    	else if(h.length > (2**128 -1)) // since we have to be able to return -1 (if the char isn't found or input error), this function must return an "int" type with a max length of (2^128 - 1)
    		return -1;									
    	else
    	{
    		uint subindex = 0;
    		for (uint i = 0; i < h.length; i ++)
    		{
    			if (h[i] == n[0]) // found the first char of b
    			{
    				subindex = 1;
    				while(subindex < n.length && (i + subindex) < h.length && h[i + subindex] == n[subindex]) // search until the chars don't match or until we reach the end of a or b
    				{
    					subindex++;
    				}	
    				if(subindex == n.length)
    					return int(i);
    			}
    		}
    		return -1;
    	}	
    }
}

// ----------------------------------------------------------------------------
// ERC Token Standard #20 Interface
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// ----------------------------------------------------------------------------
contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}


// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}


// ----------------------------------------------------------------------------
// Owned contract
// ----------------------------------------------------------------------------
contract Owned {
    address public owner;
    address public newOwner;

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


// ----------------------------------------------------------------------------
// ERC20 Token, with the addition of symbol, name and decimals and a
// fixed supply
// ----------------------------------------------------------------------------
contract BasicToken is ERC20Interface, Owned {
    using SafeMath for uint;

    string public symbol;
    string public  name;
    uint8 public decimals;
    uint _totalSupply;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;


    // ------------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------------
    constructor() public {
        symbol = "Three";
        name = "Three Token";
        decimals = 18;
        _totalSupply = 10000 * 10**uint(decimals);
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, _totalSupply);
    }


    // ------------------------------------------------------------------------
    // Total supply
    // ------------------------------------------------------------------------
    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }


    // ------------------------------------------------------------------------
    // Get the token balance for account `tokenOwner`
    // ------------------------------------------------------------------------
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    // ------------------------------------------------------------------------
    // Transfer the balance from token owner's account to `to` account
    // - Owner's account must have sufficient balance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account
    //
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
    // recommends that there are no checks for the approval double-spend attack
    // as this should be implemented in user interfaces 
    // ------------------------------------------------------------------------
    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Transfer `tokens` from the `from` account to the `to` account
    // 
    // The calling account must already have sufficient tokens approve(...)-d
    // for spending from the `from` account and
    // - From account must have sufficient balance to transfer
    // - Spender must have sufficient allowance to transfer
    // - 0 value transfers are allowed
    // ------------------------------------------------------------------------
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }


    // ------------------------------------------------------------------------
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    // ------------------------------------------------------------------------
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    // ------------------------------------------------------------------------
    // Token owner can approve for `spender` to transferFrom(...) `tokens`
    // from the token owner's account. The `spender` contract function
    // `receiveApproval(...)` is then executed
    // ------------------------------------------------------------------------
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }


    // ------------------------------------------------------------------------
    // Don't accept ETH
    // ------------------------------------------------------------------------
    function () public payable {
        revert();
    }


    // ------------------------------------------------------------------------
    // Owner can transfer out any accidentally sent ERC20 tokens
    // ------------------------------------------------------------------------
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}

contract RandomTokenSwap is Owned, usingOraclize {
    
    using strings for *;
    struct Token {
        string symbol;
        address tokenAddress;
    }
    
    struct Play {
        address playerAddress;
        bytes32 queryId;
        string tokenSent;
    }
    
    struct slice {
        uint _len;
        uint _ptr;
    }
    
    mapping (bytes32 => address) public tokenAddresses;
    uint public totalTokens = 0;
    Token[] public tokens;
    mapping (bytes32 => uint) indexOfToken;
    mapping (bytes32 => Play) playDetails;
    
    event LogRandomNumber(string _randomNumber);
    event LogOraclizeID(string _oraclizeId);
    event LogQueryEvent(string _event);
    event LogSymbol(string _symbol);
    event LogLastPlayerAddress(address _address);
    event LogResultWithBonus(uint _result);
    
    constructor() public {
        tokenAddresses[convertStringToKey("ONE")] = 0xb17C1feBB85CDBEb99b00da0BeefB091AA5f8F9d;
        Token memory oneToken = Token({
            symbol: "ONE",
            tokenAddress: 0xb17C1feBB85CDBEb99b00da0BeefB091AA5f8F9d
        });
        indexOfToken[convertStringToKey("ONE")] = 0;
        tokens.push(oneToken);
        
        tokenAddresses[convertStringToKey("TWO")] = 0x4872232D95D5d524eEa13844Aa0a745BBEA850Eb;
        Token memory twoToken  = Token({
            symbol: "TWO",
            tokenAddress: 0x4872232D95D5d524eEa13844Aa0a745BBEA850Eb
        });
        tokens.push(twoToken);
        indexOfToken[convertStringToKey("TWO")] = 1;

        tokenAddresses[convertStringToKey("THREE")] = 0x816FF8390E41594caB5F1d1A0d0F4d24Cd824909;
        Token memory threeToken  = Token({
            symbol: "THREE",
            tokenAddress: 0x816FF8390E41594caB5F1d1A0d0F4d24Cd824909
        });
        indexOfToken[convertStringToKey("THREE")] = 2;
        tokens.push(threeToken);

        totalTokens = 3;
    }
    
    function checkAllowance(string _tokenName) public view returns(uint) {
        BasicToken token = BasicToken(tokenAddresses[convertStringToKey(_tokenName)]);
        address fromUser = msg.sender;

        return token.allowance(fromUser, address(this));
    }
    
    function getBalanceOfToken(string _tokenName) public view returns(uint) {
        BasicToken token = BasicToken(tokenAddresses[convertStringToKey(_tokenName)]);
        return token.balanceOf(address(this));
    }
    
    function addTokenToSwap(string _tokenName, address _tokenAddress) public onlyOwner returns(bool) {
        tokenAddresses[convertStringToKey(_tokenName)] = _tokenAddress;

        Token memory newToken = Token({
            symbol: _tokenName,
            tokenAddress: _tokenAddress
        });
        
        indexOfToken[convertStringToKey(_tokenName)] = tokens.length - 1;
        tokens.push(newToken);
        totalTokens++;
        
        return true;
    }
    
    // This is incomplete. Will deal with the better way later.
    function removeTokenFromSwap(string _tokenName) public onlyOwner returns(bool) {
        tokenAddresses[convertStringToKey(_tokenName)] = address(0);
        uint index = indexOfToken[convertStringToKey(_tokenName)];
        delete tokens[index];
        totalTokens--;
        
        return true;
    }
    
    function checkTokenAddress(string _tokenName) public view returns(address) {
        return tokenAddresses[convertStringToKey(_tokenName)];
    }
    
    // Need concept of checking cheaply for balances.
    // For testing purposes
    // A token will have a 50% chance of being chosen
    // B token will have a 30% chance of being chosen
    // C token will have a 20% chance of being chosen
    function transferFromContract(uint _randomNumber, Play _play) private {
        string memory symbol;
        uint bonus = 0;
        
        if (StringUtils.equal(_play.tokenSent, "TWO")) {
            bonus = 10;
        }
        
        if (StringUtils.equal(_play.tokenSent, "THREE")) {
            bonus = 20;
        }
        // A Chosen
        if (_randomNumber + bonus <= 50) {
            symbol = tokens[0].symbol;
        }
        
        // B Chosen
        if (_randomNumber + bonus > 50 && _randomNumber + bonus <= 70) {
            symbol = tokens[1].symbol;
        }
        
        // C Chosen
        if (_randomNumber + bonus > 70) {
            symbol = tokens[2].symbol;
        }
        
        // Token Sent details
        BasicToken tokenSent = BasicToken(tokenAddresses[convertStringToKey(_play.tokenSent)]);
        uint singleTokenSent = 1 * 10 ** uint(tokenSent.decimals());
        
        // Token won details
        BasicToken tokenWon = BasicToken(tokenAddresses[convertStringToKey(symbol)]);
        uint balance = getBalanceOfToken(symbol);
        uint singleTokenWon = 1 * 10 ** uint(tokenWon.decimals());

        // Will just revert if there's no balance in contract for that token.
        // TODO: Proper way of re-running the function.
        if (balance == 0) {
            revert("Balance of random token is zero. Please try again.");
        }
        emit LogSymbol(symbol);
        emit LogLastPlayerAddress(_play.playerAddress);
        emit LogResultWithBonus(_randomNumber + bonus);
        tokenSent.transferFrom(_play.playerAddress, address(this), singleTokenSent);
        tokenWon.transfer(_play.playerAddress, singleTokenWon);
    }
    
    function convertStringToKey(string key) private pure returns (bytes32 ret) {
        if (bytes(key).length > 32) {
            revert();
        }

        assembly {
            ret := mload(add(key, 32))
        }
    }
    
    function __callback(bytes32 _myid, string result) public {
       if (msg.sender != oraclize_cbAddress()) revert();
        emit LogRandomNumber(result);
        uint randomNumber = parseInt(result);
        Play storage play = playDetails[_myid];
        transferFromContract(randomNumber, play);
    }
    
    // Using oraclize, this becomes random.
    function sendTransactionIfApproved(string _tokenName) public payable returns (uint) {
        if (oraclize_getPrice("WolframAlpha") > address(this).balance) {
            emit LogQueryEvent("Please send some ETH along to make transaction.");
        } else {
            emit LogQueryEvent("Oraclize query was sent, standing by for the answer..");

            bytes32 queryId = oraclize_query("WolframAlpha", "random number between 0 and 100"); 
            playDetails[queryId] = Play({playerAddress: msg.sender, queryId: queryId, tokenSent: _tokenName });

        }
        // return uint(keccak256(abi.encodePacked(block.difficulty, now, tokens.length)));

    }
    
    function bytes32ToString(bytes32 x) internal pure returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        
        return string(bytesStringTrimmed);
    }
    
    // parseInt
    function parseInt(string _a) internal pure returns (uint) {
        return parseInt(_a, 0);
    }
    
}

