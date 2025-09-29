const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with:", deployer.address);

  const CYRD = await hre.ethers.getContractFactory("CYRD");
  const cyrd = await CYRD.deploy(deployer.address);
  await cyrd.deployed();
  console.log("CYRD deployed:", cyrd.address);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
