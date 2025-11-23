async function main() {
  const Token = await ethers.deployContract("RewardToken");
  await Token.waitForDeployment();
  console.log("Token:", await Token.getAddress());

  const NFT = await ethers.deployContract("MysteryNFT");
  await NFT.waitForDeployment();
  console.log("NFT:", await NFT.getAddress());

  const LuckyDraw = await ethers.deployContract("LuckyDraw", [
    await Token.getAddress(),
    await NFT.getAddress(),
  ]);
  await LuckyDraw.waitForDeployment();
  console.log("LuckyDraw:", await LuckyDraw.getAddress());
}

main();
