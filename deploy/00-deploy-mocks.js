//mock price feed contract
const { network } = require("hardhat");

const DECIMALS = "8";
const INITIAL_ANSWER = "200000000000"; //2000

module.exports = async (hre) => {
  const { getNamedAccounts, deployments } = hre;
  const { deploy, log } = deployments;
  const { deployer } = await getNamedAccounts();
  const chainId = network.config.chainId;

  if (chainId == 31337) {
    //if we are on an local environment, we need to deploy mocks

    log("local network detected! deploying mocks...");
    await deploy("MockV3Aggregator", {
      contract: "MockV3Aggregator",
      from: deployer,
      log: true,
      args: [DECIMALS, INITIAL_ANSWER],
    });
    log("Mocks deploying...");

    log("-----------------------------------------------");
  }
};

module.exports.tags = ["all", "mocks"];
