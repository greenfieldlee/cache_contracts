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

  // const Presale = await ethers.getContractFactory("Presale");
  // console.log("Init ....... ");
  // const contract = await Presale.deploy("0x0731B8B7f1Fc7288427B8965F07905B4194fc2ac", "0x5747a7f258Bd38908A551CE6d76b8C2A428D7586", 50);
  // console.log("Deploying...");
  // const contractAddr = await contract.deployed();
  // console.log(" === Deployed Address === ");
  // console.log(contractAddr.address);

  console.log("Verifying...");
  await hre.run("verify:verify", {
    // address: contractAddr.address,
    address: "0xF81d3f184d171caFD187684cd88E7dd986E38b1f",
    constructorArguments: ["0x0731B8B7f1Fc7288427B8965F07905B4194fc2ac", "0x5747a7f258Bd38908A551CE6d76b8C2A428D7586", 50],
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
