const { expect } = require("chai");
const { utils, constants } = require("ethers");

describe("FlashLoanNFT contract", function () {
  let flashLoanNFT;
  let flashLoanFacilitator;
  let nftContract;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function () {
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();

    const FlashLoanNFT = await ethers.getContractFactory("FlashLoanNFT");
    flashLoanNFT = await FlashLoanNFT.deploy();
    await flashLoanNFT.deployed();

    const FlashLoanFacilitator = await ethers.getContractFactory(
      "NFTWithRedeemableFlashLoanFacilitator"
    );
    flashLoanFacilitator = await FlashLoanFacilitator.deploy();
    await flashLoanFacilitator.deployed();

    const NFTWithRedeemable = await ethers.getContractFactory(
      "NFTWithRedeemable"
    );
    nftContract = await NFTWithRedeemable.deploy();
    await nftContract.deployed();

    // premint a nft for test
    await nftContract.safeMint(owner.address, 0);

    // setApprovalForAll for addresses
    await nftContract.setApprovalForAll(flashLoanNFT.address, true);
    await nftContract
        .connect(addr1)
        .setApprovalForAll(flashLoanFacilitator.address, true);
  });

  it("Should approve for flashloan", async function () {
    await flashLoanNFT.approveForFlashLoans(
      nftContract.address,
      0,
      utils.parseEther("0.01")
    );
    expect(
      await nftContract.isApprovedForAll(owner.address, flashLoanNFT.address)
    ).to.equal(true);
    expect(
      await flashLoanNFT.getPremiumForToken(nftContract.address, 0)
    ).to.equal(utils.parseEther("0.01"));
  });

  it("Should do a flashloan", async function () {
    await flashLoanNFT.approveForFlashLoans(
      nftContract.address,
      0,
      utils.parseEther("0.01")
    );

    expect(await nftContract.ticketOwner(0)).to.equal(constants.AddressZero);
    expect(await nftContract.ownerOf(0)).to.equal(owner.address);

    await flashLoanNFT
      .connect(addr1)
      .flashLoan(flashLoanFacilitator.address, nftContract.address, 0, [], {
        value: utils.parseEther("0.01"),
      });

    expect(await nftContract.ticketOwner(0)).to.equal(addr1.address);
    expect(await nftContract.ownerOf(0)).to.equal(owner.address);
  });

  it("Should reject flashloan after revokeFromFlashLoans", async function () {
    await flashLoanNFT.approveForFlashLoans(
        nftContract.address,
        0,
        utils.parseEther("0.01")
    );
    await flashLoanNFT.revokeFromFlashLoans(
        nftContract.address,
        0
    );
    await expect(flashLoanNFT
        .connect(addr1)
        .flashLoan(flashLoanFacilitator.address, nftContract.address, 0, [], {
          value: utils.parseEther("0.05"),
        })
    ).to.be.revertedWith("Token not approved for flashloan");
  });


  it("Should reject unapproved flashloan", async function () {
    await nftContract.setApprovalForAll(flashLoanNFT.address, false);

    await expect(flashLoanNFT
        .connect(addr1)
        .flashLoan(flashLoanFacilitator.address, nftContract.address, 0, [], {
          value: utils.parseEther("0.05"),
        })
    ).to.be.revertedWith("Owner has not approved contract's setApprovedForAll");
  });

  it("Should reject insufficient premium when flashloaning", async function () {
    await nftContract.setApprovalForAll(flashLoanNFT.address, true);

    await nftContract
        .connect(addr1)
        .setApprovalForAll(flashLoanFacilitator.address, true);

    await flashLoanNFT.approveForFlashLoans(
        nftContract.address,
        0,
        utils.parseEther("0.01")
    );

    await expect(flashLoanNFT
        .connect(addr1)
        .flashLoan(flashLoanFacilitator.address, nftContract.address, 0, [], {
          value: utils.parseEther("0.001"),
        })
    ).to.be.revertedWith("Not enough premium sent");
  });
});
