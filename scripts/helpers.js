const hre    = require("hardhat");
const ethers = hre.ethers;

const sleep = (ms) => {
	return new Promise(resolve => setTimeout(resolve, ms));
}

const gwei = (gwei_amount) => {
	return gwei_amount * 1000000000;
}

const waitForGasPrice = (target_gwei, deployer, above_gwei = null) => {
	return new Promise(async (resolve) => {
		let current_gas;

		while(true) {
			const bn_gas = await deployer.getGasPrice();
			const gas_price = bn_gas.toNumber();

			console.log(`Gas price found: ${ethers.utils.formatUnits(gas_price, 'gwei')} GWEI`);
			current_gas = gas_price;

			if(gwei(target_gwei) > gas_price) {
				if(above_gwei == null || gwei(above_gwei) <= gas_price) {
					break;
				}
			}

			await sleep(5000);
		}

		if(current_gas < gwei(30)) {
			current_gas = gwei(35);
		} else if(current_gas < 20) {
			current_gas = gwei(20);
		}

		resolve(current_gas);
	});
}

const deploy = async (contractName, deployAs, deployArgs = [], verify = true) => {
	const [ deployer ]  = await ethers.getSigners();
	const deployer_addr = await deployer.getAddress();

	if(deployer_addr != deployAs) {
		console.log('Something went wrong. The deployer addr is not correct.');
		return;
	}

	console.log(`*** Set deployer addr: ${deployer_addr}`);

	const Factory = await ethers.getContractFactory(contractName, hre);

	console.log('*** Deploying contract');
	const contract = await Factory.deploy(...deployArgs);
	const { deployTransaction: creation_tx } = await contract.deployed();
	console.log("Contract contract deployed to:", contract.address);

	if(verify) {
		// Wait for 5 confirmations
		console.log('Wait for 5 confirmations');
		await creation_tx.wait(5);
		console.log('5 confirmations have been made.');

		// Verify contract
		try {
			console.log('Starting verification');
			await hre.run('verify:verify', {
				address: contract.address,
				constructorArguments: deployArgs
			});
		} catch(err) {
			console.log(`Error verifying: ${err.message}`);
		}
	}

	return contract;
}

module.exports = {
	sleep,
	gwei,
	waitForGasPrice,
	deploy
}