require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */

const fs = require("fs");
const privateKey = fs.readFileSync(".secret").toString();

module.exports = {
  networks: {
    hardhat: {
      chainId: 1337,
    },
    amoy: {
      url: `https://polygon-amoy.g.alchemy.com/v2/${process.env.Alchemy_api_key}`,
      accounts: [privateKey],
    },
  },
  solidity: "0.8.24",
};
