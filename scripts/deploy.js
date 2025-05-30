const hre = require("hardhat");

async function main() {
  const ticketPriceInEth = "0.01"; // Adjust as needed
  const drawDelayInSeconds = 3600; // 1 hour

  const ArtChance = await hre.ethers.getContractFactory("ArtChance");
  const artChance = await ArtChance.deploy(
    hre.ethers.utils.parseEther(ticketPriceInEth),
    drawDelayInSeconds
  );

  await artChance.deployed();
  console.log("ArtChance contract deployed to:", artChance.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
