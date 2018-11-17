pragma solidity ^0.4.24;


// Partially psuedo code. Will fix later. From Remix.
contract RandomTokenSwap {
  BasicToken oneToken = BasicToken(0xb17C1feBB85CDBEb99b00da0BeefB091AA5f8F9d);
  BasicToken twoToken = BasicToken(0x4872232D95D5d524eEa13844Aa0a745BBEA850Eb);
  BasicToken threeToken = BasicToken(0x816FF8390E41594caB5F1d1A0d0F4d24Cd824909);
  
  function checkAllowance() public view returns(uint){
    BasicToken token = BasicToken(0xb17C1feBB85CDBEb99b00da0BeefB091AA5f8F9d);
    address fromUser = msg.sender;

    return token.allowance(fromUser, address(this));
  }
  
  
  function sendTransactionIfApproved() public {
    address fromUser = msg.sender;
    uint decimals = oneToken.decimals();
    uint singleToken = 1 * 10 ** uint(decimals);
    // Adding in default users from my MetaMask for meow
    oneToken.transferFrom(fromUser, address(this), singleToken);
  }
  
  function transferFromContract(address _address) public {
    uint decimals = oneToken.decimals();
    uint singleToken = 1 * 10 ** uint(decimals);
    oneToken.transfer(_address, singleToken);
  }
  
  function getBalanceOfToken(address _tokenAddress) public view returns(uint) {
    BasicToken token = BasicToken(_tokenAddress);
    return token.balanceOf(address(this));
  }
}