const hre         = require("hardhat");
const ethers      = hre.ethers;

// npx hardhat run --network rinkeby scripts/sa-deploy.js
async function main() {
    const Contract = await ethers.getContractFactory("BaseModel");
    const contract = await Contract.deploy("https://testing.com");

    await contract.deployed();
    console.log("Contract deployed to:", contract.address);

    // const contract = await deploy("BaseModel", "0x0109492Ee14ACD69Cb15cc2E13d96829d7bba73A", ["https://testing.com"], true);
    // TESTING PURPOSES below
    // const timestamp = await getBlockTimestamp();
    // console.log(`Setting timestamp to: ${timestamp}`);
    // const tx = await contract.setAuctionStart(timestamp);
    // await tx.wait(2);
    // console.log('Mint from dutch');
    // const price = await contract.getAuctionPrice();
    // await contract.dutchMint(3, { value: price.mul(3), gasLimit: 120000 });
    // console.log('Withdraw funds spent');
    // await contract.withdrawAll({ gasLimit: 120000 });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});