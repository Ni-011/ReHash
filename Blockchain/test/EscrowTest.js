const { expect } = require("chai");
const { ethers } = require("hardhat");

const token = (n) => {
  return ethers.utils.parseUnits(n.toString(), "ether");
};

describe("Escrow", () => {
  it("saves the address", async () => {
    try {
      // get the contract
      const productsContract = await ethers.getContractFactory("products");
    } catch (err) {
      console.log("Failed to get the Contract using ethers:", err);
    }
    try {
      // deploy it
      productsContractDeployed = await productsContract.deploy();
      // wait for deployment
      await productsContractDeployed.waitForDeployment();
    } catch (err) {
      console.log("Failed to deploy:", err);
    }
  });
});
