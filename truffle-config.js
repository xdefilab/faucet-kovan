
module.exports = {
    networks: {
        development: {
            host: 'localhost', // Localhost (default: none)
            port: 8545, // Standard Ethereum port (default: none)
            network_id: '*', // Any network (default: none)
            gas: 5800000,
            timeoutBlocks: 200,
        }
    },
    // Configure your compilers
    compilers: {
        solc: {
            version: '0.5.17',
            settings: { // See the solidity docs for advice about optimization and evmVersion
                optimizer: {
                    enabled: true,
                    runs: 200,
                }
            },
        },
    },
};