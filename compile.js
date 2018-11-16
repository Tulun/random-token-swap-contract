const path = require("path");
const solc = require("solc");
const fs = require("fs-extra");

const buildPath = path.resolve(__dirname, "build");

// Remove build folder.
fs.removeSync(buildPath);

const tokenPath = path.resolve(__dirname, "contracts", "token", "BasicToken.sol");
const approveAndCallFallBackPath = path.resolve(__dirname, "contracts", "token", "ApproveAndCallFallBack.sol");
const erc20InterfacePath = path.resolve(__dirname, "contracts", "token", "ERC20Interface.sol");
const ownedPath = path.resolve(__dirname, "contracts", "token", "Owned.sol");
const safeMathPath = path.resolve(__dirname, "contracts", "token", "SafeMath.sol");

const input = {
  sources: {
    "BasicToken.sol": fs.readFileSync(tokenPath, "utf8"),
    "ApproveAndCallFallBack.sol": fs.readFileSync(approveAndCallFallBackPath, "utf8"),
    "ERC20Interface.sol": fs.readFileSync(erc20InterfacePath, "utf8"),
    "Owned.sol": fs.readFileSync(ownedPath, "utf8"),
    "SafeMath.sol": fs.readFileSync(safeMathPath, "utf8"),
  }
}

const output = solc.compile(input, 1);
console.log('o', output, output.contracts);
const contracts = output.contracts;
fs.ensureDirSync(buildPath);

for (let contract in contracts) {
  const filename = contract.split(".")[0];
  console.log(`interface for ${contract}: `, contracts[contract].interface)
  fs.outputJsonSync(
    path.resolve(buildPath, `${filename}.json`),
    contracts[contract]
  );
}

console.log('compile successful!');
console.log('Your ABIs might need to be updated on any frontend apps.')
