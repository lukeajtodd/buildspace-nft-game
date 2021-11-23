import { ethers } from "hardhat";

const main = async () => {
  const gameContractFactory = await ethers.getContractFactory("Game");
  const gameContract = await gameContractFactory.deploy(
    ["Tidus", "Wakka", "Yuna"],
    [
      "https://i.imgur.com/mUDc2KQ.gif",
      "https://i.imgur.com/iCBiadT.jpeg",
      "https://i.imgur.com/kvCZI4B.jpeg",
    ],
    [150, 300, 100],
    [80, 50, 120]
  );
  await gameContract.deployed();
  console.log("Contract deployed to:", gameContract.address);

  const txn = await gameContract.mintCharacterNFT(2);
  await txn.wait();

  const returnedTokenUri = await gameContract.tokenURI(1);
  console.log("Token URI:", returnedTokenUri);
};

const runMain = async () => {
  try {
    await main();
    process.exitCode = 0;
  } catch (error) {
    console.error(error);
    process.exitCode = 1;
  }
};

runMain();
