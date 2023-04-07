import pkg from 'hardhat';

const { ethers } = pkg;


async function main() {
  const network = await hre.network;

  const gatewayContract =
    network.config.chainId == 43113
      ? "0x517f256cc48145c25c27cf453f6f5006e5266543"
      : "0x8EA05371Eb360Eb79c295375CB2cCE9191EFdaD0";

  const tokenId = network.config.chainId == 43113 ? 1 : 2;

  const MintNft = await ethers.getContractFactory("MintNft");

  const mintNft = await MintNft.deploy(
    gatewayContract,
    1000000,
    tokenId
  );

  await mintNft.deployed();

  console.log("mintNft deployed to:", mintNft.address);

  console.log("Sleeping.....");
  await sleep(40000);

  await hre.run("verify:verify", {
    address: mintNft.address,
    constructorArguments: [gatewayContract, 1000000, tokenId],
  });
}
function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exitCode = 1;
  });
