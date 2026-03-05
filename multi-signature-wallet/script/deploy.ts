import pkg from "hardhat";
const { ethers } = pkg;
async function main() {
    const multiSig = await ethers.getContractFactory("MultiSigWallet")
    const multiSigWallet = await multiSig.deploy(["0x70997970C51812dc3A010C7d01b50e0d17dc79C8","0x70997970C51812dc3A010C7d01b50e0d17dc79C8","0x90F79bf6EB2c4f870365E785982E1f101E93b906"],2)
    await multiSigWallet.waitForDeployment()

    console.log("Multi signature contract deployed successfully\n",await  multiSigWallet.getAddress())
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
