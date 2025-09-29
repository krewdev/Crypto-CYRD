const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const tokenAddress = process.env.CYRD_ADDRESS;
  const backendAddress = process.env.BACKEND_SIGNER;
  if (!tokenAddress || !backendAddress) {
    throw new Error("Set CYRD_ADDRESS and BACKEND_SIGNER env vars");
  }

  const Redemption = await hre.ethers.getContractFactory("Redemption");
  const redemption = await Redemption.deploy(deployer.address, tokenAddress, backendAddress);
  await redemption.deployed();
  console.log("Redemption deployed:", redemption.address);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
