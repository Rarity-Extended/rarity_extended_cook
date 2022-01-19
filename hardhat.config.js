require('@nomiclabs/hardhat-etherscan');
require('@nomiclabs/hardhat-ethers');
require('@nomiclabs/hardhat-waffle');
require("@nomiclabs/hardhat-truffle5");
require("@nomiclabs/hardhat-ganache");
require('hardhat-deploy');
require('hardhat-deploy-ethers');
require('hardhat-tracer');
require("dotenv").config();

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const ANOTHER_PRIVATE_KEY = process.env.ANOTHER_PRIVATE_KEY;
if (!process.env.PRIVATE_KEY) {
  throw new Error("ENV Variable PRIVATE_KEY not set!");
}
if (!process.env.ANOTHER_PRIVATE_KEY) {
  throw new Error("ENV Variable ANOTHER_PRIVATE_KEY not set!");
}

module.exports = {
  solidity: {
    version: '0.8.0',
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      }
    }
  },
  networks: {
    hardhat: {
        forking: {
      url: "http://localhost:8545",
      // url: 'https://rpc.ftm.tools',
        },
        chainId: 250
    },
    localhost: {
      url: "http://localhost:8545",
      timeout: 2000000000,
      accounts: [PRIVATE_KEY, ANOTHER_PRIVATE_KEY]
    },
    fantom: {
      chainId: 250,
      url: 'https://rpc.ftm.tools',
      accounts: [PRIVATE_KEY, ANOTHER_PRIVATE_KEY]
    }
  }
}