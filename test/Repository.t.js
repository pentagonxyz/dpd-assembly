const { expect } = require("chai");
const { assert } = require("console");
const { Interface } = require("ethers/lib/utils");
const { ethers } = require("hardhat");

let repository;

describe("Greeter", function () {
  beforeEach(async function () {
    const Repository = await ethers.getContractFactory("DPDRepository");
    repository = await Repository.deploy();
    await repository.deployed();
  });
  it("Add DPD works", async function () {
    await repository.addDpd(
      "0x6009",
      "0x8733593b6418be9A0CCDEF9BbB8C0CC4E7bE88aC",
      "0x8733593b6418be9A0CCDEF9BbB8C0CC4E7bE88aC"
    );

    console.log(await repository.dpds(0));

    console.log("gas", (await ethers.provider.getBlock()).gasUsed);
  });
});
