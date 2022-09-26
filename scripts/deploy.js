const hre = require('hardhat');
const { mkdirSync, writeFileSync } = require('fs');
const { createAbiJSON } = require('../utils');

async function deploy(name, ...params) {
	const Contract = await hre.ethers.getContractFactory(name);
	return await Contract.deploy(...params).then((con) => {
		createAbiJSON(con, name);
		return con.deployed();
	});
}

async function main() {
	mkdirSync('abi', { recursive: true });
	// const forwarder = await deploy('Forwarder');
	// let reciept = await forwarder.deployTransaction.wait();
	// createAbiJSON(forwarder, 'Forwarder');

	const simpleForwarder = await deploy('SimpleForwarder');
	reciept = await simpleForwarder.deployTransaction.wait();

	// const registry = await deploy('Registry', forwarder.address);
	// reciept = await registry.deployTransaction.wait();
	// createAbiJSON(registry, 'Registry');
	// console.log(`Forwarder: ${forwarder.address}\nRegistry: ${registry.address}`);

	const paymentManager = await deploy('PaymentManager', simpleForwarder.address);
	reciept = await paymentManager.deployTransaction.wait();
	console.log(`simpleForwarder: ${simpleForwarder.address}\n paymentManager: ${paymentManager.address}`);

	// const token = await deploy('Token');
	// reciept = await token.deployTransaction.wait();
	// createAbiJSON(token, 'Token');
	// console.log(`Forwarder: ${forwarder.address}\ntoken: ${token.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
	main()
		.then(() => process.exit(0))
		.catch((error) => {
			console.error(error);
			process.exit(1);
		});
}

module.exports = {
	deploy,
};
