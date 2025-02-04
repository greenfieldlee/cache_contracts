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

  /*
   // Deploy EntryPoint
   const EntryPoint = await hre.ethers.getContractFactory("EntryPoint");
   const entryPoint = await EntryPoint.deploy({
    gasPrice: gasPrice, // Dynamically set gas price
  });
   await entryPoint.deployed();
   console.log("EntryPoint deployed to:", entryPoint.address);
 */
   // Deploy AccountFactory
   const AccountFactory = await hre.ethers.getContractFactory("AccountFactory");
   const accountFactory = await AccountFactory.deploy("0x219267370d3ea36d1079cA054354C1456b22752A", {
    gasPrice: gasPrice, // Dynamically set gas price
  });
   await accountFactory.deployed();
   console.log("AccountFactory deployed to:", accountFactory.address);

   // Deploy SmartWallet
   const SmartWallet = await hre.ethers.getContractFactory("SmartWallet");
   const smartWallet = await SmartWallet.deploy("0x219267370d3ea36d1079cA054354C1456b22752A", {
    gasPrice: gasPrice, // Dynamically set gas price
  });
   await smartWallet.deployed();
   console.log("SmartWallet deployed to:", smartWallet.address);

  console.log(" === Contract Deployed Successfully === ");

  const afterBalance = await deployer.getBalance();
  console.log(
    "Total Consumed balance:",
    ((beforeBalance - afterBalance) / 10 ** 18).toFixed(2).toString()
  );

  console.log("Verifying on Etherscan...");

  try {
    // await verifyContractWithRetries(entryPoint.address, []);
    await verifyContractWithRetries(accountFactory.address, ["0x219267370d3ea36d1079cA054354C1456b22752A"]);
    await verifyContractWithRetries(smartWallet.address, ["0x219267370d3ea36d1079cA054354C1456b22752A"]);
  } catch (error) {
    console.error("Contract verification ultimately failed:", error.message);
  }  
}

async function verifyContractWithRetries(address, constructorArguments, maxRetries = 5, delayMs = 5000) {
  let attempt = 0;

  while (attempt < maxRetries) {
    try {
      // console.log(`Verification attempt ${attempt + 1}...`);
      await hre.run("verify:verify", {
        address: address,
        constructorArguments: constructorArguments,
      });
      console.log("Contract verified successfully!");
      return; // Exit the loop if verification is successful
    } catch (error) {
      // console.error(`Verification failed on attempt ${attempt + 1}:`, error.message);

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
