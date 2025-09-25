const hre = require("hardhat");

async function main() {
  console.log("Starting deployment...");
  
  // Get the deployer account
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);
  
  // Get the contract factories
  const CypherRelayDollar = await hre.ethers.getContractFactory("CypherRelayDollar");
  const CypherRedemption = await hre.ethers.getContractFactory("CypherRedemption");
  
  // Deploy CYRD token
  console.log("Deploying CypherRelayDollar...");
  const cyrdToken = await CypherRelayDollar.deploy();
  await cyrdToken.waitForDeployment();
  const cyrdAddress = await cyrdToken.getAddress();
  console.log("CypherRelayDollar deployed to:", cyrdAddress);
  
  // Deploy Redemption contract
  console.log("Deploying CypherRedemption...");
  const redemption = await CypherRedemption.deploy(cyrdAddress);
  await redemption.waitForDeployment();
  const redemptionAddress = await redemption.getAddress();
  console.log("CypherRedemption deployed to:", redemptionAddress);
  
  // Grant MINTER_ROLE to redemption contract
  console.log("Setting up roles...");
  const MINTER_ROLE = await cyrdToken.MINTER_ROLE();
  await cyrdToken.grantRole(MINTER_ROLE, redemptionAddress);
  console.log("Granted MINTER_ROLE to redemption contract");
  
  // Mint initial supply to treasury (optional)
  const initialSupply = hre.ethers.parseUnits("1000000", 6); // 1M CYRD
  console.log("Minting initial supply to redemption treasury...");
  await cyrdToken.mint(redemptionAddress, initialSupply);
  console.log("Minted", hre.ethers.formatUnits(initialSupply, 6), "CYRD to treasury");
  
  // Save deployment info
  const deploymentInfo = {
    network: hre.network.name,
    chainId: hre.network.config.chainId,
    deployer: deployer.address,
    contracts: {
      CypherRelayDollar: cyrdAddress,
      CypherRedemption: redemptionAddress
    },
    timestamp: new Date().toISOString()
  };
  
  console.log("\nDeployment Summary:");
  console.log(JSON.stringify(deploymentInfo, null, 2));
  
  // Write deployment info to file
  const fs = require("fs");
  const path = require("path");
  const deploymentsDir = path.join(__dirname, "../deployments");
  
  if (!fs.existsSync(deploymentsDir)) {
    fs.mkdirSync(deploymentsDir);
  }
  
  fs.writeFileSync(
    path.join(deploymentsDir, `${hre.network.name}.json`),
    JSON.stringify(deploymentInfo, null, 2)
  );
  
  console.log("\nDeployment complete!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });