const hre = require("hardhat");

async function main() {
  // Address of a Stablecoin (e.g., USDC on Polygon)
  const USDC_ADDRESS = "0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174";

  const SubscriptionEngine = await hre.ethers.getContractFactory("SubscriptionEngine");
  const engine = await SubscriptionEngine.deploy(USDC_ADDRESS);

  await engine.waitForDeployment();
  console.log(`Subscription Engine deployed to: ${await engine.getAddress()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
