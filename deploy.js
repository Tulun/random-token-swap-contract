const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const compiledContract = require("./build/BasicToken.json");
require('dotenv').config()

console.log(process.argv);



const TO_WEI = 10**18;

const ropsten = `https://ropsten.infura.io/v3/${process.env.INFURA_API_KEY}`;
const provider = new HDWalletProvider(
  process.env.WORDS,
  ropsten
);

const web3 = new Web3(provider);
const GWEI_TO_WEI = 10**9;

// Configure deployment based on node args.
let args = [];
// node deploy.js <arg>
if (process.argv[2] === "token") {
  args = ["FUEL", "Fuel", 10000];
}

const deploy = async () => {
  const accounts = await web3.eth.getAccounts();
  console.log('attempting to deploy from account', accounts[0]);
  const count = await web3.eth.getTransactionCount(accounts[0]);
  const nonce = await web3.utils.toHex(count);
  console.log('c', count, 'nonce', nonce);

  const result = await new web3.eth.Contract(JSON.parse(compiledContract.interface))
    .deploy({ data: `0x${compiledContract.bytecode}`, arguments: args })
    .send({ 
      gas: "7700000", 
      from: accounts[0],
    });

  console.log('instance of contract', result.options.address);
  process.exit(0);
};

deploy();
