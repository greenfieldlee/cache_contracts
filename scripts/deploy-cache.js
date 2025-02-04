// scripts/deploy.js

const hre = require("hardhat");

async function main() {
  const { ethers } = hre;

  // 1. Get signer using ethers.getSigners()
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  // 2. Correctly get & format the deployer's balance
  const beforeBalance = await deployer.provider.getBalance(deployer.address);

  // const routerAddress = "0x4752ba5dbc23f44d87826276bf6fd6b1c372ad24"; // Base network
  const routerAddress = "0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3"; // BSC Test network
  const adminAddress = "0x852e87FB66b380Ea9aA8D70A96CdC0db15C15339";
  
  console.log(
    "Account balance (ETH):",
    ethers.formatUnits(beforeBalance)
  );

  // 3. Dynamically fetch the current gas price
  const {gasPrice} = await ethers.provider.getFeeData();
  console.log(
    "Current Gas Price (Gwei):",
    ethers.formatUnits(gasPrice, "gwei")
  );

  // 4. Load the contract factory
  const CACHE = await ethers.getContractFactory("CACHE");
  console.log("Initializing contract deployment...");

  // 5. Deploy with constructor arguments + custom gasPrice
  //    (BSC Testnet Router + Some other address as an example)
  const contractInstance = await CACHE.deploy(
    routerAddress, 
    adminAddress, 
    { gasPrice }
  );

  console.log("Deploying...");
  await contractInstance.waitForDeployment();

  console.log("=== Contract Deployed Successfully ===");
  console.log("Contract Address:", contractInstance.target);

  // 6. Check consumed balance
  const afterBalance = await deployer.provider.getBalance(deployer.address);
  console.log(
    "Total Consumed balance (ETH):",
    ethers.formatEther(beforeBalance - afterBalance)
  );

  // 7. Verify the contract on BscScan (or Etherscan) with retries
  console.log("Verifying on BscScan...");
  await verifyContractWithRetries(contractInstance.target, [
    routerAddress,
    adminAddress
  ]);
}

async function verifyContractWithRetries(
  address,
  constructorArguments,
  maxRetries = 5,
  delayMs = 5000
) {
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      console.log(`Verification attempt ${attempt + 1}...`);
      await hre.run("verify:verify", {
        address,
        constructorArguments,
      });
      console.log("✅ Contract verified successfully!");
      return;
    } catch (error) {
      console.error(`Verification failed on attempt ${attempt + 1}:`, error.message);

      if (attempt === maxRetries - 1) {
        console.error("❌ Max retries reached. Verification failed.");
        return;
      }

      console.log(`Retrying in ${delayMs / 1000} seconds...`);
      await new Promise((resolve) => setTimeout(resolve, delayMs));
    }
  }
}

// Execute the deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("🚨 Error deploying contract:", error.message);
    process.exit(1);
  });
