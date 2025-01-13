require("dotenv").config();
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("hardhat-contract-sizer");
require("hardhat-gas-reporter");
require("@nomiclabs/hardhat-ethers");
// require("@openzeppelin/hardhat-upgrades");

const fs = require("fs");
// const mnemonic = fs.readFileSync(".secret").toString().trim();

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
    },
    mainnet: {
      url: `https://ethereum.publicnode.com`,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      gas: 7000000,
      gasPrice: 17000000000,
    },
    ropsten: {
      chainId: 3,
      url: `https://ropsten.infura.io/v3/${process.env.INFURA_API_KEY}`,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      skipDryRun: true,
      gas: 7000000,
      gasPrice: 35000000000,
    },
    sepolia: {
      chainId: 11155111,
      url: `https://ethereum-sepolia.blockpi.network/v1/rpc/public`,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      skipDryRun: true,
      gas: 7000000,
      gasPrice: 26000000000,
    },
    goerli: {
      chainId: 5,
      url: "https://eth-goerli.g.alchemy.com/v2/K9IsbfM7Z0jHrR5VTyg0rOsu0ghafL9D",
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      skipDryRun: true,
      gas: 7000000,
      gasPrice: 120000000000,
    },
    // ropsten: {
    //   chainId: 3,
    //   url: `https://ropsten.infura.io/v3/${INFURA_PROJECT_ID}`,
    //   accounts: [`0x${METAMASK_PRIVATE_KEY}`],
    //   //		gas: 7000000,
    //   skipDryRun: true,
    // },
    bsctestnet: {
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      url: "https://data-seed-prebsc-1-s1.binance.org:8545",
      gas: 7000000,
      gasPrice: 15000000000,
    },
    bsc: {
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      url: "https://bsc-dataseed2.binance.org",
      gas: 7000000,
      gasPrice: 3000000000,
    },
    polygon: {
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      url: "https://polygon.blockpi.network/v1/rpc/public",
      gas: 7000000,
      gasPrice: 140000000000,
    },
    mumbai: {
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      url: "https://polygon-mumbai.blockpi.network/v1/rpc/public",
      gas: 7000000,
      gasPrice: 200000000000,
    },
    arbitrum: {
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      url: "https://arb1.arbitrum.io/rpc",
      gas: 7000000,
      gasPrice: 100000000,
    },
    arbitrumOneGoerli: {
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      url: "https://arbitrum-goerli.public.blastapi.io",
      gas: 7000000,
      gasPrice: 100000000,
    },
    cronosTestnet: {
      url: "https://cronos-testnet-3.crypto.org:8545",
      accounts: [`0x${process.env.PRIVATE_KEY}`],
    },
    grove: {
      url: "https://mainnet.grovechain.io",
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      gas: 7000000,
      gasPrice: 25100000000,
    },
    grovetestnet: {
      url: "https://testnet.grovechain.io",
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      gas: 7000000,
      gasPrice: 25100000000,
    },
  },
  solidity: {
    version: "0.8.19",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  etherscan: {
    apiKey: {
      mainnet: process.env.ETHERSCAN_API_KEY,
      ropsten: process.env.ETHERSCAN_API_KEY,
      goerli: process.env.ETHERSCAN_API_KEY,
      sepolia: process.env.ETHERSCAN_API_KEY,
      // binance smart chain
      bsc: process.env.BSCSCAN_API_KEY,
      bscTestnet: process.env.BSCSCAN_API_KEY,
      polygon: process.env.POLYGON_API_KEY,
      polygonMumbai: process.env.POLYGON_API_KEY,
      arbitrumOne: process.env.ARBITRUM_API_KEY,
      arbitrumOneGoerli: process.env.ARBITRUM_API_KEY,
    },
    customChains: [
      {
        network: "arbitrumOneGoerli",
        chainId: 421613,
        urls: {
          apiURL: "https://api-goerli.arbiscan.io/api",
          browserURL: "https://goerli.arbiscan.io/",
        },
      },
    ],
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS ? true : false,
  },
};
