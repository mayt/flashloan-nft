task("deploy", "Deploy the contract").setAction(
  async (_, { ethers, network, run }) => {
    // This is just a convenience check
    if (network.name === "hardhat") {
      console.warn(
        "You are trying to deploy a contract to the Hardhat Network, which" +
          "gets automatically created and destroyed every time. Use the Hardhat" +
          " option '--network localhost'"
      );
    }

    await run("compile");

    // ethers is available in the global scope
    const [deployer] = await ethers.getSigners();
    console.log(
      "Deploying the contracts with the account:",
      await deployer.getAddress()
    );

    console.log("Account balance:", (await deployer.getBalance()).toString());

    const FlashLoanNFT = await ethers.getContractFactory("FlashLoanNFT");
    const flashLoanNFT = await FlashLoanNFT.deploy();
    await flashLoanNFT.deployed();

    console.log("FlashLoanNFT address:", flashLoanNFT.address);
  }
);
