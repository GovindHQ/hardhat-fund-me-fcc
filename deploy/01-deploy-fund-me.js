//since we are using hardhat deploy in this
//we dont have to define a main function or call it

// function deployFunc() {
//   console.log("Hi!");
// }

// module.exports.default = deployFunc; //we set deployFunc as the default function that hardhat uses to deploy
const { networkConfig, developmentChain } = require("../helper-hardhat-config");
const { network } = require("hardhat");
const { verify } = require("../utils/verify");

module.exports = async (hre) => {
  const { getNamedAccounts, deployments } = hre; //pulling these variables out from hre
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;

  //if chainId is x use address Y

  // const ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"];
  let ethUsdPriceFeedAddress;

  if (developmentChain.includes(network.name)) {
    const ethUsdAggregator = await deployments.get("MockV3Aggregator"); //we get the address like this.
    ethUsdPriceFeedAddress = ethUsdAggregator.address;
  } else {
    ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"];
  }
  //if the contract doesnt exist, we deploy a minimal version for our local testing.

  //when going for localhost or hardhat network we want to use a mock to get the price feeds
  log("the constructor argument is:", ethUsdPriceFeedAddress);
  const fundMe = await deploy("FundMe2", {
    from: deployer,
    args: [ethUsdPriceFeedAddress], //put pricefeed address
    log: true,
    waitConfirmations: network.config.blockConfirmations || 1,
  });
  if (!developmentChain.includes(network.name)) {
    //verify
    await verify(fundMe.address, [ethUsdPriceFeedAddress]); //contract address and contract arguments as parameters
  }
  log("---------------------------------------------------");
  log("contract deployed at:", network.name, fundMe.address);
};

module.exports.tags = ["all", "fundme"];
