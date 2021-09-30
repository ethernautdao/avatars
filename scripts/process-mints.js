const path = require('path');

const { getContractAt } = require('../src/utils/hardhat');
const IPFS = require('../src/ipfs');
const config = require('../src/config');
const constants = require('../src/constants');

async function main() {
  const ipfs = new IPFS({
    pinningService: {
      name: config.PINNING_SERVICE_NAME,
      key: config.PINNING_SERVICE_KEY,
      endpoint: config.PINNING_SERVICE_ENDPOINT,
    },
    ipfsGatewayUrl: config.IPFS_GATEWAY_URL,
    ipfsApiUrl: config.IPFS_API_URL,
  });

  const Ethernauts = await getContractAt('Ethernauts');

  console.log(`Listening for events on Ethernauts token at ${Ethernauts.address}`);

  Ethernauts.on('Transfer', async (from, to, amount, event) => {
    if (from !== '0x0000000000000000000000000000000000000000') return;

    const tokenId = event.args.tokenId.toString();

    console.log(`Mint detected, tokenId: ${tokenId}`);

    // Upload to local ipfs node
    const resultFromLocalIpfsNode = await ipfs.uploadToLocalIpfsNodeFromAssetFile(
      path.join(constants.ASSETS_FOLDER, `${tokenId}.png`),
      {
        name: `${tokenId}.png`,
        description: 'This is an example',
      }
    );

    console.log('resultFromLocalIpfsNode', resultFromLocalIpfsNode);
  });
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
