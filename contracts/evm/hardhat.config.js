require('dotenv').config();
require('@nomicfoundation/hardhat-toolbox');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: '0.8.24',
    settings: {
      optimizer: { enabled: true, runs: 500 }
    }
  },
  networks: {
    hardhat: {},
    localhost: {
      url: 'http://127.0.0.1:8545'
    },
    polygon: {
      url: process.env.POLYGON_RPC_URL || '',
      accounts: process.env.DEPLOYER_KEY ? [process.env.DEPLOYER_KEY] : []
    },
    arbitrum: {
      url: process.env.ARBITRUM_RPC_URL || '',
      accounts: process.env.DEPLOYER_KEY ? [process.env.DEPLOYER_KEY] : []
    }
  },
  etherscan: {
    apiKey: {
      polygon: process.env.POLYGONSCAN_API_KEY || '',
      arbitrumOne: process.env.ARBISCAN_API_KEY || ''
    }
  }
};
