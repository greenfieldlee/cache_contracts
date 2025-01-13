const { ethers } = require("hardhat");
const hre = require("hardhat");

describe("Deploy Income token", function () {
  it("Should Deploy", async function () {
    const [deployer] = await hre.ethers.getSigners();
    const Lib = await ethers.getContractFactory("IterableMapping");
    const lib = await Lib.deploy();
    const Income = await ethers.getContractFactory("INCOME", {
      signer: deployer,
      libraries: {
        IterableMapping: lib.address,
      },
    });
    const income = await Income.deploy();
    await income.deployed();
    await income.connect(deployer).setMaxPerWalletPercent(2);
  });
});
