require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config({ path: ".env" });
require("@nomicfoundation/hardhat-chai-matchers");
require("hardhat-gas-reporter");

const PRIVATE_KEY = process.env.PRIVATE_KEY;
const POLYGON_API_URL = process.env.POLYGON_API_URL;
const POLYGON_SCAN_KEY = process.env.POLYGON_SCAN_KEY;
const AVALANCHE_URL = process.env.AVALANCHE_URL;
const AVALANCHE_SNOWTRACE_KEY = process.env.AVALANCHE_SNOWTRACE_KEY;

module.exports = {
  solidity: "0.8.18",
  gasReporter: {
    currency: 'AVAX',
    gasPrice: 21
  },
  networks: {
    mumbai: {
      url: POLYGON_API_URL,
      accounts: [PRIVATE_KEY],
    },
    fuji: {
      url: AVALANCHE_URL,
      accounts: [PRIVATE_KEY],
      chainId: 43113,
    },
  },
  etherscan: {
    apiKey: {
      polygonMumbai: POLYGON_SCAN_KEY,
      avalancheFujiTestnet: AVALANCHE_SNOWTRACE_KEY,
    },
  },
}