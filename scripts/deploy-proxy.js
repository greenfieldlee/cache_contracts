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

  const IncomePreSaleProxy = await ethers.getContractFactory(
    "IncomePreSaleProxy"
  );
  console.log("Init ....... ");
  const contract = await IncomePreSaleProxy.deploy(
    "0x1fa3c4d24464e0a8c5a4ae50fb3f400909139faa"
  );
  console.log("Deploying...");
  const contractAddr = await contract.deployed();
  console.log(" === Deployed Address === ");
  console.log(contractAddr.address);

  const afterBalance = await deployer.getBalance();
  console.log(
    "Total Consumed balance:",
    ((beforeBalance - afterBalance) / 10 ** 18).toFixed(2).toString()
  );

  console.log("Verifying...");
  await hre.run("verify:verify", {
    address: contractAddr.address,
    constructorArguments: ["0x1fa3c4d24464e0a8c5a4ae50fb3f400909139faa"],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("error", error);
    process.exit(1);
  });
