const { expect } = require("chai");
const { ethers } = require("hardhat");
const { deployContract } = require('./helpers');

// npx hardhat test test/polly-test.js
context("PollyMorph", function() {
  beforeEach(async function() {
	  const [ owner, addr1, addr2, addr3 ] = await ethers.getSigners();

    this.pollyUri = "https://gateway.pinata.cloud/ipfs/QmXYQu6dwcDqiMGeZuz815dHYE4WkUS8EKME8ycn8EEdA6/";
    this.pollyContract = await deployContract("Polly", [ this.pollyUri ]);

    this.fusionContract = await deployContract("Fusion", [ this.pollyContract.address ]);
    this.wallet         = owner.address;
    this.tokensOwned    = [0, 1, 2, 4, 6];
    this.wallets        = [owner, addr1, addr2, addr3];
    this.serverSigner   = addr1;

    await this.fusionContract.setSigner(this.serverSigner.address);
    this.signUriChange = async(wallet, tokens, uri) => {
      const message   = [wallet, tokens, uri];
      const hash      = ethers.utils.solidityKeccak256(["address", "uint[]", "string"], message);
      const binary    = ethers.utils.arrayify(hash);
      const signature = await this.serverSigner.signMessage(binary);

      return {
        tokens,
        uri,
        signature
      }
    }
  });

  context("Polly contract", async function() {
    it("Correct URI", async function() {
      const uri = await this.pollyContract.uri(2);
      expect(uri).to.equal(this.pollyUri + '2');

      await expect(this.pollyContract.uri(10)).to.be.revertedWith("Nonexistent token");
    });
  });

  context("Fusion contract", async function() {
    it("Verify canChangeUri modifier: Has correct calldata", async function() {
      const { tokens, uri, signature } = await this.signUriChange(this.wallet, [1,2,4,6], "test.com/1");

      await expect(this.fusionContract.wrap(tokens, "t.com/1", signature)).to.be.revertedWith("Not approved URI");
      await expect(this.fusionContract.wrap([3,4,5], uri, signature)).to.be.revertedWith("Not approved URI");
    });

    it("Verify canChangeUri modifier: Need to own the token", async function() {
      const { tokens, uri, signature } = await this.signUriChange(this.wallet, [1,2,3,4], "t.com/1");

      await expect(this.fusionContract.wrap(tokens, uri, signature)).to.be.revertedWith(`Do not own token id: 3`);
    });
  });
});