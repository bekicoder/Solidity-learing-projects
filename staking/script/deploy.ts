import pkg from "hardhat";
const { ethers } = pkg;
async function main() {
  
   // deploy token.sol
    const Token = await ethers.getContractFactory("MyToken")
    const token = await Token.deploy()
    await token.waitForDeployment()
    console.log("Token deployed address :",await token.getAddress())
  // 🔹 Replace these with real deployed token addresses
  const STAKING_TOKEN = await token.getAddress();
  const REWARD_TOKEN  =await token.getAddress();

  // 🔹 Example: 1 token per second (assuming 18 decimals)
  const REWARD_RATE = ethers.parseUnits("1", 18);

  const Staking = await ethers.getContractFactory("SimpleStaking");

  const staking = await Staking.deploy(
    STAKING_TOKEN,
    REWARD_TOKEN,
    REWARD_RATE
  );

  await staking.waitForDeployment();

  console.log("Staking deployed to:", await staking.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
