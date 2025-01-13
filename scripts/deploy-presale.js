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

  // const IncomePresale = await ethers.getContractFactory("IncomePresale");
  // console.log("Init ....... ");
  // const contract = await IncomePresale.deploy();
  // console.log("Deploying...");
  // const contractAddr = await contract.deployed();
  // console.log(" === Deployed Address === ");
  // console.log(contractAddr.address);

  console.log("Verifying...");
  await hre.run("verify:verify", {
    address: "0xAA572dEacBe458B2f7A91BC2ffB12D385e6eE815",
    constructorArguments: [],
  });

  const afterBalance = await deployer.getBalance();
  console.log(
    "Total Consumed balance:",
    ((beforeBalance - afterBalance) / 10 ** 18).toFixed(2).toString()
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("error", error);
    process.exit(1);
  });
