pragma solidity ^0.4.24;


// Partially psuedo code. Will fix later. From Remix. Need to add in other contracts to get this deploying right.
// This *works* but super incomplete.
contract RandomTokenSwap is Owned {
    struct Token {
        string symbol;
        address tokenAddress;
    }
    
    mapping (bytes32 => address) public tokenAddresses;
    uint public totalTokens = 0;
    Token[] public tokens;
    mapping (bytes32 => uint) indexOfToken;
    
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
    
    
    function sendTransactionIfApproved(string _tokenName) public {
        address fromUser = msg.sender;
        BasicToken token = BasicToken(tokenAddresses[convertStringToKey(_tokenName)]);
        
        uint singleToken = 1 * 10 ** uint(token.decimals());
        // Adding in default users from my MetaMask for meow
        token.transferFrom(fromUser, address(this), singleToken);
        transferFromContract();
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
    function transferFromContract() private {
        uint index = random() % tokens.length;
        string memory symbol = tokens[index].symbol;
        BasicToken token = BasicToken(tokenAddresses[convertStringToKey(symbol)]);
        uint balance = getBalanceOfToken(symbol);
        uint singleToken = 1 * 10 ** uint(token.decimals());

        // Will just revert if there's no balance in contract for that token.
        // TODO: Proper way of re-running the function.
        if (balance == 0) {
            revert("Balance of random token is zero. Please try again.");
        }
        
        token.transfer(msg.sender, singleToken);
    }
    
    function convertStringToKey(string key) private pure returns (bytes32 ret) {
        if (bytes(key).length > 32) {
            revert();
        }

        assembly {
            ret := mload(add(key, 32))
        }
    }
    
    // This is NOT truly random. Just a proxy for basic testing.
    function random() private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, now, tokens.length)));
    }
}