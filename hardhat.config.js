/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require('dotenv').config()

module.exports = {
  networks: {
    bnb: {
      url: "https://data-seed-prebsc-1-s1.binance.org:8545/",
      chainId: 97,
      accounts: [`${process.env.PRIVATE_KEY}`]
    },
    main: {
      url: "https://bsc-dataseed.binance.org/",
      chainId: 56,
      accounts: [`${process.env.PRIVATE_KEY}`]
    }
  },
  etherscan: {
    apiKey: "4W3GQRGEMSXKW2J8BICWZWJCP9BFQ58RGA"
  },
  solidity: {
    version: "0.8.0",
    settings: {
      optimizer: {
        enabled: true,
        runs: 9999,
      },
    },

  },
};
