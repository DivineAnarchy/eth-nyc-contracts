require("dotenv").config();
require("@openzeppelin/hardhat-upgrades");
require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("hardhat-gas-reporter");
require("solidity-coverage");
// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();
  for (const account of accounts) {
    console.log(account.address);
  }
});
// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more
/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 300
      }
    }
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: false,
      timeout: 200000
    },
    matic: {
      url: "https://rpc-mumbai.maticvigil.com",
      accounts: [process.env.TEST_P_KEY]
    }
  },
  gasReporter: {
    enabled: process.env.REPORT_GAS !== undefined,
    currency: "USD",
    gasPrice: 65,
    coinmarketcap: 'ecfc5a1a-e103-459f-a407-4a9a8e0e5c45'
  },
  etherscan: {
    apiKey: process.env.POLYGONSCAN_API_KEY
  },
};
