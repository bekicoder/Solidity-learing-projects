import pkg from "hardhat";
const { ethers } = pkg;

async function main() {
  // 1️⃣ Replace this with your compiled bytecode from solc
  const bytecode = "0x602f600b5f39602f5ff3fe5f3560e01c8063d09de08a14602357636d4ce63c14601a575b005b5f545f5260205ff35b5060015f54015f55601856";
  // 2️⃣ Use an empty ABI because our contract is Yul
  const abi = [];

  // 3️⃣ Get signer
  const [deployer] = await ethers.getSigners();
  console.log("Deploying from:", deployer.address);

  // 4️⃣ Create ContractFactory
  const factory = new ethers.ContractFactory(abi, bytecode, deployer);

  // 5️⃣ Deploy contract
  const contract = await factory.deploy();
  await contract.waitForDeployment();

  console.log("Counter deployed at:", await contract.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
