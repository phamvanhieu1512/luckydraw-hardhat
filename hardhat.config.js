require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks: {
    songbird: { 
      url: `https://coston-api.flare.network/ext/C/rpc`,
      chainId: 16,
      accounts: [
        `0x9ee25c92c1afb33fb020ed76627d1babbae4c4cd6eb42a9f708a766dad453bb6`,
      ],
    }
  },
};
