# Token Swap Contract

## V1

- [x] Contract should be able to transfer ERC-20 Tokens (Partially implemented, not robust)
- [ ] Should randomly send back a token to the user upon approval being permitted

# Notes so far

A limitation of this contract is being to able to get APPROVAL for ERC-20 token transfers within the contract itself. The approve function of the ERC-20 interface requires users to call the contract directly because it relies on the msg.sender (address) to come from the original address itself.

This means there will be two transactions required to play. Not sure this is avoidable, as the ERC-20 standard doesn't some extensions other contracts have.

E.G: 

``` 
// ----------------------------------------------------------------------------
// Contract function to receive approval and execute function in one call
//
// Borrowed from MiniMeToken
// ----------------------------------------------------------------------------
contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}
```

```    
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
```

May explore how common the *above* has been implemented.
