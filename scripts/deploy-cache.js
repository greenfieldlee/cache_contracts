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

  // Load the contract factory
  const CACHE = await hre.ethers.getContractFactory("CACHE");

  console.log("Initializing contract deployment...");
  // Deploy the contract with the constructor argument
  const contractInstance = await CACHE.deploy("0x9ac64cc6e4415144c455bd8e4837fea55603e5c3");
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
    await hre.run("verify:verify", {
      address: contractInstance.address,
      constructorArguments: ["0x9ac64cc6e4415144c455bd8e4837fea55603e5c3"],
    });
    console.log("Contract verified successfully!");
  } catch (error) {
    console.error("Verification failed:", error.message);
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
