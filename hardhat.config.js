require('dotenv').config();

require('@nomicfoundation/hardhat-toolbox');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
	solidity: {
		version: '0.8.9',
		settings: {
			optimizer: {
				enabled: true,
				runs: 200,
			},
		},
	},
	networks: {
		hardhat: {
			forking: {
				url: 'https://nd-240-117-310.p2pify.com/83ce4985408b1cfb834635c52c5ead03',
			},
			chainId: 1337,
		},
		matic: {
			url: 'https://matic-mumbai.chainstacklabs.com',
			accounts: [process.env.PRIVATE_KEY],
			chainId: 80001,
		},
	},
};
