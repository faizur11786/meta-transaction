const { existsSync, readFileSync, writeFileSync } = require('fs');
const ethSigUtil = require('eth-sig-util');

function createAbiJSON(artifact, filename) {
	const data = JSON.parse(artifact.interface.format('json'));
	const object = {
		abi: data,
		address: artifact.address,
		blockNumber: artifact.deployTransaction.blockNumber,
	};
	writeFileSync(`${__dirname}/../abi/${filename}.json`, JSON.stringify(object));
}

const EIP712Domain = [
	{ name: 'name', type: 'string' },
	{ name: 'version', type: 'string' },
	{ name: 'chainId', type: 'uint256' },
	{ name: 'verifyingContract', type: 'address' },
];

const ForwardRequest = [
	{ name: 'from', type: 'address' },
	{ name: 'to', type: 'address' },
	{ name: 'value', type: 'uint256' },
	{ name: 'gas', type: 'uint256' },
	{ name: 'nonce', type: 'uint256' },
	{ name: 'data', type: 'bytes' },
];

function getMetaTxTypeData(chainId, verifyingContract) {
	return {
		types: {
			EIP712Domain,
			ForwardRequest,
		},
		domain: {
			name: 'Forwarder',
			version: '1',
			chainId,
			verifyingContract,
		},
		primaryType: 'ForwardRequest',
	};
}

async function signTypedData(signer, from, data) {
	// If signer is a private key, use it to sign
	if (typeof signer === 'string') {
		const privateKey = Buffer.from(signer.replace(/^0x/, ''), 'hex');
		return ethSigUtil.signTypedMessage(privateKey, { data });
	}

	// // Otherwise, send the signTypedData RPC call
	// // Note that hardhatvm and metamask require different EIP712 input
	const isHardhat = data.domain.chainId == 31337;
	const [method, argData] = isHardhat ? ['eth_signTypedData', data] : ['eth_signTypedData_v4', JSON.stringify(data)];
	return await signer.send(method, [from, argData]);
}

module.exports = {
	createAbiJSON,
	EIP712Domain,
	ForwardRequest,
	getMetaTxTypeData,
	signTypedData,
};
