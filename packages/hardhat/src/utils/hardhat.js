function _getNetworkToken() {
  const { token } = require(`../../deployments/${hre.network.name}.json`);
  if (!token) throw new Error('No token data found, you need to deploy first');
  return token;
}

exports.getContractAt = async function getContractAt(contractName) {
  return await hre.ethers.getContractAt(contractName, _getNetworkToken());
};

exports.getContractFromAbi = async function getContractFromAbi(contractName) {
  const { abi } = require(`../../artifacts/contracts/${contractName}.sol/${contractName}.json`);
  return await hre.ethers.getContractAt(abi, _getNetworkToken());
};
