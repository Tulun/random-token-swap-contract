pragma solidity ^0.4.24;


// Partially psuedo code. Will fix later. From Remix. Need to add in other contracts to get this deploying right.
contract RandomTokenSwap is Owned {
    mapping (bytes32 => address) public tokenAddresses;
    
    constructor() public {
        tokenAddresses[convertStringToKey("ONE")] = 0xb17C1feBB85CDBEb99b00da0BeefB091AA5f8F9d;
        tokenAddresses[convertStringToKey("TWO")] = 0x4872232D95D5d524eEa13844Aa0a745BBEA850Eb;
        tokenAddresses[convertStringToKey("THREE")] = 0x816FF8390E41594caB5F1d1A0d0F4d24Cd824909;
    }
    
    function checkAllowance(string _tokenName) public view returns(uint) {
        BasicToken token = BasicToken(tokenAddresses[convertStringToKey(_tokenName)]);
        address fromUser = msg.sender;

        return token.allowance(fromUser, address(this));
    }
    
    
    function sendTransactionIfApproved(string _tokenName) public {
        address fromUser = msg.sender;
        BasicToken token = BasicToken(tokenAddresses[convertStringToKey(_tokenName)]);
        uint decimals = token.decimals();
        uint singleToken = 1 * 10 ** uint(decimals);
        // Adding in default users from my MetaMask for meow
        token.transferFrom(fromUser, address(this), singleToken);
        transferFromContract(singleToken, token);
    }
    
    function getBalanceOfToken(address _tokenAddress) public view returns(uint) {
        BasicToken token = BasicToken(_tokenAddress);
        return token.balanceOf(address(this));
    }
    
    function addTokenToSwap(string _tokenName, address _tokenAddress) public onlyOwner {
        tokenAddresses[convertStringToKey(_tokenName)] = _tokenAddress;
    }
    
    function checkTokenAddress(string _tokenName) public view returns(address) {
        return tokenAddresses[convertStringToKey(_tokenName)];
    }
    
    function transferFromContract(uint _singleToken, BasicToken _token) private {
        _token.transfer(msg.sender, _singleToken);
    }
    
    function convertStringToKey(string key) private pure returns (bytes32 ret) {
        if (bytes(key).length > 32) {
            revert();
        }

        assembly {
            ret := mload(add(key, 32))
        }
    }
}
