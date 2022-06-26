const hre         = require("hardhat");
const ethers      = hre.ethers;
const { deploy }  = require('./helpers');

// npx hardhat run --network matic scripts/deploy.js
async function main() {
    const pollyContract = await deploy("Polly", "0x763378cCf967EB8d54367484eA92056c0677b0D2", ["https://divineanarchy.mypinata.cloud/ipfs/QmPgoaegWhiR6WiuWcbNqiUVziMKSUMhpZa4jVqSmL47rA/"], true);

    const fusionContract = await deploy("Fusion", "0x763378cCf967EB8d54367484eA92056c0677b0D2", [
      pollyContract.address, "0x2e8DcDE53a25351B76C1b7cb91a6d89A471D22B8"
    ], true);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});