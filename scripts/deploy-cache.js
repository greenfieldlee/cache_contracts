// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);

  const beforeBalance = await deployer.getBalance();
  console.log(
    "Account balance:",
    (beforeBalance / 10 ** 18).toFixed(2).toString()
  );

  // Fetch the current gas price dynamically
  const gasPrice = await hre.ethers.provider.getGasPrice();
  console.log("Current Gas Price (in gwei):", hre.ethers.utils.formatUnits(gasPrice, "gwei"));

  // Load the contract factory
  const CACHE = await hre.ethers.getContractFactory("CACHE");

  console.log("Initializing contract deployment...");
  // Deploy the contract with the constructor argument
  const contractInstance = await CACHE.deploy("0x4752ba5dbc23f44d87826276bf6fd6b1c372ad24", {
    gasPrice: gasPrice, // Dynamically set gas price
  });
  console.log("Deploying...");

  // Wait until deployment is completed
  await contractInstance.deployed();

  console.log(" === Contract Deployed Successfully === ");
  console.log("Contract Address:", contractInstance.address);

  const afterBalance = await deployer.getBalance();
  console.log(
    "Total Consumed balance:",
    ((beforeBalance - afterBalance) / 10 ** 18).toFixed(2).toString()
  );

  console.log("Verifying on Etherscan...");
  try {
    await verifyContractWithRetries(contractInstance.address, ["0x4752ba5dbc23f44d87826276bf6fd6b1c372ad24"]);
  } catch (error) {
    console.error("Contract verification ultimately failed:", error.message);
  }  
}

async function verifyContractWithRetries(address, constructorArguments, maxRetries = 5, delayMs = 5000) {
  let attempt = 0;

  while (attempt < maxRetries) {
    try {
      console.log(`Verification attempt ${attempt + 1}...`);
      await hre.run("verify:verify", {
        address: address,
        constructorArguments: constructorArguments,
      });
      console.log("Contract verified successfully!");
      return; // Exit the loop if verification is successful
    } catch (error) {
      console.error(`Verification failed on attempt ${attempt + 1}:`, error.message);

      if (attempt === maxRetries - 1) {
        console.error("Max retries reached. Verification failed.");
        break;
      }

      console.log(`Retrying in ${delayMs / 1000} seconds...`);
      await new Promise((resolve) => setTimeout(resolve, delayMs)); // Wait before retrying
      attempt++;
    }
  }
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Error deploying contract:", error.message);
    process.exit(1);
  });
