const { expect } = require("chai");
const { ethers } = require("hardhat");

const CrowpadSimpleTokenFactory = ethers.getContractFactory(
  "CrowpadSimpleTokenFactory"
);
const CrowpadTokenFactory = ethers.getContractFactory("CrowpadTokenFactory");
const CrowpadAirdropper = ethers.getContractFactory("CrowpadAirdropper");
const CronosToken = ethers.getContractFactory("CronosToken");
const CrowpadFlexTierStakingContract = ethers.getContractFactory(
  "CrowpadFlexTierStakingContract"
);
const CrowpadBronzeTierStakingContract = ethers.getContractFactory(
  "CrowpadBronzeTierStakingContract"
);
const CrowpadSilverTierStakingContract = ethers.getContractFactory(
  "CrowpadSilverTierStakingContract"
);
const CrowpadGoldTierStakingContract = ethers.getContractFactory(
  "CrowpadGoldTierStakingContract"
);

const CrowpadSimpleTokenFactoryAddress =
  "0x5FC8d32690cc91D4c39d9d3abcBD16989F875707";
const CrowpadTokenFactoryAddress = "0x0165878A594ca255338adfa4d48449f69242Eb8F";
const CrowpadAirdropperAddress = "0xa513E6E4b8f2a923D98304ec87F64353C4D5C853";
const CrowpadFlexTierStakingContractAddress =
  "0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6";
const CrowpadBronzeTierStakingContractAddress =
  "0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6";
const CrowpadSilverTierStakingContractAddress =
  "0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6";
const CrowpadGoldTierStakingContractAddress =
  "0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6";

let owner;

describe("CrowpadSimpleTokenFactory", function () {
  let crowpadSimpleTokenFactory;
  beforeEach(async function () {
    crowpadSimpleTokenFactory = await (
      await CrowpadSimpleTokenFactory
    ).attach(CrowpadSimpleTokenFactoryAddress);
    [owner] = await ethers.getSigners();
  });
  it("should set its deploy fee on cronos", async () => {
    await crowpadSimpleTokenFactory.setDeployFee(
      ethers.utils.parseEther("0.02")
    );
    expect(await crowpadSimpleTokenFactory.deployFee()).equal(
      ethers.utils.parseEther("0.02")
    );
  });

  it("should deploy a new token on cronos", async () => {
    await crowpadSimpleTokenFactory.deployNewInstance(
      "STEED TOKEN",
      "STEED",
      6,
      100000000000,
      "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
      owner.address,
      {
        from: owner.address,
        value: ethers.utils.parseEther("0.8"),
      }
    );
  });
});

describe("CrowpadTokenFactory", function () {
  let crowpadTokenFactory;
  beforeEach(async function () {
    crowpadTokenFactory = await (
      await CrowpadTokenFactory
    ).attach(CrowpadTokenFactoryAddress);
    [owner] = await ethers.getSigners();
  });
  it("should set its deploy fee on cronos", async () => {
    await crowpadTokenFactory.setDeployFee(ethers.utils.parseEther("0.5"));
    expect(await crowpadTokenFactory.deployFee()).equal(
      ethers.utils.parseEther("0.5")
    );
  });

  it("should deploy a new token on cronos", async () => {
    await crowpadTokenFactory.deployNewInstance(
      "STEED TOKEN",
      "STEED",
      6,
      100000000000,
      10,
      10,
      60,
      "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D",
      owner.address,
      owner.address,
      {
        from: owner.address,
        value: ethers.utils.parseEther("0.8"),
      }
    );
  });
});

describe("CrowpadAirdropper", function () {
  let crowpadAirdropper, cronosToken;
  beforeEach(async function () {
    crowpadAirdropper = (await CrowpadAirdropper).attach(
      CrowpadAirdropperAddress
    );
    cronosToken = (await CronosToken).deploy();
    [owner] = await ethers.getSigners();
  });
  it("should check airdrop validity", async () => {
    await crowpadAirdropper.checkAirdropValidity(
      cronosToken.address,
      [
        "0x70997970c51812dc3a010c7d01b50e0d17dc79c8",
        "0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc",
      ],
      [1000000, 200000]
    );
  });
  it("should do airdrop", async () => {
    await crowpadAirdropper.airdropToken(
      cronosToken.address,
      [
        "0x70997970c51812dc3a010c7d01b50e0d17dc79c8",
        "0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc",
      ],
      [1000000, 200000]
    );
    expect(
      cronosToken.balanceOf("0x70997970c51812dc3a010c7d01b50e0d17dc79c8")
    ).equal(1000000);
    expect(
      cronosToken.balanceOf("0x3c44cdddb6a900fa2b585dd299e03d12fa4293bc")
    ).equal(1000000);
  });
  describe("CrowpadFlexTierStakingContract", function () {
    let crowpadFlexTierStakingContract;
    beforeEach(async function () {
      crowpadFlexTierStakingContract = (
        await CrowpadFlexTierStakingContract
      ).attach(CrowpadFlexTierStakingContractAddress);
    });
    it("should stake liquidity", async () => {
      await crowpadFlexTierStakingContract.updateTime(
        0,
        new Date(Date.now() + 100000).valueOf()
      );
      await crowpadFlexTierStakingContract.setDepositor(owner.address);
      await crowpadFlexTierStakingContract.stake(owner.address, 10000);
    });
  });
  describe("CrowpadBronzeTierStakingContract", function () {
    let crowpadBronzeTierStakingContract;
    beforeEach(async function () {
      crowpadBronzeTierStakingContract = (
        await CrowpadBronzeTierStakingContract
      ).attach(CrowpadBronzeTierStakingContractAddress);
    });
    it("should stake liquidity", async () => {
      await crowpadBronzeTierStakingContract.updateTime(
        0,
        new Date(Date.now() + 100000).valueOf()
      );
      await crowpadBronzeTierStakingContract.setDepositor(owner.address);
      await crowpadBronzeTierStakingContract.stake(owner.address, 10000);
    });
  });
  describe("CrowpadSilverTierStakingContract", function () {
    let crowpadSilverTierStakingContract;
    beforeEach(async function () {
      crowpadSilverTierStakingContract = (
        await CrowpadSilverTierStakingContract
      ).attach(CrowpadSilverTierStakingContractAddress);
    });
    it("should stake liquidity", async () => {
      await crowpadSilverTierStakingContract.updateTime(
        0,
        new Date(Date.now() + 100000).valueOf()
      );
      await crowpadSilverTierStakingContract.setDepositor(owner.address);
      await crowpadSilverTierStakingContract.stake(owner.address, 10000);
    });
  });
  describe("CrowpadGoldTierStakingContract", function () {
    let crowpadGoldTierStakingContract;
    beforeEach(async function () {
      crowpadBronzeTierStakingContract = (
        await CrowpadGoldTierStakingContract
      ).attach(CrowpadGoldTierStakingContractAddress);
    });
    it("should stake liquidity", async () => {
      await crowpadGoldTierStakingContract.updateTime(
        0,
        new Date(Date.now() + 100000).valueOf()
      );
      await crowpadGoldTierStakingContract.setDepositor(owner.address);
      await crowpadGoldTierStakingContract.stake(owner.address, 10000);
    });
  });
});
