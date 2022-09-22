const { time, loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { anyValue } = require('@nomicfoundation/hardhat-chai-matchers/withArgs');
const { expect } = require('chai');
const { deploy } = require('../scripts/deploy');
const { signTypedData, getMetaTxTypeData } = require('../utils');
const { writeFileSync } = require('fs');

describe('Registry', function () {
	// We define a fixture to reuse the same setup in every test.
	// We use loadFixture to run this setup once, snapshot that state,
	// and reset Hardhat Network to that snapshot in every test.
	async function deployOneYearLockFixture() {
		// Contracts are deployed using the first signer/account by default
		const [owner, signer, relay] = await ethers.getSigners();
		const forwarder = await deploy('Forwarder');
		let reciept = await forwarder.deployTransaction.wait();

		const registry = await deploy('Registry', forwarder.address);
		reciept = await registry.deployTransaction.wait();

		return { owner, signer, relay, forwarder, registry };
	}
	it('Should sign Transaction with Account[0]', async function () {
		const { signer, forwarder, registry } = await loadFixture(deployOneYearLockFixture);
		const message = 'Hello World!';

		const data = registry.interface.encodeFunctionData('register', [message]);
		const gas = await registry.estimateGas.register(message).then((gas) => gas.toString());
		const nonce = await forwarder.getNonce(signer.address).then((nonce) => nonce.toString());

		const chainId = await forwarder.provider.getNetwork().then((n) => n.chainId);
		const typeData = getMetaTxTypeData(chainId, forwarder.address);
		const request = {
			from: signer.address,
			to: registry.address,
			value: 0,
			gas,
			nonce,
			data,
		};
		const toSign = {
			...typeData,
			message: request,
		};
		const signature = await signTypedData(signer.provider._hardhatProvider, signer.address, toSign);

		writeFileSync(
			'request.json',
			JSON.stringify(
				{
					signature,
					request,
				},
				null,
				2
			)
		);

		expect(require('../request.json').signature).to.equal(signature);
		expect(JSON.stringify(require('../request.json').request)).to.equal(JSON.stringify(request));
	});
	it('Should verify Signed transaction', async () => {
		const { forwarder } = await loadFixture(deployOneYearLockFixture);
		const request = require('../request.json');

		const verify = await forwarder.verify(request.request, request.signature);
		expect(verify).to.true;
	});
	it('Should execute signed transaction', async () => {
		const { signer, relay, forwarder, registry } = await loadFixture(deployOneYearLockFixture);
		const request = require('../request.json');
		const message = 'Hello World!';

		const forwarderWithRelay = forwarder.connect(relay);
		const tx = await forwarderWithRelay.execute(request.request, request.signature);
		await tx.wait();

		expect(await registry.owners(message)).to.equal(signer.address);
	});
});
